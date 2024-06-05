/*
 *  Copyright 2021 NVIDIA Corporation 
 *
 *  Licensed under the Apache License, Version 2.0 with the LLVM exception
 *  (the "License"); you may not use this file except in compliance with
 *  the License.
 *
 *  You may obtain a copy of the License at
 *
 *      http://llvm.org/foundation/relicensing/LICENSE.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

// MIT License
// Modifications Copyright (c) 2024 Advanced Micro Devices, Inc.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <nvbench/nvbench.cuh>

// Grab some testing kernels from NVBench:
#include <nvbench/test_kernels.cuh>

// Thrust simplifies memory management, etc:
#include <thrust/copy.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/execution_policy.h>
// mod2_inplace performs an in-place mod2 over every element in `data`. `data`
// is reset to `input` each iteration. A manual timer is requested by passing
// `nvbench::exec_tag::timer` to `state.exec(...)`, which is used to only time
// the mod2, and not the reset.
//
// Note that this disables the batch timings, since the reset phase will throw
// off the batch results.

void mod2_inplace(nvbench::state &state)
{
  // Allocate input data:
  const std::size_t num_values = 64 * 1024 * 1024 / sizeof(nvbench::int32_t);
  thrust::device_vector<nvbench::int32_t> input(num_values);
  thrust::sequence(input.begin(), input.end());

  // Working data buffer:
  thrust::device_vector<nvbench::int32_t> data(num_values);

  // Provide throughput information:
  state.add_element_count(num_values);
  state.add_global_memory_reads<nvbench::int32_t>(num_values);
  state.add_global_memory_writes<nvbench::int32_t>(num_values);

  // Request timer with `nvbench::exec_tag::timer`:
  state.exec(nvbench::exec_tag::timer,
             // Lambda now takes a `timer` argument:
             [&input, &data /*Todo(HIP): , num_values*/](nvbench::launch &launch, auto &timer) {
               // Reset working data:
               thrust::copy(thrust::device.on(launch.get_stream()),
                            input.cbegin(),
                            input.cend(),
                            data.begin());

               // Start timer:
               timer.start();

               // Run kernel of interest:
               nvbench::mod2_kernel<<<256, 256, 0, launch.get_stream()>>>(
                 thrust::raw_pointer_cast(input.data()),
                 thrust::raw_pointer_cast(input.data()),
                 num_values);

               // Stop timer:
               timer.stop();
             });
}
NVBENCH_BENCH(mod2_inplace);
