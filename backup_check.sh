#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh
source ./functions/checkFile.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

if [ $# -ne 2 ]; then
    echo -e "Parâmetros incorretos!\nEsperado: /path/to/src /path/to/bkp"
    exit 1
fi

# Atribuir os restantes argumentos a src e bkp
src="$1"
bkp="$2"

# Verificar se $src existe
checkPath "$src"
if [ $? -ne 1 ]; then
    echo "O caminho \"$src\" não existe!"
    exit 1;
fi

# Verificar se $bkp existe
checkPath "$bkp"
if [ $? -ne 1 ]; then
    echo "O caminho \"$bkp\" não existe!"
    exit 1;
fi

shopt -s nullglob
shopt -s dotglob
for file_path in "$src"/*; do
    file_name=$(basename "$file_path")    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

    if [ -d "$file_path" ]; then
        checkPath "$bkp/$file_name"
        if [[ $? -eq 1 ]]; then
            eval "bash \"$0\" \"$file_path\" \"$bkp/$file_name\""
        fi
    else
        if [[ -e "$bkp/$file_name" ]]; then
            # A função md5sum devolve um hash associado e o nome do ficheiro(se os hashes forem iguais então os ficheiros também são)
            # awk '{print $1}' é usado para filtrar o nome do ficheiro e obter apenas o código hash

            hash_src=$(md5sum "$file_path" | awk '{print $1}')
            hash_bkp=$(md5sum "$bkp/$file_name" | awk '{print $1}')

            if [ ! "$hash_src" == "$hash_bkp" ]; then
                echo "$file_path $bkp/$file_name differ."
            fi
        fi
    fi
done
shopt -u dotglob
shopt -u nullglob