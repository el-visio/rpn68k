;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T T
;
;	Donut Demo for Amiga OCS
;
;	Texture generating etc using rpn68k
;
;
;	<<< Work in progress! >>>
;
;	Some bad coding practices here (both generally & rpn68k)
;	but still demonstrates rpn68k functionality.
;	Needs to finish, clean up and comment! Soon...
;
;
;	EL VISIO 25-feb-2020
;

	include "rpn68k.i"
	include hardware/custom.i			;	Amiga include files
	include hardware/intbits.i		; (Google is your friend)
	include hardware/dmabits.i		;
	include hardware/blit.i


;	Global struct

rsreset
GB_fast					rs.l 1
GB_chip					rs.l 1
GB_sqrt_tbl			rs.l 1
GB_sin_tbl			rs.l 1
GB_dist_tbl			rs.l 1
GB_olddma				rs.w 1
GB_oldint				rs.w 1
GB_coplist			rs.l 1
GB_logocode_w		rs.l 1
GB_logocode_l		rs.l 1
GB_sdf_bitmap		rs.l 1
GB_zoom_bitmap	rs.l 1
GB_texture			rs.l 1
GB_time					rs.l 1
SIZEOF_GB				rs.l 0

WAIT_BLIT macro
wb\@	btst	#14,dmaconr(\1)
	bne	wb\@
	endm

DOUBLE_BUFFER_PAINT macro
	move.l \1,\3
	btst #0,GB_time+3(a6)
	if_
		add.w #\2,\3
	end_if
	endm

DOUBLE_BUFFER_SHOW macro
	move.l \1,\3
	btst #0,GB_time+3(a6)
	if_not
		add.w #\2,\3
	end_if
	endm



SDF_PLANE_WIDTH			equ 44
SDF_PLANE_HEIGHT		equ 288
SDF_PLANES_SIZE			equ (SDF_PLANE_WIDTH*SDF_PLANE_HEIGHT*2)

LOGO_WIDTH 					equ 64
LOGO_HEIGHT 				equ 8

COPLIST_SIZE				equ $2000

ZOOM_PLANE_WIDTH 		equ 46
ZOOM_PLANE_HEIGHT 	equ 288
ZOOM_PLANE_SIZE 		equ (ZOOM_PLANE_WIDTH*(LOGO_HEIGHT+2)+2)

CONST_1_0 					equ 1<<12				; 1.0 in 12 bit fixed point


	lea	fast_area,a6
	lea SIZEOF_GB(a6),a1
	move.l a1,GB_fast(a6)
	move.l #chip_area,GB_chip(a6)


;	Generate 32k square root table (12 bit fixed point)

	alloc GB_fast(a6),#$8000
	sto GB_sqrt_tbl(a6)

	restore.l a0		; sqrt table buffer to a0

	ld #0,value			; value = 0
	ld #0,sqroot		; sqroot = 0

	loop_in_const $4000							; loop $4000 times
	  while_in											; while (square(sqroot) < value) {
	    square12f sqroot+LOCAL(a7)	;
	    if_lo value+LOCAL(a7)				;
	      inc sqroot+LOCAL(a7)			;   sqroot++ 
	  while_out											; }
	  move.w sqroot+LOCAL(a7),(a0)+ ; *sqrt_table++ = sqroot
	  add.w #2,value+LOCAL(a7)			; value += 2
	loop_out												; loop out


;	Generate 16x16 distance table

	alloc GB_fast(a6),#$200
	sto GB_dist_tbl(a6)

	restore.l a0							; distance table buffer to a0
	move.l GB_sqrt_tbl(a6),a2	; sqrt table to a2

	ld #-CONST_1_0,y					; y = -1.0

	loop_in_const 16
		ld #-CONST_1_0,x				; x = -1.0
		loop_in_const 16
			square12f x+LOCAL(a7)		; x * x + y * y
			square12f y+LOCAL(a7)
			add_

			and_ #$fffe							; mask lowest bit
			move.w (a2,d0.w),(a0)+	; get square root pythagoras style
			add.w #CONST_1_0/8,x+LOCAL(a7)	; step x value by 0.125
		loop_out
		add.w #CONST_1_0/8,y+LOCAL(a7)		; step y value by 0.125
	loop_out

	RESET_STACK		; drop obsolete local variables from stack


