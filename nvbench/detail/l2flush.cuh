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

#include <hip/hip_runtime_api.h>

namespace nvbench::detail
{

struct l2flush
{
  __forceinline__ l2flush()
  {
    int dev_id{};
    NVBENCH_CUDA_CALL(hipGetDevice(&dev_id));
    NVBENCH_CUDA_CALL(hipDeviceGetAttribute(&m_l2_size, hipDeviceAttributeL2CacheSize, dev_id));
    if (m_l2_size > 0)
    {
      void *buffer = m_l2_buffer;
      NVBENCH_CUDA_CALL(hipMalloc(&buffer, static_cast<size_t>(m_l2_size)));
      m_l2_buffer = reinterpret_cast<int *>(buffer);
    }
  }

  __forceinline__ ~l2flush()
  {
    if (m_l2_buffer)
    {
      NVBENCH_CUDA_CALL_NOEXCEPT(hipFree(m_l2_buffer));
    }
  }

  __forceinline__ void flush(hipStream_t stream)
  {
    if (m_l2_size > 0)
    {
      NVBENCH_CUDA_CALL(hipMemsetAsync(m_l2_buffer, 0, static_cast<size_t>(m_l2_size), stream));
    }
  }

private:
  int m_l2_size{};
  int *m_l2_buffer{};
};

} // namespace nvbench::detail
