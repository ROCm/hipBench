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

cmake_minimum_required(VERSION 3.20.1)
project(NVBenchTestExport CUDA CXX)

message(STATUS "NVBench_DIR=${NVBench_DIR}")
find_package(NVBench REQUIRED)

add_executable(test_bench test_bench.hip)
target_link_libraries(test_bench PRIVATE nvbench::main)
enable_testing()
add_test(NAME test_bench COMMAND "$<TARGET_FILE:test_bench>" --timeout 1)
add_test(NAME nvbench_ctl COMMAND "$<TARGET_FILE:nvbench::ctl>")

# Setup LD_LIBRARY_PATH for testing
if (UNIX)
  set(ctl_lib_path "")

  # Need to find installed libnvbench.so for installed nvbench-ctl.
  # Not needed for build_tree test because of RUNPATH.
  if (TEST_TYPE STREQUAL "INSTALL_TREE")
    get_property(nvbench_config TARGET nvbench::nvbench
      PROPERTY IMPORTED_CONFIGURATIONS
    )

    list(LENGTH nvbench_config num_configs)
    if (num_configs GREATER 1)
      message(WARNING
        "Multiple IMPORTED_CONFIGURATIONS for nvbench::nvbench. "
        "Picking the first one. This may cause issues."
      )
      list(GET nvbench_config 0 nvbench_config)
    endif()

    get_property(ctl_lib_path TARGET nvbench::nvbench
      PROPERTY IMPORTED_LOCATION_${nvbench_config}
    )
    cmake_path(GET ctl_lib_path PARENT_PATH ctl_lib_path)
  endif()

endif()