;	Calculate sin table
;
;	(old piece of code from Damones demo, not rpn68k style)

	alloc GB_fast(a6),#$10000
	sto.l a0

calc_sin
	move.l a0,a1
	add.l #$8000,a1

	moveq #0,d1		; sin
	move.l #1<<30,d2	; cos
	move.w #$6487,d3	; freq
	moveq #11,d5		; shift value for calc
	moveq #18,d7		; shift value for final int16 (max 1<<12)

	move.l #$3fff,d0	; 1/2 of the sintable
.1
	move.l d1,d6
	asr.l d7,d6
	move.w d6,(a0)+
	neg.w d6
	move.w d6,(a1)+	; other half of sin is neg

	move.w d6,$dff180

	move.l d1,d4
	swap d4
	muls d3,d4
	asr.l d5,d4
	sub.l d4,d2

	move.l d2,d4
	swap d4
	muls d3,d4
	asr.l d5,d4
	add.l d4,d1

	dbf d0,.1

	move.l a0,GB_sin_tbl(a6)		; Pointer to middle of sin table


;	Generate code for logo columns

	alloc GB_fast(a6),#LOGO_WIDTH*(LOGO_HEIGHT*4+2)
	sto.l GB_logocode_w(a6)
	restore.l a0

	alloc GB_fast(a6),#LOGO_WIDTH*(LOGO_HEIGHT*4+2)
	sto.l GB_logocode_l(a6)
	restore.l a3

	lea logo(pc),a2

	loop_in_const LOGO_WIDTH/8		; width bytes
		moveq #7,d2									; bit to be tested
		loop_in_const 8							; width bits
			moveq #0,d3								; src offset
			moveq #0,d4								; dest offset
			loop_in_const LOGO_HEIGHT	; height
				LS_FLUSH
				btst d2,(a2,d3.w)
				if_
					move.w cmd_or_w(pc),(a0)+
					move.w cmd_or_l(pc),(a3)+
				el_se
					move.w cmd_and_w(pc),(a0)+
					move.w cmd_and_l(pc),(a3)+
				end_if
				move.w d4,(a0)+
				move.w d4,(a3)+
				add.w #LOGO_WIDTH/8,d3
				add.w #ZOOM_PLANE_WIDTH,d4
			loop_out
			move.w cmd_rts(pc),(a0)+
			move.w cmd_rts(pc),(a3)+
			subq #1,d2
		loop_out
		addq #1,a2												; increment logo offset
	loop_out


;	Allocate SDF bitmap

	alloc GB_chip(a6),#SDF_PLANES_SIZE*2
	sto.l GB_sdf_bitmap(a6)


;	Allocate copperlist

	alloc_64k GB_chip(a6),#COPLIST_SIZE*2
	sto.l GB_coplist(a6)


;	Allocate zoomer bitmap

	alloc_64k GB_chip(a6),#ZOOM_PLANE_SIZE*2
	sto.l GB_zoom_bitmap(a6)


