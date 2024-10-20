#!/bin/bash

function isNewer() {
    # Caso ainda exista, verificamos se é mais recente ou não
    if [[ $1 -nt $2 ]]; then
        echo "OUTPUT_TESTE (isNewer()): Ficheiro da source é mais recente (copiamos)"
        return 1
    else
        echo "OUTPUT_TESTE (isNewer()): Ficheiro da bkp é mais recente ou igual (não copiamos)"
        return 0
    fi
}