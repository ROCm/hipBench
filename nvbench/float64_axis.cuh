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

#include <nvbench/axis_base.cuh>

#include <nvbench/types.cuh>

#include <vector>

namespace nvbench
{

struct float64_axis final : public axis_base
{
  explicit float64_axis(std::string name)
      : axis_base{std::move(name), axis_type::float64}
      , m_values{}
  {}

  ~float64_axis() final;

  void set_inputs(std::vector<nvbench::float64_t> inputs) { m_values = std::move(inputs); }
  [[nodiscard]] nvbench::float64_t get_value(std::size_t i) const { return m_values[i]; }

private:
  std::unique_ptr<axis_base> do_clone() const { return std::make_unique<float64_axis>(*this); }
  std::size_t do_get_size() const final { return m_values.size(); }
  std::string do_get_input_string(std::size_t i) const final;
  std::string do_get_description(std::size_t i) const final;

  std::vector<nvbench::float64_t> m_values;
};

} // namespace nvbench
