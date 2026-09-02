{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  name = "kernel-build";
  nativeBuildInputs = with pkgs; [
    # Core build tools
    gcc
    gnumake
    bc
    bison
    flex
    pkg-config

    # Required libraries for kernel tools
    elfutils # Provides libelf.h
    openssl # For signing/crypto
    zlib # Compression
    ncurses # For menuconfig

    # Kernel-specific tools
    pahole
    rsync
    python3
    perl

    # Development tools
    compiledb
    clang-tools
    gdb
  ];

  shellHook = ''
    alias kconfig='make menuconfig'
    alias kbuild='make -j$(nproc)'
    alias gen-kernel-db='scripts/clang-tools/gen_compile_commands.py'
    alias gen-module-db='compiledb make modules'
  '';
}
