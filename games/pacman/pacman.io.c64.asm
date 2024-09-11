;i/o
.include "pacman.c64.inc"

.export io_init
.export io_detect_joystick
.export io_player_direction
.export io_getkey
.export io_isr
.export io_irq_on
.export io_exit

.code


; C=0 if ok, C=1 if error or not NTSC
io_init:
:             lda VIC_HLINE
:             cmp VIC_HLINE
              beq :-
              bmi :--
              cmp #$20
              bcc @init

              ldy #0
:             lda @not_ntsc,y
              beq @exit
              jsr CHROUT
              iny
              bne :-
@not_ntsc:    .asciiz "ntsc not detected, pacman is designed to work correctly on ntsc only!"

@init:        lda #$ff  ; output port a
              sta CIA1_DDRA
              lda #0    ; input port b
              sta CIA1_DDRB
@exit:        rts

io_irq_on:
              lda #LORAM | IOEN ;disable kernel rom to setup irq vector
              sta $01           ;PLA

              lda #%01111111  ; disable interrupts from CIA1
              sta CIA1_ICR

              and VIC_CTRL1  ; clear bit 7 (high byte raster line)
              sta VIC_CTRL1  ; $d011

              lda #HLine_Border
              sta VIC_HLINE  ; Raster-IRQ at bottom border ($d012)

              lda #%00000001
              sta VIC_IMR      ; enable raster irq

              lda CIA1_ICR
              lda CIA2_ICR

              setIRQ IRQ_VEC
              rts
io_exit:
              restoreIRQ IRQ_VEC
              rts

io_isr:
        inc VIC_BORDERCOLOR
        rts

.export io_highscore_load
io_highscore_load:
            rts

; A=key and C=1 key input given, C=0 no input
;  out:
;    one of ACT_LEFT, ACT_RIGHT,... with C=1
io_player_direction:
;            bcc @joystick
            lda CIA1_PRA
        ;    and #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
        ;    cmp #(JOY_RIGHT | JOY_LEFT | JOY_DOWN | JOY_UP)
        ;    beq @rts; nothing pressed
            sec
            bit Joy_Right
            beq @r
            bit Joy_Left
            beq @l
            bit Joy_Down
            beq @d
            bit Joy_Up
            beq @u
@rts:
              clc
              rts
@u:           lda #ACT_UP
              rts
@r:   lda #ACT_RIGHT
      rts
@l:   lda #ACT_LEFT
      rts
@d:   lda #ACT_DOWN
      rts

io_getkey:
            ;map c64 keys to ascii
            lda #0
            rts

io_detect_joystick:
            lda #2
            rts

io_joystick_read:
            php
            sei
            lda #224
            sta CIA1_DDRA
            lda CIA1_PRA
            plp
            rts

.data
JOY_RIGHT   =1<<3
JOY_LEFT    =1<<2
JOY_DOWN    =1<<1
JOY_UP      =1<<0

Joy_Right:  .byte JOY_RIGHT
Joy_Left:   .byte JOY_LEFT
Joy_Down:   .byte JOY_DOWN
Joy_Up:     .byte JOY_UP

.bss
  save_irq: .res 2