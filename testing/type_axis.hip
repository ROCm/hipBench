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

#include <nvbench/type_axis.cuh>

#include <nvbench/types.cuh>

#include "test_asserts.cuh"

#include <fmt/format.h>

void test_empty()
{
  nvbench::type_axis axis("Basic", 0);

  ASSERT(axis.get_name() == "Basic");
  ASSERT(axis.get_axis_index() == 0);
  ASSERT(axis.get_type() == nvbench::axis_type::type);
  ASSERT(axis.get_size() == 0);

  axis.set_inputs<nvbench::type_list<>>();

  ASSERT(axis.get_size() == 0);

  const auto clone_base = axis.clone();
  ASSERT(clone_base.get() != nullptr);
  const auto *clone =
    dynamic_cast<const nvbench::type_axis *>(clone_base.get());
  ASSERT(clone != nullptr);

  ASSERT(clone->get_name() == "Basic");
  ASSERT(clone->get_axis_index() == 0);
  ASSERT(clone->get_type() == nvbench::axis_type::type);
  ASSERT(clone->get_size() == 0);
}

void test_single()
{
  nvbench::type_axis axis("Single", 0);
  axis.set_inputs<nvbench::type_list<nvbench::int32_t>>();

  ASSERT(axis.get_name() == "Single");
  ASSERT(axis.get_size() == 1);
  ASSERT(axis.get_input_string(0) == "I32");
  ASSERT(axis.get_description(0) == "int32_t");
  ASSERT(axis.get_is_active("I32") == true);
  ASSERT(axis.get_is_active(0) == true);

  auto clone_base = axis.clone();
  ASSERT(clone_base.get() != nullptr);
  auto *clone =
    dynamic_cast<nvbench::type_axis *>(clone_base.get());
  ASSERT(clone != nullptr);

  ASSERT(clone->get_name() == "Single");
  ASSERT(clone->get_size() == 1);
  ASSERT(clone->get_input_string(0) == "I32");
  ASSERT(clone->get_description(0) == "int32_t");
  ASSERT(clone->get_is_active("I32") == true);
  ASSERT(clone->get_is_active(0) == true);

  clone->set_active_inputs({});
  ASSERT(clone->get_name() == "Single");
  ASSERT(clone->get_size() == 1);
  ASSERT(clone->get_input_string(0) == "I32");
  ASSERT(clone->get_description(0) == "int32_t");
  ASSERT(clone->get_is_active("I32") == false);
  ASSERT(clone->get_is_active(0) == false);
  // The original property should not be modified:
  ASSERT(axis.get_is_active("I32") == true);
  ASSERT(axis.get_is_active(0) == true);

  clone->set_active_inputs({"I32"});
  ASSERT(clone->get_name() == "Single");
  ASSERT(clone->get_size() == 1);
  ASSERT(clone->get_input_string(0) == "I32");
  ASSERT(clone->get_description(0) == "int32_t");
  ASSERT(clone->get_is_active("I32") == true);
  ASSERT(clone->get_is_active(0) == true);
  // The original property should not be modified:
  ASSERT(axis.get_is_active("I32") == true);
  ASSERT(axis.get_is_active(0) == true);

  ASSERT_THROWS_ANY(clone->set_active_inputs({"NotAValidEntry"}));
}

