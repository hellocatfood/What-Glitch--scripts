#!/bin/bash

file=$1

#make a directory to do the glitching
rand=$RANDOM
mkdir /tmp/temp_$rand
cd /tmp/temp_$rand

#convert the movie to frames
avconv -i $file -qscale 0 out_%d.tga

#count the number files in the directory
fileno=$(ls out_*.tga -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

rand1=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)
rand2=$(tr -dc A-Za-z0-9_ < /dev/urandom | head -c 1)

#glitch the files
sed -i s/$rand1/$rand2/ out_$no.tga

echo -e "Glitched file $no of $fileno"

no=$(($no + 1))

done

echo -e "Converting files to .bmp's as avconv doesn't like these glitched files"
#avconv doesn't seem to like these glitch .tga's so we convert them to .bmp's
gimp -n -i -b - <<EOF
(let* ( (file's (cadr (file-glob "*.tga" 1))) (filename "") (image 0) (layer 0) )
  (while (pair? file's)
    (set! image (car (gimp-file-load RUN-NONINTERACTIVE (car file's) (car file's))))
    (set! layer (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
    (set! filename (string-append (substring (car file's) 0 (- (string-length (car file's)) 4)) ".bmp"))
    (gimp-file-save RUN-NONINTERACTIVE image layer filename filename)
    (gimp-image-delete image)
    (set! file's (cdr file's))
    )
  (gimp-quit 0)
  )
EOF

rm out_*.tga

#get path of file
path=$( readlink -f "$( dirname "$file" )" )

#get filename minus extension
file1=$(basename "$file")
filename="${file1%.*}"

#combine the images into a video
avconv -i out_%d.bmp -qscale 0 "$path"/"$filename"_tga.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
