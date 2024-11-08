#!/bin/bash

# Verifica se $INITIAL_CALL não está definida
# Ao usarmos export fazemos com que qualquer child process (chamada recursiva) consiga aceder ao valor definido na chamada inicial
if [ -z "$INITIAL_CALL" ]; then
    export INITIAL_CALL=1  # Estamos na chamada inicial
else
    export INITIAL_CALL=0  # Estamos na chamada recursiva
fi

source ./functions/checkPath.sh
source ./functions/isNewer.sh
source ./functions/checkFile.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

# Inicializar as flags e argumentos
c_flag=0
b_flag=0
r_flag=0
flags=""

echo -e "\n\n\nRECEBEMOS $0\n$1\n$2\n$3\n$4\n$5\n$6\nN ARGS $#\n\n\n"

# Processar as opções com getopts
while getopts "cb:r:" flag; do
    case $flag in
        c)
            flags+="-c"
            c_flag=1
            ;;
        b)
            b_flag=1
            blockedFiles="$OPTARG"
            flags+=" -b $blockedFiles"
            ;;
        r)
            r_flag=1
            regexpr="$OPTARG"
            flags+=" -r \"$regexpr\""
            ;;
        \?)
            echo -e "Parâmetros incorretos!\nEsperado: -c -b [tfile] -r [regexpr] path/to/src /path/to/bkp"
            exit 1
            ;;
    esac
done

index=$OPTIND
# Calcular src e bkp com base no índice
src=${!index}
bkp_index=$((index + 1))
bkp=${!bkp_index}

# Dá shift das flags e "retira-as" dos argumentos
shift $((OPTIND - 1))

