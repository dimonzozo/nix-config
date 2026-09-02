{
  config,
  pkgs,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.nix;
in
{
  options.${namespace}.nix = with types; {
    enable = mkBoolOpt true "Whether or not to manage nix configuration.";
    package = mkOpt package pkgs.lix "Which nix package to use.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      deploy-rs
      nil
      nixfmt
      nix-index
      nix-output-monitor
      nix-prefetch-git
    ];

    nix =
      let
        users = [
          "root"
          config.${namespace}.user.name
        ]
        ++ optional config.services.hydra.enable "hydra";
      in
      {
        package = cfg.package;

        settings = {
          experimental-features = "nix-command flakes";
          http-connections = 50;
          warn-dirty = false;
          log-lines = 50;
          # sandbox = "relaxed";
          auto-optimise-store = true;
          trusted-users = users;
          allowed-users = users;
        };

        optimise.automatic = true;

        gc = {
          # disabling it for a now, bacause it keeps collecting my
          # devShells
          automatic = false;
          # dates = "weekly";
          # options = "--delete-older-than 30d";
        };
      };
  };
}
