#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

c_flag=0

while getopts ":c" flag; do
    case "$flag" in
        c) 
            c_flag=1
            ;;
        \?) 
            echo -e "Parâmetros incorretos!\nEsperado: -c /path/to/src /path/to/bkp"
            exit 1
            ;;
    esac
done

# Dá shift das flags e "retira-as" dos argumentos
shift $((OPTIND - 1))

# Verifica que o programa tem exatamente 2 argumentos depois de processar as flags (path/to/src e path/to/bkp)
if [ $# -ne 2 ]; then
    echo -e "Parâmetros incorretos!\nEsperado: -c /path/to/src /path/to/bkp"
    exit 1
fi

# Atribuir os restantes argumentos a src e bkp
src="$1"
bkp="$2"

# Verificar se $src existe
checkPath $src
if [ $? -ne 1 ]; then
    exit 1;
fi
src=$new_path

# Verificar se $bkp existe
checkPath $bkp
if [ $? -ne 1 ]; then
    # criar a diretoria
    if [ $c_flag -eq 1 ]; then
        echo "mkdir -p -v $bkp"
    else
        mkdir -p -v $bkp
    fi
fi
bkp=$new_path

for file_path in "$src"{.,}*; do
    file_name=$(basename "$file_path")    # remove o prefixo do path e deixa apenas o nomes do ficheiro
    isNewer "$src$file_name" "$bkp$file_name"
    if [ $? -eq 1 ]; then
        # copia-se o ficheiro
        if [ $c_flag -eq 1 ]; then
            echo "cp -a -v \"$file_path\" $bkp"
        else
            cp -a -v "$file_path" $bkp
        fi
    fi
done
echo "Fim do programa."