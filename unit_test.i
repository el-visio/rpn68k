;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T
;
;	Include file for rpn68k unit tests
;

UT_TRUE equ $ff
UT_FALSE equ $00

;
; 	Unit test context struct
;

	rsreset
UT_mempool      rs.l 1	; Memory pool
UT_p10          rs.w 1	; variables for arithmetic tests
UT_p20          rs.w 1	; ...
UT_p30          rs.w 1	; 
UT_m10          rs.w 1	; 
UT_m20          rs.w 1	; 
UT_m30          rs.w 1	; 
UT_p10l         rs.l 1	; 
UT_p20l         rs.l 1	; 
UT_p30l         rs.l 1	; 
UT_m10l         rs.l 1	;
UT_m20l         rs.l 1	;
UT_m30l         rs.l 1	;
UT_0xf0f0       rs.w 1	;
UT_0xff00       rs.w 1	;
UT_demo_list    rs.l 1	; Demo list
SIZEOF_UT       rs.w 0


;	Demo list element struct

	rsreset
ELEM_next     rs.l 1
ELEM_value    rs.w 1
SIZEOF_ELEM   rs.w 0

;	Name for unit test case group

TEST_NAME macro
; <under construction>
	endm


;	TEST_CASE
;	Store test case pointer for debugging

TEST_CASE macro
	lea 4(pc),a5		; Store test case pointer to a5
	endm


;	Compare test result to expected value,
;	call test_failed_exit if it does not match

COMPARE_RESULT macro
	IFC \0,L
		LS_CACHE.l
		drop
		cmp.l \1,d0
		bne test_failed_exit

	ELSE
		LS_CACHE
		and.l #$ffff,d0					; mask higher word
		drop
		cmp.w \1,d0
		bne test_failed_exit

	ENDC

	IF LOCAL<>0
		printt 'ERROR: Stack size is not zero!'
		moveq #-1,d0
		rts
	ENDC

	addq #1,d7              ; update test index

	endm


ARITHMETIC_TEST_BASE macro
	IFC \0,L

		TEST_CASE 
		ld.l \1
		ld.l \2
		\3.l
		COMPARE_RESULT.l \4

		TEST_CASE 
		ld.l \1
		ldc.l \2
		\3.l
		COMPARE_RESULT.l \4

		TEST_CASE 
		ld.l \1
		\3.l \2
		COMPARE_RESULT.l \4

		TEST_CASE 
		ldc.l \1
		\3.l \2
		COMPARE_RESULT.l \4

	ELSE

		TEST_CASE 
		ld \1
		ld \2
		\3
		COMPARE_RESULT \4

		TEST_CASE 
		ld \1
		ldc \2
		\3
		COMPARE_RESULT \4

		TEST_CASE 
		ld \1
		\3 \2
		COMPARE_RESULT \4

		TEST_CASE 
		ldc \1
		\3 \2
		COMPARE_RESULT \4

	ENDC

	endm


ARITHMETIC_TEST macro
	ARITHMETIC_TEST_BASE \1,\2,\3,\4
	ARITHMETIC_TEST_BASE.l \1,\2,\3,\4
	endm


ROT_TEST_BASE macro
	IFC \0,L

		TEST_CASE 
		ld.L \1
		ld \2
		\3.L
		COMPARE_RESULT.L \4

		TEST_CASE 
		ld.L \1
		ldc \2
		\3.L
		COMPARE_RESULT.L \4

		TEST_CASE 
		ld.L \1
		\3.L \2
		COMPARE_RESULT.L \4

		TEST_CASE 
		ldc.L \1
		\3.L \2
		COMPARE_RESULT.L \4

	ELSE

		TEST_CASE 
		ld \1
		ld \2
		\3
		COMPARE_RESULT \4

		TEST_CASE 
		ld \1
		ldc \2
		\3
		COMPARE_RESULT \4

		TEST_CASE 
		ld \1
		\3 \2
		COMPARE_RESULT \4

		TEST_CASE 
		ldc \1
		\3 \2
		COMPARE_RESULT \4
	ENDIF

	endm


ROT_TEST macro
	ROT_TEST_BASE.w \1,\2,\3,\4
	ROT_TEST_BASE.l \1,\2,\3,\4
	endm


IF_TEST_BASE_l macro			; 32-bit tests
										; If between two values in stack
	TEST_CASE

	ld.L \1
	ld.L \2
	\3.L
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between two values in stack, TOS cached
	TEST_CASE

	ld.L \1
	ldc.L \2
	\3.L
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between single arg and uncached TOS
	TEST_CASE

	ld.L \1
	\3.L \2
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between single arg and cached TOS
	TEST_CASE

	ldc.L \1
	\3.L \2
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between two args
	TEST_CASE

	\3.L \1,\2
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4

	endm


IF_TEST_BASE_w macro			; 16-bit tests
; If between two values in stack
	TEST_CASE

	ld \1
	ld \2
	\3
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between two values in stack, TOS cached
	TEST_CASE

	ld \1
	ldc \2
	\3
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between single arg and uncached TOS
	TEST_CASE

	ld \1
	\3 \2
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between single arg and cached TOS
	TEST_CASE

	ldc \1
	\3 \2
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4


; If between two args
	TEST_CASE

	\3 \1,\2
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if
	COMPARE_RESULT \4

	endm


IF_TEST macro
	IF_TEST_BASE_w \1,\2,\3,\4
	IF_TEST_BASE_l \1,\2,\3,\4
	endm


CREATE_DEMO_LIST macro
	move.l #0,UT_demo_list(a6)						; Set list root to NULL

	lea list_values(pc),a2								; Pointer to demo values
	loop_in #NUM_LIST_VALUES
		ld_addr UT_demo_list(a6)						; List root pointer
		alloc UT_mempool(a6),#SIZEOF_ELEM		; Allocate element
		sto a1															; Element ptr to a1
		move.l #0,ELEM_next(a1)							; Set next to NULL
		move.w (a2)+,ELEM_value(a1)					; Set value
		ld.l a1															; Load elem ptr to stack
		list_insert_\1 ELEM_value,ELEM_next	; Insert element
	loop_out

	endm


COMPARE_DEMO_LIST macro
	ld #0,num_list_matches\@							; Num matches varible

	lea \1,a2															; Reference to a2
	move.l UT_demo_list(a6),a5						; List root to a5
	while_in
		if_not_null.l a5
		and_if_eq ELEM_value(a5),\2
			inc num_list_matches\@+LOCAL(a7)
			move.l ELEM_next(a5),a5
	while_out

	COMPARE_RESULT #NUM_LIST_VALUES		; Compare number of matches
																		; to array size

	endm
