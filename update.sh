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

for version in "${versions[@]}"; do
    rcVersion="${version%-rc}"

    fullVersion="$(
        grep "^$rcVersion." <<<"$tags" | tail -1)"

    if [ -z "$fullVersion" ]; then
        echo >&2 "warning: cannot find full version for $version"
        continue
    fi
    fullVersion="${fullVersion#v}"

    echo "$version: $fullVersion"
done
