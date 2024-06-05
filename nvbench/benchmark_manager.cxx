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

#include <nvbench/benchmark_manager.cuh>

#include <nvbench/detail/throw.cuh>

#include <fmt/format.h>

#include <algorithm>
#include <stdexcept>

namespace nvbench
{

benchmark_manager &benchmark_manager::get()
{ // Karen's function:
  static benchmark_manager the_manager;
  return the_manager;
}

benchmark_base &benchmark_manager::add(std::unique_ptr<benchmark_base> bench)
{
  m_benchmarks.push_back(std::move(bench));
  return *m_benchmarks.back();
}

benchmark_manager::benchmark_vector benchmark_manager::clone_benchmarks() const
{
  benchmark_vector result(m_benchmarks.size());
  std::transform(m_benchmarks.cbegin(), m_benchmarks.cend(), result.begin(), [](const auto &bench) {
    return bench->clone();
  });
  return result;
}

const benchmark_base &benchmark_manager::get_benchmark(const std::string &name) const
{
  auto iter =
    std::find_if(m_benchmarks.cbegin(), m_benchmarks.cend(), [&name](const auto &bench_ptr) {
      return bench_ptr->get_name() == name;
    });
  if (iter == m_benchmarks.cend())
  {
    NVBENCH_THROW(std::out_of_range, "No benchmark named '{}'.", name);
  }

  return **iter;
}

} // namespace nvbench
