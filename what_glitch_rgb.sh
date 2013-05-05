#!/bin/bash

echo -e $0
echo -e "By Antonio Roberts | hellocatfood"
echo -e "www.hellocatfood.com"
echo -e "GNU/GPL. See Licence"
file=$1
echo -e "Lets glitch $file"

#get bitrate
bitRate=$(avprobe $1 2>&1 | grep bitrate | cut -d ':' -f 6 | sed s/"kb\/s"//)

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#convert the movie to frames
avconv -i $file -b "$bitRate"k out_%d.bmp

#count the number files in the directory
fileno=$(ls out_*.bmp -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

convert -separate out_$no.bmp in_%d.bmp

#glitch the red channel
sed -i s/a/63/g in_0.bmp

#glitch the green channel
sed -i s/b/bnÂ£/g in_1.bmp

#glitch the blue channel
sed -i s/h/^2/g in_2.bmp

#combine the channels into one image
convert in_0.bmp in_1.bmp in_2.bmp -combine out_$no.bmp

#clear the directory of files
rm in_*.bmp

echo -e "Glitched file $no of $fileno"

no=`expr $no + 1`

done

#combine the images into a video
avconv -i out_%d.bmp -b "$bitRate"k "$file"_bmprgb.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
echo -e "Job done. Check for "$file"_bmprgb.mkv"
echo -e "----------------------------------------------------"