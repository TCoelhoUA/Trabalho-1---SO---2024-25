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

# Verifica que o programa tem exatamente 2 argumentos depois de processar as flags (path/to/src e path/to/bkp)
if [ $# -ne 2 ]; then
    echo -e "Parâmetros incorretos!\nEsperado: /path/to/src /path/to/bkp"
    exit 1
fi

# Atribuir os restantes argumentos a src e bkp
src="$1"
bkp="$2"

# Verificar se $src existe
checkPath $src
if [ $? -ne 1 ]; then
    exit 1;
fi

# Verificar se $bkp existe
checkPath $bkp
if [ $? -ne 1 ]; then
    exit 1;
fi

shopt -s nullglob
shopt -s dotglob

for file_path in "$src"/*; do
    file_name=$(basename "$file_path")    # Remove o prefixo do caminho e deixa apenas o nome do ficheiro/diretório

    if [ -d "$file_path" ]; then
        checkPath "$bkp/$file_name"
        if [[ $? -eq 1 ]]; then
            eval "bash \"$0\" \"$file_path\" \"$bkp/$file_name\""
        fi
    else
        if [[ -e "$bkp/$file_name" ]]; then
            # A função md5sum devolve um hash associado e o nome do ficheiro(se os hashes forem iguais então os ficheiros também são)
            # awk '{print $1}' é usado para filtrar o nome do ficheiro e obter apenas o código hash
            hash_src=$(md5sum "$file_path" | awk '{print $1}')
            hash_bkp=$(md5sum "$bkp/$file_name" | awk '{print $1}')

            echo -e "hash_src = $hash_src\nhash_bkp = $hash_bkp"

            if [ ! "$hash_src" == "$hash_bkp" ]; then
                echo "$file_path $bkp/$file_name differ."
            fi
        fi
    fi
done
#echo "While backuping $bkp: $errors Errors; $warnings Warnings; $updated Updated; $copied Copied (${copied_size}B); $deleted Deleted (${deleted_size}B)"
shopt -u dotglob
shopt -u nullglob

# Exibir "Fim do programa" apenas na primeira execução (não recursiva)
if [ $INITIAL_CALL -eq 1 ]; then
    echo "Fim do programa."
fi