void test_several()
{
  nvbench::type_axis axis("Several", 0);
  axis.set_inputs<
    nvbench::type_list<nvbench::int32_t, nvbench::float64_t, bool>>();

  ASSERT(axis.get_name() == "Several");
  ASSERT(axis.get_size() == 3);
  ASSERT(axis.get_input_string(0) == "I32");
  ASSERT(axis.get_description(0) == "int32_t");
  ASSERT(axis.get_is_active(0) == true);
  ASSERT(axis.get_is_active("I32") == true);
  ASSERT(axis.get_input_string(1) == "F64");
  ASSERT(axis.get_description(1) == "double");
  ASSERT(axis.get_is_active(1) == true);
  ASSERT(axis.get_is_active("F64") == true);
  ASSERT(axis.get_input_string(2) == "bool");
  ASSERT(axis.get_description(2) == "");
  ASSERT(axis.get_is_active(2) == true);
  ASSERT(axis.get_is_active("bool") == true);

  auto clone_base = axis.clone();
  ASSERT(clone_base.get() != nullptr);
  auto *clone =
    dynamic_cast<nvbench::type_axis *>(clone_base.get());
  ASSERT(clone != nullptr);

  ASSERT(clone->get_name() == "Several");
  ASSERT(clone->get_size() == 3);
  ASSERT(clone->get_input_string(0) == "I32");
  ASSERT(clone->get_description(0) == "int32_t");
  ASSERT(clone->get_is_active(0) == true);
  ASSERT(clone->get_is_active("I32") == true);
  ASSERT(clone->get_input_string(1) == "F64");
  ASSERT(clone->get_description(1) == "double");
  ASSERT(clone->get_is_active(1) == true);
  ASSERT(clone->get_is_active("F64") == true);
  ASSERT(clone->get_input_string(2) == "bool");
  ASSERT(clone->get_description(2) == "");
  ASSERT(clone->get_is_active(2) == true);
  ASSERT(clone->get_is_active("bool") == true);

  clone->set_active_inputs({"I32", "bool"});
  ASSERT(clone->get_name() == "Several");
  ASSERT(clone->get_size() == 3);
  ASSERT(clone->get_input_string(0) == "I32");
  ASSERT(clone->get_description(0) == "int32_t");
  ASSERT(clone->get_is_active(0) == true);
  ASSERT(clone->get_is_active("I32") == true);
  ASSERT(clone->get_input_string(1) == "F64");
  ASSERT(clone->get_description(1) == "double");
  ASSERT(clone->get_is_active(1) == false);
  ASSERT(clone->get_is_active("F64") == false);
  ASSERT(clone->get_input_string(2) == "bool");
  ASSERT(clone->get_description(2) == "");
  ASSERT(clone->get_is_active(2) == true);
  ASSERT(clone->get_is_active("bool") == true);

  // The cloned axis should not change:
  ASSERT(axis.get_name() == "Several");
  ASSERT(axis.get_size() == 3);
  ASSERT(axis.get_input_string(0) == "I32");
  ASSERT(axis.get_description(0) == "int32_t");
  ASSERT(axis.get_is_active(0) == true);
  ASSERT(axis.get_is_active("I32") == true);
  ASSERT(axis.get_input_string(1) == "F64");
  ASSERT(axis.get_description(1) == "double");
  ASSERT(axis.get_is_active(1) == true);
  ASSERT(axis.get_is_active("F64") == true);
  ASSERT(axis.get_input_string(2) == "bool");
  ASSERT(axis.get_description(2) == "");
  ASSERT(axis.get_is_active(2) == true);
  ASSERT(axis.get_is_active("bool") == true);
}

void test_get_type_index()
{
  nvbench::type_axis axis("GetIndexTest", 0);
  axis.set_inputs<
    nvbench::
      type_list<nvbench::int8_t, nvbench::uint16_t, nvbench::float32_t, bool>>();

  ASSERT(axis.get_type_index("I8") == 0);
  ASSERT(axis.get_type_index("U16") == 1);
  ASSERT(axis.get_type_index("F32") == 2);
  ASSERT(axis.get_type_index("bool") == 3);

  const auto clone_base = axis.clone();
  ASSERT(clone_base.get() != nullptr);
  const auto *clone =
    dynamic_cast<const nvbench::type_axis *>(clone_base.get());
  ASSERT(clone != nullptr);

  ASSERT(clone->get_type_index("I8") == 0);
  ASSERT(clone->get_type_index("U16") == 1);
  ASSERT(clone->get_type_index("F32") == 2);
  ASSERT(clone->get_type_index("bool") == 3);
}

int main()
{
  test_empty();
  test_single();
  test_several();
  test_get_type_index();
}
