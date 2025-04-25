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

set_source_files_properties(nvbench-ctl.hip
	                PROPERTIES LANGUAGE HIP)

add_executable(nvbench.ctl nvbench-ctl.hip)
nvbench_config_target(nvbench.ctl)
target_link_libraries(nvbench.ctl PRIVATE nvbench hip::host)
set_target_properties(nvbench.ctl PROPERTIES
  OUTPUT_NAME nvbench-ctl
  EXPORT_NAME ctl
)
add_dependencies(nvbench.all nvbench.ctl)
nvbench_install_executables(nvbench.ctl)

if (NVBench_ENABLE_TESTING)
  # Test: nvbench
  add_test(NAME nvbench.ctl.no_args COMMAND "$<TARGET_FILE:nvbench.ctl>")
  # Should print the version without any args:
  set_property(TEST nvbench.ctl.no_args
    PROPERTY PASS_REGULAR_EXPRESSION "NVBench v"
  )

  # Test: nvbench --version
  add_test(NAME nvbench.ctl.version COMMAND "$<TARGET_FILE:nvbench.ctl>" --version)
  # Should print the version without any args:
  set_property(TEST nvbench.ctl.version
    PROPERTY PASS_REGULAR_EXPRESSION "NVBench v"
  )

  # Test: nvbench --list
  add_test(NAME nvbench.ctl.list COMMAND "$<TARGET_FILE:nvbench.ctl>" --list)

  # Test: nvbench -l
  add_test(NAME nvbench.ctl.l COMMAND "$<TARGET_FILE:nvbench.ctl>" -l)

  # Test: nvbench --help
  add_test(NAME nvbench.ctl.help COMMAND "$<TARGET_FILE:nvbench.ctl>" --help)

  # Test: nvbench -h
  add_test(NAME nvbench.ctl.h COMMAND "$<TARGET_FILE:nvbench.ctl>" -h)

  # Test: nvbench --help-axes
  add_test(NAME nvbench.ctl.help_axes COMMAND "$<TARGET_FILE:nvbench.ctl>" --help-axes)

  # Test: nvbench --help-axis
  add_test(NAME nvbench.ctl.help_axis COMMAND "$<TARGET_FILE:nvbench.ctl>" --help-axis)
endif()
