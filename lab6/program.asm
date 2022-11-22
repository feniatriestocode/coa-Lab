.text
.globl main            		 label "main" must be global

main:

label: add $t0, $t0, $s0       $t0 = $8 = 24 (D) 
       sw $ra, 4($t2)          Mem[$t2+4] = 31
       lw $t5, 4($t2)          $t5 = $13 = 31
       sub $t1, $t1, $a0       $t1 = $9 = 5
       or $t6, $t7, $t5        $t6 = $14 = 31
       and $s3, $s0, $s2       $s3 = $19 = 16
       lw $t6, 4($t2)          $t6 = $14 = 31
       sw $gp, 8($t2)          Mem[$t2+8] = 28
       lw $v0, 8($t2)          $v0 = $2 = 28
       and $a0, $v0, $t5       $a0 = $4 = 28, RAW stall
       or $a0, $a0, $t0        $a0 = $4 = 28, bypass from ALU
       add $t1, $a0, $v0       $t1 = $9 = 56, bypass from ALU 
       slt $sp, $a0, $t1       $sp = $29 = 1
       lw $v0, 8($t2)          $v0 = $2 = 28
       sll $s4, $v0, 12        $s4 = $20 = 0x0001c000, RAW stall
       sllv $s6, $s4, $sp      $s6 = $22 = 0x00038000, bypass from ALU
       addi $s6, $s6, -100     $s6 = $22 = 0x00037f9c
