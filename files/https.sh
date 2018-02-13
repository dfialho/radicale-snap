#!/bin/bash

. $SNAP/defs.sh

LIVE_CERTS_DIR=$CERTS_DIR/live
LIVE_CERT=$LIVE_CERTS_DIR/fullchain.pem
LIVE_KEY=$LIVE_CERTS_DIR/privkey.pem

SELF_SIGNED_DIR=$CERTS_DIR/self-signed
SELF_SIGNED_KEY=$SELF_SIGNED_DIR/privkey.pem
SELF_SIGNED_CERT=$SELF_SIGNED_DIR/fullchain.pem

CERTBOT_DIR=$CERTS_DIR/certbot
CERTBOT_LIVE_DIR=$CERTBOT_DIR/config/live

function is_https_enabled {
	[ -e $LIVE_CERTS_DIR ]
}

function deactivate_certificates {
	rm -rf $LIVE_CERTS_DIR
	snapctl restart radicale
}

function activate_certificates {
	local cert_directory=$1
	ln -s $cert_directory $LIVE_CERTS_DIR
	snapctl restart radicale
}

function uses_self_signed {
	is_https_enabled && [ $(readlink -f $LIVE_CERTS_DIR) == $SELF_SIGNED_DIR ]
}

function certbot {

	${SNAP}/bin/certbot \
		--config-dir $CERTBOT_DIR/config 	\
		--work-dir $CERTBOT_DIR/work 		\
		--logs-dir $CERTBOT_DIR/logs $@

}
