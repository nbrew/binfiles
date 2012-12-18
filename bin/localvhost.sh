#!/bin/bash

# Local vhost configuration for Mac OS X machines

VHOST_DIR=/Users/nathan/workspace

function enable_vhosts() {
  sudo sed -i -e "s;#\(Include /private/etc/apache2/extra/httpd-vhosts.conf\)$;\1;" /private/etc/apache2/httpd.conf
}

function create_project_log_dir() {
  if [ ! -d "${PROJECT_DIR}/log" ]; then
    echo 'Creating log directory and logs.'
    mkdir -p ${VHOST_DIR}/${project}/log
  fi
  touch ${PROJECT_DIR}/log/error_log ${PROJECT_DIR}/log/access_log
}

function make_vhost_conf() {
  echo ""
  echo "Adding the vhost to /private/etc/apache2/extra/httpd-vhosts.conf :"

  echo "<VirtualHost *:80>
  DocumentRoot '${PROJECT_DIR}'
  ServerName ${hostname}
  ErrorLog '${PROJECT_DIR}/log/error_log'
  CustomLog '${PROJECT_DIR}/log/access_log' common
  <Directory ${PROJECT_DIR}>
    Order allow,deny
    Allow from all
  </Directory>
</VirtualHost>" | sudo tee /private/etc/apache2/extra/httpd-vhosts.conf
}

function add_hostname_to_hosts_file() {
  sudo bash -c "echo '127.0.0.1 ${hostname}' >> /etc/hosts"
}

# function restart_apache() {
#   sudo apachectl configtest && sudo apachectl restart
# }

if [ -z "${1}" ]; then
  echo "Enter the project directory name:"
  read project
else
  project="${1}"
fi

PROJECT_DIR=${VHOST_DIR}/${project}

if [ ! -d "${PROJECT_DIR}" ]; then
  echo 'The specified project directory does not exist.'
  echo "Please verify the path: ${PROJECT_DIR}"
  exit 1;
fi

echo "Enter the local hostname: (suggested: ${project}.local)"
read hostname
if [ -z "${hostname}" ]; then
  hostname="${project}.local"
fi

echo "Setting local hostname to: ${hostname}"

enable_vhosts
create_project_log_dir
add_hostname_to_hosts_file
make_vhost_conf
# restart_apache

exit;