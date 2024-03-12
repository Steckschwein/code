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
; use imagemagick $ convert <image> -geometry 256 -colors 256 <image.ppm>
;
.include "fat32.inc"
.include "steckos.inc"

.autoimport

.export char_out=krn_chrout
.export fopen=krn_fopen
.export fread_byte=krn_fread_byte
.export fclose=krn_close

.zeropage
  p_option: .res 2

appstart $1000
.code

    stz _slide_delay

    jsr parseOpt
    bne @l_select_opt
    lda (paramptr)      ; param given at all?
    bne @l_open_file    ; yes, try open as file
    bra @l_open_dir     ; open dir otherwise

@l_select_opt:
    SetVector _opt_slide, p_option
    jsr is_option
    bcc @l_open_file
    lda #$88
    sta _slide_delay

@l_open_dir:
    lda #<_cwd
    ldy #>_cwd
    ldx #(_cwd_end-_cwd)
    jsr krn_getcwd
    bcs exit

    lda #<_cwd
    ldx #>_cwd
    jsr krn_opendir
    bcs io_error
    stx _fd_dir

    jsr gfxui_on
@l_next_ppm:
    jsr gfxui_blank
    jsr next_ppm_file
    bcs @l_close_dir

    lda #<_ppmfile
    ldx #>_ppmfile
    ldy #1
    jsr ppm_load_image
    bcs ppm_error

    jsr slide_show
    bcc @l_next_ppm

@l_close_dir:
    ldx _fd_dir
    jsr krn_close
    bra exit

@l_open_file:
    jsr gfxui_on
    lda paramptr
    ldx paramptr+1
    ldy #1
    jsr ppm_load_image
    bcs ppm_error

    keyin

exit:
    jsr gfxui_off
    jmp (retvec)

io_error:
    pha
    jsr primm
    .byte CODE_LF, "i/o error: ", 0
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

slide_show:
              lda _slide_delay
              bpl @l_kbdhit

              and #$7f
              tay
@l_wait:      sys_delay_ms 1000
              phy
              jsr krn_getkey
              ply
              bcc :+
              cmp #KEY_ESCAPE
              beq @l_exit
:             dey
              bne @l_wait
@l_next:      clc
              rts

@l_kbdhit:    keyin
@l_kbd_esc:   cmp #KEY_ESCAPE
              bne @l_next
@l_exit:      rts

parseOpt:
              ldy #0
              ldx #0
:             lda (paramptr),y
              beq @l_exit
              cmp #' '
              bne @l_opt
              cpx #0
              beq @l_next
              bra @l_exit
@l_opt:       cpx #0
              bne @l_capture
              cmp #'-'
              bne @l_exit
@l_capture:   sta _option,x
              inx
@l_next:      iny
              cpx #_option_end-_option
              bne :-
@l_exit:      stz _option,x
              cpx #0
              rts

is_option:
              ldy #0
:             lda _option,y
              beq @l_exit
              cmp (p_option),y
              bne @l_noop
              iny
              cpy #(_option_end-_option)
              bne :-
@l_noop:      clc
              rts
@l_exit:      cpy #2
              rts



next_ppm_file:
@l_next:      lda #<_direntry
              ldy #>_direntry
              ldx _fd_dir
              jsr krn_readdir
              bcs @l_exit
              ldy #F32DirEntry::Ext
              ldx #0
:             lda _direntry,y
              cmp _ppmext,x
              bne @l_next
              iny
              inx
              cpx #(_ppmext_end-_ppmext)
              bne :-

              ldy #0
              ldx #0
:             lda _direntry,y
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
              clc
@l_exit:      rts

gfxui_on:
    jsr krn_textui_disable      ;disable textui

    jsr vdp_mode7_on         ;enable gfx7 mode
    vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px
    ; vdp_sreg v_reg25_wait | v_reg25_yjk , v_reg25 ; mask left border, activate 2 pages (4x16k mode 3 screens)

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
  _ppmext:  .byte "PPM"
  _ppmext_end:
  _opt_slide: .asciiz "-slide"

.bss
  _slide_delay: .res 1
  _fd_dir:   .res 1
  _direntry: .res DIR_Entry_Size
  _cwd:     .res 64
  _cwd_end:
  _ppmfile: .res 12
  _option:  .res 16
  _option_end: