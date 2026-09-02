{
  lib,
  config,
  internal,
  pkgs,
  namespace,
  ...
}:
with lib;
with internal;
let
  inherit (pkgs.stdenv) isDarwin;
  cfg = config.${namespace}.cli-apps.helix;
in
{
  options.${namespace}.cli-apps.helix = {
    enable = mkEnableOption "Helix - a post-modern modal text editor";
    package = mkOption {
      type = types.package;
      default = pkgs.helix;
      description = "Helix package to use";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      package = cfg.package;
      settings = {
        theme = "catppuccin_mocha";
        editor = {
          shell = [
            "fish"
            "-c"
          ];
          mouse = true;
          true-color = true;
          auto-save = true;
          idle-timeout = 0;
          bufferline = "never";
          cursorline = true;
          line-number = "relative";
          trim-trailing-whitespace = true;
          end-of-line-diagnostics = "hint";
          # rainbow-brackets = true;
          color-modes = true;
          indent-guides.render = true;
          # default-yank-register = "*";
          soft-wrap = {
            enable = true;
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          statusline = {
            separator = "│";
            left = [
              "mode"
              "spinner"
              "file-name"
              "read-only-indicator"
              "file-modification-indicator"
              "separator"
              "total-line-numbers"
              "separator"
              "spacer"
              "version-control"
            ];
            right = [
              "register"
              "spacer"
              "diagnostics"
              "separator"
              "selections"
              "separator"
              "position"
              "position-percentage"
              "spacer"
              "separator"
              "file-encoding"
              "file-line-ending"
              "separator"
              "file-type"
            ];
          };
          inline-diagnostics = {
            # other-lines = "error";
            cursor-line = "warning";
          };
          lsp = {
            display-messages = true;
            display-inlay-hints = false;
          };
          gutters = [
            "diagnostics"
            "line-numbers"
            "spacer"
            "diff"
          ];
        };
        keys.normal = {
          space.w = ":w";
          space.q = ":q";
          space.l = [
            ":write-all"
            ":sh kitty @ launch --no-response --cwd=current --type=overlay --copy-env lazygit"
            ":reload-all"
          ];
          space.z = [
            ":write-all"
            ":sh kitty @ launch --no-response --cwd=current --type=overlay --copy-env yazi"
            ":reload-all"
          ];
          space.n = [
            (
              if isDarwin then ":sh echo \"%{buffer_name}\" | pbcopy" else ":sh echo \"%{buffer_name}\" | wl-copy"
            )
          ];
          "C-e" = [
            ":sh rm -f /tmp/files2open"
            ":set mouse false"
            ":insert-output yazi \"%{buffer_name}\" --chooser-file=/tmp/files2open"
            ":redraw"
            ":set mouse true"
            ":open /tmp/files2open"
            "select_all"
            "split_selection_on_newline"
            "goto_file"
            ":buffer-close! /tmp/files2open"
          ];
        };
        keys.insert = {
          "C-[" = "normal_mode";
        };
      };
      # Language-specific configurations
      languages = {
        language-server = {
          clangd = {
            command = "clangd";
            config = {
              compilationDatabase = "compile_commands_fixed.json";
            };
          };
          gopls = {
            command = "gopls";
            config = {
              # "diagnostics.disable" = [ "depguard" ];
            };
          };
          qmlls = {
            command = "qmlls";
            args = [ "-E" ];
          };
        };

        language = [
          {
            name = "go";
            formatter = {
              command = pkgs.writeScript "go-formatter" ''
                #!${pkgs.bash}/bin/bash
                ${pkgs.gotools}/bin/goimports | \
                ${pkgs.gofumpt}/bin/gofumpt
              '';
            };
            language-servers = [ "gopls" ];
            auto-format = true;
          }
          {
            name = "rust";
            auto-format = true;
          }
          {
            name = "c";
            auto-format = true;
            language-servers = [ "clangd" ];
          }
          {
            name = "ruby";
            auto-format = true;
          }
          {
            name = "nix";
            auto-format = true;
            formatter.command = lib.getExe pkgs.nixfmt;
          }
          {
            name = "lua";
            auto-format = true;
          }
          {
            name = "html";
          }
          {
            name = "qml";
            language-servers = [ "qmlls" ];
          }
        ];
      };
    };
  };
}
