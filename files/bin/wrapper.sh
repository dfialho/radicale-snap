#!/bin/bash

CONFIG_FILE=$SNAP/config.ini
STORAGE_DIR=$SNAP_COMMON/storage
USERS_FILE=$SNAP_DATA/auth

radicale --config $CONFIG_FILE \
	--storage-filesystem-folder=$STORAGE_DIR \
	--auth-htpasswd-filename=$USERS_FILE \
