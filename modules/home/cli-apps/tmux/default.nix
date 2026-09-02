{
  lib,
  internal,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.cli-apps.tmux;
in
{
  options.${namespace}.cli-apps.tmux = {
    enable = mkEnableOption "Tmux - terminal multiplexer for managing multiple terminal sessions";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      sensibleOnTop = false;
      clock24 = true;
      baseIndex = 1;
      historyLimit = 500000;
      keyMode = "vi";
      shell = "${pkgs.fish}/bin/fish";
      mouse = true;
      terminal = "tmux-256color";
      escapeTime = 10;
      extraConfig = ''
        set -g default-terminal "tmux-256color"
        set-option -sa terminal-features ',alacritty:RGB'
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        # set -ga terminal-overrides '*:kUP3=\e[1;9A,*:kDN3=\e[1;9B,*:kRIT3=\e[1;9C,*:kLFT3=\e[1;9D'
        set-environment -g COLORTERM "truecolor"
        set -g pane-base-index 1
        # set -g @resurrect-strategy-nvim 'session'

        bind k clear-history
        bind y display-popup -E "tmux capture-pane -p | fzf | pbcopy"
        bind k send-keys 'C-l'
        bind P swap-window -t -1 \; prev
        bind N swap-window -t +1 \; next

        bind M-b send-prefix

        bind -n M-t new-window
        bind -n M-w kill-window
        bind -n M-r command-prompt -I "#W" "rename-window '%%'"

        bind -n M-[ previous-window
        bind -n M-] next-window
        bind -n M-S-Left swap-window -t -1\; select-window -t -1
        bind -n M-S-Right swap-window -t +1\; select-window -t +1
        bind -n S-Left previous-window
        bind -n S-Right next-window

        # Switch to specific windows (tabs in tmux terminology)
        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        # Theme settings
        set -g status-left ""
        set -g status-right ""

        # Show status panel only when more than one window opened
        if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"
        set-hook -g window-linked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
        set-hook -g window-unlinked 'if -F "#{==:#{session_windows},1}" "set -g status off" "set -g status on"'
      '';
      plugins = with pkgs.tmuxPlugins; [
        # TODO: update to recent stable versions
        # pain-control
        # sessionist
        # vim-tmux-navigator
        # continuum
        # resurrect
        # {
        #   plugin = mkTmuxPlugin {
        #     pluginName = "cpu";
        #     version = "unstable-2024-10-06";
        #     src = pkgs.fetchFromGitHub {
        #       owner = "tmux-plugins";
        #       repo = "tmux-cpu";
        #       rev = "bcb110d754ab2417de824c464730c412a3eb2769";
        #       hash = "sha256-OrQAPVJHM9ZACyN36tlUDO7l213tX2a5lewDon8lauc=";
        #     };
        #   };
        # }
        # {
        #   plugin = mkTmuxPlugin {
        #     pluginName = "battery";
        #     version = "unstable-2023-12-01";
        #     src = pkgs.fetchFromGitHub {
        #       owner = "tmux-plugins";
        #       repo = "tmux-battery";
        #       rev = "48fae59ba4503cf345d25e4e66d79685aa3ceb75";
        #       hash = "sha256-yKMTuRiNnGC3tAbZeWzMEudzhBSJhji8sZh96rFxpb8=";
        #     };
        #   };
        # }
        {
          plugin = mkTmuxPlugin {
            pluginName = "catppuccin";
            version = "2.1.1";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "tmux";
              rev = "179572333b0473020e45f34fd7c1fd658b2831f4";
              hash = "sha256-9+SpgO2Co38I0XnEbRd7TSYamWZNjcVPw6RWJIHM+4c=";
            };
          };
          extraConfig = ''
            set -g @catppuccin_flavor 'mocha'
          '';
        }
      ];
    };
  };
}
