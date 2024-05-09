.eqv index $t0
.eqv char $a0
.eqv digit $s1
.eqv num $s2
.eqv multiplier $t1
.eqv index_sw $t2
.eqv array $s3
.eqv tam_array $s4
.eqv flag $s5
.eqv num2 $t3
.eqv index2 $t4


.data
arquivo: .asciiz "/home/gabriel/Área de Trabalho/Unifor/Arquitetura de Computadores/list"
arquivo_ordenado: .asciiz "/home/gabriel/Área de Trabalho/Unifor/Arquitetura de Computadores/numeros"
numeros_string: .space 1024  # Espaço para ler dados do arquivo
		.align 2
numeros_int:.space 1024 #espaço para escrever os dados em inteiros(são 100 números)
numero_atual:.space 100 #armazena o número atual
numeros:.space 1024
buffer:.space 1024 #idx
virgula:.asciiz ","
n: .word 100
buffer2: .space 1025  # 1024 bytes + 1 para '\0'

.text
# Abrir arquivo para leitura
abrir_arquivo:
    li $v0, 13             # Syscall para abrir arquivo
    la $a0, arquivo        # Endereço do nome do arquivo
    li $a1, 0              # 0 para leitura
    li $a2, 0              # Modo de arquivo (não necessário para leitura)
    syscall                # Executa o syscall
    move $s0, $v0          # Salva o descritor de arquivo em $s0

# Ler dados do arquivo
    li $v0, 14             # Syscall para ler de um arquivo
    move $a0, $s0          # Descritor de arquivo
    la $a1, numeros_string # Buffer onde os dados serão lidos
    li $a2, 1024             # Número de bytes a ler
    syscall                # Executa o syscall
    move $t0, $v0          # Salva quantos bytes foram lidos

# Imprimir dados lidos (para diagnóstico)
    li $v0, 4              # Syscall para imprimir string
    la $a0, numeros_string # Endereço do buffer
    syscall                # Executa o syscall para imprimir o conteúdo do buffer

# Fechar o arquivo
    move $a0, $s0          # Descritor de arquivo para fechar
    li $v0, 16             # Syscall para fechar arquivo
    syscall                # Executa o syscall
    
li index,0
li index_sw,0

init:
	li multiplier,1
	li num,0

loop:
	lb char,numeros_string(index)
	addi index,index,1
	beq char,$zero,store
	beq char,'\n',store
	beq char,',',store
	beq char,'-',sign
	sub digit,char,'0'
	mul num,num,10
	add num,num,digit
	j loop

store:
	mul num,num,multiplier
	#store in memory
	sw num,numeros_int(index_sw)
	addi index_sw,index_sw,4
	beq char,$zero,exit
	beq char,'\n',exit
	j init

sign:
	li multiplier,-1
	j loop
	
exit:
    la $a0, numeros_int      # Carrega o endereço base do array em $a0
    lw $a1, n            # Carrega o tamanho do array em $a1
    addi $a1, $a1, -1    # Decrementa $a1 porque precisamos de n-1 passadas

outer_loop:
    li $t0, 0            # Índice i inicializado com 0
    li $t1, 0            # Flag para verificar trocas

inner_loop:
    sll $t2, $t0, 2      # Converte índice para deslocamento em bytes
    add $t3, $a0, $t2    # Endereço de array[i]
    lw $t4, 0($t3)       # Carrega array[i]
    lw $t5, 4($t3)       # Carrega array[i+1]

    bgt $t4, $t5, swap   # Se array[i] > array[i+1], troca
    j continue

swap:
    sw $t4, 4($t3)       # Troca os elementos (armazena o valor de array[i] em array[i+1])
    sw $t5, 0($t3)       # Troca os elementos (armazena o valor de array[i+1] em array[i])
    li $t1, 1            # Define a flag de troca

continue:
    addi $t0, $t0, 1     # Incrementa o índice i
    blt $t0, $a1, inner_loop # Continua o loop interno se i < n-1

    beqz $t1, finish     # Se nenhuma troca foi feita, o array está ordenado
    li $t1, 0            # Reseta a flag para a próxima passagem
    j outer_loop         # Repete o loop externo
finish:
# Escrever no arquivo ordenado
#escrever no txt

# Escrever no arquivo ordenado
escrever:
    li $v0, 13                # Syscall para abrir arquivo (para escrita)
    la $a0, arquivo_ordenado  # Endereço do nome do arquivo ordenado
    li $a1, 1                 # Flags para criar e escrever              
    syscall
    move $s0, $v0             # Salva o descritor de arquivo retornado em $v0

    li $v0, 15                # Syscall para escrever em um arquivo
    move $a0, $s0             # Descritor de arquivo para o arquivo ordenado
    la $a1, numeros_int      # Endereço base do array ordenado para escrever
    li $a2,400       # Escreve 100 números * 4 bytes cada = 400 bytes
    syscall

    li $v0, 16                # Syscall para fechar arquivo
    move $a0, $s0             # Usa o descritor de arquivo
    syscall

finalizar:
    li $v0, 10                # Syscall para terminar a execução
    syscall

	
	
	
	
	
	
	
	

	
	
	
