;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T

LS_FLAGS_SIZE_MASK		equ	7
LS_FLAGS_B 						equ	(1)
LS_FLAGS_W 						equ	(1<<1)
LS_FLAGS_L 						equ	(1<<2)
LS_FLAGS_HAS_ARG 			equ	(1<<3)
LS_FLAGS_HAS_ARG2			equ	(1<<4)
LS_FLAGS_SPLIT_ARG1		equ (1<<5)
LS_FLAGS_SPLIT_ARG2		equ (1<<6)
LS_FLAGS_CACHE_SHIFT 	equ	7
LS_FLAGS_CACHE_MASK 	equ	(7<<LS_FLAGS_CACHE_SHIFT)

;	LS_FLAGS - Set flags for command
;
;	Environment variable LS_FLAGS_<name> will be created
;	and can be used to control macro flow.
;
;
;	There are some differences between AsmOne and VASM on how
;	to interpret the \0 argument (the operation size) so this
;	mechanism is here to keep rpn68k compatible with multiple
;	assemblers.
;
;	Also there's an AsmOne bug where \0 argument is lost when
;	another macro is called inside a macro, so it's better to
;	store it when you can.
;
;	\0 Command size
;	\1 Command name
;	\2 Command arg 1 (= \1 from the original command)
;	\3 Command arg 2 (= \2 from the original command)
;	\4 Command arg 1 (= \3 from the original command)
;	\5 Command arg 2 (= \4 from the original command)

LS_FLAGS macro
	; Set command size flags
	
	IFC \0,L
		LS_SET LS_FLAGS_\1,LS_FLAGS_L
	ELSE
	IFC \0,B
		LS_SET LS_FLAGS_\1,LS_FLAGS_B
	ELSE
		LS_SET LS_FLAGS_\1,LS_FLAGS_W
	ENDC
	ENDC


	; Set 'has arg' flag

	IFNB \2
		LS_SET LS_FLAGS_\1,(LS_FLAGS_\1|LS_FLAGS_HAS_ARG)
	ENDC


	; Set 'has 2nd arg' flag

	IFNB \3
		LS_SET LS_FLAGS_\1,(LS_FLAGS_\1|LS_FLAGS_HAS_ARG2)
	ENDC

	endm


;	LS_FLAGS_B2W
;
;	Helper macro that forces LS_FLAGS_B into LS_FLAGS_W so
;	you can directly use the op size for adjusting LOCAL or LS_CACHED

LS_FLAGS_B2W macro
	IF LS_FLAGS_\1&LS_FLAGS_B
		LS_SET LS_FLAGS_\1,LS_FLAGS_\1^(LS_FLAGS_B|LS_FLAGS_W)
	ENDIF

	endm
