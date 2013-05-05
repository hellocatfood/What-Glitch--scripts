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

convert -colorspace CMYK -separate out_$no.bmp in_%d.bmp

#glitch the cyan channel
sed -i s/t/63a/g in_0.bmp

#glitch the magenta channel
sed -i s/l/ÃÂ£ÃÂ£uns/g in_1.bmp

#glitch the yellow channel
sed -i s/h/ÃÂ£24/g in_2.bmp

#glitch the key channel
sed -i s/a/64a/g in_3.bmp

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
echo -e "Job done. Check for "$file"_bmpcmyk.mkv"
echo -e "----------------------------------------------------"
