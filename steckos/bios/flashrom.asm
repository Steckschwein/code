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
.include "keyboard.inc"
.include "zeropage.inc"
.include "appstart.inc"
.include "xmodem.inc"
.include "vdp.inc"
.include "rom.inc"

.autoimport

.export char_out=vdp_charout

.export crc16_hi = BUFFER_0
.export crc16_lo = BUFFER_1
.export crc16_init = crc16_table_init
.export xmodem_rcvbuffer = xmodem_block

.exportzp ptr1,ptr2

.zeropage
ptr1:   .res 2
ptr2:   .res 2

rom_address = $10000

appstart $1000
              jsr primm
              .byte "Flash image to ROM address $10000", CODE_LF,0

              jsr primm
              .asciiz "Sector erase... "
              lda #rom_address>>$10  ; 1 - $10000
              jsr rom_sector_erase
              bcc halt
              jsr printok

              jsr flash_sector
              bcc halt
              jsr printok

              jsr primm
              .asciiz "Going to reset... "

              ldx #3
:             sys_delay_ms 1000
              dex
              bne :-

              ; erase VRAM to make sure ROM image will init VRAM correctly
              vdp_vram_w 0
              lda #0
              ldx #0 ; $200 pages to clear (128k)
              jsr vdp_fill
              jsr vdp_fill

              lda #(SLOT_ROM | rom_address>>14)
              sta slot2_ctrl
              inc a
              sta slot3_ctrl

              jmp (SYS_VECTOR_RESET)  ; reset

halt:
              pha
              jsr primm
              .byte "FAIL ",0
              pla
              jsr hexout_s
:             bra :-

printok:      jsr primm
              .byte "OK",CODE_LF,0
              rts


flash_sector:
              jsr primm
              .asciiz "Flash image "

              sei
              lda #<handle_block
              ldx #>handle_block
              jsr xmodem_upload_callback
              pha
              rol
              eor #01
              lsr
              pla
              rts

handle_block: ldy crs_x ; save crs x
              phy
              pha

              lda #<rom_io_data
              ldy #>rom_io_data
              jsr rom_write
              bcs @ok
              bra halt
@ok:
              clc
              lda rom_io_data+rom_access_t::address+0
              adc #$80
              sta rom_io_data+rom_access_t::address+0
              lda rom_io_data+rom_access_t::address+1
              adc #0
              sta rom_io_data+rom_access_t::address+1
              lda rom_io_data+rom_access_t::address+2
              adc #0
              sta rom_io_data+rom_access_t::address+2

              pla
              jsr hexout_s
              inc crs_x
              lda rom_io_data+rom_access_t::address+2
              jsr hexout_s
              lda rom_io_data+rom_access_t::address+1
              jsr hexout
              lda rom_io_data+rom_access_t::address+0
              jsr hexout
              pla
              sta crs_x
              rts

.data
  rom_io_data:
    .dword rom_address
    .byte $80
    .addr xmodem_block+xmodem_block_t::data

.bss
  xmodem_block:
    .tag xmodem_block_t