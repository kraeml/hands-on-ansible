/usr/bin/ruby2.3 -I/var/lib/gems/2.3.0/gems/rspec-support-3.4.1/lib:/var/lib/gems/2.3.0/gems/rspec-core-3.4.4/lib /var/lib/gems/2.3.0/gems/rspec-core-3.4.4/exe/rspec ./spec/example/default.rb
[33m
### start [example@ctl] (127.0.0.1) serverspec... ###
[m
User "root"
  should exist
  should have uid 0
  should have home directory "/root"

Group "root"
  should have gid 0

Filesystem
  File "/"
    should be mounted

Host "www.google.com"
  should be resolvable
  should be reachable

Finished in 1.4 seconds (files took 1.04 seconds to load)
7 examples, 0 failures

/usr/bin/ruby2.3 -I/var/lib/gems/2.3.0/gems/rspec-support-3.4.1/lib:/var/lib/gems/2.3.0/gems/rspec-core-3.4.4/lib /var/lib/gems/2.3.0/gems/rspec-core-3.4.4/exe/rspec ./spec/example/default.rb
[33m
### start [example@web1] (192.168.60.11) serverspec... ###
[m
User "root"
  should exist
  should have uid 0
  should have home directory "/root"

Group "root"
  should have gid 0

Filesystem
  File "/"
    should be mounted

Host "www.google.com"
  should be resolvable
  should be reachable

Finished in 2 seconds (files took 1.11 seconds to load)
7 examples, 0 failures

/usr/bin/ruby2.3 -I/var/lib/gems/2.3.0/gems/rspec-support-3.4.1/lib:/var/lib/gems/2.3.0/gems/rspec-core-3.4.4/lib /var/lib/gems/2.3.0/gems/rspec-core-3.4.4/exe/rspec ./spec/example/default.rb
[33m
### start [example@web2] (192.168.60.12) serverspec... ###
[m
User "root"
  should exist
  should have uid 0
  should have home directory "/root"

Group "root"
  should have gid 0

Filesystem
  File "/"
    should be mounted

Host "www.google.com"
  should be resolvable
  should be reachable

Finished in 2.01 seconds (files took 1.04 seconds to load)
7 examples, 0 failures

/usr/bin/ruby2.3 -I/var/lib/gems/2.3.0/gems/rspec-support-3.4.1/lib:/var/lib/gems/2.3.0/gems/rspec-core-3.4.4/lib /var/lib/gems/2.3.0/gems/rspec-core-3.4.4/exe/rspec ./spec/example/default.rb
[33m
### start [example@web3] (192.168.60.13) serverspec... ###
[m
User "root"
  should exist
  should have uid 0
  should have home directory "/root"

Group "root"
  should have gid 0

Filesystem
  File "/"
    should be mounted

Host "www.google.com"
  should be resolvable
  should be reachable

Finished in 2.07 seconds (files took 1.05 seconds to load)
7 examples, 0 failures

/usr/bin/ruby2.3 -I/var/lib/gems/2.3.0/gems/rspec-support-3.4.1/lib:/var/lib/gems/2.3.0/gems/rspec-core-3.4.4/lib /var/lib/gems/2.3.0/gems/rspec-core-3.4.4/exe/rspec ./spec/www/default.rb
[33m
### start [www@web1] (192.168.60.11) serverspec... ###
[m
Package "nginx"
  should be installed

Finished in 0.95134 seconds (files took 1.12 seconds to load)
1 example, 0 failures

description,,,,result
example@ctl(127.0.0.1),,,,
,User "root",,,
,,should exist,,OK
,,should have uid 0,,OK
,,should have home directory "/root",,OK
,Group "root",,,
,,should have gid 0,,OK
,Filesystem,,,
,,File "/",,
,,,should be mounted,OK
,Host "www.google.com",,,
,,should be resolvable,,OK
,,should be reachable,,OK
example@web1(192.168.60.11),,,,
,User "root",,,
,,should exist,,OK
,,should have uid 0,,OK
,,should have home directory "/root",,OK
,Group "root",,,
,,should have gid 0,,OK
,Filesystem,,,
,,File "/",,
,,,should be mounted,OK
,Host "www.google.com",,,
,,should be resolvable,,OK
,,should be reachable,,OK
example@web2(192.168.60.12),,,,
,User "root",,,
,,should exist,,OK
,,should have uid 0,,OK
,,should have home directory "/root",,OK
,Group "root",,,
,,should have gid 0,,OK
,Filesystem,,,
,,File "/",,
,,,should be mounted,OK
,Host "www.google.com",,,
,,should be resolvable,,OK
,,should be reachable,,OK
example@web3(192.168.60.13),,,,
,User "root",,,
,,should exist,,OK
,,should have uid 0,,OK
,,should have home directory "/root",,OK
,Group "root",,,
,,should have gid 0,,OK
,Filesystem,,,
,,File "/",,
,,,should be mounted,OK
,Host "www.google.com",,,
,,should be resolvable,,OK
,,should be reachable,,OK
www@web1(192.168.60.11),,,,
,Package "nginx",,,
,,should be installed,,OK
