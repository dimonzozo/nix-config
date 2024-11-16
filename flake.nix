{
  description = "My nix-darwin and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:dimonzozo/neovim";
    neovim.inputs.nixpkgs.follows = "unstable";

    matugen.url = "github:InioX/matugen?ref=v2.2.0";
    matugen.inputs.nixpkgs.follows = "nixpkgs";

    ags.url = "github:Aylur/ags?ref=v1.8.2";
    ags.inputs.nixpkgs.follows = "nixpkgs";

    # Yubikey Guide
    yubikey-guide = {
      url = "github:drduh/YubiKey-Guide";
      flake = false;
    };

    # GPG default configuration
    gpg-base-conf = {
      url = "github:drduh/config";
      flake = false;
    };

    bibata-cursors = {
      url = "github:suchipi/Bibata_Cursor";
      flake = false;
    };

    harpoon2 = {
      url = "github:ThePrimeagen/harpoon?ref=harpoon2";
      flake = false;
    };
  };
  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
      };
    in

    # nix run nix-darwin -- switch --flake $HOME/.config/nix-config/
    # nix run home-manager -- switch -b backup --flake $HOME/.config/nix-config/
    # sudo nixos-rebuild switch --flake $HOME/.config/nix-config/
    lib.mkFlake {
      inherit inputs;

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-25.9.0"
          "electron-27.3.11"
        ];
      };

      overlays = with inputs; [
        neovim.overlays.default
        hyprpanel.overlay
      ];

      src = ./.;
    };
}
