#!/bin/sh

CONFIG_FILE=$SNAP/config.ini
STORAGE_FOLDER=$SNAP_COMMON/storage
USERS_FILE=$SNAP_DATA/auth

radicale --config $CONFIG_FILE \
	--storage-filesystem-folder=$STORAGE_FOLDER \
	--auth-htpasswd-filename=$USERS_FILE \
