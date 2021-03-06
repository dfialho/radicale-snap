#!/bin/bash
set -e

. ${SNAP}/defs.sh


# Create git repository to store versions of the user's data
cd ${STORAGE_DIR}
if [[ ! -d .git/ ]]; then
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


function radicale {
	${SNAP}/bin/radicale --config ${CONFIG_FILE} 	\
		--storage-filesystem-folder=${STORAGE_DIR} 	\
		--auth-htpasswd-filename=${USERS_FILE} 		\
		--logging-config=${LOGGERS_FILE} 			\
		--server-hosts=0.0.0.0:$(snapctl get port) $@
}

radicale
