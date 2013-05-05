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

#gimp and imagemagick encode .pix files differently, so we'll go with the one that does it best
echo -e " You may see a lot of error messages here. Don't worry about them"
gimp -n -i -b - <<EOF
(let* ( (file's (cadr (file-glob "*.bmp" 1))) (filename "") (image 0) (layer 0) )
  (while (pair? file's)
    (set! image (car (gimp-file-load RUN-NONINTERACTIVE (car file's) (car file's))))
    (set! layer (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
    (set! filename (string-append (substring (car file's) 0 (- (string-length (car file's)) 4)) ".pix"))
    (gimp-file-save RUN-NONINTERACTIVE image layer filename filename)
    (gimp-image-delete image)
    (set! file's (cdr file's))
    )
  (gimp-quit 0)
  )
EOF

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

#glitch the files

sed -i s/a/b/g out_$no.pix
sed -i s/A/h/g out_$no.pix
sed -i s/K/0/g out_$no.pix
sed -i s/ÃÂ¿/e/g out_$no.pix
sed -i s/@/$/g out_$no.pix
sed -i s/t/b/g out_$no.pix
sed -i s/#/g/g out_$no.pix
sed -i s/h/o/g out_$no.pix

echo -e "Glitched file $no of $fileno"

no=`expr $no + 1`

done

#gimp and imagemagick encode .pix files differently, so we'll go with the one that does it best
echo -e "You may see a lot of error messages here. Don't worry about them"
gimp -n -i -b - <<EOF
(let* ( (file's (cadr (file-glob "*.pix" 1))) (filename "") (image 0) (layer 0) )
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

rm out_*.pix

#combine the images into a video
avconv -i out_%d.bmp -b "$bitRate"k "$file"_pix.mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
echo -e "Job done. Check for "$file"_pix.mkv"
echo -e "----------------------------------------------------"