# Verifica que o programa tem exatamente 2 argumentos depois de processar as flags (path/to/src e path/to/bkp)
if [ $# -ne 2 ]; then
    echo -e "Parâmetros incorretos!\nEsperado: -c -b [tfile] -r [regexpr] path/to/src /path/to/bkp"
    exit 1
fi

# Ajustar o index com base nas flags ativadas
# -c
# if [ $c_flag -eq 1 ] && [ $b_flag -eq 0 ] && [ $r_flag -eq 0 ]; then
#     index=2
#     flags="-c"

# # -c -b [tfile]
# elif [ $c_flag -eq 1 ] && ([ $b_flag -eq 1 ] && [ $r_flag -eq 0 ]); then
#     index=4
#     flags="-c -b $blockedFiles"

# # -c -b [tfile] -r [regexpr]
# elif [ $c_flag -eq 1 ] && ([ $b_flag -eq 1 ] && [ $r_flag -eq 1 ]); then
#     index=6
#     flags="-c -b $blockedFiles -r "$regexpr""

# # -b [tfile]
# elif [ $c_flag -eq 0 ] && [ $b_flag -eq 1 ] && [ $r_flag -eq 0 ]; then
#     index=3
#     flags="-b $blockedFiles"

# # -b [tfile] -r [regexpr]
# elif [ $c_flag -eq 0 ] && [ $b_flag -eq 1 ] && [ $r_flag -eq 1 ]; then
#     index=5
#     flags="-b $blockedFiles -r "$regexpr""

# # -r [regexpr]
# elif [ $c_flag -eq 0 ] && [ $b_flag -eq 0 ] && [ $r_flag -eq 1 ]; then
#     index=3
#     flags="-r "$regexpr""

# # -c -r [regexpr]
# elif [ $c_flag -eq 1 ] && [ $b_flag -eq 0 ] && [ $r_flag -eq 1 ]; then
#     index=4
#     flags="-c -r "$regexpr""

# elif [ $# -eq 2 ]; then
#     index=1
# else
#     echo "Número de argumentos inválido!"
#     exit 1
# fi



# Exibir as flags e os parâmetros
echo "FLAGS EM GERAL = $flags"
echo "OUTPUT_TESTE (Flag c): $c_flag"
echo "OUTPUT_TESTE (Flag b): $b_flag"
echo "BLOCKED FILES = $blockedFiles"
echo "OUTPUT_TESTE (Flag r): $r_flag"
echo "REGEXPR = "$regexpr""
echo "OUTPUT_TESTE (Flags): $flags"

# index=$OPTIND
# # Calcular src e bkp com base no índice
# src=${!index}
# bkp_index=$((index + 1))
# bkp=${!bkp_index}
# src=${!$OPTIND}
# bkp_index=$(($OPTIND + 1))
# bkp=${!bkp_index}
# echo $OPTIND
echo "$src - $bkp_index - $bkp"

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

shopt -s nullglob
shopt -s dotglob
for path in "$bkp"*; do
    name=$(basename "$path")

    echo "NAME = $name"
    echo "PATH = $path"
    # Se o ficheiro/diretório já não existir em src, então apagados de bkp
    if [ ! -e "$src$name" ]; then
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

for file_path in "$src"*; do
    file_name=$(basename "$file_path")    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

    if [ -d "$file_path" ]; then
        #echo "OUTPUT_TESTE: $file_path é um diretório."

        # Criar o diretório de destino correspondente, se não existir
        if [ ! -d "$bkp$file_name" ]; then
            if [ $c_flag -eq 1 ]; then
                echo "mkdir -p -v \"$bkp$file_name\""
            else
                mkdir -p -v "$bkp$file_name"
            fi
        fi

        echo "INICIO DA RECURSAO"
        # Chama o script de backup recursivamente para esse subdiretório
        if [ $c_flag -eq 1 ]; then
            echo -e "FILEPATH $file_path\nOUTRO $bkp$file_name"
            echo -e "\n\n\n(dentro do c)ENVIÁMOS: $0 $flags \"$file_path\" \"$bkp$file_name\""
            echo "bash $0 $flags \"$file_path\" \"$bkp$file_name\""
        fi
        echo -e "\n\n\n(fora do C)ENVIÁMOS: $0 $flags \"$file_path\" \"$bkp$file_name\""
        echo "FLAGS: $flags"
        #bash "$0" $flags "$file_path" "$bkp$file_name"
        # Pass flags correctly and call the script recursively
        eval "bash \"$0\" $flags \"$file_path\" \"$bkp$file_name\""


        #bash "$0" ${c_flag:+-c} ${b_flag:+-b "$blockedFiles"} ${r_flag:+-r "$regexpr"} "$file_path" "$bkp$file_name"

        echo "FIM DA RECURSAO"
        
#       Possível implementação de não copiar pastas vazias mas talvez até seja melhor incluí-las de qualquer forma
#
#        # Apaga o diretório se ele estiver vazio
#        if [ $b_flag -eq 1 || $r_flag -eq 1 ]; then
#            if [ $c_flag -eq 1 ]; then
#                echo "rmdir $bkp"
#            else
#                rmdir $bkp
#            fi
#        fi


    else

        echo "NOME = $file_name"
        isNewer "$file_path" "$bkp$file_name"
        # Se ainda existir e for mais recente, então copiamos
        if [ $? -eq 1 ]; then
            if [ $c_flag -eq 1 ]; then
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ "$file_name" =~ "$regexpr" ]]; then
                            # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b -r)
                            checkFile "$blockedFiles" "$file_name"
                            if [[ $? -eq 1 ]]; then
                                echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                            else
                                echo "cp -a -v \"$file_path $bkp\""
                            fi
                        fi
                    else
                        # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b)
                        checkFile "$blockedFiles" "$file_name"
                        if [[ $? -eq 1 ]]; then
                            echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                        else
                            echo "cp -a -v \"$file_path\" \"$bkp\""
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -c -r)
                        if [[ "$file_name" =~ "$regexpr" ]]; then
                            echo "cp -a -v \"$file_path\" \"$bkp\""
                        fi
                    else
                        # (Flags: -c)
                        echo "cp -a -v \"$file_path\" \"$bkp\""
                    fi
                fi
            else
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ "$file_name" =~ "$regexpr" ]]; then
                            # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (FLags: -b -r)
                            checkFile "$blockedFiles" "$file_name"
                            if [[ $? -eq 1 ]]; then
                                echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                            else
                                cp -a -v "$file_path" "$bkp"
                            fi
                        fi
                    else
                        # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -b)
                        checkFile "$blockedFiles" "$file_name"
                        if [[ $? -eq 1 ]]; then
                            echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                        else
                            cp -a -v "$file_path" "$bkp"
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -r)
                        if [[ "$file_name" =~ "$regexpr" ]]; then
                            cp -a -v "$file_path" "$bkp"
                        fi
                    else
                        cp -a -v "$file_path" "$bkp"
                    fi
                fi
            fi
        fi
    fi
done
shopt -u dotglob
shopt -u nullglob

# Exibir "Fim do programa" apenas na primeira execução (não recursiva)
if [ $INITIAL_CALL -eq 1 ]; then
    echo "Fim do programa."
fi