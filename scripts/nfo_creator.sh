#!/bin/bash

# ---- Utilisation ----
# ./<moi>.sh /album/a/scanner/ .ext artiste album genre annee

FOLDER="$1"
EXTENSION="$2"
ARTIST="$3"
ALBUM="$4"
GENRE="$5"
ANNEE="$6"

FIRST_FILE=$(ls "$FOLDER"/*."$EXTENSION" | head -1)

NFO_FORMAT=$(mediainfo "$FIRST_FILE" | grep -E "Format/Info" | head -n1 | cut -d':' -f 2)
NFO_LIBRARY=$(mediainfo "$FIRST_FILE" | grep -E "Writing" | head -n1 | cut -d':' -f 2)
NFO_DEPTH=$(mediainfo "$FIRST_FILE" | grep -E "Bit depth" | head -n1 | cut -d':' -f 2)
NFO_SAMPLING=$(mediainfo "$FIRST_FILE" | grep -E "Sampling" | head -n1 | cut -d':' -f 2)
NFO_CHANNEL=$(mediainfo "$FIRST_FILE" | grep -E "Channel\(" | head -n1 | cut -d':' -f 2)

if [ "$EXTENSION" = "mp3" ]
then
  NFO_FORMAT=" MPEG Audio Layer 3"
fi


echo "---------------------------------------------------------------------
                   $ARTIST - $ALBUM
---------------------------------------------------------------------


Artiste..........: $ARTIST
Album............: $ALBUM
Genre............: $GENRE
Source...........: CD
Year.............: $ANNEE
Codec............:$NFO_FORMAT
Version..........:$NFO_LIBRARY
Channels.........:$NFO_CHANNEL / $NFO_SAMPLING / $NFO_DEPTH

Posted by........: Krammer

Included.........: NFO


---------------------------------------------------------------------
                       Tracklisting
---------------------------------------------------------------------"

# set -x
# for i in "${FOLDER}"/*.{flac,m4a,mp3}
# # for i in "$FOLDER"/*."$EXTENSION"
# do
#   POSITION=$(mediainfo "$i" | grep -E "Track name/Position" | uniq | cut -d':' -f 2 | cut -d' ' -f 2)
#   NOM=$(mediainfo "$i" | grep -E "(Track name |Movie name )" | uniq | cut -d':' -f 2)
#   DUREE=$(mediainfo "$i" | grep -E "Duration " | uniq | cut -d':' -f 2)
#   echo "$POSITION -$NOM -$DUREE"
# done


for i in "$FOLDER"/*."$EXTENSION"
do
  [ -f "$i" ] || continue
  DUREE=$(ffprobe -i "$i" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal | grep -Po "(?<=^0.)[:\d]*")
  NOM=$(ffprobe -i "$i" -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1)
  POSITION=$(ffprobe -i "$i" -loglevel error -show_entries format_tags=track -of default=noprint_wrappers=1:nokey=1)
  echo "$POSITION - $NOM [$DUREE]"
done





SIZE=$(du -shm "$FOLDER" | cut -f1)
echo
echo "Total size.......: $SIZE Mo"
