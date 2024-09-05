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

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}")
  set(NVBench_TOPLEVEL_PROJECT ON)
else()
  set(NVBench_TOPLEVEL_PROJECT OFF)
endif()

include(cmake/NVBenchRapidsCMake.cmake)
nvbench_load_rapids_cmake()

project(NVBench
  LANGUAGES CXX HIP
  VERSION 0.1.0
)

nvbench_init_rapids_cmake()

# See NVIDIA/NVBench#52
find_package(HIP REQUIRED)

option(NVBench_ENABLE_TESTING "Build NVBench testing suite." ON)
option(NVBench_ENABLE_DEVICE_TESTING
  "Include tests that require a GPU (with locked clocks)."
  OFF
)
option(NVBench_ENABLE_EXAMPLES "Build NVBench examples." OFF)

include(cmake/NVBenchConfigTarget.cmake)
include(cmake/NVBenchDependentDlls.cmake)
include(cmake/NVBenchExports.cmake)
include(cmake/NVBenchWriteConfigHeader.cmake)
include(cmake/NVBenchDependencies.cmake)
include(cmake/NVBenchInstallRules.cmake)
include(cmake/NVBenchUtilities.cmake)
include(cmake/NVBenchLibhipcxx.cmake)

# synchronize HIP and CUDA architectures
if (DEFINED CMAKE_HIP_ARCHITECTURES AND NOT CMAKE_CUDA_ARCHITECTURES)
  set(CMAKE_CUDA_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES})
elseif (DEFINED CMAKE_CUDA_ARCHITECTURES AND NOT CMAKE_HIP_ARCHITECTURES)
  set(CMAKE_HIP_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES})
endif()
message(STATUS "NVBench CUDA architectures: ${CMAKE_CUDA_ARCHITECTURES}")

add_subdirectory(nvbench)

if (NVBench_ENABLE_EXAMPLES OR NVBench_ENABLE_TESTING)
  enable_testing()
endif()

add_subdirectory(exec)

if (NVBench_ENABLE_EXAMPLES)
  add_subdirectory(examples)
endif()

if (NVBench_ENABLE_TESTING)
  add_subdirectory(testing)
endif()

nvbench_generate_exports()
