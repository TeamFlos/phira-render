#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'Please provide a file name'
    exit 1
fi

for dir in *; do
    if [ -d "$dir" ]; then
        touch $dir/$1.ftl
    fi
done
