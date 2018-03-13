#!/bin/bash

#ansible --version

# ansible wird installiert und ein Upgrade durchgeführt.
# Version von ansible wird ausgegeben.
# ToDo Was passiert wenn ansible nicht installiert ist?
sudo pip install --upgrade ansible
# ToDo Kann weg nicht notwendig
ansible --version

#ls -lachi /etc/ansible/

# /vagrant ist Sync-Folder zum Hostsystem
# kopiert von Host die Hosts Datei in den Gastpfad
# /etc/ansible/hosts
# Nur kopieren wenn nicht vorhanden oder andere Version vorliegt
sudo cp /vagrant/hosts /etc/ansible
#cat /etc/ansible/hosts

# Ansible führt für die Gruppe 'local'
# aus der Datei /etc/ansible/hosts
# das Ping Modul aus
ansible local -m ping

# Existiert die Datei .ssh/id_rsa => wenn ja lösche
# alle Dateien im gleichen Verzeichnis, die mit id_rsa beginnen
# Erzeuge einen RSA-Schlüssel in der Datei .ssh/id_rsa mit
# vorgegebener Passphrase
if [ -f ~/.ssh/id_rsa ]
then
  rm ~/.ssh/id_rsa*
fi
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N geheim

# übernehmen den Fingerprint von 192.168.60.2 und schreiben
# ihn in die Datei ~/.ssh/known_hosts
# damit wird der dem System bekannt gegeben.
ssh-keyscan -H 192.168.60.2 >> ~/.ssh/known_hosts
#cat ~/.ssh/known_hosts

# Aktualisieren der verfügbaren Pakete
# Installation von sshpass ohne Nutzereingabe
# Befüllen der Datei passwort mit Benutzerpasswort
# Kopieren des öffenlichen Schlüssels anhand Passwort
# aus passwort-Datei in Zielsystem
sudo apt-get update
sudo apt-get install -y sshpass
echo 'vagrant' > passwort
sshpass -f passwort ssh-copy-id vagrant@192.168.60.2


# Installation von expect ohne Nutzer-Interaktion
# Kopieren des ssh-add-passphrase.sh Skripts aus dem Shared-Folder
# in das aktuelle Verzeichnis
# Setzen des Ausführen-Rechts für den aktuellen Benutzer
# für die Datei ssh-add-passphrase.sh
# Setzen der Umgebungsvariablen für den SSH-Agent & Schreiben der
# Ausgabe nach /dev/null
# Ausführung des ssh-add-passphrase.sh Skripts
sudo apt-get install -y expect
cp /vagrant/ssh-add-passphrase.sh ./
chmod u+x ssh-add-passphrase.sh
#cat ssh-add-passphrase.sh
eval `ssh-agent -s` > /dev/null
./ssh-add-passphrase.sh

#env
#ssh-add -l

# Ansible Befehl Ping wird auf dem Loadbalancer ausgeführt
ansible lb -m ping
# Fingerprint und Public-Key Übernahme für die restlichen IPs aus
# dem Netz.
for i in 11 12 13 21 22
do
    ssh-keyscan -H 192.168.60.${i} >> ~/.ssh/known_hosts
    sshpass -f passwort ssh-copy-id vagrant@192.168.60.${i}
done
# Das Modul Ping wird auf allen Rechnern ausgeführt
ansible all -m ping
