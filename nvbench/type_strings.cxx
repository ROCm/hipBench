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

#include <nvbench/type_strings.cuh>

#include <fmt/format.h>

#include <string>

#if defined(__GNUC__) || defined(__clang__)
#define NVBENCH_CXXABI_DEMANGLE
#endif

#ifdef NVBENCH_CXXABI_DEMANGLE
#include <cxxabi.h>

#include <cstdlib>
#include <memory>

namespace
{
struct free_wrapper
{
  void operator()(void *ptr) { std::free(ptr); }
};
} // end namespace

#endif // NVBENCH_CXXABI_DEMANGLE

namespace nvbench
{

std::string demangle(const std::string &str)
{
#ifdef NVBENCH_CXXABI_DEMANGLE
  std::unique_ptr<char, free_wrapper> demangled{
    abi::__cxa_demangle(str.c_str(), nullptr, nullptr, nullptr)};
  return std::string(demangled.get());
#else
  return str;
#endif
};

} // namespace nvbench
