#!/usr/bin/env bash
set -e

if [[ -z "${GEN_GO_DEPS}" ]]; then
	exit 0
fi

export GOMODCACHE="${PWD}"/go-mod
pushd "${S}" >/dev/null
echo "[I] Running go mod download..." >&2
go mod download -modcacherw -x
popd >/dev/null

export XZ_OPTS="-T0 -9"
# Make a reproducible tarball.
# Assume go will make file permissions stable so there are no --mode=go+u,go-w .
#
# References:
#  https://reproducible-builds.org/docs/archives/
#  https://www.gnu.org/software/tar/manual/html_section/Reproducibility.html
# For details on --pax-option, see:
#  https://www.gnu.org/software/tar/manual/html_section/Portability.html
# For details on --format, see:
#  https://www.gnu.org/software/tar/manual/html_section/Formats.html
unset POSIXLY_CORRECT
echo "[I] Archiving go-mod..." >&2
tar --sort=name --clamp-mtime --mtime="@${SOURCE_DATE_EPOCH}" \
	--numeric-owner --owner=0 --group=0 \
	--format=posix --pax-option=delete=atime,delete=ctime \
	-acf "${P}"-deps.tar.xz go-mod
# Output
FILES+=("${P}"-deps.tar.xz)
