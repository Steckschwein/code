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

; Steckschwein i/o related stuff

.include "pacman.sts.inc"

.export io_init
.export io_detect_joystick
.export io_exit
.export io_getkey
.export io_player_direction
.export io_isr
.export io_irq_on

.export io_port_vdp_reg
.export io_port_vdp_ram
.export io_port_vdp_pal

.export io_port_snd_reg
.export io_port_snd_dat


.autoimport

appstart $1000

.code

io_port_vdp_reg=a_vreg
io_port_vdp_pal=a_vregpal
io_port_vdp_ram=a_vram

io_port_snd_reg=opl_stat
io_port_snd_dat=opl_data

io_init:      jsr joystick_on
              lda #JOY_PORT1
              sta joystick_port
              clc
              rts

io_isr:       jmp fetchkey

io_irq_on:    setIRQ IRQ_VEC
              rts

io_detect_joystick:
              jsr joystick_detect
              bcs @exit
              sta joystick_port
@exit:        rts

io_getkey=getkey

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
@joystick:    lda joystick_port
              jsr joystick_read
              and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
              cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
              beq @exit ; nothing pressed
              sec
              bit #JOY_RIGHT
              beq @r
              bit #JOY_LEFT
              beq @l
              bit #JOY_DOWN
              beq @d
              bit #JOY_UP
              beq @u
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

io_exit:      sei
              jsr joystick_off
              restoreIRQ IRQ_VEC
              cli
              jmp (retvec)

.bss
              joystick_port:  .res 1
              save_irq:       .res 2
