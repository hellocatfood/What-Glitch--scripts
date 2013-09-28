#!/bin/bash

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#convert the movie to frames
avconv -i $file -qscale 0 out_%d.ppm

#count the number files in the directory
fileno=$(ls out_*.ppm -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

#glitch the files
sed -i s/P6/P5/ out_$no.ppm

echo -e "Glitched file $no of $fileno"

no=$(($no + 1))

done

#get path of file
path=$( readlink -f "$( dirname "$file" )" )

#get filename minus extension
file1=$(basename "$file")
filename="${file1%.*}"

#combine the images into a video
avconv -i out_%d.ppm -qscale 0 "$path"/"$filename"_ppm.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
