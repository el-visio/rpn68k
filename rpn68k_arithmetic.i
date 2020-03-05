;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T

LS_ARITHMETIC_BASE macro
	LS_FLAGS.\0 ab,\2,\3

	IF LSF_ab&LSF_HAS_ARG 	; Called with argument
		IF LSF_ab&LSF_W
			LS_CACHE
			\1 \2,d0								; Apply operation to cached TOS (16-bit)
		ELSE
			LS_CACHE.l
			\1.l \2,d0							; Apply operation to cached TOS (32-bit)
		ENDC

	ELSE												; No argument
		IF LSF_ab&LSF_W
			LS_CACHE
			\1.w (a7)+,d0						; Apply operation for two topmost
															; values in stack (16-bit)

		ELSE
			LS_CACHE.l
			\1.l (a7)+,d0						; Apply operation for two topmost
															; values in stack (32-bit)
		ENDC
		LS_SET LOCAL,LOCAL-(LSF_ab&LSF_SIZE_MASK)
	ENDC
	endm


LS_ARITHMETIC_BASE_2 macro
	LS_FLAGS.\0 ab2,\2,\3

	IF LSF_ab2&LSF_HAS_ARG
		IF LSF_ab2&LSF_W
			LS_CACHE
			\1.w \2,d0
		ELSE
			LS_CACHE.l
			\1.l \2,d0
		ENDC
	ELSE
		IF LSF_ab2&LSF_W
			LS_CACHE
			\1.w d0,(a7)
			drop
		ELSE
			LS_CACHE.l
			\1.l d0,(a7)
			drop
		ENDC
	ENDC
	endm


LS_ARITHMETIC_BASE_3 macro
	LS_FLAGS.\0 ab3,\2,\3

	IF LSF_ab3&LSF_W
		IF LSF_ab3&LSF_HAS_ARG
			ldc \2
		ELSE
			LS_CACHE
		ENDC

		\1 d0,(a7)
	ELSE
		IF LSF_ab3&LSF_HAS_ARG
			ldc.l \2
		ELSE
			LS_CACHE.l
		ENDC

		\1.l d0,(a7)
	ENDC  
	drop

	endm


LS_ROT_BASE macro
	LS_FLAGS.\0 rotb,\2,\3

	IF LSF_rotb&LSF_HAS_ARG
		IF LSF_rotb&LSF_W
			LS_CACHE
			\1 \2,d0
		ELSE
			LS_CACHE.l
			\1.l \2,d0
		ENDC
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1
			LS_SET LOCAL,LOCAL-2
		ELSE										; Todo cache is not supposed to be 4
			move.w d0,d1
			drop
		ENDC

		IF LSF_rotb&LSF_W
			LS_CACHE
			\1 d1,d0
		ELSE
			LS_CACHE.l
			\1.l d1,d0
		ENDC
	ENDC
	endm


LS_ARITHMETIC_S_BASE macro
	LS_FLAGS.\0 asingle,\2,\3

	IF LSF_asingle&LSF_W
		IF LSF_asingle&LSF_HAS_ARG
			ldc \2
		ELSE
			LS_CACHE
		ENDC
		\1.w d0
	ELSE
		IF LSF_asingle&LSF_HAS_ARG
			ldc.l \2
		ELSE
			LS_CACHE.l
		ENDC
		\1.l d0
	ENDC
	endm


;	div
;
;	div   int16 value / int16 divider -> int16 result
;	div.l int32 value / int16 divider -> int16 result

div macro
	LS_FLAGS.\0 div,\1,\2

	IF LSF_div&LSF_HAS_ARG
		IF LSF_div&LSF_W
			LS_CACHE.w
			ext.l d0
		ELSE
			LS_CACHE.l
		ENDC
		divs \1,d0
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1					; divider is 16-bit
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC


		IF LSF_div&LSF_W
			LS_CACHE
			ext.l d0
		ELSE
			LS_CACHE.l
		ENDC

		divs d1,d0
	ENDC

	restore		; result is 16 bit
	endm



;	udiv
;
;	Divide unsigned
;
;	udiv   uint16 value / uint16 divider -> uint16 result
;	udiv.l uint32 value / uint16 divider -> uint16 result

