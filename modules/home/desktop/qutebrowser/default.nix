{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.qutebrowser;
in
{
  options.${namespace}.desktop.qutebrowser = with types; {
    enable = mkBoolOpt false "Qutebrowser.";
  };

  config = mkIf cfg.enable {
    programs.qutebrowser = {
      enable = true;
      settings = {
        "colors.webpage.darkmode.enabled" = true;
        "content.javascript.clipboard" = "access-paste";
        "input.insert_mode.auto_enter" = true;
        "input.insert_mode.auto_leave" = true;
        "input.insert_mode.plugins" = true;
        "qt.force_platform" = "wayland";
        "qt.force_software_rendering" = "none";
        "qt.args" = [
          "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
          "--enable-accelerated-video-decode"
          "--enable-gpu-rasterization"
          "--enable-native-gpu-memory-buffers"
          "--enable-zero-copy"
          "--ignore-gpu-blocklist"
          "--use-gl=egl"
          "--disable-software-rasterizer"
        ];
      };
    };
  };
}
