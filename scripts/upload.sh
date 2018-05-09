#!/bin/bash

set -x
shopt -s globstar
NFO_SH="$SCRIPTDIR/nfo_creator.sh"

# Trouver automatiquement le dossier à scanner
DOSSIER_SOURCE=`find ${INPUTDIR}* -maxdepth 1 -type d -print -quit`

# Exit si pas de dossier source
if [ -z "$DOSSIER_SOURCE" ]; then exit; fi

# Liste des options pour les différents formats
  ARG_MP3_320="-map_metadata 0 -id3v2_version 3 -c:a libmp3lame -b:a 320k"
  ARG_AAC_256="-map_metadata 0 -id3v2_version 3 -c:a libfdk_aac -vbr 5"
  ARG_FLAC="-map_metadata 0 -id3v2_version 3 -acodec flac"


############### FONCTIONS ###############

ExtractFilename() {
  # Extraire le nom du fichier <path> en paramètre
  file="$1"
  filename="${file##*/}"      # Retirer les dossiers (avant le dernier /)
  filename="${filename%.*}"   # Retirer l'extension (après le dernier .)
  echo "$filename"
}

ConvertMP3320() {
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.m4a
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_MP3_320 "$DEST"/"$filename.mp3"   # Conversion en MP3 v0
  done
}

ConvertAAC256() {
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.m4a
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_AAC_256 "$DEST"/"$filename.m4a"   # Conversion en AAC
  done
}

ConvertFLAC() {
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.m4a
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_FLAC "$DEST"/"$filename.flac"   # Conversion en FLAC
  done
}




############### FIN FONCTIONS ###############


# Saisie des informations sur l'upload (avec récuperation par défaut)
  FILE=`find "$DOSSIER_SOURCE" -type f -print -quit`
  echo "$FILE a été selectionné pour la saisie facilitée"

  ARTISTE=`mediainfo --Inform="General;%Performer%" "$FILE"`
  read -e -p "Artiste > " -i "$ARTISTE" ARTISTE

  ALBUM=`mediainfo --Inform="General;%Album%" "$FILE"`
  read -e -p "Album > " -i "$ALBUM" ALBUM

  DATE=`mediainfo "$FILE" | grep 'Recorded date' | cut -d: -f2 | tr -d '[:space:]'`
  read -e -p "Année > " -i "$DATE" DATE
  read -e -p "Nombre de disques > " -i "1" NB_DISQUES

  GENRE=`mediainfo --Inform="General;%Genre%" "$FILE"`
  read -e -p "Genre > " -i "$GENRE" GENRE

  ffmpeg -n -i "$FILE" "$OUTPUTDIR/cover.jpg" && $LINKCOVER=`$SCRIPTDIR/imgur.sh` || echo "L'extraction et/ou l'envoi automatique de la cover a échoué..."
  read -e -p "Lien cover > " -i "$LINKCOVER" LINKCOVER

  echo -n "Description de l'album (finir par \$) > "
  read -d '$' DESCRIPTION_ALBUM
  echo -n "Description de l'artiste (finir par \$) > "
  read -d '$' DESCRIPTION_ARTISTE

# Création du dossier principal
  DOSSIER_PRINCIPAL="${OUTPUTDIR}/$ARTISTE - $ALBUM"
  mkdir -p "$DOSSIER_PRINCIPAL"
  cd "$DOSSIER_PRINCIPAL"

# Création des dossiers respectifs
  DOSSIER_AAC="$ARTISTE - $ALBUM ($DATE - AAC 256)"
  mkdir "$DOSSIER_AAC"

  DOSSIER_MP3="$ARTISTE - $ALBUM ($DATE - MP3 320)"
  mkdir "$DOSSIER_MP3"

  DOSSIER_FLAC="$ARTISTE - $ALBUM ($DATE - FLAC)"
  mkdir "$DOSSIER_FLAC"

# Pour chaque fichier .m4a dans le dossier source
ConvertMP320 "$DOSSIER_SOURCE" "$DOSSIER_MP3"
ConvertAAC256 "$DOSSIER_SOURCE" "$DOSSIER_AAC"
ConvertFLAC "$DOSSIER_SOURCE" "$DOSSIER_FLAC"


# Utilisation du script NFO
# ./<moi>.sh /album/a/scanner/ .ext artiste album genre annee
sh "$NFO_SH" "$DOSSIER_AAC" 'm4a' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_AAC"/mediainfo.nfo
sh "$NFO_SH" "$DOSSIER_MP3" 'mp3' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_MP3"/mediainfo.nfo
sh "$NFO_SH" "$DOSSIER_FLAC" 'flac' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_FLAC"/mediainfo.nfo


# Copie du NFO plus facile d'accès
cp "$DOSSIER_AAC"/mediainfo.nfo NFO_"$ALBUM"_AAC.nfo
cp "$DOSSIER_MP3"/mediainfo.nfo NFO_"$ALBUM"_MP3.nfo
cp "$DOSSIER_FLAC"/mediainfo.nfo NFO_"$ALBUM"_FLAC.nfo

# Copier la cover dans chaque dossier
cp "$OUTPUTDIR"/cover.jpg "$DOSSIER_AAC"/cover.jpg
cp "$OUTPUTDIR"/cover.jpg "$DOSSIER_MP3"/cover.jpg
mv "$OUTPUTDIR"/cover.jpg "$DOSSIER_FLAC"/cover.jpg


