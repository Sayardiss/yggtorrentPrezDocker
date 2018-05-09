FROM jrottenberg/ffmpeg

MAINTAINER Sayardiss

ADD ./scripts/nfo_creator.sh /usr/local/bin/nfo_creator.sh
ADD ./scripts/upload.sh /usr/local/bin/upload.sh

ENV SCRIPTDIR="/tmp/scripts/"
ENV INPUTDIR="/tmp/input/"
ENV OUTPUTDIR="/tmp/output/"
ENV WORKDIR="/tmp/"

ENV PATH="/tmp/script/:${PATH}"


RUN apt install -y mediainfo # python3 python3-taglib

# ENTRYPOINT ["/bin/sh","/tmp/script/presentation.sh"]
ENTRYPOINT ["/tmp/scripts/upload.sh"]
