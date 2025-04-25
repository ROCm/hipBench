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

file_version = (1, 0, 0)

file_version_string = "{}.{}.{}".format(file_version[0],
                                        file_version[1],
                                        file_version[2])


def check_file_version(filename, root_node):
    try:
        version_node = root_node["meta"]["version"]["json"]
    except KeyError:
        print("WARNING:")
        print("  {} is written in an older, unversioned format. ".format(filename))
        print("  It may not read correctly.")
        print("  Reader expects JSON file version {}.".format(file_version_string))
        return

    # TODO We could do something fancy here using semantic versioning, but
    # for now just warn on mismatch.
    if version_node["string"] != file_version_string:
        print("WARNING:")
        print("  {} was written using a different NVBench JSON file version."
              .format(filename))
        print("  It may not read correctly.")
        print("  (file version: {} reader version: {})"
              .format(version_node["string"], file_version_string))