# Création du fichier torrent
# TODO
#  mktorrent -v -p -a http://t411.download -o "$DOSSIER_AAC.torrent" "$DOSSIER_AAC"
#  mktorrent -v -p -a http://t411.download -o "$DOSSIER_MP3.torrent" "$DOSSIER_MP3"
#  mktorrent -v -p -a http://t411.download -o "$DOSSIER_FLAC.torrent" "$DOSSIER_FLAC"


# Récupérer la taille des dossiers, pour la présentation
SIZE_AAC=$(du -sm "$DOSSIER_AAC" | awk '{print $1;}')
SIZE_MP3=$(du -sm "$DOSSIER_MP3" | awk '{print $1;}')
SIZE_FLAC=$(du -sm "$DOSSIER_FLAC" | awk '{print $1;}')

# Création des fichiers de présentation
PROFILELINK="https://www.t411.li/users/torrents/?id=98179255"
LINK_SIGNATURE="https://s25.postimg.org/ge85a664v/T411Signature.png"
LINK_DESCRIPTIF2="https://s25.postimg.org/gkh8zipvz/Descriptif2.png"
LINK_INFORMATION2="https://s25.postimg.org/oh6blhqq7/Information_2.png"
LINK_DETAILUPLOAD="https://s25.postimg.org/ypu7dkpe7/Details_upload.png"
LINK_UPLOADERS="https://s25.postimg.org/6zrlp8jv3/Uploaders.jpg"


echo "[center]
[url=$PROFILELINK][img width=500]$LINK_SIGNATURE[/img][/url]

[b][color=#0FBCA9][size=7].·[ [color=#ff9204]$ARTISTE[/color] $ALBUM ]·.[/size][/color][/b]

[img width=500]$COVER[/img]




[url=$PROFILELINK][img width=400]$LINK_DESCRIPTIF2[/img][/url]

$DESCRIPTION_ALBUM

$DESCRIPTION_ARTISTE

[url=$PROFILELINK][img width=400]$LINK_INFORMATION2[/img][/url]


[b]Artiste de l'album :[/b] $ARTISTE
[b]Nombre de disques :[/b] $NB_DISQUES
[b]Genre :[/b] $GENRE
[b]Date de sortie :[/b] $DATE


[url=$PROFILELINK][img width=400]$LINK_DETAILUPLOAD[/img][/url]

" > debut_prez.tmp
cp debut_prez.tmp "$ARTISTE - $ALBUM ($DATE - AAC 256Kbps).txt"
cp debut_prez.tmp "$ARTISTE - $ALBUM ($DATE - MP3 320Kbps).txt"
mv debut_prez.tmp "$ARTISTE - $ALBUM ($DATE - FLAC).txt"


# Description pour AAC 256 Kbps
echo "[b]Format : [/b] AAC 256 Kbps
[b]Taille des fichiers :[/b] $SIZE_AAC Mo" >> "$ARTISTE - $ALBUM ($DATE - AAC 256Kbps).txt"


# Description pour MP3 v0 Kbps
echo "[b]Format : [/b] MP3 320 Kbps
[b]Taille des fichiers :[/b] $SIZE_MP3 Mo" >> "$ARTISTE - $ALBUM ($DATE - MP3 320Kbps).txt"


# Description pour FLAC
echo "[b]Format : [/b] FLAC - Lossless
[b]Taille des fichiers :[/b] $SIZE_FLAC Mo" >> "$ARTISTE - $ALBUM ($DATE - FLAC).txt"


echo "

[url=$PROFILELINK]Allez faire un tour sur mes autres uploads ![/url]
[url=$PROFILELINK][img width=300]$LINK_SIGNATURE[/img][/url]

[url=$PROFILELINK][img width=500]$LINK_UPLOADERS[/img][/url]


[/center]" > fin_prez.tmp

cat fin_prez.tmp >> "$ARTISTE - $ALBUM ($DATE - AAC 256Kbps).txt"
cat fin_prez.tmp >> "$ARTISTE - $ALBUM ($DATE - MP3 320Kbps).txt"
cat fin_prez.tmp >> "$ARTISTE - $ALBUM ($DATE - FLAC).txt"
rm fin_prez.tmp



# Partie avec les arguments

while test $# -gt 0; do
        case "$1" in
				# Afficher l'aide : -h
                -h|--help)
                        echo "-s (comme seedbox) pour copier les dossiers dans la seedbox, et ajouter le torrent"
                        echo "-d (comme deluge) pour faire la même chose sur Deluge"
                        echo "-D (comme Delete) pour supprimer ensuite (gvfs-trash)"
                        exit 0
                        ;;
				# Ajouter le torrent sur la seedbox (avec lien dans le home)
                -s)
                        shift
                          cp -rv "$DOSSIER_AAC" "$DOSSIER_MP3" "$DOSSIER_FLAC" ~/Seedbox/torrents/
                          cp "$DOSSIER_AAC.torrent" "$DOSSIER_MP3.torrent" "$DOSSIER_FLAC.torrent" ~/Seedbox/watch/
                        ;;
				# Ajouter le torrent à Deluge
                -d)
                        shift
                          cp -rv "$DOSSIER_AAC" "$DOSSIER_MP3" "$DOSSIER_FLAC" /media/barthelemy/HDD_Programmes/Torrent/
                          cp "$DOSSIER_AAC.torrent" "$DOSSIER_MP3.torrent" "$DOSSIER_FLAC.torrent" /media/barthelemy/HDD_Programmes/Torrent/--watch--
                        ;;
				# Supprimer ensuite les dossiers temporaires
                -D)
                        shift
                          gvfs-trash "$DOSSIER_AAC" "$DOSSIER_MP3" "$DOSSIER_FLAC"
                        ;;
                *)
                        shift
                        ;;
        esac
done
