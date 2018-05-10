#!/bin/bash

# Toutes les variables doivent être exportées pour être passées en tant que var d'environnement

PROFILELINK="https://www.t411.li/users/torrents/?id=98179255"
LINK_SIGNATURE="https://s25.postimg.org/ge85a664v/T411Signature.png"
LINK_DESCRIPTIF2="https://s25.postimg.org/gkh8zipvz/Descriptif2.png"
LINK_INFORMATION2="https://s25.postimg.org/oh6blhqq7/Information_2.png"
LINK_DETAILUPLOAD="https://s25.postimg.org/ypu7dkpe7/Details_upload.png"
LINK_UPLOADERS="https://s25.postimg.org/6zrlp8jv3/Uploaders.jpg"


TXT_AAC="$ARTISTE - $ALBUM ($DATE - AAC 256Kbps).txt"
TXT_MP3="$ARTISTE - $ALBUM ($DATE - MP3 320Kbps).txt"
TXT_FLAC="$ARTISTE - $ALBUM ($DATE - FLAC).txt"


# Récupérer la taille des dossiers, pour la présentation
SIZE_AAC=$(du -sm "$DOSSIER_AAC" | awk '{print $1;}')
SIZE_MP3=$(du -sm "$DOSSIER_MP3" | awk '{print $1;}')
SIZE_FLAC=$(du -sm "$DOSSIER_FLAC" | awk '{print $1;}')



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


echo "

[url=$PROFILELINK]Allez faire un tour sur mes autres uploads ![/url]
[url=$PROFILELINK][img width=300]$LINK_SIGNATURE[/img][/url]

[url=$PROFILELINK][img width=500]$LINK_UPLOADERS[/img][/url]


[/center]" > fin_prez.tmp

cat fin_prez.tmp >> "$TXT_AAC"
cat fin_prez.tmp >> "$TXT_MP3"
cat fin_prez.tmp >> "$TXT_FLAC"
rm fin_prez.tmp
