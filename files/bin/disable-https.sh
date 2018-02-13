#!/bin/bash
set -e

. ${SNAP}/defs.sh
. ${SNAP}/https.sh
. ${SNAP}/utils.sh


check_root;


if is_https_enabled; then
	echo "Disabling HTTPS..."
	deactivate_certificates;
	echo "HTTPs is now disabled"
else
	echo "HTTPs is already disabled"
fi