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

#include <nvbench/cuda_timer.cuh>

#include <nvbench/cuda_stream.cuh>
#include <nvbench/test_kernels.cuh>
#include <nvbench/types.cuh>

#include "test_asserts.cuh"

#include <fmt/format.h>

void test_basic(hipStream_t time_stream,
                hipStream_t exec_stream,
                bool expected)
{
  nvbench::cuda_timer timer;

  NVBENCH_CUDA_CALL(hipDeviceSynchronize());

  timer.start(time_stream);
  nvbench::sleep_kernel<<<1, 1, 0, exec_stream>>>(0.25);
  timer.stop(time_stream);

  NVBENCH_CUDA_CALL(hipDeviceSynchronize());
  const bool captured = timer.get_duration() > 0.25;
  ASSERT_MSG(captured == expected,
             "Unexpected result from timer: {} seconds (expected {})",
             timer.get_duration(),
             (expected ? "> 0.25s" : "< 0.25s"));
}

void test_basic()
{
  nvbench::hip_stream stream1;
  nvbench::hip_stream stream2;

  test_basic(stream1, stream1, true);
  test_basic(stream1, stream2, false);
}

int main() { test_basic(); }
