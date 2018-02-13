#!/bin/bash
set -e

. $SNAP/defs.sh
. $SNAP/https.sh

# Validity period of a self-signed certificate
VALIDITY_PERIOD=2592000


while true; do

	if is_https_enabled; then
		if uses_self_signed; then

	    	# Check the self-signed certificate. Does it need to be renewed?
			cert_date=$(openssl x509 -noout -enddate -in $SELF_SIGNED_CERT | sed -e 's/.*=\(.*\)$/\1/')
			cert_date=$(date -d "$cert_date" "+%s")
			current_date=$(date "+%s")
			difference=$(($cert_date-$current_date))

		    if [[ $difference -lt $seconds_to_renew ]]; then
				echo "Renewing self-signed certificate" >&2
				generate_self_signed_certificate;
				snapctl restart radicale
				echo "Self-signed certificates were renewed" >&2
			else
				echo "Self-signed certificates aren't due for renewal" >&2
			fi
		else
			# No need to check the Let's Encrypt certificates-- they'll only
			# renew if they're within 30 days of expiration.
			certbot renew >&2
			snapctl restart radicale
		fi
	fi

  	# Run once a day
	sleep 1d

done