;	Allocate space for 64 textures

	alloc_64k GB_chip(a6),#16*2*2*65
	sto.l GB_texture(a6)

	restore.l a2									; texture pointer to a2

	loop_in_const 65							; generate 65 bitmaps
		var donut_idx								; variable name for loop_in counter

		ldc donut_idx+LOCAL(a7)			; calculate outer radius
		add_ #10
		div12f #100	
		var outer_r									; variable name

		ldc donut_idx+LOCAL(a7)			; calculate inner radius
		add_ #50
		div12f #120
		sub_ #$400
		var inner_r									; variable name

		move.l GB_dist_tbl(a6),a0		; pointer to 16x16 distance table

		loop_in_const 16
			loop_in_const 16
				ldc (a0)									; get distance from center
				sub_ outer_r+LOCAL(a7)		; outer circle radius
				
				ldc (a0)								; get distance from center
				sub_ inner_r+LOCAL(a7)	; inner circle radius
				neg_										; negate inner circle
				max											; substract inner from outer

				ldc (a0)+								; get distance from center
				ldc inner_r+LOCAL(a7)		; outer_r - $a00
				sub_ #$700							;
				sub_										;
				min											; add to signed distance field

				max #0			;	Calculate 2 bit anti-alias
				div #$e0		;
				min #3			;

				roxr.w #1,d0	; chunky bit for plane 0
				roxl.w #1,d2
				roxr.w #1,d0	; chunky bit for plane 1
				roxl.w #1,d3
			loop_out				; x loop out

			move.w d2,(a2)+	; output plane 0
			move.w d3,(a2)+	; output plane 1
		loop_out					; y loop out
	loop_out						; texture loop out


	; kill system

	lea $dff000,a5
	move.w dmaconr(a5),GB_olddma(a6)
	move.w intenar(a5),GB_oldint(a6)
	move.w #$7fff,dmacon(a5)
	move.w #$7fff,intena(a5)


	; Set screen

	move.w #$1c71,diwstrt(a5)
	move.w #$3cd1,diwstop(a5)
	move.w #$30,ddfstrt(a5)
	move.w #$d8,ddfstop(a5)
	move.w #SDF_PLANE_WIDTH,bpl1mod(a5)
	move.w #-44,bpl2mod(a5)
	move.w #$3000,bplcon0(a5)
	move.l GB_coplist(a6),cop1lc(a5)
	move.w #0,copjmp1(a5)


	; Enable DMA

	move.w #DMAF_SETCLR|DMAF_MASTER|DMAF_RASTER|DMAF_BLITTER|DMAF_COPPER,dmacon(a5)


;	Main loop

main_loop
	lea $dff000,a5
	move.w #INTF_VERTB,intreq(a5)

main_loop_vbl
	btst #INTB_VERTB,intreqr+1(a5)
	beq main_loop_vbl
	move.w #INTF_VERTB,intreq(a5)

	bsr tick

	inc.l GB_time(a6)		; add time counter
	btst #6,$bfe001
	bne main_loop


;	Exit

	lea $dff000,a5
	WAIT_BLIT a5

	move.w #$7fff,intena(a5)
	move.w #$7fff,dmacon(a5)

	move.l GB_coplist(a6),a1
	move.l #$fffffffe,(a1)
	move.l a1,cop1lc(a5)

	ldc GB_olddma(a6)		; restore dma
	or_ #DMAF_SETCLR
	sto dmacon(a5)

	ldc GB_oldint(a6)		; restore interrupts
	or_ #DMAF_SETCLR
	sto intena(a5)

	moveq #0,d0
	rts									; DIRTY EXIT


;	This is called every frame

tick
	; Set SDF bitmap pointers

	DOUBLE_BUFFER_SHOW GB_sdf_bitmap(a6),SDF_PLANES_SIZE,a0
	move.l a0,bplpt(a5)					; first bitplane
	add.w	#44,a0
	move.l a0,bplpt+8(a5)				; second bitplane


	; set copperlist

	DOUBLE_BUFFER_SHOW GB_coplist(a6),COPLIST_SIZE,a1
	move.l a1,cop1lc(a5)
	move.w #0,copjmp1(a5)


	; Set colors

	lea colors(pc),a0
	lea color(a5),a2
	move.w #$f26,d2

	move.w (a0)+,(a2)+
	move.w (a0)+,(a2)+
	move.w d2,(a2)+
	move.w d2,(a2)+
	move.w (a0)+,(a2)+
	move.w (a0)+,(a2)+
	move.w d2,(a2)+
	move.w d2,(a2)+


