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

rom_get_product_id:
        lda #$90  ; get id command
        jsr _sdp_sequence
        sys_delay_us 10



        lda #$f0  ; reset command
        jsr _sdp_sequence
        sys_delay_us 10
        rts

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
        pla

        ldy #0  ; timeout
        sta (__volatile_ptr)  ; write
@wait:  sys_delay_ms 1
        dey
        bne @test
        sec                   ; C=1 error
        bra @exit
@test:  cmp (__volatile_ptr)  ; due to bit 6 toggle, we have to compare twice
        bne @wait             ; to verify that the expected value is really written
        cmp (__volatile_ptr)  ;
        bne @wait
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

_sdp_sequence:
        ldx slot1_ctrl ; save slot1_ctrl
        phx

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

        plx
        stx slot1_ctrl
        rts
.data
  manufacturer:
    .byte $bf
    .asciiz "Greenliant"
  deviceid:
    .byte $5d
    .asciiz "GLS29EE512"
