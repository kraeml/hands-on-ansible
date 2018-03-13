# Refactoring PHP diff

```diff
diff -uNr -X diffignore ../B03800_05_code/diffignore ./diffignore
--- ../B03800_05_code/diffignore	1970-01-01 01:00:00.000000000 +0100
+++ ./diffignore	2016-04-01 08:49:17.390879114 +0200
@@ -0,0 +1,9 @@
+itory
+*.md
+Wordpress.*
+*.md
+texput.log
+.vagrant
+*meta*
+*.diff
+*~
diff -uNr -X diffignore ../B03800_05_code/Makefile ./Makefile
--- ../B03800_05_code/Makefile	2016-03-21 20:11:19.802242755 +0100
+++ ./Makefile	2016-04-01 08:50:50.598883021 +0200
@@ -81,4 +81,7 @@

 all: odt revealjs html pdf_single pdf_multi

+diff:
+	diff -uNr -X diffignore ../B03800_05_code/ ./ > Loops-und-PHP.diff
+
 .PHONY: odt revealjs pdf_single pdf_multi html all
Binärdateien ../B03800_05_code/MySQL_und_Nginx.pmd.pdf und ./MySQL_und_Nginx.pmd.pdf sind verschieden.
diff -uNr -X diffignore ../B03800_05_code/projects/group_vars/all ./projects/group_vars/all
--- ../B03800_05_code/projects/group_vars/all	2016-03-21 20:11:20.982242790 +0100
+++ ./projects/group_vars/all	2016-03-21 20:11:20.974242789 +0100
@@ -1,2 +1,20 @@
 #filename: group_vars/all
 mysql_bind:  "{{ ansible_eth0.ipv4.address }}"
+mysql:
+  databases:
+    fifalive:
+      state: present
+    fifanews:
+      state: present
+  users:
+    fifa:
+      pass: supersecure1234
+      host: '%'
+      priv: '*.*:ALL'
+      state: present
+nginx:
+  phpsites:
+    fifanews:
+      name: fifanews.com
+      port: 8080
+      doc_root: /var/www/fifanews
diff -uNr -X diffignore ../B03800_05_code/projects/roles/mysql/tasks/configure.yml ./projects/roles/mysql/tasks/configure.yml
--- ../B03800_05_code/projects/roles/mysql/tasks/configure.yml	2016-03-21 20:11:20.978242789 +0100
+++ ./projects/roles/mysql/tasks/configure.yml	2016-03-21 20:11:20.970242789 +0100
@@ -4,4 +4,21 @@
    template: src="my.cnf.j2" dest="{{ mysql['config']['cnfpath'] }}" mode=0644
    notify:
     - restart mysql service
-
+
+ - name: create mysql databases
+   mysql_db:
+     name: "{{ item.key }}"
+     state: "{{ item.value.state }}"
+   with_dict: "{{ mysql['databases'] }}"
+
+ - name: create mysql users
+   mysql_user:
+     name: "{{ item.key }}"
+     host: "{{ item.value.host }}"
+     password: "{{ item.value.pass }}"
+     priv: "{{ item.value.priv }}"
+     state: "{{ item.value.state }}"
+   with_dict: "{{ mysql['users'] }}"
+
+
+
diff -uNr -X diffignore ../B03800_05_code/projects/roles/nginx/tasks/configure.yml ./projects/roles/nginx/tasks/configure.yml
--- ../B03800_05_code/projects/roles/nginx/tasks/configure.yml	2016-03-21 20:11:20.978242789 +0100
+++ ./projects/roles/nginx/tasks/configure.yml	2016-03-21 20:11:20.966242789 +0100
@@ -6,3 +6,10 @@
  - name: create home page for default site
    copy: src=index.html dest=/usr/share/nginx/html/index.html

+ - name: create php virtual hosts
+   template:
+     src: php_vhost.j2
+     dest: /etc/nginx/conf.d/{{ item.key }}.conf
+   with_dict: "{{ nginx['phpsites'] }}"
+   notify:
+     - restart nginx service
diff -uNr -X diffignore ../B03800_05_code/projects/roles/nginx/templates/php_vhost.j2 ./projects/roles/nginx/templates/php_vhost.j2
--- ../B03800_05_code/projects/roles/nginx/templates/php_vhost.j2	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/nginx/templates/php_vhost.j2	2016-03-21 20:11:20.966242789 +0100
@@ -0,0 +1,21 @@
+#{{ ansible_managed }}
+
+server {
+    listen   {{ item.value.port }};
+
+  location / {
+        root   {{ item.value.doc_root }};
+        index  index.php;
+    }
+
+  location ~ .php$ {
+        fastcgi_split_path_info ^(.+\.php)(.*)$;
+        fastcgi_pass   backend;
+        fastcgi_index  index.php;
+        fastcgi_param  SCRIPT_FILENAME  {{ item.value.doc_root }}$fastcgi_script_name;
+        include fastcgi_params;
+    }
+}
+upstream backend {
+        server 127.0.0.1:9000;
+}
diff -uNr -X diffignore ../B03800_05_code/projects/roles/php5-fpm/defaults/main.yml ./projects/roles/php5-fpm/defaults/main.yml
--- ../B03800_05_code/projects/roles/php5-fpm/defaults/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/php5-fpm/defaults/main.yml	2016-03-21 20:11:20.966242789 +0100
@@ -0,0 +1,16 @@
+---
+#filename: roles/php5-fpm/defaults/main.yml
+#defaults file for php5-fpm
+php5:
+  packages:
+    - php5-common
+    - php5-curl
+    - php5-mysql
+    - php5-cli
+    - php5-gd
+    - php5-mcrypt
+#    - php5-suhosin
+    - php5-memcache
+    - php5-fpm
+  service:
+    name: php5-fpm
diff -uNr -X diffignore ../B03800_05_code/projects/roles/php5-fpm/handlers/main.yml ./projects/roles/php5-fpm/handlers/main.yml
--- ../B03800_05_code/projects/roles/php5-fpm/handlers/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/php5-fpm/handlers/main.yml	2016-03-21 20:11:20.962242789 +0100
@@ -0,0 +1,5 @@
+---
+# filename: roles/php5-fpm/handlers/main.yml
+# handlers file for php5-fpm
+- name: restart php5-fpm service
+  service: name="{{ php5['service']['name'] }}" state=restarted
diff -uNr -X diffignore ../B03800_05_code/projects/roles/php5-fpm/tasks/install.yml ./projects/roles/php5-fpm/tasks/install.yml
--- ../B03800_05_code/projects/roles/php5-fpm/tasks/install.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/php5-fpm/tasks/install.yml	2016-03-21 20:11:20.054242763 +0100
@@ -0,0 +1,17 @@
+#filename: roles/php5-fpm/tasks/install.yml
+#  - name: Add an Apt signing key,
+#    apt_key:
+#      id: B12D0447319F1ADB
+#      url: https://sektioneins.de/files/repository.asc
+#      state: present
+
+#  - name: /etc/apt/sources.list for Ubuntu trusty (stable) (amd64 only)
+#    apt_repository:
+#      repo: 'deb http://repo.suhosin.org/ ubuntu-trusty main'
+
+  - name: install php5-fpm and family
+    apt:
+      name: "{{ item }}"
+    with_items: php5.packages
+    notify:
+     - restart php5-fpm service
diff -uNr -X diffignore ../B03800_05_code/projects/roles/php5-fpm/tasks/main.yml ./projects/roles/php5-fpm/tasks/main.yml
--- ../B03800_05_code/projects/roles/php5-fpm/tasks/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/php5-fpm/tasks/main.yml	2016-03-21 20:11:20.962242789 +0100
@@ -0,0 +1,9 @@
+---
+#filename: roles/php5-fpm/tasks/main.yml
+# tasks file for php5-fpm
+- include_vars: "{{ ansible_os_family }}.yml"
+  when: ansible_os_family != 'Debian'
+
+- include: install.yml
+- include: service.yml
+
diff -uNr -X diffignore ../B03800_05_code/projects/roles/php5-fpm/tasks/service.yml ./projects/roles/php5-fpm/tasks/service.yml
--- ../B03800_05_code/projects/roles/php5-fpm/tasks/service.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/php5-fpm/tasks/service.yml	2016-03-21 20:11:20.962242789 +0100
@@ -0,0 +1,6 @@
+#filename: roles/php5-fpm/tasks/service.yml
+# manage php5-fpm service
+- name: start php5-fpm service
+  service:
+    name: "{{ php5['service']['name'] }}"
+    state: started   
diff -uNr -X diffignore ../B03800_05_code/projects/roles/php5-fpm/vars/main.yml ./projects/roles/php5-fpm/vars/main.yml
--- ../B03800_05_code/projects/roles/php5-fpm/vars/main.yml	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/roles/php5-fpm/vars/main.yml	2016-03-21 20:11:20.962242789 +0100
@@ -0,0 +1,2 @@
+---
+# vars file for php5-fpm
diff -uNr -X diffignore ../B03800_05_code/projects/www.yml ./projects/www.yml
--- ../B03800_05_code/projects/www.yml	2016-03-21 20:11:20.974242789 +0100
+++ ./projects/www.yml	2016-03-21 20:11:20.958242789 +0100
@@ -6,6 +6,7 @@
      - shell: echo 'I":" Beginning to configure web server..'
   roles:
      - { role: nginx, when: ansible_os_family == 'Debian' }
+     - php5-fpm
      - wordpress
   post_tasks:
      - shell: echo 'I":" Done configuring nginx web server...'
```
