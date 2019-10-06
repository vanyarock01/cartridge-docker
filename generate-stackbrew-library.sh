#!/usr/bin/env bash
set -eu

declare -A aliases=(
    [2]='latest'
    [1]=''
)

self="$(basename "$BASH_SOURCE")"
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

versions=( */ )
versions=( "${versions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

# get the most recent commit which modified any of "$@"
fileCommit() {
    git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
    local dir="$1"; shift
    (
        cd "$dir"
        fileCommit \
            Dockerfile \
            $(git show HEAD:./Dockerfile | awk '
                toupper($1) == "COPY" {
                    for (i = 2; i < NF; i++) {
                        print $i
                    }
                }
            ')
    )
}

cat <<-EOH
# this file is generated via https://github.com/tarantool/cartridge-docker/blob/$(fileCommit "$self")/$self

Maintainers: Konstantin Nazarov <mail@knazarov.com> (@knazarov)
GitRepo: https://github.com/tarantool/cartridge-docker.git
EOH

# prints "$2$1$3$1...$N"
join() {
    local sep="$1"; shift
    local out; printf -v out "${sep//%/%%}%s" "$@"
    echo "${out#$sep}"
}

for version in "${versions[@]}"; do
    commit="$(dirCommit "$version")"

    # Strip suffix qualifiers from versions like "6.4.3-alpha1"
    plainVersion="${version%-*}"

    fullVersion="$(git show "$commit":"$version/Dockerfile" | awk '$1 == "ENV" && $2 == "TARANTOOL_VERSION" { print $3; exit }')"

    versionAliases=()
    while [ "$fullVersion" != "$version" -a "${fullVersion%[.-]*}" != "$fullVersion" ]; do
        versionAliases+=( $fullVersion )
        fullVersion="${fullVersion%[.-]*}"
    done
    versionAliases+=(
        $version
        ${aliases[$version]:-}
    )


    echo
    cat <<-EOE
Tags: $(join ', ' "${versionAliases[@]}")
Architectures: amd64
GitCommit: $commit
Directory: $version
EOE

    for variant in alpine; do
        [ -f "$version/$variant/Dockerfile" ] || continue

        commit="$(dirCommit "$version/$variant")"

        variantAliases=( "${versionAliases[@]/%/-$variant}" )
        variantAliases=( "${variantAliases[@]//latest-/}" )

        echo
        cat <<-EOE
Tags: $(join ', ' "${variantAliases[@]}")
Architectures: amd64
GitCommit: $commit
Directory: $version/$variant
EOE
    done
done
