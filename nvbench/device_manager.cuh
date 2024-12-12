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

#include <nvbench/device_info.cuh>

#include <vector>

namespace nvbench
{

/**
 * Singleton class that caches CUDA device information.
 */
struct device_manager
{
  using device_info_vector = std::vector<nvbench::device_info>;

  /**
   * @return The singleton benchmark_manager instance.
   */
  [[nodiscard]] static device_manager &get();

  /**
   * @return The total number of detected CUDA devices.
   */
  [[nodiscard]] int get_number_of_devices() const { return static_cast<int>(m_devices.size()); }

  /**
   * @return The number of devices actually used by all benchmarks.
   * @note This is only valid after nvbench::option_parser::parse executes.
   */
  [[nodiscard]] int get_number_of_used_devices() const
  {
    return static_cast<int>(m_used_devices.size());
  }

  /**
   * @return The device_info object corresponding to `id`.
   */
  [[nodiscard]] const nvbench::device_info &get_device(int id) { return m_devices.at(static_cast<size_t>(id)); }

  /**
   * @return A vector containing device_info objects for all detected CUDA
   * devices.
   */
  [[nodiscard]] const device_info_vector &get_devices() const { return m_devices; }

  /**
   * @return A vector containing device_info objects for devices that are
   * actively used by all benchmarks.
   * @note This is only valid after nvbench::option_parser::parse executes.
   */
  [[nodiscard]] const device_info_vector &get_used_devices() const { return m_used_devices; }

private:
  device_manager();

  friend struct option_parser;

  void set_used_devices(device_info_vector devices) { m_used_devices = std::move(devices); }

  device_info_vector m_devices;
  device_info_vector m_used_devices;
};

} // namespace nvbench
