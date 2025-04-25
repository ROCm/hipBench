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

# Test that we're converging to an accurate mean + stdev without timing out:
set(test_name nvbench.test.device.noisy_bench)
add_executable(${test_name} noisy_bench.hip)
set_source_files_properties(noisy_bench.hip
	                    PROPERTIES LANGUAGE HIP)
target_link_libraries(${test_name} PRIVATE nvbench::main fmt)
nvbench_config_target(${test_name})
add_dependencies(nvbench.test.all ${test_name})

if (NVBench_ENABLE_DEVICE_TESTING)
  add_test(NAME ${test_name} COMMAND "$<TARGET_FILE:${test_name}>")
  set_tests_properties(${test_name} PROPERTIES
    # Any timeouts/warnings are hard failures for this test.
    FAIL_REGULAR_EXPRESSION "Warn;timed out"
  )
endif()
