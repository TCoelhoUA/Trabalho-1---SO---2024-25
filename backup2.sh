#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

#!/bin/bash

# Inicializar as flags e argumentos
c_flag=0
b_flag=0
r_flag=0
flags=""
no_file=""
regexpr=""

# Processar as opções com getopts
while getopts "cb:r:" flag; do
    case $flag in
        c)
            c_flag=1
            ;;
        b)
            b_flag=1
            no_file="$OPTARG"
            ;;
        r)
            r_flag=1
            regexpr="$OPTARG"
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Ajustar o index com base nas flags ativadas
if [ $c_flag -eq 1 ] && [ $b_flag -eq 0 ] && [ $r_flag -eq 0 ]; then
    index=2
elif [ $c_flag -eq 1 ] && ([ $b_flag -eq 1 ] || [ $r_flag -eq 1 ]); then
    index=4
elif [ $c_flag -eq 0 ] && ([ $b_flag -eq 1 ] || [ $r_flag -eq 1 ]); then
    index=3
elif [ $c_flag -eq 0 ] && [ $b_flag -eq 1 ] && [ $r_flag -eq 1 ]; then
    index=5
elif [ $c_flag -eq 1 ] && [ $b_flag -eq 1 ] && [ $r_flag -eq 1 ]; then
    index=6
elif [ $# -eq 2 ]; then
    index=1
else
    echo "Número de argumentos inválido!"
    exit 1
fi

# Exibir as flags e os parâmetros
echo "OUTPUT_TESTE (Flag c): $c_flag"
echo "OUTPUT_TESTE (Flag b): $b_flag"
echo "OUTPUT_TESTE (Flag r): $r_flag"
echo "OUTPUT_TESTE (Flags): $flags"

# Calcular src e bkp com base no índice
src=${!index}
bkp_index=$((index + 1))
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
        #echo "OUTPUT_TESTE: $file_path é um diretório."

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
            echo "bash $0 $flags $file_path $bkp$file_name"
        fi
        bash $0 $flags $file_path $bkp$file_name


    else
        # Se o item é um arquivo, verificar se precisa ser copiado
        isNewer $file_path $bkp$file_name
        if [ $? -eq 1 ]; then
            # Copia o arquivo
            if [ $c_flag -eq 1 ]; then
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ $file_name == *$regexpr* ]]; then
                            if [[ $file_name == "$no_file" ]]; then
                                echo "Arquivo $file_name será ignorado (flag -b)."
                            else
                                echo "cp -a -v $file_path $bkp"
                            fi
                        fi
                    else
                        if [[ $file_name == "$no_file" ]]; then
                            echo "Arquivo $file_name será ignorado (flag -b)."
                        else
                            echo "cp -a -v $file_path $bkp"
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos
                        if [[ $file_name == *$regexpr* ]]; then
                            echo "cp -a -v $file_path $bkp"
                        fi
                    else
                        echo "cp -a -v $file_path $bkp"
                    fi
                fi
            else
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ $file_name == *$regexpr* ]]; then
                            if [[ $file_name == "$no_file" ]]; then
                                echo "Arquivo $file_name será ignorado (flag -b)."
                            else
                                cp -a -v $file_path $bkp
                            fi
                        fi
                    else
                        if [[ $file_name == "$no_file" ]]; then
                            echo "Arquivo $file_name será ignorado (flag -b)."
                        else
                            cp -a -v $file_path $bkp
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos
                        if [[ $file_name == *$regexpr* ]]; then
                            cp -a -v $file_path $bkp
                        fi
                    else
                        cp -a -v $file_path $bkp
                    fi
                fi
            fi
        fi
    fi
done

# Exibir "Fim do programa" apenas na primeira execução (não recursiva)
if [ $main_call -eq 1 ]; then
    echo "Fim do programa."
fi