udiv macro
	LS_FLAGS.\0 udiv,\1,\2

	IF LSF_udiv&LSF_HAS_ARG
		IF LSF_udiv&LSF_W
			LS_CACHE
			and.l #$ffff,d0
		ELSE
			LS_CACHE.l
		ENDC
		divu \1,d0
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1					; divider is 16-bit
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC

		IF LSF_udiv&LSF_W
			LS_CACHE
			and.l #$ffff,d0
		ELSE
			LS_CACHE.l
		ENDC

		divu d1,d0
	ENDC

	restore		; result is 16 bit
	endm


;	div12f
;
;	Divide 12-bit fixed point
;
;	div12f   int16 value / int16 divider -> int16 result
;	div12f.l int32 value / int16 divider -> int16 result

div12f macro
	LS_FLAGS.\0 div,\1,\2

	IF LSF_div&LSF_HAS_ARG
		IF LSF_div&LSF_W
			LS_CACHE
			ext.l d0
		ELSE
			LS_CACHE.l
		ENDC

		asl.l #6,d0
		asl.l #6,d0
		divs \1,d0
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1					; divider is 16-bit
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC

		IF LSF_div&LSF_W
			LS_CACHE
			ext.l d0
		ELSE
			LS_CACHE.l
		ENDC

		asl.l #6,d0
		asl.l #6,d0
		divs d1,d0
	ENDC

	restore		; result is 16 bit
	endm


;	mod
;
;	Get remainer from division
;
;	mod   int16 value % int16 divider -> int16 result
;	mod.l int32 value % int16 divider -> int16 result

mod macro
	LS_FLAGS.\0 mod,\1,\2

	IF LSF_mod&LSF_W
		div \1,\2
	ELSE
		div.l \1,\2
	ENDIF

	swap	d0
	endm


;	add_to
;
;	Add top of stack to address given in argument

add_to macro 
	LS_FLAGS.\0 add_to,\1,\2

	IF LS_CACHED=0
		IF LSF_add_to&LSF_W
			add.w (a7)+,\1
		ELSE
			add.l (a7)+,\1
		ENDC

		LS_SET LOCAL,LOCAL-(LSF_add_to&LSF_SIZE_MASK)
	ELSE
		IF LS_CACHED=4
			add.l d0,\1
		ELSE
			add.w d0,\1
		ENDC
		drop
	ENDC
	endm

add_ macro
	LS_ARITHMETIC_BASE.\0 add,\1,\2
	endm

sub_ macro
	LS_ARITHMETIC_BASE_2.\0 sub,\1,\2
	endm

inc macro
	IFC \0,L
		IFNB \1
			add.L #1,\1
		ELSE
			add_.L #1
		ENDC
	ELSE
		IFNB \1
			add.w #1,\1
		ELSE
			add_ #1
		ENDC
	ENDC
	endm


;	mul
;
;	Multiply
;
;	mul   int16 value * int16 multiplier -> int16 result
;	mul.l int16 value * int16 multiplier -> int32 result

mul macro
	LS_FLAGS.\0 mul,\1,\2

	LS_CACHE
	IF LSF_mul&LSF_HAS_ARG
		muls \1,d0
	ELSE
		muls (a7)+,d0
		LS_SET LOCAL,LOCAL-2
	ENDC

	IF LSF_mul&LSF_L
		LS_SET LS_CACHED,4 	; return value for mul.l is int32
	ENDC
	endm


;	mul12f
;
;	Multiply 12-bit fixed point
;
;	mul12f   int16 value * int16 multiplier -> int16 result
;	mul12f.l int16 value * int16 multiplier -> int32 result

mul12f macro
	LS_FLAGS.\0 mul12f,\1,\2

	mul.l \1
	asr.l #6,d0
	asr.l #6,d0

	IF LSF_mul12f&LSF_W
		restore					; cache is now 16-bit
	ENDC

	endm


;	square12f
;
;	Multiply 12-bit fixed point value by itself

square12f macro
	LS_FLAGS square12f,\1,\2

	IF LSF_square12f&LSF_HAS_ARG
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	IF LSF_square12f&LSF_W
		muls d0,d0
		asr.l #6,d0
		asr.l #6,d0
	ELSE
		muls d0,d0
		asr.l #6,d0
		asr.l #6,d0
		restore.l
	ENDC

	endm


