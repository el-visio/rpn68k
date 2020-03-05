;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T
;
;	If commands for rpn68k
;
;

;	If branch after tst or btst asm command

if_ macro
	LS_JUMP_FWD beq
	endm


;	If branch after tst or btst asm command

if_not macro
	LS_JUMP_FWD bne
	endm


if_null macro
	LS_FLAGS.\0 if_null,\1,\2

	IF LSF_if_null&LSF_HAS_ARG
		IF LSF_if_null&LSF_W
			ldc \1
		ELSE
			ldc.l \1
		ENDC
	ELSE
		IF LSF_if_null&LSF_W
			LS_CACHE
			tst d0
		ELSE
			LS_CACHE.l
			tst.l d0
		ENDC	
	ENDC

	drop
	if_not

	endm


if_not_null macro
	LS_FLAGS.\0 if_null,\1,\2

	IF LSF_if_null&LSF_HAS_ARG
		IF LSF_if_null&LSF_W
			ldc \1
		ELSE
			ldc.l \1
		ENDC
	ELSE
		IF LSF_if_null&LSF_W
			LS_CACHE
			tst d0
		ELSE
			LS_CACHE.l
			tst.l d0
		ENDC	
	ENDC

	drop
	if_

	endm


LS_IF_BASE macro
	LS_FLAGS.\0 if_base,\3,\4

	IF LSF_if_base&LSF_HAS_ARG2
		IF LSF_if_base&LSF_W
			ldc \3
			cmp \4,d0
		ELSE
			ldc.l \3
			cmp.l \4,d0
		ENDC
		LS_JUMP_FWD \1
	ELSE
	IF LSF_if_base&LSF_HAS_ARG
		IF LSF_if_base&LSF_W
			LS_CACHE
			cmp \3,d0
		ELSE
			LS_CACHE.l
			cmp.l \3,d0
		ENDC
		LS_JUMP_FWD \1
	ELSE 
		IF LSF_if_base&LSF_W
			LS_CACHE
			cmp (a7)+,d0
		ELSE
			LS_CACHE.l
			cmp.l (a7)+,d0
		ENDC
		LS_SET LOCAL,LOCAL-(LSF_if_base&LSF_SIZE_MASK)
		LS_JUMP_FWD \2
	ENDC
	ENDC
	drop

	endm



LS_AND_IF_BASE macro
	LS_FLAGS.\0 if_base,\3,\4

	IF LSF_if_base&LSF_HAS_ARG2
		IF LSF_if_base&LSF_W
			ldc \3
			cmp \4,d0
		ELSE
			ldc.l \3
			cmp.l \4,d0
		ENDC
		LS_JUMP_FWD_AND \1
	ELSE
	IF LSF_if_base&LSF_HAS_ARG
		IF LSF_if_base&LSF_W
			LS_CACHE
			cmp \3,d0
		ELSE
			LS_CACHE.l
			cmp.l \3,d0
		ENDC
		LS_JUMP_FWD_AND \1
	ELSE 
		IF LSF_if_base&LSF_W
			LS_CACHE
			cmp (a7)+,d0
		ELSE
			LS_CACHE.l
			cmp.l (a7)+,d0
		ENDC
		LS_SET LOCAL,LOCAL-(LSF_if_base&LSF_SIZE_MASK)
		LS_JUMP_FWD_AND \2
	ENDC
	ENDC
	drop

	endm


el_se macro
	LS_SET LS_CACHED,0		; TODO check flag
	LS_JUMP_FWD bra

	LS_SWAP_CS_ONE_MANY

	LS_SET LOCAL,((_0>>LSCS_LOCAL_SHIFT)&LSCS_LOCAL_MASK)
	REPT ((_0>>LSCS_AND_IF_SHIFT)&LSCS_AND_IF_MASK)+1
		LS_LABEL_FWD _0
		LS_DROP_CS
	ENDR

	endm


end_if macro
	REPT ((_0>>LSCS_AND_IF_SHIFT)&LSCS_AND_IF_MASK)+1
		LS_LABEL_FWD _0
		LS_DROP_CS
	ENDR

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
