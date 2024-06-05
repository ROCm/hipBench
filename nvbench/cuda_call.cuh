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

#include <hip/hip_runtime.h>
#include <hip/hip_runtime_api.h>

#include <string>

/// Throws a std::runtime_error if `call` doesn't return `hipSuccess`.
#define NVBENCH_CUDA_CALL(call)                                                                    \
  do                                                                                               \
  {                                                                                                \
    const hipError_t nvbench_cuda_call_error = call;                                              \
    if (nvbench_cuda_call_error != hipSuccess)                                                    \
    {                                                                                              \
      nvbench::cuda_call::throw_error(__FILE__, __LINE__, #call, nvbench_cuda_call_error);         \
    }                                                                                              \
  } while (false)

/// Throws a std::runtime_error if `call` doesn't return `hipSuccess`.
#define NVBENCH_DRIVER_API_CALL(call)                                                              \
  do                                                                                               \
  {                                                                                                \
    const hipError_t nvbench_cuda_call_error = call;                                                 \
    if (nvbench_cuda_call_error != hipSuccess)                                                   \
    {                                                                                              \
      nvbench::cuda_call::throw_error(__FILE__, __LINE__, #call, nvbench_cuda_call_error);         \
    }                                                                                              \
  } while (false)

/// Terminates process with failure status if `call` doesn't return
/// `hipSuccess`.
#define NVBENCH_CUDA_CALL_NOEXCEPT(call)                                                           \
  do                                                                                               \
  {                                                                                                \
    const hipError_t nvbench_cuda_call_error = call;                                              \
    if (nvbench_cuda_call_error != hipSuccess)                                                    \
    {                                                                                              \
      nvbench::cuda_call::exit_error(__FILE__, __LINE__, #call, nvbench_cuda_call_error);          \
    }                                                                                              \
  } while (false)

namespace nvbench::cuda_call
{

void throw_error(const std::string &filename,
                 std::size_t lineno,
                 const std::string &call,
                 hipError_t error);

void throw_error(const std::string &filename,
                 std::size_t lineno,
                 const std::string &call,
                 hipError_t error);

void exit_error(const std::string &filename,
                std::size_t lineno,
                const std::string &command,
                hipError_t error);

} // namespace nvbench::cuda_call
