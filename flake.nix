{
  description = "My nix-darwin and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    catppuccin.url = "github:catppuccin/nix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    snowfall-lib.url = "github:snowfallorg/lib";
    snowfall-lib.inputs.nixpkgs.follows = "nixpkgs";

    neovim.url = "github:dimonzozo/neovim";
    neovim.inputs.nixpkgs.follows = "nixpkgs-unstable";

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
    lib.mkFlake {
      inherit inputs;

      overlays = with inputs; [
        neovim.overlays.default
      ];

      src = ./.;
    };
}
