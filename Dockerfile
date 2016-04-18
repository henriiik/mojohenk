FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    cpanminus \ 
    libdbd-mysql-perl \
    locales \
    perl


RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN cpanm -v \
    Mojolicious \
    Mojo::mysql

CMD ["/usr/local/bin/morbo", "/var/data/src/hello.pl"]  