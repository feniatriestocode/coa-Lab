.data
	d: .asciiz "LII"

.text
.globl main
main:
	la $a0, d
	li $a1, 0
	jal roman_to_decimal

	move $a0, $v0
	li $v0, 1
	syscall

	li $v0, 10
	syscall

roman_to_decimal:
	addi $sp, $sp, -4
	sw $ra, ($sp)

	lb $t0, ($a0)
	li $t1, 0

	beq $t0, 'M', M
	beq $t0, 'D', D
	beq $t0, 'C', C
	beq $t0, 'L', L
	beq $t0, 'X', X
	beq $t0, 'V', V
	beq $t0, 'I', I
	beq $t0, '\0', return

	M:
		li $t0, 1000
		beq $t0, $a1, L2
		j L1

	D:
		li $t0, 500
		j L1

	C:
		li $t0, 100
		beq $t0, $a1, L2
		bne $a1, $0, L1
		li $a1, 100
		j out

	L:
		li $t0, 50
		j L1

	X:
		li $t0, 10
		beq $t0, $a1, L2
		bne $a1, $0, L1
		li $a1, 10
		j out

	V:
		li $t0, 5
		j L1

	I:
		li $t0, 1
		beq $t0, $a1, L2
		li $a1, 1
		j out

	L1:
		sub $t1, $t0, $a1
		j L3

	L2:
		add $t1, $a1, $t0

	L3:
		move $a1, $0

	out:
		add $v0, $v0, $t1
		addi $a0, $a0, 1
		jal roman_to_decimal

	return:
		add $v0, $v0, $t0
		lw $ra, ($sp)
		add $sp, $sp, 4
		jr $ra
