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

.include "system.inc"

.importzp __volatile_ptr, __volatile_tmp
.autoimport

.export rom_sdp_disable
.export rom_sdp_enable
.export rom_write_byte_protected
.export rom_write_byte

.code

ROM_BASE = $4000 ; we use just one 16k slot to write to rom

rom_write_page:
        rts

; in:
;   .A    - byte to write
;   .X/.Y - rom address (low/high)
; out:
;   C=0 on success, C=1 on error
rom_write_byte_protected:
rom_write_byte:
        stx __volatile_ptr  ; rom address low byte

        ldx bank1           ; safe bank reg
        phx

        pha;        sta __volatile_tmp

        ldx #$80            ; select first 16k ROM

        tya
        and #$7f            ; mask 32k ROM address
        bit #$40            ; low/high rom bank ?
        bvc :+
        inx                 ; inc to 2nd 16k ROM
:       stx bank1           ; 16k ROM to slot 1

        and #$3f            ; map to bank1 address $4000-7fff
        ora #>ROM_BASE      ; offset to bank 1 ($4000)
        sta __volatile_ptr+1

;        jsr rom_sdp_enable
        pla ; lda __volatile_tmp

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
        stx bank1
        rts


; disable software data protection (sdp)
;
; disable - $aa, $55, $80, $aa, $55, $20
rom_sdp_disable:
        lda #$00
        jsr _sdp_sequence
        lda #$a0
        jsr _sdp_sequence
        sys_delay_ms 50 ; write cycle delay
        rts

; enable software data protection (sdp)
; enable sequence- $aa, $55, $a0
rom_sdp_enable:
        lda #$20
        jsr _sdp_sequence
        sys_delay_ms 50   ; write cycle delay
        rts

_sdp_sequence:
        ldx bank1 ; save bank1
        phx
        ldx #$81
        stx bank1
        ldx #$aa
        stx ROM_BASE + ($5555 & $3fff)
        ldx #$80
        stx bank1
        ldx #$55
        stx ROM_BASE + $2aaa
        ldx #$81
        stx bank1
        eor #$80
        sta ROM_BASE + ($5555 & $3fff)
        plx
        stx bank1
        rts
