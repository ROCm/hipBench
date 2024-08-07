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

#include <nvbench/axes_metadata.cuh>
#include <nvbench/axis_base.cuh>
#include <nvbench/state.cuh>

#include <optional>
#include <string>
#include <utility>
#include <vector>

namespace nvbench
{
struct benchmark_base;
struct device_info;

namespace detail
{

struct state_generator
{
  static std::vector<nvbench::state> create(const benchmark_base &bench);

private:
  explicit state_generator(const benchmark_base &bench);

  void build_axis_configs();
  void build_states();
  void add_states_for_device(const std::optional<nvbench::device_info> &device);

  const benchmark_base &m_benchmark;
  // bool is a mask value; true if the config is used.
  std::vector<std::pair<nvbench::named_values, bool>> m_type_axis_configs;
  std::vector<nvbench::named_values> m_non_type_axis_configs;
  std::vector<nvbench::state> m_states;
};

// Detail class; Generates a cartesian product of axis indices.
// Used by state_generator.
//
// Usage:
// ```
// state_iterator sg;
// sg.add_axis(...);
// for (sg.init(); sg.iter_valid(); sg.next())
// {
//   for (const auto& index : sg.get_current_indices())
//   {
//     std::string axis_name = index.axis;
//     nvbench::axis_type type = index.type;
//     std::size_t value_index = index.index;
//     std::size_t axis_size = index.size;
//   }
// }
// ```
struct state_iterator
{
  struct axis_index
  {
    std::string axis;
    nvbench::axis_type type;
    std::size_t index;
    std::size_t size;
  };

  void add_axis(const nvbench::axis_base &axis);
  void add_axis(std::string axis, nvbench::axis_type type, std::size_t size);
  [[nodiscard]] std::size_t get_number_of_states() const;
  void init();
  [[nodiscard]] const std::vector<axis_index> &get_current_indices() const;
  [[nodiscard]] bool iter_valid() const;
  void next();

  std::vector<axis_index> m_indices;
  std::size_t m_current{};
  std::size_t m_total{};
};

} // namespace detail
} // namespace nvbench
