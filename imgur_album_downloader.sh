#!/bin/bash
# Another Imgur album downloader

# grab passed url
url="$1"

# temporary file for source code
tmp=".tmpsrc"

# display usage and exit
Usage() {

    printf "USAGE: ./imgur_dler.sh <imgur_album>"
    exit 1

}

# retrieve images files, excludes videos
DownloadImages() {

    # check for "imgur.com/a/" in url
    if [[ $url =~ "imgur.com/a/" ]]; then

        # add /all for pulling large albums
        url="${url}/all"

        # download source
        curl -s $url > $tmp

        # grab ids of images
        ids="$(awk -F'"' '/itemscope/ {print $2}' $tmp)"

        # grab a directory name
        dir_name="$(awk -F'>' '/post-title / {print $2}' $tmp | sed 's/<[/]h1$//g')"

        #printf "$dir_name\n"

        mkdir "$dir_name"

        # if empty dir_name string then request user input
        if [[ -z $dir_name ]]; then
            printf "Enter a directory name: "
            read dir_name
        fi

        for id in $ids; do

            # format for downloading source
            id_url="http://imgur.com/$id"

            # grab source
            curl -s $id_url > $tmp

            #printf "$item_url $tmp\n"

            # grab url to image
            image="$(awk -F'"' '/rel="image_src"/ {print $4}' $tmp)"

            # create filename from direct image url
            save_as="$(echo $image | awk -F'/' '{print $4}')"

            #printf "$image $dir_name/$save_as\n"
            # download and save
            curl -s $image > $save_as
            mv "${save_as}" "${dir_name}" 2>/dev/null

        done

    # clean up temp file
    
    rm $tmp 2>/dev/null

    else

        # print error message and exit
        print "This script only works with imgur albums.\n"
        Usage
        exit 1

    fi

}

# if no passed arguments display usage
if [[ -z $url ]]; then
    Usage
    exit 1
fi

DownloadImages
