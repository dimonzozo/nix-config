# nix-config

A [Nix flake](https://zero-to-nix.com/concepts/flakes) that configures my machines: NixOS hosts
(x86_64 and Apple Silicon) and Home Manager environments on macOS.

It is not a drop-in configuration for someone else's computer. It might be useful as a reference
for a small, hand-rolled flake layout that does not depend on a framework library.

## Design

The whole wiring lives in two files:

* `flake.nix` declares inputs and lists the hosts.
* `lib/internal.nix` provides `mkNixosSystem` and `mkHomeConfiguration`, plus a few helpers
  (`mkOpt`, `mkBoolOpt`, `mkNginxProxyPass`).

`mkNixosSystem { hostname; system; hmUsername; }` assembles a NixOS system from:

1. every `modules/nixos/**/default.nix` (auto-discovered, always imported, each guarded by its own
   `enable` option);
2. Home Manager as a NixOS module, loading every `modules/home/**/default.nix` and
   `homes/<system>/<user>@<host>/default.nix` for `hmUsername`;
3. `systems/<system>/<host>/default.nix` (the host itself, usually importing `hardware.nix`);
4. a small core: hostname, `allowUnfree`, the microvm overlay.

`mkHomeConfiguration { username; hostname; system; }` does the same for standalone Home Manager
(macOS), loading `modules/home/**` and `homes/<system>/<user>@<host>`.

All custom options live under the `internal` namespace, for example `internal.desktop.plasma.enable`
or `internal.tools.sops.enable`. A host is mostly a list of such switches plus host-specific
services. The module argument `namespace` is always `"internal"`; modules use it so the prefix is
defined in one place.

### Public and private split

Anything that describes my network or self-hosted services lives in a separate private flake,
consumed as the `nix-private` input (`git+ssh://git@github.com/dimonzozo/nix-config-private`).
It exports plain NixOS modules (`acme`, `lyria-network`, `smart-home`, `vault`, `mvm-gateway`,
`mvm-lasuite-meet`) which a host imports explicitly, see `systems/x86_64-linux/lyria/default.nix`.
Interface names, VLANs and addresses of the home network live there too.

The private modules read secrets that are declared here (`modules/nixos/tools/sops`), so the public
repo owns the sops files and key management and the private repo owns the service definitions.
To work on the private repo locally, switch the input to the commented-out `git+file://` URL.

## Layout

```
flake.nix                 inputs and host list
lib/internal.nix          mkNixosSystem, mkHomeConfiguration, option helpers
.sops.yaml                age recipients and creation rules (commands in comments)

systems/<system>/<host>/  NixOS hosts: default.nix (services, switches) + hardware.nix
homes/<system>/<user>@<host>/default.nix
                          per-host Home Manager switches

modules/nixos/            NixOS modules, all under internal.*
  apps/                   1password, firefox, steam, virtualbox
  desktop/                plasma, niri
  hardware/               audio (pipewire)
  impermanence/           tmpfs root + persisted paths per host (hosts/<host>.nix)
  monitoring/             prometheus, node exporter, grafana
  nix/                    nix settings, lix, trusted users
  secrets/hosts/          host-level sops file
  security/               gpg, keyring, privileges (sudo/doas), tpm2
  services/               printing, vnc, ssh (empty placeholder)
  system/                 env, locale, time, xkb
  tools/                  git, go, llm, sops
  user/                   the primary user account
  virtualization/         qemu, docker, podman, libvirt, vswitch

modules/home/             Home Manager modules, all under internal.*
  cli-apps/               fish (+ passage-otp), helix, tmux, zellij, lazygit
  desktop/                firefox, mpv, qutebrowser, theme, iwgtk, macos defaults
  secrets/users/<user>/   user-level sops file
  tools/                  common (package suites), git, kitty, sops
  user/                   username and home directory

shells/                   dev shells, exported as devShells (kernel-build, kernel-dev, verilog-sim)
```

## Hosts

| Host           | System         | What it is                                                                  |
|----------------|----------------|-----------------------------------------------------------------------------|
| `lyria`        | x86_64-linux   | Home server. mdraid + btrfs via disko, impermanence, microvm host, restic, private smart-home/acme modules |
| `lyria-testvm` | x86_64-linux   | QEMU twin of lyria for testing the disko layout and impermanence            |
| `toussaint`    | x86_64-linux   | Framework 13 (AMD) laptop. LUKS unlocked via TPM2 + PIN, Plasma, impermanence |
| `vizima`       | aarch64-linux  | Apple Silicon Mac running NixOS via nixos-apple-silicon, LUKS, Plasma. Peripheral firmware is read from `/boot/asahi`, never committed |
| `vizima`       | aarch64-darwin | The same Mac on the macOS side, Home Manager only                           |
| `cintra`       | aarch64-darwin | Work Mac, Home Manager only                                                 |
| `pine`         | aarch64-linux  | Parallels VM                                                                |

Linux hosts use `nixosConfigurations.<host>`. macOS hosts use `homeConfigurations."<user>@<host>"`.
nix-darwin is not used.

## Day to day

Fish defines `sw` for the common case:

```bash
sw                      # Linux:  nh os switch ~/.config/nix-config
sw                      # macOS:  nh home switch ~/.config/nix-config
```

Equivalent plain commands:

```bash
sudo nixos-rebuild switch --flake ~/.config/nix-config#<host>
home-manager switch -b backup --flake ~/.config/nix-config#<user>@<host>
nix flake update        # bump all inputs
nix flake update nix-private
nix develop .#kernel-dev   # also: kernel-build, verilog-sim
```

## Bootstrapping a machine

### NixOS

1. Boot the installer, clone this repo.
2. Partition. `lyria` and `lyria-testvm` carry a disko layout in `hardware.nix`:
   `nix run github:nix-community/disko -- --mode disko systems/x86_64-linux/<host>/hardware.nix`.
   Other hosts have a hand-written `fileSystems` block; partition to match it.
3. `nixos-install --flake .#<host>`.
4. First boot: the user password comes from sops (`users_dima_hashed_password`). Until the host's
   age key is registered (next section) that secret cannot be decrypted, so use the console and
   the fallback `internal.user.initialPassword` to log in, then rotate it.
5. Register the host in `.sops.yaml` and rekey (below). Rebuild.

Hosts with `internal.impermanence.enable = true` keep `/` on tmpfs. Everything that must survive a
reboot is listed in `modules/nixos/impermanence/hosts/<host>.nix`, and the SSH host key that sops
depends on is read from `/persist/system/etc/ssh/`.

### macOS

```bash
HOSTNAME=cintra
sudo scutil --set HostName "$HOSTNAME"
sudo scutil --set LocalHostName "$HOSTNAME"
sudo scutil --set ComputerName "$HOSTNAME"

xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

git clone git@github.com:dimonzozo/nix-config ~/.config/nix-config
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt        # or: nix shell nixpkgs#age --command ...
# add the public key to .sops.yaml, rekey (see Secrets)
nix run home-manager -- switch -b backup --flake ~/.config/nix-config#dima@$HOSTNAME
```

## Adding a host

1. `systems/<system>/<host>/default.nix` and `hardware.nix`. Copy the closest existing host.
2. `homes/<system>/<user>@<host>/default.nix`.
3. Add the host to `flake.nix` under `nixosConfigurations` (or `homeConfigurations` for macOS).
4. If impermanence is on: `modules/nixos/impermanence/hosts/<host>.nix`. The module asserts that
   a file exists for the hostname.
5. Secrets: add the host and user age keys to `.sops.yaml`, run `sops updatekeys` on both sops
   files.
6. Private modules: import what the host needs from `inputs.nix-private.nixosModules.*`.

## Adding a module

Drop a `default.nix` under `modules/nixos/<group>/<name>/` or `modules/home/<group>/<name>/`.
It is imported automatically. Follow the existing shape:

```nix
{ config, lib, internal, namespace, pkgs, ... }:
with lib;
with internal;
let
  cfg = config.${namespace}.group.name;
in
{
  options.${namespace}.group.name = {
    enable = mkBoolOpt false "What this enables.";
  };

  config = mkIf cfg.enable {
    # ...
  };
}
```

Everything must be behind `enable` because every module is loaded on every host.

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix) and age. Two encrypted
files are committed:

