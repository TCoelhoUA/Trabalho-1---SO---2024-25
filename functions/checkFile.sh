#!/bin/bash

function checkFile() {
    while IFS= read -r line; do
        if [ $2 == $line ]; then
            #echo "OUTPUT_TESTE (checkFile()): O ficheiro $2 foi detetado como proibido, logo não copiamos"
            return 1
        fi
    done < $1
    return 0
}