	.data
	.eqv    FHSIZE 14
	.eqv    IHSIZE 40
BitMapFileHeader: .space 14
headerbreak:	  .space 2	# necessary for allignment reasons
BitMapInfoHeader: .space 40
	.eqv    bfTableStart 10
	.eqv    biWidthStart 4
	.eqv    biHeightStart 8
	.eqv    biTableSizeStart 20
