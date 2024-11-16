{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.tools.git;
  user = config.${namespace}.user;
in
{
  options.${namespace}.tools.git = with types; {
    enable = mkBoolOpt false "Whether or not to install and configure git.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
    signingKey = mkOpt types.str "" "The key ID to sign commits with.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      delta
      difftastic
    ];

    programs.git = {
      enable = true;
      inherit (cfg) userName userEmail;

      aliases = {
        stdiff = "diff";
        deltadiff = "!delta";
        dfdiff = "!difft";
      };
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        pull = {
          default = "current";
          rebase = true;
        };
        merge = {
          conflictStyle = "zdiff3";
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          colorMovedWS = "allow-indentation-change";
          external = "difft";
        };
        core = {
          whitespace = "trailing-space,space-before-tab";
          pager = "delta";
        };
        color = {
          ui = true;
        };
        rerere = {
          enabled = true;
        };
        column = {
          ui = "auto";
        };
        branch = {
          sort = "-committerdate";
        };
        # Delta configuration
        delta = {
          features = "decorations";
          side-by-side = true;
          line-numbers = true;
          navigate = true;
          light = false;
          dark = true;
          syntax-theme = "Catppuccin-mocha";
          plus-style = "syntax #1a332a";
          minus-style = "syntax #332222";
          commit-decoration-style = "bold #f5c2e7 box ul";
          file-style = "bold #89b4fa ul";
          file-decoration-style = "none";
          hunk-header-decoration-style = "cyan box ul";
          whitespace-error-style = "#45475a reverse";
        };
      };
      ignores = [
        ".DS_Store"
        ".svn"
        "*~"
        "*.swp"
        "*.rbc"
        "/vendor/bundle"
        ".idea"
        ".vscode"
        ".editorconfig"
        # Additional common ignores
        "*.log"
        "node_modules/"
        ".env"
        ".env.local"
        ".env.*.local"
        "coverage/"
        "dist/"
        ".cache/"
        ".tmp/"
      ];
    };
  };
}
