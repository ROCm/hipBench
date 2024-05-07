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

if(NVBench_ENABLE_INSTALL_RULES)

  include(GNUInstallDirs)
  rapids_cmake_install_lib_dir(NVBench_INSTALL_LIB_DIR)

  # in-source public headers:
  install(DIRECTORY "${NVBench_SOURCE_DIR}/nvbench"
    TYPE INCLUDE
    FILES_MATCHING
      PATTERN "*.cuh"
      PATTERN "internal" EXCLUDE
  )

  # generated headers from build dir:
  install(
    FILES
      "${NVBench_BINARY_DIR}/nvbench/config.cuh"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/nvbench"
  )
  install(
    FILES
      "${NVBench_BINARY_DIR}/nvbench/detail/version.cuh"
      "${NVBench_BINARY_DIR}/nvbench/detail/git_revision.cuh"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/nvbench/detail"
  )

  #
  # Install CMake files needed by consumers to locate dependencies:
  #

  # Borrowing this logic from rapids_cmake's export logic to make sure these end
  # up in the same location as nvbench-config.cmake:
  rapids_cmake_install_lib_dir(config_install_location)
  set(config_install_location "${config_install_location}/cmake/nvbench")

  if (NVBench_ENABLE_NVML)
    install(
      FILES
        "${NVBench_SOURCE_DIR}/cmake/NVBenchNVML.cmake"
      DESTINATION "${config_install_location}"
    )
  endif()

  if (NVBench_ENABLE_CUPTI)
    install(
      FILES
        "${NVBench_SOURCE_DIR}/cmake/NVBenchCUPTI.cmake"
      DESTINATION "${config_install_location}"
    )
  endif()
endif()

# Call with a list of library targets to generate install rules:
function(nvbench_install_libraries)
  if(NVBench_ENABLE_INSTALL_RULES)
    install(TARGETS ${ARGN}
      DESTINATION "${NVBench_INSTALL_LIB_DIR}"
      EXPORT nvbench-targets
    )
  endif()
endfunction()

# Call with a list of executables to generate install rules:
function(nvbench_install_executables)
  if(NVBench_ENABLE_INSTALL_RULES)
    install(TARGETS ${ARGN} EXPORT nvbench-targets)
  endif()
endfunction()
