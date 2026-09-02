{
  pkgs,
  mkShell,
  ...
}:
let
  kernelDevPackage = pkgs.linuxPackages_6_6.kernel.dev;
in
mkShell {
  name = "kernel-dev";
  nativeBuildInputs = with pkgs; [
    bear
    clang-tools
    gdb
    gettext
    kernelDevPackage
    python3
    # Kernel development
    pahole
    sparse
    # Static analysis
    flawfinder
    cppcheck
  ];

  shellHook = ''
    export KERNEL_SRC="${kernelDevPackage}/lib/modules/${kernelDevPackage.version}/build"
    export KERNEL_SOURCE="${kernelDevPackage}/lib/modules/${kernelDevPackage.version}/source"
    envsubst < .clangd.template > .clangd
  '';
}
