// MIT License
//
// Modifications Copyright (C) 2023-2025 Advanced Micro Devices, Inc. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include <nvbench/cuda_call.cuh>

#include "test_asserts.cuh"

namespace
{
__global__ void multiply5(const int32_t *__restrict__ a, int32_t *__restrict__ b)
{
  const auto id = blockIdx.x * blockDim.x + threadIdx.x;
  b[id]         = 5 * a[id];
}
} // namespace

int main()
{ 
  if constexpr(HIP_PLATFORM_AMD) {
    return 0; // This test is presently not supported on AMD platform (internal issue 16)"; 
  }

  multiply5<<<256, 256>>>(nullptr, nullptr);

  try
  {
    NVBENCH_CUDA_CALL(cudaStreamSynchronize(0));
    ASSERT(false);
  }
  catch (const std::runtime_error &)
  {
    ASSERT(cudaGetLastError() == cudaError_t::cudaSuccess);
  }

  return 0;
}
