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
.include "rom.inc"

.export rom_read_device_id
.export rom_get_device_name
.export rom_write
.export rom_sector_erase

.autoimport

.importzp __volatile_ptr, __volatile_tmp

.segment "ZEROPAGE_LIB": zeropage

  p_data: .res 2  ; pointer to data
  p_rom:  .res 2  ; rom address in 16k slot

.code

ROM_BASE = slot3 ; 16k slot to access the ROM

ROM_CMD_ADDRESS_0 = $5555
ROM_CMD_ADDRESS_1 = $2aaa

ROM_CMD_CHIP_ERASE    = $10
ROM_CMD_SECTOR_ERASE  = $30
ROM_CMD_PREPARE       = $80
ROM_CMD_PROGRAM       = $a0
ROM_CMD_DEVICEID      = $90
ROM_CMD_RESET         = $f0



slot_ctrl=ctrl_port | (ROM_BASE>>14)


; @out: A - manufacturer ID
; @out: X - device ID
rom_read_device_id:
              ldx #0
              jmp rom_access_with_fn

;@name: rom_write - write data
;@in: A/Y pointer to rom write struct (low/high)
;@out: C=1 on success, C=0 on error
rom_write:
              sta __volatile_ptr
              sty __volatile_ptr+1
              ldx #2
              jmp rom_access_with_fn


; @in: A - sector [0..7]
; @out: C=1 on success, C=0 on error
rom_sector_erase:
              and #$07
              ldx #4
              jmp rom_access_with_fn

; @out: C=1 on success, C=0 on error
; @out: A/X - pointer to null terminated string denoting the device label
rom_get_device_name:
              jsr rom_read_device_id
              sta __volatile_tmp
              ldy #0
@find:        lda rom_ids+1,y
              beq @exit
              cmp __volatile_tmp
              bne @next
              txa
              cmp rom_ids+0,y
              beq @exit
@next:        iny
              iny
              bra @find

@exit:        lda rom_labels+1,y
              pha
              lda rom_labels+0,y
              plx
              rts


;@in: X offset to rom access function - @see rom_fn_table
rom_access_with_fn:
              php
              sei

              ldy slot_ctrl ; save slot_ctrl
              phy

              jsr @call_rom_fn

              ply
              sty slot_ctrl
              plp
              cmp #0  ; set flags accordingly
              beq @exit
              clc
@exit:        rts
@call_rom_fn: jmp (rom_fn_table,x)

rom_fn_table:
              .word rom_fn_read_device_id
              .word rom_fn_write
              .word rom_fn_sector_erase

rom_fn_sector_erase:
              pha

              lda #ROM_CMD_PREPARE
              jsr _cmd_sequence ; send $aa, $55, $80

              jsr _cmd_sequence_aa_55 ; send $aa, $55

              pla ; get sector (0..7)
              asl ; x4 (16k slots)
              asl
              ora #SLOT_ROM
              sta slot_ctrl   ; select rom page
              lda #ROM_CMD_SECTOR_ERASE        ; sector erase command
              sta ROM_BASE

              jsr rom_wait_toggle
              bcc @exit
              ldy #0
@wait_data:   lda ROM_BASE,y
              cmp #$ff        ; data erased?
              bne @wait_data
              iny
              bne @wait_data
              tya
@exit:        rts


rom_fn_read_device_id:
              lda #ROM_CMD_DEVICEID  ; send device id command
              jsr _cmd_sequence

              lda #SLOT_ROM | ($0000>>14)
              sta slot_ctrl

              lda ROM_BASE+0  ; read manufacturer
              pha
              ldx ROM_BASE+1  ; read chip id

              lda #ROM_CMD_RESET  ; reset command
              jsr _cmd_sequence

              pla
              rts

rom_fn_write:
              ldy #rom_write_t::len
              lda (__volatile_ptr),y
              beq @exit ; 0 bytes to write?
              tax

              iny                         ; init data pointer (y=rom_write_t::p_data)
              lda (__volatile_ptr),y
              sta p_data
              iny
              lda (__volatile_ptr),y
              sta p_data+1

              ldy #0
@write:       phy
              ldy #rom_write_t::address   ; set rom pointer upon address
              lda (__volatile_ptr),y      ; bit 7-0 of address
              sta p_rom+0
              iny                         ; bit 15-8 of address
              lda (__volatile_ptr),y
              sta __volatile_tmp
              and #$3f                    ; bit 13-8 only to fit 16k slot
              clc
              adc #>ROM_BASE              ; add to rom base
              sta p_rom+1
              iny                         ; bit 23-16 of rom address
              lda (__volatile_ptr),y      ; we ignore high byte of high word (bit 31-24) of address entirely
              and #$07                    ; and also mask bit 18-16 (512k)
              asl __volatile_tmp          ; x2 - calculate the rom bank to enable in 16k slot
              rol
              asl __volatile_tmp          ; x4
              rol
              ora #SLOT_ROM               ; rom slot
              tay

              jsr _cmd_sequence_program   ; send byte program sequence

              sty slot_ctrl               ; enable bank

              ply                         ; restore y
              lda (p_data),y              ; read data
              sta (p_rom),y               ; write to rom address

              jsr rom_wait_toggle
              bcc @exit                  ; C=0, toggle error
              iny
              dex
              bne @write
              txa ; X=0 => A, ok
@exit:        rts

rom_wait_toggle:
              lda ROM_BASE        ; read
              eor ROM_BASE        ; eor
              and #1<<6           ; mask toggle bit
              sec                 ; assume ok
              beq @exit           ; toggle bit stable, exit

              lda ROM_BASE
              ;bmi @wait          ; I/O7 erase in progress
              and #1<<5           ; I/O5 = 1 (timeout) ?
              beq rom_wait_toggle

              lda ROM_BASE
              eor ROM_BASE        ; still toggling ?
              and #1<<6
              sec
              beq @exit

@reset:       lda #$f0            ; reset command
              jsr _cmd_sequence
              lda #ROM_ERROR_TOGGLE_TIMEOUT ; C=0, A=<error>
              clc
@exit:        rts

; send write command sequence $aa, $55, $a0
_cmd_sequence_program:
              lda #ROM_CMD_PROGRAM
; sends $aa, $55, $<A>
_cmd_sequence:
              pha
              jsr _cmd_sequence_aa_55
              lda #SLOT_ROM | (ROM_CMD_ADDRESS_0>>14)
              sta slot_ctrl
              pla
              sta ROM_BASE + (ROM_CMD_ADDRESS_0 & $3fff)  ; cmd byte
              rts

_cmd_sequence_aa_55:
              lda #SLOT_ROM | (ROM_CMD_ADDRESS_0>>14)
              sta slot_ctrl
              lda #$aa
              sta ROM_BASE + (ROM_CMD_ADDRESS_0 & $3fff)

              lda #SLOT_ROM | (ROM_CMD_ADDRESS_1>>14)
              sta slot_ctrl
              lda #$55
              sta ROM_BASE + (ROM_CMD_ADDRESS_1 & $3fff)
              rts

.data
  rom_ids:
            .word $bf5d ; manufacturer id, device id
            .word $52a4
            .word $3786
            .word 0

  rom_labels:
            .word rom_label_0
            .word rom_label_1
            .word rom_label_2
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
