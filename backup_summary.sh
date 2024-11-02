#!/bin/bash

source ./functions/checkPath.sh
source ./functions/isNewer.sh
source ./functions/checkFile.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

c_flag=0
b_flag=0
r_flag=0
flags=""

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
            flags="-c"
        else
            echo "Parâmetro incorreto. Esperado: '[-c]'"
            exit 1
        fi
        ;;
    
    # 1 Flag ativa (b/r)
    4)
        index=3
        case $1 in
            "-b")
                if [[ -f $2 ]]; then
                    b_flag=1
                    flags="-b $2"
                    blockedFiles=$2
                else
                    echo "Parâmetro incorreto. Esperado: '[-b tfile]'"
                    exit 1
                fi
                ;;
            "-r")
                r_flag=1
                regexpr=$2
                flags="-r $2"
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
                    flags="-c -b $3"
                    blockedFiles=$3
                else
                    echo "Parâmetro incorreto. Esperado: '[-b tfile]'"
                    exit 1
                fi
                ;;
            "-r")
                r_flag=1
                regexpr=$3
                flags="-c -r $3"
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
            flags="-b $2 -r $4"
            blockedFiles=$2
            regexpr=$4
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
        regexpr=$5
        blockedFiles=$3
        flags="-c -b $3 -r $5"
        ;;

    *)
        echo "Número de argumentos inválido!"
        exit 1
        ;;
esac

errors=0
warnings=0
updated=0
copied=0
copied_size=0
deleted=0
deleted_size=0

echo "OUTPUT_TESTE (Flag c): "$c_flag
echo "OUTPUT_TESTE (Flag b): "$b_flag
echo "OUTPUT_TESTE (Flag r): "$r_flag
echo "OUTPUT_TESTE (Flags): "$flags

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

# Dentro de cada diretório fazemos esta verificação de possíveis ficheiro/diretórios apagados
for path in "$bkp"/*; do
    if [ -e "$path" ]; then
        name=$(basename $path)

        # Se já não existir na src, então apagamos do bkp
        if [[ ! -f $src$name ]]; then
            deleted_size=$(stat -c%s "$bkp$name")
            # Verificar se é ficheiro ou diretório
            if [[ -f $path ]]; then
                if [ $c_flag -eq 1 ]; then
                    echo "rm $bkp$name"
                else
                    rm -v $bkp$name
                fi
            else
                if [ $c_flag -eq 1 ]; then
                    echo "rm -r $bkp$name"
                else
                    rm -r -v $bkp$name
                fi
            fi
        fi
    fi
done

for file_path in $src*; do
    file_name=$(basename $file_path)    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

    if [ -d $file_path ]; then
        #echo "OUTPUT_TESTE: $file_path é um diretório."

        # Criar o diretório de destino correspondente, se não existir
        if [ ! -d $bkp$file_name ]; then
            if [ $c_flag -eq 1 ]; then
                echo "mkdir -p -v $bkp$file_name"
            else
                mkdir -p -v "$bkp$file_name"
            fi
        fi

        main_call=0

        # Chama o script de backup recursivamente para esse subdiretório
        if [ $c_flag -eq 1 ]; then
            echo "bash $0 $flags $file_path $bkp$file_name"
        fi
        bash $0 $flags $file_path $bkp$file_name


    else


        isNewer $file_path $bkp$file_name
        # Se ainda existir e for mais recente, então copiamos
        if [ $? -eq 1 ]; then
            if [ $c_flag -eq 1 ]; then
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ $file_name == *$regexpr* ]]; then
                            # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b -r)
                            checkFile $blockedFiles $file_name
                            if [[ $? -eq 1 ]]; then
                                echo "Arquivo $file_name será ignorado (flag -b)."
                            else
                                echo "cp -a -v $file_path $bkp"
                            fi
                        fi
                    else
                        # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b)
                        checkFile $blockedFiles $file_name
                        if [[ $? -eq 1 ]]; then
                            echo "Arquivo $file_name será ignorado (flag -b)."
                        else
                            echo "cp -a -v $file_path $bkp"
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -c -r)
                        if [[ $file_name == *$regexpr* ]]; then
                            echo "cp -a -v $file_path $bkp"
                        fi
                    else
                        # (Flags: -c)
                        echo "cp -a -v $file_path $bkp"
                    fi
                fi
            else
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ $file_name == *$regexpr* ]]; then
                            # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (FLags: -b -r)
                            checkFile $blockedFiles $file_name
                            if [[ $? -eq 1 ]]; then
                                echo "Arquivo $file_name será ignorado (flag -b)."
                            else
                                cp -a -v $file_path $bkp
                            fi
                        fi
                    else
                        # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -b)
                        checkFile $blockedFiles $file_name
                        if [[ $? -eq 1 ]]; then
                            echo "Arquivo $file_name será ignorado (flag -b)."
                        else
                            cp -a -v $file_path $bkp
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -r)
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

echo "DELEDTED = $deleted_size (B)"
# Exibir "Fim do programa" apenas na primeira execução (não recursiva)
if [ $main_call -eq 1 ]; then
    echo "Fim do programa."
fi