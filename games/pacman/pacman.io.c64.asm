;i/o
    .include "pacman.c64.inc"

    .export io_init
    .export io_detect_joystick
    .export io_joystick_read
    .export io_player_direction
    .export io_getkey
    .export io_isr
    .export io_irq_on
    .export io_exit

.code

io_init:
        lda #$ff  ; output port a
        sta CIA1_DDRA
        lda #0    ; input port b
        sta CIA1_DDRB
        rts

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
    rts

io_exit:
    rts

io_isr:
    rts

.export io_highscore_load
io_highscore_load:
            rts

;  out:
;    one of ACT_LEFT, ACT_RIGHT,... with C=1
io_player_direction:
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
