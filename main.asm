	.globl main
	
	.include "syscalls.asm"
	.include "bmp_data.asm"
	.include "complex.asm"
	
	.data
	
input: 	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/small.bmp"
output:	.asciz  "/Users/domin/Desktop/studia/sem2_23L/ARKO/RISC V/Julia-set/smallAfter.bmp"
hello:	.asciz	"\nWelcome to Mandelbrot set generator!\n"
bye:	.asciz	"\nMandelbrot set was generated. Have a good day!"
error:	.asciz	"\nCould not open file\n"

	.text

main:
	li	a7, INSTR
	la 	a0, hello
	ecall	
	
	jal	open_bmp_file

##### mandelbrot set generator
start_table_iterator:
	mv	t0, s5		# t0 = start -> iterator
	add	t6, s5, s3	# t6 = start + size -> end
	
	li	t2, 0
loop_width:
	bge	t2, s1, end_loop
	bge	t0, t6, end_loop
	
	li	t3, 0
loop_height:
	bge	t0, t6, end_loop
	
	# complex number real part = (RE_START + (x / WIDTH) * (RE_END - RE_START)
	div	s6, t2, s1
	li	s8, RE_START
	add	s6, s6, s8
	li	s9, RE_END
	sub	s9, s9, s8
	mul	s6, s6, s9	# s6 = complex number real part

	# complex number imaginary part = IM_START + (y / HEIGHT) * (IM_END - IM_START))
	div	s7, t3, s2
	li	s8, IM_START
	add	s7, s7, s8
	li	s9, IM_END
	sub	s9, s9, s8
	mul	s7, s7, s9	# s7 = complex number imaginary part
	
	jal	mandelbrot
	
	# hue = int(255 * m / MAX_ITER)
	li	t4, 255
	mul	s8, s10, t4
	div	s8, s8, s11		# s8 = hue
	
	# value = 255 if m < MAX_ITER else 0
	bge	s10, s11, val_zero
	li	s9, 255

store:
	bge	t0, t6, end_loop
	# store blue
	sb	s9, (t0)
	# store green
	addi	t0, t0, 1
	bge	t0, t6, end_loop
	sb	t4, (t0)
	# store red
	addi	t0, t0, 1
	bge	t0, t6, end_loop
	sb	s8, (t0)

	addi	t0, t0, 1
	
	beq	t3, s2, next_width
	addi	t3, t3, 1
	b	loop_height

next_width:
	addi	t2, t2, 1
	b	loop_width

val_zero:
	li	s9, 0
	b	store	

end_loop:
	jal 	open_dest_file

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


##### mandlebrot
mandelbrot:
	li	s8, 0		# s8 = z real part
	li	s9, 0		# s9 = z imaginary part
	li	s10, 0		# s10 = n
	li	s11, MAX_ITER
	
mloop:
	# s4 = abs(z)	where z = s8 + s9 * i
	mv	t4, s8
	mv	t5, s9
	
	mul	t4, t4, t4
	mul	t5, t5, t5
	add	s4, t4, t5
	
	li	t4, 4	
	bgt	s4, t4, end_mloop
	li	t4, MAX_ITER
	bge	s4, t4, end_mloop
	
	# z = z*z + c
	# s8 = s8^2 - s9^2 + s6
	mv	t4, s8		# save s8 for counting new s9
	mul	s8, s8, s8
	mul	t5, s9, s9
	sub	s8, s8, t5
	add	s8, s8, s6

	# s9 = 2 * s8 * s9 + s7
	li	t5, 2
	mul	s9, s9, t5
	mul	s9, s9, t4
	add	s9, s9, s7
	
	# n += 1
	addi	s10, s10, 1
	b mloop	

end_mloop:
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
