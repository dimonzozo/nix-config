{
  inputs,
  lib,
  home-manager-lib,
  ...
}:

with builtins;
with lib;
with home-manager-lib;
let
  internal = rec {
    ## Create a NixOS module option.
    ##
    ## ```nix
    ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
    ## ```
    ##
    #@ Type -> Any -> String
    mkOpt =
      type: default: description:
      mkOption { inherit type default description; };

    ## Create a boolean NixOS module option.
    ##
    ## ```nix
    ## lib.mkBoolOpt true "Description of my option."
    ## ```
    ##
    #@ Type -> Any -> String
    mkBoolOpt = mkOpt types.bool;

    ## Matchers for file kinds. These are often used with `readDir`.
    ## Example Usage:
    ## ```nix
    ## is-file-kind "directory"
    ## ```
    ## Result:
    ## ```nix
    ## false
    ## ```
    #@ String -> Bool
    is-file-kind = kind: kind == "regular";
    is-directory-kind = kind: kind == "directory";

    ## Safely read from a directory if it exists.
    ## Example Usage:
    ## ```nix
    ## safe-read-directory ./some/path
    ## ```
    ## Result:
    ## ```nix
    ## { "my-file.txt" = "regular"; }
    ## ```
    #@ Path -> Attrs
    safe-read-directory = path: if pathExists path then readDir path else { };

    ## Get files at a given path, traversing any directories within.
    ## Example Usage:
    ## ```nix
    ## get-files-recursive ./something
    ## ```
    ## Result:
    ## ```nix
    ## [ "./something/some-directory/a-file" ]
    ## ```
    #@ Path -> [Path]
    get-files-recursive =
      path:
      let
        entries = safe-read-directory path;
        filtered-entries = filterAttrs (
          name: kind: (is-file-kind kind) || (is-directory-kind kind)
        ) entries;
        map-file =
          name: kind:
          let
            path' = "${path}/${name}";
          in
          if is-directory-kind kind then get-files-recursive path' else path';
        files = flatten (mapAttrsToList map-file filtered-entries);
      in
      files;

    ## Get nix files at a given path named "default.nix", traversing any directories within.
    ## Example Usage:
    ## ```nix
    ## get-default-nix-files-recursive "./something"
    ## ```
    ## Result:
    ## ```nix
    ## [ "./something/some-directory/default.nix" ]
    ## ```
    #@ Path -> [Path]
    get-default-nix-files-recursive =
      path: builtins.filter (name: builtins.baseNameOf name == "default.nix") (get-files-recursive path);

    mkNixosSystem =
      {
        hostname,
        system,
        hmUsername ? null,
        ...
      }:
      let
        nixosModules = (get-default-nix-files-recursive ../modules/nixos);

        homeManagerModule = {
          imports = [
            inputs.home-manager.nixosModules.home-manager
          ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs internal;
              namespace = "internal";
            };
            users.${hmUsername}.imports = [
              (../homes + "/${system}/${hmUsername}@${hostname}")
            ]
            ++ (get-default-nix-files-recursive ../modules/home);
          };
        };

        homeManagerIntegration = lib.optionals (hmUsername != null) [
          homeManagerModule
        ];

        coreConfiguration = [
          {
            networking.hostName = hostname;
            nixpkgs.config.allowUnfree = true;
          }
        ];

        overlays = [
          {
            nixpkgs.overlays = [
              inputs.microvm.overlay
            ];
          }
        ];

        extraModules = [ ];

        systemConfiguration = [ ../systems/${system}/${hostname} ];
      in
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs internal;
          namespace = "internal";
        };

        modules =
          nixosModules
          ++ homeManagerIntegration
          ++ coreConfiguration
          ++ overlays
          ++ systemConfiguration
          ++ extraModules;
      };

    # Helper to make a Home Manager configuration
    mkHomeConfiguration =
      {
        username,
        hostname,
        system,
      }:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          inherit inputs internal;
          namespace = "internal";
        };

        modules = (get-default-nix-files-recursive ../modules/home) ++ [
          inputs.sops-nix.homeManagerModules.sops
          (../homes + "/${system}/${username}@${hostname}")
        ];
      };

    mkNginxProxyPassHost = (
      host: localPort: {
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
        ];
        locations."/" = {
          proxyPass = "http://${host}:${toString localPort}";
          proxyWebsockets = true;
        };
      }

    );

    mkNginxProxyPass = (localPort: mkNginxProxyPassHost "127.0.0.1" localPort);
  };
in
internal
