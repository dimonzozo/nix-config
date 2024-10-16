{
  options,
  lib,
  namespace,
  inputs,
  ...
}:
with lib;
with lib.${namespace};
{
  imports = with inputs; [
    home-manager.darwinModules.home-manager
  ];

  options.${namespace}.home = with types; {
    file = mkOpt attrs { } "A set of files to be managed by home-manager's <option>home.file</option>.";
    configFile =
      mkOpt attrs { }
        "A set of files to be managed by home-manager's <option>xdg.configFile</option>.";
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
    homeConfig = mkOpt attrs { } "Final config for home-manager.";
  };

  config = {
    internal.home.extraOptions = {
      home.stateVersion = mkDefault "22.05";
      home.file = mkAliasDefinitions options.${namespace}.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.${namespace}.home.configFile;
    };

    home-manager = {
      useUserPackages = false;
      useGlobalPkgs = false;
    };
  };
}
