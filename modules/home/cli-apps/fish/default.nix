{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (pkgs.stdenv) isDarwin isLinux;

  cfg = config.${namespace}.cli-apps.fish;
in
{
  options.${namespace}.cli-apps.fish = {
    enable = mkEnableOption "Fish - a smart and user-friendly command line shell";
    manageSshConfig = mkEnableOption "Manage SSH config.";
    atuinSync = mkEnableOption "Enable Atuin history sync.";
    includeSecretAliases = mkEnableOption "Include secret Fish aliases.";
  };

  config =
    let
      manageSshConfig = config.${namespace}.tools.sops.enable && cfg.manageSshConfig;
      manageAtuinKeys = config.${namespace}.tools.sops.enable && cfg.atuinSync;
      includeSecretAliases = config.${namespace}.tools.sops.enable && cfg.includeSecretAliases;

      # passage-otp: generate a TOTP code from an otpauth:// URI stored in a passage entry.
      passageOtp = pkgs.writeShellApplication {
        name = "passage-otp";
        runtimeInputs = [
          pkgs.oath-toolkit
          pkgs.passage
        ]
        ++ lib.optionals isLinux [ pkgs.wl-clipboard ];
        text = builtins.readFile ./passage-otp.sh;
      };
    in
    mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.manageSshConfig -> config.${namespace}.tools.sops.enable;
          message = ''
            internal.cli-apps.fish.manageSshConfig requires internal.tools.sops.enable to be true
          '';
        }
        {
          assertion = cfg.atuinSync -> config.${namespace}.tools.sops.enable;
          message = ''
            internal.cli-apps.fish.atuinSync requires internal.tools.sops.enable to be true
          '';
        }
        {
          assertion = cfg.includeSecretAliases -> config.${namespace}.tools.sops.enable;
          message = ''
            internal.cli-apps.fish.includeSecretAliases requires internal.tools.sops.enable to be true
          '';
        }
      ];

      # Install passage-otp into ~/.local/bin with fish completion mirroring passage's.
      home.file.".local/bin/passage-otp".source = lib.getExe passageOtp;
      xdg.configFile."fish/completions/passage-otp.fish".source = ./passage-otp.fish;

      sops = {
        secrets = lib.mkMerge (
          [ ]
          ++ lib.optionals manageSshConfig [
            {
              ssh_config = {
                path = "${config.home.homeDirectory}/.ssh/config";
              };
            }
          ]
          ++ lib.optionals includeSecretAliases [
            {
              secret_fish_aliases = {
                path = "${config.home.homeDirectory}/.config/fish/secret_aliases.fish";
              };
            }
          ]
          ++ lib.optionals manageAtuinKeys [
            {
              atuin_key = {
                path = "${config.home.homeDirectory}/.local/share/atuin/key";
              };
            }
          ]
        );
      };

      programs = {
        nix-search-tv.enable = true;

        atuin = mkIf cfg.atuinSync {
          enable = true;
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          package = pkgs.atuin;
          flags = [ "--disable-up-arrow" ];
          settings = {
            auto_sync = true;
            dialect = "us";
            key_path = config.sops.secrets.atuin_key.path or "";
            show_preview = true;
            style = "compact";
            sync_frequency = "1h";
            sync_address = "https://api.atuin.sh";
            update_check = false;
            enter_accept = false;
            sync = {
              records = true;
            };
          };
        };

        fish = {
          enable = true;
          interactiveShellInit = ''
            set fish_greeting # Disable greeting
            export PATH="$HOME/.local/bin:$PATH"
          ''
          + lib.strings.optionalString includeSecretAliases ''
            # include secret shell aliases
            source ${config.sops.secrets.secret_fish_aliases.path}
          ''
          + lib.strings.optionalString (config.services.ssh-agent.enable && isDarwin) ''
            set -x SSH_AUTH_SOCK $(${pkgs.getconf}/bin/getconf DARWIN_USER_TEMP_DIR)ssh-agent
          '';
          plugins = [
            {
              name = "git";
              src = pkgs.fishPlugins.plugin-git.src;
            }
            {
              name = "fzf";
              src = pkgs.fishPlugins.fzf-fish.src;
            }
          ];
          functions = {
            nr = {
              description = "";
              body = ''
                nix run nixpkgs#$argv[1] -- $argv[2..]
              '';
            };
            ns = {
              body = ''
                "${pkgs.nix-search-tv.src}/nixpkgs.sh"
              '';
            };
            nsh = {
              description = "";
              body = ''
                set -l packages
                set -l cmd_args
                set -l parsing_packages true

                for arg in $argv
                  if test $parsing_packages = true
                    if string match -q -- "-*" $arg
                      set parsing_packages false
                      set -a cmd_args $arg
                    else
                      set -a packages nixpkgs#$arg
                    end
                  else
                    set -a cmd_args $arg
                  end
                end

                # Default to -c fish if no command specified
                if test (count $cmd_args) -eq 0
                  set cmd_args "-c" "fish"
                end

                # Create a meaningful shell name from package names
                set -l package_names
                for pkg in $packages
                  set -a package_names (string replace "nixpkgs#" "" $pkg)
                end
                set -l shell_name (string join "+" $package_names)

                # Handle nesting by preserving existing nix shell info
                set -l current_name $name
                if test -n "$current_name"
                  set shell_name "$current_name>$shell_name"
                end

                # Set environment variables for starship
                env IN_NIX_SHELL=pure name=$shell_name nix shell $packages $cmd_args
              '';
            };
            ce = {
              description = "";
              body = ''
                # Requires one argument
                if test (count $argv) -ne 1
                    echo "Usage: ce <config_file>"
                    return 1
                end

                set -l config_path $argv[1]
                set -l temp_path "/tmp/$(basename $config_path).tmp"

                # Check if file exists and is readable
                if not test -r $config_path
                    echo "Error: Cannot read $config_path"
                    return 1
                end

                # Create temporary copy with same permissions
                if not sudo cp -p $config_path $temp_path
                    echo "Error: Failed to create temporary copy"
                    return 1
                end

                # Edit the temp file
                sudo $EDITOR $temp_path

                # Check if file was modified (compare with original)
                if cmp -s $config_path $temp_path
                    echo "No changes made"
                    sudo rm $temp_path
                    return 0
                end

                # Replace original with edited version
                if sudo cp -p $temp_path $config_path
                    echo "Changes applied to $config_path"
                    sudo rm $temp_path
                    return 0
                else
                    echo "Error: Failed to apply changes. Temporary file preserved at $temp_path"
                    return 1
                end
              '';
            };
          };
          shellAliases =
            let
              baseAliases = {
                b = "bundle";
                d = "docker";
                dc = "docker-compose";
                be = "bundle exec";
                rub = "be rubocop";
                lg = "lazygit";
                ldo = "lazydocker";
                ssh0 = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR";
                scp0 = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
                sshy = "ssh -o CheckHostIP=no";
                fda = "fd -IH";
                rga = "rg -uuu";
                g = "git";
                ls = "eza --hyperlink";
                ll = "eza -alh --hyperlink";
                ggpush = "git push origin (__git.current_branch)";
                ee = "cd $HOME/.config/nix-config && $EDITOR .";
                vimdiff = "nvim -d";
                vi = "nvim";
                vim = "nvim";
                s = "systemctl";
                j = "journalctl";
                us = "systemctl --user";
                z = "zellij";
                za = "zellij attach -c";
              };
              linuxAliases = lib.optionalAttrs isLinux {
                sw = "nh os switch \"$HOME/.config/nix-config\"";
              };
              darwinAliases = lib.optionalAttrs isDarwin {
                sw = "nh home switch \"$HOME/.config/nix-config\"";
              };
            in
            baseAliases // linuxAliases // darwinAliases;
        };
        starship = {
          enable = true;
          settings = {
            add_newline = false;
            format = "$username$hostname$directory$nix_shell$git_branch$git_state$git_status$cmd_duration$line_break$python$character";
            directory = {
              style = "blue";
            };
            character = {
              success_symbol = "[➜](bold green)";
              error_symbol = "[✗](bold red) ";
              vicmd_symbol = "[](bold blue) ";
            };
            git_branch = {
              format = "[$branch]($style)";
              style = "bright-black";
            };
            git_status = {
              format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
              style = "cyan";
              conflicted = "​";
              untracked = "​";
              modified = "​";
              staged = "​";
              renamed = "​";
              deleted = "​";
              stashed = "≡";
            };
            git_state = {
              format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
              style = "bright-black";
            };
            cmd_duration = {
              format = "[$duration]($style) ";
              style = "yellow";
            };
            python = {
              format = "[$virtualenv]($style) ";
              style = "bright-black";
            };
            nix_shell = {
              impure_msg = "[impure shell](bold red)";
              pure_msg = "[pure shell](bold green)";
              unknown_msg = "[unknown shell](bold yellow)";
              format = "via [❄️ $state( \($name\))](bold blue) ";
            };
          };
        };
      };
    };
}
