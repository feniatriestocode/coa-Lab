.macro printString (%address)
	li $v0, 4
	la $a0, %address
	syscall
.end_macro

.macro terminate
	li $v0, 10
	syscall
.end_macro

.data
	prompt:       	.asciiz "Enter roman number.\n"
	not_a_number: 	.asciiz "Not a roman number.\n"
	num_roman:    	.asciiz "Is roman number.\n"
	empty_string: 	.asciiz "No string found.\n"
	buffer:       	.space 21
.text
.globl main
main:
	.L:
		printString(prompt)

		li $v0, 8
		la $a0, buffer
		li $a1, 10
		syscall

		jal check_roman
		beq $v0, 0, .L

		move $v0, $0
		move $a1, $0
		jal roman_to_decimal
		move $a0, $v0
		li $v0, 1
		syscall
		terminate
	
		
check_roman:
	addi $sp, $sp, -8
	sw   $ra, 4($sp)
	sw   $a0, 0($sp) #store address of beginning of string
	
	lb   $t0, ($a0)    #load first char

	beq  $t0, 'M', is_roman
	beq  $t0, 'D', is_roman
	beq  $t0, 'C', is_roman
	beq  $t0, 'L', is_roman
	beq  $t0, 'X', is_roman
	beq  $t0, 'V', is_roman
	beq  $t0, 'I', is_roman
	beq  $t0, '\n', reached_end
	
	#input was no roman number
	printString(not_a_number)
	move $v0, $zero
	j .end
	
	is_roman:
		addi $a0, $a0, 1
		jal check_roman
		j .end

	reached_end:
		sb $0, ($a0)
		printString(num_roman)
		addi $v0, $zero, 1

	#reset stack
	.end:
		lw $ra, 4($sp)
		lw $a0, 0($sp)
		addi $sp, $sp, 8

	jr $ra

# a0: The address of the buffer
# a1: Must be initialized with the value 0
# $v0: Returns the roman number to decimal
roman_to_decimal:
	addi $sp, $sp, -4
	sw $ra, ($sp)

	lb $t0, ($a0)
	li $t1, 0

	# Switch case implementation 
	beq $t0, 'M', M
	beq $t0, 'D', D
	beq $t0, 'C', C
	beq $t0, 'L', L
	beq $t0, 'X', X
	beq $t0, 'V', V
	beq $t0, 'I', I
	beq $t0, '\0', end

	M:
		li $t0, 1000
		beq $t0, $a1, L2
		j L1

	D:
		li $t0, 500
		j L1

	C:
		li $t0, 100
		ble $t0, $a1, L2
		bne $a1, $0, L1
		li $a1, 100
		j out

	L:
		li $t0, 50
		j L1

	X:
		li $t0, 10
		ble $t0, $a1, L2
		bne $a1, $0, L1
		li $a1, 10
		j out

	V:
		li $t0, 5
		j L1

	I:
		li $t0, 1
		ble $t0, $a1, L2
		li $a1, 1
		j out

	# Subtruct carry
	L1:
		sub $t1, $t0, $a1
		j L3

	# Add carry to loaded value
	L2:
		add $t1, $a1, $t0

	# Clear a1
	L3:
		move $a1, $0

	# Add final value to v0
	out:
		add $v0, $v0, $t1
		addi $a0, $a0, 1
		jal roman_to_decimal
		j return

	# When the number finishes, add the remaining carry
	end:
		add $v0, $v0, $a1

	return:
		lw $ra, ($sp)
		add $sp, $sp, 4
		jr $ra
