#!/bin/bash

function yes_or_no_question {
	question=$1

	while true; do
		read -p "${question} (y/n): " answer
		case ${answer} in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

function check_root {
	if [[ $(id -u) -ne 0 ]]; then
		echo "This utility requires root permissions (try using sudo)"
		exit 1
	fi
}