;	Clear zoomer bitmap

	DOUBLE_BUFFER_PAINT GB_zoom_bitmap(a6),ZOOM_PLANE_SIZE,a0
	add.w	#ZOOM_PLANE_WIDTH,a0
	moveq #0,d2

	REPT (ZOOM_PLANE_WIDTH*LOGO_HEIGHT)/4
		move.l d2,(a0)+
	ENDR

	ld #-(128<<7),x1_orig
	ld #128<<7,x2_orig
	ld #384<<4,camera_z

	move.l GB_sin_tbl(a6),a2			; sin table
	ldc GB_time+2(a6)
	lsl_ #8
	move.w (a2,d0.w),d0
	var z_orig	

	ld camera_z+LOCAL(a7)
	ldc camera_z+LOCAL(a7)
	sub_ z_orig+LOCAL(a7)
	div12f
	var multiplier

	ldc GB_time+2(a6)
	mul #$240
	move.w (a2,d0.w),d0
	var y_mid

	ldc y_mid+LOCAL(a7)
	sub_ #LOGO_HEIGHT<<9
	mul12f multiplier+LOCAL(a7)
	var y1

	ldc y_mid+LOCAL(a7)
	add_ #LOGO_HEIGHT<<9
	mul12f multiplier+LOCAL(a7)
	var y2

	ldc y2+LOCAL(a7)
	sub_ y1+LOCAL(a7)
	udiv #LOGO_HEIGHT
	sto	d3						; delta y

	ldc y1+LOCAL(a7)
	add_ #$ac<<7			; screen center
	sto d2						; y pos

	DOUBLE_BUFFER_PAINT GB_zoom_bitmap(a6),ZOOM_PLANE_SIZE,d4
	addq	#2,d4

	ld #LOGO_HEIGHT+1,num_y_lines

	if_lo d2,#$1c<<7
		ldc #$1c<<7
		sub_ d2
		udiv d3					; / delta_y = num steps before first line

		dup
		mul #ZOOM_PLANE_WIDTH
		sto_add d4

		dup
		mul d3
		sto_add d2

		LS_CACHE
		sub.w d0,num_y_lines+LOCAL(a7)
		drop
	end_if

	DOUBLE_BUFFER_PAINT GB_coplist(a6),COPLIST_SIZE,a2

	move.w #bplpt+6,(a2)+
	move.w d4,(a2)+
	move.w #bplpt+4,(a2)+
	swap d4
	move.w d4,(a2)+
	swap d4
	add.w #ZOOM_PLANE_WIDTH,d4


COP_INNER macro
	loop_in
		ldc d2
		and_ #$ff80					; blitqueue needs this
		lsl_ #1
		or_ #1
		sto (a2)+
		move.w #$ff00,(a2)+
		move.w #bplpt+6,(a2)+
		move.w d4,(a2)+
		
		add.w #ZOOM_PLANE_WIDTH,d4
		add.w d3,d2
	loop_out
	endm


	ldc #$100<<7		; Calculate number of rows before y = $100
	sub_ d2					; which needs an extra wait in the copperlist
	udiv d3					;
	inc							;

	min num_y_lines+LOCAL(a7)

	LS_CACHE
	sub.w d0,num_y_lines+LOCAL(a7)

	COP_INNER				; create coplist until line $100
	move.l #$ffe1fffe,(a2)+			; wait for line $100
