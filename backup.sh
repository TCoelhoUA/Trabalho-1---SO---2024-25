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

main_call=1

for file_path in $src*; do
    file_name=$(basename $file_path)    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

    if [ -d $file_path ]; then
        echo "$file_path é um diretório."

        # Criar o diretório de destino correspondente, se não existir
        if [ ! -d $bkp/$file_name ]; then
            if [ $c_flag -eq 1 ]; then
                echo "mkdir -p -v $bkp/$file_name"
            else
                mkdir -p -v $bkp/$file_name
            fi
        fi

        main_call=0

        # Chama o script de backup recursivamente para esse subdiretório
        if [ $c_flag -eq 1 ]; then
            echo "bash $0 -c \"$file_path/\" \"$bkp/$file_name/\""
        else
            bash $0 $file_path $bkp/$file_name
        fi


    else
        # Se o item é um arquivo, verificar se precisa ser copiado
        isNewer $file_path $bkp/$file_name
        if [ $? -eq 1 ]; then
            # Copia o arquivo
            if [ $c_flag -eq 1 ]; then
                echo "cp -a -v \"$file_path\" \"$bkp\""
            else
                cp -a -v $file_path $bkp
            fi
        fi
    fi
done

# Exibir "Fim do programa" apenas na primeira execução (não recursiva)
if [ $main_call -eq 1 ]; then
    echo "Fim do programa."
fi