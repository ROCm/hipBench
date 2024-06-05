/*
 *  Copyright 2021-2022 NVIDIA Corporation
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

#include <memory>

namespace nvbench
{

/**
 * Manages and provides access to a CUDA stream.
 *
 * May be owning or non-owning. If the stream is owned, it will be freed with
 * `hipStreamDestroy` when the `hip_stream`'s lifetime ends. Non-owning
 * `hip_stream`s are sometimes referred to as views.
 *
 * @sa nvbench::make_cuda_stream_view
 */
struct hip_stream
{
  /**
   * Constructs a hip_stream that owns a new stream, created with
   * `hipStreamCreate`.
   */
  hip_stream()
      : m_stream{[]() {
                   hipStream_t s;
                   NVBENCH_CUDA_CALL(hipStreamCreate(&s));
                   return s;
                 }(),
                 stream_deleter{true}}
  {}

  /**
   * Constructs a `hip_stream` from an explicit hipStream_t.
   *
   * @param owning If true, `hipStreamCreate(stream)` will be called from this
   * `hip_stream`'s destructor.
   *
   * @sa nvbench::make_cuda_stream_view
   */
  hip_stream(hipStream_t stream, bool owning)
      : m_stream{stream, stream_deleter{owning}}
  {}

  ~hip_stream() = default;

  // move-only
  hip_stream(const hip_stream &)            = delete;
  hip_stream &operator=(const hip_stream &) = delete;
  hip_stream(hip_stream &&)                 = default;
  hip_stream &operator=(hip_stream &&)      = default;

  /**
   * @return The `hipStream_t` managed by this `hip_stream`.
   * @{
   */
  operator hipStream_t() const { return m_stream.get(); }

  hipStream_t get_stream() const { return m_stream.get(); }
  /**@}*/

private:
  struct stream_deleter
  {
    using pointer = hipStream_t;
    bool owning;

    constexpr void operator()(pointer s) const noexcept
    {
      if (owning)
      {
        NVBENCH_CUDA_CALL_NOEXCEPT(hipStreamDestroy(s));
      }
    }
  };

  std::unique_ptr<hipStream_t, stream_deleter> m_stream;
};

/**
 * Creates a non-owning view of the specified `stream`.
 */
inline nvbench::hip_stream make_cuda_stream_view(hipStream_t stream)
{
  return hip_stream{stream, false};
}

} // namespace nvbench
