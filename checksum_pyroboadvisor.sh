#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "$0")" && pwd)
dockerfile="$script_dir/Dockerfile"

url=$(sed -n 's/^ENV PYROBOADVISOR_URL="\([^"]*\)"$/\1/p' "$dockerfile")
url_count=$(grep -c '^ENV PYROBOADVISOR_URL=' "$dockerfile" || true)
hash_count=$(grep -c '^ENV PYROBOADVISOR_SHA256=' "$dockerfile" || true)

if [[ "$url_count" -ne 1 || "$hash_count" -ne 1 || -z "$url" ]]; then
	printf 'Expected exactly one PYROBOADVISOR_URL and PYROBOADVISOR_SHA256 in %s\n' "$dockerfile" >&2
	exit 1
fi

archive=$(mktemp)
trap 'rm -f "$archive"' EXIT
curl -fsSL "$url" -o "$archive"
checksum=$(sha256sum "$archive" | awk '{print $1}')

sed -i "s|^ENV PYROBOADVISOR_SHA256=.*|ENV PYROBOADVISOR_SHA256=\"$checksum\"|" "$dockerfile"
printf 'Updated PYROBOADVISOR_SHA256: %s\n' "$checksum"