#!/bin/bash
# Another imgur album downloader

# grab passed url
url="$1"

# temporary file for source code
tmp=".tmpsrc"

# text formatting
bold="\e[01;37m"
rst="\e[m"

# display usage and exit
Usage() {

    printf "${bold}USAGE${rst}: ./imgur_dler.sh imgur.com/a/<album_id>\n"
    exit 1

}

# retrieve images files, excludes videos
DownloadImages() {

    # check for "imgur.com/a/" in url
    if [[ $url =~ 'imgur.com/a/' ]]; then

        # add /all for pulling large albums
        url="${url}/all"

        # download source
        curl -s $url -o $tmp

        # grab ids of images
        ids="$(awk -F'"' '/itemscope/ {print $2}' $tmp)"

        # grab a directory name
        dir_name="$(awk -F'>' '/post-title / {print $2}' $tmp | sed 's/<[/]h1$//g')"

        # if empty dir_name string then request user input
        if [[ -z $dir_name ]]; then
            printf "Enter a directory name: "
            read dir_name

        # if the directory exists then display message and quit
        elif [[ -e $dir_name ]]; then
            printf "Directory exists. Exiting.\n"
            exit 1

        fi

        # make directory
        mkdir "$dir_name"

        for id in $ids; do

            # format for downloading source
            id_url="http://imgur.com/$id"

            # grab source
            curl -s $id_url -o $tmp

            # grab url to image
            image="$(awk -F'"' '/rel="image_src"/ {print $4}' $tmp)"

            # create filename from direct image url
            save_as="$(echo $image | awk -F'/' '{print $4}')"

            # download and save
            curl -s "$image" -o "$save_as" 

            # move to dir_name folder
            mv "${save_as}" "${dir_name}" 2>/dev/null

        done

    # clean up temp file
    rm $tmp 2>/dev/null

    else
        # print error message and exit
        printf "This script only works with imgur albums.\n"
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
