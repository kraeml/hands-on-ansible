#!/usr/bin/env python
import argparse
import json
import subprocess
import re

ANSIBLE_INV = {
    "lxc_container": {
        "hosts": [],
        "vars": {
            "ansible_user": "ubuntu"
        }
    },
    'local': {
        'hosts': ['localhost'],
        'vars': {'ansible_connection': 'local'}
    }
}

HOST_VARS = {
} 

def output_list_inventory(json_output):
    print(json.dumps(json_output) )

def find_host(search_host, inventory):
    host_attribs = inventory.get(search_host, {})
    print(json.dumps(host_attribs))
    
def all_lxc_ips():
    lines = subprocess.check_output(['sudo', 'lxc-ls', '--fancy']).split('\n')
    for line in lines:
        if 'RUNNING' not in line:
            continue
        lxc_name = line.split(' ')[0]
        ip = re.findall( r'[0-9]+(?:\.[0-9]+){3}', line )
        ANSIBLE_INV["lxc_container"]["hosts"].append(ip)
        ANSIBLE_INV.setdefault(lxc_name, "0.0.0.0")
        ANSIBLE_INV[lxc_name]=ip
        print(ip)

def main():

    # Argument parsing
    parser = argparse.ArgumentParser(description="Ansible dynamic inventory")
    parser.add_argument("--list", 
                        help="Ansible inventory of all of the groups",
                        action="store_true", dest="list_inventory")
    parser.add_argument("--host",
                        help="Ansible inventory of a particular host", action="store",
                        dest="ansible_host", type=str)

    cli_args = parser.parse_args()
    list_inventory = cli_args.list_inventory
    ansible_host = cli_args.ansible_host
    
    all_lxc_ips()

    if list_inventory:
        output_list_inventory(ANSIBLE_INV) 
    if ansible_host:
        find_host(ansible_host, HOST_VARS)


if __name__ == "__main__":
    main()