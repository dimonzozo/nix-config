{
  config,
  lib,
  namespace,
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
    programs.git = {
      enable = true;
      inherit (cfg) userName userEmail;
      difftastic = {
        enable = true;
        display = "inline"; # or "side-by-side-show-both"
      };
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        push = {
          default = "matching";
          autoSetupRemote = true;
        };
        pull = {
          rebase = true;
        };
        core = {
          whitespace = "trailing-space,space-before-tab";
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
      ];
    };
  };
}
