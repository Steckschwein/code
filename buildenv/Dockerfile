FROM debian:stretch-slim
USER root
RUN apt-get update && apt-get -y install build-essential git python3 python3-pip subversion
RUN pip3 install -U py65
RUN svn checkout https://svn.code.sf.net/p/acme-crossass/code-0/trunk acme \
	&& cd acme/src \
	&& make \
	&& make install
RUN git clone https://github.com/cc65/cc65.git \
	&& cd cc65 \
 	&& git reset --hard V2.17 \	# 8e759067 => V2.17
	&& PREFIX=/usr/local/ make  TARGETS=none\
	&& PREFIX=/usr/local/ make install

