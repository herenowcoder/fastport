#!/bin/sh

Index='/usr/ports/INDEX-8'
RevIndex='/var/tmp/ports_revindex'

[ $RevIndex -nt $Index ] || revindex <$Index | sort > $RevIndex

strip_version() {
    echo $1 | sed -E 's/(.+)-.+/\1/'
}

get_version() {
    echo $1 | sed -E 's/.+-(.+)/\1/'
}

pkg_src() {
    local pkg=$1
    head -n5 "/var/db/pkg/$pkg/+CONTENTS" | grep 'ORIGIN:' | cut -d':' -f2
    # the same:
    # pkg_info -o $pkg | g -A1 Origin: | tail +2
}

lookup_revindex() {
    grep "$1|" $RevIndex
}

check_pkg() {
    idx_ver=$(get_version $(lookup_revindex $(pkg_src $1) | cut -d'|' -f2))
    if [ "$(get_version $1)" != "$idx_ver" ]; then
	echo "installed: $1, index has: $idx_ver"
    fi
}

check_all_pkgs() {
    for i in $(ls /var/db/pkg); do
	check_pkg $i
    done
}

[ "$1" = "-a" ] && check_all_pkgs
