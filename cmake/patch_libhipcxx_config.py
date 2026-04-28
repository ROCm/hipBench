#!/usr/bin/env python3
"""
patch_libhipcxx_config.py <path/to/__config>

Adds TSC clock-rate support for GPU architectures missing from libhipcxx 1.9.0:
  - gfx950  (MI350 / MI355X, CDNA4)
  - gfx1101, gfx1102  (RDNA3 variants)
  - gfx1200, gfx1201  (R9700 / R9700 XT, RDNA4)
  - Generic fallback for any other future architecture

Exits 0 on success (including already-patched), non-zero on error.
"""
import sys, re

def main():
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <path/to/__config>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    with open(path, "r") as f:
        src = f.read()

    # Idempotent check
    if "__gfx950__" in src:
        print(f"[patch_libhipcxx] already patched: {path}")
        sys.exit(0)

    # The exact original TSC block in libhipcxx 1.9.0
    # (trailing spaces on the NANOSECONDS lines are intentional in the source)
    OLD = (
        "#if defined(__gfx908__) || defined(__gfx90a__)\n"
        "#define _LIBCUDACXX_HIP_TSC_CLOCKRATE 25000000\n"
        "#define _LIBCUDACXX_HIP_TSC_NANOSECONDS_PER_CYCLE 40 // (1/_LIBCUDACXX_HIP_TSC_CLOCKRATE)  \n"
        "// gfx940 gfx941 and gfx942: 100 MHz TSC for wall_clock64 -> 1*1e9/100*1e6 ns/cycle = 10 ns/cycle\n"
        "#elif defined(__gfx940__) || defined(__gfx941__) || defined(__gfx942__) || defined(__gfx1100__)\n"
        "#define _LIBCUDACXX_HIP_TSC_CLOCKRATE 100000000\n"
        "#define _LIBCUDACXX_HIP_TSC_NANOSECONDS_PER_CYCLE 10 // (1/_LIBCUDACXX_HIP_TSC_CLOCKRATE)  \n"
        "#endif"
    )

    NEW = (
        "#if defined(__gfx908__) || defined(__gfx90a__)\n"
        "#define _LIBCUDACXX_HIP_TSC_CLOCKRATE 25000000\n"
        "#define _LIBCUDACXX_HIP_TSC_NANOSECONDS_PER_CYCLE 40 // (1/_LIBCUDACXX_HIP_TSC_CLOCKRATE)\n"
        "// gfx940/941/942 (CDNA3), gfx950 (CDNA4),\n"
        "// gfx1100/1101/1102 (RDNA3), gfx1200/1201 (RDNA4):\n"
        "// 100 MHz TSC for wall_clock64 -> 1e9/100e6 ns/cycle = 10 ns/cycle\n"
        "#elif defined(__gfx940__) || defined(__gfx941__) || defined(__gfx942__) \\\n"
        "   || defined(__gfx950__) \\\n"
        "   || defined(__gfx1100__) || defined(__gfx1101__) || defined(__gfx1102__) \\\n"
        "   || defined(__gfx1200__) || defined(__gfx1201__)\n"
        "#define _LIBCUDACXX_HIP_TSC_CLOCKRATE 100000000\n"
        "#define _LIBCUDACXX_HIP_TSC_NANOSECONDS_PER_CYCLE 10 // (1/_LIBCUDACXX_HIP_TSC_CLOCKRATE)\n"
        "#else\n"
        "// Fallback for unknown GPU architectures: assume 100 MHz TSC (safe default).\n"
        "#define _LIBCUDACXX_HIP_TSC_CLOCKRATE 100000000\n"
        "#define _LIBCUDACXX_HIP_TSC_NANOSECONDS_PER_CYCLE 10\n"
        "#endif"
    )

    if OLD not in src:
        # Try a more lenient match (strip trailing spaces from each line)
        old_stripped = "\n".join(l.rstrip() for l in OLD.splitlines())
        src_stripped_lines = "\n".join(l.rstrip() for l in src.splitlines())
        if old_stripped not in src_stripped_lines:
            print(f"[patch_libhipcxx] ERROR: could not find TSC block in {path}", file=sys.stderr)
            print("  Expected block (first line):", OLD.splitlines()[0], file=sys.stderr)
            sys.exit(1)
        # Reconstruct: replace line-by-line using stripped comparison
        lines = src.splitlines(keepends=True)
        old_lines = OLD.splitlines()
        for i in range(len(lines) - len(old_lines) + 1):
            chunk = [l.rstrip("\n").rstrip() for l in lines[i:i+len(old_lines)]]
            if chunk == old_lines:
                patched = lines[:i] + [NEW + "\n"] + lines[i+len(old_lines):]
                with open(path, "w") as f:
                    f.writelines(patched)
                print(f"[patch_libhipcxx] patched (lenient): {path}")
                sys.exit(0)
        print(f"[patch_libhipcxx] ERROR: lenient match failed for {path}", file=sys.stderr)
        sys.exit(1)

    patched = src.replace(OLD, NEW, 1)
    with open(path, "w") as f:
        f.write(patched)
    print(f"[patch_libhipcxx] patched: {path}")

if __name__ == "__main__":
    main()
