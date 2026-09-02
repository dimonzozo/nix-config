{
  pkgs,
  mkShell,
  ...
}:
mkShell {
  name = "verilog-sim";
  nativeBuildInputs = with pkgs; [
    # Icarus Verilog - Open source Verilog simulation and synthesis tool
    iverilog

    # GTKWave - Waveform viewer
    gtkwave

    # Verilator - Fast Verilog/SystemVerilog simulator
    verilator

    # Yosys - Verilog synthesis suite
    yosys

    # Verilog Language Server - Note we're using the one from nodePackages
    # internal.svlangserver

    # Other useful tools
    gnumake
    python3
  ];
}
