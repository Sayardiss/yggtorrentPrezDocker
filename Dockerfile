FROM jrottenberg/ffmpeg

MAINTAINER Sayardiss


ENV SCRIPTDIR="/tmp/scripts/"
ENV INPUTDIR="/tmp/input/"
ENV OUTPUTDIR="/tmp/output/"
ENV WORKDIR="/tmp/"

ENTRYPOINT ["/tmp/scripts/upload.sh"]


RUN apt update && apt install -y mediainfo mktorrent curl imagemagick && apt clean && rm -rf /var/lib/apt/lists/*
