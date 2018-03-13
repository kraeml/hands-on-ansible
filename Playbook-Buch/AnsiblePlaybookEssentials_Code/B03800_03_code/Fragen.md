# Playbook Variablen

[Ansible Variablen Doc](http://docs.ansible.com/ansible/playbooks_variables.html)

1. Welche der unten angegebenen Variablnamen sind gültig?

  a. foo_port

  b. foo5

  c. foo-port

  d. foo port

  e. foo.port

  f. 12

  a und b sind richtig ToDO Mischen

2. YAML unterstützt auch dictionaries, die Schlüssel auf Werte abbilden. Geben Sie hierzu ein Beispiel an. Der Name der Variable soll Foo lauten. Es sollen zwei Schlüssel mit den Namen Feld1 und Feld2 beinhalten. Der Wert für Feld1 soll Eins sein und für Feld2 zwei sein.

  ```yaml
  Foo:
  Feld1: Eins
  Feld2: zwei
  ```

3. Im Inventoryfile können sogenannte Hostvariablen angegeben werden. Gegeben ist die Gruppe atlanta mit den Hosts host1 und host2\. Für beide Hosts soll die Variable http_port und maxRequestsPerChild gesetzt werden. Für host1 ist der Port auf 80 und der Request auf 808 und für host2 der Port auf 303 und der Request auf 909 zu setzen. Geben Sie den Inventory Eintrag an.

  ```ini
  [atlanta]
  host1 http_port=80 maxRequestsPerChild=808
  host2 http_port=303 maxRequestsPerChild=909
  ```

4. Variablen können auch auf eine ganze Gruppe gleichzeitig angewendet werden. Geben Sie für die Gruppe atlanta die Gruppenvariablen ntp_server mit dem Wert ntp.atlanta.example.com und proxy mit dem Wert proxy.atlanta.example.com in einer Inventory Datei an.

  ```ini
  [atlanta:vars]
  ntp_server=ntp.atlanta.example.com
  proxy=proxy.atlanta.example.com
  ```

5. In einem Playbook ist es möglich, Variablen direkt inline zu definieren. Geben Sie hier den Eintrag in einem Playbook an, der die Variable http_port für die Gruppe webservers auf den Wert 80 setzt.

  ```yaml
  - hosts: webservers
  vars:
  http_port: 80
  ```

6. Welchen zwei Ordner einer Rolle dienen Ausschließlich zur Angabe von Variablen?

  Im Verzeichnis defaults und vars.

7. Sie sollen ein Jinja2-Vorlagen erstellen die in Abhängigkeit von der Variable max_amp_value den Text "My am goes to 22". Wobei die 22 durch die Variable bestimmt werden soll. Wie lautet die Zeile im entsprechenden Template?

  ```j2
  My amp goes to {{ max_amp_value }}
  ```

8. Es soll eine Variable remote_install_path verwendet werden, um zu entscheiden, wo eine Datei (als Zielpfad) platziert werden soll. Geben Sie hier die entsprechenden Angaben in einem gültigen YAML-Playbook an. Verwenden Sie das Modul template. Die Vorlage hat den Namen foo.cfg.j2 und soll in Anbhängigkeit der Variable remote_install_path als Datei foo.cfg abgelegt werden.

  ```yaml
  template: src=foo.cfg.j2 dest="{{ remote_install_path }}/foo.cfg"
  ```

9. Mit welchem Modul werden System Fakten eingesammelt?

  setup

10. Wie können in einem Playbook das Sammeln von System Fakten deaktiviert werden?

  ```yaml
  - hosts: whatever
  gather_facts: no
  ```

11. In welchem Verzeichnis können local Facts-Dateien abgelegt werden?

  /etc/ansible/facts.d

12. Geben Sie einen alternativen Zugriff auf den Inhalt von ansible_eth0.ipv4.address an.

  ansible_eth0["ipv4"]["address"]

13. Geben Sie hier den Aufruf von einem Playbook mit dem Namen release.yml an. Dabei sollen die Variablen version mit dem Wert 1.23.45 und other_variable mit dem Inhalt foo mitgegeben werden.

  ```bash
  ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
  ```

14. Variablen Vorrangsregeln: Welcher Ansible Varialen Angabe gewinnt immer?

  Die extra-vars Eingabe über Kommado-Zeilenangabe.

15. Parametrierte Rollen sind nützlich. Wenn Sie eine Rolle verwenden und einen Standard überschreiben möchten, übergeben Sie sie als Parameter an die Rolle. Die Rolle apache soll aufgerufen werden. Dabei soll die Variable http_port mit dem Wert 8080 als Parameter übergeben werden.

  ```yaml
  roles:
    - { role: apache, http_port: 8080 }
  ```
