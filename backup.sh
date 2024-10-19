#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

main_call=1

if [ $main_call -eq 1 ]; then

    c_flag=0
    b_flag=0
    r_flag=0

    case $# in
        # Nenhuma Flag ativa
        2)
            index=1
            ;;

        # 1 Flag ativa (c)
        3)
            index=2
            if [[ "$1" == "-c" ]]; then
                c_flag=1
            else
                echo "Parâmetro incorreto. Esperado: '[-c]'"
                exit 1
            fi
            ;;
        
        # 1 Flag ativa (b/r)
        4)
            case $1 in
                "-b")
                    if [[ -f $2 ]]; then
                        b_flag=1
                    else
                        echo "Parâmetro incorreto. Esperado: '[-b tfile]'"
                        exit 1
                    fi
                    ;;
                "-r")
                    r_flag=1
                    ;;
                *)
                    echo "Parâmetros incorretos. Esperado: '[-b tfile] ou [-r regexpr]'"
                    exit 1
            esac
            ;;

        # 2 Flags ativas (c + b/r)
        5)
            index=4
            if [[ "$1" == "-c" ]]; then
                c_flag=1
            else
                echo "Parâmetro incorreto. Esperado: '[-c]'"
                exit 1
            fi
            
            case $2 in
                "-b")
                    if [[ -f $3 ]]; then
                        b_flag=1
                    else
                        echo "Parâmetro incorreto. Esperado: '[-b tfile]'"
                        exit 1
                    fi
                    ;;
                "-r")
                    r_flag=1
                    ;;
                *)
                    echo "Parâmetros incorretos. Esperado: '[-b tfile] ou [-r regexpr]'"
                    exit 1
            esac
            ;;
        
        # 2 Flags ativas (b + r)
        6)
            index=5
            if [[ "$1" == "-b" && -f $2 && "$3" == "-r" ]]; then
                b_flag=1
                r_flag=1
            fi
            ;;

        # 3 Flags ativas
        7)
            index=6
            if [[ "$1" == "-c" ]]; then
                c_flag=1
            else
                echo "Parâmetro incorreto. Esperado: '[-c]'"
                exit 1
            fi

            if [[ -f $3 ]]; then
                b_flag=1
            else
                echo "Parâmetro incorreto. Esperado: '[-b tfile]'"
                exit 1
            fi

            r_flag=1
            ;;

        *)
            echo "Número de argumentos inválido!"
            exit 1
            ;;
    esac
fi

echo "OUTPUT_TESTE (Flag c): "$c_flag
echo "OUTPUT_TESTE (Flag b): "$b_flag
echo "OUTPUT_TESTE (Flag r): "$r_flag

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
        if [ ! -d $bkp$file_name ]; then
            if [ $c_flag -eq 1 ]; then
                echo "mkdir -p -v $bkp$file_name"
            else
                mkdir -p -v $bkp$file_name
            fi
        fi

        main_call=0

        # Chama o script de backup recursivamente para esse subdiretório
        if [ $c_flag -eq 1 ]; then
            echo "bash $0 -c \"$file_path/\" \"$bkp$file_name/\""
        else
            bash $0 $file_path $bkp$file_name
        fi


    else
        # Se o item é um arquivo, verificar se precisa ser copiado
        isNewer $file_path $bkp$file_name
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