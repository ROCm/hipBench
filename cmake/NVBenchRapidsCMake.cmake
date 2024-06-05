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

# Called before project(...)
macro(nvbench_load_rapids_cmake)
  if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/NVBENCH_RAPIDS.cmake")
    file(DOWNLOAD
    https://$ENV{GITHUB_USER}:$ENV{GITHUB_PASS}@raw.githubusercontent.com/AMD-AI/rapids-cmake/main/RAPIDS.cmake
      "${CMAKE_CURRENT_BINARY_DIR}/NVBENCH_RAPIDS.cmake"
    )
  endif()
  include("${CMAKE_CURRENT_BINARY_DIR}/NVBENCH_RAPIDS.cmake")

  include(rapids-cmake)
  include(rapids-cpm)
  # include(rapids-cuda)
  include(rapids-hip)
  include(rapids-export)
  include(rapids-find)

  rapids_hip_init_architectures(NVBench)
endmacro()

# Called after project(...)
macro(nvbench_init_rapids_cmake)
  rapids_cmake_build_type(Release)
  rapids_cmake_write_version_file("${NVBench_BINARY_DIR}/nvbench/detail/version.cuh")
  rapids_cmake_write_git_revision_file(
    nvbench_git_revision
    "${NVBench_BINARY_DIR}/nvbench/detail/git_revision.cuh"
  )
  rapids_cpm_init()
endmacro()
