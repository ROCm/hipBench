#include "hip/hip_runtime.h"
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

#include <hip/std/chrono>

#include <hip/hip_runtime.h>

/*!
 * @file test_kernels.cuh
 * A collection of simple kernels for testing purposes.
 *
 * Note that these kernels are written to be short and simple, not performant.
 */

namespace nvbench
{

/*!
 * Each launched thread just sleeps for `seconds`.
 */
__global__ void sleep_kernel(double seconds)
{
  const auto start = hip::std::chrono::high_resolution_clock::now();
  const auto ns =
    hip::std::chrono::nanoseconds(static_cast<nvbench::int64_t>(seconds * 1000 * 1000 * 1000));
  const auto finish = start + ns;

  auto now = hip::std::chrono::high_resolution_clock::now();
  while (now < finish)
  {
    now = hip::std::chrono::high_resolution_clock::now();
  }
}

/*!
 * Naive copy of `n` values from `in` -> `out`.
 */
template <typename T, typename U>
__global__ void copy_kernel(const T *in, U *out, std::size_t n)
{
  const auto init = blockIdx.x * blockDim.x + threadIdx.x;
  const auto step = blockDim.x * gridDim.x;

  for (auto i = init; i < n; i += step)
  {
    out[i] = static_cast<U>(in[i]);
  }
}

/*!
 * For `i <- [0,n)`, `out[i] = in[i] % 2`.
 */
template <typename T, typename U>
__global__ void mod2_kernel(const T *in, U *out, std::size_t n)
{
  const auto init = blockIdx.x * blockDim.x + threadIdx.x;
  const auto step = blockDim.x * gridDim.x;

  for (auto i = init; i < n; i += step)
  {
    out[i] = static_cast<U>(in[i] % 2);
  }
}

} // namespace nvbench
