	.globl main
	
	.include "syscalls.asm"
	
	.data
input: 	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/lena.bmp"
output:	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/lena_Julia_set.bmp"
error:	.asciz	"\nCould not open file\n"
	.text

main:

open_bmp_file:
	la	a0, input
	mv	a1, zero	# read only mode
	li 	a7, OPEN
	ecall
	
	li	t0, -1
	beq	a0, t0, open_bmp_error

	mv	s0, a0		# save the file descriptor

open_bmp_error:
	li	a7, INSTR
	la 	a0, error
	ecall
	
	li	a7, ERROR
	ecall