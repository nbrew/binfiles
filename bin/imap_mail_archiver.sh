#!/bin/bash

# This script makes use of the archivemail script, which in turn requires python 2.3 (at least)
# See: http://archivemail.sourceforge.net/
# See: http://archivemail.sourceforge.net/manpage.html
#
# The list of IMAP directories can be had, with a little processing, by running
# the folling in a new Terminal session:
#
# > telnet mail.example.com 143
#  Trying 123.456.789.12...
#  Connected to mail.example.com (123.456.789.12).
#  Escape character is '^]'.
#  * OK IMAP4 ready
#
#  . LOGIN accountname@mail.example.com passwordhere
#  . OK LOGIN completed
#  . list "" "*"
#  . LOGOUT
# For more information, including connecting via openssl, see: http://bobpeers.com/technical/telnet_imap

username='username'
password=''
hostname='mail.example.com'
output_dir='/Users/username/archive/mail/${username}_at_${hostname}'
archive_before_date='2011-01-01'

imap_directories=('INBOX')
if ('username' -eq "${username}") {
  imap_directories=( "INBOX" "Sent Items" )
}

function archive_folder() {
  folder_name=$1
  # escaped=`echo "$1" | sed 's/[[:space:]]/\\\ /g'`

  archive_dir=`dirname "${output_dir}/${folder_name}"`

  # Remove the -n flag to perform a real backup
  # We don't compress to allow an indexable copy for local use on a user's machine
  # Preserve unread maintains the read state of messages. Otherwise they'd be marked as read.
  # Flagged messages are not archived by default (without --include-flagged).
  archivemail -n -D ${archive_before_date} --include-flagged --no-compress --preserve-unread \
    --output-dir="${archive_dir}" \
    "imap://${username}:${password}@${hostname}/${folder_name}"
}

if [ -d '${output_dir}' ]; then
  cd '${output_dir}';
fi

tLen=${#imap_directories[@]}
for (( i=0; i<${tLen}; i++ )); do
  f=${imap_directories[$i]}
  if [[ "${f}" =~ "/" ]]; then
    # echo "Subfolder found ${f}"
    if [ ! -d "${output_dir}/${f}" ]; then
      echo "Creating folder: ${output_dir}/${f}"
      mkdir -p "${output_dir}/${f}"
    fi
  fi

  archive_folder "${f}"
done
exit 0

# 16apr12 - initial version