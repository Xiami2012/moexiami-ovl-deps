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

relnote="## Information for reproducible builds

OS:
\`\`\`
$(grep -E '^(NAME|VERSION)=' /etc/os-release)
\`\`\`

\`\`\`
$(go version)

$(tar --version | head -1)

$(xz --version)
\`\`\`

## Checksum of packaged files
\`\`\`
$(sha256sum --tag "${FILES[@]}")
\`\`\`"
gh release create "${P}" --target "${GITHUB_SHA}" -n "${relnote}" ${FILES[@]}
