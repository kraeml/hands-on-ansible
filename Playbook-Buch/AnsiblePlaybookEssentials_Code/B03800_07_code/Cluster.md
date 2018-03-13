# Knoten aufspüren und Clustering

Beim Clusterbau müssen Klassen von Knoten (Webserver) Informationen über andere
 Klassen (Datenbanken) finden können. Oder der Loadbalancer Informationen über
 die Webserver.

* Informationen über ander Knoten bekommen.
* Erstellung von dynamischen Konfigurationen.
* Warum und wie schaltet man das "fact caching" ein.

## Knoten über magische Variablen

Wir kennen bereits die benutzerdefinierten und systemgenerierten (facts) Variablen.
Es gibt auch noch Variablen im Inventory, Plays welche Gruppen gibt es bzw. sind
 im Play beteiligt. Diese Variablen nennt man auch "magic Variables".

```
Magic Variables     Beschreibung
hostvars            Sind "facts" eines anderen Hosts.
groups              Eine Liste der Gruppen im Inventory.
group_names         Eine Liste der Gruppen zu einem Host.
inventory_hostname  Der Hostname im Inventory.
play_hosts          Liste alle Hosts die im Play beteiligt sind.
```

Weitere "magic_variables" sind `delegate_to, inventory_dir und inventory_file`.

## Die Loadbalancer-Rolle

Der Haproxy verteilt die Anfragen auf die drei Webserver.

ToDo: Bild erstellen.

` ansible-galaxy init --init-path projects/roles/ haproxy`

```yaml
---
# filename: roles/haproxy/defaults/main.yml
haproxy:
  config:
    cnfpath: /etc/haproxy/haproxy.cfg
    enabled: 1
    listen_address: 0.0.0.0
    listen_port: 8080
  service: haproxy
  pkg: haproxy
```

```yaml
---
# filename: roles/haproxy/tasks/main.yml
- include: install.yml
- include: configure.yml
- include: service.yml
```

```yaml
---
# filename: roles/haproxy/tasks/install.yml
  - name: install haproxy
    apt:
      name: "{{ haproxy['pkg'] }}"
```

```yaml
---
# filename: roles/haproxy/tasks/configure.yml
 - name: create haproxy config
   template: src="haproxy.cfg.j2" dest="{{ haproxy['config']['cnfpath'] }}" mode=0644
   notify:
    - restart haproxy service

 - name: enable haproxy  
   template: src="haproxy.default.j2" dest=/etc/default/haproxy mode=0644
   notify:
    - restart haproxy service
```

```yaml
---
# filename: roles/haproxy/tasks/service.yml
 - name: start haproxy server
   service:
     name: "{{ haproxy['service'] }}"
     state: started  
```

```yaml
---
# filename: roles/haproxy/handlers/main.yml
- name: restart haproxy service
  service: name="{{ haproxy['service'] }}" state=restarted
```

```jinja2
#filename: roles/haproxy/templates/haproxy.cfg.j2
global
        log 127.0.0.1   local0
        log 127.0.0.1   local1 notice
        maxconn 4096
        user haproxy
        group haproxy
        daemon

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        retries 3
        option redispatch
        maxconn 2000
        contimeout      5000
        clitimeout      50000
        srvtimeout      50000

listen  fifanews {{ haproxy['config']['listen_address'] }}:{{ haproxy['config']['listen_port'] }}
        cookie  SERVERID rewrite
        balance roundrobin
    {% for host in groups['www'] -%}
        server  {{ hostvars[host]['ansible_hostname'] }} {{ hostvars[host]['ansible_eth1']['ipv4']['address'] }}:{{ hostvars[host]['nginx']['phpsites']['fifanews']['port'] }} cookie {{ hostvars[host]['inventory_hostname'] }} check
    {% endfor -%}
```

```yaml
---
#filename: lb.yml
- hosts: lb
  remote_user: vagrant
  become: yes
  roles:
     - { role: haproxy, when: ansible_os_family == 'Debian' }
```

```yaml
# This is a sitewide playbook
# filename: site.yml
- include: db.yml
- include: www.yml
- include: lb.yml
```

Das Playbook kann jetzt mit `ansible-playbook -i customhosts site.yml` ausgeführt werden.

## Zugriff auf nicht-playbooks Hosts

Starten wir unser Paybook nur für den Loadbalancer

`ansible-playbook -i customhosts lb.yml`

wird ein Fehler auftreten.

Ansible meldet das die Variablen der nicht beteiligten Hosts nicht bekannt sind.
 Da Ansible die Facts nur im Arbeitsspeicher hält, können wir nach einem Playbook
 lauf nicht auf "ehemalige" Hosts-facts zugreifen. Darüber hinaus, kann Ansible
 nur nach einem Durchlauf auf einem Hosts die Fakten an andere Host bekannt geben.

