	.globl main
	
	.include "syscalls.asm"
	.include "bmp_data.asm"
	.include "complex.asm"
	
	.data
	
input: 	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/lena.bmp"
output:	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/lenaAfter.bmp"
hello:	.asciz	"Welcome to Mandelbrot set generator!"
bye:	.asciz	"\nMandelbrot set was generated. Have a good day!"
error:	.asciz	"\nCould not open file\n"

	.text

main:
	li	a7, INSTR
	la 	a0, hello
	ecall	
	
	jal open_bmp_file
	jal start_table_iterator
	jal open_dest_file

	li	a7, INSTR
	la 	a0, bye
	ecall
	
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
	mv	a0, s3
	li	a7, HEAP
	ecall
	
	mv	s5, a0				# s5 = table pointer

copy_table:
	# read all bitMap table into buffer at once
	mv	a0, s0				# s0 = file descriptor
	mv	a1, s5				# s5 = table pointer
	mv	a2, s3				# s3 = full size in bytes
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


##### mandelbrot generator
start_table_iterator:
	mv	t0, s5		# t0 = start -> iterator
	add	t6, s5, s3	# t6 = start + size -> end

loop:
	bge	t0, t6, end_loop
	lbu	t1, (t0)
	
	lb	t2, 0(t0)
	lb	t3, 1(t0)
	lb	t4, 2(t0)
		
	li t2, 50        # Set the red component to maximum value
	li t3, 0          # Set the green component to minimum value
	li t4, 0          # Set the blue component to minimum value
	
	# Save the modified BMP file back to disk
	sb t2, 0(t0)      # Store the red component of the pixel
	sb t3, 1(t0)      # Store the green component of the pixel
	sb t4, 2(t0)      # Store the blue component of the pixel
	
	#sb	t1, (t0)
	addi	t0, t0, 1
	b	loop	

end_loop:
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
