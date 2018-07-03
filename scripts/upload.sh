#!/bin/bash

set -a # Activer l'exportation des variables
# set -x
shopt -s globstar
NFO_SH="$SCRIPTDIR/nfo_creator.sh"
SECRETSFILE="$SCRIPTDIR/secrets.key"

# Trouver automatiquement le dossier à scanner
DOSSIER_SOURCE=`find ${INPUTDIR}* -maxdepth 1 -type d -print -quit`
echo "Je détecte le dossier $DOSSIER_SOURCE"

# Exit si pas de dossier source
if [ -z "$DOSSIER_SOURCE" ]; then exit; fi

# Liste des options pour les différents formats
  ARG_MP3_320="-map_metadata 0 -id3v2_version 3 -c:a libmp3lame -b:a 320k"
  ARG_AAC_256="-map_metadata 0 -id3v2_version 3 -c:a libfdk_aac -vbr 5"
  ARG_FLAC="-map_metadata 0 -id3v2_version 3 -acodec flac"
  ARG_ALAC="-map_metadata 0 -id3v2_version 3 -acodec alac"


############### FONCTIONS ###############

ExtractFilename() {
  # Extraire le nom du fichier <path> en paramètre
  file="$1"
  filename="${file##*/}"      # Retirer les dossiers (avant le dernier /)
  filename="${filename%.*}"   # Retirer l'extension (après le dernier .)
  echo "$filename"
}

ConvertMP3320() {
  echo "Conversion au format MP3"
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.{m4a,flac}
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_MP3_320 "$DEST"/"$filename.mp3"   # Conversion en MP3 v0
  done
}

ConvertAAC256() {
  echo "Conversion au format AAC"
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.{m4a,flac,mp3}
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_AAC_256 "$DEST"/"$filename.m4a"   # Conversion en AAC
  done
}

ConvertFLAC() {
  echo "Conversion au format FLAC"
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.{m4a,flac}
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_FLAC "$DEST"/"$filename.flac"   # Conversion en FLAC
  done
}

ConvertALAC() {
  echo "Conversion au format ALAC"
  SRC="$1"
  DEST="$2"
  shopt -s globstar
  for file in "$SRC"/**/*.{m4a,flac}
  do
    filename=$( ExtractFilename "$file" )
    ffmpeg -i "$file" $ARG_ALAC "$DEST"/"$filename.m4a"   # Conversion en ALAC
  done
}




############### FIN FONCTIONS ###############


# Saisie des informations sur l'upload (avec récuperation par défaut)
  FIN_SAISIE='$'

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

  COVERPATH="$OUTPUTDIR/cover.jpg"
  ffmpeg -y -i "$FILE" "$COVERPATH" && mogrify -resize 500 "$COVERPATH" && echo "Upload vers imgur..." && LINKCOVER=`$SCRIPTDIR/imgur.sh "$COVERPATH"` || echo "L'extraction et/ou l'envoi automatique de la cover a échoué..."
  read -e -p "Lien cover > " -i "$LINKCOVER" LINKCOVER

  echo -n "Description de l'album (finir par $FIN_SAISIE) > "
  read -d "$FIN_SAISIE" DESCRIPTION_ALBUM
  echo -n "Description de l'artiste (finir par $FIN_SAISIE) > "
  read -d "$FIN_SAISIE" DESCRIPTION_ARTISTE

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

  DOSSIER_ALAC="$ARTISTE - $ALBUM ($DATE - ALAC)"
  mkdir "$DOSSIER_ALAC"

# Pour chaque fichier .m4a dans le dossier source
ConvertMP3320 "$DOSSIER_SOURCE" "$DOSSIER_MP3"
ConvertAAC256 "$DOSSIER_SOURCE" "$DOSSIER_AAC"
ConvertFLAC "$DOSSIER_SOURCE" "$DOSSIER_FLAC"
ConvertALAC "$DOSSIER_SOURCE" "$DOSSIER_ALAC"


