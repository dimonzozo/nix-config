# Renders what plasma-manager will write into the real KDE config files, but
# rooted at ./result instead of $HOME, so it can be inspected without touching
# a live Plasma session. See README.md, "Seeing what gets written".
{
  flake ? ../../../..,
  host ? "vizima",
  user ? "dima",
  root ? "result",
}:
let
  self = builtins.getFlake (toString flake);
  lib = self.inputs.nixpkgs.lib;
  plasma = self.nixosConfigurations.${host}.config.home-manager.users.${user}.programs.plasma;
  prefix = dir: lib.mapAttrs' (path: v: lib.nameValuePair "${root}/${dir}/${path}" v);
in
{
  # The attrset plasma-manager feeds to write_config.py, keyed by file path.
  data =
    (prefix "home" plasma.file)
    // (prefix "config" plasma.configFile)
    // (prefix "data" plasma.dataFile);

  # Files whose undeclared keys are dropped rather than merged. Empty unless
  # overrideConfig is on (bar kwinrulesrc, which window-rules always claims).
  resetFiles = map (f: "${root}/config/${f}") (
    lib.subtractLists plasma.resetFilesExclude plasma.resetFiles
  );

  immutableByDefault = plasma.immutableByDefault;
}
