{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.hardware.audio;
in
{
  options.${namespace}.hardware.audio = with types; {
    enable = mkBoolOpt false "Whether or not to enable audio support.";
    extra-packages = mkOpt (listOf package) [
      pkgs.qjackctl
      pkgs.easyeffects
    ] "Additional packages to install.";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;
    };

    environment.etc = {
      # "pipewire/pipewire.conf.d/10-pipewire.conf".source =
      #   pkgs.writeText "pipewire.conf" (builtins.toJSON pipewire-config);
      # "pipewire/pipewire.conf.d/21-alsa.conf".source =
      #   pkgs.writeText "pipewire.conf" (builtins.toJSON alsa-config);

      #       "wireplumber/wireplumber.conf".source =
      #         pkgs.writeText "pipewire.conf" (builtins.toJSON pipewire-config);

      # "wireplumber/scripts/config.lua.d/alsa.lua".text = ''
      #   local input = ${lua-format.generate "sample.lua" cfg.alsa-monitor}

      #   if input.rules == nil then
      #    input.rules = {}
      #   end

      #   local rules = input.rules

      #   for _, rule in ipairs(input.rules) do
      #     table.insert(alsa_monitor.rules, rule)
      #   end
      # '';
    };

    hardware.pulseaudio.enable = mkForce false;

    environment.systemPackages =
      with pkgs;
      [
        pulsemixer
        pavucontrol
      ]
      ++ cfg.extra-packages;

    internal.user.extraGroups = [ "audio" ];
  };
}
