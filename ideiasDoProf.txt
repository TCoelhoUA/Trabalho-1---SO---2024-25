Situações a ter em conta:

✔ - Existe
✗ - Não existe

Comando ÚTIL:
date -d "Tue Oct 15 08:49:09" +%s (retorna um número que corresponde ao número de segundos passados desde um certo tempo que não sei bem qual é, mas basicamente todas as datas têm número diferentes, o que facilita na comparação, sendo que datas mais recentes têm número maiores)

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

NAO ACEITAR BKP NA PROPRIA SOURCE, ia começar a alterar a source enquanto se iterava com ela, provavelmente ia dar um loop qualquer

[[ $f1 -nt $f2]] -> $f1 e $f2 são ficheiro, o -nt compara as datas (nt = newer than), isso faz com que o comando date -d "dat" +%s já não seja preciso

              src    bkp
> atualizados/mantidos     ✔      ✔    (existem em ambos no entanto a versão na src é mais desatualizada do que no bkp) [causa provável: alguém mexeu diretamente no bkp]
