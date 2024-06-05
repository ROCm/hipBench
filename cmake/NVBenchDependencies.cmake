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

################################################################################
# fmtlib/fmt
rapids_cpm_find(fmt 9.1.0
  CPM_ARGS
    GITHUB_REPOSITORY fmtlib/fmt
    GIT_TAG 9.1.0
    GIT_SHALLOW TRUE
    OPTIONS
      # Force static to keep fmt internal.
      "BUILD_SHARED_LIBS OFF"
      "CMAKE_POSITION_INDEPENDENT_CODE ON"
)

if(TARGET fmt::fmt AND NOT TARGET fmt)
  add_library(fmt ALIAS fmt::fmt)
endif()

################################################################################
# nlohmann/json
#
# Following recipe from
# http://github.com/cpm-cmake/CPM.cmake/blob/master/examples/json/CMakeLists.txt
# Download the zips because the repo takes an excessively long time to clone.
rapids_cpm_find(nlohmann_json 3.9.1
  # Release:
  CPM_ARGS
    URL https://github.com/nlohmann/json/releases/download/v3.9.1/include.zip
    URL_HASH SHA256=6bea5877b1541d353bd77bdfbdb2696333ae5ed8f9e8cc22df657192218cad91
    PATCH_COMMAND
      # Work around compiler bug in nvcc 11.0, see NVIDIA/NVBench#18
      ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/patches/nlohmann_json.hpp"
        "./include/nlohmann/json.hpp"

  # Development version:
  # I'm waiting for https://github.com/nlohmann/json/issues/2676 to be fixed,
  # leave this in to simplify testing patches as they come out.
  #  CPM_ARGS
  #    VERSION develop
  #    URL https://github.com/nlohmann/json/archive/refs/heads/develop.zip
  #    OPTIONS JSON_MultipleHeaders ON
)

add_library(nvbench_json INTERFACE IMPORTED)
if (TARGET nlohmann_json::nlohmann_json)
  # If we have a target, just use it. Cannot be an ALIAS library because
  # nlohmann_json::nlohmann_json itself might be one.
  target_link_libraries(nvbench_json INTERFACE nlohmann_json::nlohmann_json)
else()
  # Otherwise we only downloaded the headers.
  target_include_directories(nvbench_json SYSTEM INTERFACE
    "${nlohmann_json_SOURCE_DIR}/include"
  )
endif()

################################################################################
# CUDAToolkit
rapids_find_package(HIP REQUIRED
  BUILD_EXPORT_SET nvbench-targets
  INSTALL_EXPORT_SET nvbench-targets
)

# Append CTK targets to this as we add optional deps
set(ctk_libraries hip::host)
################################################################################
# Libhipcxx
include("${CMAKE_CURRENT_LIST_DIR}/NVBenchLibhipcxx.cmake")
list(APPEND ctk_libraries libhipcxx::libhipcxx hip::host)
################################################################################