### Fact-caching mir Redis

* Installieren von Redis auf dem Ansible Host.
* Die Konfigurationen von Ansible (>1.8) auf Redis einstellen.

```bash
sudo apt-get install redis-server
sudo service redis-server start
apt-get install python-pip
pip install redis
```

```
# filename: /etc/ansible/ansible.cfg
# Comment following lines
# gathering = smart
# fact_caching = memory
# Add following lines
gathering = smart
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

```bash
ansible-playbook -i customhosts www.yml
redis-cli
keys *
```

` ansible-playbook -i customhosts lb.yml`

### Caching in Dateien

Daten können auch als JSON-Datei gespeichert werden.

```
# filename: /etc/ansible/ansible.cfg
fact_caching = jsonfile
fact_caching_connection = /tmp/cache
```

```bash
 mkdir /tmp/cache
 chmod 777 /tmp/cache
```

```diff
diff -uNr -X diffignore ../B03800_06_code/projects/lb.yml ./projects/lb.yml
--- ../B03800_06_code/projects/lb.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/lb.yml	2016-03-21 20:11:20.958242789 +0100
@@ -0,0 +1,9 @@
+---
+#filename: lb.yml
+- hosts: lb
+  remote_user: vagrant
+  become: yes
+  roles:
+     - { role: haproxy, when: ansible_os_family == 'Debian' }
+
+
diff -uNr -X diffignore ../B03800_06_code/projects/roles/base/defaults/main.yml ./projects/roles/base/defaults/main.yml
--- ../B03800_06_code/projects/roles/base/defaults/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/base/defaults/main.yml	2016-03-21 20:11:20.958242789 +0100
@@ -0,0 +1,2 @@
+---
+cluster: clusterA
diff -uNr -X diffignore ../B03800_06_code/projects/roles/base/tasks/main.yml ./projects/roles/base/tasks/main.yml
--- ../B03800_06_code/projects/roles/base/tasks/main.yml	2016-03-21 20:11:20.970242789 +0100
+++ ./projects/roles/base/tasks/main.yml	2016-03-21 20:11:20.082242764 +0100
@@ -1,8 +1,17 @@
 ---
 # essential tasks. should run on all nodes
- - name: creating devops group
+ - name: creating devops group
    group: name=devops state=present
  - name: create devops user with admin previleges
    user: name=devops comment="Devops User" uid=2001 group=devops
  - name: install htop package
    action: apt name=htop state=present update_cache=yes
