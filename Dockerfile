FROM johnae/trice-docker-base
MAINTAINER John Axel Eriksson <john@insane.se>

ENV DEBIAN_FRONTEND noninteractive

ENV RBENV_MRI 2.0.0-p247
ENV RBENV_JRUBY jruby-1.7.9

ADD install_ruby.sh /root/install_ruby.sh
RUN chmod +x /root/install_ruby.sh && /root/install_ruby.sh && rm /root/install_ruby.sh # 2013-12-24
