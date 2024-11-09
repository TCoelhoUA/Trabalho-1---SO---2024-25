#!/bin/bash

# Função que verifica se o path indicado existe
function checkPath() {
    if [ -d "$1" ]; then
        return 1
    else
        return 0
    fi
}