+   when: ansible_os_family == 'Debian'
+
+# - name: install htop package
+#   action: yum name=htop state=present update_cache=yes
+#   when: ansible_os_family == 'RedHat'
+
+ - name: set cluster id
+   set_fact:
+     cluster: "{{ cluster }}"
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/defaults/main.yml ./projects/roles/haproxy/defaults/main.yml
--- ../B03800_06_code/projects/roles/haproxy/defaults/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/defaults/main.yml	2016-03-21 20:11:20.958242789 +0100
@@ -0,0 +1,10 @@
+---
+# filename: roles/haproxy/defaults/main.yml
+haproxy:
+  config:
+    cnfpath: /etc/haproxy/haproxy.cfg
+    enabled: 1
+    listen_address: 0.0.0.0
+    listen_port: 8080
+  service: haproxy
+  pkg: haproxy
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/handlers/main.yml ./projects/roles/haproxy/handlers/main.yml
--- ../B03800_06_code/projects/roles/haproxy/handlers/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/handlers/main.yml	2016-03-21 20:11:20.958242789 +0100
@@ -0,0 +1,4 @@
+---
+# filename: roles/haproxy/handlers/main.yml
+- name: restart haproxy service
+  service: name="{{ haproxy['service'] }}" state=restarted
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/tasks/configure.yml ./projects/roles/haproxy/tasks/configure.yml
--- ../B03800_06_code/projects/roles/haproxy/tasks/configure.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/tasks/configure.yml	2016-03-21 20:11:20.958242789 +0100
@@ -0,0 +1,11 @@
+---
+# filename: roles/haproxy/tasks/configure.yml
+ - name: create haproxy config
+   template: src="haproxy.cfg.j2" dest="{{ haproxy['config']['cnfpath'] }}" mode=0644
+   notify:
+    - restart haproxy service
+
+ - name: enable haproxy  
+   template: src="haproxy.default.j2" dest=/etc/default/haproxy mode=0644
+   notify:
+    - restart haproxy service
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/tasks/install.yml ./projects/roles/haproxy/tasks/install.yml
--- ../B03800_06_code/projects/roles/haproxy/tasks/install.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/tasks/install.yml	2016-03-21 20:11:20.954242789 +0100
@@ -0,0 +1,5 @@
+---
+# filename: roles/haproxy/tasks/install.yml
+  - name: install haproxy
+    apt:
+      name: "{{ haproxy['pkg'] }}"
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/tasks/main.yml ./projects/roles/haproxy/tasks/main.yml
--- ../B03800_06_code/projects/roles/haproxy/tasks/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/tasks/main.yml	2016-03-21 20:11:20.954242789 +0100
@@ -0,0 +1,5 @@
+---
+# filename: roles/haproxy/tasks/main.yml
+- include: install.yml
+- include: configure.yml
+- include: service.yml
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/tasks/service.yml ./projects/roles/haproxy/tasks/service.yml
--- ../B03800_06_code/projects/roles/haproxy/tasks/service.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/tasks/service.yml	2016-03-21 20:11:20.954242789 +0100
@@ -0,0 +1,6 @@
+---
+# filename: roles/haproxy/tasks/service.yml
+ - name: start haproxy server
+   service:
+     name: "{{ haproxy['service'] }}"
+     state: started   
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/templates/haproxy.cfg.j2 ./projects/roles/haproxy/templates/haproxy.cfg.j2
--- ../B03800_06_code/projects/roles/haproxy/templates/haproxy.cfg.j2	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/templates/haproxy.cfg.j2	2016-03-21 20:11:20.954242789 +0100
@@ -0,0 +1,27 @@
+#filename: roles/haproxy/templates/haproxy.cfg.j2
+global
+        log 127.0.0.1   local0
+        log 127.0.0.1   local1 notice
+        maxconn 4096
+        user haproxy
+        group haproxy
+        daemon
+
+defaults
+        log     global
+        mode    http
+        option  httplog
+        option  dontlognull
+        retries 3
+        option redispatch
+        maxconn 2000
+        contimeout      5000
+        clitimeout      50000
+        srvtimeout      50000
+
+listen  fifanews {{ haproxy['config']['listen_address'] }}:{{ haproxy['config']['listen_port'] }}
+        cookie  SERVERID rewrite
+        balance roundrobin
+    {% for host in groups['www'] -%}
+        server  {{ hostvars[host]['ansible_hostname'] }} {{ hostvars[host]['ansible_eth1']['ipv4']['address'] }}:{{ hostvars[host]['nginx']['phpsites']['fifanews']['port'] }} cookie {{ hostvars[host]['inventory_hostname'] }} check
+    {% endfor -%}
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/templates/haproxy.default.j2 ./projects/roles/haproxy/templates/haproxy.default.j2
--- ../B03800_06_code/projects/roles/haproxy/templates/haproxy.default.j2	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/templates/haproxy.default.j2	2016-03-21 20:11:20.954242789 +0100
@@ -0,0 +1,2 @@
+#filename: roles/haproxy/templates/haproxy.default
+ENABLED="{{ haproxy['config']['enabled'] }}"
\ Kein Zeilenumbruch am Dateiende.
diff -uNr -X diffignore ../B03800_06_code/projects/roles/haproxy/vars/main.yml ./projects/roles/haproxy/vars/main.yml
--- ../B03800_06_code/projects/roles/haproxy/vars/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/haproxy/vars/main.yml	2016-03-21 20:11:20.954242789 +0100
@@ -0,0 +1,2 @@
+---
+# vars file for haproxy
diff -uNr -X diffignore ../B03800_06_code/projects/roles/mysql/tasks/install_RedHat.yml ./projects/roles/mysql/tasks/install_RedHat.yml
--- ../B03800_06_code/projects/roles/mysql/tasks/install_RedHat.yml	2016-03-21 20:11:19.994242761 +0100
+++ ./projects/roles/mysql/tasks/install_RedHat.yml	2016-03-21 20:11:20.950242789 +0100
@@ -1,8 +1,8 @@
 ---
 # filename: roles/mysql/tasks/install_RedHat.yml
 - name: install mysql server
-  yum:
-    name: "{{ mysql['pkg']['server'] }}"
+  yum:
+    name: "{{ mysql['pkg']['server'] }}"  
   when: mysql.server

 - name: install mysql python binding
diff -uNr -X diffignore ../B03800_06_code/projects/roles/mysql/vars/RedHat.yml ./projects/roles/mysql/vars/RedHat.yml
--- ../B03800_06_code/projects/roles/mysql/vars/RedHat.yml	2016-04-01 08:25:00.000000000 +0200
+++ ./projects/roles/mysql/vars/RedHat.yml	2016-03-21 20:11:20.950242789 +0100
@@ -8,6 +8,5 @@
     bind: 0.0.0.0
   pkg:
     server: mariadb-server
-    client: mariadb-client
     python: MySQL-python
   service: mariadb
