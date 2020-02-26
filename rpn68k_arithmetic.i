;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T

LS_ARITHMETIC_BASE macro
	IF NARG=2  			; Called with argument
		IFC \0,L			; 32-bit operation
			LS_CACHE.l
			\1.l \2,d0		;   Add value to cached TOS (d0)
		ELSE						;		16-bit operation
			LS_CACHE
			\1 \2,d0			;   Add value to d0
		ENDC

	ELSE							; No argument
		IFC \0,L				; 32-bit operation

			LS_CACHE.l			; Cache TOS
			\1.l (a7)+,d0		; Apply operation for two topmost
											; values in stack
			LS_SET LOCAL,LOCAL-4	; Adjust local variable offset

		ELSE							; 16-bit operation
			LS_CACHE				; Cache TOS
			\1.w (a7)+,d0		; Apply operation for two topmost
											; values in stack
			LS_SET LOCAL,LOCAL-2	; Adjust local variable offset
		ENDC
	ENDC
	endm

LS_ARITHMETIC_BASE_COPY macro
	IF NARG=2
		IFC \0,L
			LS_CACHE.l
			\1.l \2,d0
		ELSE
			LS_CACHE
			\1 \2,d0
		ENDC
	ELSE
		IFC \0,L
			LS_CACHE.l
			\1.l (a7)+,d0
			LS_SET LOCAL,LOCAL-4
		ELSE
			LS_CACHE
			\1 (a7)+,d0
			LS_SET LOCAL,LOCAL-2
		ENDC
	ENDC
	endm

LS_ARITHMETIC_BASE_2 macro
	LS_OP_SIZE ar_base_2,\0
	IF NARG=2
		IF OP_SIZE_ar_base_2=4
			LS_CACHE.L
			\1.L \2,d0
		ELSE
			LS_CACHE
			\1 \2,d0
		ENDC
	ELSE
		IF OP_SIZE_ar_base_2=4
			LS_CACHE.L
			\1.L d0,(a7)
			drop
		ELSE
			LS_CACHE
			\1 d0,(a7)
			drop
		ENDC
	ENDC
	endm

LS_ARITHMETIC_BASE_3 macro
	LS_OP_SIZE ar_base_3,\0

	IF OP_SIZE_ar_base_3=4
		IF NARG=2
			ldc.l \2
		ENDIF
		LS_CACHE.l
		\1.l d0,(a7)
		drop
	ELSE
		IF NARG=2
			ldc \2
		ENDIF
		LS_CACHE
		\1 d0,(a7)
		drop
	ENDC  

	endm

LS_ROT_BASE macro
	LS_OP_SIZE rot_base,\0
	IF NARG=2
		IF OP_SIZE_rot_base=4     ; 32-bit operation
			LS_CACHE.L
			\1.L \2,d0
		ELSE
			LS_CACHE
			\1 \2,d0
		ENDC
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC
		IF OP_SIZE_rot_base=4			; 32-bit operation
			LS_CACHE.L
			\1.L d1,d0
		ELSE
			LS_CACHE
			\1 d1,d0
		ENDC
	ENDC
	endm

; todo div.l should use 32-bit source value
div macro
	IFNB \1
		LS_CACHE
		ext.l d0
		divs \1,d0
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC

		LS_CACHE
		ext.l d0        
		divs d1,d0
	ENDC
	endm

div12f macro
	IFNB \1
		LS_CACHE
		ext.l d0
		asl.l #6,d0
		asl.l #6,d0
		divs \1,d0
	ELSE 
		IF LS_CACHED=0
			move.w (a7)+,d1
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC

		LS_CACHE
		ext.l d0        
		asl.l #6,d0
		asl.l #6,d0
		divs d1,d0
	ENDC
	endm

; todo mod.l should use 32-bit source value
mod macro
	IFNB \1
		LS_CACHE
		ext.l d0
		divs \1,d0
		swap d0
	ELSE
		IF LS_CACHED=0
			move.w (a7)+,d1
			LS_SET LOCAL,LOCAL-2
		ELSE
			move.w d0,d1
			drop
		ENDC

		LS_CACHE
		ext.l d0
		divs d1,d0
		swap d0
	ENDC
	endm

add_to macro 
	IF LS_CACHED=0
		add.\0 (a7)+,\1
		IFC \0,l
			LS_SET LOCAL,LOCAL-4
		ELSE
			LS_SET LOCAL,LOCAL-2
		ENDC
	ELSE
		IF LS_CACHED=4
			add.l d0,\1
		ELSE
			add.W d0,\1
		ENDC
		drop
	ENDC
	endm

add_ macro
	LS_ARITHMETIC_BASE.\0 add,\1
	endm

sub_ macro
	LS_ARITHMETIC_BASE_2.\0 sub,\1
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

mul macro
	IFNB \1
		LS_CACHE
		muls \1,d0
	ELSE
		LS_CACHE
		muls (a7)+,d0
		LS_SET LOCAL,LOCAL-2
	ENDC

	IFC \0,L
		LS_SET LS_CACHED,4 	; return value for mul.l is int32
	ENDC
	endm

mul12f macro
	mul.L \1
	asr_.L #6
	asr_.L #6
	restore		; cache is now 16-bit
	endm

square12f macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	muls d0,d0
	asr_.l #6
	asr_.l #6
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
	LS_ROT_BASE.\0 asl,\1
	endm

asr_ macro
	LS_ROT_BASE.\0 asr,\1
	endm

rol_ macro
	LS_ROT_BASE.\0 rol,\1
	endm

ror_ macro
	LS_ROT_BASE.\0 ror,\1
	endm

neg_ macro
	IFC \0,L
		LS_CACHE.l
		neg.l d0
	ELSE
		LS_CACHE
		neg.w d0
	endm

min macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	cmp.w (a7),d0

	dc.w $6e04		; asmone workaround
	addq #2,a7

	dc.w $6002		; asmone workaround
	move.w (a7)+,d0

LOCAL set LOCAL-2
	endm


max macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	cmp.w (a7),d0

	dc.w $6e04		; asmone workaround
	move.w (a7)+,d0

	dc.w $6002		; asmone workaround
	addq #2,a7

LOCAL set LOCAL-2
	endm


umin macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	cmp.w (a7),d0

	dc.w $6204		; asmone workaround
	addq #2,a7

	dc.w $6002		; asmone workaround
	move.w (a7)+,d0


LOCAL set LOCAL-2
	endm


umax macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	cmp.w (a7),d0

	dc.w $6204		; asmone workaround
	move.w (a7)+,d0

	dc.w $6002		; asmone workaround
	addq #2,a7

LOCAL set LOCAL-2
	endm
