#!/bin/bash
set -e

. ${SNAP}/defs.sh
. ${SNAP}/https.sh
. ${SNAP}/utils.sh

COMMAND="radicale.enable-https"

function usage {
	echo "Usage:"
	echo "  $COMMAND -h"
	echo "  Display this help message."
	echo
	echo "  $COMMAND <subcommand> [OPTIONS]"
	echo "  Run the provided subcommand."
	echo
	echo "Available subcommands:"
	echo "  lets-encrypt"
	echo "  Obtain a certificate from Let's Encrypt and automatically keep it"
	echo "  up-to-date."
	echo
	echo "  self-signed"
	echo "  Generate and use a self-signed certificate. This is easier to"
	echo "  setup than Let's Encrypt certificates, but will cause warnings in"
	echo "  browsers."
	echo
}

function lets_encrypt_usage {
	echo "Usage:"
	echo "  $COMMAND lets-encrypt [-h] [-t]"
	echo
	echo "  Obtain a certificate from Let's Encrypt and"
	echo "  automatically keep it up to date."
	echo
	echo "  -h: Display this help message"
	echo "  -t: Obtain a test certificate. This is a valid Let's"
	echo "      Encrypt certificate, but is not signed by a"
	echo "      recognized CA, so browsers will show a warning."
	echo
}

function check_https_already_enabled {

	if is_https_enabled; then

	  echo "HTTPs is already enabled"

		while true; do
			read -p "Do you want to obtain new certificates? (y/n) " answer
			case $answer in
				[Yy]* ) break;;
				[Nn]* ) exit;;
				* ) echo "Please answer (y)es or (n)o.";;
			esac
		done

	fi

}

function handle_lets_encrypt {

	test_cert=""

	while getopts ":th" opt; do
		case $opt in
			t) test_cert="--test-cert";; # obtain test cert
			h)
				lets_encrypt_usage
				exit 0
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
				exit 1
				;;
		esac
	done

	check_https_already_enabled;

	echo "In order for Let's Encrypt to verify that you actually own the"
	echo "domain(s) for which you're requesting a certificate, there are a"
	echo "number of requirements of which you need to be aware:"
	echo ""

	echo "1. In order to register with the Let's Encrypt ACME server, you must"
	echo "   agree to the currently-in-effect Subscriber Agreement located"
	echo "   here:"
	echo ""
	echo "     https://letsencrypt.org/repository/"
	echo ""
	echo "   By continuing to use this tool you agree to these terms. Please"
	echo "   cancel now if otherwise."
	echo ""

	echo "2. You must have the domain name(s) for which you want certificates"
	echo "   pointing at the external IP address of this machine."
	echo ""

	echo "3. Both ports 80 and 443 on the external IP address of this machine"
	echo "   must point to this machine (e.g. port forwarding might need to be"
	echo "   setup on your router)."
	echo ""

	yes_or_no_question "Do you meet these requirements?" || exit

	read -p "Please enter an email address (for urgent notices or key recovery): " email
	read -p "Please enter your domain name: " domain

	# The directory containing the certificates obtained with certbot
	certdir=$CERTBOT_LIVE_DIR/$domain

	# Remove the previous certificates and certbot configurations
	if [ -e $certdir ]; then
		echo "Cleaning up previous certificates..."
		rm -rf $CERTBOT_DIR
	fi

	echo -n "Attempting to obtain certificates... "

	mkdir -p $CERTBOT_DIR
	mkdir -p $CERTBOT_DIR/config
	mkdir -p $CERTBOT_DIR/work
	mkdir -p $CERTBOT_DIR/logs

	certbot certonly $test_cert \
		--standalone 			\
		--rsa-key-size 4096 	\
		--email $email 			\
		--non-interactive 		\
		--agree-tos 			\
		-d $domain

	# Give access only to root
	chmod -R 700 $CERTBOT_DIR

	echo "done"
	echo
	
	# Activate the new certificates
	activate_certificates $certdir;

}

function handle_self_signed {

	check_https_already_enabled;

	echo -n "Generating key and self-signed certificate... "

	mkdir -p $SELF_SIGNED_DIR

	output=$(openssl req -newkey rsa:4096 -nodes -keyout $SELF_SIGNED_KEY \
			 -x509 -days 90 -out $SELF_SIGNED_CERT)

	if [ $? -ne 0 ]; then
		echo "error:" >&2
		echo "$output" >&2
		exit 1
	fi

	# Give access only to root
	chmod -R 700 $SELF_SIGNED_DIR

	echo "done"
	echo
	
	# Activate the new certificates
	activate_certificates $SELF_SIGNED_DIR;
}

####################################
# ------------- MAIN ------------- #
####################################

check_root;

# Parse options for the base command
while getopts ":h" opt; do
	case $opt in
		h)
			usage
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done

# Move to subcommand
shift $((OPTIND-1))

if [ $# = 0 ]; then
	echo "Missing subcommand. Run '$COMMAND -h' for help." >&2
	exit 1
fi

subcommand=$1

# Remove subcommand from args
shift

case $subcommand in
	lets-encrypt|self-signed)
		handle_${subcommand//-/_} "$@"
		;;
	*)
		echo "No such subcommand: $subcommand. Run '$COMMAND -h' for help." >&2
		exit 1
		;;
esac