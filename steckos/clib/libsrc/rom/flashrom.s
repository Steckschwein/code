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
.include "kernel/kernel_jumptable.inc"

.export _flash_get_device_id
.export _flash_get_device_name
.export _flash_sector_erase
.export _flash_write

.autoimport

.importzp ptr1

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
              bra :+
@erase:       jsr rom_sector_erase
              lda #0
:             tax
              rts
.endproc

; extern unsigned char __fastcall__ flash_write(flash_block *);
.proc _flash_write
              sta __volatile_ptr
              stx __volatile_ptr+1
              ;jsr rom_write
              lda #0
              tax
              rts
.endproc
