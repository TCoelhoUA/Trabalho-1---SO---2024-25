-- Teste Válidos --
# Teste 1 # Sem flags
./backup_files.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 2 # Com flag -c
./backup_files.sh -c /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

-- Testes Inválidos --
# Teste 3 # Path de Source Inexistente
./backup_files.sh /home/tiago/Desktop/NOTHING /home/tiago/Desktop/BACKUP

# Teste 4 # Path de Source e Backup iguais
./backup_files.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/SOURCE

# Teste 5 # Com flag -c e argumentos para -c
./backup_files.sh -c some_argument /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP
