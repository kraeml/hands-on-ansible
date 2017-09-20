#/bin/bash

for i in ais-bashy web1 web2 db playbooks; do
	lxc-create -n ${i} -t ubuntu
	lxc-update-config -c /var/lib/lxc/${i}/config
	lxc-start -n ${i}
	sleep 10
done
lxc-ls --fancy
