.include "asmunit.inc" 	; test api
.include "debug.inc"

.include "vdp.inc"
.include "gfx.inc"

.import gfx_line
.importzp __volatile_tmp

debug_enabled=1
.code

.macro createtest name, input, linectrl

      test name

      lda #<input
      ldy #>input
      resetCycles
      jsr gfx_line
      assertCycles 360

      assertMemory __volatile_tmp, 1
         .byte linectrl

      assertMemory input, 8
.endmacro

.export vdp_wait_cmd=mock_wait_cmd

; -------------------

      ; y longest, draw x left => right (1), y top => down (0)
      createtest "line 0", testline_0, v_reg45_dix | v_reg45_maj
         .word 80
         .byte 4
         .byte $ff
         .byte $0
         .word 16
         .byte 156

      createtest "line 1", testline_1, v_reg45_maj
         .word 64
         .byte 4
         .byte $ff
         .byte $0
         .word 32
         .byte 156 ; y longest, draw x left => right, y top => down

      createtest "line 2", testline_2, v_reg45_dix
         .word 320
         .byte 4
         .byte $ff
         .byte $0
         .word 220
         .byte 156 ;

      createtest "line 3", testline_3, 0
         .word 20
         .byte 0
         .byte $ff
         .byte $0
         .word 480
         .byte 160; x longest, draw x left => right, y top => down

      createtest "line 4", testline_4, v_reg45_diy
         .word 0
         .byte 160
         .byte $ff
         .byte $0
         .word 500
         .byte 0; x longest, draw x left => right (0), y bottom up (8)

      createtest "line 5", testline_5, 0
         .word 0
         .byte 0
         .byte $ff
         .byte $0
         .word 255
         .byte 191; x longest (0), draw x left => right (0), y top down (0)

      createtest "line 6", testline_6, v_reg45_diy
         .word 256
         .byte 129
         .byte $ff
         .byte $0
         .word 255
         .byte 128; x longest (0), draw y bottom up (1)

      brk

mock_wait_cmd:
   rts ; dummy wait cmd

.data
testline_0:
   .word 80
   .byte 4
   .byte $ff ; color
   .byte 0;operator
   .word 64       ;x2/y2
   .byte 160
testline_1:
   .word 64
   .byte 4
   .byte $ff
   .byte 0;operator
   .word 96       ;x2/y2
   .byte 160
testline_2:
   .word 320
   .byte 4
   .byte $ff
   .byte 0;operator
   .word 100
   .byte 160
testline_3:
   .word 20
   .byte 0
   .byte $ff
   .byte 0;operator
   .word 500
   .byte 160
testline_4:
   .word 0
   .byte 160
   .byte $ff
   .byte 0;operator
   .word 500         ;x2/y2
   .byte 160
testline_5:
	.word 0
   .byte 0
   .byte $ff
   .byte 0;operator
   .word 255         ;x2/y2
   .byte 191
testline_6:
	.word 256
   .byte 129
   .byte $ff
   .byte 0;operator
   .word 511
   .byte 1
