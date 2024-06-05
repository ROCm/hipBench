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

#include <nvbench/printer_base.cuh>

#include <memory>
#include <vector>

namespace nvbench
{

/*!
 * An nvbench::printer_base that just forwards calls to other `printer_base`s.
 */
struct printer_multiplex : nvbench::printer_base
{
  printer_multiplex();

  template <typename Format, typename... Ts>
  Format &emplace(Ts &&...ts)
  {
    m_printers.push_back(std::make_unique<Format>(std::forward<Ts>(ts)...));
    return static_cast<Format &>(*m_printers.back());
  }

  [[nodiscard]] std::size_t get_printer_count() const { return m_printers.size(); }

protected:
  void do_log_argv(const std::vector<std::string> &argv) override;
  void do_print_device_info() override;
  void do_print_log_preamble() override;
  void do_print_log_epilogue() override;
  void do_log(nvbench::log_level, const std::string &) override;
  void do_log_run_state(const nvbench::state &) override;
  void do_process_bulk_data_float64(nvbench::state &,
                                    const std::string &,
                                    const std::string &,
                                    const std::vector<nvbench::float64_t> &) override;
  void do_print_benchmark_list(const benchmark_vector &benches) override;
  void do_print_benchmark_results(const benchmark_vector &benches) override;
  void do_set_completed_state_count(std::size_t states) override;
  void do_add_completed_state() override;
  void do_set_total_state_count(std::size_t states) override;

  std::vector<std::unique_ptr<nvbench::printer_base>> m_printers;
};

} // namespace nvbench
