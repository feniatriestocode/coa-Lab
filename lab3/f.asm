.text
.globl main
main:
	li $a0, 8
	li $a1, 9
	jal f

	li $v0, 10
	syscall

f:
	beqz $a0, m
	beqz $a1, n

	addi $sp, $sp, -4
	sw $ra, ($sp)

	addi $a0, $a0, -1
	jal f
	addi $a0, $a0, 1

	addi $a1, $a1, -1
	jal f
	addi $a1, $a1, 1

	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

	m:
		add $v0, $v0, $a1
		jr $ra

	n:
		add $v0, $v0, $a0
		jr $ra