#!/bin/bash

function isNewer() {
    # Caso ainda exista, verificamos se é mais recente ou não
    if [[ "$1" -nt "$2" ]]; then
        return 1
    else
        return 0
    fi
}