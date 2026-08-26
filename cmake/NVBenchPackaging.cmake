# MIT License
#
# Copyright (C) 2025 Advanced Micro Devices, Inc. All rights reserved.
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

set(CPACK_PACKAGE_NAME "hipbench" CACHE STRING "Overwrite package name.")
set(CPACK_PACKAGE_VENDOR "Advanced Micro Devices, Inc.")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_VENDOR}")
set(CPACK_OUTPUT_FILE_PREFIX "dist" CACHE PATH "Package output file prefix.")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
if(NOT CPACK_PACKAGING_INSTALL_PREFIX)
  set(CPACK_PACKAGING_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
endif()

# Enable component-based packaging
set(CPACK_COMPONENTS_ALL main devel)

# Component descriptions
set(CPACK_COMPONENT_MAIN_DISPLAY_NAME "hipBench Runtime")
set(CPACK_COMPONENT_MAIN_DESCRIPTION "hipBench runtime libraries and executables")
set(CPACK_COMPONENT_DEVEL_DISPLAY_NAME "hipBench Development Files")
set(CPACK_COMPONENT_DEVEL_DESCRIPTION "Headers and CMake files for developing with hipBench")
set(CPACK_COMPONENT_DEVEL_DEPENDS main)

# DEB-specific component packaging
set(CPACK_DEB_COMPONENT_INSTALL ON)
set(CPACK_DEBIAN_ENABLE_COMPONENT_DEPENDS ON)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_MAIN_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
set(CPACK_DEBIAN_DEVEL_PACKAGE_NAME "${CPACK_PACKAGE_NAME}-dev")
# CPACK_DEBIAN_ENABLE_COMPONENT_DEPENDS derives the dependency on the main
# package from CPACK_COMPONENT_DEVEL_DEPENDS, so only external ones belong here.
if (NOT NVBench_INSTALL_CPM_DEPS OR NOT libhipcxx_ADDED)
  set(CPACK_DEBIAN_DEVEL_PACKAGE_DEPENDS "libhipcxx-dev (>= 2.7.0)")
endif()

# RPM-specific component packaging
set(CPACK_RPM_COMPONENT_INSTALL ON)
set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
set(CPACK_RPM_MAIN_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
set(CPACK_RPM_DEVEL_PACKAGE_NAME "${CPACK_PACKAGE_NAME}-devel")
set(CPACK_RPM_MAIN_PACKAGE_SUMMARY "hipBench runtime libraries and executables")
set(CPACK_RPM_DEVEL_PACKAGE_SUMMARY "hipBench development files")
set(rpm_devel_requires "${CPACK_PACKAGE_NAME} = ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
if (NOT NVBench_INSTALL_CPM_DEPS OR NOT libhipcxx_ADDED)
  list(APPEND rpm_devel_requires "libhipcxx-devel >= 2.7.0")
endif()
# rpm spells this out comma separated, so a bare CMake list would not do
list(JOIN rpm_devel_requires ", " CPACK_RPM_DEVEL_PACKAGE_REQUIRES)

include(CPack)
