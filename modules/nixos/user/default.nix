{
  config,
  pkgs,
  lib,
  internal,
  namespace,
  inputs,
  ...
}:
with lib;
with internal;
let
  cfg = config.${namespace}.user;
in
{
  options.${namespace}.user = with types; {
    name = mkOpt str "dima" "The name to use for the user account.";
    fullName = mkOpt str "Dmitrii Miaskovskii" "The full name of the user.";
    email = mkOpt str "dimonzozo@gmail.com" "The email of the user.";
    initialPassword =
      mkOpt str "password"
        "The initial password to use when the user is first created.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.catppuccin.nixosModules.catppuccin
  ];

  config = {
    programs.zsh = {
      enable = true;
      autosuggestions.enable = true;
      histFile = "$XDG_CACHE_HOME/zsh.history";
    };

    # internal.home = {
    #   file = {
    #     "Desktop/.keep".text = "";
    #     "Documents/.keep".text = "";
    #     "Downloads/.keep".text = "";
    #     "Music/.keep".text = "";
    #     "Pictures/.keep".text = "";
    #     "Videos/.keep".text = "";
    #     "work/.keep".text = "";
    #     "projects/.keep".text = "";
    #   };
    # };

    users.users.${cfg.name} =
      let
        hashedPasswordFile = lib.attrByPath [
          "users_${cfg.name}_hashed_password"
          "path"
        ] null config.sops.secrets;
      in
      {
        isNormalUser = true;

        inherit (cfg) name;
        inherit hashedPasswordFile;

        initialPassword = if hashedPasswordFile == null then cfg.initialPassword else null;

        home = "/home/${cfg.name}";
        group = "users";

        shell = pkgs.bash;

        extraGroups = [
          "wheel"
          "video"
          "render"
          "input"
        ]
        ++ cfg.extraGroups;
      }
      // cfg.extraOptions;
  };
}
