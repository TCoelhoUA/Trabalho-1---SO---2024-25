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
source ./functions/checkExistance.sh

# $1 - src (Pasta a copiar)
# $2 - bkp (Pasta onde colar) [Criar Pasta caso não exista]

# Inicializar as flags e argumentos
c_flag=0
b_flag=0
r_flag=0
flags=""

errors=0
warnings=0
updated=0
copied=0
deleted=0

copied_size=0
deleted_size=0

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
                ((errors+=1))
            fi
            flags+=" -b $blockedFiles"
            ;;
        r)
            r_flag=1
            regexpr="$OPTARG"
            flags+=" -r \"$regexpr\""
            ;;
        \?)
            echo -e "Parâmetros incorretos!\nEsperado: -c -b [tfile] -r [regexpr] path/to/src /path/to/bkp"
            ((errors+=1))
            ;;
    esac
done

# Dá shift das flags e "retira-as" dos argumentos
shift $((OPTIND - 1))

# Verifica que o programa tem exatamente 2 argumentos depois de processar as flags (path/to/src e path/to/bkp)
if [ $# -ne 2 ]; then
    echo -e "Parâmetros incorretos!\nEsperado: -c -b [tfile] -r [regexpr] path/to/src /path/to/bkp"
    ((errors+=1))
fi

# Atribuir os restantes argumentos a src e bkp
src="$1"
bkp="$2"

# Verifica se $src e $bkp são o mesmo diretório
if [[ "$src" == "$bkp" ]]; then
    echo "Os caminhos \"/path/to/src\" e \"/path/to/bkp\" não podem ser iguais!"
    ((errors+=1))
fi

# Verificar se $src existe
checkPath "$src"
if [ $? -ne 1 ]; then
    echo "O caminho \"$src\" não existe!"
    ((errors+=1))
fi

if [[ errors -eq 0 ]]; then
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
        name=$(basename "$path")

        # Se o ficheiro/diretório já não existir em src, então apagamos de bkp
        if [ ! -e "$src/$name" ]; then
            ((deleted+=1))
            deleted_size=$((deleted_size + $(stat -c%s "$path")))
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
        file_name=$(basename "$file_path")    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

        if [ -d "$file_path" ]; then
            # Criar o diretório de destino correspondente, se não existir
            if [ ! -d "$bkp/$file_name" ]; then
                if [ $c_flag -eq 1 ]; then
                    echo "mkdir -p -v \"$bkp/$file_name\""
                else
                    mkdir -p -v "$bkp/$file_name"
                fi
            fi

            # Chama o script de backup recursivamente para esse subdiretório
            if [ $c_flag -eq 1 ]; then
                echo "eval \"bash \"$0\" $flags \"$file_path\" \"$bkp/$file_name\"\""
            fi
            eval "bash \"$0\" $flags \"$file_path\" \"$bkp/$file_name\""

        else
            isNewer "$file_path" "$bkp/$file_name"
            # Se ainda existir e for mais recente, então copiamos
            if [ $? -eq 1 ]; then
                checkExistance "$bkp/$file_name"    # Utilizado para, no final, sabermos se o ficheiro foi copiado ou atualizado
                control=$?
                var=0

                if [ $c_flag -eq 1 ]; then
                    if [ $b_flag -eq 1 ]; then
                        if [ $r_flag -eq 1 ]; then
                            if [[ "$file_name" =~ $regexpr ]]; then
                                # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b -r)
                                checkFile "$blockedFiles" "$file_path" "$file_name"
                                if [[ $? -eq 1 ]]; then
                                    echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                                else
                                    echo "cp -a -v \"$file_path $bkp\""
                                    var=1
                                fi
                            else
                                echo "Arquivo \"$file_name\" será ignorado (flag -r)."
                            fi
                        else
                            # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -c -b)
                            checkFile "$blockedFiles" "$file_path" "$file_name"
                            if [[ $? -eq 1 ]]; then
                                echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                            else
                                echo "cp -a -v \"$file_path\" \"$bkp\""
                                var=1
                            fi
                        fi
                    else
                        if [ $r_flag -eq 1 ]; then
                            # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -c -r)
                            if [[ "$file_name" =~ $regexpr ]]; then
                                echo "cp -a -v \"$file_path\" \"$bkp\""
                                var=1
                            else
                                echo "Arquivo \"$file_name\" será ignorado (flag -r)."
                            fi
                        else
                            # (Flags: -c)
                            echo "cp -a -v \"$file_path\" \"$bkp\""
                            var=1
                        fi
                    fi
                else
                    if [ $b_flag -eq 1 ]; then
                        if [ $r_flag -eq 1 ]; then
                            if [[ "$file_name" =~ $regexpr ]]; then
                                # Mesmo que o ficheiro verifique a expressão regular, se estiver no ficheiro da flag -b, então é ignorado (FLags: -b -r)
                                checkFile "$blockedFiles" "$file_path" "$file_name"
                                if [[ $? -eq 1 ]]; then
                                    echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                                else
                                    cp -a -v "$file_path" "$bkp"
                                    var=1
                                fi
                            else
                                echo "Arquivo \"$file_name\" será ignorado (flag -r)."
                            fi
                        else
                            # Se o ficheiro estiver no ficheiro da flag -b, então é ignorado (Flags: -b)
                            checkFile "$blockedFiles" "$file_path" "$file_name"
                            if [[ $? -eq 1 ]]; then
                                echo "Arquivo \"$file_name\" será ignorado (flag -b)."
                            else
                                cp -a -v "$file_path" "$bkp"
                                var=1
                            fi
                        fi
                    else
                        if [ $r_flag -eq 1 ]; then
                            # Se o nome do ficheiro verificar a expressão regular, então copiamos (Flags: -r)
                            if [[ "$file_name" =~ $regexpr ]]; then
                                cp -a -v "$file_path" "$bkp"
                                var=1
                            else
                                echo "Arquivo \"$file_name\" será ignorado (flag -r)."
                            fi
                        else
                            cp -a -v "$file_path" "$bkp"
                            var=1
                        fi
                    fi
                fi
                # Verificação para ver se o ficheiro não foi ignorado
                if [[ $var -eq 1 ]]; then
                    # Verificação final para atribuir os valores certos a Updated e Copied
                    if [[ $control -eq 1 ]]; then
                        ((updated+=1))
                    else
                        ((copied+=1))
                        copied_size=$((copied_size + $(stat -c%s "$file_path")))
                    fi
                fi
            # Verifica se o ficheiro em src é mais antigo do que em bkp
            elif [[ "$file_path" -ot "$bkp/$file_name" ]]; then
                echo "WARNING: backup entry $bkp/$file_name is newer than $file_path; Should not happen"
                ((warnings+=1))
            fi
        fi
    done
fi
shopt -u dotglob
shopt -u nullglob

echo -e "While backuping $src: $errors Errors; $warnings Warnings; $updated Updated; $copied Copied (${copied_size}B); $deleted Deleted (${deleted_size}B)\n"

# Exibir "Fim do programa" apenas na primeira execução (não recursiva)
if [ $INITIAL_CALL -eq 1 ]; then
    echo "Fim do programa."
fi