.data
	array: 	.byte 0x70,0x8C,0xF3,0x82,0x1B,0x9D,0x52,0x3C,0x46
	msg1: 	.asciiz "Give pointer:\n"
	msg2: 	.asciiz "Give offset:\n"
	msg3: 	.asciiz "Give nbits:\n"
	.align 2
		store: .word 0

.text
.globl main
	# s0: &array 
	# s1: pointer
	# s2: offset
	# s3: nbits
	# s4: byte to store
	# t0: constant (8)
	# t1: constant (32)
	# t2: &store
	# t3: bit counter (for the ones we read)
	# t4:
	# t9: bits to shift left
main:
	la $s0, array
	li $t0, 8
	li $t1, 32

	la $a0, msg1
	jal print_str
	jal read_int
	move $s1, $v0

	la $a0, msg2
	jal print_str
	jal read_int
	move $s2, $v0

	la $a0, msg3
	jal print_str
	jal read_int
	move $s3, $v0

	# Add pointer value to the array address
	add $s0, $s0, $s1

	la $t2, store + 3

	# Add offset and nbits together
	add $t4, $s2, $s3
	sub $t5, $t1, $t4
	move $t9, $0
	bgt $t4, 8, L1
	sub $t9, $t0, $t4
	
	L1:
		lb $s4, ($s0)
		move $a0, $s2
		jal create_mask_right
		move $t8, $v0
		move $a0, $t9
		jal create_mask_left
		and $v0 , $v0, $t8
		lb $s4, ($s0)
		and $s4, $v0, $s4
		sb $s4, ($t2)
		add $t4, $s2, $t9
		sub $t3, $t0, $t4
		sub $s3, $s3, $t3
		beq $0, $s3, finale
		addi $s0, $s0, 1
		addi $t2, $t2, -1

		bgt $s3, 8, set_offsets
		move $s2, $0
		move $t9, $t5
		j L1

		set_offsets:
			move $s2, $0
			move $t9, $0
			j L1

	finale:
		lw $a0, store
		srlv $a0, $a0, $t5
		jal print_hex
		
		li $v0, 10
		syscall
	
print_str:
	li $v0, 4
	syscall
	jr $ra

print_hex:
	li $v0, 34
	syscall
	jr $ra

read_int:
	li $v0, 5
	syscall
	jr $ra

create_mask_left:
	addi $sp, $sp, -4
	sw $t0, ($sp)

	li $t0, 0xff
	sllv $v0, $t0, $a0

	lw $t0, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
create_mask_right:
	addi $sp, $sp, -4
	sw $t0, ($sp)

	li $t0, 0xff
	srlv $v0, $t0, $a0

	lw $t0, ($sp)
	addi $sp, $sp, 4
	jr $ra