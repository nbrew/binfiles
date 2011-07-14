#!/bin/bash
set -v

#
# From my gist: https://gist.github.com/1068590/3a77f77e3567e9feeb00c4c67eed9e0a3600bdf2
#

function usage() {
  echo ""
  echo "usage: ./$0 deployment_username [deployment_group]"
  echo ""
  echo "Creates a new user, and optionally a new group then generates keys for that user."
  echo ""
  echo "Examples:"
  echo " ./$0 marshmallow deployers"
  exit 1
}

# Parameters:
# username: (string) username to attempt to add
# groupname: (string) group name to append
function create_user() {
  local deploy_user=$1
  local optional_group=$2

  if [ -z $deploy_user ]; then
    usage
    exit 1
  fi

  `getent passwd $deploy_user 2>&1`
  if [ $? -eq 2 ]; then
if [ -z $optional_group ]; then
sudo /usr/sbin/useradd ${deploy_user}
    else
sudo /usr/sbin/useradd -G ${optional_group} ${deploy_user}
    fi
else
echo "WARNING: Deploy user already exists."
  fi
}

function create_group() {
  local group_name=$1
  if [ -z $group_name ]; then
echo ""
    echo "usage: create_group groupname"
    exit 1
  fi
  `getent group $group_name 2>&1` # returns 2 when a group is not found
  if [ $? -eq 2 ]; then
sudo /usr/sbin/groupadd ${group_name}
  fi
}

function generate_ssh_keys() {
  local deploy_user=$1
  local pubkey
  if [ -z $deploy_user ]; then
echo ""
    echo "usage: generate_ssh_keys username"
    echo ""
    exit 1
  fi

sudo mkdir -p "/home/${deploy_user}/.ssh"
  sudo chmod 700 "/home/${deploy_user}/.ssh"
  if [ -f "/home/${deploy_user}/.ssh/id_rsa" ]; then
echo 'SSH key already exists';
  else
    # passwordless key for automated deployments
    sudo ssh-keygen -q -f "/home/${deploy_user}/.ssh/id_rsa" -N ''
  fi
  # update the user and group for the .ssh dir
  sudo touch "/home/${deploy_user}/.ssh/authorized_keys"
  sudo chown -R ${deploy_user}:${deploy_user} "/home/${deploy_user}/.ssh"
  sudo chmod 600 "/home/${deploy_user}/.ssh/authorized_keys"
  pubkey=`sudo cat /home/${deploy_user}/.ssh/id_rsa.pub`
  echo "Below is the SSH public key for your server."
  echo "Please add this key to your gitosis keydir or account on GitHub."
  echo ""
  echo ${pubkey}
  echo ""
}

function config_deploy_user() {
  local group_name=$2
  if [ $# -lt 1 ]; then
    usage
    exit 1
  fi
  if [ $# -eq 2 ]; then
    create_group ${group_name}
  fi

  create_user $1
  if [ $? -eq 0 ]; then
    generate_ssh_keys $1 ${group_name}
  else
    echo "Unable to add user. Perhaps it already exists?"
  fi
}

config_deploy_user $1 $2
exit 0
