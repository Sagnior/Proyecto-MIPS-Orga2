#Autores: Saul Ugueto y Alejandro Graterol
#Fecha: 09/02/2019

.data
	Menu: .asciiz "	SELECCIONE UN NUMERO DE OPCION:\n	1-INSERTAR ERROR\n	2-DETECTAR ERROR\n	0-Salir\n\n"
	ArchivoEntrada: .asciiz "ENTRADA.txt"
	ArchivoConError: .asciiz "ArchivoConError.txt"
	ErrorListo: .asciiz "\nError Insertado Exitosamente\n\n"
	buffer: .space 3145728 	# 3MB
.text
	# ABRIENDO ARCHIVO PARA LECTURA
	li $v0, 13	   # 13 = Open File
	la $a0, ArchivoEntrada       # load address, carga la direccion del archivo en $a0
	li $a1, 0 	   # modo lectura = 0 , modo escritura= 1,
	li $a2, 0 	   # modo ignorado para que se pueda hacer la lectura del archivo
	syscall		   # Listo, archivo abierto para lectura
	# $v0 contiene ahora el file descriptor, el cual guardaremos en $s1 para 
	#poder usar $v0 otra vez libremente
	move $s1, $v0		# guardando el file descriptor en $s1
	
		# APLICANDO LA LECTURA
	li $v0, 14	# 14 = read from file
	move $a0, $s1	# copiando en $a0 el file descriptor, q es el archivo abierto
	la $a1, buffer	# load addres del bufer de 3 MB 
	la $a2, 3145728 # maximo numero de caracteres a leer
	syscall
	# $v0 contiene el numero de caracteres leidos , el cual guardaremos en $s2
	move $s2, $v0   # largo del buffer llenado = $s2 , p=$s2

MainMenu:
	#Imprimiendo Menu de opciones
	la $a0, Menu	# load address del menu a imprimir
	li $v0, 4	# print string= 4
	syscall
	
	#Leyendo opcion
	li $v0, 5	# read integer=5
	syscall
	# faltan los saltos condicionales y finalizaciones despues de los saltos
	beq $v0, 1, InsercionDeError
	
InsercionDeError:
	addi $t0, $0, 3 	#agregando el valor 3 al registro $t0 
	div $s2, $t0		#  p/3 
	mflo $t0		# t0= p/3 (division entera)
	la $s4, buffer
	add $s4, $s4, $t0	# guardando el valor ascii del caracter de la posición p/3
	
	#Escribir el error en el archivo
	lb $t2, ($s4)
	addi $t2, $t2, 10	# sumanddole 10 al ascii
	sb $t2, ($s4)		# guardando el error en la posicion p/3 del buffer
	
	# ABRIENDO ARCHIVO PARA ESCRITURA
	li $v0, 13	   		# 13 = Open File
	la $a0, ArchivoConError		# load address, carga la direccion del archivo en $a0
	li $a1, 1 	   		# modo escritura= 1,
	li $a2, 0 	   		# modo ignorado para que se pueda hacer la escritura del archivo
	syscall		   		# Listo, archivo abierto para escritura
	# $v0 contiene ahora el file descriptor, el cual guardaremos en $s3 para 
	#poder usar $v0 otra vez libremente
	move $s3, $v0			# guardando el file descriptor en $s3
	
		#APLICANDO ESCRITURA
	li $v0, 15			# write to file = 15
	move $a0, $s3			# file descriptor del archivo con error agregado al arguento $a0
	la $a1, buffer			# direccion del buffer de salida 
	move $a2, $s2			# numero de caracteres a escribir
	syscall				# Listo, ahora $v0 contiene el numero de caracteres escritos
	
		#CERRANDO ARCHIVO CON ERROR
	li $v0, 16			# Close file = 16
	move $a0, $s3			# File descriptor
	syscall
	
	la $a0, ErrorListo 	# load address del mensaje a imprimir
	li $v0, 4			# print string= 4
	syscall
	j MainMenu
###########################################################################################################
