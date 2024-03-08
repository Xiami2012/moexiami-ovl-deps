#!/usr/bin/env bash

load_config() {
	source config

	if [[ -z "${PN}" ]] || [[ -z "${PV}" ]]; then
		echo "[E] Empty PN or PV. PN=${PN} PV=${PV}" >&2
		return 1
	fi
	: "${P:=${PN}-${PV}}"
	: "${S:=${P}}"

	if [[ -z "${SOURCE_DATE_EPOCH}" ]]; then
		SOURCE_DATE_EPOCH=$(stat -c %Y config)
		echo "[W] SOURCE_DATE_EPOCH is not set." \
			"Default to ${SOURCE_DATE_EPOCH} ." >&2
	fi
}

handle_src_uri() {
	if [[ -z "${SRC_URI}" ]]; then
		return
	fi

	if [[ -z "${SRC_SHA256SUM}" ]]; then
		echo "[E] SRC_URI provided but no SRC_SHA256SUM defined." >&2
		return 1
	fi
	local nol1 nol2
	nol1=$(wc -l <<< "${SRC_URI}")
	nol2=$(wc -l <<< "${SRC_SHA256SUM}")
	if [[ "${nol1}" -ne "${nol2}" ]]; then
		echo "[E] Lines of SRC_URI(${nol1}) and SRC_SHA256SUM(${nol2}) mismatch." >&2
		return 1
	fi

	if ! declare -F config_src_unpack >/dev/null; then
		echo "[E] SRC_URI provided but no config_src_unpack defined." >&2
		return 1
	fi

	local srcl uri fname
	while read -r srcl; do
		# Ignore empty line
		if [[ -z "${srcl}" ]]; then
			continue
		fi

		if [[ "${srcl}" =~ ([^ ]*)\ *-\>\ *([^ ]*) ]]; then
			# URI -> FNAME
			uri=${BASH_REMATCH[1]}
			fname=${BASH_REMATCH[2]}
		else
			# URI
			uri=${srcl}
			fname=$(basename "${srcl}")
		fi

		if [ -f "${fname}" ]; then
			echo "[I] ${fname} exists. Skip downloading." >&2
		else
			echo "[I] Downloading ${uri} to ${fname} ..." >&2
			curl -L -o "${fname}" "${uri}"
		fi
	done <<< "${SRC_URI}"

	sha256sum -c <<< "${SRC_SHA256SUM}"
	config_src_unpack
}

load_config
handle_src_uri
