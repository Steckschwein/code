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

;
; use imagemagick $convert <image> -geometry 256 -colors 256 <image.ppm>
;
.include "zeropage.inc"
.include "common.inc"
; .include "vdp.inc"
.include "fat32.inc"
.include "steckos.inc"

.autoimport

.export char_out=krn_chrout
.export fopen=krn_fopen
.export fread_byte=krn_fread_byte
.export fclose=krn_close

.zeropage
  ptr:  .res 2

appstart $1000
.code
    lda (paramptr)
    bne @l_openfile

    lda #<_cwd
    ldy #>_cwd
    ldx #(_cwd_end-_cwd)
    jsr krn_getcwd

    lda #<_cwd
    ldx #>_cwd
    jsr krn_opendir
    bcs io_error
    stx fd_dir

    jsr gfxui_on
@l_next_ppm:
    jsr gfxui_blank
    jsr next_ppm_file
    bcs @l_closedir

    lda #<_ppmfile
    ldx #>_ppmfile
    jsr ppm_load_image
    bcs ppm_error
    keyin
    bra @l_next_ppm

@l_closedir:
    ldx fd_dir
    jsr krn_close
    bra exit

@l_openfile:
    lda #<paramptr
    ldx #>paramptr
    jsr ppm_load_image
    bcs ppm_error

    keyin
exit:
    jsr gfxui_off
    jmp (retvec)

io_error:
    pha
    jsr primm
    .byte CODE_LF,"i/o error: ",0
    pla
    jsr hexout_s
    lda #CODE_LF
    jsr char_out
    bra exit

ppm_error:
    jsr gfxui_off
    cpx #0
    beq io_error
    jsr primm
    .byte CODE_LF,"Not a valid ppm file! Must be type P6 with 256x192px and 8bpp colors.",CODE_LF,0
    bra exit

next_ppm_file:
@l_next:
              lda #<direntry
              ldy #>direntry
              ldx fd_dir
              jsr krn_readdir
              bcs @l_exit
              ldy #F32DirEntry::Ext
              lda direntry,y
              cmp #'P'
              bne @l_next
              iny
              lda direntry,y
              cmp #'P'
              bne @l_next
              iny
              lda direntry,y
              cmp #'M'
              bne @l_next

              phx
              ldy #0
              ldx #0
:             lda direntry,y
              cmp #' '
              beq @skip
              sta _ppmfile,x
              inx
@skip:        iny
              cpy #.sizeof(F32DirEntry::Name)
              bne @l_ext
              lda #'.'
              sta _ppmfile,x
              inx
@l_ext:       cpy #.sizeof(F32DirEntry::Name)+.sizeof(F32DirEntry::Ext)
              bne :-
              stz _ppmfile,x
              plx
              clc
@l_exit:
              rts

gfxui_on:
    jsr krn_textui_disable      ;disable textui

    jsr vdp_mode7_on         ;enable gfx7 mode
    vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

gfxui_blank:
    ldy #0
    jmp vdp_mode7_blank

gfxui_off:
    php
    sei

    pha
    phx
    vdp_sreg v_reg9_nt, v_reg9  ; 192px
    jsr krn_textui_init
    plx
    pla

    plp
    rts

.data
  _ppmext:  .asciiz "ppm"

.bss
fd_dir:   .res 1
direntry: .res DIR_Entry_Size
_cwd:     .res 64
_cwd_end:
_ppmfile: .res 32