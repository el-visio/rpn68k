;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T

;	Condition codes for branch generation

LSCS_bne equ $6		; eq
LSCS_beq equ $7		; ne
LSCS_ble equ $f		; hi
LSCS_blt equ $d		; hs

LSCS_bge equ $c		; lo
LSCS_bgt equ $e		; ls
LSCS_bls equ $3		; uhi
LSCS_bcs equ $5		; uhs

LSCS_bcc equ $4		; ulo
LSCS_bhi equ $2		; uls
LSCS_bra equ $0
LSCS_bsr equ $1

LSCS_bvc equ $8
LSCS_bvs equ $9
LSCS_bpl equ $a
LSCS_bmi equ $b

LSCS_OFFSET_MASK	equ $7fff		; pre-shift		
LSCS_LONG_MASK 		equ 1<<15		; one bit, no shift
LSCS_COND_MASK		equ $000f		; post-shift
LSCS_COND_SHIFT		equ 16
LSCS_LOCAL_MASK		equ $01fe		; post-shift
LSCS_LOCAL_SHIFT	equ 19
LSCS_AND_IF_MASK	equ $7			; post-shift
LSCS_AND_IF_SHIFT	equ 28

LS_PUSH_LABEL2 macro
	LS_PUSH_CS ((*-rpn68k_sect)>>1)|(LOCAL<<LSCS_LOCAL_SHIFT)
	endm


LS_PUSH_ZERO macro
	LS_PUSH_CS (LOCAL<<LSCS_LOCAL_SHIFT)
	endm


LS_JUMP_FWD macro
	dc.w $6000|(LSCS_\1<<8)		; create jump command
	LS_PUSH_LABEL2
	dc.w $0000
	endm


LS_JUMP_FWD_AND macro
	dc.w $6000|(LSCS_\1<<8)		; create jump command
	LS_SET LS_TEMP,(_0>>LSCS_AND_IF_SHIFT)&LSCS_AND_IF_MASK
	LS_PUSH_CS ((*-rpn68k_sect)>>1)|(LOCAL<<LSCS_LOCAL_SHIFT)|((LS_TEMP+1)<<LSCS_AND_IF_SHIFT)
	dc.w $0000
	endm


LS_LABEL_FWD macro
	IF (\1&LSCS_OFFSET_MASK)>0
		LS_SET LS_TMP_PTR,*-rpn68k_sect							; save current output ptr
		RORG ((\1&LSCS_OFFSET_MASK)<<1)							; set output ptr
		dc.w LS_TMP_PTR-((\1&LSCS_OFFSET_MASK)<<1)	; write branch offset
		RORG LS_TMP_PTR															; restore output ptr
	ENDC
	endm


loop_in macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	subq.w #1,d0			; Decrement and check for zero
	LS_JUMP_FWD bcs		; branch & offset placeholder

	LS_PUSH_LABEL2		; branch here from loop end
	endm


loop_in_const macro
	ldc #(\1)-1
	LS_PUSH_ZERO			; push zero, no zero check jump for const

	LS_PUSH_LABEL2		; next loop label
	endm


loop_out macro
	LS_SET LS_TMP_LOCAL,((_0>>LSCS_LOCAL_SHIFT)&LSCS_LOCAL_MASK)

	; Drop extra values from stack to reach loop counter
	IF (LOCAL+LS_CACHED-LS_TMP_LOCAL)>2
		IF (LOCAL-LS_TMP_LOCAL>2)
			addq #LOCAL-LS_TMP_LOCAL-2,a7
			LS_SET LOCAL,LS_TMP_LOCAL+2
		ENDC

		LS_SET LS_CACHED,0
	ENDC

	LS_CACHE

	; loop again if counter > 0 
	dbf	d0,rpn68k_sect+((_0&LSCS_OFFSET_MASK)<<1)
	LS_DROP_CS

	; exit label if loop count zero
	LS_LABEL_FWD _0
	LS_DROP_CS

	; Drop loop counter
	drop
	endm


while_in macro
	LS_FLUSH
	LS_PUSH_LABEL2		; branch here from loop end

	endm


while_out macro
	LS_SWAP_CS_MANY_ONE

	; Drop extra values from stack
	LS_SET LS_CACHED,0
	LS_SET LS_TMP_LOCAL,((_0>>LSCS_LOCAL_SHIFT)&LSCS_LOCAL_MASK)
	IF LOCAL>LS_TMP_LOCAL
		addq #LOCAL-LS_TMP_LOCAL,a7
		LS_SET LOCAL,LS_TMP_LOCAL
	ENDC

	; Loop again
	bra rpn68k_sect+((_0&LSCS_OFFSET_MASK)<<1)
	LS_DROP_CS

	; Exit while loop
	REPT ((_0>>LSCS_AND_IF_SHIFT)&LSCS_AND_IF_MASK)+1
		LS_LABEL_FWD _0
		LS_DROP_CS
	ENDR

	endm
