;       T T T T T T T T T T T T T T T T T T T T T T T T T T T T T
;
;	Donut Demo for Amiga OCS
;
;	Texture generating etc with rpn68k
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
	include hardware/intbits.i		;
	include hardware/dmabits.i		;


;	Global struct

rsreset
GB_fast				rs.l 1
GB_chip				rs.l 1
GB_sqrt_tbl		rs.l 1
GB_sin_tbl		rs.l 1
GB_dist_tbl		rs.l 1
GB_olddma			rs.l 1
GB_oldint			rs.l 1
GB_sdf_bitmap rs.l 1
GB_texture		rs.l 1
GB_time				rs.l 1
SIZEOF_GB			rs.l 0

SDF_PLANE_WIDTH equ 44
SDF_PLANE_HEIGHT equ 288

MAX_OUTER_RADIUS equ $0f00
MAX_INNER_RADIUS equ $0600


start

	lea	fast_area,a6
	lea SIZEOF_GB(a6),a1
	move.l a1,GB_fast(a6)
	move.l #chip_area,GB_chip(a6)

	alloc GB_fast(a6),#$8000
	sto GB_sqrt_tbl(a6)
	restore.l
	sto a0

;
;	Generate 32k square root table (12 bit fixed point)
;

	ld #0,value			; value = 0
	ld #0,sqroot		; sqroot = 0

	loop_in_const $4000				; loop $4000 times
	  while_in								; while (square(sqroot) < value) {
	    square12f sqroot+LOCAL(a7)
	    if_lo value+LOCAL(a7)	;
	      inc sqroot+LOCAL(a7);   sqroot++ 
	  while_out								; }
	  move.w sqroot+LOCAL(a7),(a0)+ ; *sqrt_table++ = sqroot
	  add.w #2,value+LOCAL(a7); value += 2
	loop_out									; loop out

	drop	; drop local variable (sqroot)
	drop	; drop local variable (value)


;
;	Generate 16x16 distance table
;

	alloc GB_fast(a6),#$200
	sto GB_dist_tbl(a6)
	restore.l
	sto.l a0
	move.l GB_sqrt_tbl(a6),a2

	ld #-(1<<12),y

	loop_in_const 16
	  ld #-(1<<12),x
	  loop_in_const 16
	    square12f x+LOCAL(a7)
    	    square12f y+LOCAL(a7)
	    add_

	    and_ #$fffe
	    move.w (a2,d0.w),(a0)+
	    drop

	    add.w #(1<<9),x+LOCAL(a7)
	  loop_out
	  add.w #(1<<9),y+LOCAL(a7)
	loop_out

	drop	; y


;
;	Calculate sin table
;
;	(old piece of code from Damones demo, not rpn68k style)
;

	alloc GB_fast(a6),#$10000
	sto GB_sin_tbl(a6)
	restore.l
	sto a0

calc_sin
	move.l a0,a1
	add.l	#$8000,a1

	moveq	#0,d1		; sin
	move.l	#1<<30,d2	; cos
	move.w	#$6487,d3	; freq
	moveq	#11,d5		; shift value for calc
	moveq	#18,d7		; shift value for final int16 (max 1<<12)

	move.l	#$3fff,d0	; 1/2 of the sintable