diff -uNr -X diffignore ../B03800_06_code/projects/roles/nginx/tasks/install.yml ./projects/roles/nginx/tasks/install.yml
--- ../B03800_06_code/projects/roles/nginx/tasks/install.yml	2016-04-01 08:25:00.000000000 +0200
+++ ./projects/roles/nginx/tasks/install.yml	2016-03-21 20:11:20.950242789 +0100
@@ -1,5 +1,8 @@
 ---
  - name: add official nginx repository
-   apt_repository: repo='deb http://nginx.org/packages/ubuntu/ lucid nginx'
+   apt_repository:
+     repo: 'ppa:nginx/stable'
+     state: absent
+
  - name: install nginx web server and ensure its at the latest version
    apt: name=nginx state=latest force=yes
diff -uNr -X diffignore ../B03800_06_code/projects/roles/nginx/tasks/main.yml ./projects/roles/nginx/tasks/main.yml
--- ../B03800_06_code/projects/roles/nginx/tasks/main.yml	2016-03-21 20:11:20.966242789 +0100
+++ ./projects/roles/nginx/tasks/main.yml	2016-03-21 20:11:20.950242789 +0100
@@ -3,5 +3,3 @@
  - include: install.yml
  - include: configure.yml
  - include: service.yml
-
-
diff -uNr -X diffignore ../B03800_06_code/projects/roles/php5-fpm/tasks/install.yml ./projects/roles/php5-fpm/tasks/install.yml
--- ../B03800_06_code/projects/roles/php5-fpm/tasks/install.yml	2016-03-21 20:11:20.054242763 +0100
+++ ./projects/roles/php5-fpm/tasks/install.yml	2016-03-21 20:11:20.946242789 +0100
@@ -1,17 +1,8 @@
-#filename: roles/php5-fpm/tasks/install.yml
-#  - name: Add an Apt signing key,
-#    apt_key:
-#      id: B12D0447319F1ADB
-#      url: https://sektioneins.de/files/repository.asc
-#      state: present
-
-#  - name: /etc/apt/sources.list for Ubuntu trusty (stable) (amd64 only)
-#    apt_repository:
-#      repo: 'deb http://repo.suhosin.org/ ubuntu-trusty main'
-
+ #filename: roles/php5-fpm/tasks/install.yml
   - name: install php5-fpm and family
     apt:
       name: "{{ item }}"
     with_items: php5.packages
     notify:
      - restart php5-fpm service
+
diff -uNr -X diffignore ../B03800_06_code/projects/roles/wordpress/defaults/main.yml ./projects/roles/wordpress/defaults/main.yml
--- ../B03800_06_code/projects/roles/wordpress/defaults/main.yml	2016-03-21 20:11:20.962242789 +0100
+++ ./projects/roles/wordpress/defaults/main.yml	2016-03-21 20:11:20.174242766 +0100
@@ -3,8 +3,8 @@
 wp_srcdir: /usr/local/src
 wp_docroot: /var/www
 wp_sitedir: fifanews
-wp_user: nginx
-wp_group: nginx
+wp_user: www-data
+wp_group: www-data
 wp_dbname: fifanews
 wp_dbuser: fifa
 wp_dbpass: supersecure1234
diff -uNr -X diffignore ../B03800_06_code/projects/roles/wordpress/tasks/configure.yml ./projects/roles/wordpress/tasks/configure.yml
--- ../B03800_06_code/projects/roles/wordpress/tasks/configure.yml	2016-03-21 20:11:20.054242763 +0100
+++ ./projects/roles/wordpress/tasks/configure.yml	2016-03-21 20:11:20.174242766 +0100
@@ -23,3 +23,4 @@
       src: wp-config.php.j2
       dest: "{{ wp_docroot }}/{{ wp_sitedir }}/wp-config.php"
       mode: 0644
+      
\ Kein Zeilenumbruch am Dateiende.
diff -uNr -X diffignore ../B03800_06_code/projects/site.yml ./projects/site.yml
--- ../B03800_06_code/projects/site.yml	2016-03-21 20:11:20.962242789 +0100
+++ ./projects/site.yml	2016-03-21 20:11:20.942242788 +0100
@@ -1,5 +1,6 @@
 ---
 # This is a sitewide playbook
 # filename: site.yml
-- include: www.yml
 - include: db.yml
+- include: www.yml
+- include: lb.yml
diff -uNr -X diffignore ../B03800_06_code/projects/www.yml ./projects/www.yml
--- ../B03800_06_code/projects/www.yml	2016-03-21 20:11:20.958242789 +0100
+++ ./projects/www.yml	2016-03-21 20:11:20.942242788 +0100
@@ -11,4 +11,6 @@
   post_tasks:
      - shell: echo 'I":" Done configuring nginx web server...'

-
+  vars:
+    cluster:
+      id: clusterB
```
