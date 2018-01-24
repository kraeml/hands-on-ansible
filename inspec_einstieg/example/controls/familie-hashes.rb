# encoding: utf-8
# copyright: 2017, The Authors

title 'Familiencheck'

gruppen = {
    'familie' => 'familie',
    'erwachsene' => 'erwachsene',
    'finanzen' => 'finanzen',
    'rezepte' => 'rezepte',
    'kinder' => 'kinder'
  }
# you add controls here

control 'User-1.0' do
  impact 0.7
  title 'Teste User'
  desc 'Teste User und Gruppenzugehörigkeit'
  ENV['LC_MESSAGES'] = 'C'
  describe user('vater') do
    it { should exist }
    its('groups') { should be_in [ 'vater', 'erwachsene','familie','finanzen'] }
    its('group') { should eq 'vater' }
    its('home') { should eq '/home/vater' }
    its('shell') { should eq '/bin/csh' }
  end
  describe user('mutter') do
    it { should exist }
    its('groups') { should be_in ['mutter','erwachsene','familie','rezepte','finanzen']}
    its('home') { should eq '/home/mutter' }
    its('shell') { should eq '/bin/bash' }
  end
  describe user('tochter') do
    it { should exist }
    its('groups') { should be_in ['tochter', 'familie','kinder']}
    its('home') { should eq '/home/tochter' }
    its('shell') { should eq '/bin/bash' }
  end
  describe user('sohn') do
    it { should exist }
    its('groups') { should be_in ['sohn', 'familie','kinder']}
    its('home') { should eq '/home/sohn' }
    its('shell') { should eq '/bin/sh' }
  end
  describe user('kindermaedchen') do
    it { should exist }
    its('groups') { should be_in ['kindermaedchen', 'erwachsene','rezepte']}
    its('home') { should eq '/home/kindermaedchen' }
    its('shell') { should eq '/bin/sh' }
  end
  describe user('gast') do
    it { should exist }
    its('groups') { should be_in ['gast']}
    its('home') { should eq '/home/gast' }
    its('shell') { should eq '/bin/bash' }
  end
end

control 'Ordner-1.0' do
  impact 0.7
  title 'Sind die Ordner da'
  desc 'Ordner und Rechte'
  describe file('/var/familienfotos') do
    it { should be_directory }
	its('mode') { should cmp '03775' }
	its('owner') { should eq 'root' }
	its('group') { should eq 'familie' }
  end
  describe file('/var/gruselfilme') do
    it { should be_directory }
	its('mode') { should cmp '03770' }
	its('owner') { should eq 'root' }
	its('group') { should eq 'erwachsene' }
  end
  describe file('/var/finanzen') do
    it { should be_directory }
	its('mode') { should cmp '03770' }
	its('owner') { should eq 'root' }
	its('group') { should eq 'finanzen' }
  end
  describe file('/var/kochrezepte') do
    it { should be_directory }
	its('mode') { should cmp '03750' }
	its('owner') { should eq 'mutter' }
	its('group') { should eq 'rezepte' }
  end
  describe file('/var/zeichenfilme') do
    it { should be_directory }
	its('mode') { should cmp '03750' }
	its('owner') { should eq 'kindermaedchen' }
	its('group') { should eq 'kinder' }
  end
end
