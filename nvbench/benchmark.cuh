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

#include <nvbench/benchmark_base.cuh>

#include <nvbench/axes_metadata.cuh>
#include <nvbench/runner.cuh>
#include <nvbench/type_list.cuh>

#include <string>
#include <vector>

namespace nvbench
{

/**
 * Holds a complete benchmark specification: a KernelGenerator and parameter
 * axes.
 *
 * Creation and configuration of this class is documented in the NVBench
 * [README](../README.md) file. Refer to that for usage details.
 *
 * This class is purposefully kept small to reduce the amount of template code
 * generated for each benchmark. Most of the functionality is implemented in
 * nvbench::benchmark_base -- this class only holds type aliases related to the
 * `KernelGenerator` and `TypeAxes` parameters, and exposes them to
 * `benchmark_base` through a private virtual API.
 *
 * Delegates responsibilities to the following classes:
 * - nvbench::benchmark_base: all non-templated benchmark handling.
 *
 * @tparam KernelGenerator See the [README](../README.md).
 * @tparam TypeAxes A `nvbench::type_list` of `nvbench::type_list`s. See the
 * [README](../README.md) for more details.
 */
template <typename KernelGenerator, typename TypeAxes = nvbench::type_list<>>
struct benchmark final : public benchmark_base
{
  using kernel_generator = KernelGenerator;
  using type_axes        = TypeAxes;
  using type_configs     = nvbench::tl::cartesian_product<type_axes>;

  static constexpr std::size_t num_type_configs = nvbench::tl::size<type_configs>{};

  benchmark()
      : benchmark_base(type_axes{})
  {}

private:
  std::unique_ptr<benchmark_base> do_clone() const final { return std::make_unique<benchmark>(); }

  void do_set_type_axes_names(std::vector<std::string> names) final
  {
    m_axes.set_type_axes_names(std::move(names));
  }

  void do_run() final
  {
    nvbench::runner<benchmark> runner{*this};
    runner.generate_states();
    runner.run();
  }
};

} // namespace nvbench
