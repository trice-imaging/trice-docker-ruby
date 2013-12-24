#!/bin/bash

# Fake a fuse install - for java install
apt-get install --force-yes -y -q adduser libfuse2
mkdir -p /tmp/fuseinstall
cd /tmp/fuseinstall ; apt-get download fuse
cd /tmp/fuseinstall ; dpkg-deb -x fuse_* .
cd /tmp/fuseinstall ; dpkg-deb -e fuse_*
cd /tmp/fuseinstall ; rm fuse_*.deb
cd /tmp/fuseinstall ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
cd /tmp/fuseinstall ; dpkg-deb -b . /fuse.deb
cd /tmp/fuseinstall ; dpkg -i /fuse.deb

rm -rf /tmp/fuseinstall

add-apt-repository ppa:webupd8team/java -y
apt-get update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install --force-yes -y -q oracle-java7-installer

source /etc/profile

upgrade_rbenv

test -e /usr/local/rbenv/versions/$RBENV_JRUBY || rbenv install $RBENV_JRUBY
test -e /usr/local/rbenv/versions/$RBENV_MRI || rbenv install $RBENV_MRI

jruby_client
rbenv shell $RBENV_JRUBY
gem install bundler --no-ri --no-rdoc

rbenv shell $RBENV_MRI
gem install bundler --no-ri --no-rdoc
