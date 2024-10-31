# [nix-darwin] & [Home Manager] Configurations

This repository contains a [Nix Flake](https://zero-to-nix.com/concepts/flakes) for configuring my computers and/or their home environment.
It is not intended to be a drop in configuration for your computer, but might serve as a reference or starting point for your own configuration.

## Installing

### Macos

It is easier to manage configuration if each host has unique hostname. We can make it cool and choose from some theme
i've used [https://hostnamegenerator.com](https://hostnamegenerator.com).

```bash
HOSTNAME=dambrosio

sudo scutil --set HostName "$HOSTNAME"
sudo scutil --set LocalHostName "$HOSTNAME"
sudo scutil --set ComputerName "$HOSTNAME"
```

Installing Macos console utils.

```bash
xcode-select --install
```

Then let's declare few env variables for pleasant scripting.

```bash
CONFIG_DIR=$HOME/.config/nix-config
SOPS_DIR=$HOME/.config/sops/age/
```

Creating config dir and cloning project.

```bash
mkdir -p $CONFIG_DIR
git clone https://github.com/dimonzozo/nix-config $CONFIG_DIR
```

Installing NIX with unoficiall, but very cool installer.
Please read more about it [here](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer).

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

TODO: add block about creating host config here

Applying nix-darwin and home-manager configuration.

```bash
nix run nix-darwin -- switch --flake $HOME/.config/nix-config
nix run home-manager -- switch -b backup --flake $HOME/.config/nix-config
```

## Inspirations

* [Wimpy's NixOS, nix-darwin & Home Manager Configurations](https://github.com/wimpysworld/nix-config)
* [Plus Ultra](https://github.com/jakehamilton/config)

## Resources

* [Youtube: Nix From Nothing #1](https://www.youtube.com/watch?v=t8ydCYe9Y3M)
* [Youtube: Nix From Nothing #2](https://www.youtube.com/watch?v=POUeOSjeJ1w)
* [Nix Installer](https://github.com/DeterminateSystems/nix-installer)
* [Nix Darwin Reference](https://daiderd.com/nix-darwin/manual/index.html)
* [Home-Manager Reference](https://home-manager-options.extranix.com)
* [NixVim Docs](https://nix-community.github.io/nixvim/)

## See also

* [NeoVim Configuration](https://github.com/dimonzozo/neovim)
