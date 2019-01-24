#Autores: Saul Ugueto y Alejandro Graterol
#Fecha: 09/02/2019

.data
	Pregunta: .asciiz "¿Desea insertar un error? Elija entre opcion 1 o 2:\n  1-Si\n  2-No\n\n"
	NumeroInvalido: .asciiz " Estimado usuario le recordamos que debe seleccionar una opcion valida\n\n"
	Menu: .asciiz "	SELECCIONE UN NUMERO DE OPCION:\n	1-INSERTAR ERROR\n	2-DETECTAR ERROR\n	0-Salir\n\n"
	ArchivoEntrada: .asciiz "ENTRADA.txt"
	ArchivoConError: .asciiz "ArchivoCopia.txt"
	ErrorListo: .asciiz "\nError insertado exitosamente\n\n"
	buffer: .space 3145728 	# 3MB
	SaltarLinea: .asciiz "\n"
	HayError: .asciiz "\nEl archivo contiene errores\n\n" 		# tal cual lo dice el pdf
	NoHayError: .asciiz "\nEl archivo se mantiene inalterado\n\n"
	ErrorNoAgregado: .asciiz "\nNo se ha insertado ningun error\n\n"
.text
	# ABRIENDO ARCHIVO PARA LECTURA
	li $v0, 13	   # 13 = Open File
	la $a0, ArchivoEntrada       # load address, carga la direccion del archivo ENTRADA.txt en $a0
	li $a1, 0 	   # modo lectura = 0 , modo escritura= 1,
	li $a2, 0 	   # modo ignorado para que se pueda hacer la lectura del archivo
	syscall		   # Listo, archivo abierto para lectura
	# $v0 contiene ahora el file descriptor, el cual guardaremos en $s1 para 
	#poder usar $v0 otra vez libremente
	move $s1, $v0		# guardando el file descriptor en $s1
	#---------------------------------------------------------------------------------------------------	
		# APLICANDO LA LECTURA
	li $v0, 14	# 14 = read from file
	move $a0, $s1	# copiando en $a0 el file descriptor de ENTRADA.txt, q es el archivo abierto
	la $a1, buffer	# load addres del bufer de 3 MB 
	la $a2, 3145728 # maximo numero de caracteres a leer
	syscall
	# $v0 contiene el numero de caracteres leidos p , el cual guardaremos en $s2
	move $s2, $v0   #  p = $s2

	la $s0, buffer		# direccion de buffer en $s0 
	
	addi $t0, $0, 0		# contador para recorrer el bufer
	addi $t1, $0, 0		# almacena la suma de los valores ascii
	#---
	sumOri:
	lb $t2, ($s0)	# cargar byte ascii de la primera posicion de la direccion de memoria del bufer
	add $t1, $t1, $t2
	addi $s0, $s0, 1	# pararse en el caracter siguiente
	addi $t0, $t0, 1
	bne $s2, $t0, sumOri	# si P != $t0 suma todos los valores del bufer del archivo sin error
	
	move $s5, $t1		# pasa el resultado de toda la suma a s5 por usar los save registers para su propósito
	#imprimir para ver s5
	#li $v0, 1
	#move $a0, $s5
	#syscall
	#li $v0, 4
	#la $a0 SaltarLinea
	#syscall
#---------------------------------------------------------------------------------------------------------------------------	
	
	# ABRIENDO ARCHIVOCOPIA PARA ESCRITURA
	li $v0, 13	   		# 13 = Open File
	la $a0, ArchivoConError		# load address, carga la direccion del ArchivoCopia en $a0
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
	
	# cerrando ArchivoCopia.txt
	li $v0, 16			# Close file = 16
	move $a0, $s3			# File descriptor
	syscall
#---------------------------------------------------------------------------------------------------
MainMenu:
	#Imprimiendo Menu de opciones
	la $a0, Menu	# load address del menu a imprimir
	li $v0, 4	# print string= 4
	syscall
	EsperaOpcion:
	#Leyendo opcion
	li $v0, 5	# read integer=5
	syscall
	# faltan los saltos condicionales y finalizaciones despues de los saltos
	beq $v0, 1, InsercionDeError
	beq $v0, 2, DeteccionDeError
	beq $v0, 0, CerrarPrograma
	
	la $a0, NumeroInvalido
	li $v0, 4
	syscall
	
	j EsperaOpcion		#si se da un entero invalido
	