* `modules/nixos/secrets/hosts/secrets.yaml`, decrypted by the host at boot using the age key
  derived from its SSH host key. Holds the user's hashed password, restic credentials, and
  credentials consumed by private modules.
* `modules/home/secrets/users/dima/secrets.yaml`, decrypted by the user with
  `~/.config/sops/age/keys.txt`. Holds the SSH client config, atuin sync key and private fish
  aliases, which sops-nix places into the home directory on activation.

Recipients are listed in `.sops.yaml`. The comment block at the top of that file has the exact
commands for generating keys, editing, and rekeying. The short version:

```bash
# host key (run on the host)
nix shell nixpkgs#ssh-to-age --command \
  ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub          # on impermanence hosts: /persist/system/etc/ssh/...

# user key
age-keygen -y ~/.config/sops/age/keys.txt

# edit
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt sops modules/nixos/secrets/hosts/secrets.yaml

# after changing .sops.yaml
sops updatekeys modules/nixos/secrets/hosts/secrets.yaml modules/home/secrets/users/dima/secrets.yaml
```

Never commit anything under `secrets/` that is not sops-encrypted.

## Inspirations

* [Wimpy's NixOS, nix-darwin & Home Manager Configurations](https://github.com/wimpysworld/nix-config)
* [Plus Ultra](https://github.com/jakehamilton/config) and its `snowfall-lib`, which this repo used to be built on

## Resources

* [Nix Installer](https://github.com/DeterminateSystems/nix-installer)
* [Home Manager options](https://home-manager-options.extranix.com)
* [nixos-apple-silicon](https://github.com/nix-community/nixos-apple-silicon)
* [impermanence](https://github.com/nix-community/impermanence)
* [disko](https://github.com/nix-community/disko)

## License

Apache 2.0, see `LICENSE`.
