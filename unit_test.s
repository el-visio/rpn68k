;       T T T T T T T T T T T T T T T 
;
;	Unit tests for rpn68k
;
;
;	Build and run, then see register values for information
;
;	d0:  $0000 success
;		   $ffff unit test failed
;	
;	d6:  actual value for a failed test
;
;	d7:  number of succesful test cases (also the index of
;			 failed test if any)
;
;	a5:	 pointer to failed test, disassemble here to investigate
;

  include rpn68k.i
  include list.i
  include unit_test.i

UT_ARITH_TESTS equ 1	; Enable tests for arithmetic commands
UT_IF_TESTS    equ 1	; Enable tests for if commands
UT_ALLOC_TESTS equ 1	; Enable tests for memory allocation
UT_LIST_TESTS  equ 1	; Enable tests for list insertion



  RPN68K_INIT		; init rpn68k

  moveq #0,d7								; Reset unit test index

  lea membuffer,a6					; Membuffer pointer to a6
  lea SIZEOF_UT(a6),a1			; Add unit test context size
  move.l a1,UT_mempool(a6)	; Store to UT_mempool

;
;	Add test values to unit test context
;

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


  IF UT_ARITH_TESTS=1

  TEST_NAME 'add_'

  LS_ARITH_TEST #10,#20,add_,#30
  LS_ARITH_TEST #-10,#20,add_,#10
  LS_ARITH_TEST #-10,#-20,add_,#-30

  LS_ARITH_TEST_BASE.w UT_p10(a6),UT_p20(a6),add_,#30
  LS_ARITH_TEST_BASE.w UT_m10(a6),UT_p20(a6),add_,#10
  LS_ARITH_TEST_BASE.w UT_m10(a6),UT_m20(a6),add_,#-30

  LS_ARITH_TEST_BASE.l UT_p10l(a6),UT_p20l(a6),add_,#30
  LS_ARITH_TEST_BASE.l UT_m10l(a6),UT_p20l(a6),add_,#10
  LS_ARITH_TEST_BASE.l UT_m10l(a6),UT_m20l(a6),add_,#-30


  TEST_NAME 'sub_'

  LS_ARITH_TEST #30,#20,sub_,#10
  LS_ARITH_TEST #10,#30,sub_,#-20
  LS_ARITH_TEST #-10,#-20,sub_,#10

  LS_ARITH_TEST_BASE.w UT_p30(a6),UT_p20(a6),sub_,#10
  LS_ARITH_TEST_BASE.w UT_p10(a6),UT_p30(a6),sub_,#-20
  LS_ARITH_TEST_BASE.w UT_m10(a6),UT_m20(a6),sub_,#10

  LS_ARITH_TEST_BASE.l UT_p30l(a6),UT_p20l(a6),sub_,#10
  LS_ARITH_TEST_BASE.l UT_p10l(a6),UT_p30l(a6),sub_,#-20
  LS_ARITH_TEST_BASE.l UT_m10l(a6),UT_m20l(a6),sub_,#10


  TEST_NAME 'mul'

  LS_ARITH_TEST_BASE.w #10,#20,mul,#200
  LS_ARITH_TEST_BASE.w #10,#-20,mul,#-200
  LS_ARITH_TEST_BASE.w #-10,#-20,mul,#200

  LS_ARITH_TEST_BASE.w UT_p10(a6),UT_p20(a6),mul,#200
  LS_ARITH_TEST_BASE.w UT_p10(a6),UT_m20(a6),mul,#-200
  LS_ARITH_TEST_BASE.w UT_m10(a6),UT_m20(a6),mul,#200


  TEST_NAME 'div'

  LS_ARITH_TEST_BASE.w #200,#10,div,#20
  LS_ARITH_TEST_BASE.w #200,#-10,div,#-20
  LS_ARITH_TEST_BASE.w #-200,#-10,div,#20


  TEST_NAME 'mod'

  LS_ARITH_TEST_BASE.w #15,#10,mod,#5
  LS_ARITH_TEST_BASE.w #15,#5,mod,#0
  LS_ARITH_TEST_BASE.w #30,#20,mod,#10


  TEST_NAME 'and_'

  LS_ARITH_TEST #$ff00,#$f0f0,and_,#$f000
  LS_ARITH_TEST_BASE.w UT_0xff00(a6),UT_0xf0f0(a6),and_,#$f000


  TEST_NAME 'or_'

  LS_ARITH_TEST #$ff00,#$f0f0,or_,#$fff0
  LS_ARITH_TEST_BASE.w UT_0xff00(a6),UT_0xf0f0(a6),or_,#$fff0


  TEST_NAME 'xor_'

  LS_ARITH_TEST #$ff00,#$f0f0,xor_,#$0ff0
  LS_ARITH_TEST_BASE.w UT_0xff00(a6),UT_0xf0f0(a6),xor_,#$0ff0


  TEST_NAME 'asr_'

  LS_ROT_TEST #1024,#6,asr_,#16
  LS_ROT_TEST #-1024,#6,asr_,#-16


  TEST_NAME 'asl_'

  LS_ROT_TEST #16,#6,asl_,#1024
  LS_ROT_TEST #-16,#6,asl_,#-1024


  TEST_NAME 'ror_'

  LS_ROT_TEST_BASE.w #$1234,#4,ror_,#$4123
  LS_ROT_TEST_BASE.l #$12345678,#4,ror_,#$81234567


  TEST_NAME 'rol_'

  LS_ROT_TEST_BASE.w #$1234,#4,rol_,#$2341
  LS_ROT_TEST_BASE.l #$12345678,#4,rol_,#$23456781

  ENDC	; UT_ARITH_TESTS


  IF UT_IF_TESTS=1

  TEST_NAME 'if_eq'

  LS_IF_TEST #15,#15,if_eq,#UT_TRUE
  LS_IF_TEST #15,#10,if_eq,#UT_FALSE
  LS_IF_TEST_BASE_w UT_p10(a6),#10,if_eq,#UT_TRUE
  LS_IF_TEST_BASE_w UT_p10(a6),#0,if_eq,#UT_FALSE
  LS_IF_TEST_BASE_l UT_p10l(a6),#10,if_eq,#UT_TRUE
  LS_IF_TEST_BASE_l UT_p10l(a6),#0,if_eq,#UT_FALSE


  TEST_NAME 'if_ne'

  LS_IF_TEST #15,#15,if_ne,#UT_FALSE
  LS_IF_TEST #15,#10,if_ne,#UT_TRUE
  LS_IF_TEST_BASE_w UT_p10(a6),#10,if_ne,#UT_FALSE
  LS_IF_TEST_BASE_w UT_p10(a6),#0,if_ne,#UT_TRUE
  LS_IF_TEST_BASE_l UT_p10l(a6),#10,if_ne,#UT_FALSE
  LS_IF_TEST_BASE_l UT_p10l(a6),#0,if_ne,#UT_TRUE


