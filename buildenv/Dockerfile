FROM debian:buster-slim
RUN apt-get update \
    && apt-get install --no-install-recommends -y gcc make libc-dev git python3 python3-pip \
    && pip3 install -U py65
    && git clone https://github.com/cc65/cc65.git \
	&& cd cc65 \
 	&& git reset --hard V2.19 \
	&& PREFIX=/usr/local/ make TARGETS=none\
	&& PREFIX=/usr/local/ make install \
    && apt-get remove -y gcc libc-dev python3-pip

RUN useradd -ms /bin/bash schwein
USER schwein
WORKDIR /home/schwein