and_ macro
	LS_ARITHMETIC_BASE.\0 and,\1
	endm


or_ macro
	LS_ARITHMETIC_BASE.\0 or,\1
	endm


xor_ macro
	LS_ARITHMETIC_BASE_3.\0 eor,\1
	endm


asl_ macro
	LS_ROT_BASE.\0 asl,\1,\2
	endm


asr_ macro
	LS_ROT_BASE.\0 asr,\1,\2
	endm


lsl_ macro
	LS_ROT_BASE.\0 lsl,\1,\2
	endm


lsr_ macro
	LS_ROT_BASE.\0 lsr,\1,\2
	endm


rol_ macro
	LS_ROT_BASE.\0 rol,\1,\2
	endm


ror_ macro
	LS_ROT_BASE.\0 ror,\1,\2
	endm


;	neg
;
;	Negate top of stack.

neg_ macro
	LS_ARITHMETIC_S_BASE.\0 neg,\1,\2
	endm


;	not
;
;	Logical not top of stack.

not_ macro
	LS_ARITHMETIC_S_BASE.\0 not,\1,\2
	endm


abs macro
	LS_FLAGS.\0 abs,\1,\2

	IF LSF_abs&LSF_W
		IF LSF_abs&LSF_HAS_ARG
			ldc \1
		ELSE
			LS_CACHE
		ENDC
		tst.w d0
	ELSE
		IF LSF_abs&LSF_HAS_ARG
			ldc.l \1
		ELSE
			LS_CACHE.l
		ENDC
		tst.l d0
	ENDC

	bpl.b *+4

	IF LSF_abs&LSF_W
		neg.w d0
	ELSE
		neg.l d0
	ENDC

	endm




LS_MINMAX_HEADER macro
	LS_FLAGS.\0 minmax,\1,\2

	IF LSF_minmax&LSF_HAS_ARG
		IF LSF_minmax&LSF_W
			ldc \1
		ELSE
			ldc.l \1
		ENDC
	ENDC

	IF LSF_minmax&LSF_W
		LS_CACHE
		cmp.w (a7),d0
	ELSE
		LS_CACHE.l
		cmp.l (a7),d0
	ENDC

	LS_SET LOCAL,LOCAL-(LSF_minmax&LSF_SIZE_MASK)
	endm


LS_MINMAX_DROP_TOP macro
	IF LSF_minmax&LSF_W
		move.w (a7)+,d0
	ELSE
		move.l (a7)+,d0
	ENDC
	endm


LS_MINMAX_DROP_2ND macro
	addq #LSF_minmax&LSF_SIZE_MASK,a7
	endm


LS_MINMAX_EXIT macro
	dc.w $6002		; asmone workaround branch BRA.b
	endm


LS_MINMAX_BGT macro
	dc.w $6e04		; asmone workaround branch BGT.b
	endm
	

LS_MINMAX_BHI macro
	dc.w $6204		; asmone workaround branch BHI.b
	endm


;	min
;
;	Get minimum value
		
min macro
	LS_MINMAX_HEADER.\0 \1,\2

	LS_MINMAX_BGT
	LS_MINMAX_DROP_2ND

	LS_MINMAX_EXIT
	LS_MINMAX_DROP_TOP

	endm


;	umin
;
;	Get minimum value (unsigned)
	
umin macro
	LS_MINMAX_HEADER.\0 \1,\2

	LS_MINMAX_BHI
	LS_MINMAX_DROP_2ND

	LS_MINMAX_EXIT
	LS_MINMAX_DROP_TOP
	endm


;	max
;
;	Get maximum value
		
max macro
	LS_MINMAX_HEADER.\0 \1,\2

	LS_MINMAX_BGT
	LS_MINMAX_DROP_TOP

	LS_MINMAX_EXIT
	LS_MINMAX_DROP_2ND

	endm


;	umax
;
;	Get maximum value (unsigned)

umax macro
	LS_MINMAX_HEADER.\0 \1,\2

	LS_MINMAX_BHI
	LS_MINMAX_DROP_TOP

	LS_MINMAX_EXIT
	LS_MINMAX_DROP_2ND

	endm
