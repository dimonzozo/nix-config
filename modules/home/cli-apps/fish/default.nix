{
  lib,
  config,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.${namespace}.cli-apps.fish;
in
{
  options.${namespace}.cli-apps.fish = {
    enable = mkEnableOption "Fish Shell.";
    manageSshKeys = mkEnableOption "Manage SSH keys.";
    manageSshConfig = mkEnableOption "Manage SSH config.";
    atuinSync = mkEnableOption "Enable Atuin history sync.";
    includeSecretAliases = mkEnableOption "Include secret Fish aliases.";
  };

  config =
    let
      manageSshKeys = config.${namespace}.tools.sops.enable && cfg.manageSshKeys;
      manageSshConfig = config.${namespace}.tools.sops.enable && cfg.manageSshConfig;
      manageAtuinKeys = config.${namespace}.tools.sops.enable && cfg.atuinSync;
      includeSecretAliases = config.${namespace}.tools.sops.enable && cfg.includeSecretAliases;
    in
    # tVal = pkgs.lib.debug.traceVal;
    # tSeq = pkgs.lib.debug.traceSeq;
    mkIf cfg.enable {
      sops = {
        secrets = lib.mkMerge (
          [ ]
          ++ lib.optionals manageSshKeys [
            {
              ssh_key = {
                mode = "0600";
                path = "${config.home.homeDirectory}/.ssh/id_${config.home.username}";
              };
              ssh_pub = {
                mode = "0644";
                path = "${config.home.homeDirectory}/.ssh/id_${config.home.username}.pub";
              };
            }
          ]
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
          catppuccin.enable = true;
          enable = true;
          interactiveShellInit =
            ''
              set fish_greeting # Disable greeting
            ''
            + lib.strings.optionalString includeSecretAliases ''
              # include secret shell aliases
              source ${config.sops.secrets.secret_fish_aliases.path}
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
          shellAliases = {
            b = "bundle";
            d = "docker";
            dc = "docker-compose";
            be = "bundle exec";
            rub = "be rubocop";
            l = "eza -lah";
            lg = "lazygit";
            ldo = "lazydocker";
            ssh0 = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR";
            scp0 = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
            sshy = "ssh -o CheckHostIP=no";
            fda = "fd -IH";
            rga = "rg -uuu";
            g = "git";
            ls = "ls -alh";
            ggpush = "git push origin (__git.current_branch)";
          };
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
              format = "\\([$state( $progress_current/$progress_total)]($style)\) ";
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
          };
        };
      };
    };
}
