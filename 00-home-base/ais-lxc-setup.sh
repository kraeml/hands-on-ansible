#!/bin/bash

set -uxe

# Path for prepare playbook
PREPARE=~/rdf/ais/hands-on-ansible/02-playbooks/00-simple-playbook-examples/prepare_ansible_target.yml
# Create ssh-key with empty passphrase (ONLY FOR TESTING)
MAKE_SSH_KEY="ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N \"\""

# Create containers
# The login user is ubuntu with password ubuntu
for i in ais-bashy web1 web2 db playbooks; do
	sudo lxc-create -n ${i} -t ubuntu && \
	# Remove legacy configuration keys \
	sudo lxc-update-config -c /var/lib/lxc/${i}/config && \
	# Start container \ 
	sudo lxc-start -n ${i} && \
	# Prepare ais-bashy \
	if [[ ${i} == "ais-bashy" ]]; then
		echo "Wait for comming up"
		sleep 5
		# Get ip
		ip=$(sudo lxc-ls --fancy | grep ${i} | cut -d '-' -f 3 | tr -d ' ')
		# Remove host key for ip
		ssh-keygen -R ${ip}
		# Add ip into known_hosts
		ssh-keyscan -H ${ip} >> ~/.ssh/known_hosts
		# Setup ssh-key for user
		ls ~/.ssh/id_rsa || ansible -i localhost, -m shell -a "${MAKE_SSH_KEY}" --connection=local localhost
		# Run prepare playbook
		ansible-playbook -i ${ip}, -u ubuntu --ask-pass --ask-become-pass ${PREPARE}
	fi
done
sleep 5
sudo lxc-ls --fancy
