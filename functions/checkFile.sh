#!/bin/bash

function checkFile() {
    # Verifica se o ficheiro ou o seu path corresponde a alguma linha do ficheiro
    while IFS= read -r line; do
        if [ "$3" == "$line" ] || [ "$2" == "$line" ]; then
            return 1
        fi
    done < "$1"
    return 0
}