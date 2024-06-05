#include "hip/hip_runtime.h"
/*
 *  Copyright 2021 NVIDIA Corporation 
 *
 *  Licensed under the Apache License, Version 2.0 with the LLVM exception
 *  (the "License"); you may not use this file except in compliance with
 *  the License.
 *
 *  You may obtain a copy of the License at
 *
 *      http://llvm.org/foundation/relicensing/LICENSE.txt
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */


// MIT License
// Modifications Copyright (c) 2024 Advanced Micro Devices, Inc.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#pragma once

#include <nvbench/config.cuh>
#include <nvbench/cuda_call.cuh>
#include <nvbench/detail/device_scope.cuh>

#include <hip/hip_runtime_api.h>

#include <cstdint> // CHAR_BIT
#include <stdexcept>
#include <string_view>
#include <utility>

namespace nvbench
{

namespace detail
{
int get_ptx_version(int);
} // namespace detail

struct device_info
{
  explicit device_info(int device_id);

  // Mainly used by unit tests:
  device_info(int device_id, hipDeviceProp_t prop)
      : m_id{device_id}
      , m_prop{prop}
  {}

  /// @return The device's id on the current system.
  [[nodiscard]] int get_id() const { return m_id; }

  /// @return The name of the device.
  [[nodiscard]] std::string_view get_name() const { return std::string_view(m_prop.name); }

  [[nodiscard]] bool is_active() const
  {
    int id{-1};
    NVBENCH_CUDA_CALL(hipGetDevice(&id));
    return id == m_id;
  }

  void set_active() const
  {
    NVBENCH_CUDA_CALL(hipSetDevice(m_id));
  }

  /// Enable or disable persistence mode.
  /// @note Only supported on Linux.
  /// @note Requires root / admin privileges.
  void set_persistence_mode(bool state);

  /// Symbolic values for special clock rates
  enum class clock_rate
  {
    /// Unlock clocks
    none,
    /// Base TDP clock; Preferred for stable benchmarking
    base,
    /// Maximum clock rate
    maximum
  };

  /// Lock GPU clocks to the specified rate.
  /// @note Only supported on Volta+ (sm_70+) devices.
  /// @note Requires root / admin privileges.
  void lock_gpu_clocks(clock_rate rate);

  /// @return The SM version of the current device as (major*100) + (minor*10).
  [[nodiscard]] int get_sm_version() const { return m_prop.major * 100 + m_prop.minor * 10; }
  
#if defined(__HIP_PLATFORM_AMD__)
  /// @return The CU architecture of the current device.
  [[nodiscard]] const char* get_cu_archname() const { return m_prop.name; }
#endif

  /// @return The PTX version of the current device, e.g. sm_80 returns 800.
  [[nodiscard]] __forceinline__ int get_ptx_version() const
  {
    return detail::get_ptx_version(m_id);
  }

  /// @return The default clock rate of the SM in Hz.
  [[nodiscard]] std::size_t get_sm_default_clock_rate() const
  { // kHz -> Hz
    return static_cast<std::size_t>(m_prop.clockRate * 1000);
  }
  
#if defined(__HIP_PLATFORM_AMD__)
  /// @return The CU architecture of the current device.
  /// @return The max clock rate of the CU in Hz.
  [[nodiscard]] std::size_t get_cu_max_clock_rate() const
  { // kHz -> Hz
    return static_cast<std::size_t>(m_prop.clockRate * 1000);
  }
#endif

  /// @return The number of physical streaming multiprocessors on this device.
  [[nodiscard]] int get_number_of_sms() const { return m_prop.multiProcessorCount; }

#if defined(__HIP_PLATFORM_AMD__) 
  /// @return The maximum number of resident blocks per CU.
  [[nodiscard]] int get_max_blocks_per_cu() const { return m_prop.maxThreadsPerMultiProcessor/m_prop.warpSize; }
#else
  /// @return The maximum number of resident blocks per SM.
  [[nodiscard]] int get_max_blocks_per_sm() const { return m_prop.maxBlocksPerMultiProcessor; }
#endif

  /// @return The maximum number of resident threads per SM.
  [[nodiscard]] int get_max_threads_per_sm() const { return m_prop.maxThreadsPerMultiProcessor; }

