#!/bin/bash

function checkExistance() {
    if [ -e "$1" ]; then
        return 1
    else
        return 0
    fi
}