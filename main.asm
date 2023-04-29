	.globl main
	
	.include "syscalls.asm"
	.include "bmp_data.asm"
	.include "complex.asm"
	
	.data
	
input: 	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/lena.bmp"
output:	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/lenaAfter.bmp"
hello:	.asciz	"Welcome to Julia set generator"
error:	.asciz	"\nCould not open file\n"
	.text

main:
	li	a7, INSTR
	la 	a0, hello
	ecall	
	
	jal open_bmp_file


padding:
	# padding: t5 = (4 - (width % 4)) % 4
	li	t4, 4
	remu	t5, s1, t4
	sub	t5, t4, t5
	remu	t5, t5, t4

start_table_iterator:
	mv	t0, s5		# t0 = start -> iterator
	add	t6, s5, s3	# t6 = start + size -> end

loop:
	bge	t0, t6, end_loop
	lbu	t1, (t0)
	
	sb	t1, (t0)
	addi	t0, t0, 1
	b	loop	

end_loop:
	jal open_dest_file

exit:
	li	a7, EXIT
	ecall


##### read bmp file function
open_bmp_file:
	la	a0, input
	mv	a1, zero	# read only mode
	li 	a7, OPEN
	ecall
	
	li	t0, -1
	beq	a0, t0, open_bmp_error

	mv	s0, a0		# save the file descriptor

read_headers:
	mv	a0, s0
	la	a1, BitMapFileHeader
	li	a2, FileHeaderSIZE
	li	a7, READ
	ecall

	# this is stupid, but fixes alignment problems
	la	t0, headerbreak
	sh	zero, (t0)
	
	mv	a0, s0
	la	a1, BitMapInfoHeader
	li	a2, InfoHeaderSIZE
	li	a7, READ
	ecall

get_dims:
	la	t0, BitMapInfoHeader
	lw 	s1, biWidthStart(t0)		# s1 = width
	lw	s2, biHeightStart(t0)		# s2 = height
	lw	s3, biTableSizeStart(t0)	# s3 = full size in bytes

create_table:
	# let's pretend sbrk always works
	mv	a0, s3
	li	a7, HEAP
	ecall
	
	mv	s5, a0		# s5 = table pointer

copy_table:
	# read all bitMap table into buffer at once
	mv	a0, s0				# s0 - file descriptor
	mv	a1, s5				# s5 - table pointer
	mv	a2, s3				# s3 - full size in bytes
	li	a7, READ
	ecall
	
close_source_file:
	mv	a0, s0
	li	a7, CLOSE
	ecall

	ret

open_bmp_error:
	li	a7, INSTR
	la 	a0, error
	ecall
	
	li	a7, ERROR
	ecall
	
	ret


##### write to bmp file function
open_dest_file:
	la	a0, output
	li	a1, 1		# write-only
	li	a7, OPEN
	ecall
	
	mv	s0, a0

write_headers:
	mv	a0, s0
	la	a1, BitMapFileHeader
	li	a2, FileHeaderSIZE
	li	a7, WRITE
	ecall

	mv	a0, s0
	la	a1, BitMapInfoHeader
	li	a2, InfoHeaderSIZE
	li	a7, WRITE
	ecall

write_table:
	mv	a0, s0
	mv	a1, s5
	mv	a2, s3
	li	a7, WRITE
	ecall

close_dest_file:
	mv	a0, s0
	li	a7, CLOSE
	ecall
	
	ret
