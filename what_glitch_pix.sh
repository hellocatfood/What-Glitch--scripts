#!/bin/bash

# What Glitch? pix.
# By Antonio Roberts
# www.hellocatfood.com
# GNU/GPL. See License for license details

#What Glitch?
#======================
#The What Glitch? scripts were made to demonstrate the wide variety of glitches and compression artifacts you can find in image file formats. The method used in most of the scripts is to find and replace parts of text within the image file, although reducing the bit depth can also produce commonly seen glitch visuals

#Required Dependencies
#=====================
#Sed
#FFMPEG
#Mplayer
#Imagemagick
#GIMP

#Basic Useage
#==================
#1. Make the file executable: In a terminal type chmod+x what_glitch_webp.sh
#2. Run ./what_glitch_pix.sh
#3. Drop a video file into terminal window and press Enter

#Notes
#==================
#The scripts have only been tested on Ubuntu Linux 10.10. If you are able to get them working with other operating systems please feel free to share your techniques

#These scripts seem to work best with AVI video files that are 24 or 25 frames per second. Files that are 30 frames per second get out of sync with the audio

#Make sure the name of the directory containing the image to glitch doesn't contain spaces e.g. "untitled_folder" instead of "untitled folder"

#The video needs audio order for this script to work. If you know what you're doing you can edit parts of this script for it to work on files that have no audio

#As this scripts processes each frame of a video file it will take a very long time to complete. It is recommended for use only on small video clips!

echo -e "\033[33mWhat Glitch? pix. \033[0m"
echo -e "\033[32mBy Antonio Roberts | hellocatfood \033[0m"
echo -e "\033[35mwww.hellocatfood.com \033[0m"
echo -e "\033[31mGNU/GPL. See License for license details \033[0m"
read -p "DROP A VIDEO FILE HERE> " file
echo -e "\033[32mLets glitch $file \033[0m" 
file="$(echo $file | sed -e "s/'//" | sed -e "s/'//")"

#calculate the framerate
framerate=$(mplayer -vo null -ao null -cache-min 0 -frames 0 -identify $file | grep ID_VIDEO_FPS= | sed -e "s/"ID_VIDEO_FPS="//")

#make a directory to do the glitching
rand=$RANDOM
mkdir temp_$rand
cd temp_$rand

#extract the audio
ffmpeg -i $file -ab 320k videoaudio.wav

#convert the movie to frames
ffmpeg -i $file -sameq -r $framerate out_%d.bmp

#count the number files in the directory
fileno=$(ls out_*.bmp -1 | wc -l)

#gimp and imagemagick encode .pix files differently, so we'll go with the one that does it best
echo -e "\033[33m You may see a lot of error messages here. Don't worry about them \033[0m"
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
sed -i s/¿/e/g out_$no.pix
sed -i s/@/$/g out_$no.pix
sed -i s/t/b/g out_$no.pix
sed -i s/#/g/g out_$no.pix
sed -i s/h/o/g out_$no.pix

echo -e "\033[33mGlitched file $no of $fileno \033[0m"

no=`expr $no + 1`

done

#gimp and imagemagick encode .pix files differently, so we'll go with the one that does it best
echo -e "\033[33mYou may see a lot of error messages here. Don't worry about them \033[0m"
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
ffmpeg -i out_%d.bmp -sameq -vcodec huffyuv -r $framerate ../outfile_pix_"$rand".mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
echo -e "\033[33mJob done. Check for outfile_pix_"$rand".mkv \033[0m"
echo -e "\033[31m---------------------------------------------------- \033[0m"
