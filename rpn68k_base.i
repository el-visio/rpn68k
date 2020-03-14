;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T
;
;	Fundamental macros and commands for rpn68k
;


LS_SET macro
\1 SET \2
	endm

LS_INC macro
\1 SET \1+1
	endm

RPN68K_INIT macro
	LS_SET      LS_CACHED,0
	LS_SET      LOCAL,0
	LS_SET      LS_LABEL_NUM,1
	LS_SET      _0,0
	LS_SET      _1,0
	LS_SET      _2,0
	LS_SET      _3,0
	LS_SET      _4,0
	LS_SET      _5,0
	LS_SET      _6,0
	LS_SET      _7,0
	LS_SET      _8,0
	LS_SET      _9,0
	LS_SET      _a,0
	LS_SET      _b,0
	LS_SET      _c,0
	LS_SET      _d,0
	LS_SET      _e,0
	LS_SET      _f,0

; local variables mask in cs stack
LS_MASK_LOCAL equ $ff

; local variables shift amount in cs stack
LS_SHIFT_LOCAL equ 24

; label number mask in cs stack
LS_MASK_LABEL equ ((1<<LS_SHIFT_LOCAL)-1)

	endm

;	LS_FLUSH - Flush top of stack
;
;	If d0 has cached top of stack, move it to the actual stack
;	in the memory

LS_FLUSH macro
	IF LS_CACHED=2
		move.w d0,-(a7)
	ELSE
	IF LS_CACHED=4
		move.l d0,-(a7)
	ENDC
	ENDC

	LS_SET LOCAL,LOCAL+LS_CACHED
	LS_SET LS_CACHED,0
	endm


;	LS_CACHE
;	Cache top of stack
;
;	If the cache is currently empty, move the top of stack to d0

LS_CACHE macro
	IF LS_CACHED=0
		LS_FLAGS.\0 cache,\1

		IF LSF_cache&LSF_L 	; 32-bit
			move.l (a7)+,d0
		ELSE								; 16-bit
			move.w (a7)+,d0
		ENDC

		LS_SET LS_CACHED,LSF_cache&LSF_SIZE_MASK
		LS_SET LOCAL,LOCAL-(LSF_cache&LSF_SIZE_MASK)

	ENDC
	endm


; 	var
;	Set local variable name.

var macro										; todo don't flush
	LS_FLUSH
	LS_SET \1,(-LOCAL)
	endm


LS_ARGSIZE macro
	LS_FLUSH
	LS_SET __ARGOFF,(\1)
	endm


LS_ARG macro
	IFC \0,L
		LS_SET __ARGOFF,(__ARGOFF-4)
		LS_SET \1,(__ARGOFF-LOCAL)
	ELSE
		LS_SET __ARGOFF,(__ARGOFF-2)
		LS_SET \1,(__ARGOFF-LOCAL)
	ENDC
	endm

	
alloc macro
	IFNB \2
		ldc.l \2
	ENDC

	LS_CACHE.l
	move.l \1,a1
	add.l d0,\1
	move.l a1,d0

	endm


alloc_64k macro
	IFNB \2
		ldc.l \2
	ENDC

	LS_CACHE.l
	
	dup.l
	restore
	neg_

	if_ulo 2+\1
		add.w #$1,\1
		move.w #0,2+\1
	end_if

	alloc \1

	endm


;	Push internal control structure stack

LS_PUSH_CS macro
_f SET  _e
_e SET _d
_d SET _c
_c SET _b
_b SET _a
_a SET _9
_9 SET _8
_8 SET _7
_7 SET _6
_6 SET _5
_5 SET _4
_4 SET _3
_3 SET _2
_2 SET _1
_1 SET _0
_0 SET \1
	endm


;	Drop internal control structure stack

LS_DROP_CS macro
_0 SET _1
_1 SET _2
_2 SET _3
_3 SET _4
_4 SET _5
_5 SET _6
_6 SET _7
_7 SET _8
_8 SET _9
_9 SET _a
_a SET _b
_b SET _c
_c SET _d
_d SET _e
_e SET _f
_f SET 0
	endm


; swap <one> <many> -> <many> <one>

LS_SWAP_CS_ONE_MANY macro
	LS_SET LS_TEMP,(_1>>LSCS_AND_IF_SHIFT)&LSCS_AND_IF_MASK
	LS_SET LS_TEMP_TOP,_0

	IF LS_TEMP=0
LS_SWAP_TMP set _0
_0 set _1
_1 set LS_SWAP_TMP
	ENDC

	IF LS_TEMP=1
LS_SWAP_TMP set _0
_0 set _1
_1 set _2
_2 set LS_SWAP_TMP
	ENDC

	IF LS_TEMP=2
LS_SWAP_TMP set _0
_0 set _1
_1 set _2
_2 set _3
_3 set LS_SWAP_TMP
	ENDC

	IF LS_TEMP=3
LS_SWAP_TMP set _0
_0 set _1
_1 set _2
_2 set _3
_3 set _4
_4 set LS_SWAP_TMP
	ENDC

	endm


; swap <many> <one> -> <one> <many>

LS_SWAP_CS_MANY_ONE macro
	LS_SET LS_TEMP,(_0>>LSCS_AND_IF_SHIFT)&LSCS_AND_IF_MASK

	IF LS_TEMP=0
