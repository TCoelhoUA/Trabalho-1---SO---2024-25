Situações a ter em conta:

✔ - Existe
✗ - Não existe

Situações habituais:

              src    bkp
> novos        ✔      ✗    (existem na src mas não no bkp)
> apagados     ✗      ✔    (existem no bkp mas já não existem na src)
> atualizados  ✔      ✔    (existem em ambos mas na src está mais atualizado)
> mantidos     ✔      ✔    (existem em ambos e continuam iguais)

Situações anómalas:

Na consola:

./backup.sh [-c] [-b tfile] [-r regexpr] dir_trabalho dir_backup

Esta estrutura da linha de comando deve ser sempre validada pelo script, assim como a existência da diretoria de trabalho (src).

              src    bkp
> atualizados/mantidos     ✔      ✔    (existem em ambos no entanto a versão na src é mais desatualizada do que no bkp) [causa provável: alguém mexeu diretamente no bkp]
