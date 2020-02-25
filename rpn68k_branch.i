;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T

LS_LABEL macro
	IF \1=0
LA_\2
	ELSE
		IF (\1&3)=0
			LS_LABEL (\1/4),a\2
		ENDC
		IF (\1&3)=1
			LS_LABEL (\1/4),b\2
		ENDC
		IF (\1&3)=2
			LS_LABEL (\1/4),c\2
		ENDC
		IF (\1&3)=3
			LS_LABEL (\1/4),d\2
		ENDC
	ENDC
	endm

LS_JUMP macro
	IF \2=0
		IFC \1,DBF_D0
			dbf d0,LA_\3
		ELSE
			\1 LA_\3
		ENDC
	ELSE
		IF (\2&3)=0
			LS_JUMP \1,(\2/4),a\3
		ENDC
		IF (\2&3)=1
			LS_JUMP \1,(\2/4),b\3
		ENDC
		IF (\2&3)=2
			LS_JUMP \1,(\2/4),c\3
		ENDC
		IF (\2&3)=3
			LS_JUMP \1,(\2/4),d\3
		ENDC
	ENDC
	endm

LS_PUSH_LABEL macro
	LS_PUSH_CS LS_LABEL_NUM|(LOCAL<<LS_SHIFT_LOCAL)
	LS_INC LS_LABEL_NUM
	endm

loop_in macro
	IFNB \1
		ldc \1
	ELSE
		LS_CACHE
	ENDC

	LS_PUSH_LABEL
	LS_JUMP bra,(_0&LS_MASK_LABEL)

	LS_PUSH_LABEL
	LS_LABEL (_0&LS_MASK_LABEL)
	endm

loop_in_const macro
	ldc #\1-1
	LS_PUSH_LABEL

	LS_PUSH_LABEL
	LS_LABEL (_0&LS_MASK_LABEL)
	endm

loop_out macro
	LS_FLUSH

	LS_SWAP_CS

	IF (LOCAL-(_0>>LS_SHIFT_LOCAL))>2
		add.w #LOCAL-(_0>>LS_SHIFT_LOCAL)-2,a7
		LS_SET LOCAL,(_0>>LS_SHIFT_LOCAL)+2
	ENDC

	LS_CACHE

	; label for first loop count decrement
	LS_LABEL (_0&LS_MASK_LABEL)
	LS_DROP_CS

	; loop again if counter > 0 
	LS_JUMP DBF_D0,(_0&LS_MASK_LABEL)
	LS_DROP_CS

	drop
	endm

while_in macro
	LS_FLUSH

	LS_PUSH_LABEL
	LS_LABEL (_0&LS_MASK_LABEL)
	endm

while_out macro
	LS_FLUSH

	LS_SWAP_CS

	LS_JUMP bra,(_0&LS_MASK_LABEL)
	LS_DROP_CS

	LS_LABEL (_0&LS_MASK_LABEL)
	LS_DROP_CS
	endm
