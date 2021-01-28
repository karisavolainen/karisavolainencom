#!/bin/bash
PATH=$PATH:$HOME/sh

# copy images to site folder
mkdir -p site
cp -vr content/images site/
echo

for file  in $(find . -name index); do
    # what is our template
    template=$(grep '#template' $file|cut -d' ' -f2)
    # what is our css file
    cssfile=$(grep '#css' $file|cut -d' ' -f2)
    # echo  --- $template

    # create page file (index.html in page folder)
    page=site/$(basename $(dirname $file))
    echo $page
    mkdir -p $page
    :> $page/index.html
    # copy css file into page folder
    cp -v blocks/$cssfile $page/

    # read template and build the page
    while read line; do
        case "$line" in
            \#block*)
                # insert block contents
                block=$(echo $line|cut -d ' ' -f 2)
                cat blocks/$block >> $page/index.html
                ;;
            \#include*)
                echo "Run markdown > $page/index.html"
                ./markdown.pl $(dirname $file)/$(echo $line|cut -d ' ' -f 2) >> $page/index.html
                ;;
            *)
                # pure html from template file
                echo $line >> $page/index.html
                ;;
            esac
    done < blocks/$template
    echo
done
