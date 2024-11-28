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
.export rom_write_byte

.autoimport

.importzp __volatile_ptr, __volatile_tmp

.segment "ZEROPAGE_LIB": zeropage

.code

ROM_BASE = slot3 ; 16k slot to access the ROM

ROM_CMD_ADDRESS_0 = $5555
ROM_CMD_ADDRESS_1 = $2aaa

slot_ctrl=ctrl_port | (ROM_BASE>>14)


; @out: A - manufacturer ID
; @out: X - device ID
rom_read_device_id:
              ldx #0
              jmp rom_access_with_fn

;@name: rom_write - write data
;@in: A/Y pointer to rom write struct (low/high)
;@out: C=1 on success, C=0 on error
.export rom_write
rom_write:
              sta __volatile_ptr
              sty __volatile_ptr+1

              ldx #2
              jmp rom_access_with_fn


; @in: A - sector [0..7]
.export rom_sector_erase
rom_sector_erase:
              and #$07
              ldx #4
              jmp rom_access_with_fn


;@in: A/Y pointer to rom write struct (low/high)
;@in: X offset to rom access function - @see rom_fn_table
rom_access_with_fn:
              php
              sei

              ldy slot_ctrl ; save slot_ctrl
              phy

              jsr @rom_access_fn

              ply
              sty slot_ctrl
              plp
              rts
@rom_access_fn:
              jmp (rom_fn_table,x)

rom_fn_table:
              .word rom_fn_read_device_id
              .word rom_fn_write
              .word rom_fn_sector_erase

rom_fn_sector_erase:
              lda #$80
              jsr _cmd_sequence ; send $aa, $55, $80

              jsr _cmd_sequence_aa_55 ; send $aa, $55
              lda #SLOT_ROM | ($60000>>14)
              sta slot_ctrl
              lda #$30  ; sector erase
              sta ROM_BASE + ($60000 & $3fff)

              jmp rom_wait_toggle


rom_fn_read_device_id:
              lda #$90  ; send device id command
              jsr _cmd_sequence

              lda #SLOT_ROM | ($0000>>14)
              sta slot_ctrl

              lda ROM_BASE+0  ; read manufacturer
              pha
              ldx ROM_BASE+1  ; read chip id

              lda #$f0  ; reset command
              jsr _cmd_sequence

              pla
              rts

rom_fn_write:
              ldx #0
              ldy #$ff
:             jsr _cmd_sequence_program
              lda #$98
              sta slot_ctrl
              txa
              sta ROM_BASE,x
              jsr rom_wait_toggle
              dey
              inx
              bne :-
              rts

rom_wait_toggle:
              ldy #0
@wait:        iny
              beq @reset
              lda ROM_BASE        ; read
              eor ROM_BASE        ; eor
              and #1<<6           ; mask toggle bit
              beq @exit           ; toggle bit stable, exit

              lda ROM_BASE
              and #1<<5           ; I/O5 = 1 (timeout) ?
              beq @wait

              lda ROM_BASE
              cmp ROM_BASE        ; still toggling
              beq @exit

@reset:       lda #$f0            ; reset command
              jmp _cmd_sequence

@exit:        rts


.export rom_get_device_name
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

; in:
;   A   - byte to write
;   X/Y - rom address (low/high)
; out:
;   C=1 on success, C=0 on error
rom_write_byte:
              stx __volatile_ptr  ; rom address low byte

              ldx slot_ctrl      ; safe bank reg
              phx

              pha

              ldx #$80            ; select first 16k of ROM

              tya
              and #$7f            ; mask 32k ROM address
              bit #$40            ; low/high rom bank ?
              bvc :+
              inx                 ; inc to 2nd 16k ROM
:             stx slot_ctrl      ; 16k ROM to slot 1

              and #$3f            ; map to slot1 ($4000-7fff)
              ora #>ROM_BASE      ; offset to bank 1 ($4000)
              sta __volatile_ptr+1

              jsr _cmd_sequence_program

              pla                   ; data byte
              sta (__volatile_ptr)  ; write

              jsr rom_wait_toggle

@test:        lda (__volatile_ptr)  ; due to bit 6 toggle, we have to compare again
              cmp (__volatile_ptr)  ; to verify that the expected value is really written, C is set accordingly

              ply
              sty slot_ctrl
              rts

; send write command sequence $aa, $55, $a0
_cmd_sequence_program:
              lda #$a0
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
