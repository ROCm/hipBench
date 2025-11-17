/*
 *  Copyright 2025 NVIDIA Corporation
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
//
// Modifications Copyright (C) 2023-2025 Advanced Micro Devices, Inc. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <nvbench/cuda_call.cuh>
#include <nvbench/cuda_stream.cuh>
#include <nvbench/detail/timestamps_kernel.cuh>
#include <nvbench/types.cuh>

#include <nvbench/cuda_runtime.h>

#include <cstdio>
#include <cstdlib>
#include <cuda/std/chrono>

namespace
{

__global__ void get_timestamps_kernel(nvbench::uint64_t *global_timestamp,
                                      nvbench::uint64_t *sm0_timestamp)
{
#ifdef __CUDA_ARCH__
  nvbench::uint32_t smid;
  asm volatile("mov.u32 %0, %%smid;" : "=r"(smid));
  if (smid == 0)
  {
    nvbench::uint64_t gts, lts;
    asm volatile("mov.u64 %0, %%globaltimer;" : "=l"(gts));
    lts = clock64();

    *global_timestamp = gts;
    *sm0_timestamp    = lts;
  }
#elif defined(__HIP_DEVICE_COMPILE__) || defined(__HIPCC_RTC__)
  using namespace cuda::std::chrono;
  nvbench::uint64_t gts, lts;
  // NOTE(HIP/AMD): gts is not a UNIX timestamp 
  // (it is only used to detect GPU throttling).
  gts = static_cast<nvbench::uint64_t>(
          cuda::std::chrono::duration_cast<cuda::std::chrono::nanoseconds>(
            cuda::std::chrono::system_clock::now().time_since_epoch()
          ).count());
  lts = clock64();

  *global_timestamp = gts;
  *sm0_timestamp    = lts;
#endif
}

} // namespace

namespace nvbench::detail
{

timestamps_kernel::timestamps_kernel()
{
  NVBENCH_CUDA_CALL(
    cudaHostRegister(&m_host_timestamps, sizeof(nvbench::uint64_t) * 2, cudaHostRegisterMapped));
  NVBENCH_CUDA_CALL(cudaHostGetDevicePointer((void**)&m_device_timestamps, &m_host_timestamps, 0));
}

timestamps_kernel::~timestamps_kernel()
{
  NVBENCH_CUDA_CALL_NOEXCEPT(cudaHostUnregister(&m_host_timestamps));
}

void timestamps_kernel::record(const nvbench::cuda_stream &stream)
{
  m_host_timestamps[0] = 0;
  m_host_timestamps[1] = 0;

  int device_id = 0;
  int num_sms   = 0;

  NVBENCH_CUDA_CALL(cudaGetDevice(&device_id));
  NVBENCH_CUDA_CALL(cudaDeviceGetAttribute(&num_sms, cudaDevAttrMultiProcessorCount, device_id));

  get_timestamps_kernel<<<static_cast<unsigned int>(num_sms), 1, 0, stream.get_stream()>>>(
    m_device_timestamps,
    m_device_timestamps + 1);
}

} // namespace nvbench::detail
