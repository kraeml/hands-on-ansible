# Verwaltung von Umgebungen

* dev: Entwicklungsumgebung
* qa: Qualitätssicherung (Test)
* stage: Abbild von Production um Stresstest zu fahren
* prod: Produktionsumgebung

Alle Umgebung sollten möglichst gleich sein aber haben miteinander nichts zu tun.

Eine Dev-DB hat nichts mit einer stage/prod-DB gemeinsam (Datenschutz)!

In einer Dev-Umgebung können wir LB, Webserver und DB auf einer virtuellen Maschine
 laufen lassen. Im Stage können LB, Webserver und DB getrennt sein. In Production
 läuft der LB mit drei Webservern und DBs getrennt.

ToDo: Bild erstellen

Wie kann man mit Ansible diese Umgebung gemeinsam verwalten?

1. Getrennte Inventory-Dateien für die Umgebung.
2. Verwendung von group_vars und host_vars für die Umgebungen.

Beides ist möglich.

## Inventory Gruppen und Variablen

Im Inventory können verschiedene Gruppen aufgeführt werden.

```ini
#customhosts
#inventory configs for my cluster
[db]
192.168.60.21 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
192.168.60.22 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
[www]
192.168.60.11 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
192.168.60.12 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
192.168.60.13 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key

[lb]
192.168.60.2 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
```

Im Ordner `group_vars` können diese Gruppen auch verwendet werden.

```
group_vars/
├── all
└── www
```

Die spezifischste Variablen wird genommen.

## Verwendung von nested Gruppen

1. Erstellen eines `environments` Ordners. Dort wird eine Inventory-Datei mit dem
 Namen der Umgebung erstellt.

```bash
environments/
└── dev
```

2. Erstellen Sie eine Elterngruppe mit dem Namen der Umgebung.

```ini
#customhosts
#inventory configs for my cluster
[db]
192.168.60.21 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
#192.168.60.22 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
[www]
192.168.61.11 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
#192.168.61.12 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
#192.168.61.13 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key

[lb]
192.168.60.2 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key

[dev:children]
db
www
lb
```

3. Im Ordner `group_vars` wird in `all` die Variable `env_name` mit dem Wert `default`

```yaml
#filename: group_vars/all
mysql_bind:  "{{ ansible_eth0.ipv4.address }}"
mysql:
  databases:
    fifalive:
      state: present
    fifanews:
      state: present
  users:
    fifa:
      pass: supersecure1234
      host: '%'
      priv: '*.*:ALL'
      state: present
nginx:
  phpsites:
    fifanews:
      name: fifanews.com
      port: 8080
      doc_root: /var/www/fifanews
env_name: default
```
4. Im Ordner `group_vars` wird die Datei `dev` erstellt.
```bash
group_vars/
├── all
├── dev
└── www
```
Mit dem Inhalt `env_name: dev`
5. Aufrufen mit `ansible-playbook -i environments/dev site.yml`

Dadurch wird das Inventory für `dev` aufgerufen **und** die Umgebungsvariable
 auf `dev` gesetzt.

Dies kann jetzt auch mit `qa` `stage` und `prod` geschehen.

## Umgebungstypische Inventory-Variablen setzen

* Die `-i` Option kann nicht nur Inventory-Dateien laden, sondern auch mit Verzeichnissen umgehen.
* Die `host` und `group` Variablen können relativ zum entsprechenden Inventory in
 den Ordnern `host_vars` bzw. `group_vars` gesetzt werden.

Hinweis: Einen übergeordneten Ordner `group_vars` würde allerdings die Variablen
 der untergeordneten `group_vars` überschreiben.

```bash
  environments_2/
├── dev
│   └── group_vars
│       └── all
├── prod
│   └── group_vars
│       └── all
└── stage
    └── group_vars
        └── all
```

Die Variablen und Inventory können jetzt entsprechend gesetzt werden. Besonders
 die Variable `env_name`.

Der Aufruf ist `ansible-playbook -i environments/dev site.yml`. Wobei `dev` jetzt
 ein Verzeichnis ist.

Jetzt kann auch auf die Variable `env_name` zugegriffen werden.

# Diff