; signed if
  TEST_NAME 'if_lo'

  LS_IF_TEST #20,#15,if_lo,#UT_FALSE
  LS_IF_TEST #15,#15,if_lo,#UT_FALSE
  LS_IF_TEST #10,#15,if_lo,#UT_TRUE
  LS_IF_TEST #10,#-10,if_lo,#UT_FALSE
  LS_IF_TEST #-10,#10,if_lo,#UT_TRUE


  TEST_NAME 'if_ls'

  LS_IF_TEST #20,#15,if_ls,#UT_FALSE
  LS_IF_TEST #15,#15,if_ls,#UT_TRUE
  LS_IF_TEST #10,#15,if_ls,#UT_TRUE
  LS_IF_TEST #10,#-10,if_ls,#UT_FALSE
  LS_IF_TEST #-10,#10,if_ls,#UT_TRUE


  TEST_NAME 'if_hi'

  LS_IF_TEST #20,#15,if_hi,#UT_TRUE
  LS_IF_TEST #15,#15,if_hi,#UT_FALSE
  LS_IF_TEST #10,#15,if_hi,#UT_FALSE
  LS_IF_TEST #10,#-10,if_hi,#UT_TRUE
  LS_IF_TEST #-10,#10,if_hi,#UT_FALSE


  TEST_NAME 'if_hs'

  LS_IF_TEST #20,#15,if_hs,#UT_TRUE
  LS_IF_TEST #15,#15,if_hs,#UT_TRUE
  LS_IF_TEST #10,#15,if_hs,#UT_FALSE
  LS_IF_TEST #10,#-10,if_hs,#UT_TRUE
  LS_IF_TEST #-10,#10,if_hs,#UT_FALSE


