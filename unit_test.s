;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T
;
;	Unit tests for rpn68k
;
;
;	Build and run, then see register values for information
;
;	d0:  $0000 success
;	     $ffff unit test failed
;	
;	d6:  actual result for a failed test
;
;	d7:  number of succesful test cases (also the index of
;	     failed test if any)
;
;	a5:  pointer to failed test, disassemble here to investigate
;

	include rpn68k.i
	include list.i
	include unit_test.i


ENABLE_TEST_ARITHMETIC	equ 1	; Enable tests for arithmetic commands
ENABLE_TEST_LOOPS				equ 1	; Enable tests for loops
ENABLE_TEST_IF					equ 1	; Enable tests for if commands
ENABLE_TEST_AND_IF			equ 1	; Enable tests for and if commands
ENABLE_TEST_WHILE				equ 1	; Enable tests for while commands
ENABLE_TEST_ALLOC				equ 1	; Enable tests for memory allocation
ENABLE_TEST_LIST				equ 1	; Enable tests for list insertion


PRIME_1 equ 3		;	Constants for loop tests
PRIME_2	equ 5		;
PRIME_3 equ 7		;


;
;	Unit test start
;

start
	moveq #0,d7								; Reset unit test index

	lea membuffer,a6					; Membuffer pointer to a6
	lea SIZEOF_UT(a6),a1			; Add unit test context size
	move.l a1,UT_mempool(a6)	; Store to UT_mempool

;	Add test values to unit test context

	move.w #10,UT_p10(a6)
	move.w #20,UT_p20(a6)
	move.w #30,UT_p30(a6)
	move.w #-10,UT_m10(a6)
	move.w #-20,UT_m20(a6)
	move.w #-30,UT_m30(a6)

	move.l #10,UT_p10l(a6)
	move.l #20,UT_p20l(a6)
	move.l #30,UT_p30l(a6)
	move.l #-10,UT_m10l(a6)
	move.l #-20,UT_m20l(a6)
	move.l #-30,UT_m30l(a6)

	move.w #$f0f0,UT_0xf0f0(a6)
	move.w #$ff00,UT_0xff00(a6)

;
;	Unit tests for arithmetic operations
;

	IF ENABLE_TEST_ARITHMETIC=1

