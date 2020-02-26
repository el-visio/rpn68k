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
GB_fast				rs.l 1
GB_chip				rs.l 1
GB_sqrt_tbl		rs.l 1
GB_sin_tbl		rs.l 1
GB_dist_tbl		rs.l 1
GB_olddma			rs.w 1
GB_oldint			rs.w 1
GB_sdf_bitmap rs.l 1
GB_texture		rs.l 1
GB_time				rs.l 1
SIZEOF_GB			rs.l 0

WAIT_BLIT macro
wb\@	btst	#14,dmaconr(\1)
	bne	wb\@
	endm


SDF_PLANE_WIDTH equ 44
SDF_PLANE_HEIGHT equ 288

MAX_OUTER_RADIUS equ $0f00
MAX_INNER_RADIUS equ $0600

CONST_1_0 			equ 1<<12				; 1.0 in 12 bit fixed point



start
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
;	sto GB_sin_tbl(a6)
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


;	Allocate screen bitmap

	alloc GB_chip(a6),#SDF_PLANE_WIDTH*SDF_PLANE_HEIGHT*2
	sto.l GB_sdf_bitmap(a6)


;	Allocate space for 64 textures

	alloc GB_chip(a6),#16*2*2*64	
	sto.l GB_texture(a6)

	restore.l a2									; texture pointer to a2

	loop_in_const 64							; generate 64 bitmaps
		var donut_idx								; variable name for loop_in counter

		ldc donut_idx+LOCAL(a7)			; calculate outer radius
		add_ #26
		div12f #100	
		var outer_r									; variable name

		ldc donut_idx+LOCAL(a7)			; calculate inner radius
		add_ #90
		div12f #180
		sub_ #$200
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
				ldc outer_r+LOCAL(a7)		; outer_r - 0.5
				sub_ #CONST_1_0/2				;
				sub_										;
				min											; add to signed distance field

				neg_				; calculate 2 bit anti-alias 
				add_ #$300	;
				max #0			;
				asr_ #8
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
	move.w #SDF_PLANE_WIDTH,bpl2mod(a5)
	move.w #$2000,bplcon0(a5)


	; Enable DMA

	move.w #DMAF_SETCLR|DMAF_MASTER|DMAF_RASTER|DMAF_BLITTER,dmacon(a5)


;	Main loop

main_loop
	lea $dff000,a5
	move.w #INTF_VERTB,intreq(a5)

.vbl
	btst #INTB_VERTB,intreqr+1(a5)
	beq .vbl
	move.w #INTF_VERTB,intreq(a5)

	bsr tick

	inc.l GB_time(a6)		; add time counter
	btst #6,$bfe001
	bne main_loop


;	Exit

	ldc GB_oldint(a6)		; restore interrupts
	or_ #DMAF_SETCLR
	sto intena(a5)

	ldc GB_olddma(a6)		; restore dma
	or_ #DMAF_SETCLR
	sto dmacon(a5)

	rts									; DIRTY EXIT


;	This is called every frame

tick
	; Set bitplane pointers

	move.l GB_sdf_bitmap(a6),a0
	lea bplpt(a5),a2
	move.l a0,(a2)+				; first bitplane
	add.w	#44,a0
	move.l a0,(a2)+				; second bitplane


	; Set colors

	lea colors(pc),a0
	lea color(a5),a2
	move.l (a0)+,(a2)+
	move.l (a0)+,(a2)+


	; setup blitter

	WAIT_BLIT a5

	move.l a2,bltapt(a5)
	move.l a3,bltdpt(a5)
	move.w #SRCA+DEST+$f0,bltcon0(a5)
	move.w #0,bltcon1(a5)
	move.l #-1,bltafwm(a5)
	move.w #0,bltamod(a5)
	move.w #SDF_PLANE_WIDTH-2,bltdmod(a5)


	ldc GB_time+2(a6)
	mul #700
	var sin_y1

	ldc GB_time+2(a6)
	mul #-500
	var sin_y2

	move.l GB_sin_tbl(a6),a2			; sin table
	move.l GB_sdf_bitmap(a6),a3		; output bitmap


	loop_in_const SDF_PLANE_HEIGHT/16			; y loop
		moveq #0,d2

		ldc sin_y1+LOCAL(a7)
		move.w (a2,d0.w),d0			; get sin

		ldc sin_y2+LOCAL(a7)
		move.w (a2,d0.w),d0			; get sin
		add_

		var sin_y

		ldc GB_time+2(a6)
		mul #500
		var sin_x1

		ldc GB_time+2(a6)
		mul #-700
		var sin_x2

		loop_in_const SDF_PLANE_WIDTH/2				; x loop
			lea (a3,d2.w),a1

			ldc sin_x1+LOCAL(a7)
			move.w (a2,d0.w),d0			; sin pt

			ldc sin_x2+LOCAL(a7)
			move.w (a2,d0.w),d0			; sin pt
			add_

			add_ sin_y+LOCAL(a7)
			asr_ #2

			mul12f #31
			add_ #32
			asl_ #6
			ext.l d0
			restore.l			
			add_.l GB_texture(a6)
			
			WAIT_BLIT a5
			sto.l bltapt(a5)
			move.l a1,bltdpt(a5)
			move.w #32<<6+1,bltsize(a5)
			addq #2,d2

			add.w #$1000,sin_x1+LOCAL(a7)
			add.w #$1400,sin_x2+LOCAL(a7)
			
		loop_out

		add.w #$1000,sin_y1+LOCAL(a7)
		add.w #$1400,sin_y2+LOCAL(a7)

		lea SDF_PLANE_WIDTH*32(a3),a3
	loop_out

	RESET_STACK

	rts

colors
	dc.w $c8c,$95b,$426,$203


	section fast_area,bss

fast_area
	ds.b	$40000

	section chip_area,bss_c
chip_area
	ds.b	$60000

