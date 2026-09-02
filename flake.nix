{
  description = "Personal nixos, nix-darwin and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-private.url = "git+ssh://git@github.com/dimonzozo/nix-config-private";
    # nix-private.url = "git+file:///home/dima/.config/nix-config-private";
    nix-private.inputs.nixpkgs.follows = "nixpkgs";
    nix-private.inputs.flake-parts.follows = "flake-parts";

    catppuccin.url = "github:catppuccin/nix/release-26.05";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    microvm.url = "github:astro/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # quickshell.url = "github:outfoxxed/quickshell";
    # quickshell.inputs.nixpkgs.follows = "nixpkgs";

    # noctalia.url = "github:noctalia-dev/noctalia-shell";
    # noctalia.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    # GPG default configuration
    gpg-base-conf = {
      url = "github:drduh/config";
      flake = false;
    };

    bibata-cursors = {
      url = "github:suchipi/Bibata_Cursor";
      flake = false;
    };
  };
  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      internal = import ./lib/internal.nix {
        inherit inputs;
        lib = inputs.nixpkgs.lib;
        home-manager-lib = inputs.home-manager.lib;
      };
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;

        specialArgs = {
          inherit internal;
        };
      }
      {
        imports = [
          inputs.home-manager.flakeModules.default
        ];

        systems = [
          "x86_64-linux"
        ];

        perSystem =
          {
            pkgs,
            ...
          }:
          {
            devShells = {
              kernel-build = pkgs.callPackage ./shells/kernel-build { };
              kernel-dev = pkgs.callPackage ./shells/kernel-dev { };
              verilog-sim = pkgs.callPackage ./shells/verilog-sim { };
            };
          };

        flake = {
          nixosConfigurations = {
            lyria-testvm = internal.mkNixosSystem {
              hostname = "lyria-testvm";
              system = "x86_64-linux";
              hmUsername = "dima";
            };

            lyria = internal.mkNixosSystem {
              hostname = "lyria";
              system = "x86_64-linux";
              hmUsername = "dima";
            };

            toussaint = internal.mkNixosSystem {
              hostname = "toussaint";
              system = "x86_64-linux";
              hmUsername = "dima";
            };

            pine = internal.mkNixosSystem {
              hostname = "pine";
              system = "aarch64-linux";
              hmUsername = "dima";
            };

            vizima = internal.mkNixosSystem {
              hostname = "vizima";
              system = "aarch64-linux";
              hmUsername = "dima";
            };
          };

          homeConfigurations = {
            "dima@cintra" = internal.mkHomeConfiguration {
              username = "dima";
              hostname = "cintra";
              system = "aarch64-darwin";
            };

            "dima@vizima" = internal.mkHomeConfiguration {
              username = "dima";
              hostname = "vizima";
              system = "aarch64-darwin";
            };
          };
        };
      };
}
