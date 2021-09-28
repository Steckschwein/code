.include "asmunit.inc" 	; test api
.include "debug.inc"

.include "vdp.inc"
.include "gfx.inc"

.import gfx_line
.importzp __volatile_tmp

debug_enabled=1
.code

.macro createtest name, input, linectrl
      .local name, input
      test name

      lda #<input
      ldy #>input
      resetCycles
      jsr gfx_line
      assertCycles 390

      assertMemory __volatile_tmp, 1
         .byte linectrl
      assertMemory input, 9
.endmacro

.export vdp_wait_cmd=mock_wait_cmd

; -------------------

      createtest "line 0", testline_0, v_reg45_dix | v_reg45_maj
         .word 80,4,16,156
         .byte $ff

      createtest "line 1", testline_1, v_reg45_maj
         .word 64,4,32,156 ; y longest, draw x left => right, y top => down
         .byte $ff

      createtest "line 2", testline_2, v_reg45_dix
         .word 320,4,220,156 ;
         .byte $ff

      createtest "line 3", testline_3, 0
         .word 20,0,480,160; x longest, draw x left => right, y top => down
         .byte $ff

      createtest "line 4", testline_4, v_reg45_diy
         .word 0,160,500,0; x longest, draw x left => right (0), y bottom up (8)
         .byte $ff

      createtest "line 5", testline_5, 0
         .word 0,0,255,191; x longest (0), draw x left => right (0), y top down (0)
         .byte $ff

      brk

mock_wait_cmd:
   rts ; dummy wait cmd

.data
testline_0:
   .word 80,4,64,160
   .byte $ff ; color
testline_1:
   .word 64,4,96,160
   .byte $ff
testline_2:
   .word 320,4,100,160
   .byte $ff
testline_3:
   .word 20,0,500,160
   .byte $ff
testline_4:
   .word 0,160,500,160
   .byte $ff
testline_5:
	.word 0,0,255,191
   .byte $ff
