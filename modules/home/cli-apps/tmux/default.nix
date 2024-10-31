{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.cli-apps.tmux;
in
{
  options.${namespace}.cli-apps.tmux = {
    enable = mkEnableOption "Tmux";
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
      '';
      plugins = with pkgs.tmuxPlugins; [
        pain-control
        sessionist
        vim-tmux-navigator
        continuum
        resurrect
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-continuum-mode countdown
            set -g @dracula-day-month true
            set -g @dracula-show-left-icon session
            set -g @dracula-show-flags false
            set -g @dracula-show-powerline false
            set -g @dracula-show-timezone false
            set -g @dracula-plugins "battery time"
            set -g @dracula-show-location false
            set -g @dracula-show-fahrenheit false
            set -g @dracula-show-empty-plugins false
            set -g @dracula-refresh-rate 10
            set -g @dracula-time-format "%a %d/%m %H:%M"
          '';
        }
      ];
    };
  };
}
