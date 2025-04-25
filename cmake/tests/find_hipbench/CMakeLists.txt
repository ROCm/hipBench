# Modifications Copyright (c) 2024 Advanced Micro Devices, Inc.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# 3.20.1 required for rapids-cmake
cmake_minimum_required(VERSION 3.20.1)

project(HipBenchClient
  LANGUAGES CXX HIP
  VERSION 0.0.0
)

option(FIND_NVBENCH "Find package nvbench instead of hipbench." OFF)

if (FIND_NVBENCH)
  find_package(NVBench)
  find_package(nvbench) # NOTE: package name is case insensitive
else()
  find_package(hipbench)
endif()

# works for both
add_executable(nvbench_client source.hip)
target_link_libraries(nvbench_client nvbench::nvbench)

# works only for hipbench
if (NOT FIND_NVBENCH)
  add_executable(hipbench_client source.hip)
  target_link_libraries(hipbench_client hipbench::hipbench)
endif()
