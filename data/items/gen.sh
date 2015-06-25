#!/bin/sh

mkdir -p print/ texture/
rm -f print/* texture/*

id=1
for i in `cat list.txt`;
do
    dir=$(dirname "$i")

    # generate texture
    convert "src/$i" -background white -colorspace RGB -normalize -resize "240x240" -gravity center -extent "256x256" -format "PNG" "texture/$id.png"

    # generate print
    # convert "src/$i" -background white -colorspace RGB -normalize -resize "384x288" -gravity center -extent "384x288" -ordered-dither o8x8 -monochrome -colorspace RGB -format "PNG" "print/$id.png"
    convert "src/$i" -background white -colorspace RGB -normalize -resize "384x288" -gravity center -extent "384x288" -ordered-dither o8x8 -monochrome -colorspace RGB -size "384x288" -depth 8 -format "RGB" "print/$id.rgb"

    id=$(expr $id + 1)
done

# generate full textures
convert -append \
    texture/1.png \
    texture/2.png \
    texture/3.png \
    texture/4.png \
    texture/5.png \
    texture/6.png \
    texture/7.png \
    texture/8.png \
    texture/9.png \
    texture/10.png \
    texture/11.png \
    texture/12.png \
    -format "PNG" \
    ../../public/images/lemanmake1.png

convert -append \
    texture/13.png \
    texture/14.png \
    texture/15.png \
    texture/16.png \
    texture/17.png \
    texture/18.png \
    texture/19.png \
    texture/20.png \
    texture/21.png \
    texture/22.png \
    texture/23.png \
    texture/24.png \
    -format "PNG" \
    ../../public/images/lemanmake2.png

convert -append \
    texture/25.png \
    texture/26.png \
    texture/27.png \
    texture/28.png \
    texture/29.png \
    texture/30.png \
    texture/31.png \
    texture/32.png \
    texture/33.png \
    texture/34.png \
    texture/35.png \
    texture/36.png \
    -format "PNG" \
    ../../public/images/lemanmake3.png
