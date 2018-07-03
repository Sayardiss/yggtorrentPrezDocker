#!/bin/bash

# Toutes les variables doivent être exportées pour être passées en tant que var d'environnement
PROFILELINK='/profile/486880-krammer'
LINK_SIGNATURE='http://i.imgur.com/yJI4wGK.png'
LINK_DESCRIPTIONALBUM='http://i.imgur.com/uE43iGX.png'
LINK_INFOALBUM='http://i.imgur.com/b2JoXyR.png'
LINK_DETAILUPLOAD='http://i.imgur.com/EXSNz8J.png'

# Nom des fichiers contenant le BBCode (sert aussi pour le titre de l'upload)
TXT_AAC="$ARTISTE - $ALBUM ($DATE) [AAC 256 kbps].txt"
TXT_MP3="$ARTISTE - $ALBUM ($DATE) [MP3 320 kbps].txt"
TXT_FLAC="$ARTISTE - $ALBUM ($DATE) [FLAC 16 bit - 44.1 kHz].txt"
TXT_ALAC="$ARTISTE - $ALBUM ($DATE) [ALAC 16 bit - 44.1 kHz].txt"



# Récupérer la taille des dossiers, pour la présentation
SIZE_AAC=$(du -sm "$DOSSIER_AAC" | awk '{print $1;}')
SIZE_MP3=$(du -sm "$DOSSIER_MP3" | awk '{print $1;}')
SIZE_FLAC=$(du -sm "$DOSSIER_FLAC" | awk '{print $1;}')
SIZE_ALAC=$(du -sm "$DOSSIER_ALAC" | awk '{print $1;}')

# N'afficher la bannière de description album que s'il y a une description de l'album ou de l'artiste (variable $PARTIE_DESCRIPTION)
if [[ -n "$DESCRIPTION_ALBUM" || -n "$DESCRIPTION_ARTISTE" ]]; then
  PARTIE_DESCRIPTION=$(cat <<-END


[url=$PROFILELINK][img]$LINK_DESCRIPTIONALBUM[/img][/url]

$DESCRIPTION_ALBUM

$DESCRIPTION_ARTISTE
END
)
fi

# Générer la première partie commune
echo "[center]
[url=$PROFILELINK][img]$LINK_SIGNATURE[/img][/url]

[b][color=#6c6d6f][size=200].·[ [color=#37abb5]$ARTISTE[/color] $ALBUM ]·.[/size][/color][/b]

[img]$LINKCOVER[/img]

$PARTIE_DESCRIPTION


[url=$PROFILELINK][img]$LINK_INFOALBUM[/img][/url]


[b]Artiste de l'album :[/b] $ARTISTE
[b]Nombre de disques :[/b] $NB_DISQUES
[b]Genre :[/b] $GENRE
[b]Date de sortie :[/b] $DATE


[url=$PROFILELINK][img]$LINK_DETAILUPLOAD[/img][/url]

[b][u]Liste des fichiers[/u][/b]

" > debut_prez.tmp


# Récupérer la durée
shopt -s nullglob
for i in "$DOSSIER_AAC"/*.{flac,m4a,mp3}
do
  DUREE=$(ffprobe -i "$i" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal | grep -Po "(?<=^0.)[:\d]*")
  NOM=$(ffprobe -i "$i" -loglevel error -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1)
  POSITION=$(ffprobe -i "$i" -loglevel error -show_entries format_tags=track -of default=noprint_wrappers=1:nokey=1)
  echo "$POSITION - $NOM [$DUREE]" >> debut_prez.tmp
done
shopt -u nullglob

echo >> debut_prez.tmp


cp debut_prez.tmp "$TXT_AAC"
cp debut_prez.tmp "$TXT_MP3"
cp debut_prez.tmp "$TXT_ALAC"
mv debut_prez.tmp "$TXT_FLAC"


# Description pour AAC 256 Kbps
echo "[b]Format : [/b] AAC 256 Kbps
[b]Taille des fichiers :[/b] $SIZE_AAC Mo" >> "$TXT_AAC"


# Description pour MP3 v0 Kbps
echo "[b]Format : [/b] MP3 320 Kbps
[b]Taille des fichiers :[/b] $SIZE_MP3 Mo" >> "$TXT_MP3"


# Description pour FLAC
echo "[b]Format : [/b] FLAC 16 Bits / 44,100 Hz - Lossless
[b]Taille des fichiers :[/b] $SIZE_FLAC Mo" >> "$TXT_FLAC"


# Description pour ALAC
echo "[b]Format : [/b] ALAC 16 Bits / 44,100 Hz - Apple Lossless (natif iTunes)
[b]Taille des fichiers :[/b] $SIZE_ALAC Mo" >> "$TXT_ALAC"

# Signature de fin
echo "

[url=$PROFILELINK]Allez faire un tour sur mes autres uploads ![/url]
[url=$PROFILELINK][img]$LINK_SIGNATURE[/img][/url]


[/center]" > fin_prez.tmp

cat fin_prez.tmp >> "$TXT_AAC"
cat fin_prez.tmp >> "$TXT_MP3"
cat fin_prez.tmp >> "$TXT_FLAC"
cat fin_prez.tmp >> "$TXT_ALAC"
rm fin_prez.tmp