unit_test_arithmetic

	TEST_NAME 'add_'

	ARITHMETIC_TEST #10,#20,add_,#30
	ARITHMETIC_TEST #-10,#20,add_,#10
	ARITHMETIC_TEST #-10,#-20,add_,#-30

	ARITHMETIC_TEST_WWW UT_p10(a6),UT_p20(a6),add_,#30
	ARITHMETIC_TEST_WWW UT_m10(a6),UT_p20(a6),add_,#10
	ARITHMETIC_TEST_WWW UT_m10(a6),UT_m20(a6),add_,#-30

	ARITHMETIC_TEST_LLL UT_p10l(a6),UT_p20l(a6),add_,#30
	ARITHMETIC_TEST_LLL UT_m10l(a6),UT_p20l(a6),add_,#10
	ARITHMETIC_TEST_LLL UT_m10l(a6),UT_m20l(a6),add_,#-30


	TEST_NAME 'sub_'

	ARITHMETIC_TEST #30,#20,sub_,#10
	ARITHMETIC_TEST #10,#30,sub_,#-20
	ARITHMETIC_TEST #-10,#-20,sub_,#10

	ARITHMETIC_TEST_WWW UT_p30(a6),UT_p20(a6),sub_,#10
	ARITHMETIC_TEST_WWW UT_p10(a6),UT_p30(a6),sub_,#-20
	ARITHMETIC_TEST_WWW UT_m10(a6),UT_m20(a6),sub_,#10

	ARITHMETIC_TEST_LLL UT_p30l(a6),UT_p20l(a6),sub_,#10
	ARITHMETIC_TEST_LLL UT_p10l(a6),UT_p30l(a6),sub_,#-20
	ARITHMETIC_TEST_LLL UT_m10l(a6),UT_m20l(a6),sub_,#10



	TEST_NAME 'mul'

	ARITHMETIC_TEST_WWW #10,#20,mul,#200
	ARITHMETIC_TEST_WWW #10,#-20,mul,#-200
	ARITHMETIC_TEST_WWW #-10,#-20,mul,#200

	ARITHMETIC_TEST_WWW UT_p10(a6),UT_p20(a6),mul,#200
	ARITHMETIC_TEST_WWW UT_p10(a6),UT_m20(a6),mul,#-200
	ARITHMETIC_TEST_WWW UT_m10(a6),UT_m20(a6),mul,#200

	ARITHMETIC_TEST_WWL #$1000,#$2000,mul,#$02000000
	ARITHMETIC_TEST_WWL #$1000,#-$2000,mul,#$fe000000


	TEST_NAME 'mul12f'

	ARITHMETIC_TEST_WWW #$200,#1<<11,mul12f,#$100
	ARITHMETIC_TEST_WWW #$200,#1<<13,mul12f,#$400

	ARITHMETIC_TEST_WWL #$7000,#$7000,mul12f,#$31000


	TEST_NAME 'div'

	ARITHMETIC_TEST_WWW #200,#10,div,#20
	ARITHMETIC_TEST_WWW #200,#-10,div,#-20
	ARITHMETIC_TEST_WWW #-200,#-10,div,#20

	ARITHMETIC_TEST_LWW #200,#10,div,#20
	ARITHMETIC_TEST_LWW #200,#-10,div,#-20
	ARITHMETIC_TEST_LWW #-200,#-10,div,#20


	TEST_NAME 'div12f'

	ARITHMETIC_TEST_WWW #$2000,#2<<12,div12f,#$1000		; / 2.0
	ARITHMETIC_TEST_WWW #$2000,#1<<12,div12f,#$2000		; / 1.0
	ARITHMETIC_TEST_WWW #$2000,#1<<11,div12f,#$4000		; / 0.5
	
	ARITHMETIC_TEST_WWW #-$2000,#2<<12,div12f,#-$1000		; / 2.0
	ARITHMETIC_TEST_WWW #-$2000,#1<<12,div12f,#-$2000		; / 1.0
	ARITHMETIC_TEST_WWW #-$2000,#1<<11,div12f,#-$4000		; / 0.5
	
	ARITHMETIC_TEST_LWW #$2000,#2<<12,div12f,#$1000		; / 2.0
	ARITHMETIC_TEST_LWW #$2000,#1<<12,div12f,#$2000		; / 1.0
	ARITHMETIC_TEST_LWW #$2000,#1<<11,div12f,#$4000		; / 0.5
	
	ARITHMETIC_TEST_LWW #-$2000,#2<<12,div12f,#-$1000		; / 2.0
	ARITHMETIC_TEST_LWW #-$2000,#1<<12,div12f,#-$2000		; / 1.0
	ARITHMETIC_TEST_LWW #-$2000,#1<<11,div12f,#-$4000		; / 0.5


	TEST_NAME 'mod'

	ARITHMETIC_TEST_WWW #15,#10,mod,#5
	ARITHMETIC_TEST_WWW #15,#5,mod,#0
	ARITHMETIC_TEST_WWW #30,#20,mod,#10

	ARITHMETIC_TEST_WWW #-15,#10,mod,#-5
	ARITHMETIC_TEST_WWW #-15,#5,mod,#0
	ARITHMETIC_TEST_WWW #-30,#20,mod,#-10

	ARITHMETIC_TEST_LWW #15,#10,mod,#5
	ARITHMETIC_TEST_LWW #15,#5,mod,#0
	ARITHMETIC_TEST_LWW #30,#20,mod,#10

	ARITHMETIC_TEST_LWW #-15,#10,mod,#-5
	ARITHMETIC_TEST_LWW #-15,#5,mod,#0
	ARITHMETIC_TEST_LWW #-30,#20,mod,#-10


	TEST_NAME 'and_'

	ARITHMETIC_TEST #$ff00,#$f0f0,and_,#$f000
	ARITHMETIC_TEST_WWW UT_0xff00(a6),UT_0xf0f0(a6),and_,#$f000


	TEST_NAME 'or_'

	ARITHMETIC_TEST #$ff00,#$f0f0,or_,#$fff0
	ARITHMETIC_TEST_WWW UT_0xff00(a6),UT_0xf0f0(a6),or_,#$fff0


	TEST_NAME 'xor_'

	ARITHMETIC_TEST #$ff00,#$f0f0,xor_,#$0ff0
	ARITHMETIC_TEST_WWW UT_0xff00(a6),UT_0xf0f0(a6),xor_,#$0ff0


	TEST_NAME 'max'

	ARITHMETIC_TEST #10,#20,max,#20
	ARITHMETIC_TEST #-10,#20,max,#20
	ARITHMETIC_TEST #20,#10,max,#20
	ARITHMETIC_TEST #20,#-10,max,#20


	TEST_NAME 'min'

	ARITHMETIC_TEST #10,#20,min,#10
	ARITHMETIC_TEST #-10,#20,min,#-10
	ARITHMETIC_TEST #20,#10,min,#10
	ARITHMETIC_TEST #20,#-10,min,#-10


	TEST_NAME 'umax'

	ARITHMETIC_TEST #10,#20,umax,#20
	ARITHMETIC_TEST #-$1000,#20,umax,#-$1000
	ARITHMETIC_TEST #20,#10,umax,#20
	ARITHMETIC_TEST #20,#-$1000,umax,#-$1000


	TEST_NAME 'umin'

	ARITHMETIC_TEST #10,#20,umin,#10
	ARITHMETIC_TEST #-$1000,#20,umin,#20
	ARITHMETIC_TEST #20,#10,umin,#10
	ARITHMETIC_TEST #20,#-$1000,umin,#20


	TEST_NAME 'asr_'

	ROT_TEST #1024,#6,asr_,#16
	ROT_TEST #-1024,#6,asr_,#-16


	TEST_NAME 'asl_'

	ROT_TEST #16,#6,asl_,#1024
	ROT_TEST #-16,#6,asl_,#-1024


	TEST_NAME 'ror_'

	ARITHMETIC_TEST_WWW #$1234,#4,ror_,#$4123
	ARITHMETIC_TEST_LWL #$12345678,#4,ror_,#$81234567


	TEST_NAME 'rol_'

	ARITHMETIC_TEST_WWW #$1234,#4,rol_,#$2341
	ARITHMETIC_TEST_LWL #$12345678,#4,rol_,#$23456781


	ENDC	; ENABLE_TEST_ARITHMETIC


