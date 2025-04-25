# Modifications Copyright (c) 2024 Advanced Micro Devices, Inc.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# file_to_string(file_in file_out string_name)
#
# Create a C++ file `file_out` that defines a string named `string_name` in
# `namespace`, which contains the contents of `file_in`.

# Cache this so we can access it from wherever file_to_string is called.
set(_nvbench_file_to_string_path "${CMAKE_CURRENT_LIST_DIR}/FileToString.in")
function(file_to_string file_in file_out namespace string_name)
  file(READ "${file_in}" file_in_contents)

  set(file_out_contents)
  string(APPEND file_to_string_payload
    "#include <string>\n"
    "namespace ${namespace} {\n"
    "const std::string ${string_name} =\n"
    "R\"expected(${file_in_contents})expected\";\n"
    "}\n"
  )

  configure_file("${_nvbench_file_to_string_path}" "${file_out}")
endfunction()
