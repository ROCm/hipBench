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

#include <nvbench/detail/transform_reduce.cuh>

#include <nvbench/internal/table_builder.cuh>

#include <fmt/color.h>
#include <fmt/format.h>

#include <algorithm>
#include <cstdint>
#include <iterator>
#include <string>
#include <vector>

namespace nvbench::internal
{

/*!
 * Implementation detail for markdown_printer.
 *
 * Usage:
 *
 * ```
 * markdown_table table;
 * table.add_cell(...); // Insert all cells
 * std::string table_str = table.to_string();
 * ```
 */
struct markdown_table : private table_builder
{
  using table_builder::add_cell;

  markdown_table(bool color)
      : m_color(color)
  {}

  std::string to_string()
  {
    if (m_columns.empty())
    {
      return {};
    }

    this->fix_row_lengths();

    std::vector<char> buffer;
    buffer.reserve(4096);
    auto iter = std::back_inserter(buffer);

    iter = this->print_header(iter);
    iter = this->print_divider(iter);
    iter = this->print_rows(iter);

    return std::string(buffer.data(), buffer.size());
  }

private:
  template <typename Iter>
  Iter print_header(Iter iter)
  {
    fmt::format_to(iter, m_color ? (m_bg | m_vdiv_fg) : m_no_style, "|");
    for (const column &col : m_columns)
    {
      iter = fmt::format_to(iter,
                            m_color ? (m_bg | m_header_fg) : m_no_style,
                            " {:^{}} ",
                            col.header,
                            col.max_width);
      iter = fmt::format_to(iter, m_color ? (m_bg | m_vdiv_fg) : m_no_style, "|");
    }
    return fmt::format_to(iter, "\n");
  }

  template <typename Iter>
  Iter print_divider(Iter iter)
  {
    iter = fmt::format_to(iter, m_color ? (m_bg | m_vdiv_fg) : m_no_style, "|");
    for (const column &col : m_columns)
    {
      iter = fmt::format_to(iter,
                            m_color ? (m_bg | m_hdiv_fg) : m_no_style,
                            "{:-^{}}",
                            "",
                            col.max_width + 2);
      iter = fmt::format_to(iter, m_color ? (m_bg | m_vdiv_fg) : m_no_style, "|");
    }
    return fmt::format_to(iter, "\n");
  }

  template <typename Iter>
  Iter print_rows(Iter iter)
  {
    auto style     = m_bg | m_data_fg;
    auto style_alt = m_bg | m_data_fg_alt;

    for (std::size_t row = 0; row < m_num_rows; ++row)
    {
      iter = fmt::format_to(iter, m_color ? (m_bg | m_vdiv_fg) : m_no_style, "|");
      for (const column &col : m_columns)
      {
        iter = fmt::format_to(iter,
                              m_color ? style : m_no_style,
                              " {:>{}} ",
                              col.rows[row],
                              col.max_width);
        iter = fmt::format_to(iter, m_color ? (m_bg | m_vdiv_fg) : m_no_style, "|");
      } // cols

      iter = fmt::format_to(iter, "\n");

      {
        using std::swap;
        swap(style, style_alt);
      }
    } // rows

    return iter;
  }

  bool m_color;

  // clang-format off
  fmt::text_style m_no_style    {};
  fmt::text_style m_bg          { bg(fmt::rgb{ 20, 20,   32}) };
  fmt::text_style m_vdiv_fg     { fg(fmt::rgb{ 20, 20,   32}) };
  fmt::text_style m_header_fg   { fg(fmt::rgb{200, 200, 200}) };
  fmt::text_style m_hdiv_fg     { fg(fmt::rgb{170, 170, 170}) };
  fmt::text_style m_data_fg     { fg(fmt::rgb{200, 200, 200}) };
  fmt::text_style m_data_fg_alt { fg(fmt::rgb{170, 170, 170}) };
  // clang-format on
};

} // namespace nvbench::internal
