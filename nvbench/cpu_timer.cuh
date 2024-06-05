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

#include <chrono>

namespace nvbench
{

struct cpu_timer
{
  __forceinline__ cpu_timer() = default;

  // move-only
  cpu_timer(const cpu_timer &)            = delete;
  cpu_timer(cpu_timer &&)                 = default;
  cpu_timer &operator=(const cpu_timer &) = delete;
  cpu_timer &operator=(cpu_timer &&)      = default;

  __forceinline__ void start() { m_start = std::chrono::high_resolution_clock::now(); }

  __forceinline__ void stop() { m_stop = std::chrono::high_resolution_clock::now(); }

  // In seconds:
  [[nodiscard]] __forceinline__ nvbench::float64_t get_duration()
  {
    const auto duration = m_stop - m_start;
    const auto ns       = std::chrono::duration_cast<std::chrono::nanoseconds>(duration).count();
    return static_cast<nvbench::float64_t>(ns) * (1e-9);
  }

private:
  std::chrono::high_resolution_clock::time_point m_start;
  std::chrono::high_resolution_clock::time_point m_stop;
};

} // namespace nvbench
