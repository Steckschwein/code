; based on "NES and SNES Controllers on a 6502 (like the C64) by Michael Steil
; https://www.pagetable.com/?p=1365

.include "via.inc"
.include "snes.inc"

.export query_controllers
.importzp controller1, controller2

query_controllers:
    lda #$ff-bit_data1-bit_data2
    sta nes_ddr
    lda #$00
    sta nes_data

    ; pulse latch
    lda #bit_latch
    sta nes_data
    ;lda #0
    ;sta nes_data
    stz nes_data

    ; read 3x 8 bits
    ldx #0
l2: ldy #8
l1: lda nes_data
    cmp #bit_data2
    rol controller2,x
    and #bit_data1
    cmp #bit_data1
    rol controller1,x
    ;lda #bit_clk
    ;sta nes_data
    inc nes_data
    ;lda #0
    ;sta nes_data
    stz nes_data

    dey
    bne l1
    inx
    cpx #3
    bne l2
    rts

