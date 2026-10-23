{
  config,
  namespace,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  # Test host for the new-machine bootstrap flow. Install with disko into a
  # VM, boot with sops and impermanence disabled, run
  # scripts/bootstrap-persist.sh, add the printed age key to .sops.yaml and
  # rekey, then enable the two flags below and reboot into tmpfs root.
  internal = {
    user = {
      name = "dima";
    };

    # Stage 2 of the bootstrap: flip both after bootstrap-persist.sh.
    # tools.sops.enable = true;
    # impermanence.enable = true;

    system = {
      locale.enable = true;
      time.enable = true;
      xkb.enable = true;
    };

    nix.enable = true;
  };

  services.openssh.enable = true;

  # Imperative password until impermanence forces mutableUsers = false and
  # the sops hashed password takes over.
  users.mutableUsers = true;

  system.stateVersion = "26.05";

  nixpkgs.config.allowUnfree = true;
}
