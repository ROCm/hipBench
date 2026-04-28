# =============================================================================
# Copyright (c) 2021, NVIDIA CORPORATION.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
# =============================================================================

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

# ---------------------------------------------------------------------------
# find_and_configure_libhipcxx
#
# Uses rapids_cpm_libhipcxx to fetch libhipcxx, then applies a post-fetch
# patch to include/hip/std/detail/__config that adds
# _LIBCUDACXX_HIP_TSC_CLOCKRATE definitions for GPU architectures missing
# from libhipcxx 1.9.0:
#
#   gfx950        AMD Instinct MI350 / MI355X  (CDNA4)
#   gfx1101/1102  Radeon RX 7000 series        (RDNA3 variants)
#   gfx1200/1201  Radeon R9700 / R9700 XT      (RDNA4)
#   <others>      generic 100 MHz fallback
#
# Without this patch, building for any of the above targets fails with:
#   error: use of undeclared identifier '_LIBCUDACXX_HIP_TSC_CLOCKRATE'
#
# The patch logic lives in patch_libhipcxx_config.py (same directory).
# ---------------------------------------------------------------------------

set(_NVBENCH_PATCH_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/patch_libhipcxx_config.py")
set(_LIBHIPCXX_CONFIG_RELPATH "include/hip/std/detail/__config")

# Apply the TSC patch to the given libhipcxx source directory (idempotent).
function(_nvbench_patch_libhipcxx_config src_dir)
  set(config_file "${src_dir}/${_LIBHIPCXX_CONFIG_RELPATH}")
  if(NOT EXISTS "${config_file}")
    message(WARNING
      "NVBenchLibhipcxx: ${config_file} not found — skipping TSC patch")
    return()
  endif()

  find_package(Python3 QUIET COMPONENTS Interpreter)
  if(Python3_FOUND)
    set(_py "${Python3_EXECUTABLE}")
  else()
    find_program(_py NAMES python3 python)
  endif()

  if(NOT _py)
    message(WARNING
      "NVBenchLibhipcxx: Python3 not found — TSC patch not applied.\n"
      "  Run manually: python3 ${_NVBENCH_PATCH_SCRIPT} ${config_file}")
    return()
  endif()

  execute_process(
    COMMAND "${_py}" "${_NVBENCH_PATCH_SCRIPT}" "${config_file}"
    RESULT_VARIABLE _result
    OUTPUT_VARIABLE _output
    ERROR_VARIABLE  _error
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT _result EQUAL 0)
    message(FATAL_ERROR
      "NVBenchLibhipcxx: TSC patch failed:\n${_error}")
  endif()
  message(STATUS "${_output}")
endfunction()

# ---------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------
function(find_and_configure_libhipcxx)
  include(${rapids-cmake-dir}/cpm/libhipcxx.cmake)

  rapids_cpm_libhipcxx(
    BUILD_EXPORT_SET nvbench-targets
    INSTALL_EXPORT_SET nvbench-targets
  )

  # libhipcxx_SOURCE_DIR is exported by rapids_cpm_libhipcxx / CPM.
  if(DEFINED libhipcxx_SOURCE_DIR AND EXISTS "${libhipcxx_SOURCE_DIR}")
    _nvbench_patch_libhipcxx_config("${libhipcxx_SOURCE_DIR}")
  else()
    # Fallback: probe common CPM / FetchContent cache locations.
    foreach(_candidate
        "${CMAKE_BINARY_DIR}/_deps/libhipcxx-src"
        "${FETCHCONTENT_BASE_DIR}/libhipcxx-src")
      if(EXISTS "${_candidate}/${_LIBHIPCXX_CONFIG_RELPATH}")
        _nvbench_patch_libhipcxx_config("${_candidate}")
        break()
      endif()
    endforeach()
  endif()

endfunction()

find_and_configure_libhipcxx()
