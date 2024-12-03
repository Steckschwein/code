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

.include "asminc/common.inc"
.include "asminc/zeropage.inc"
.include "asminc/rom.inc"
.include "kernel/kernel_jumptable.inc"

.export _flash_get_device_id
.export _flash_get_device_name
.export _flash_sector_erase
.export _flash_write

.autoimport

.importzp ptr1, sreg

;extern unsigned int __fastcall__ flash_get_device_id();
.proc _flash_get_device_id
              jmp rom_read_device_id
.endproc

;extern unsigned char* __fastcall__ flash_get_device_name();
.proc _flash_get_device_name
              jmp rom_get_device_name
.endproc

; extern unsigned char __fastcall__ flash_sector_erase(long address);
.proc _flash_sector_erase
              lda sreg  ; low byte of highword denotes sector - 64k sectors
              cmp #$08
              bcc @erase
              lda #$ff
              bra @exit
@erase:       jsr rom_sector_erase
              bcc @exit ; wirh A=<error code>
              lda #0
@exit:        ldx #0
              rts

.endproc

; extern unsigned char __fastcall__ flash_write(flash_block *);
.proc _flash_write
              php
              ;sei
              sta ptr1
              stx ptr1+1
              ldy #0
:             lda (ptr1)
              sta rom_write_data+rom_write_t::address,y
              jsr inc_ptr
              iny
              cpy #5  ; 32 bit address and len
              bne :-
              lda ptr1
              sta rom_write_data+rom_write_t::p_data
              lda ptr1+1
              sta rom_write_data+rom_write_t::p_data+1

              lda #<rom_write_data
              ldy #>rom_write_data
              jsr rom_write
              bcc :+
              lda #0
:             ldx #0
              plp
              rts

inc_ptr:      inc ptr1
              bne :+
              inc ptr1+1
:             rts
.endproc

.bss
  rom_write_data:
    .tag rom_write_t