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

.importzp __volatile_ptr, __volatile_tmp
.autoimport

.export rom_sdp_disable
.export rom_write_byte

.code

ROM_BASE = slot1 ; we use just one 16k slot to write to rom

ROM_CMD_ADDRESS_0 = $5555
ROM_CMD_ADDRESS_1 = $2aaa



; @out: A - manufacturer ID
;       Y - device ID
rom_read_device_id:
        ldx #0
        jmp rom_access_with_fn

;@name: rom_write_page - write
;@in: A/Y, pointer to rom write struct (low/high)
;@out: C=0 on success, C=1 on error
.export rom_write
rom_write:
        sta __volatile_ptr
        sty __volatile_ptr+1

        ldy #rom_write_t::target+1
        lda (__volatile_ptr),y

        ldx #2
        jsr rom_access_with_fn
        clc
        rts


;@in: A/Y pointer to rom access function
rom_access_with_fn:
        php
        sei

        lda slot1_ctrl ; save slot1_ctrl
        pha

        jsr rom_access_fn

        plx
        stx slot1_ctrl
        plp
        rts

rom_access_fn:
        jmp (rom_fn_table,x)

rom_fn_table:
        .word rom_fn_read_device_id
        .word rom_fn_write

rom_fn_read_device_id:
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
        rts

rom_fn_write:
        jsr rom_write_begin
        lda #$9f
        sta slot1_ctrl
        ldx #$a9
:       txa
        sta ROM_BASE,x
        inx
        ;bne :-
        ; fall through, check toggle bit

rom_wait_toggle:
        ldy #0
@wait:  iny
        beq @exit
        lda ROM_BASE        ; read
        eor ROM_BASE        ; eor
        and #1<<6           ; mask toggle bit
        bne @wait           ; bit 6 is set, rom is toggling still
@exit:  rts

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
        bra @find

@print: lda rom_labels+0,x
        pha
        lda rom_labels+1,x
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


; in:
;   .A    - byte to write
;   .X/.Y - rom address (low/high)
; out:
;   C=1 on success, C=0 on error
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

        jsr rom_write_begin

        pla                   ; data byte
        sta (__volatile_ptr)  ; write

        jsr rom_wait_toggle

@test:  lda (__volatile_ptr)  ; due to bit 6 toggle, we have to compare again
        cmp (__volatile_ptr)  ; to verify that the expected value is really written, C is set accordingly

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
        rts

; send write command sequence $aa, $55, $a0
rom_write_begin:
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
