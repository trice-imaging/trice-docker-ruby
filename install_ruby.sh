#!/bin/bash

source /etc/profile

upgrade_rbenv

test -e /usr/local/rbenv/versions/$RBENV_JRUBY || rbenv install $RBENV_JRUBY
test -e /usr/local/rbenv/versions/$RBENV_MRI || rbenv install $RBENV_MRI

jruby_client
rbenv shell $RBENV_JRUBY
gem install bundler --no-ri --no-rdoc

rbenv shell $RBENV_MRI
gem install bundler --no-ri --no-rdoc
