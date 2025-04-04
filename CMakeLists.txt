# 3.30.4 required for rapids-cmake
cmake_minimum_required(VERSION 3.30.4)

# NOTE(HIP/AMD): make *.cu files HIP lang files
set(CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/overrides.cmake")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_LIST_DIR}")
  set(NVBench_TOPLEVEL_PROJECT ON)
else()
  set(NVBench_TOPLEVEL_PROJECT OFF)
endif()

include(cmake/NVBenchRapidsCMake.cmake)
nvbench_load_rapids_cmake()

project(NVBench
  LANGUAGES CXX HIP
  VERSION 0.2.0
)

nvbench_init_rapids_cmake()

# Define NVBench_DETECTED_${LANG}_STANDARDS
include(cmake/DetectSupportedStandards.cmake)
detect_supported_standards(NVBench CXX 17 20)
detect_supported_standards(NVBench HIP 17 20)

# See NVIDIA/NVBench#52
find_package(HIP REQUIRED)
set(cupti_default OFF) # TODO(HIP): Replace with ROCm analogue
#if (${CUDAToolkit_VERSION} VERSION_LESS 11.3)
#  set(cupti_default OFF)
#endif()

option(BUILD_SHARED_LIBS "Build NVBench as a shared library" ON)

option(NVBench_ENABLE_NVML "Build with NVML support from the Cuda Toolkit." OFF)
option(NVBench_ENABLE_CUPTI "Build NVBench with CUPTI." ${cupti_default})

option(NVBench_ENABLE_TESTING "Build NVBench testing suite." OFF)
option(NVBench_ENABLE_HEADER_TESTING "Build NVBench testing suite." OFF)
option(NVBench_ENABLE_DEVICE_TESTING
  "Include tests that require a GPU (with locked clocks)."
  OFF
)
option(NVBench_ENABLE_EXAMPLES "Build NVBench examples." OFF)
option(NVBench_ENABLE_INSTALL_RULES "Install NVBench." ${NVBench_TOPLEVEL_PROJECT})
option(NVBench_DISABLE_INSTALL_CPM_DOWNLOADS
  "Do NOT install/package dependencies DOWNLOADED by CPM together with this project.
  This has only an effect on packages downloaded by CPM not those that CPM has found locally."
  OFF
)

include(cmake/NVBenchUtilities.cmake) # Must be first
include(cmake/NVBenchClangdCompileInfo.cmake) # Must be before any targets are created

include(cmake/NVBenchConfigTarget.cmake)
include(cmake/NVBenchExports.cmake)
include(cmake/NVBenchWriteConfigHeader.cmake)
include(cmake/NVBenchDependencies.cmake)
include(cmake/NVBenchInstallRules.cmake)
include(cmake/NVBenchLibhipcxx.cmake)

# synchronize HIP and CUDA architectures
if (DEFINED CMAKE_HIP_ARCHITECTURES AND NOT CMAKE_CUDA_ARCHITECTURES)
  set(CMAKE_CUDA_ARCHITECTURES ${CMAKE_HIP_ARCHITECTURES})
elseif (DEFINED CMAKE_CUDA_ARCHITECTURES AND NOT CMAKE_HIP_ARCHITECTURES)
  set(CMAKE_HIP_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES})
endif()
message(STATUS "NVBench CUDA architectures: ${CMAKE_CUDA_ARCHITECTURES}")

add_subdirectory(nvbench)

if (NVBench_ENABLE_EXAMPLES OR
    NVBench_ENABLE_TESTING OR
    NVBench_ENABLE_HEADER_TESTING)
  include(CTest)
  enable_testing()
endif()

add_subdirectory(exec)

if (NVBench_ENABLE_EXAMPLES)
  add_subdirectory(examples)
endif()

if (NVBench_ENABLE_TESTING)
  add_subdirectory(testing)
endif()

if (NVBench_ENABLE_HEADER_TESTING)
  include(cmake/NVBenchHeaderTesting.cmake)
endif()

nvbench_generate_exports()

include(cmake/NVBenchPackaging.cmake)
