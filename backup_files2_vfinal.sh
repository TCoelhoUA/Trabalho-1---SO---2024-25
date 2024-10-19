#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

c_flag=0

case $# in
    2)
        index=1
        ;;
    3)
        index=2
        if [[ "$1" == "-c" ]]; then
            c_flag=1
        else
            echo "Parâmetro incorreto. Esperado: '[-c]'"
            exit 1
        fi
        ;;
    *)
        echo "Número de argumentos inválido!"
        exit 1
        ;;
esac

src=${!index}
bkp_index=$((index+1))
bkp=${!bkp_index}

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

for file_path in $src*; do
    file_name=$(basename $file_path)    # remove o prefixo do path e deixa apenas o nomes do ficheiro
    isNewer $src$file_name $bkp$file_name
    if [ $? -eq 1 ]; then
        # copia-se o ficheiro
        if [ $c_flag -eq 1 ]; then
            echo "cp -a -v $file_path $bkp"
        else
            cp -a -v $file_path $bkp
        fi
    fi
done
echo "Fim do programa."