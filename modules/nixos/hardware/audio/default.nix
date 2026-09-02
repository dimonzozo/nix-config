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
  cfg = config.${namespace}.hardware.audio;
in
{
  options.${namespace}.hardware.audio = with types; {
    enable = mkBoolOpt false "Whether or not to enable audio support.";
    extra-packages = mkOpt (listOf package) [
    ] "Additional packages to install.";
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true; # Enable PipeWire as the main audio service
      alsa.enable = true; # Enable ALSA support for compatibility with ALSA applications
      pulse.enable = true; # Enable PulseAudio support for compatibility with PulseAudio applications
      jack.enable = true; # Enable JACK support for professional audio applications
      wireplumber.enable = true; # Enable WirePlumber as the session manager
    };

    environment.systemPackages =
      with pkgs;
      [
        pavucontrol # GUI mixer
        easyeffects # Audio effects and filters
        crosspipe # PipeWire patchbay
        qpwgraph # Another PipeWire patchbay (more graphical)
        # libcamera
        # v4l-utils
      ]
      ++ cfg.extra-packages;

    internal.user.extraGroups = [ "audio" ];
  };
}
