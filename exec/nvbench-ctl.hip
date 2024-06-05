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

#include <nvbench/main.cuh>

#include <vector>

int main(int argc, char const *const *argv)
try
{
  // If no args, substitute a new argv that prints the version
  std::vector<const char*> alt_argv;
  if (argc == 1)
  {
    alt_argv.push_back("--version");
    alt_argv.push_back(nullptr);
    argv = alt_argv.data();
  }

  NVBENCH_MAIN_PARSE(argc, argv);
  NVBENCH_CUDA_CALL(hipDeviceReset());
  return 0;
}
catch (std::exception & e)
{
  std::cerr << "\nNVBench encountered an error:\n\n" << e.what() << "\n";
  return 1;
}
catch (...)
{
  std::cerr << "\nNVBench encountered an unknown error.\n";
  return 1;
}