; unsigned if
  TEST_NAME 'if_ulo'

  LS_IF_TEST #20,#15,if_ulo,#UT_FALSE
  LS_IF_TEST #15,#15,if_ulo,#UT_FALSE
  LS_IF_TEST #10,#15,if_ulo,#UT_TRUE
  LS_IF_TEST #10,#-10,if_ulo,#UT_TRUE
  LS_IF_TEST #-10,#10,if_ulo,#UT_FALSE


  TEST_NAME 'if_uls'

  LS_IF_TEST #20,#15,if_uls,#UT_FALSE
  LS_IF_TEST #15,#15,if_uls,#UT_TRUE
  LS_IF_TEST #10,#15,if_uls,#UT_TRUE
  LS_IF_TEST #10,#-10,if_uls,#UT_TRUE
  LS_IF_TEST #-10,#10,if_uls,#UT_FALSE


  TEST_NAME 'if_uhi'

  LS_IF_TEST #20,#15,if_uhi,#UT_TRUE
  LS_IF_TEST #15,#15,if_uhi,#UT_FALSE
  LS_IF_TEST #10,#15,if_uhi,#UT_FALSE
  LS_IF_TEST #10,#-10,if_uhi,#UT_FALSE
  LS_IF_TEST #-10,#10,if_uhi,#UT_TRUE


  TEST_NAME 'if_uhs'

  LS_IF_TEST #20,#15,if_uhs,#UT_TRUE
  LS_IF_TEST #15,#15,if_uhs,#UT_TRUE
  LS_IF_TEST #10,#15,if_uhs,#UT_FALSE
  LS_IF_TEST #10,#-10,if_uhs,#UT_FALSE
  LS_IF_TEST #-10,#10,if_uhs,#UT_TRUE

  ENDC	; UT_IF_TESTS



  IF UT_ALLOC_TESTS=1

  TEST_CASE
  alloc UT_mempool(a6),#1000
  sub_.l UT_mempool(a6)
  LS_COMPARE_RESULT.l #-1000

  TEST_CASE
  alloc UT_mempool(a6),#2000
  sub_.l UT_mempool(a6)
  LS_COMPARE_RESULT.l #-2000

  ENDC ; UT_ALLOC_TESTS


  IF UT_LIST_TESTS=1

  TEST_NAME 'list'

  TEST_CASE
  UT_CREATE_DEMO_LIST asc
  UT_COMPARE_DEMO_LIST list_values_sorted(pc),(a2)+

  TEST_CASE
  UT_CREATE_DEMO_LIST desc
  UT_COMPARE_DEMO_LIST list_values_sorted+NUM_LIST_VALUES*2(pc),-(a2)

  ENDC	; UT_LIST_TESTS

;
;	All tests successful
;

  moveq	#0,d0					; Error code for success
  moveq	#0,d6					;	Reset actual result
  move.l d0,a5				; Reset failed test pointer
  rts

;
;	Test failed!
;

UT_test_failed
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

;	Memory area for unit tests

membuffer
	ds.b $1000
