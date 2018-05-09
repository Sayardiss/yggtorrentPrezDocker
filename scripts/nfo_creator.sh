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

NFO_FORMAT=$(mediainfo "$FIRST_FILE" | grep -E "Format/Info" | uniq | cut -d':' -f 2)
NFO_LIBRARY=$(mediainfo "$FIRST_FILE" | grep -E "Writing" | uniq | cut -d':' -f 2)
NFO_DEPTH=$(mediainfo "$FIRST_FILE" | grep -E "Bit depth" | uniq | cut -d':' -f 2)
NFO_SAMPLING=$(mediainfo "$FIRST_FILE" | grep -E "Sampling" | uniq | cut -d':' -f 2)
NFO_CHANNEL=$(mediainfo "$FIRST_FILE" | grep -E "Channel\(" | uniq | cut -d':' -f 2)

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
Information......: nc

Ripped by........: nc
Posted by........: Krammer

Included.........: NFO"





#mediainfo "$i" | grep -E "Track name/Position|Track name |Duration" | sort | uniq | cut -d':' -f 2
echo
echo "---------------------------------------------------------------------
                       Tracklisting
---------------------------------------------------------------------"


for i in "$FOLDER"/*."$EXTENSION"
do
  POSITION=$(mediainfo "$i" | grep -E "Track name/Position" | uniq | cut -d':' -f 2 | cut -d' ' -f 2)
  NOM=$(mediainfo "$i" | grep -E "(Track name |Movie name )" | uniq | cut -d':' -f 2)
  DUREE=$(mediainfo "$i" | grep -E "Duration " | uniq | cut -d':' -f 2)
  echo "$POSITION -$NOM -$DUREE"
done


SIZE=$(du -shm "$FOLDER" | cut -f1)
echo
echo "Total size.......: $SIZE Mo"