  /// @return The maximum number of threads per block.
  [[nodiscard]] int get_max_threads_per_block() const { return m_prop.maxThreadsPerBlock; }

#if defined(__HIP_PLATFORM_AMD__)
  /// @return The number of registers per CU.
  [[nodiscard]] int get_registers_per_cu() const { return m_prop.regsPerBlock; } //see: https://github.com/ROCm-Developer-Tools/hipamd/blob/4209792929ddf54ba9530813b7879cfdee42df14/src/hip_device.cpp#LL295C35-L295C59 
#else
  /// @return The number of registers per SM.
  [[nodiscard]] int get_registers_per_sm() const { return m_prop.regsPerMultiprocessor; }
#endif

  /// @return The number of registers per block.
  [[nodiscard]] int get_registers_per_block() const { return m_prop.regsPerBlock; }

  /// @return The total number of bytes available in global memory.
  [[nodiscard]] std::size_t get_global_memory_size() const { return m_prop.totalGlobalMem; }

  struct memory_info
  {
    std::size_t bytes_free;
    std::size_t bytes_total;
  };

  /// @return The size and usage of this device's global memory.
  [[nodiscard]] memory_info get_global_memory_usage() const;

  /// @return The peak clock rate of the global memory bus in Hz.
  [[nodiscard]] std::size_t get_global_memory_bus_peak_clock_rate() const
  { // kHz -> Hz
    return static_cast<std::size_t>(m_prop.memoryClockRate) * 1000;
  }

  /// @return The width of the global memory bus in bits.
  [[nodiscard]] int get_global_memory_bus_width() const { return m_prop.memoryBusWidth; }

  //// @return The global memory bus bandwidth in bytes/sec.
  [[nodiscard]] std::size_t get_global_memory_bus_bandwidth() const
  { // 2 is for DDR, CHAR_BITS to convert bus_width to bytes.
    return 2 * this->get_global_memory_bus_peak_clock_rate() *
           (unsigned long) (this->get_global_memory_bus_width() / CHAR_BIT);
  }

  /// @return The size of the L2 cache in bytes.
  [[nodiscard]] std::size_t get_l2_cache_size() const
  {
    return static_cast<std::size_t>(m_prop.l2CacheSize);
  }

#if defined(__HIP_PLATFORM_AMD__)
  [[nodiscard]] std::size_t get_shared_memory_per_cu() const
  {
    return m_prop.sharedMemPerBlock;
  }
#else
  /// @return The available amount of shared memory in bytes per SM.
  [[nodiscard]] std::size_t get_shared_memory_per_sm() const
  {
    return m_prop.sharedMemPerMultiprocessor;
  }
#endif

  /// @return The available amount of shared memory in bytes per block.
  [[nodiscard]] std::size_t get_shared_memory_per_block() const { return m_prop.sharedMemPerBlock; }

  /// @return True if ECC is enabled on this device.
  [[nodiscard]] bool get_ecc_state() const { return m_prop.ECCEnabled; }

  /// @return A cached copy of the device's hipDeviceProp_t.
  [[nodiscard]] const hipDeviceProp_t &get_cuda_device_prop() const { return m_prop; }

  [[nodiscard]] bool operator<(const device_info &o) const { return m_id < o.m_id; }
  [[nodiscard]] bool operator==(const device_info &o) const { return m_id == o.m_id; }
  [[nodiscard]] bool operator!=(const device_info &o) const { return m_id != o.m_id; }

private:
  int m_id;
  hipDeviceProp_t m_prop;
};

// get_ptx_version implementation; this needs to stay in the header so it will
// pick up the downstream project's compilation settings.
// TODO this is fragile and will break when called from any library
// translation unit.
namespace detail
{
// Templated to workaround ODR issues since __global__functions cannot be marked
// inline.
template <typename>
__global__ void noop_kernel()
{}

inline const auto noop_kernel_ptr = &noop_kernel<void>;

[[nodiscard]] inline int get_ptx_version(int dev_id)
try
{
  nvbench::detail::device_scope _{dev_id};
  hipFuncAttributes attr{};
  NVBENCH_CUDA_CALL(hipFuncGetAttributes(&attr, ((const void *)nvbench::detail::noop_kernel_ptr)));
  return attr.ptxVersion * 10;
}
catch (...)
{ // Fail gracefully when no appropriate PTX is found for this device.
  return -1;
}

} // namespace detail

} // namespace nvbench
