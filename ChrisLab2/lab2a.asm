.data
	msg1:		.asciiz "Enter size for first array:\n"
	msg2:		.asciiz "Enter size for second array:\n"
	msg3:		.asciiz "Enter elements for first array:\n"
	msg4:		.asciiz "Enter elements for second array:\n"
	err: 		.asciiz "-- No elements were inserted --\n"
	curly_left:	.byte '{'
	curly_right:	.byte '}'
	comma:		.byte ','
	.align 2
		len1: 	.word 0
	.align 2
		array1: .word 0
	.align 2
		len2: 	.word 0
	.align 2
		array2: .word 0
	.align 2
		farray:	.word 0
	.align 2
		flen:	.word 0

.text
.globl main
main:
	# User input for arrays
	la $a0, len1
	la $a1, len2
	la $a2, array1
	la $a3, array2
	la $s0, farray

	jal user_input

	# Merge
	jal merge
	sw $v0, flen

	lw $a0, farray
	lw $a1, flen
	jal parray
	
	# Exit
	Exit:
		li $v0, 10
		syscall
# Takes the sizes of the arrays, creates them and 
# fills them with the elements, all given by the user
user_input:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $a0, 4($sp)	# len1
	sw $a1, 8($sp)	# len2
	sw $a2, 12($sp)	# &array1
	sw $a3, 16($sp)	# &array2

	la $a0, msg1
	jal print_str

	lw $a0, 4($sp)
	jal read_int

	move $a1, $a2
	lw $a0, ($a0)
	jal malloc

	la $a0, msg3
	jal print_str

	# First load the address where we
	# store the value and then the value itself
	lw $t1, 4($sp)
	lw $t1, ($t1)
	lw $t2, 12($sp)
	lw $t2, ($t2)
	jal insert

	la $a0, msg2
	jal print_str

	la $a0, len2
	jal read_int

	move $a1, $a3
	lw $a0, ($a0)
	jal malloc

	la $a0, msg4
	jal print_str

	lw $t1, 8($sp)
	lw $t1, ($t1)
	lw $t2, 16($sp)
	lw $t2, ($t2)
	jal insert

	lw $t0, 4($sp)
	lw $t0, ($t0)
	lw $t1, 8($sp)
	lw $t1, ($t1)
	
	bne $t0, $t1, Lout
	beq $t1, 0, NULL

	# Case where both arrays are empty
	NULL:
		la $a0, err
		jal print_str
		li $v0 10
		syscall
	
	Lout:	
		lw $ra, ($sp)
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a2, 12($sp)
		lw $a3, 16($sp)
		addi $sp, $sp, 20
		jr $ra

	# a0: string to print
	print_str:
		li $v0, 4
		syscall
		jr $ra

	# a0: address where we store the value we read
	read_int:
		li $v0, 5
		syscall
		sw $v0, ($a0)
		jr $ra
	
	# a0: Num of bytes to allocate, $a1: address of array pointer
	malloc:
		sll $a0, $a0, 2
		li $v0, 9
		syscall
		sw $v0, ($a1)
		jr $ra
	
	# a0: address where we store the value for the array
	# t1: length of array
	# t2: address of the array pointer
	insert:
		addi $sp, $sp, -4
		sw $ra, ($sp)
		li $t0, 0

		loop:
			beq $t0, $t1, end
			move $a0, $t2
			jal read_int
			addi $t0, $t0, 1
			addi $t2, $t2, 4
			j loop
		end:
			lw $ra, ($sp)
			addi $sp, $sp, 4
			jr $ra

merge:
	addi $sp, $sp, -24
	sw $ra, ($sp)
	sw $a0, 4($sp)	# len1
	sw $a1, 8($sp)	# len2
	sw $a2, 12($sp)	# array1
	sw $a3, 16($sp)	# array2
	sw $s0, 20($sp) # farray

	# First load the address where we
	# store the value and then the value itself	
	lw $t0, 4($sp)
	lw $t0, ($t0)
	lw $t1, 8($sp)
	lw $t1, ($t1)
	add $a0, $t1, $t0
	move $t9, $a0
	
	lw $a1, 20($sp)
	jal malloc

	move $t2, $t0	# len1
	move $t3, $t1	# len2
	li $t0, 0	# Array1 counter
	li $t1, 0	# Array2 counter
	li $t7, 0	# Farray counter
	lw $a1, ($a1)	# &Array1
	lw $a2, ($a2)	# &Array2
	lw $a3, ($a3)	# &Farray
	
	# t7: Counter for longest array
	# t8: Longest array address
	# t9: Lenght of the longest array
	compare:
		beq $t0, $t2, fill1
		beq $t1, $t3, fill2

		lw $s0, ($a2)
		lw $s1, ($a3)
		slt $t4, $s0, $s1
		beq $t4, 1, L1
		sw $s1, ($a1)
		addi $t1, $t1, 1
		addi $a3, $a3, 4
		j out
		L1:
			sw $s0, ($a1)
			addi $t0, $t0, 1
			addi $a2, $a2, 4

		out:
			addi $t7, $t7, 1
			addi $a1, $a1, 4
			j compare
	# len2 > len1, so we need to fill the final array with the array2 elements
	fill1:
		move $t8, $a3
		move $t5, $t1
		j fill

	# len1 > len1, so we need to fill the final array with the array1 elements
	fill2:
		move $t8, $a2
		move $t5, $t0

	# Fill the final array
	fill:
		beq $t7, $t9, return
		lw $t6, ($t8)
		sw $t6, ($a1)
		add $t7, $t7, 1
		add $t8, $t8, 4
		add $a1, $a1, 4
		j fill

	# Returns the sum of the 
	# lenghts of the two arrays
	return:
		add $v0, $t2, $t3

	lw $ra, ($sp)
	lw $a0, 4($sp)	# len1
	lw $a1, 8($sp)	# len2
	lw $a2, 12($sp)	# array1
	lw $a3, 16($sp)	# array2
	lw $s0, 20($sp)	
	addi $sp, $sp, 20
	jr $ra

# Prints the final array in the {...} format
parray:
	addi $sp, $sp, -4
	sw $a0, ($sp)
	move $t0, $a0
	move $t1, $a1
	li $t2, 0
	
	lb $a0, curly_left
	li $v0, 11
	syscall

	L2:
		lw $a0, ($t0)
		li $v0, 1
		syscall
		addi $t2, $t2, 1
		beq $t2, $t1, fin
		lb $a0, comma
		li $v0, 11
		syscall
		addi $t0, $t0, 4
		j L2

	fin:
		lb $a0, curly_right
		li $v0, 11
		syscall

	jr $ra
