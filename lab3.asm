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
	prompt:       .asciiz "Enter roman number.\n"
	not_a_number: .asciiz "Not a roman number.\n"
	num_roman:    .asciiz "Is roman number.\n"
	empty_string: .asciiz "No string found.\n"
	.align 2
	buffer:       .space 10
	string_end: 	.asciiz "/n"
	null_char:    .asciiz "/0"
.word 

.text

.globl main

main: 
	printString(prompt)
	li $v0, 8
	la $a0, buffer
	li $a1, 10
	syscall
	jal check_roman
	terminate
	
		
check_roman:
	addi $sp, $sp, -12
	sw   $ra, 8($sp)
	sw   $s0, 4($sp) #store register to preserve its contents
	sw   $a0, 0($sp) #store address of beginning of string
	
	lb   $s0, 0($a0)    #load first char
	beq  $s0, 'M', is_roman
	beq  $s0, 'D', is_roman
	beq  $s0, 'C', is_roman
	beq  $s0, 'L', is_roman
	beq  $s0, 'X', is_roman
	beq  $s0, 'V', is_roman
	beq  $s0, 'I', is_roman
	beq  $s0, '\n', reached_end
	
	#input was no roman number
	printString(not_a_number)
	move $v0, $zero 
	j end
	
is_roman:
	addi $a0, $a0, 1
	jal check_roman
	j end
reached_end:
	addi $v0, $zero, 1
	printString(num_roman)

end:
	#reset stack
	lw   $ra, 8($sp)
	lw   $s0, 4($sp) 
	lw   $a0, 0($sp) 
	addi $sp, $sp, 12

jr $ra