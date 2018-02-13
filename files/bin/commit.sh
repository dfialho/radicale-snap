#!/bin/bash
set -e

. ${SNAP}/defs.sh

cd $STORAGE_DIR

# Create git repository to store versions of the user's data
if [ ! -d .git/ ]; then
	# This is a bogus email and name
	git config --global user.email "radicale@mail.com"
	git config --global user.name "radicale"

	git init

	# include a gitignore with the radicale tmp files
	echo ".Radicale.cache" > .gitignore
	echo ".Radicale.lock" >> .gitignore
	echo ".Radicale.tmp.*" >> .gitignore
	echo ".Radicale.props" >> .gitignore

	git add .gitignore
	git commit -m "Initial commit"
fi

git add -A
git diff --cached --quiet || git commit -m "Changes by $1 at $(date)"

echo "Committed changes of user $1" >&2
