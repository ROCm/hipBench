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

#include <nvbench/type_list.cuh>
#include <nvbench/type_strings.cuh>

#include <type_traits>

namespace nvbench
{

/*!
 * Convert an enum to a type, allowing it to be used as a compile-time
 * parameter.
 *
 * See the enums.cu example for usage.
 *
 * \relatesalso enum_type_list
 * \relatesalso NVBENCH_DECLARE_ENUM_TYPE_STRINGS
 */
template <auto Value, typename T = decltype(Value)>
struct enum_type : std::integral_constant<T, Value>
{};

/*!
 * \brief Helper utility that generates a `type_list` of
 * `std::integral_constant`s.
 *
 * See the enums.cu example for usage.
 *
 * \relatesalso enum_type
 * \relatesalso NVBENCH_DECLARE_ENUM_TYPE_STRINGS
 */
template <auto... Ts>
using enum_type_list = nvbench::type_list<enum_type<Ts>...>;

// Specialize nvbench::type_strings for generic `enum_type<...>`:
template <typename T, T Value>
struct type_strings<nvbench::enum_type<Value, T>>
{
  static std::string input_string()
  {
    if constexpr (std::is_enum_v<T>)
    {
      return std::to_string(static_cast<std::underlying_type_t<T>>(Value));
    }
    return std::to_string(Value);
  }

  static std::string description() { return nvbench::demangle<nvbench::enum_type<Value, T>>(); }
};

} // namespace nvbench

/*!
 * \brief Declare `type_string`s for an `enum_type_list`.
 *
 * Given an enum type `T` and two callables that produce input and description
 * strings, declare a specialization for
 * `nvbench::type_string<std::integral_constant<T, Value>>`.
 *
 * Must be used from global namespace scope.
 *
 * See the enums.cu example for usage.
 *
 * \relatesalso enum_type_list
 * \relatesalso nvbench::enum_type_list
 */
#define NVBENCH_DECLARE_ENUM_TYPE_STRINGS(T, input_generator, description_generator)               \
  namespace nvbench                                                                                \
  {                                                                                                \
  template <T Value>                                                                               \
  struct type_strings<enum_type<Value, T>>                                                         \
  {                                                                                                \
    static std::string input_string() { return input_generator(Value); }                           \
    static std::string description() { return description_generator(Value); }                      \
  };                                                                                               \
  }
