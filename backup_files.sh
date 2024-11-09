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

# Verifica se $src e $bkp são o mesmo diretório
if [[ "$src" == "$bkp" ]]; then
    echo "Os caminhos \"/path/to/src\" e \"/path/to/bkp\" não podem ser iguais!"
    exit 1;
fi

# Verificar se $src existe
checkPath "$src"
if [ $? -ne 1 ]; then
    echo "O caminho \"$src\" não existe!"
    exit 1;
fi

# Verificar se $bkp existe
checkPath "$bkp"
if [ $? -ne 1 ]; then
    # criar a diretoria
    if [ $c_flag -eq 1 ]; then
        echo "mkdir -p -v \"$bkp\""
    else
        mkdir -p -v "$bkp"
    fi
fi

shopt -s nullglob
shopt -s dotglob
for path in "$bkp"/*; do
    name=$(basename "$path")    # remove o prefixo do path e deixa apenas o nome do ficheiro

    # Se o ficheiro/diretório já não existir em src, então apagamos de bkp
    if [ ! -e "$src/$name" ]; then
        # Verificar se é ficheiro ou diretório
        if [ -f "$path" ]; then
            if [ $c_flag -eq 1 ]; then
                echo "rm -v \"$path\""
            else
                rm -v "$path"
            fi
        else
            if [ $c_flag -eq 1 ]; then
                echo "rm -r -v \"$path\""
            else
                rm -r -v "$path"
            fi
        fi
    fi
done

for file_path in "$src"/*; do
    file_name=$(basename "$file_path")    # remove o prefixo do path e deixa apenas o nome do ficheiro

    # Verifica se o ficheiro é mais recente em src do que em bkp (copia se for mais recente ou se ainda não existir em bkp)
    isNewer "$src/$file_name" "$bkp/$file_name"
    if [ $? -eq 1 ]; then
        if [ $c_flag -eq 1 ]; then
            echo "cp -a -v \"$file_path\" \"$bkp\""
        else
            cp -a -v "$file_path" "$bkp"
        fi
    fi
done
shopt -u nullglob
shopt -u dotglob

echo "Fim do programa."