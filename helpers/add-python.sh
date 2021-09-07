#!/usr/bin/env bash

for versionFull in "$@"; do

	semver=( ${versionFull//./ } )
	vMajor="${semver[0]}"
	vMinor="${semver[1]}"
	vPatch="${semver[2]}"

	curl -sSL "https://www.python.org/ftp/python/${versionFull}/Python-${versionFull}.tar.xz" -o /tmp/python.tar.xz
	curl -sSL "https://www.python.org/ftp/python/${versionFull}/Python-${versionFull}.tgz" -o /tmp/python.tgz

	gzHash=$( sha256sum /tmp/python.tgz | cut -d " " -f 1 )
	xzHash=$( sha256sum /tmp/python.tar.xz | cut -d " " -f 1 )

	sed -e 's/%%VERSION%%/'"$versionFull"'/g' "./helpers/template" > "./plugins/python-build/share/python-build/$versionFull"
	sed -i.bak 's/%%MINOR%%/'"${vMajor}${vMinor}"'/g' "./plugins/python-build/share/python-build/${versionFull}"
	sed -i.bak 's!%%XZHASH%%!'"${xzHash}"'!g' "./plugins/python-build/share/python-build/${versionFull}"
	sed -i.bak 's!%%GZHASH%%!'"${gzHash}"'!g' "./plugins/python-build/share/python-build/${versionFull}"

	# This .bak thing above and below is a Linux/macOS compatibility fix
	rm "./plugins/python-build/share/python-build/${versionFull}.bak"
done