.1	move.l d1,d6
	asr.l	d7,d6
	move.w	d6,(a0)+
	neg.w	d6
	move.w	d6,(a1)+	; other half of sin is neg

	move.w	d6,$dff180

	move.l	d1,d4
	swap	d4
	muls	d3,d4
	asr.l	d5,d4
	sub.l	d4,d2

	move.l	d2,d4
	swap	d4
	muls	d3,d4
	asr.l	d5,d4
	add.l	d4,d1

	dbf	d0,.1

	alloc GB_chip(a6),#SDF_PLANE_WIDTH*SDF_PLANE_HEIGHT*2
	sto.l GB_sdf_bitmap(a6)

	alloc GB_chip(a6),#16*2*2*64	; allocate space for 64 textures
	sto.l GB_texture(a6)

	move.l GB_texture(a6),a2		; texture pointer

	loop_in_const 64							; generate 64 bitmaps
		var donut_idx								; loop counter variable name
		move.l GB_dist_tbl(a6),a0		; pointer to 16x16 distance table

		ld donut_idx+LOCAL(a7)			; calculate outer radius
		inc													;
		asl_ #6											;	
		mul12f #MAX_OUTER_RADIUS		;
		var outer_r									; variable name

		ld donut_idx+LOCAL(a7)			; calculate inner radius
		inc													;
		asl_ #6											;
		mul12f #MAX_INNER_RADIUS		;
		var inner_r									; variable name

		loop_in_const 16
			loop_in_const 16
				ldc (a0)									; get distance from center
				sub_ outer_r+LOCAL(a7)		; outer circle radius
				
				ldc (a0)+								; get distance from center
				sub_ inner_r+LOCAL(a7)	; inner circle radius
				neg_					; negate inner circle
				max						; substract inner from outer

				neg_				; calculate 2 bit anti-alias 
				add_ #$100	;
				max #0			; 
				asr_ #8			;
				min #3			;

				roxr.w #1,d0	; chunky bit for plane 0
				roxl.w #1,d2
				roxr.w #1,d0	; chunky bit for plane 1
				roxl.w #1,d3
				drop					; drop top of stack
			loop_out
			move.w d2,(a2)+	; output plane 0
			move.w d3,(a2)+	; output plane 1
		loop_out
	loop_out

	lea $dff000,a5
	move.w dmaconr(a5),GB_olddma(a6)
	move.w intenar(a5),GB_oldint(a6)
	move.w #$7fff,dmacon(a5)
	move.w #$7fff,intena(a5)

	move.w #$1c71,diwstrt(a5)
	move.w #$3cd1,diwstop(a5)
	move.w #$30,ddfstrt(a5)
	move.w #$d8,ddfstop(a5)
	move.w #SDF_PLANE_WIDTH,bpl1mod(a5)
	move.w #SDF_PLANE_WIDTH,bpl2mod(a5)
	move.w #$2000,bplcon0(a5)

	move.w #DMAF_SETCLR|DMAF_MASTER|DMAF_RASTER|DMAF_BLITTER,dmacon(a5)

;
;	Main loop
;
;

main_loop

	move.w #INTF_VERTB,intreq(a5)

.vbl
	btst #INTB_VERTB,intreqr+1(a5)
	beq .vbl
	move.w #INTF_VERTB,intreq(a5)

	bsr tick

	inc.l GB_time(a6)
	btst #6,$bfe001
	bne .vbl


;
;	Exit
;


	ldc GB_oldint(a6)
	or_ #DMAF_SETCLR
	sto intena(a5)

	ldc GB_olddma(a6)
	or_ #DMAF_SETCLR
	sto dmacon(a5)

	rts


tick:	lea $dff000,a5
	move.l GB_sdf_bitmap(a6),a0
	lea 	bplpt(a5),a2
	move.l a0,(a2)+				; first bitplane
	add.w	#44,a0
	move.l a0,(a2)+				; second bitplane

	lea colors(pc),a0
	lea color(a5),a2
	move.l (a0)+,(a2)+
	move.l (a0)+,(a2)+

	move.l GB_texture(a6),a2
	ldc	GB_time+2(a6)		; lower word of GB_time
	and_ #$003f
	asl_ #6
	add_to a2

	move.w #SDF_PLANE_WIDTH*SDF_PLANE_HEIGHT,d2
	loop_in #22
		move.l GB_sdf_bitmap(a6),a3
		add.w d2,a3
		push.l a2
		loop_in #32					; todo USE BLITTER
			move.w (a2)+,(a3)
			add.w #SDF_PLANE_WIDTH,a3
		loop_out

		pop.l a2

		add.w #2,d2
	loop_out


	rts

colors	dc.w $000,$555,$aaa,$fff


	section fast_area,bss

fast_area
	ds.b	$40000

	section chip_area,bss_c
chip_area
	ds.b	$60000

