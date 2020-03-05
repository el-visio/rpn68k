;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T

LSF_SIZE_MASK			equ	7
LSF_B 						equ	(1)
LSF_W 						equ	(1<<1)
LSF_L 						equ	(1<<2)
LSF_HAS_ARG 			equ	(1<<3)
LSF_HAS_ARG2			equ	(1<<4)
LSF_SPLIT_ARG1		equ (1<<5)
LSF_SPLIT_ARG2		equ (1<<6)
LSF_CACHE_SHIFT 	equ	7
LSF_CACHE_MASK 		equ	(7<<LSF_CACHE_SHIFT)

;	LS_FLAGS - Set flags for command
;
;	Environment variable LSF_<name> will be created
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
		LS_SET LSF_\1,LSF_L
	ELSE
	IFC \0,B
		LS_SET LSF_\1,LSF_B
	ELSE
		LS_SET LSF_\1,LSF_W
	ENDC
	ENDC


	; Set 'has arg' flag

	IFNB \2
		LS_SET LSF_\1,(LSF_\1|LSF_HAS_ARG)
	ENDC


	; Set 'has 2nd arg' flag

	IFNB \3
		LS_SET LSF_\1,(LSF_\1|LSF_HAS_ARG2)
	ENDC

	endm


;	LSF_B2W
;
;	Helper macro that forces LSF_B into LSF_W so
;	you can directly use the op size for adjusting LOCAL or LS_CACHED

LSF_B2W macro
	IF LSF_\1&LSF_B
		LS_SET LSF_\1,LSF_\1^(LSF_B|LSF_W)
	ENDIF

	endm
