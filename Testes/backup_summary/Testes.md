-- Teste Válidos --
# Teste 1 # Sem flags
./backup_summary.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 2 # Com flag -c
./backup_summary.sh -c /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 3 # Com flag -b
./backup_summary.sh -b /home/tiago/Desktop/Testes/exclude_list.txt /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 4 # Com flag -r
./backup_summary.sh -r '.*\.txt$' /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 5 # Com flags -c e -b
./backup_summary.sh -c -b /home/tiago/Desktop/Testes/exclude_list.txt /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 6 # Com flags -b e -r
./backup_summary.sh -r '.*\.log$' -b /home/tiago/Desktop/Testes/exclude_list.txt /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 7 # Com flags -c, -b e -r
./backup_summary.sh -c -b /home/tiago/Desktop/Testes/exclude_list.txt -r '.*\.txt$' /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

-- Testes Inválidos --
# Teste 8 # Path de Source Inexistente
./backup_summary.sh /home/tiago/Desktop/NOTHING /home/tiago/Desktop/BACKUP

# Teste 9 # Path de Source e Backup iguais
./backup_summary.sh /home/tiago/Desktop/SOURCE /home/tiago/Desktop/SOURCE

# Teste 10 # Com flag -c e argumentos para -c
./backup_summary.sh -c some_argument /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 11 # Com flag -b e "exclude_list.txt" inválido/não existente
./backup_summary.sh -b /home/tiago/Desktop/Testes/non_existent.txt /home/tiago/Desktop/SOURCE /home/tiago/Desktop/BACKUP

# Teste 12 # Com flag -k e Path de Source Inexistente
./backup_summary.sh -k /home/tiago/Desktop/NOTHING /home/tiago/Desktop/BACKUP
