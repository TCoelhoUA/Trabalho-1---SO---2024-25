#!/bin/bash

# Função que verifica se o path indicado existe
function checkPath() {
    new_path=$1
    # Se o path não acabar em "/", então adicionamos.
    if [[ ! $1 =~ /$ ]]; then
        new_path="$1/"
    fi

    if [ -d "$new_path" ]; then
        echo "OUTPUT_TESTE (checkPath()): O caminho $new_path existe."
        return 1
    else
        echo "OUTPUT_TESTE (checkPath()): O caminho $new_path não existe."
        return 0
    fi
}