	.eqv BITS_PER_BYTE 8
	.eqv FRACTION_BITS 16				# 1 << 16 = 2^16 = 65536
	.eqv FRACTION_DIVISOR (1 << FRACTION_BITS)
	.eqv FRACTION_MASK (FRACTION_DIVISOR - 1)	# 65535 (all LSB set, all MSB clear)