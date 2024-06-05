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

#include <string>

namespace nvbench
{

struct state;
struct summary;

/*!
 * Markdown output format.
 *
 * Includes customization points to modify numeric formatting.
 */
struct markdown_printer : nvbench::printer_base
{
  using printer_base::printer_base;

  /*!
   * Enable / disable color in the output.
   *
   * Turn off for file outputs. May not work on some interactive terminals.
   * Off by default. Enable for stdout markdown printers by passing `--color` on
   * the command line.
   *
   * @{
   */
  void set_color(bool enabled) { m_color = enabled; }
  [[nodiscard]] bool get_color() const { return m_color; }
  /*!@}*/

protected:
  // Virtual API from printer_base:
  void do_print_device_info() override;
  void do_print_log_preamble() override;
  void do_print_log_epilogue() override;
  void do_log(nvbench::log_level level, const std::string &msg) override;
  void do_log_run_state(const nvbench::state &exec_state) override;
  void do_print_benchmark_list(const benchmark_vector &benches) override;
  void do_print_benchmark_results(const benchmark_vector &benches) override;

  // Customization points for formatting:
  virtual std::string do_format_default(const nvbench::summary &data);
  virtual std::string do_format_duration(const nvbench::summary &seconds);
  virtual std::string do_format_item_rate(const nvbench::summary &items_per_sec);
  virtual std::string do_format_bytes(const nvbench::summary &bytes);
  virtual std::string do_format_byte_rate(const nvbench::summary &bytes_per_sec);
  virtual std::string do_format_sample_size(const nvbench::summary &count);
  virtual std::string do_format_percentage(const nvbench::summary &percentage);

  bool m_color{false};
};

} // namespace nvbench
