#!/bin/bash
set -e

. $SNAP/defs.sh


radicale --config $CONFIG_FILE 					\
	--storage-filesystem-folder=$STORAGE_DIR 	\
	--auth-htpasswd-filename=$USERS_FILE 		\
	--server-pid=$PID_FILE		 				\
	--logging-config=$LOGGERS_FILE 				\
	 --server-hosts=0.0.0.0:$(snapctl get port)	\