;
;	Unit tests for loops
;

	IF ENABLE_TEST_LOOPS=1

unit_test_loops

	TEST_NAME 'loop_in'

	TEST_CASE			; loop value is arg

	ld.l #0,loop_res1		; test result

	loop_in #PRIME_1
		loop_in #PRIME_2
			loop_in #PRIME_3
				inc.l loop_res1+LOCAL(a7)
			loop_out
			ldc.l #0			; dummy cached value, should be removed
		loop_out
		ld.l #0					; dummy value, should be removed
	loop_out

	COMPARE_RESULT.l #(PRIME_1*PRIME_2*PRIME_3)


	TEST_CASE		; loop value is cached

	ld.l #0,loop_res2		; test result

	ldc #PRIME_1
	loop_in
		ldc #PRIME_2
		loop_in
			ldc #PRIME_3
			loop_in
				inc.l loop_res2+LOCAL(a7)
			loop_out
			ldc.l #0			; dummy cached value, should be removed
		loop_out			
		ld.l #0					; dummy value, should be removed
	loop_out

	COMPARE_RESULT.l #(PRIME_1*PRIME_2*PRIME_3)


	TEST_CASE		; loop value is in stack

	ld.l #0,loop_res3		; test result

	ld #PRIME_1
	loop_in
		ld #PRIME_2
		loop_in
			ld #PRIME_3
			loop_in
				inc.l loop_res3+LOCAL(a7)
			loop_out
			ldc.l #0			; dummy cached value, should be removed
		loop_out			
		ld.l #0					; dummy value, should be removed
	loop_out

	COMPARE_RESULT.l #(PRIME_1*PRIME_2*PRIME_3)


	TEST_CASE		; loop_in_const

	ld.l #0,loop_res4		; test result

	loop_in_const PRIME_1
		loop_in_const PRIME_2
			loop_in_const PRIME_3
				inc.l loop_res4+LOCAL(a7)
			loop_out
			ldc.l #0			; dummy cached value, should be removed
		loop_out			
		ld.l #0					; dummy value, should be removed
	loop_out

	COMPARE_RESULT.l #(PRIME_1*PRIME_2*PRIME_3)


	ENDC	; ENABLE_TEST_LOOPS


;
;	Unit tests for if_<condition>
;

	IF ENABLE_TEST_IF=1

unit_test_if

	TEST_NAME 'if_eq'	; if equal

	IF_TEST #15,#15,if_eq,#UT_TRUE
	IF_TEST #15,#10,if_eq,#UT_FALSE
	IF_TEST_BASE_w UT_p10(a6),#10,if_eq,#UT_TRUE
	IF_TEST_BASE_w UT_p10(a6),#0,if_eq,#UT_FALSE
	IF_TEST_BASE_l UT_p10l(a6),#10,if_eq,#UT_TRUE
	IF_TEST_BASE_l UT_p10l(a6),#0,if_eq,#UT_FALSE


	TEST_NAME 'if_ne'	; if not equal

	IF_TEST #15,#15,if_ne,#UT_FALSE
	IF_TEST #15,#10,if_ne,#UT_TRUE
	IF_TEST_BASE_w UT_p10(a6),#10,if_ne,#UT_FALSE
	IF_TEST_BASE_w UT_p10(a6),#0,if_ne,#UT_TRUE
	IF_TEST_BASE_l UT_p10l(a6),#10,if_ne,#UT_FALSE
	IF_TEST_BASE_l UT_p10l(a6),#0,if_ne,#UT_TRUE


