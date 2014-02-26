FROM johnae/trice-docker-app-base:latest
MAINTAINER John Axel Eriksson <john@insane.se>

ENV DEBIAN_FRONTEND noninteractive

ENV USER app
ENV RBENV_MRI 2.0.0-p451
ENV RBENV_JRUBY jruby-1.7.11

ADD install_ruby.sh /root/install_ruby.sh
RUN chmod +x /root/install_ruby.sh && /root/install_ruby.sh && rm /root/install_ruby.sh # 2013-12-24
