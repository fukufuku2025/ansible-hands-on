#!/bin/sh

export LANG=C
export PATH=/usr/bin:/usr/sbin

if [ `id -u` -ne 0 ]; then
  echo "$0 : you should execute this script as root."
  exit 1
fi

if
  grep ansible /etc/group > /dev/null 2>&1
then
  :
else
  groupadd -g 924 ansible
  echo "groupadd ansible"
fi

if
  grep ansible /etc/passwd > /dev/null 2>&1
then
  :
else
  PASSWD='$5$8pAYN57sJrmUc$pVXJQGg5JBCvBxcTM9Xqb09WIwSdJDoHhVM/HVMlJJ3'
  adduser -c "Ansible" -g ansible -u 924 -p $PASSWD -s /bin/bash ansible
  echo "useradd ansible"
fi

#if [ -n "${HTTP_PROXY}" ]; then
#  echo 'proxy=${HTTP_PROXY}' >> /etc/dnf/dnf.conf
#fi

if [ -d /etc/sudoers.d -a ! -f /etc/sudoers.d/ansible ]; then
  cat << EOF > /etc/sudoers.d/ansible
ansible ALL = (ALL)     NOPASSWD: ALL
Defaults:ansible !requiretty
EOF
  chown root:root /etc/sudoers.d/ansible
  chmod 0440 /etc/sudoers.d/ansible
  echo "created /etc/sudoers.d/ansible"
fi
