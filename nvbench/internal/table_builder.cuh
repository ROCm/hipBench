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

#include <algorithm>
#include <cstdint>
#include <string>
#include <vector>

namespace nvbench::internal
{

/*!
 * State for a text table (rows and columns of cells). Tracks column widths.
 */
struct table_builder
{
  struct column
  {
    std::string key;
    std::string header;
    std::vector<std::string> rows;
    std::size_t max_width;
  };

  std::vector<column> m_columns;
  std::size_t m_num_rows{};

  void add_cell(std::size_t row,
                const std::string &column_key,
                const std::string &header,
                std::string value)
  {
    auto iter = std::find_if(m_columns.begin(), m_columns.end(), [&column_key](const column &col) {
      return col.key == column_key;
    });

    auto &col = iter == m_columns.end()
                  ? m_columns.emplace_back(
                      column{column_key, header, std::vector<std::string>{}, header.size()})
                  : *iter;

    col.max_width = std::max(col.max_width, value.size());
    if (col.rows.size() <= row)
    {
      col.rows.resize(row + 1);
      col.rows[row] = std::move(value);
    }
  }

  void fix_row_lengths()
  { // Ensure that each row is the same length:
    m_num_rows = nvbench::detail::transform_reduce(
      m_columns.cbegin(),
      m_columns.cend(),
      std::size_t{},
      [](const auto &a, const auto &b) { return a > b ? a : b; },
      [](const column &col) { return col.rows.size(); });
    std::for_each(m_columns.begin(), m_columns.end(), [num_rows = m_num_rows](column &col) {
      col.rows.resize(num_rows);
    });
  }
};

} // namespace nvbench::internal