;	move.w #color,(a2)+
;	move.w #$0f0,(a2)+

	ldc num_y_lines+LOCAL(a7)
	COP_INNER				; create coplist until obj end
	move.l #$fffffffe,(a2)+



	moveq	#0,d4										; column code offset

	ldc x1_orig+LOCAL(a7)
	mul12f.l multiplier+LOCAL(a7)
	var x1_projected

	ldc x2_orig+LOCAL(a7)
	mul12f.l multiplier+LOCAL(a7)
	var x2_projected

	ldc.l x2_projected+LOCAL(a7)
	sub_.l x1_projected+LOCAL(a7)
	div.l #LOGO_WIDTH
	var column_delta_x

	moveq #0,d2
	move.w column_delta_x+LOCAL(a7),d2

	while_in
		ldc.l x1_projected+LOCAL(a7)
		add_.l d2
		if_lo.l #-(176<<7)
			add.l d2,x1_projected+LOCAL(a7)
			add.w #LOGO_HEIGHT*4+2,d4
	while_out

	ld x1_projected+2+LOCAL(a7),x1

	ldc x1+LOCAL(a7)
	and_ #%1111100000000000
	var screen_x

	DOUBLE_BUFFER_PAINT GB_zoom_bitmap(a6),ZOOM_PLANE_SIZE,a0

	add.w	#ZOOM_PLANE_WIDTH,a0
	ldc screen_x+LOCAL(a7)
	add_ #192<<7
	lsr.w #7,d0
	lsr.w #3,d0
	sto_add a0

 	move.l GB_logocode_w(a6),a2
 	move.l GB_logocode_l(a6),a3

	while_in
		if_lo d4,#(LOGO_HEIGHT*4+2)*LOGO_WIDTH
		and_if_lo x1+LOCAL(a7),#176<<7
			ldc x1+LOCAL(a7)
			sub_ screen_x+LOCAL(a7)
			asr_ #7
			move.w #$ffff,d2
			lsr.w d0,d2
			drop

			ldc x1+LOCAL(a7)									; if ((x1 + column_delta_x) <
			add_ column_delta_x+LOCAL(a7)			;    (screen_x + 16<<7))
			ldc screen_x+LOCAL(a7)
			add_ #16<<7
			if_lo															; column fits in a word
				move.w d2,d3										; single word operation
				not.w d3
				jsr (a2,d4.w)
			el_se															; column over word border
				swap d2													; --> two word operation
				move.w #$ffff,d2
				move.l d2,d3
				not.l d3
				jsr (a3,d4.w)

				add.w #16<<7,screen_x+LOCAL(a7)
				addq #2,a0
			end_if

			add.w #LOGO_HEIGHT*4+2,d4
			ldc x1+LOCAL(a7)
			add_ column_delta_x+LOCAL(a7)
			sto x1+LOCAL(a7)
	while_out

	ldc x1+LOCAL(a7)
	sub_ screen_x+LOCAL(a7)
	asr_ #7
	move.w #$ffff,d3
	lsr.w d0,d3
	not.w d3

	loop_in_const LOGO_HEIGHT
		and.w d3,(a0)
		add.w #ZOOM_PLANE_WIDTH,a0
	loop_out


	; setup blitter

	WAIT_BLIT a5

	move.w #SRCA+DEST+$f0,bltcon0(a5)
	move.w #0,bltcon1(a5)
	move.l #-1,bltafwm(a5)
	move.w #0,bltamod(a5)
	move.w #SDF_PLANE_WIDTH-2,bltdmod(a5)

	move.l GB_sqrt_tbl(a6),a0
	move.l GB_sin_tbl(a6),a2			; sin table
	move.l GB_texture(a6),a4
	DOUBLE_BUFFER_PAINT GB_sdf_bitmap(a6),SDF_PLANES_SIZE,a3

	ldc GB_time+2(a6)
	mul #$60
	move.w (a2,d0.w),d0		; get sin
	mul12f #128<<4
	var center_x	

	ldc GB_time+2(a6)
	mul #$60
	add_ #$4000						; add PI/2 
	move.w (a2,d0.w),d0		; get cos
	mul12f #128<<4
	var center_y

	ldc #-(168<<4)
	sub_ center_x+LOCAL(a7)
	var x_coord

	loop_in_const SDF_PLANE_WIDTH/2		; x loop
		square12f x_coord+LOCAL(a7)
		var x_squared

		add.w #16<<4,x_coord+LOCAL(a7)

		WAIT_BLIT a5
		move.l a3,bltdpt(a5)

		ldc #-(136<<4)
		sub_ center_y+LOCAL(a7)
		var y_coord

		loop_in_const SDF_PLANE_HEIGHT/16				; y loop
			square12f y_coord+LOCAL(A7)
			add_ x_squared+LOCAL(a7)
			and_ #$fffe
			move.w (a0,d0.w),d0

			ldc GB_time+2(a6)
			asl_ #6
			sub_

			asl_ #5

			move.w (a2,d0.w),d0

			add_ #CONST_1_0
			asr_ #1

			and_ #%0001111111000000
			lea (a4,d0.w),a1

			add.w #16<<4,y_coord+LOCAL(a7)

			WAIT_BLIT a5
			move.l a1,bltapt(a5)
			move.w #32<<6+1,bltsize(a5)

		loop_out

		addq #2,a3
	loop_out

	RESET_STACK

	rts


colors
	dc.w $000,$a42,$9c9,$fff

cmd_and_w
	and.w d3,$555(a0)
cmd_or_w
	or.w d2,$555(a0)
cmd_and_l
	and.l d3,$555(a0)
cmd_or_l
	or.l d2,$555(a0)
cmd_rts
	rts

logo
	inciff	'rpn68k.iff'



	section section_fast,bss
fast_area
	ds.b	$40000


	section section_chip,bss_c
chip_area
	ds.b	$60000

