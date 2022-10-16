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
