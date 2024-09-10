; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE

; JuniorComputer i/o related stuff

.include "pacman.jc.inc"

.export io_init
.export io_detect_joystick
.export io_joystick_read
.export io_exit
.export io_getkey
.export io_player_direction
.export io_isr
.export io_irq_on

.export io_port_vdp_reg:absolute
.export io_port_vdp_ram:absolute
.export io_port_vdp_pal:absolute

.autoimport

.code

io_port_vdp_reg=$0 ; TODO
io_port_vdp_pal=$0 ; TODO
io_port_vdp_ram=$0 ; TODO


io_init:      clc
              rts

io_isr:       rts   ; TODO fetch/get key from keyboard if necessary, oth

io_irq_on:    rts

io_detect_joystick:
@exit:        rts

io_joystick_read:
              rts

io_getkey:    lda #0  ; get key from keyboard
              rts

; A=key and C=1 key input given, C=0 no input
io_player_direction:
              bcc @joystick
              cmp #KEY_CRSR_RIGHT
              beq @r
              cmp #KEY_CRSR_LEFT
              beq @l
              cmp #KEY_CRSR_DOWN
              beq @d
              cmp #KEY_CRSR_UP
              bne @joystick
@u:           lda #ACT_UP
              rts
@r:           lda #ACT_RIGHT
              rts
@l:           lda #ACT_LEFT
              rts
@d:           lda #ACT_DOWN
              rts
@joystick:    ;jsr io_joystick_read
;              sec
;              bit #JOY_RIGHT
 ;             beq @r
  ;            bit #JOY_LEFT
   ;           beq @l
    ;          bit #JOY_DOWN
     ;         beq @d
      ;        bit #JOY_UP
       ;       beq @u
@exit:        clc
              rts

.export io_highscore_load
io_highscore_load:
              lda #0
              sta game_state+GameState::highscore
              sta game_state+GameState::highscore+1
              sta game_state+GameState::highscore+2
              sta game_state+GameState::highscore+3
              rts

io_exit:      rts ; quite, return to shell/prompt