# Utilisation du script NFO
# ./<moi>.sh /album/a/scanner/ .ext artiste album genre annee
echo "Génération des fichiers .nfo"
sh "$NFO_SH" "$DOSSIER_PRINCIPAL/$DOSSIER_AAC" 'm4a' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_AAC"/mediainfo.nfo
sh "$NFO_SH" "$DOSSIER_PRINCIPAL/$DOSSIER_MP3" 'mp3' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_MP3"/mediainfo.nfo
sh "$NFO_SH" "$DOSSIER_PRINCIPAL/$DOSSIER_FLAC" 'flac' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_FLAC"/mediainfo.nfo
sh "$NFO_SH" "$DOSSIER_PRINCIPAL/$DOSSIER_ALAC" 'm4a' "$ARTISTE" "$ALBUM" "$GENRE" "$DATE" >> "$DOSSIER_ALAC"/mediainfo.nfo


# Copie du NFO plus facile d'accès
cp "$DOSSIER_AAC"/mediainfo.nfo NFO_"$ALBUM"_AAC.nfo
cp "$DOSSIER_MP3"/mediainfo.nfo NFO_"$ALBUM"_MP3.nfo
cp "$DOSSIER_FLAC"/mediainfo.nfo NFO_"$ALBUM"_FLAC.nfo
cp "$DOSSIER_ALAC"/mediainfo.nfo NFO_"$ALBUM"_ALAC.nfo

# Copier la cover dans chaque dossier
if [ -f "$COVERPATH" ]; then
  cp "$COVERPATH" "$DOSSIER_AAC"/cover.jpg
  cp "$COVERPATH" "$DOSSIER_MP3"/cover.jpg
  cp "$COVERPATH" "$DOSSIER_FLAC"/cover.jpg
  mv "$COVERPATH" "$DOSSIER_ALAC"/cover.jpg
fi

# Création du fichier torrent
  TRACKER="http://tracker.ygg.is:8080/$(grep passkey $SECRETSFILE | cut -d: -f2 | grep -Eo '[[:alnum:]]+')/announce"
  echo "Création du fichier .torrent en utilisant l'adresse '$TRACKER'"
  mktorrent -v -p -a "$TRACKER" -o "$DOSSIER_AAC.torrent" "$DOSSIER_AAC"
  mktorrent -v -p -a "$TRACKER" -o "$DOSSIER_MP3.torrent" "$DOSSIER_MP3"
  mktorrent -v -p -a "$TRACKER" -o "$DOSSIER_FLAC.torrent" "$DOSSIER_FLAC"
  mktorrent -v -p -a "$TRACKER" -o "$DOSSIER_ALAC.torrent" "$DOSSIER_ALAC"


# Création des fichiers de présentation BBCode
${SCRIPTDIR}/bbcode_generator.sh



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
                        if [ -d "$TORRENTDIR" ]; then
                          PART1=`dirname "$DOSSIER_SOURCE"`
                          PART2=`basename "$DOSSIER_SOURCE"`
                          mv "$DOSSIER_SOURCE" "$PART1/.$PART2"
                          mv "$DOSSIER_AAC" "$DOSSIER_MP3" "$DOSSIER_FLAC" "$DOSSIER_ALAC" "$TORRENTDIR"
                          cp "$DOSSIER_AAC.torrent" "$DOSSIER_MP3.torrent" "$DOSSIER_FLAC.torrent" "$DOSSIER_ALAC.torrent" "$TORRENTDIR"/--watch--
                        fi
                        ;;
				# Supprimer ensuite les dossiers temporaires
                -D)
                        shift
                          gvfs-trash "$DOSSIER_AAC" "$DOSSIER_MP3" "$DOSSIER_FLAC" "$DOSSIER_ALAC"
                        ;;
                *)
                        shift
                        ;;
        esac
done
