#!/bin/bash

function isNewer() {
    if [[ $1 -nt $2 ]]; then
        echo "OUTPUT_TESTE (isNewer()): Ficheiro da source é mais recente (copiamos)"
        return 1
    else
        echo "OUTPUT_TESTE (isNewer()): Ficheiro da bkp é mais recente (não copiamos)"
        return 0
    fi
}