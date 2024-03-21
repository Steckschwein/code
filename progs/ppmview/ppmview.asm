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

appstart $1000
.code
              stz _settings
              stz _param_ix

              ldx #<(opt_hlp-options)
              jsr hasOption
              bcc @opt_rgb
              ldy #0
:             lda usage,y
              beq :+
              jsr char_out
              iny
              bne :-
:             jmp exit

@opt_rgb:     ldx #<(opt_rgb-options)
              jsr hasOption
              bcc @opt_sld
              lda #$80            ; set rgb
              sta _settings
              sty _param_ix       ; safe paramptr offset
@opt_sld:
              ldx #<(opt_sld-options)
              jsr hasOption
              bcc @opt_none
              lda #$48            ; set slide delay enable, 8 x 1000ms
              tsb _settings
              cpy _param_ix       ; safe paramptr offset
              bcc @opt_none
              sty _param_ix

@opt_none:    ldy _param_ix       ; options parsed?
              lda (paramptr),y    ; param given after options?
              bne @l_open_file    ; yes, try open as file
                                  ; open dir otherwise
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

              jsr @load_ppm
              bcs ppm_error

              jsr slide_show
              bcc @l_next_ppm
@l_close_dir:
              ldx _fd_dir
              jsr krn_close
              bra exit

@load_ppm:    lda _settings
              and #$80
              ora #$01 ; page 1
              tay
              lda #<_filename
              ldx #>_filename
              jmp ppm_load_image

@l_open_file: ldx #0
:             lda (paramptr),y
              sta _filename,x
              beq :+
              iny
              inx
              cpx #(_filename_end-_filename)
              bne :-

:             jsr gfxui_on
              jsr @load_ppm
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

ppm_error:    jsr gfxui_off
              cpx #0
              beq io_error
              jsr primm
              .byte CODE_LF,"Not a valid ppm file! Must be type P6 with 256x192px and 8bpp colors.",CODE_LF,0
              bra exit

slide_show:
              bit _settings
              bvc @l_kbdhit
              lda _settings
              and #$3f
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


; C=1 if requested option was found in paramptr, C=0 otherwise
hasOption:
              ldy #0
@next:        lda (paramptr),y
              beq @notfound
              cmp #'-'
              beq @opt_start
              iny
              bne @next
@notfound:    clc
@exit:        rts
@opt_start:   iny
              lda (paramptr),y
              beq @end
              cmp #' '
              bne @opt_cmp
@end:         lda options,x   ; if ' ' is reached then end of option required
              sec             ; we mark a "found" if we branch
              beq @exit       ; \0 end of option
@opt_cmp:     cmp options,x
              bne @next
              inx
              bra @opt_start

next_ppm_file:
@l_next:      lda #<_direntry
              ldy #>_direntry
              ldx _fd_dir
              jsr krn_readdir
              bcs @l_exit
              lda _direntry+F32DirEntry::Attr
              and #DIR_Attr_Mask_Archive
              beq @l_next
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
              sta _filename,x
              inx
@skip:        iny
              cpy #.sizeof(F32DirEntry::Name)
              bne @l_ext
              lda #'.'
              sta _filename,x
              inx
@l_ext:       cpy #.sizeof(F32DirEntry::Name)+.sizeof(F32DirEntry::Ext)
              bne :-
              stz _filename,x
              clc
@l_exit:      rts

gfxui_on:
              jsr krn_textui_disable      ;disable textui

              jsr vdp_mode7_on         ;enable gfx7 mode
              vdp_sreg v_reg9_ln | v_reg9_nt, v_reg9  ; 212px

              bit _settings
              bmi gfxui_blank
              vdp_sreg v_reg25_wait | v_reg25_yjk, v_reg25  ; enable yjk

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
              _ppmext:    .byte "PPM"
              _ppmext_end:

              options:
              opt_sld:  .asciiz "slide"
              opt_rgb:  .asciiz "rgb"
              opt_hlp:  .asciiz "h"
              usage:
                .byte "ppmview [-rgb] [-slide] file",CODE_LF
                .byte "  -h     - this help",CODE_LF
                .byte "  -rgb   - encode ppm data to GRB (SCREEN 7), defaults to YJK",CODE_LF
                .byte "  -slide - slide show of ppm files in current directory",CODE_LF
                .byte 0
.bss
              _param_ix:  .res 1
              _settings:  .res 1 ; bit 7 rgb on/off, bit 6 slide, bit 5-0 slide delay
              _fd_dir:    .res 1
              _direntry:  .res DIR_Entry_Size
              _filename:  .res 64
              _filename_end:
              _cwd:       .res 64
              _cwd_end:
