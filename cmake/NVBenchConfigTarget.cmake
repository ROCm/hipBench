# MIT License
#
# Modifications Copyright (C) 2023-2025 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

include(CheckCXXCompilerFlag)

option(NVBench_ENABLE_WERROR
  "Treat warnings as errors while compiling NVBench."
  ${NVBench_TOPLEVEL_PROJECT}
)
mark_as_advanced(NVBench_ENABLE_WERROR)

# Builds all NVBench targets (libs, tests, examples, etc).
add_custom_target(nvbench.all)

set(NVBench_LIBRARY_OUTPUT_DIR "${CMAKE_BINARY_DIR}/lib")
set(NVBench_EXECUTABLE_OUTPUT_DIR "${CMAKE_BINARY_DIR}/bin")

add_library(nvbench.build_interface INTERFACE)

# TODO Why must this be installed/exported if it's just a private interface?
# CMake complains about it missing from the export set unless we export it.
# Is there way to avoid this?
set_target_properties(nvbench.build_interface PROPERTIES
  EXPORT_NAME internal_build_interface
)

function(nvbench_add_cxx_flag target_name type flag)
  string(MAKE_C_IDENTIFIER "NVBench_CXX_FLAG_${flag}" var)
  check_cxx_compiler_flag(${flag} ${var})

  if (${${var}})
    target_compile_options(${target_name} ${type}
      $<$<COMPILE_LANGUAGE:CXX>:${flag}>
      $<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:-Xcompiler=${flag}>
    )
  endif()
endfunction()

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "/W4")

  if (NVBench_ENABLE_WERROR)
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "/WX")
  endif()

  # Suppress overly-pedantic/unavoidable warnings brought in with /W4:
  # C4505: unreferenced local function has been removed
  # The CUDA `host_runtime.h` header emits this for
  # `__cudaUnregisterBinaryUtil`.
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "/wd4505")

  # Required by fmt:
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "/utf-8")
else()
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wall")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wextra")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wconversion")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Woverloaded-virtual")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wcast-qual")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wpointer-arith")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wunused-local-typedef")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wunused-parameter")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wvla")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wgnu")
  nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wno-gnu-line-marker") # WAR 3916341

  if (NVBench_ENABLE_WERROR)
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Werror")
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wno-unused-private-field")
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wno-conversion")
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wno-bitwise-instead-of-logical")
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wno-unused-variable")
    nvbench_add_cxx_flag(nvbench.build_interface INTERFACE "-Wno-defaulted-function-deleted")
  endif()
endif()

# Experimental filesystem library
if (CMAKE_CXX_COMPILER_ID STREQUAL GNU OR CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  target_link_libraries(nvbench.build_interface INTERFACE stdc++fs)
endif()

# CUDA-specific flags
if (CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA")
  # fmtlib uses llvm's _BitInt internally, which is not available when compiling through nvcc:
  target_compile_definitions(nvbench.build_interface INTERFACE "FMT_USE_BITINT=0")
endif()

target_compile_options(nvbench.build_interface INTERFACE
  $<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:-Xcudafe=--display_error_number>
  $<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:-Wno-deprecated-gpu-targets>
)
if (NVBench_ENABLE_WERROR)
  target_compile_options(nvbench.build_interface INTERFACE
    $<$<COMPILE_LANG_AND_ID:CUDA,NVIDIA>:-Xcudafe=--promote_warnings>
  )
endif()

function(nvbench_config_target target_name)
  target_link_libraries(${target_name} PRIVATE nvbench.build_interface)
  set_target_properties(${target_name} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${NVBench_LIBRARY_OUTPUT_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${NVBench_LIBRARY_OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "${NVBench_EXECUTABLE_OUTPUT_DIR}"
    WINDOWS_EXPORT_ALL_SYMBOLS ON # oooo pretty hammer...
  )
endfunction()
