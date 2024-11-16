{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.pyprland;
  configDir = ".config";
in
{
  options.${namespace}.desktop.addons.pyprland = {
    enable = mkBoolOpt false "Whether or not to enable pyprland.";

    scratchpads = mkOpt (types.attrsOf (
      types.submodule {
        options = {
          command = mkOpt types.str "" "Command to execute for the scratchpad";
          animation = mkOpt types.str "fromTop" "Animation style";
          unfocus = mkOpt types.str "hide" "Action on unfocus";
          excludes = mkOpt types.str "*" "Window exclusions";
          lazy = mkBoolOpt true "Whether to lazy load the scratchpad";
          multi = mkBoolOpt false "Allow multiple instances";
          class = mkOpt types.str "" "Window class";
          size = mkOpt types.str "" "Window size (format: 'width% height%')";
          margin = mkOpt types.int 0 "Window margin";
        };
      }
    )) { } "Scratchpad configurations";

    shortcuts = mkOpt (types.attrsOf (types.listOf types.anything)) { } "Shortcut menu entries";

    plugins = mkOpt (types.listOf types.str) [
      "scratchpads"
      "magnify"
      "expose"
      "shortcuts_menu"
      "toggle_special"
    ] "List of plugins to enable";
  };

  config = mkIf cfg.enable {
    # Required packages
    environment.systemPackages = with pkgs; [
      python3
      pyprland
      hyprpicker
    ];

    # Configuration files
    home-manager.users.${config.${namespace}.user.name} = {
      home.file = {
        "${configDir}/hypr/pyprland.toml" = {
          text = ''
            [pyprland]
            plugins = [
              ${concatStringsSep ",\n  " (map (p: ''"${p}"'') cfg.plugins)}
            ]

            ${concatMapStrings (
              name:
              let
                pad = cfg.scratchpads.${name};
              in
              ''
                [scratchpads.${name}]
                command = "${pad.command}"
                animation = "${pad.animation}"
                unfocus = "${pad.unfocus}"
                excludes = "${pad.excludes}"
                lazy = ${if pad.lazy then "true" else "false"}
                multi = ${if pad.multi then "true" else "false"}
                ${optionalString (pad.class != "") ''class = "${pad.class}"''}
                ${optionalString (pad.size != "") ''size = "${pad.size}"''}
                ${optionalString (pad.margin != 0) ''margin = ${toString pad.margin}''}
              ''
            ) (attrNames cfg.scratchpads)}

            [shortcuts_menu.entries]
            ${concatStringsSep "\n" (
              mapAttrsToList (
                name: shortcut:
                let
                  options = builtins.head shortcut;
                  command = builtins.elemAt shortcut 1;
                in
                ''
                  "${name}" = [
                    {name = "${options.name}", options = ${builtins.toJSON options.options}},
                    "${command}"
                  ]''
              ) cfg.shortcuts
            )}
          '';
        };
      };

      # Hyprland config additions
      wayland.windowManager.hyprland.extraConfig = ''
        exec-once = pypr
      '';
    };
  };
}
