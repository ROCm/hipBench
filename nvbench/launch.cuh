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

#include <nvbench/cuda_stream.cuh>

namespace nvbench
{

/**
 * Configuration object used to communicate with a `KernelLauncher`.
 *
 * The `KernelLauncher` passed into `nvbench::state::exec` is required to
 * accept an `nvbench::launch` argument:
 *
 * ```cpp
 * state.exec([](nvbench::launch &launch) {
 *   kernel<<<M, N, 0, launch.get_stream()>>>();
 * }
 * ```
 */
struct launch
{
  explicit launch(const nvbench::hip_stream &stream)
      : m_stream{stream}
  {}

  // move-only
  launch(const launch &)            = delete;
  launch(launch &&)                 = default;
  launch &operator=(const launch &) = delete;
  launch &operator=(launch &&)      = delete; // cannot move const nvbench::hip_stream &m_stream

  /**
   * @return a CUDA stream that all kernels and other stream-ordered CUDA work
   * must use. This stream can be changed by the `KernelGenerator` using the
   * `nvbench::state::set_cuda_stream` method.
   */
  __forceinline__ const nvbench::hip_stream &get_stream() const { return m_stream; };

private:
  // The stream is owned by the `nvbench::state` associated with this launch.
  const nvbench::hip_stream &m_stream;
};

} // namespace nvbench
