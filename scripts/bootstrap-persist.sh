#!/usr/bin/env bash
# Bootstrap /persist for a new impermanence host. DRAFT.
#
# Run as root on the freshly installed host (sops and impermanence still
# disabled), from the nix-config checkout:
#
#   sudo ./scripts/bootstrap-persist.sh [extra nix flags, e.g. --impure]
#
# It derives the persist layout from the host's own
# environment.persistence."/persist/system" declaration, so the impermanence
# host file in modules/nixos/impermanence/hosts/<host>.nix is the single
# source of truth. Steps:
#
#   1. generate SSH host keys directly in /persist/system/etc/ssh
#   2. copy every declared file that already exists on the live system
#      (machine-id etc.), so impermanence never binds an empty file over it
#   3. rsync every declared directory's current content into /persist
#   4. print the host age recipient for .sops.yaml
#
# Afterwards: add the key on a trusted host, `sops updatekeys` both secrets
# files, commit; then enable tools.sops + impermanence for the host,
# `nixos-rebuild boot`, reboot.

set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="$(hostname)"
PERSIST="/persist/system"

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }

echo "==> Reading persistence declaration for ${HOST}"
eval_list() {
  nix eval "${FLAKE_DIR}#nixosConfigurations.${HOST}.config.environment.persistence.\"${PERSIST}\".$1" \
    --apply "$2" --json "${@:3}"
}
# Entries may be plain strings or attrsets ({ directory = ...; } / { file = ...; }).
DIRS=$(eval_list directories 'ds: map (d: if builtins.isString d then d else d.directory) ds' "$@" | tr -d '[]"' | tr ',' ' ')
FILES=$(eval_list files 'fs: map (f: if builtins.isString f then f else f.file) fs' "$@" | tr -d '[]"' | tr ',' ' ')

echo "    directories: ${DIRS}"
echo "    files: ${FILES}"

echo "==> Creating directory skeleton and copying current state"
for d in ${DIRS}; do
  mkdir -p "${PERSIST}${d}"
  if [ -d "${d}" ] && ! mountpoint -q "${d}"; then
    rsync -aHAX "${d}/" "${PERSIST}${d}/"
    echo "    synced ${d}"
  fi
done

for f in ${FILES}; do
  mkdir -p "${PERSIST}$(dirname "${f}")"
  if [ -e "${f}" ] && [ ! -e "${PERSIST}${f}" ] && [ ! -L "${f}" ]; then
    cp -a "${f}" "${PERSIST}${f}"
    echo "    copied ${f}"
  fi
done

echo "==> SSH host keys"
mkdir -p "${PERSIST}/etc/ssh"
[ -f "${PERSIST}/etc/ssh/ssh_host_ed25519_key" ] \
  || ssh-keygen -t ed25519 -N "" -C "root@${HOST}" -f "${PERSIST}/etc/ssh/ssh_host_ed25519_key"
[ -f "${PERSIST}/etc/ssh/ssh_host_rsa_key" ] \
  || ssh-keygen -t rsa -b 4096 -N "" -C "root@${HOST}" -f "${PERSIST}/etc/ssh/ssh_host_rsa_key"

echo "==> Host age recipient (add as host_${HOST} to .sops.yaml, then rekey):"
nix run nixpkgs#ssh-to-age -- -i "${PERSIST}/etc/ssh/ssh_host_ed25519_key.pub"

cat <<EOF

Next steps:
  1. On a trusted host: add the key above to .sops.yaml, run
     sops updatekeys on both secrets files, commit and push.
  2. Enable tools.sops and impermanence for ${HOST}, rebuild with
     'nixos-rebuild boot', then reboot into tmpfs root.
EOF
