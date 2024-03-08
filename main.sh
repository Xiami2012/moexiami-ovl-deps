#!/usr/bin/env bash
set -e

source prepare.sh

# Check releases existence first to avoid unnecessary building
if gh release view "${P}"; then
	echo "[E] Release ${P} exists. Exiting."
	exit 1
fi

# Prepare output variables
FILES=()
source gen-go-deps.sh

relnote="\`\`\`
$(sha256sum "${FILES[@]}")
\`\`\`"
gh release create "${P}" --target "${GITHUB_SHA}" -n "${relnote}" ${FILES[@]}
