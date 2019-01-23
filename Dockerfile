FROM jrottenberg/ffmpeg

MAINTAINER Sayardiss


ENV SCRIPTDIR="/tmp/scripts/"
ENV INPUTDIR="/tmp/input/"
ENV OUTPUTDIR="/tmp/output/"
ENV TORRENTDIR="/tmp/torrent/"
ENV WORKDIR="/tmp/"

RUN apt update && apt install -y mediainfo mktorrent curl imagemagick && apt clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/tmp/scripts/upload.sh"]
