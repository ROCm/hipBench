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

#pragma once

#include <nvbench/cuda_call.cuh>

#include <nvbench/types.cuh>

#include <hip/hip_runtime_api.h>

namespace nvbench
{

struct cuda_timer
{
  __forceinline__ cuda_timer()
  {
    NVBENCH_CUDA_CALL(hipEventCreate(&m_start));
    NVBENCH_CUDA_CALL(hipEventCreate(&m_stop));
  }

  __forceinline__ ~cuda_timer()
  {
    NVBENCH_CUDA_CALL(hipEventDestroy(m_start));
    NVBENCH_CUDA_CALL(hipEventDestroy(m_stop));
  }

  // move-only
  cuda_timer(const cuda_timer &)            = delete;
  cuda_timer(cuda_timer &&)                 = default;
  cuda_timer &operator=(const cuda_timer &) = delete;
  cuda_timer &operator=(cuda_timer &&)      = default;

  __forceinline__ void start(hipStream_t stream)
  {
    NVBENCH_CUDA_CALL(hipEventRecord(m_start, stream));
  }

  __forceinline__ void stop(hipStream_t stream)
  {
    NVBENCH_CUDA_CALL(hipEventRecord(m_stop, stream));
  }

  [[nodiscard]] __forceinline__ bool ready() const
  {
    const hipError_t state = hipEventQuery(m_stop);
    if (state == hipErrorNotReady)
    {
      return false;
    }
    NVBENCH_CUDA_CALL(state);
    return true;
  }

  // In seconds:
  [[nodiscard]] __forceinline__ nvbench::float64_t get_duration() const
  {
    NVBENCH_CUDA_CALL(hipEventSynchronize(m_stop));
    float elapsed_time;
    // According to docs, this is in ms with a resolution of ~0.5 microseconds.
    NVBENCH_CUDA_CALL(hipEventElapsedTime(&elapsed_time, m_start, m_stop));
    return elapsed_time / 1000.0;
  }

private:
  hipEvent_t m_start;
  hipEvent_t m_stop;
};

} // namespace nvbench
