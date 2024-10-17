#!/bin/bash

# $1 - SOURCE (Pasta a copiar)
# $2 - DESTINATION (Pasta onde colar) [Criar Pasta caso não exista]

$SOURCE=$1  # Argumento $1 passa a ser $SOURCE
$DIRETORIA=$2 # Argumento $2 passa a ser $DIRETORIA

# Verificar se a $SOURCE existe
if [ ! -d "$SOURCE" ]; then
    echo "O caminho $SOURCE não existe."
    exit 1;
fi

# Verificar se a $DIRETORIA existe
if [ -d "$DIRETORIA" ]; then
    # fazer copia (talvez cp fich1, cp fich2, etc... 1 a 1)
    echo "existe"
else
    # criar a diretoria
    #mkdir -v -p $DIRETORIA
    echo "DIR nao existe"
fi
echo "fim"