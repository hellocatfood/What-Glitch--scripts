#!/bin/bash

#Copyright 2013 Antonio Roberts, License: GPL v3+

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#get bitrate
bitRate=$(avprobe $1 2>&1 | grep bitrate | cut -d ':' -f 6 | sed s/"kb\/s"//)

#convert the movie to frames
avconv -i $file -b "$bitRate"k out_%d.bmp

#count the number files in the directory
fileno=$(ls out_*.bmp -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

rand1=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)
rand2=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)
rand3=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)
rand4=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)

rand5=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 2)
rand6=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 2)
rand7=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 2)
rand8=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 2)

convert -colorspace CMYK -separate out_$no.bmp in_%d.bmp

#glitch the cyan channel
sed -i s/$rand1/$rand5/g in_0.bmp

#glitch the magenta channel
sed -i s/$rand2/$rand6/g in_1.bmp

#glitch the yellow channel
sed -i s/$rand3/$rand7/g in_2.bmp

#glitch the key channel
sed -i s/$rand4/$rand8/g in_3.bmp

#combine the channels into one image
convert in_0.bmp in_1.bmp in_2.bmp in_3.bmp -set colorspace CMYK -combine out_$no.bmp

#clear the directory of files
rm in_*.bmp

echo -e "Glitched file $no of $fileno"

no=`expr $no + 1`

done

#combine the images into a video
avconv -i out_%d.bmp -b "$bitRate"k "$file"_bmpcmyk.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/