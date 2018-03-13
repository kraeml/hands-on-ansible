# Die Wordpress Rolle

Erstellt mit

```bash
ansible-galaxy init --init-path projects/roles wordpress
```

## Verzeichnisstruktur

```bash
projects/roles/wordpress/
￼
├── defaults
│   └── main.yml
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   ├── configure.yml
│   ├── install.yml
│   └── main.yml
├── templates
│   └── wp-config.php.j2
└── vars
    └── main.yml

6 directories, 9 files
```

## defaults/

```yaml
---
# defaults file for wordpress
wp_srcdir: /usr/local/src
wp_docroot: /var/www
wp_sitedir: fifanews
wp_user: nginx
wp_group: nginx
wp_dbname: fifanews
wp_dbuser: fifa
wp_dbpass: supersecure1234
wp_dbhost: 192.168.61.11
```

## tasks

```yaml
---
# tasks file for wordpress
# filename: roles/wordpress/tasks/main.yml
- include: install.yml
- include: configure.yml
```

```yaml
---
  # filename: roles/wordpress/tasks/install.yml
  - name: download wordpress
    # Zur Demo von command und register.
    # Besser das Modul get_url verwenden
    command: /usr/bin/wget -c https://wordpress.org/latest.tar.gz
    args:
      chdir: "{{ wp_srcdir }}"
      # Hier creates
      # Der Key removes gibt es auch noch
      # Falls das Kommado keine Datei erstellen sollte, dann
      # selber eine Flag-Datei erzeugen lassen.
      creates: "{{ wp_srcdir }}/latest.tar.gz"
      # Der Status von command wird gespeichert
      # •	 changed: This shows the status of whether the state was changed
      # •	 cmd: Through this, the command sequence is launched
      # •	 rc: This refers to the return code
      # •	 stdout: This is the output of the command
      # •	 stdout_lines: This is the output line by line
      # •	 stderr: These state the errors, if any
    register: wp_download

  - name: create nginx docroot
    file:
      path: "{{ wp_docroot }}"
      state: directory
      owner: "{{ wp_user }}"
      group: "{{ wp_group }}"

  - name: extract wordpress
    # Shell Modul wegen der && Verknüpfung
    shell: "tar xzf latest.tar.gz && mv wordpress {{ wp_docroot }}/{{ wp_sitedir }}"
    args:
      chdir: "{{ wp_srcdir }}"
      creates: "{{ wp_docroot }}/{{ wp_sitedir }}"
      # Nur wenn Download erfolgreich war
      when: wp_download.rc == 0
```

```yaml
---
  # filename: roles/wordpress/tasks/configure.yml
  - name: change permissions for wordpress site
    # Sets permissions for all WordPress files recursively.
    file:
      path: "{{ wp_docroot }}/{{ wp_sitedir }}"
      state: directory
      owner: "{{ wp_user }}"
      group: "{{ wp_group }}"
      recurse: true

  - name: get unique salt for wordpress
    # runs a command locally and registers the results in the
    # wp_salt variable. This is to provide WordPress with secret keys for
    # additional security. This variable will be used inside a template this time.
    local_action: command curl https://api.wordpress.org/secret-key/1.1/salt
    register: wp_salt

  - name: copy wordpress template
    # generate a Jinja2 template and copy it over to the target
    # host as the wp-config.php file.
    template:
      src: wp-config.php.j2
      dest: "{{ wp_docroot }}/{{ wp_sitedir }}/wp-config.php"
      mode: 0644
```

## templates

```
<?php
define('DB_NAME', 'wp_dbname');
define('DB_USER', 'wp_dbuser');
define('DB_PASSWORD', '{{ wp_dbpass }}');
define('DB_HOST', '{{ wp_dbhost }}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
{{ wp_salt.stdout }}
$table_prefix  = 'wp_';
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
```
