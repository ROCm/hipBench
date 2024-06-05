<!---
 Modifications Copyright (c) 2024 Advanced Micro Devices, Inc.
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
-->

# Overview

This project is a work-in-progress. Everything is subject to change.
hipBench is an open source project. It is derived from 
[NVBench](https://github.com/NVIDIA/nvbench).

hipBench is a C++17 library designed to simplify HIP kernel benchmarking. It
features:

* [Parameter sweeps](docs/benchmarks.md#parameter-axes): a powerful and
  flexible "axis" system explores a kernel's configuration space. Parameters may
  be dynamic numbers/strings or [static types](docs/benchmarks.md#type-axes).
* [Runtime customization](docs/cli_help.md): A rich command-line interface
  allows [redefinition of parameter axes](docs/cli_help_axis.md), CUDA/AMD device
  selection, locking GPU clocks, changing output formats, and more.
* [Throughput calculations](docs/benchmarks.md#throughput-measurements): Compute
  and report:
  * Item throughput (elements/second)
  * Global memory bandwidth usage (bytes/second and per-device %-of-peak-bw)
* Multiple output formats: Currently supports markdown (default) and CSV output.
* [Manual timer mode](docs/benchmarks.md#explicit-timer-mode-nvbenchexec_tagtimer):
  (optional) Explicitly start/stop timing in a benchmark implementation.
* Multiple measurement types:
  * Cold Measurements:
    * Each sample runs the benchmark once with a clean device L2 cache.
    * GPU and CPU times are reported.
  * Batch Measurements:
    * Executes the benchmark multiple times back-to-back and records total time.
    * Reports the average execution time (total time / number of executions).

# Supported Compilers and Tools

- CMake > 2.23.1
- ROCm >= 6.2
- g++: 7 -> 12
- clang++: 9 -> 18
- cl.exe: 2019 -> 2022 (19.29, 29.39)
- Headers are tested with C++17 -> C++20.

# Known limitations

Generally, we aim for feature parity with NVBench.
Currently, we do not support CUDA devices with HIP's CUDA backend.
If this feature is relevant to your project, please let us know by opening a feature request on Github.

# Getting Started

## Minimal Benchmark

A basic kernel benchmark can be created with just a few lines of HIP C++:

```cpp
void my_benchmark(nvbench::state& state) {
  state.exec([](nvbench::launch& launch) {
    my_kernel<<<num_blocks, 256, 0, launch.get_stream()>>>();
  });
}
NVBENCH_BENCH(my_benchmark);
```

See [Benchmarks](docs/benchmarks.md) for information on customizing benchmarks
and implementing parameter sweeps.

## Command Line Interface

Each benchmark executable produced by hipBench provides a rich set of
command-line options for configuring benchmark execution at runtime. See the
[CLI overview](docs/cli_help.md)
and [CLI axis specification](docs/cli_help_axis.md) for more information.

## Examples

This repository provides a number of [examples](examples/) that demonstrate
various hipBench features and usecases:

- [Runtime and compile-time parameter sweeps](examples/axes.cu)
- [Enums and compile-time-constant-integral parameter axes](examples/enums.cu)
- [Reporting item/sec and byte/sec throughput statistics](examples/throughput.cu)
- [Skipping benchmark configurations](examples/skip.cu)
- [Benchmarking on a specific stream](examples/stream.cu)
- [Benchmarks that sync CUDA devices: `nvbench::exec_tag::sync`](examples/exec_tag_sync.cu)
- [Manual timing: `nvbench::exec_tag::timer`](examples/exec_tag_timer.cu)

### Building Examples

To build the examples:
```
mkdir -p build
cd build
cmake -DNVBench_ENABLE_EXAMPLES=ON -DCMAKE_HIP_ARCHITECTURES=gfx90a .. && make
```
Be sure to set `CMAKE_HIP_ARCHITECTURES` based on the GPU you are running on.

Examples are built by default into `build/bin` and are prefixed with `nvbench.example`.

<details>
  <summary>Example output from `nvbench.example.throughput`</summary>

```
# Devices

## [0] `AMD Instinct MI210`
* CU Architecture: AMD Instinct MI210
* Number of CUs: 104
* CU Max Clock Rate: 1700 MHz
* Global Memory: 65446 MiB Free / 65520 MiB Total
* Global Memory Bus Peak: 1638 GB/sec (4096-bit DDR @1600MHz)
* Max Shared Memory: 64 KiB/CU, 64 KiB/Block
* L2 Cache Size: 8192 KiB
* Maximum Active Blocks: 32/CU
* Maximum Active Threads: 2048/CU, 1024/Block
* Available Registers: 65536/CU, 65536/Block
* ECC Enabled: No

# Log

```
Run:  [1/1] throughput_bench [Device=0]
Pass: Cold: 0.153360ms GPU, 0.161058ms CPU, 0.50s total GPU, 0.64s total wall, 3264x 
Pass: Batch: 0.146135ms GPU, 0.50s total GPU, 0.50s total wall, 3422x
```

# Benchmark Results

## throughput_bench

### [0] AMD Instinct MI210

| NumElements |  DataSize  | Samples |  CPU Time  | Noise |  GPU Time  | Noise |  Elem/s  | GlobalMem BW | BWUtil | Samples | Batch GPU  |
|-------------|------------|---------|------------|-------|------------|-------|----------|--------------|--------|---------|------------|
|    16777216 | 64.000 MiB |   3264x | 161.058 us | 5.10% | 153.360 us | 0.77% | 109.397G | 875.180 GB/s | 53.42% |   3422x | 146.135 us |
```

</details>


## Demo Project

To get started using hipBench with your own kernels, consider trying out
the [NVBench Demo Project](https://github.com/allisonvacanti/nvbench_demo).

`nvbench_demo` provides a simple CMake project that uses hipBench to build an
example benchmark. It's a great way to experiment with the library without a lot
of investment.

# Contributing

Contributions are welcome!


## Tests

To build `nvbench` tests:
```
mkdir -p build
cd build
cmake -DNVBench_ENABLE_TESTING=ON .. && make
```

Tests are built by default into `build/bin` and prefixed with `nvbench.test`.

To run all tests:
```
make test
```
or
```
ctest
```
# License

hipBench is an open source project. It is derived from [NVBench](https://github.com/NVIDIA/nvbench).
The original [NVBench](https://github.com/NVIDIA/nvbench) is released under the Apache 2.0 License with LLVM exceptions.
Any new files and modifications made to exisiting files by AMD are distributed under MIT.
See [LICENSE](./LICENSE).

# Scope and Related Projects

hipBench will measure the CPU and AMD GPU execution time of a ***single
host-side critical region*** per benchmark. It is intended for regression
testing and parameter tuning of individual kernels.

hipBench is focused on evaluating the performance of HIP kernels and is not
optimized for CPU microbenchmarks. This may change in the future, but for now,
consider using Google Benchmark for high resolution CPU benchmarks.
