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

.code

ROM_BASE = $4000

rom_write_page:
        rts

; in:
;   .A    - byte to write
;   .X/.Y - rom address (low/high)
rom_write_byte_protected:
        sta __volatile_tmp

        lda ctrl_port+1     ; safe bank reg
        pha

        stx __volatile_ptr  ; rom address low byte
;        txa
 ;       jsr hexout_s

        ldx #$80            ; select first 16k ROM

        tya
        and #$7f            ; mask 32k ROM address
        bit #$40            ; low/high rom bank ?
        bvc :+
        inx                 ; inc to 2nd 16k ROM
:       stx ctrl_port+1     ; 16k ROM to slot 1

        and #$3f
        ora #>ROM_BASE      ; offset to bank 1 ($4000)
        ;jsr hexout_s
        sta __volatile_ptr+1

        txa
;        jsr hexout_s

        jsr rom_sdp_enable

        lda __volatile_tmp
        sta (__volatile_ptr)
:       cmp (__volatile_ptr)
        bne :-
;        and #1<<6 ; toggle bit?
 ;       eor #1<<6
  ;      bne :-
        pla
        sta ctrl_port+1

 @exit: rts



; disable - $aa, $55, $80, $aa, $55, $20
rom_sdp_disable:
        lda #$00
        jsr _sdp_sequence
        lda #$a0
        bra _sdp_sequence
; enable  - $aa, $55, $a0
rom_sdp_enable:
        lda #$20
_sdp_sequence:
        ldx ctrl_port+1
        phx
        ldx #$81
        stx ctrl_port+1
        ldx #$aa
        stx ROM_BASE + ($5555 & $3fff)
        ldx #$80
        stx ctrl_port+1
        ldx #$55
        stx ROM_BASE + $2aaa
        ldx #$81
        stx ctrl_port+1
        eor #$80
        sta ROM_BASE + ($5555 & $3fff)
        plx
        stx ctrl_port+1
        rts
