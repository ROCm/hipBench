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

set(srcs
  axes_metadata.cxx
  axis_base.cxx
  benchmark_base.cxx
  benchmark_manager.cxx
  blocking_kernel.hip
  csv_printer.hip
  cuda_call.hip
  device_info.hip
  device_manager.hip
  float64_axis.cxx
  int64_axis.cxx
  markdown_printer.hip
  named_values.cxx
  option_parser.hip
  printer_base.cxx
  printer_multiplex.cxx
  runner.cxx
  state.cxx
  string_axis.cxx
  type_axis.cxx
  type_strings.cxx

  detail/measure_cold.hip
  detail/measure_hot.hip
  detail/state_generator.cxx
)

file(GLOB HIP_SOURCES
  ./*.hip
  ./detail/*.hip)

set_source_files_properties(${HIP_SOURCES} state.cxx
	                   PROPERTIES LANGUAGE HIP)

# CUDA 11.0 can't compile json_printer without crashing
# So for that version fall back to C++ with degraded
# output ( no PTX version info )
if(CMAKE_CUDA_COMPILER_ID STREQUAL NVIDIA AND
   CMAKE_CUDA_COMPILER_VERSION VERSION_LESS 11.1)
  set(json_printer_impl json_printer.cxx)
  set(json_is_cu FALSE)
else()
  set(json_printer_impl json_printer.hip)
  set(json_is_cu TRUE)
endif()
list(APPEND srcs ${json_printer_impl})

# Generate doc strings from md files:
include("../cmake/FileToString.cmake")
file_to_string("../docs/cli_help.md"
  "${NVBench_BINARY_DIR}/nvbench/internal/cli_help.cuh"
  ""
  cli_help_text
)
file_to_string("../docs/cli_help_axis.md"
  "${NVBench_BINARY_DIR}/nvbench/internal/cli_help_axis.cuh"
  ""
  cli_help_axis_text
)

nvbench_write_config_header(config.cuh.in
  "${NVBench_BINARY_DIR}/nvbench/config.cuh"
)

# nvbench (nvbench::nvbench)
add_library(nvbench SHARED ${srcs})
nvbench_config_target(nvbench)
target_include_directories(nvbench PUBLIC
  "$<BUILD_INTERFACE:${NVBench_SOURCE_DIR}>"
  "$<BUILD_INTERFACE:${NVBench_BINARY_DIR}>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_link_libraries(nvbench
  PUBLIC
    ${ctk_libraries}
  PRIVATE
    fmt::fmt
    nvbench_json
    nvbench_git_revision
)
target_compile_features(nvbench PUBLIC cuda_std_17 PRIVATE cxx_std_17)
add_dependencies(nvbench.all nvbench)

# nvbench.main (nvbench::main)
add_library(nvbench.main OBJECT main.hip)
nvbench_config_target(nvbench.main)
target_link_libraries(nvbench.main PUBLIC nvbench)
set_target_properties(nvbench.main PROPERTIES EXPORT_NAME main)
add_dependencies(nvbench.all nvbench.main)

# Support add_subdirectory:
add_library(nvbench::nvbench ALIAS nvbench)
add_library(nvbench::main ALIAS nvbench.main)

nvbench_install_libraries(nvbench nvbench.main nvbench.build_interface)

# nvcc emits several unavoidable warnings while compiling nlohmann_json:
if (json_is_cu)
  set_property(SOURCE ${json_printer_impl} APPEND PROPERTY COMPILE_OPTIONS
    # error #186-D: pointless comparison of unsigned integer with zero
    $<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:-Xcudafe=--diag_suppress=186>
    # error #940-D: missing return statement at end of non-void function
    # (the end of the function in hash.hpp(114) is unreachable)
    $<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:-Xcudafe=--diag_suppress=940>
  )
endif()
