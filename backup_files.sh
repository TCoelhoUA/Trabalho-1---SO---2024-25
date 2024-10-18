#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

case $# in
    2)
        index=1
        c_flag=0
        ;;
    3)
        index=2
        if [[ "$1" == "-c" ]]; then
            c_flag=1
        else
            echo "Parâmetro incorreto. Esperado: '-c'"
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
echo "src = $src"
echo "bkp = $bkp"

# Verificar se $src existe
checkPath $src
if [ $? -ne 1 ]; then
    exit 1;
fi
src=$new_path

isNew=0   # Variável que indica se é a primeira vez que $bkp é criada ou não (default = 0)

# Verificar se $bkp existe
checkPath $bkp
if [ $? -ne 1 ]; then
    # criar a diretoria
    echo "OUTPUT_TESTE: (então será criada)."
    if [ $c_flag -eq 1 ]; then
        echo "mkdir -p -v $bkp"
    else
        mkdir -p -v $bkp
        isNew=1
    fi
fi
bkp=$new_path

if [ $isNew -eq 1 ]; then
    # copiar todos os ficheiros de src para bkp
    echo "OUTPUT_TESTE: O caminho é novo, então, copiamos todos os ficheiros de src para bkp (sem avaliar datas)"
    for file_path in $src*; do
        echo "OUTPUT_TESTE (ficheiro): $file_path"
        echo "OUTPUT_TESTE (diretoria): $bkp"

        if [ $c_flag -eq 1 ]; then
            echo "cp -a -v $file_path $bkp"
        else
            cp -a -v $file_path $bkp
        fi
    done
else
    # avaliar as datas de modificação dos ficheiros
    echo "OUTPUT_TESTE: O caminho não é novo, então, ao copiarmos cada ficheiros de src para bkp temos de ter em atenção às datas de modificação"
    for file_path in $src*; do
        file_name=$(basename $file_path)    # remove o prefixo do path e deixa apenas o nomes do ficheiro
        echo "OUTPUT_TESTE (file_path): $file_path"
        echo "OUTPUT_TESTE (file_name): $file_name"
        isNewer $src$file_name $bkp$file_name
        if [ $? -eq 1 ]; then
            # copia-se o ficheiro
            echo "foi copiado"
            if [ $c_flag -eq 1 ]; then
                echo "cp -a -v $file_path $bkp"
            else
                cp -a -v $file_path $bkp
            fi
        fi
    done
fi

echo "OUTPUT_TESTE: isNew = $isNew (1 se o diretório de bkp é novo e 0 se já existia)"
echo "Fim do programa."