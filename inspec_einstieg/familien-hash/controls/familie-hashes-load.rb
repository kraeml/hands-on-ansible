# encoding: utf-8
# copyright: 2017, The Authors
require 'yaml'

user_data = YAML.load_file(File.join(__dir__, 'user-data.yml'))
gruppen = user_data['gruppen']

title 'Familiencheck'

users = [
  {
    'login' => 'vater',
    'shell' => '/bin/csh',
    'password' => 'geheim2',
    'gruppen' => [
      gruppen['familie'],
      gruppen['erwachsene'],
      gruppen['finanzen']
    ]
  },
  {
    'login' => 'mutter',
    'shell' => '/bin/bash',
    'password' => 'foo',
    'gruppen' => [
      gruppen['familie'],
      gruppen['erwachsene'],
      gruppen['finanzen'],
      gruppen['rezepte']
    ]
  },
  {
    'login' => 'tochter',
    'shell' => '/bin/bash',
    'password' => 'bar',
    'gruppen' => [
      gruppen['familie'],
      gruppen['kinder']
    ]
  },
  {
    'login' => 'sohn',
    'shell' => '/bin/sh',
    'password' => 'passw0rd',
    'gruppen' => [
      gruppen['familie'],
      gruppen['kinder']
    ]
  },
  {
    'login' => 'kindermaedchen',
    'shell' => '/bin/sh',
    'password' => 'CaHrdf1618',
    'gruppen' => [
      gruppen['erwachsene'],
      gruppen['rezepte']
    ]
  },
  {
    'login' => 'gast',
    'shell' => '/bin/bash',
    'password' => 'gast',
    'gruppen' => []
  }
]

# you add controls here
control 'Benutzer-1.0' do
  impact 1.0
  title 'Test Benutzer'
  desc 'Benutzer sind da'
  users.each do|u|
    describe user(u['login']) do
      it { should exist }
    end
  end
end
control 'Gruppen-1.0' do
  impact 1.0
  title 'Test Gruppen'
  desc 'Gruppen sind da'
  gruppen.each do|key, value|
    describe group(value) do
      it { should exist }
    end
  end
end
