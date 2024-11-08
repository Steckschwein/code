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
; SOFTWARE.

.include "common.inc"
.include "system.inc"

.importzp __volatile_ptr, __volatile_tmp
.autoimport

.export rom_sdp_disable
.export rom_sdp_enable
.export rom_write_byte

.code

ROM_BASE = slot1 ; we use just one 16k slot to write to rom

ROM_CMD_ADDRESS_0 = $5555
ROM_CMD_ADDRESS_1 = $2aaa

; @out: A - manufacturer ID
;       Y - device ID
rom_read_device_id:
        php
        sei
        ldx slot1_ctrl ; save slot1_ctrl
        phx

        lda #$90  ; get id command
        jsr _sdp_sequence

        lda #SLOT_ROM | ($0000>>14)
        sta slot1_ctrl

        lda ROM_BASE+0  ; mfr
        pha
        ldy ROM_BASE+1  ; id

        lda #$f0  ; reset command
        jsr _sdp_sequence

        pla

        plx
        stx slot1_ctrl
        plp
        rts

.export rom_print_device_id
rom_print_device_id:
        jsr rom_read_device_id
        sta __volatile_tmp
        ldx #0
@find:  lda rom_ids+1,x
        beq @print
        cmp __volatile_tmp
        bne @next
        tya
        cmp rom_ids+0,x
        beq @print
@next:  inx
        inx
        inx
        inx
        bra @find

@print: lda rom_ids+2,x
        pha
        lda rom_ids+3,x
        tax
        pla
        jsr strout
        lda #' '
        jsr char_out
        lda #'('
        jsr char_out
        lda __volatile_tmp
        jsr hexout_s
        lda #'/'
        jsr char_out
        tya
        jsr hexout_s
        lda #')'
        jmp char_out

rom_write_page:
        rts

; in:
;   .A    - byte to write
;   .X/.Y - rom address (low/high)
; out:
;   C=0 on success, C=1 on error
rom_write_byte:
        stx __volatile_ptr  ; rom address low byte

        ldx slot1_ctrl      ; safe bank reg
        phx

        pha

        ldx #$80            ; select first 16k of ROM

        tya
        and #$7f            ; mask 32k ROM address
        bit #$40            ; low/high rom bank ?
        bvc :+
        inx                 ; inc to 2nd 16k ROM
:       stx slot1_ctrl      ; 16k ROM to slot 1

        and #$3f            ; map to slot1 ($4000-7fff)
        ora #>ROM_BASE      ; offset to bank 1 ($4000)
        sta __volatile_ptr+1

        jsr rom_sdp_enable

        pla                   ; data byte

        ldy #0                ; timeout
        sta (__volatile_ptr)  ; write

@wait_toggle:
        lda (__volatile_ptr)  ; read
        eor #1<<6             ; toggle bit
        cmp (__volatile_ptr)  ; same?
        beq @wait_toggle      ; then bit 6 is toggling still

@test:  cmp (__volatile_ptr)  ; due to bit 6 toggle, we have to compare twice
        bne @wait_toggle      ; to verify that the expected value is really written
        cmp (__volatile_ptr)  ;
        bne @wait_toggle
        clc
;        and #1<<6 ; toggle bit?
 ;       eor #1<<6
  ;      bne :-
@exit:
        lda (__volatile_ptr)
        plx
        stx slot1_ctrl
        rts


; disable software data protection (sdp)
;
; disable sequence - $aa, $55, $80, $aa, $55, $20
rom_sdp_disable:
        lda #$80
        jsr _sdp_sequence
        lda #$20
        jsr _sdp_sequence
        sys_delay_ms 50 ; write cycle delay
        rts

; enable software data protection (sdp)
; enable sequence - $aa, $55, $a0
rom_sdp_enable:
        lda #$a0

; sends $aa, $55, $<A>
_sdp_sequence:
        ldx #SLOT_ROM | (ROM_CMD_ADDRESS_0>>14)
        stx slot1_ctrl
        ldx #$aa
        stx ROM_BASE + (ROM_CMD_ADDRESS_0 & $3fff)

        ldx #SLOT_ROM | (ROM_CMD_ADDRESS_1>>14)
        stx slot1_ctrl
        ldx #$55
        stx ROM_BASE + (ROM_CMD_ADDRESS_1 & $3fff)

        ldx #SLOT_ROM | (ROM_CMD_ADDRESS_0>>14)
        stx slot1_ctrl
        sta ROM_BASE + (ROM_CMD_ADDRESS_0 & $3fff)  ; cmd byte
        rts

.data
  rom_ids:
    .word $bf5d ; mfr id, device id
    .word rom_label_0
    .word $52a4
    .word rom_label_1
    .word $3786
    .word rom_label_2
    .byte 0,0
    .word rom_label_unknown
  rom_label_0:
    .asciiz "Greenliant - GLS29EE512"
  rom_label_1:
    .asciiz "Alliance - AS29F040"
  rom_label_2:
    .asciiz "AMIC - A29040B"
  rom_label_unknown:
    .asciiz "unknown"

.bss
