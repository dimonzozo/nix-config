{
  config,
  lib,
  internal,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.desktop.qutebrowser;
in
{
  options.${namespace}.desktop.qutebrowser = with types; {
    enable = mkBoolOpt false "Qutebrowser - a keyboard-focused browser with a minimal GUI";
  };

  config = mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;
      keyBindings = {
        command = {
          "<Ctrl-n>" = "completion-item-focus next";
          "<Ctrl-p>" = "completion-item-focus prev";
        };
      };
      settings = {
        "colors.webpage.darkmode.enabled" = true;
        "content.javascript.clipboard" = "access-paste";
        "input.insert_mode.auto_enter" = true;
        "input.insert_mode.auto_leave" = true;
        "input.insert_mode.plugins" = true;
        "qt.force_platform" = "wayland";
        # "qt.force_software_rendering" = "none";
        "qt.args" = [
          # "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
          # "--enable-accelerated-video-decode"
          # "--enable-gpu-rasterization"
          # "--enable-native-gpu-memory-buffers"
          # "--enable-zero-copy"
          # "--ignore-gpu-blocklist"
          # "--use-gl=egl"
          # "--disable-software-rasterizer"
        ];
      };
    };
  };
}
