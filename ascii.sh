#!/bin/bash

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#get bitrate
bitRate=$(avprobe $1 2>&1 | grep bitrate | cut -d ':' -f 6 | sed s/"kb\/s"//)

#convert the movie to frames
avconv -i $file -b "$bitRate"k out_%d.png

#Calculate image size
imsize=$(identify -format "%wx%h" out_1.png )

#count the number files in the directory
fileno=$(ls out_*.png -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

#glitch the files
img2txt -W 80 -d random -f tga out_"$no".png > out_"$no".tga

#resize the images
mogrify -scale $imsize! out_"$no".tga

echo -e "Glitched file $no of $fileno"

no=`expr $no + 1`

done

#combine the images into a video
avconv -i out_%d.tga -b "$bitRate"k "$file"_caca.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/

echo -e "\033[33mJob done. Check for "$file"_caca_"$rand".tga \033[0m"
echo -e "\033[31m---------------------------------------------------- \033[0m"
