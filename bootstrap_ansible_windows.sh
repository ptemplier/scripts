#!/bin/bash
#
# Chris Gilbert - 10/02/2015
# Bootstrap ansible on Windows/Babun Shell
#
echo Setting up ansible pre-requisties on windows..

pact install python-paramiko python-crypto python-setuptools openssl libsasl2 gettext
easy_install pip
pip install --upgrade pyyaml jinja2 requests

echo Installing ansible from src..

git clone https://github.com/ansible/ansible /opt/ansible
cd /opt/ansible
# Switch to latest stable version at time of writing - list versions with 'git tag' command
git checkout v1.8.2
# Checkout submodules
git submodule update --init --recursive


echo """
source /opt/ansible/hacking/env-setup
export ANSIBLE_LIBRARY=\$ANSIBLE_HOME/library
# This setting is to tweak SSH on Cygwin - will be a bit slower, but will work!
export ANSIBLE_SSH_ARGS=\"-o ControlMaster=no\"
export ANSIBLE_REMOTE_USER=root
export TERM=cygwin
""" >> ~/.bash_profile

mkdir /c
mkdir ~/.ssh
mkdir /etc/ansible
echo """
[training]
ansible-training
""" >> /etc/ansible/hosts

echo "c: /c ntfs acl,user 0 0" >> /etc/fstab
mount -a


cat <<EOF >>  ~/.bash_profile 
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "\${SSH_ENV}"
    echo succeeded
    chmod 600 "\${SSH_ENV}"
    . "\${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "\${SSH_ENV}" ]; then
    . "\${SSH_ENV}" > /dev/null
    #ps \${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep \${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
EOF

. ~/.bash_profile

