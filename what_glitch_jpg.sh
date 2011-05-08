#!/bin/bash

# What Glitch? jpg.
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

#Basic Useage
#==================
#1. Make the file executable: In a terminal type chmod+x what_glitch_webp.sh
#2. Run ./what_glitch_jpg.sh
#3. Drop a video file into terminal window and press Enter

#Notes
#==================
#The scripts have only been tested on Ubuntu Linux 10.10. If you are able to get them working with other operating systems please feel free to share your techniques

#These scripts seem to work best with AVI video files that are 24 or 25 frames per second. Files that are 30 frames per second get out of sync with the audio

#Make sure the name of the directory containing the image to glitch doesn't contain spaces e.g. "untitled_folder" instead of "untitled folder"

#The video needs audio order for this script to work. If you know what you're doing you can edit parts of this script for it to work on files that have no audio

#As this scripts processes each frame of a video file it will take a very long time to complete. It is recommended for use only on small video clips!

echo -e "\033[33mWhat Glitch? jpg. \033[0m"
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
ffmpeg -i $file -sameq -r $framerate out_%d.jpg

#count the number files in the directory
fileno=$(ls out_*.jpg -1 | wc -l)

#begin the glitch loop
no=1
while [ $no -le $fileno ]
do

#glitch the files
sed -i s/@/63/g out_$no.jpg

echo -e "\033[33mGlitched file $no of $fileno \033[0m"

no=`expr $no + 1`

done

#combine the images into a video
ffmpeg -i out_%d.jpg -sameq -vcodec huffyuv -r $framerate ../outfile_jpg_"$rand".mkv

#remove the temporary directory
cd ../
rm -rf temp_$rand/
echo -e "\033[33mJob done. Check for outfile_jpg_"$rand".mkv \033[0m"
echo -e "\033[31m---------------------------------------------------- \033[0m"
