#Autores: Saul Ugueto y Alejandro Graterol
#Fecha: 09/02/2019

.data
	Direccion: .asciiz "ENTRADA.txt"
	buffer: .space 3145728 	# 3MB
.text
	# ABRIENDO ARCHIVO
	li $v0, 13		# 13 = Open File
	la $a0, Direccion  # load addres, carga la direccion del archivo en $a0
	li $a1, 0 	   # modo lectura = 0 , modo escritura= 1,
	li $a2, 0 	   # modo ignorado para que se pueda hacer la lectura del archivo
	syscall		   # Listo, archivo abierto para lectura
	# $v0 contiene ahora el file descriptor, el cual debe guardaremos en $s1 para 
	#poder usar $v0 otra vez libremente
	move $s1, $v0		# guardando el file descriptor en $s1
	
	# APLICANDO LA LECTURA
	li $v0, 14	# 14 = read from file
	move $a0, $s1	# copiando en $a0 el file descriptor, q es el archivo abierto
	la $a1, buffer	# load addres del bufer de 3 MB 
	la $a2, 3145728 # maximo numero de caracteres a leer
	syscall
	# $v0 contiene el numero de caracteres leidos , el cual guardaremos en $s2
	move $s2, $v0   # largo del buffer = $s2 , p=$s2
	
	