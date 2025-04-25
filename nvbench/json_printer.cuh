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

#include <nvbench/types.cuh>

#include <string>
#include <vector>

namespace nvbench
{

/*!
 * JSON output format.
 *
 * All modifications to the output file should increment the semantic version
 * of the json files appropriately (see json_printer::get_json_file_version()).
 */
struct json_printer : nvbench::printer_base
{
  using printer_base::printer_base;

  json_printer(std::ostream &stream, std::string stream_name, bool enable_binary_output)
      : printer_base(stream, std::move(stream_name))
      , m_enable_binary_output{enable_binary_output}
  {}

  /**
   * The json schema version. Follows semantic versioning.
   */
  struct version_t
  {
    nvbench::uint16_t major;
    nvbench::uint16_t minor;
    nvbench::uint16_t patch;

    [[nodiscard]] std::string get_string() const;
  };

  [[nodiscard]] static version_t get_json_file_version();

  [[nodiscard]] bool get_enable_binary_output() const { return m_enable_binary_output; }
  void set_enable_binary_output(bool b) { m_enable_binary_output = b; }

protected:
  // Virtual API from printer_base:
  void do_log_argv(const std::vector<std::string> &argv) override { m_argv = argv; }
  void do_process_bulk_data_float64(nvbench::state &state,
                                    const std::string &tag,
                                    const std::string &hint,
                                    const std::vector<nvbench::float64_t> &data) override;
  void do_print_benchmark_results(const benchmark_vector &benches) override;

  bool m_enable_binary_output{false};
  std::size_t m_num_jsonbin_files{};

  std::vector<std::string> m_argv;
};

} // namespace nvbench
