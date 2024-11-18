#!/bin/bash

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
            if [[ ! -f "$blockedFiles" ]]; then
                echo "[tfile] tem de ser um ficheiro válido!"
                exit 1;
            fi
            flags+=" -b $blockedFiles"
            ;;
        r)
            r_flag=1
            regexpr="$OPTARG"
            flags+=" -r \"$regexpr\""
            ;;
        \?)
            echo -e "Parâmetros incorretos!\nEsperado: -c -b [tfile] -r [regexpr] /path/to/src /path/to/bkp"
            exit 1
            ;;
    esac
done

# Dá shift das flags e "retira-as" dos argumentos
shift $((OPTIND - 1))

# Verifica que o programa tem exatamente 2 argumentos depois de processar as flags (path/to/src e path/to/bkp)
if [ $# -ne 2 ]; then
    echo -e "Parâmetros incorretos!\nEsperado: -c -b [tfile] -r [regexpr] /path/to/src /path/to/bkp"
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
    echo "mkdir -p -v \"$bkp\""
    # criar a diretoria
    if [ $c_flag -eq 0 ]; then
        mkdir -p "$bkp"
    else
fi

shopt -s nullglob
shopt -s dotglob
for path in "$bkp"/*; do
    name=$(basename "$path")    # remove o prefixo do path e deixa apenas o nome do ficheiro

    # Se o ficheiro/diretório já não existir em src, então apagamos de bkp
    if [ ! -e "$src/$name" ]; then
        # Verificar se é ficheiro ou diretório
        if [ -f "$path" ]; then
            if [ $c_flag -eq 0 ]; then
                rm "$path"
            fi
        else
            if [ $c_flag -eq 0 ]; then
                rm -r "$path"
            fi
        fi
    fi
done

for file_path in "$src"/*; do
    file_name=$(basename "$file_path")    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

    if [ -d "$file_path" ]; then
        # Criar o diretório de destino correspondente, se não existir
        if [ ! -d "$bkp/$file_name" ]; then
            echo "mkdir $bkp/$file_name"
            if [ $c_flag -eq 0 ]; then
                mkdir "$bkp/$file_name"
            fi
        fi

        # Chama o script de backup recursivamente para esse subdiretório
        eval "bash \"$0\" $flags \"$file_path\" \"$bkp/$file_name\""
        
    else
        # Verifica se o ficheiro é mais recente em src do que em bkp (copia se for mais recente ou se ainda não existir em bkp)
        isNewer "$file_path" "$bkp/$file_name"
        # Se ainda existir e for mais recente, então copiamos
        if [ $? -eq 1 ]; then
            if [ $c_flag -eq 1 ]; then
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ "$file_name" =~ $regexpr ]]; then
                            # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b -r)
                            checkFile "$blockedFiles" "$file_path" "$file_name"
                            if [[ $? -eq 0 ]]; then
                                echo "cp -a $file_path $bkp/$file_name"
                            fi
                        fi
                    else
                        # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b)
                        checkFile "$blockedFiles" "$file_path" "$file_name"
                        if [[ $? -eq 0 ]]; then
                            echo "cp -a $file_path $bkp/$file_name"
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -c -r)
                        if [[ "$file_name" =~ $regexpr ]]; then
                            echo "cp -a $file_path $bkp/$file_name"
                        fi
                    else
                        # (Flags: -c)
                        echo "cp -a $file_path $bkp/$file_name"
                    fi
                fi
            else
                if [ $b_flag -eq 1 ]; then
                    if [ $r_flag -eq 1 ]; then
                        if [[ "$file_name" =~ $regexpr ]]; then
                            # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (FLags: -b -r)
                            checkFile "$blockedFiles" "$file_path" "$file_name"
                            if [[ $? -eq 0 ]]; then
                                echo "cp -a $file_path $bkp/$file_name"
                                cp -a "$file_path" "$bkp"
                            fi
                        fi
                    else
                        # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -b)
                        checkFile "$blockedFiles" "$file_path" "$file_name"
                        if [[ $? -eq 0 ]]; then
                            echo "cp -a $file_path $bkp/$file_name"
                            cp -a "$file_path" "$bkp"
                        fi
                    fi
                else
                    if [ $r_flag -eq 1 ]; then
                        # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -r)
                        if [[ "$file_name" =~ $regexpr ]]; then
                            echo "cp -a $file_path $bkp/$file_name"
                            cp -a "$file_path" "$bkp"
                        fi
                    else
                        echo "cp -a $file_path $bkp/$file_name"
                        cp -a "$file_path" "$bkp"
                    fi
                fi
            fi
        fi
    fi
done
shopt -u dotglob
shopt -u nullglob