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

set(example_srcs
  axes.hip
  enums.hip
  exec_tag_sync.hip
  exec_tag_timer.hip
  skip.hip
  stream.hip
  throughput.hip
  auto_throughput.hip
)

# Metatarget for all examples:
add_custom_target(nvbench.example.all)
add_dependencies(nvbench.all nvbench.example.all)

foreach(example_src IN LISTS example_srcs)
  get_filename_component(example_name "${example_src}" NAME_WLE)
  string(PREPEND example_name "nvbench.example.")
  add_executable(${example_name} "${example_src}")
  nvbench_config_target(${example_name})
  target_include_directories(${example_name} PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
  target_link_libraries(${example_name} PRIVATE nvbench::main)
  set_target_properties(${example_name} PROPERTIES COMPILE_FEATURES cuda_std_17)
  add_test(NAME ${example_name}
    COMMAND "$<TARGET_FILE:${example_name}>" --timeout 0.1 --min-time 1e-5
  )

  add_dependencies(nvbench.example.all ${example_name})
endforeach()

# Silence some warnings from old thrust headers:
set(thrust_examples
  auto_throughput
  axes
  exec_tag_sync
  exec_tag_timer
  skip
  throughput
)
