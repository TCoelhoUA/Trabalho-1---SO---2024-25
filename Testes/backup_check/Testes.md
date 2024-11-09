# -- Pastas exatamente iguais -- #
-- Teste Válidos --
# Teste 1 # Sem flags
./backup_check.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

-- Testes Inválidos --
# Teste 2 # Sem argumentos
./backup_check.sh

# Teste 3 # Path de Source Inexistente
./backup_check.sh /home/tiago/Desktop/NOTHING /home/tiago/Desktop/BACKUP

# Teste 4 # Path de Backup Inexistente
./backup_check.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/NOTHING

# -- 3 Ficheiros alterados em BACKUP -- #
# Teste 5 # (Criou-se uma pasta cópia de BACKUP "BACKUP_MOD", onde se alterou "file5.html", "final          space" e "file2.log")
./backup_check.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP_MOD