```diff
diff -uNr -X ./diffignore ../B03800_08_code/diffignore ./diffignore
--- ../B03800_08_code/diffignore	2016-04-18 16:51:10.722642742 +0200
+++ ./diffignore	2016-04-18 17:00:29.942628083 +0200
@@ -9,3 +9,4 @@
 *meta*
 *.diff
 *~
+*.pdf
diff -uNr -X ./diffignore ../B03800_08_code/projects/aws_creds.yml ./projects/aws_creds.yml
--- ../B03800_08_code/projects/aws_creds.yml	2016-04-11 20:47:33.208187856 +0200
+++ ./projects/aws_creds.yml	1970-01-01 01:00:00.000000000 +0100
@@ -1,10 +0,0 @@
-$ANSIBLE_VAULT;1.1;AES256
-30346239616537373261633165373666386264613239643064656434333364353238643532666238
-3034623264333631336430633965656637663365663937630a353463326261653031613661653636
-32386266613733303936623861613731386162316435386533363636336430616637303236353136
-6166386661653434310a333539356139633433613532303033656430636235343932613230643765
-33356130356666663661636538306631633436366265386363373130323836316637616663303437
-35363438393862343736303734643433623432323132343566316366386561393861336562636263
-64336539393637303262643036363931356631653430663133366632653433386335616539353232
-64393166356162633732353362343263623630366337396165343135383535326230356532613463
-64613836306433633762353635616536346636646538326363376565383163666335
diff -uNr -X ./diffignore ../B03800_08_code/projects/environments/dev ./projects/environments/dev
--- ../B03800_08_code/projects/environments/dev	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/environments/dev	2016-04-11 20:47:33.008187849 +0200
@@ -0,0 +1,17 @@
+#customhosts
+#inventory configs for my cluster
+[db]
+192.168.60.21 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
+#192.168.60.22 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
+[www]
+192.168.61.11 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
+#192.168.61.12 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
+#192.168.61.13 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
+
+[lb]
+192.168.60.2 ansible_ssh_user=vagrant ansible_ssh_private_key_file=/vagrant/insecure_private_key
+
+[dev:children]
+db
+www
+lb
diff -uNr -X ./diffignore ../B03800_08_code/projects/group_vars/all ./projects/group_vars/all
--- ../B03800_08_code/projects/group_vars/all	2016-04-11 20:47:33.208187856 +0200
+++ ./projects/group_vars/all	2016-04-11 20:47:33.196187856 +0200
@@ -18,3 +18,4 @@
       name: fifanews.com
       port: 8080
       doc_root: /var/www/fifanews
+env_name: default
diff -uNr -X ./diffignore ../B03800_08_code/projects/group_vars/dev ./projects/group_vars/dev
--- ../B03800_08_code/projects/group_vars/dev	1970-01-01 01:00:00.000000000 +0100
+++ ./projects/group_vars/dev	2016-04-11 20:47:33.196187856 +0200
@@ -0,0 +1 @@
+env_name: dev
diff -uNr -X ./diffignore ../B03800_08_code/projects/roles/nginx/tasks/configure.yml ./projects/roles/nginx/tasks/configure.yml
--- ../B03800_08_code/projects/roles/nginx/tasks/configure.yml	2016-04-11 20:47:33.200187856 +0200
+++ ./projects/roles/nginx/tasks/configure.yml	2016-04-11 20:47:33.188187856 +0200
@@ -4,7 +4,9 @@
    notify:
     - restart nginx service
  - name: create home page for default site
-   copy: src=index.html dest=/usr/share/nginx/html/index.html
+   template:
+     src: index.html.j2
+     dest: /usr/share/nginx/html/index.html

  - name: create php virtual hosts
    template:
diff -uNr -X ./diffignore ../B03800_08_code/projects/roles/nginx/templates/index.html.j2 ./projects/roles/nginx/templates/index.html.j2
--- ../B03800_08_code/projects/roles/nginx/templates/index.html.j2	2016-04-11 20:47:33.200187856 +0200
+++ ./projects/roles/nginx/templates/index.html.j2	2016-04-11 20:47:33.188187856 +0200
@@ -1,5 +1,5 @@
 <html>
  <body>
-   <h1> Welcome to {{ item.value.name }} </h1>
+   <h1> Welcome to {{ env_name }} </h1>
  </body>
 </html>
diff -uNr -X ./diffignore ../B03800_08_code/projects/test/vars.yml ./projects/test/vars.yml
--- ../B03800_08_code/projects/test/vars.yml	2016-04-11 20:47:33.196187856 +0200
+++ ./projects/test/vars.yml	1970-01-01 01:00:00.000000000 +0100
@@ -1,4 +0,0 @@
----
-demo:
-  pass: supersecret
-
```
