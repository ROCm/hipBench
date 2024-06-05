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

#include <nvbench/types.cuh>

namespace nvbench
{

struct hip_stream;

/**
 * Blocks a CUDA stream -- many sharp edges, read docs carefully.
 *
 * @warning This helper breaks the CUDA programming model and will cause
 * deadlocks if misused. It should not be used outside of benchmarking.
 * See caveats section below.
 *
 * This is used to improve the precision of timing with CUDA events. Consider
 * the following pattern for timing a kernel launch:
 *
 * ```
 * NVBENCH_CUDA_CALL(hipEventRecord(start_event));
 * my_kernel<<<...>>>();
 * NVBENCH_CUDA_CALL(hipEventRecord(stop_event));
 * ```
 *
 * The `start_event` may be recorded a non-trivial amount of time before
 * `my_kernel` is ready to launch due to various work submission latencies. To
 * reduce the impact of these latencies, blocking_kernel can be used to prevent
 * the `start_event` from being recorded until all work is queued:
 *
 * ```
 * blocking_kernel blocker;
 * blocker.block(stream);
 *
 * NVBENCH_CUDA_CALL(hipEventRecord(start_event));
 * my_kernel<<<...>>>();
 * NVBENCH_CUDA_CALL(hipEventRecord(stop_event))
 *
 * blocker.unblock();
 * ```
 *
 * The work submitted after `blocker.block(stream)` will not execute until
 * `blocker.unblock()` is called.
 *
 * ## Timeout
 *
 * The `block` method takes a `timeout` argument. If this is greater than 0,
 * the blocking kernel will print an error message and unblock after `timeout`
 * seconds.
 *
 * ## Caveats and warnings
 *
 * - Every call to `block()` must be followed by a call to `unblock()`.
 * - Do not queue "too much" work while blocking.
 *   - Amount of work depends on device and driver.
 *   - Do tests and schedule conservatively (~32 kernel launches max).
 * - This helper does NOT guarantee that the work submitted while blocking will
 *   execute uninterrupted.
 *   - Kernels on other streams may run between the `hipEventRecord` calls
 *     in the above example.
 */
struct blocking_kernel
{
  blocking_kernel();
  ~blocking_kernel();

  void block(const nvbench::hip_stream &stream, nvbench::float64_t timeout);

  __forceinline__ void unblock()
  {
    volatile nvbench::int32_t &flag = m_host_flag;
    flag                            = 1;

    const volatile nvbench::int32_t &timeout_flag = m_host_timeout_flag;
    if (timeout_flag)
    {
      blocking_kernel::timeout_detected();
    }
  }

  // move-only
  blocking_kernel(const blocking_kernel &)            = delete;
  blocking_kernel(blocking_kernel &&)                 = default;
  blocking_kernel &operator=(const blocking_kernel &) = delete;
  blocking_kernel &operator=(blocking_kernel &&)      = default;

private:
  nvbench::int32_t m_host_flag{};
  nvbench::int32_t m_host_timeout_flag{};
  nvbench::int32_t *m_device_flag{};
  nvbench::int32_t *m_device_timeout_flag{};

  static void timeout_detected();
};

} // namespace nvbench
