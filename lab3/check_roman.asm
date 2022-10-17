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
	L1:
		printString(prompt)

		li $v0, 8
		la $a0, buffer
		li $a1, 10
		syscall

		jal check_roman
		beq $v0, 0, L1
		# jal roman_to_decimal
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
	j end
	
	is_roman:
		addi $a0, $a0, 1
		jal check_roman
		j end

	reached_end:
		printString(num_roman)
		addi $v0, $zero, 1
		sb $0, ($a0)

	#reset stack
	end:
		lw   $ra, 4($sp)
		lw   $a0, 0($sp)
		addi $sp, $sp, 8

	jr $ra