; signed if tests

	TEST_NAME 'if_lo'	; if lower

	IF_TEST #20,#15,if_lo,#UT_FALSE
	IF_TEST #15,#15,if_lo,#UT_FALSE
	IF_TEST #10,#15,if_lo,#UT_TRUE
	IF_TEST #10,#-10,if_lo,#UT_FALSE
	IF_TEST #-10,#10,if_lo,#UT_TRUE


	TEST_NAME 'if_ls' ; if lower or same

	IF_TEST #20,#15,if_ls,#UT_FALSE
	IF_TEST #15,#15,if_ls,#UT_TRUE
	IF_TEST #10,#15,if_ls,#UT_TRUE
	IF_TEST #10,#-10,if_ls,#UT_FALSE
	IF_TEST #-10,#10,if_ls,#UT_TRUE


	TEST_NAME 'if_hi'	; if higher

	IF_TEST #20,#15,if_hi,#UT_TRUE
	IF_TEST #15,#15,if_hi,#UT_FALSE
	IF_TEST #10,#15,if_hi,#UT_FALSE
	IF_TEST #10,#-10,if_hi,#UT_TRUE
	IF_TEST #-10,#10,if_hi,#UT_FALSE


	TEST_NAME 'if_hs'	; if higher or same

	IF_TEST #20,#15,if_hs,#UT_TRUE
	IF_TEST #15,#15,if_hs,#UT_TRUE
	IF_TEST #10,#15,if_hs,#UT_FALSE
	IF_TEST #10,#-10,if_hs,#UT_TRUE
	IF_TEST #-10,#10,if_hs,#UT_FALSE


; unsigned if	tests

	TEST_NAME 'if_ulo'	; if lower (unsigned)

	IF_TEST #20,#15,if_ulo,#UT_FALSE
	IF_TEST #15,#15,if_ulo,#UT_FALSE
	IF_TEST #10,#15,if_ulo,#UT_TRUE
	IF_TEST #10,#-10,if_ulo,#UT_TRUE
	IF_TEST #-10,#10,if_ulo,#UT_FALSE


	TEST_NAME 'if_uls'	; if lower or same (unsigned)

	IF_TEST #20,#15,if_uls,#UT_FALSE
	IF_TEST #15,#15,if_uls,#UT_TRUE
	IF_TEST #10,#15,if_uls,#UT_TRUE
	IF_TEST #10,#-10,if_uls,#UT_TRUE
	IF_TEST #-10,#10,if_uls,#UT_FALSE


	TEST_NAME 'if_uhi'	; if higher (unsigned)

	IF_TEST #20,#15,if_uhi,#UT_TRUE
	IF_TEST #15,#15,if_uhi,#UT_FALSE
	IF_TEST #10,#15,if_uhi,#UT_FALSE
	IF_TEST #10,#-10,if_uhi,#UT_FALSE
	IF_TEST #-10,#10,if_uhi,#UT_TRUE


	TEST_NAME 'if_uhs'	; if higher or same (unsigned)

	IF_TEST #20,#15,if_uhs,#UT_TRUE
	IF_TEST #15,#15,if_uhs,#UT_TRUE
	IF_TEST #10,#15,if_uhs,#UT_FALSE
	IF_TEST #10,#-10,if_uhs,#UT_FALSE
	IF_TEST #-10,#10,if_uhs,#UT_TRUE

	ENDC	; ENABLE_TEST_IF


;
;	Unit tests for if_<condition>
;

	IF ENABLE_TEST_AND_IF=1

