# encoding: utf-8
# copyright: 2017, The Authors

title 'sample section'

gruppen = [ 'familie', 'erwachsene', 'finanzen', 'rezepte', 'kinder' ]
benutzer = [ 'vater', 'mutter', 'tochter', 'sohn', 'kindermaedchen', 'gast' ]
verzeichnisse = [ 'familienfotos', 'gruselfilme', 'finanzen', 'kochrezepte', 'zeichenfilme' ]

control 'Verzeichnisse-1.0' do
  impact 1.0
  title 'Test Verzeichnisse'
  desc 'Verzeichnisse einfache Anwesenheit'
  verzeichnisse.each do|v|
    describe file('/var/'+v) do
      it { should be_directory }
    end
  end
end

control 'Benutzer-1.0' do
  impact 1.0
  title 'Test Gruppen'
  desc 'Benutzer sind da'
  benutzer.each do|b|
    describe user(b) do
      it { should exist }
    end
  end
end

control 'Gruppen-1.0' do
  impact 1.0
  title 'Test Gruppen'
  desc 'Gruppen sind da'
  gruppen.each do|g|
    describe group(g) do
      it { should exist }
    end
  end
end

control 'Verzeichnisse-2.0' do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title 'Test /var/finanzen is directory'             # A human-readable title
  desc 'An optional description...'
  describe file('/var/finanzen') do                  # The actual test
    it { should be_directory }
    its('mode') { should cmp '03770' }
    its('owner') { should eq 'root' }
    it { should be_grouped_into 'finanzen' }
  end
  describe file('/var/kochrezepte') do                  # The actual test
    it { should be_directory }
    its('mode') { should cmp '03750' }
    its('owner') { should eq 'mutter' }
    it { should be_grouped_into 'rezepte' }
  end
end
