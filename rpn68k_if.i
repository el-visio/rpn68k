;	If commands for rpn68k
;
;

if_ macro
	LS_PUSH_LABEL
	LS_JUMP beq,(_0&LS_MASK_LABEL)
	endm

if_not macro
	LS_PUSH_LABEL
	LS_JUMP bne,(_0&LS_MASK_LABEL)
	endm

if_null macro
	IFC \0,L
		IFNB \1
			ldc.L \1
		ELSE
			LS_CACHE.L
			tst.L d0
		ENDIF
		drop
		if_not
	ELSE
		IFNB \1
			ldc \1
		ELSE
			LS_CACHE
			tst d0
		ENDIF
		drop
		if_not
	ENDC

	endm

if_not_null macro
	IFC \0,L
		IFNB \1
			ldc.L \1
		ELSE
			LS_CACHE.L
			tst.L d0
		ENDIF
		drop
		if_
	ELSE
		IFNB \1
			ldc \1
		ELSE
			LS_CACHE
			tst d0
		ENDIF
		drop
		if_
	ENDC

	endm




LS_IF_BASE_l macro			; 32-bit
	; Two argument comparison:
	; Load first one to stack, then recurse
	IFNB \4
		ldc.L \3
		LS_IF_BASE_l \1,\2,\4
	ELSE
		LS_CACHE.L

		IFNB \3
			cmp.L \3,d0
			LS_PUSH_LABEL
			LS_JUMP \1,(_0&LS_MASK_LABEL)
		ELSE 
			cmp.L (a7)+,d0
			LS_SET LOCAL,LOCAL-4
			LS_PUSH_LABEL
			LS_JUMP \2,(_0&LS_MASK_LABEL)
		ENDC
		drop
	ENDC

	endm

LS_IF_BASE_w macro			; 16-bit
	; Two argument comparison:
	; Load first one to stack, then recurse
	IFNB \4
		ldc \3
		LS_IF_BASE_w \1,\2,\4
	ELSE
		LS_CACHE

		IFNB \3
			cmp \3,d0
			LS_PUSH_LABEL
			LS_JUMP \1,(_0&LS_MASK_LABEL)
		ELSE 
			cmp (a7)+,d0
			LS_SET LOCAL,LOCAL-2
			LS_PUSH_LABEL
			LS_JUMP \2,(_0&LS_MASK_LABEL)
		ENDC
		drop
	ENDC

	endm


LS_IF_BASE macro			; select macro by op size
	IFC \0,L
		LS_IF_BASE_l \1,\2,\3,\4
	ELSE
		LS_IF_BASE_w \1,\2,\3,\4
	ENDC
	endm
	



LS_AND_IF_BASE_l macro
	IFNB \4
		ldc.L \3
		LS_AND_IF_BASE_l \1,\2,\4
	ELSE
		LS_CACHE.L

		IFNB \3
			cmp.L \3,d0
			LS_JUMP \1,(_0&LS_MASK_LABEL)
		ELSE 
			cmp.L (a7)+,d0
			LS_SET LOCAL,LOCAL-4
			LS_JUMP \2,(_0&LS_MASK_LABEL)
		ENDC
		drop
	ENDC

	endm


LS_AND_IF_BASE_w macro
	IFNB \4
		ldc \3
		LS_AND_IF_BASE_w \1,\2,\4
	ELSE
		LS_CACHE

		IFNB \3
			cmp \3,d0
			LS_JUMP \1,(_0&LS_MASK_LABEL)
		ELSE 
			cmp (a7)+,d0
			LS_SET LOCAL,LOCAL-2
			LS_JUMP \2,(_0&LS_MASK_LABEL)
		ENDC
		drop
	ENDC

	endm



LS_AND_IF_BASE macro			; select macro by op size
	IFC \0,L
		LS_AND_IF_BASE_l \1,\2,\3,\4
	ELSE
		LS_AND_IF_BASE_w \1,\2,\3,\4
	ENDC
	endm



if_eq macro
	LS_IF_BASE.\0 bne,bne,\1,\2
	endm

if_ne macro
	LS_IF_BASE.\0 beq,beq,\1,\2
	endm

if_hi macro
	LS_IF_BASE.\0 ble,bge,\1,\2
	endm

if_hs macro
	LS_IF_BASE.\0 blt,bgt,\1,\2
	endm

if_lo macro
	LS_IF_BASE.\0 bge,ble,\1,\2
	endm

if_ls macro
	LS_IF_BASE.\0 bgt,blt,\1,\2
	endm

if_uhi macro
	LS_IF_BASE.\0 bls,bcc,\1,\2
	endm

if_uhs macro
	LS_IF_BASE.\0 bcs,bhi,\1,\2
	endm

if_ulo macro
	LS_IF_BASE.\0 bcc,bls,\1,\2
	endm

if_uls macro
	LS_IF_BASE.\0 bhi,bcs,\1,\2
	endm

and_if_eq macro
	LS_AND_IF_BASE.\0 bne,bne,\1,\2
	endm

and_if_ne macro
	LS_AND_IF_BASE.\0 beq,beq,\1,\2
	endm

and_if_hi macro
	LS_AND_IF_BASE.\0 ble,bge,\1,\2
	endm

and_if_hs macro
	LS_AND_IF_BASE.\0 blt,bgt,\1,\2
	endm

and_if_lo macro
	LS_AND_IF_BASE.\0 bge,ble,\1,\2
	endm

and_if_ls macro
	LS_AND_IF_BASE.\0 bgt,blt,\1,\2
	endm

and_if_uhi macro
	LS_AND_IF_BASE.\0 bls,bcc,\1,\2
	endm

and_if_uhs macro
	LS_AND_IF_BASE.\0 bcs,bhi,\1,\2
	endm

and_if_ulo macro
	LS_AND_IF_BASE.\0 bcc,bls,\1,\2
	endm

and_if_uls macro
	LS_AND_IF_BASE.\0 bhi,bcs,\1,\2
	endm



end_if macro
	LS_LABEL (_0&LS_MASK_LABEL)
	LS_DROP_CS
	endm

el_se macro
	LS_PUSH_CS LS_LABEL_NUM|(LOCAL<<LS_SHIFT_LOCAL)
	LS_INC LS_LABEL_NUM
	LS_SET LS_CACHED,0
	LS_JUMP bra,(_0&LS_MASK_LABEL)

	LS_SWAP_CS

	LS_LABEL (_0&LS_MASK_LABEL)
	LS_SET LOCAL,(_0>>LS_SHIFT_LOCAL)
	LS_DROP_CS

	endm