unit_test_and_if

	TEST_NAME 'and_if'

	TEST_CASE

	if_eq #1,#1
	and_if_lo #-1,#0
	and_if_hi #0,#-1
	and_if_ne #1,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_TRUE


	TEST_CASE

	if_eq #1,#1
	and_if_ls #-1,#0
	and_if_ls #0,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_TRUE


	TEST_CASE

	if_eq #1,#1
	and_if_hs #0,#-1
	and_if_hs #0,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_TRUE


	TEST_CASE

	if_eq #1,#1
	and_if_ulo #0,#$ffff
	and_if_uhi #$ffff,#0
	and_if_eq #1,#1
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_TRUE


	TEST_CASE

	if_eq #1,#1
	and_if_uls #0,#$ffff
	and_if_uls #$0,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_TRUE


	TEST_CASE

	if_eq #1,#1
	and_if_uhs #$ffff,0
	and_if_uhs #$0,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_TRUE


	TEST_CASE

	if_eq #1,#1
	and_if_lo #-1,#0
	and_if_hi #0,#-1
	and_if_ne #1,#1
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_FALSE


	TEST_CASE

	if_eq #1,#1
	and_if_lo #-1,#0
	and_if_hi #0,#0
	and_if_ne #1,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_FALSE


	TEST_CASE

	if_eq #1,#1
	and_if_lo #0,#0
	and_if_hi #0,#-1
	and_if_ne #1,#0
		ldc #UT_TRUE
	el_se
		ldc #UT_FALSE
	end_if

	COMPARE_RESULT #UT_FALSE


	ENDC	; ENABLE_TEST_AND_IF


;
;	Unit tests for while loops
;

	IF ENABLE_TEST_WHILE=1

unit_test_while

	TEST_NAME 'while'

	TEST_CASE
	ld.l #0,while_res1		; test result

	move.w #$1000,d2

	while_in
		ldc d2
		if_hi #0
			subq.w #1,d2
			inc.l while_res1+LOCAL(a7)
	while_out

	COMPARE_RESULT.l #$1000


	TEST_CASE
	ld.l #0,while_res2		; test result
	move.w #$1000,d2

	while_in
		ldc d2
		if_hi #0
			subq.w #1,d2
			inc.l while_res2+LOCAL(a7)
			ldc.l #0		; extra cached value to the stack inside while loop,
									; should be automatically removed
	while_out

	COMPARE_RESULT.l #$1000


	TEST_CASE
	ld.l #0,while_res3		; test result
	move.w #$1000,d2

	while_in
		ldc d2
		if_hi #0
			subq.w #1,d2
			inc.l while_res3+LOCAL(a7)
			ld.l #0		; extra value to the stack inside while loop,
								; should be automatically removed
	while_out

	COMPARE_RESULT.l #$1000


	TEST_CASE
	ld.l #0,while_res4		; test result

	move.w #PRIME_1,d2

	while_in
		ldc d2
		if_hi #0
			move.w #PRIME_2,d3
			while_in
				ldc d3
				if_hi #0
					move.w #PRIME_3,d4
					while_in
						ldc d4
						if_hi #0
							subq.w #1,d4
							inc.l while_res4+LOCAL(a7)
						while_out
					subq.w #1,d3
			while_out
			subq.w #1,d2
	while_out

	COMPARE_RESULT.l #PRIME_1*PRIME_2*PRIME_3


	ENDC


;
;	Tests for allocation from memory pool
;

	IF ENABLE_TEST_ALLOC=1

unit_test_alloc

	TEST_CASE
	alloc UT_mempool(a6),#1000
	sub_.l UT_mempool(a6)
	COMPARE_RESULT.l #-1000

	TEST_CASE
	alloc UT_mempool(a6),#2000
	sub_.l UT_mempool(a6)
	COMPARE_RESULT.l #-2000

	ENDC ; ENABLE_TEST_ALLOC


;
;	Test for list insertion
;

	IF ENABLE_TEST_LIST=1

unit_test_list

	TEST_NAME 'list'

	TEST_CASE
	CREATE_DEMO_LIST ascending		; create ascending list
	COMPARE_DEMO_LIST list_values_sorted(pc),(a2)+

	TEST_CASE
	CREATE_DEMO_LIST descending	; create descending list
	COMPARE_DEMO_LIST list_values_sorted+NUM_LIST_VALUES*2(pc),-(a2)

	ENDC	; ENABLE_TEST_LIST

;
;	All tests successful (hooray!)
;

	moveq	#0,d0					; Error code for success
	moveq	#0,d6					;	Reset actual result
	move.l d0,a5				; Reset previous test pointer
	rts

;
;	Test failed!
;

test_failed_exit
	move.l d0,d6				; Failed test result to d6
	moveq #-1,d0				; Error code for failed test
	rts



;	Values for list insertion unit test

list_values
	dc.w 100,10,1000,42,24,101,10101,555,7,22,17
	LS_ARRAY_LEN NUM_LIST_VALUES,list_values,2


;	Reference values for list insertion unit test

list_values_sorted
	dc.w 7,10,17,22,24,42,100,101,555,1000,10101


	section fast_area,bss

;	Memory area for unit test context, 
; allocation and list tests

membuffer
	ds.b $1000
