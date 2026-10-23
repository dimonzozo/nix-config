{
  config,
  lib,
  internal,
  namespace,
  inputs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.impermanence;
  hostFiles = builtins.attrNames (builtins.readDir ./hosts);
  supportedHosts = map (
    filename: builtins.substring 0 ((builtins.stringLength filename) - 4) filename
  ) (builtins.filter (filename: lib.hasSuffix ".nix" filename) hostFiles);
in
{
  # Two-stage design, on purpose: host files activate on hostname match
  # alone, so the /persist bind mounts are live from the first rebuild and
  # state accumulates while the system still boots from the btrfs root
  # subvolume. The enable flag only arms the destructive part (tmpfs /,
  # mutableUsers = false) inside each host file. New-host flow:
  # scripts/bootstrap-persist.sh, rekey sops, flip the flag, reboot.
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ]
  ++
    # Import all host files - they will be conditionally activated
    (map (host: ./hosts/${host}.nix) supportedHosts);

  options.${namespace}.impermanence = with types; {
    enable = mkBoolOpt false "Enable impermanence module.";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.elem config.networking.hostName supportedHosts;
        message = ''
          Impermanence configuration is only allowed on supported hosts.
          Supported hosts: ${toString supportedHosts}
          Current host: ${config.networking.hostName}
        '';
      }
    ];
  };
}