LS_SWAP_TMP set _1
_1 set _0
_0 set LS_SWAP_TMP
	ENDC

	IF LS_TEMP=1
LS_SWAP_TMP set _2
_2 set _1
_1 set _0
_0 set LS_SWAP_TMP
	ENDC

	IF LS_TEMP=2
LS_SWAP_TMP set _3
_3 set _2
_2 set _1
_1 set _0
_0 set LS_SWAP_TMP
	ENDC

	IF LS_TEMP=3
LS_SWAP_TMP set _4
_4 set _3
_3 set _2
_2 set _1
_1 set _0
_0 set LS_SWAP_TMP
	ENDC

	endm


;	push
;	Push to stack (alias for ld)

push macro
	ld.\0 \1
	endm


;	pop
;	Pop from stack (alias for sto)

pop macro
	sto.\0 \1
	endm


;	ld
;
;	load value to stack

ld macro
	LS_FLAGS.\0 ld,\1,\2,\3

	LS_FLUSH	; Flush cached value if any

	IF LSF_ld&LSF_W
		move.w \1,-(a7)					; 16-bit
	ELSE
		move.l \1,-(a7)					; 32-bit
	ENDC

	LS_SET LOCAL,LOCAL+(LSF_ld&LSF_SIZE_MASK)

	IF LSF_ld&LSF_HAS_ARG2
		var \2
	ENDC

	endm


;	ldc 
;
;	load value to cache

ldc macro
	LS_FLAGS.\0 ldc,\1,\2,\3

	LS_FLUSH

	IF LSF_ldc&LSF_W
		move.w \1,d0							; 16-bit
	ELSE
	IF LSF_ldc&LSF_L
		move.l \1,d0							; 32-bit
	ELSE
		move.b \1,d0							; 8-bit
		ext.w d0
		; Force cache size to 2
		LSF_B2W ldc
	ENDC
	ENDC

	LS_SET LS_CACHED,LSF_ldc&LSF_SIZE_MASK
	endm


;	Load address to stack

ld_addr macro
	LS_FLUSH
	pea \1
	LS_SET LOCAL,LOCAL+4
	endm


;	Store top of stack to location

sto macro
	LS_FLAGS.\0 sto,\1,\2

	IF LS_CACHED=2
		IF LSF_sto&LSF_W
			move.w d0,\1
		ELSE
			move.b d0,\1
		ENDC
	ELSE
	IF LS_CACHED=4
		move.l d0,\1
	ELSE
		IF LSF_sto&LSF_W
			LS_SET LOCAL,LOCAL-2
			move.w (a7)+,\1						; 16-bit
		ELSE
		IF LSF_sto&LSF_L
			LS_SET LOCAL,LOCAL-4
			move.l (a7)+,\1						; 32-bit
		ELSE
			LS_SET LOCAL,LOCAL-2
			move.b (a7)+,\1						; 8 bit
		ENDC
		ENDC
	ENDC
	ENDC

	LS_SET LS_CACHED,0

	endm


;	Store additive

sto_add macro 
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


;	Store substractive

sto_sub macro 
	LS_FLAGS.\0 add_to,\1,\2

	IF LS_CACHED=0
		IF LSF_add_to&LSF_W
			sub.w (a7)+,\1
		ELSE
			sub.l (a7)+,\1
		ENDC

		LS_SET LOCAL,LOCAL-(LSF_add_to&LSF_SIZE_MASK)
	ELSE
		IF LS_CACHED=4
			sub.l d0,\1
		ELSE
			sub.w d0,\1
		ENDC
		drop
	ENDC
	endm


;	drop 
;
;	Drop top of stack
;	(please use other methods for this where possible)

drop macro
	LS_FLAGS.\0 drop

	IF LS_CACHED>0
		LS_SET LS_CACHED,0
	ELSE
		addq #LSF_drop&LSF_SIZE_MASK,a7
		LS_SET LOCAL,LOCAL-(LSF_drop&LSF_SIZE_MASK)
	ENDC
	endm


;	Reset stack	(do this before you RTS)

RESET_STACK macro
	lea LOCAL(a7),a7
	LS_SET LOCAL,0
	endm


;	dup
;
;	Duplicate top of stack.

dup macro
	LS_FLAGS.\0 dup

	IF LS_CACHED=0
		IF LSF_dup&LSF_W
			move.w (a7),d0
		ELSE
			move.l (a7),d0
		ENDC
		LS_SET LS_CACHED,LSF_dup&LSF_SIZE_MASK
	ELSE
		IF LS_CACHED=4
			move.l d0,-(a7)
		ELSE
			move.w d0,-(a7)
		ENDC
		LS_SET LOCAL,LOCAL+LS_CACHED
	ENDC
	endm


;	restore
;
;	Restore previously cached value
; 	If used with argument it will be stored again in the
;	desired location

restore macro
	LS_FLAGS.\0 restore,\1,\2

	LS_SET LS_CACHED,LSF_restore&LSF_SIZE_MASK

	IF LSF_restore&LSF_HAS_ARG
		IF LSF_restore&LSF_W
			sto \1
		ELSE
			sto.l \1
		ENDC
	ENDC

	endm


;	LS_ARRAY_LEN
;
;	Helper macro to calculate array length
;
;	\1 label for length
;	\2 start offset
;	\3 element size
;

LS_ARRAY_LEN macro
\1 equ (*-\2)/(\3)
	endm
