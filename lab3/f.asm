.text
.globl main
main:
	li $a0, 3
	li $a1, 5
	jal f

	li $v0, 10
	syscall

f:
	beqz $a0, m
	beqz $a1, n

	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $a1, ($sp)

	addi $a0, $a0, -1
	jal f

	lw $a0, 4($sp)
	lw $a1, ($sp)
	addi $sp, $sp, 4
	sw $v0, ($sp)
	addi $a1, $a1, -1
	jal f

	lw $t0, ($sp)
	add $v0, $v0, $t0

	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra

	m:
		move $v0, $a1
		jr $ra

	n:
		move $v0, $a0
		jr $ra
