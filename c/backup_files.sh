#!/bin/bash

source ./functions/*

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

src=$1  # Argumento $1 passa a ser $src
bkp=$2  # Argumento $2 passa a ser $bkp

# Verificar se $src existe
checkPath "$src"
if [ $? -ne 1 ]; then
    exit 1;
fi
src=$new_path


isNew=0   # Variável que indica se é a primeira vez que $bkp é criada ou não (default = 0)

# Verificar se $bkp existe
checkPath "$bkp"
if [ $? -ne 1 ]; then
    # criar a diretoria
    echo "OUTPUT_TESTE: (então será criada)."
    mkdir -p -v $bkp
    isNew=1
fi
bkp=$new_path

if [ $isNew -eq 1 ]; then
    # copiar todos os ficheiros de src para bkp
    echo "OUTPUT_TESTE: O caminho é novo, então, copiamos todos os ficheiros de src para bkp (sem avaliar datas)"
    for file in "$src"*; do
        echo "OUTPUT_TESTE (ficheiro): $file"
        echo "OUTPUT_TESTE (diretoria): $bkp"
        cp -v $file $bkp
    done
else
    # avaliar as datas de modificação dos ficheiros
    echo "OUTPUT_TESTE: O caminho não é novo, então, ao copiarmos cada ficheiros de src para bkp temos de ter em atenção às datas de modificação"
    for file in "$src"*; do
        echo "OUTPUT_TESTE (ficheiro): $file"
    done
fi
echo "OUTPUT_TESTE: isNew = $isNew (1 se o diretório de bkp é novo e 0 se já existia)"
echo "Fim do programa."