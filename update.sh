#!/usr/bin/env bash
set -Eeuo pipefail

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
    versions=( */ )
fi
versions=( "${versions[@]%/}" )


tags="$(
    git ls-remote --tags https://github.com/tarantool/tarantool.git \
        | cut -d/ -f3 \
        | cut -d^ -f1 \
        | sort -uV
)"

cartridgeCliVersion="$(
    git ls-remote --tags https://github.com/tarantool/cartridge-cli.git \
        | cut -d/ -f3 \
        | cut -d^ -f1 \
        | grep ".*\..*\..*" \
        | sort -uV \
        | tail -1
)"

cartridgeVersion="$(
    git ls-remote --tags https://github.com/tarantool/cartridge.git \
        | cut -d/ -f3 \
        | cut -d^ -f1 \
        | grep ".*\..*\..*" \
        | sort -uV \
        | tail -1
)"

echo "Cartridge CLI version: $cartridgeCliVersion"
echo "Cartridge version: $cartridgeVersion"

for version in "${versions[@]}"; do
    rcVersion="${version%-rc}"

    fullVersion="$(
        grep "^$rcVersion\." <<<"$tags" | tail -1)"

    if [ -z "$fullVersion" ]; then
        echo >&2 "warning: cannot find full version for $version"
        continue
    fi
    fullVersion="${fullVersion#v}"

    cp "$version/Dockerfile" "$version/Dockerfile.template"

    echo "Latest Tarantool version $version: $fullVersion"

    sed -e 's/^\(ENV TARANTOOL_VERSION\) .*/\1 '"$fullVersion"'/' \
        -e 's/^\(ENV CARTRIDGE_VERSION\) .*/\1 '"$cartridgeVersion"'/' \
        -e 's/^\(ENV CARTRIDGE_CLI_VERSION\) .*/\1 '"$cartridgeCliVersion"'/' \
           "$version/Dockerfile.template" > "$version/Dockerfile"

    rm -f "$version/Dockerfile.template"

done
