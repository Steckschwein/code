FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install --no-install-recommends -y gcc make libc-dev git python3 python3-pip 
RUN pip install -U --break-system-packages py65 
RUN git clone https://github.com/cc65/cc65.git \
	&& cd cc65 \
	&& git reset --hard V2.19 \
	&& PREFIX=/usr/local/ make TARGETS=none\
	&& PREFIX=/usr/local/ make install \
    	&& apt-get remove -y gcc libc-dev python3-pip \
	&& apt-get autoremove -y

RUN useradd -ms /bin/bash schwein && chown -R schwein:schwein /home/schwein
USER schwein
WORKDIR /home/schwein

