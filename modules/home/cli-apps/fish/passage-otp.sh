# passage-otp: generate a TOTP code from an otpauth:// URI stored in a passage entry
# usage: passage-otp <entry>   (or: passage-otp -c <entry> to copy to clipboard)
# NOTE: shebang and `set -euo pipefail` are provided by writeShellApplication.

clip=0
[ "${1:-}" = "-c" ] && { clip=1; shift; }

entry="${1:?usage: passage-otp [-c] <entry>}"

uri="$(passage "$entry" | grep -m1 -i '^otpauth://')" || {
	echo "passage-otp: no otpauth:// URI found in '$entry'" >&2
	exit 1
}

# pull a query parameter out of the URI (case-insensitive key)
param() { printf '%s' "$uri" | sed -nE "s|.*[?&]${1}=([^&]+).*|\1|Ip"; }

secret="$(param secret)"
[ -n "$secret" ] || { echo "passage-otp: no secret= in URI" >&2; exit 1; }

digits="$(param digits)";   digits="${digits:-6}"
period="$(param period)";   period="${period:-30}"
algo="$(param algorithm)";  algo="$(printf '%s' "${algo:-SHA1}" | tr '[:upper:]' '[:lower:]')"

code="$(oathtool -b --totp="$algo" --digits="$digits" --time-step-size="${period}s" "$secret")"

if [ "$clip" = 1 ] && command -v wl-copy >/dev/null; then
	printf '%s' "$code" | wl-copy
	echo "passage-otp: copied ${digits}-digit code to clipboard" >&2
else
	printf '%s\n' "$code"
fi
