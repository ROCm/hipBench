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

macro(nvbench_generate_exports)
  if(NVBench_ENABLE_INSTALL_RULES)
    set(nvbench_build_export_code_block "")
    set(nvbench_install_export_code_block "")

    if (NVBench_ENABLE_NVML)
      string(APPEND nvbench_build_export_code_block
        "include(\"${NVBench_SOURCE_DIR}/cmake/NVBenchNVML.cmake\")\n"
      )
      string(APPEND nvbench_install_export_code_block
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/NVBenchNVML.cmake\")\n"
      )
    endif()

    if (NVBench_ENABLE_CUPTI)
      string(APPEND nvbench_build_export_code_block
        "include(\"${NVBench_SOURCE_DIR}/cmake/NVBenchCUPTI.cmake\")\n"
      )
      string(APPEND nvbench_install_export_code_block
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/NVBenchCUPTI.cmake\")\n"
      )
    endif()

    if (TARGET nvbench_json)
      set(nvbench_json_code_block
        [=[
        add_library(nvbench_json INTERFACE IMPORTED)
        if (TARGET nlohmann_json::nlohmann_json)
          target_link_libraries(nvbench_json INTERFACE nlohmann_json::nlohmann_json)
        endif()
        ]=])
      string(APPEND nvbench_build_export_code_block ${nvbench_json_code_block})
      string(APPEND nvbench_install_export_code_block ${nvbench_json_code_block})
    endif()

    rapids_export(BUILD NVBench
      EXPORT_SET nvbench-targets
      NAMESPACE "nvbench::"
      GLOBAL_TARGETS nvbench main ctl internal_build_interface
      LANGUAGES HIP CXX
      FINAL_CODE_BLOCK nvbench_build_export_code_block
    )
    rapids_export(INSTALL NVBench
      EXPORT_SET nvbench-targets
      NAMESPACE "nvbench::"
      GLOBAL_TARGETS nvbench main ctl internal_build_interface
      LANGUAGES HIP CXX
      FINAL_CODE_BLOCK nvbench_install_export_code_block
    )

    # hipbench package provides hipbench:: and nvbench:: targets
    set(nvbench_targets nvbench main ctl internal_build_interface)
    set(hipbench_global_targets "")
    foreach(target ${nvbench_targets})
      list(APPEND hipbench_global_targets nvbench_${target} hipbench_${target})
      add_library(nvbench_${target} INTERFACE)
      add_library(hipbench_${target} INTERFACE)
      set_target_properties(nvbench_${target} PROPERTIES EXPORT_NAME nvbench::${target})
      if (${target} STREQUAL "nvbench")
        set_target_properties(hipbench_${target} PROPERTIES EXPORT_NAME hipbench::hipbench)
        target_link_libraries(nvbench_${target} INTERFACE nvbench)
        target_link_libraries(hipbench_${target} INTERFACE nvbench)
      else()
        set_target_properties(hipbench_${target} PROPERTIES EXPORT_NAME hipbench::${target})
        target_link_libraries(nvbench_${target} INTERFACE nvbench.${target})
        target_link_libraries(hipbench_${target} INTERFACE nvbench.${target})
      endif()
    endforeach()
    nvbench_install_libraries(${hipbench_global_targets})

    rapids_export(BUILD hipBench
      EXPORT_SET nvbench-targets
      GLOBAL_TARGETS ${hipbench_global_targets}
      LANGUAGES HIP CXX
      FINAL_CODE_BLOCK nvbench_build_export_code_block
    )
    rapids_export(INSTALL hipBench
      EXPORT_SET nvbench-targets
      GLOBAL_TARGETS ${hipbench_global_targets}
      LANGUAGES HIP CXX
      FINAL_CODE_BLOCK nvbench_install_export_code_block
    )
  endif()
endmacro()
