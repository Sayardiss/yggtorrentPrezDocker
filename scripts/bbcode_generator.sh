#!/bin/bash

# Toutes les variables doivent être exportées pour être passées en tant que var d'environnement
PROFILELINK="/profile/486880-krammer"
LINK_SIGNATURE="https://i.imgur.com/yJI4wGK.png"
LINK_DESCRIPTIONALBUM="https://i.imgur.com/uE43iGX.png"
LINK_INFOALBUM="https://i.imgur.com/b2JoXyR.png"
LINK_DETAILUPLOAD="https://i.imgur.com/EXSNz8J.png"

# Nom des fichiers contenant le BBCode (sert aussi pour le titre de l'upload)
TXT_AAC="$ARTISTE - $ALBUM ($DATE - AAC 256Kbps).txt"
TXT_MP3="$ARTISTE - $ALBUM ($DATE - MP3 320Kbps).txt"
TXT_FLAC="$ARTISTE - $ALBUM ($DATE - FLAC).txt"


# Récupérer la taille des dossiers, pour la présentation
SIZE_AAC=$(du -sm "$DOSSIER_AAC" | awk '{print $1;}')
SIZE_MP3=$(du -sm "$DOSSIER_MP3" | awk '{print $1;}')
SIZE_FLAC=$(du -sm "$DOSSIER_FLAC" | awk '{print $1;}')

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

" > debut_prez.tmp
cp debut_prez.tmp "$TXT_AAC"
cp debut_prez.tmp "$TXT_MP3"
mv debut_prez.tmp "$TXT_FLAC"


# Description pour AAC 256 Kbps
echo "[b]Format : [/b] AAC 256 Kbps
[b]Taille des fichiers :[/b] $SIZE_AAC Mo" >> "$TXT_AAC"


# Description pour MP3 v0 Kbps
echo "[b]Format : [/b] MP3 320 Kbps
[b]Taille des fichiers :[/b] $SIZE_MP3 Mo" >> "$TXT_MP3"


# Description pour FLAC
echo "[b]Format : [/b] FLAC - Lossless
[b]Taille des fichiers :[/b] $SIZE_FLAC Mo" >> "$TXT_FLAC"


# Signature de fin
echo "

[url=$PROFILELINK]Allez faire un tour sur mes autres uploads ![/url]
[url=$PROFILELINK][img]$LINK_SIGNATURE[/img][/url]


[/center]" > fin_prez.tmp

cat fin_prez.tmp >> "$TXT_AAC"
cat fin_prez.tmp >> "$TXT_MP3"
cat fin_prez.tmp >> "$TXT_FLAC"
rm fin_prez.tmp