#----------------------------------------------------------------------------------------------------------------------
DeteccionDeError:
	# ABRIENDO ARCHIVO PARA LECTURA
	li $v0, 13	   # 13 = Open File
	la $a0, ArchivoConError       # load address, carga la direccion del archivo en $a0
	li $a1, 0 	   # modo lectura = 0 , modo escritura= 1,
	li $a2, 0 	   # modo ignorado para que se pueda hacer la lectura del archivo
	syscall		   # Listo, archivo abierto para lectura
	# $v0 contiene ahora el file descriptor, el cual guardaremos en $s3 para 
	#poder usar $v0 otra vez libremente
	move $s3, $v0		# guardando el file descriptor en $s3
	
		# APLICANDO LA LECTURA
	li $v0, 14	# 14 = read from file
	move $a0, $s3	# copiando en $a0 el file descriptor, q es el archivo abierto
	la $a1, buffer	# load addres del bufer de 3 MB 
	la $a2, 3145728 # maximo numero de caracteres a leer
	syscall		# no se guarda el p de $v0 porque no lo necesitamos en esta ocasion
	
	la $s0, buffer		# direccion de buffer en $s0 
	addi $t0, $0, 0		# contador para recorrer el bufer
	addi $t1, $0, 0		# almacena la suma de los valores ascii
	
	
	
	sumDes:
	lb $t2, ($s0)		# cargar byte ascii de la primera posicion de la direccion de memoria del bufer
	add $t1, $t1, $t2
	addi $s0, $s0, 1
	addi $t0, $t0, 1
	
	#imprimir para ver
	#li $v0, 1
	#move $a0, $t0
	#syscall
	
	bne $s2, $t0, sumDes	# suma todos los valores del bufer del archivo sin error
	move $s6, $t1		# pasa el resultado de toda la suma a s6 por usar los save registers para su propósito (almacenar valores finales o costantes)
	
	#viendo $s6
	#li $v0, 1
	#move $a0, $s6
	#syscall
	#li $v0, 4
	#la $a0 SaltarLinea
	#syscall
	
	bne $s5, $s6, ErrorDetectado
	
NoTieneError:
	la $a0, NoHayError	# load address de la cadena NoHayError
	li $v0, 4	# print string= 4
	syscall
	# cerrando ArchivoCopia.txt
	li $v0, 16			# Close file = 16
	move $a0, $s3			# File descriptor
	syscall
j MainMenu

ErrorDetectado:
	la $a0, HayError	# load address de la cadena HayError
	li $v0, 4	# print string= 4
	syscall
	# cerrando ArchivoConError.txt
	li $v0, 16			# Close file = 16
	move $a0, $s3			# File descriptor
	syscall
j MainMenu

#----------------------------------------------------------------------------------------------------------------------
CerrarPrograma:
	# Cerrando ENTRADA.txt
	li $v0, 16			# Close file = 16
	move $a0, $s1			# File descriptor ENTRADA.txt
	syscall
	jr $ra 		# Salir del programa
#----------------------------------------------------------------------------------------------------------------------


InsercionDeError:
	la $a0, Pregunta
	li $v0, 4
	syscall
	OpcionValida:
	li $v0, 5
	syscall
	beq $v0, 1 MeterError
	beq $v0, 2 ErrorNoInsertado
	
	la $a0, NumeroInvalido
	li $v0,4
	syscall
	j OpcionValida
	
	ErrorNoInsertado:
	la $a0, ErrorNoAgregado
	li $v0, 4
	syscall
	
	j MainMenu
	
	MeterError:
	# ABRIENDO ARCHIVO PARA ESCRITURA
	li $v0, 13	   		# 13 = Open File
	la $a0, ArchivoConError		# load address del direccion del archivo copia
	li $a1, 1 	   		# modo escritura= 1,
	li $a2, 0 	   		# modo ignorado para que se pueda hacer la escritura del archivo
	syscall		   		# Listo, archivo abierto para escritura
	# $v0 contiene ahora el file descriptor, el cual guardaremos en $s3 para 
	#poder usar $v0 otra vez libremente
	move $s3, $v0			# guardando el file descriptor en $s3
	
	addi $t0, $0, 3 	#agregando el valor 3 al registro $t0 
	div $s2, $t0		#  p/3 
	mflo $t0		# t0= p/3 (division entera)
	la $s4, buffer
	add $s4, $s4, $t0	# guardando el valor ascii del caracter de la posición p/3
	
	#Escribir el error en el archivo
	lb $t2, ($s4)
	addi $t2, $t2, 10	# sumanddole 10 al ascii
	sb $t2, ($s4)		# guardando el error en la posicion p/3 del buffer
	
	
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

#------------------------------------------------------------------------------------------------------------------------
	