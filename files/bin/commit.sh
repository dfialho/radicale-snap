#!/bin/bash
set -e

. ${SNAP}/defs.sh

cd ${STORAGE_DIR}
git add -A
git diff --cached --quiet || git commit -m "Changes by $1 at $(date)"

echo "Committed changes of user $1" >&2
