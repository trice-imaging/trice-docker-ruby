#!/bin/bash

cd /usr/local
test -e /usr/local/rbenv || git clone https://github.com/sstephenson/rbenv.git
cat << EOF > /etc/profile.d/rbenv.sh
export PATH="/usr/local/rbenv/bin:\$PATH"
export RBENV_ROOT=/usr/local/rbenv
eval "\$(rbenv init -)"
upgrade_rbenv()
{
        pushd /usr/local/rbenv
        git pull
        popd
        pushd /usr/local/rbenv/plugins/ruby-build
        git pull
        popd
}
EOF

mkdir -p rbenv/plugins
test -e /usr/local/rbenv/plugins/ruby-build || git clone https://github.com/sstephenson/ruby-build.git rbenv/plugins/ruby-build

echo 'export PATH="/usr/local/rbenv/plugins/ruby-build/bin:$PATH"' > /etc/profile.d/ruby-build.sh

cat << EOF > /etc/profile.d/jruby.sh
jruby_client()
{
  export JRUBY_OPTS="--1.9 -J-noverify -Xcompile.invokedynamic=false -J-Dfile.encoding=UTF8 -J-Xms512m -J-Xmx2048m -J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 -J-XX:+UseCompressedOops --server"
}

jruby_server()
{
  export JRUBY_OPTS="--1.9 -J-noverify -Xcompile.invokedynamic=false -J-Dfile.encoding=UTF8 -J-Xms512m -J-Xmx4096m -J-XX:+TieredCompilation -J-XX:+UseCompressedOops --server"
}
EOF

chmod +x /etc/profile.d/ruby-build.sh
chmod +x /etc/profile.d/rbenv.sh
chmod +x /etc/profile.d/jruby.sh

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
cd /
rm -rf /tmp/fuseinstall

add-apt-repository ppa:webupd8team/java -y
apt-get update
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install --force-yes -y -q oracle-java7-installer

source /etc/profile

upgrade_rbenv

test -e /usr/local/rbenv/versions/$RBENV_JRUBY || rbenv install $RBENV_JRUBY
test -e /usr/local/rbenv/versions/$RBENV_MRI || rbenv install $RBENV_MRI

## Regardless of version, these two will always work
ln -s /usr/local/rbenv/versions/$RBENV_JRUBY /usr/local/rbenv/versions/jruby
ln -s /usr/local/rbenv/versions/$RBENV_MRI /usr/local/rbenv/versions/mri

jruby_client
rbenv shell $RBENV_JRUBY
gem install bundler --no-ri --no-rdoc

rbenv shell $RBENV_MRI
gem install bundler --no-ri --no-rdoc

useradd -U $USER

groupadd rbenv

adduser $USER rbenv

chown -R $USER:rbenv /usr/local/rbenv
chmod -R ug+rwx /usr/local/rbenv

## allow passwordless sudo

cat << EOF > /etc/sudoers.d/100-allow-app-user
$USER ALL=(ALL) NOPASSWD:ALL
EOF

chown root:root /etc/sudoers.d/100-allow-app-user
chmod 0440 /etc/sudoers.d/100-allow-app-user
