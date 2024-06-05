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

set(test_srcs
  axes_metadata.hip
  benchmark.hip
  create.hip
  cuda_timer.hip
  cpu_timer.hip
  enum_type_list.hip
  float64_axis.hip
  int64_axis.hip
  named_values.hip
  option_parser.hip
  range.hip
  ring_buffer.hip
  runner.hip
  state.hip
  state_generator.hip
  string_axis.hip
  type_axis.hip
  type_list.hip
)

file(GLOB HIP_SOURCES_TEST
	./*.hip)

set_source_files_properties(${HIP_SOURCES_TEST}
                            PROPERTIES LANGUAGE HIP)

# Metatarget for all examples:
add_custom_target(nvbench.test.all)
add_dependencies(nvbench.all nvbench.test.all)

foreach(test_src IN LISTS test_srcs)
  get_filename_component(test_name "${test_src}" NAME_WLE)
  string(PREPEND test_name "nvbench.test.")
  add_executable(${test_name} "${test_src}")
  target_include_directories(${test_name} PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
  target_link_libraries(${test_name} PRIVATE nvbench::nvbench fmt)
  set_target_properties(${test_name} PROPERTIES COMPILE_FEATURES cuda_std_17)
  nvbench_config_target(${test_name})
  add_test(NAME ${test_name} COMMAND "$<TARGET_FILE:${test_name}>")

  add_dependencies(nvbench.test.all ${test_name})
endforeach()

add_subdirectory(cmake)
add_subdirectory(device)
