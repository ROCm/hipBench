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

#include <nvbench/detail/transform_reduce.cuh>

#include <cmath>
#include <functional>
#include <iterator>
#include <limits>
#include <type_traits>

namespace nvbench::detail::statistics
{

/**
 * Computes and returns the unbiased sample standard deviation.
 *
 * If the input has fewer than 5 sample, infinity is returned.
 */
template <typename Iter, typename ValueType = typename std::iterator_traits<Iter>::value_type>
ValueType standard_deviation(Iter first, Iter last, ValueType mean)
{
  static_assert(std::is_floating_point_v<ValueType>);

  const auto num = last - first;
  if (num < 5) // don't bother with low sample sizes.
  {
    return std::numeric_limits<ValueType>::infinity();
  }

  const auto variance = nvbench::detail::transform_reduce(first,
                                                          last,
                                                          ValueType{},
                                                          std::plus<>{},
                                                          [mean](auto val) {
                                                            val -= mean;
                                                            val *= val;
                                                            return val;
                                                          }) /
                        static_cast<ValueType>((num - 1));
  return std::sqrt(variance);
}

} // namespace nvbench::detail::statistics
