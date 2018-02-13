#!/bin/bash

##
# Script to manage users using the htpasswd tool
# Users are registered in the ${SNAP_USER_COMMON}/users file
#
# This script is associated with the 'users' command
##

# This script requires USERS_FILE, and STORAGE_DIR
. $SNAP/defs.sh


function usage {
  echo "Usage: users COMMAND <username>"
  echo "Commands:"
  echo "    create:  Creates a new user"
  echo "    passwd:  Changes the password of an existing user"
  echo "    delete:  Deletes a user"
  echo "    list:    Lists all registered users"
  echo
  exit 1
}

# Function to list all existing users 
function users {
  cut -d: -f1 $USERS_FILE
}

# Function to test if a user exists
function user_exists {
  existing_user=$1

  for user in $(users);
  do
    if [ "$user" = "$existing_user" ]; then
      return 0
    fi
  done

  return 1

}

function authenticate_user {
  htpasswd -B -v $USERS_FILE $1
}

# Command to create a new user
function create {
  user_to_create=$1

  if user_exists $user_to_create; then
    echo "User '$user_to_create' already exists"
    exit 1
  fi

  echo "Lets create a new user with name '$user_to_create'"
  echo "Please provide a password for the new user"

  if htpasswd -B $USERS_FILE $user_to_create; then
    echo "Successfully created new user '$user_to_create'"
  else
    echo "Failed to create user '$user_to_create'"
  fi

}

# Command to change the password of an existing user
function passwd {
  user_to_update=$1

  if ! user_exists $user_to_update; then
    echo "User '$user_to_update' does not exist"
    exit 1
  fi

  echo "Lets change the password of user '$user_to_update'"
  echo "Please provide the current password for user '$user_to_update'"

  if authenticate_user $user_to_update; then

    if htpasswd -B $USERS_FILE $user_to_update; then
      echo "Successfully updated password of user '$user_to_update'"
    else
      echo "Failed to update password for user '$user_to_update'"
    fi

  fi
}

# Command to delete a user
function delete {
  user_to_delete=$1

  if ! user_exists $user_to_delete; then
    echo "User '$user_to_delete' does not exist"
    exit 1
  fi

  echo "Lets delete user '$user_to_delete'"
  echo "Please provide the password for user '$user_to_delete'"

  if authenticate_user $user_to_delete; then

    if htpasswd -D $USERS_FILE $user_to_delete; then

      # remove user data
      if [ -d $STORAGE_DIR/collection-root/$user_to_delete ]; then
        echo "Deleting user data"
        rm -rf $STORAGE_DIR/collection-root/$user_to_delete
      fi

      echo "Successfully deleted user '$user_to_delete'"
    else
      echo "Failed to delete user '$user_to_delete'"
    fi

  fi

}

# Command to list existing users
function list {

  local all_users=$(users)

  if [ -z $all_users ]; then
    echo
    echo "There are no users registered yet"
    echo "Use the following command to create a new user: "
    echo "    radicale.users create <username>"
    echo
    exit 0
  fi

  echo "USERS"
  for user in $all_users;
  do
    echo "- $user"
  done

}

function main {

  case "$1" in
    create|passwd|delete)

          if [ $(id -u) -ne 0 ]; then
            echo "The '$1' command requires root permissions (try using sudo)"
            exit 1
          fi

          if [ "$#" -ne "2" ]; then
            usage;
          else
            ${1} ${2}
          fi

          ;;

    list)
          ${1} ;;

    -h|--help)
          usage ;;

    -*)   echo "Argument error. Use the -h option." ;;
    *)    echo "Command error. Use the -h option." ;;
  esac

}

main "$@";