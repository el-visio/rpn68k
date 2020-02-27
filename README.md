# rpn68k 

_"Special tool for special people"_


## What is rpn68k?

A macro extension for Motorola 68000 assembly with Forth inspired syntax. Improve your development time without slowing down the code. 

Featuring
- hybrid accumulator / stack arithmetic, also fixed point operations
- named local variables
- structured assembly: if / else / endif, range loops, while loops - and _everything can be nested_
- functions with input and output values
- inline assembly because it _IS_ assembly


## What can rpn68k do for YOU?

If you enjoy assembly programming on oldskool platforms like Commodore Amiga, Atari ST or NeoGeo this might make your life easier and more ambitious projects possible.

Using rpn68k improves
- development speed
- readability
- code reusability
- the need to come up with label names for branches, good riddance!


## What does rpn68k look like?

Generating a 12-bit fixed point square root table (pseudocode in comments)
```
  include "rpn68k.i"

gen_sqrt:
  lea sqrt_table(pc),a0           ; int16* out = &sqrt_table

  ld #0,value                     ; int16 value = 0
  ld #0,sqroot                    ; int16 sqroot = 0

  loop_in_const $4000             ; for (int i = 0; i < 0x4000; i++) {
    while_in                      ;   while (square12f(sqroot) < value) {
      square12f sqroot+LOCAL(a7)  ;
      if_lo value+LOCAL(a7)       ;
        inc sqroot+LOCAL(a7)      ;     sqroot++
    while_out                     ;   }
    move.w sqroot+LOCAL(a7),(a0)+ ;   *out++ = sqroot
    add.w #2,value+LOCAL(a7)      ;   value += 2
  loop_out                        ; }

  RESET_STACK                     ; remove local variables 'value' and 'sqroot' from stack

  rts

sqrt_table:
  ds.w	$4000
```

This is the disassembled code
```
gen_sqrt:
    lea    sqrt_table(pc),a0
    move.w #$0000,-(a7)
    move.w #$0000,-(a7)
    move.w #$3fff,d0
.1  move.w d0,-(a7)
.2  move.w ($0002,a7),d0
    muls.w d0,d0
    asr.l  #6,d0
    asr.l  #6,d0
    cmp.w  ($0004,a7),d0
    bge.w  .3
    addi.w #$0001,($0002,a7)
    bra.w  .2
.3  move.w ($0002,a7),(a0)+
    addi.w #$0002,($0004,a7)
    move.w (a7)+,d0
    dbf    d0,.1
    lea    ($0004,a7),a7
    rts

sqrt_table:
    ds.w  $4000
```


## How to get started with rpn68k

Currently:
- Build the [unit tests](https://github.com/el-visio/rpn68k/blob/master/unit_test.s?ts=2) then disassemble
- Check out [the UNFINISHED demo project in WIP branch](https://github.com/el-visio/rpn68k/blob/wip-donut-demo/donut_demo.s?ts=2) (Amiga OCS!)
- Educate yourself about [reverse polish notation](https://en.wikipedia.org/wiki/Reverse_Polish_notation). Note: While the classic RPN style can be used you'll get the maximum performance with a few rpn68k specific optimization tricks - THEN _you're playing with power!_ 

In _very near_ future: 
- Read the documentation 
- Check out the FINISHED demo project



### Happy hacking!
