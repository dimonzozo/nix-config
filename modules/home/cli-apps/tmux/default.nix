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
      historyLimit = 100000;
      keyMode = "vi";
      shell = "${pkgs.fish}/bin/fish";
      mouse = true;
      terminal = "tmux-256color";
      extraConfig = ''
        set -g default-terminal "tmux-256color"
        set-option -sa terminal-features ',alacritty:RGB'
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        # set -ga terminal-overrides '*:kUP3=\e[1;9A,*:kDN3=\e[1;9B,*:kRIT3=\e[1;9C,*:kLFT3=\e[1;9D'
        set-environment -g COLORTERM "truecolor"
        set -g pane-base-index 1

        bind k clear-history
        bind y display-popup -E "tmux capture-pane -p | fzf | pbcopy"
        bind k send-keys 'C-l'

        # dracula theme settings
        set -g @dracula-show-timezone false
        set -g @dracula-plugins "battery ssh-session time"
        set -g @dracula-show-empty-plugins false
        set -g @dracula-refresh-rate 10
      '';
      plugins = with pkgs.tmuxPlugins; [
        tmux-fzf
        vim-tmux-navigator
        pain-control
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-show-timezone false
            set -g @dracula-plugins "battery ssh-session time"
            set -g @dracula-show-empty-plugins false
            set -g @dracula-refresh-rate 10
          '';
        }
      ];
    };
  };
}
