;
;	Macros and commands for rpn68k
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

LS_FLUSH macro
	IF LS_CACHED=2
		move.w d0,-(a7)
		LS_SET LS_CACHED,0
		LS_SET LOCAL,LOCAL+2
	ELSE
	IF LS_CACHED=4
		move.l d0,-(a7)
		LS_SET LS_CACHED,0
		LS_SET LOCAL,LOCAL+4
	ENDC
	ENDC
	endm

LS_CACHE macro
	IF LS_CACHED=0
		IFC \0,L
			move.l (a7)+,d0
			LS_SET LS_CACHED,4
			LS_SET LOCAL,LOCAL-4
		ELSE
			move.w (a7)+,d0
			LS_SET LS_CACHED,2
			LS_SET LOCAL,LOCAL-2
		ENDC
	ENDC
	endm

var macro
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

LS_OP_SIZE macro
	IFC \2,L
OP_SIZE_\1 set 4
	ELSE
OP_SIZE_\1 set 2
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

LS_PUSH_CS macro
_f  SET         _e
_e  SET         _d
_d  SET         _c
_c  SET         _b
_b  SET         _a
_a  SET         _9
_9  SET         _8
_8  SET         _7
_7  SET         _6
_6  SET         _5
_5  SET         _4
_4  SET         _3
_3  SET         _2
_2  SET         _1
_1  SET         _0
_0  SET         \1
		endm

LS_DROP_CS macro
_0  SET         _1
_1  SET         _2
_2  SET         _3
_3  SET         _4
_4  SET         _5
_5  SET         _6
_6  SET         _7
_7  SET         _8
_8  SET         _9
_9  SET         _a
_a  SET         _b
_b  SET         _c
_c  SET         _d
_d  SET         _e
_e  SET         _f
_f  SET         0
		endm

LS_SWAP_CS macro
LS_SWAP_TMP set _0
_0 set _1
_1 set LS_SWAP_TMP
		endm

push macro
	ld.\0 \1
	endm

pop macro
	sto.\0 \1
	endm

ld macro
	IFC \0,L
		LS_FLUSH
		move.l \1,-(a7)
		LS_SET LOCAL,LOCAL+4
	ELSE
		LS_FLUSH
		move.w \1,-(a7)
		LS_SET LOCAL,LOCAL+2
	ENDC

	IFNB \2
		var \2
	ENDC

	endm

ldc macro
	IFC \0,L
		LS_FLUSH
		move.l \1,d0
		LS_SET LS_CACHED,4
	ELSE
	IFC \0,B
		LS_FLUSH
		move.b \1,d0
		ext.w d0
		LS_SET LS_CACHED,2
	ELSE
		LS_FLUSH
		move.w \1,d0
		LS_SET LS_CACHED,2
	ENDC
	ENDC
	endm

ld_addr macro
	LS_FLUSH
	pea \1
	LS_SET LOCAL,LOCAL+4
	endm

sto macro
	IF LS_CACHED=4
		move.l d0,\1
		LS_SET LS_CACHED,0
	ELSE
	IF LS_CACHED=2
		IFC \0,B
			move.b d0,\1        ; todo non-cached byte
			LS_SET LS_CACHED,0
		ELSE
			move.w d0,\1
			LS_SET LS_CACHED,0
		ENDC
	ELSE
	IFC \0,L
		LS_SET LOCAL,LOCAL-4
		move.l (a7)+,\1
	ELSE
		LS_SET LOCAL,LOCAL-2
		move.w (a7)+,\1
	ENDC
	ENDC
	ENDC
	endm

drop macro
	IF LS_CACHED>0
		LS_SET LS_CACHED,0
	ELSE
	IFC \0,L
		addq #4,a7
		LS_SET LOCAL,LOCAL-4
	ELSE
		addq #2,a7
		LS_SET LOCAL,LOCAL-2
	ENDC
	ENDC
	endm

RESET_STACK macro
	lea LOCAL(a7),a7
	LS_SET LOCAL,0
	endm


dup macro
	IF LS_CACHED=0
		IFC \0,l
			move.l (a7),d0
			LS_SET LS_CACHED,4
		ELSE
			move.w (a7),d0
			LS_SET LS_CACHED,2
		ENDC
	ELSE
	IF LS_CACHED=4
		move.l d0,-(a7)
		LS_SET LOCAL,LOCAL+4
	ELSE
		move.w d0,-(a7)
		LS_SET LOCAL,LOCAL+2
	ENDC
	ENDC
	endm

restore macro
	IFC \0,L
		LS_SET LS_CACHED,4
	ELSE
		LS_SET LS_CACHED,2
	ENDC
	endm

LS_ARRAY_LEN macro
;	Helper macro to calculate array length
;
;	\1 label for length
;	\2 start offset
;	\3 element size
;
\1 equ (*-\2)/(\3)
	endm

string macro
	ld_addr .string\@(pc)
	bra .next\@
.string\@
	dc.b \1
	dc.b 0
	EVEN
.next\@
	endm
