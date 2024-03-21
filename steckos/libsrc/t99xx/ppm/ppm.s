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
; use imagemagick $convert <image> -geometry 256 -color 256 <image.ppm>
; convert <file>.pdf[page] -resize 256x212^ -gravity center -crop x212+0+0 +repage pic.ppm
; convert <file> -resize 256^x192 -gravity center -crop 256x192+0+0 +repage <out file>.ppm
;
.setcpu "65c02"
.include "common.inc"
.include "vdp.inc"
.include "fcntl.inc"
.include "errno.inc"
.include "zeropage.inc"

.autoimport

.export ppm_width
.export ppm_height

.export ppm_load_image
.export ppm_parse_header
; for TEST purpose only
.export rgb_bytes_to_grb

.define MAX_WIDTH 256
.define MAX_HEIGHT 212
.define COLOR_DEPTH 255
.define BLOCK_BUFFER 8

.segment "ZEROPAGE_LIB": zeropage
              _i:         .res 1
              codec:      .res 1


.struct yjk ; !!! do not change order here, due to indirect access in rgb_bytes_to_yjk
              b3 .byte
              g3 .byte
              r3 .byte
              b2 .byte
              g2 .byte
              r2 .byte
              b1 .byte
              g1 .byte
              r1 .byte
              b0 .byte
              g0 .byte
              r0 .byte

              bm .byte
              gm .byte
              rm .byte

              ym .byte
              j .byte
              k .byte
.endstruct

.code

;@name: ppm_load_image
;@in: A/X file name to load
;@in: Y Bit 0 - vdp vram page to load ppm into - either 0 for address $00000 or 1 for address $10000
;@in: Y Bit 7 - encode ppm RGB bytes to VDP9958 GRB encoding, YJK otherwise (default)
;@out: C=0 success and image loaded to vram (mode 7), C=1 otherwise with A/X error code where X ppm specific error, A i/o specific error
;@out: ppm_width / ppm_height denoting the size of the image on success (C=0)
.proc ppm_load_image

              stz fd
              sty codec
              sty vram_page

              ldy #O_RDONLY
              jsr fopen
              bcs @io_error
              stx fd

              jsr ppm_parse_header
              bcc @ppm_ok
              lda #0
              ldx #$ff
              bra @error
@ppm_ok:
              jsr load_image
              bcc @close_exit
@io_error:
              ldx #0
@error:
              sec
@close_exit:
              php
              phx
              pha
              ldx fd
              beq @l_exit
              jsr fclose
@l_exit:
              pla
              plx
              plp
              rts
.endproc

load_image:
              stz cols
              stz rows

              lda vram_page
              and #$01
              asl
              asl
              sta vram_page

              php
              sei ;critical section, avoid vdp irq here
              jsr copy_to_vram
              bcs @l_err
              plp
              clc
              rts
@l_err:
              plp
              sec
              rts

copy_to_vram:
              jsr set_screen_addr  ; adjust vram address to cols/rows
              bbr7 codec, @yjk
              jsr rgb_bytes_to_grb
              bra @io
@yjk:         jsr rgb_bytes_to_yjk
@io:          bcs @exit
              ;    jsr hexout
              lda cols
              cmp ppm_width
              bne copy_to_vram
              stz cols
              inc rows
              lda rows
              cmp ppm_height
              bne copy_to_vram
              clc
@exit:
              rts


rgb_bytes_to_yjk:
              ldy #4*3-1
  :           jsr fread_byte            ; read 4 consecutive pixel with 3 byte (rgb) each
              ;bcs @exit
              lsr                       ; r3,g3,b3..r0,g0,b0 = readByte(fd) >> 3
              lsr
              lsr
              sta yjk_chunk+yjk::b3,y   ; b3 we count down
              dey
              bpl :-

              ldy #2                    ; rm,bm,gm
              clc                       ; never overflows
  :           lda #2                    ; rm = ((r0 + r1 + r2 + r3 + 2)>>2); bm, gm same manner
              adc yjk_chunk+yjk::b0,y
              adc yjk_chunk+yjk::b1,y
              adc yjk_chunk+yjk::b2,y
              adc yjk_chunk+yjk::b3,y
              lsr
              lsr
              sta yjk_chunk+yjk::bm,y
              dey
              bpl :-

              asl yjk_chunk+yjk::bm     ; ym = round(bm/2 + rm/4 + gm/8) => (bm*4 + rm*2 + gm + 8/2) / 8 => round(A/B) = (A+B/2)/B ;) FTW
              asl yjk_chunk+yjk::bm     ;    = (bm<<2 + rm<<1 + gm + 4) >> 3 => +4 for round()
              lda yjk_chunk+yjk::rm
              asl
              clc
              adc yjk_chunk+yjk::bm
              adc yjk_chunk+yjk::gm
              adc #4
              lsr
              lsr
              lsr
              sta yjk_chunk+yjk::ym

              sec                       ; j = rm - ym;
              lda yjk_chunk+yjk::rm
              sbc yjk_chunk+yjk::ym
              sta yjk_chunk+yjk::j
              lda yjk_chunk+yjk::gm     ; k = gm - ym;
              sbc yjk_chunk+yjk::ym
              sta yjk_chunk+yjk::k

              ldy #3*3                  ; r,g,b see yjk struct - we count down
  :           lda yjk_chunk+yjk::b3,y   ; y3..y0 = round(b0/2 + r0/4 + g0/8) = (b0<<2 + r0<<1 + g + 4)>>3
              asl
              asl
              sta yjk_chunk+yjk::b3,y
              lda yjk_chunk+yjk::r3,y
              asl
              clc
              adc yjk_chunk+yjk::b3,y
              adc yjk_chunk+yjk::g3,y
              adc #4
              and #$f8                  ; !!! we do not >>3 (div 8) but mask out bit 2..0 - the y value in vram has to be placed as bit 7..3 and bit 2..0 are the k/j component
              sta yjk_chunk+yjk::r3,y   ; store y0..y3 in r0..r3, not used anymore
              dey
              dey
              dey
              bpl :-

              lda yjk_chunk+yjk::k      ; r0 (y0) with k low
              and #$07
              ora yjk_chunk+yjk::r0
              sta a_vram
              lda yjk_chunk+yjk::k      ; r1 (y1) with k high
              lsr
              lsr
              lsr
              and #$07
              ora yjk_chunk+yjk::r1
              vdp_wait_l 16
              sta a_vram

              lda yjk_chunk+yjk::j      ; r2 with j low
              and #$07
              ora yjk_chunk+yjk::r2
              vdp_wait_l 8
              sta a_vram
              lda yjk_chunk+yjk::j      ; r3 with j high
              lsr
              lsr
              lsr
              and #$07
              ora yjk_chunk+yjk::r3
              vdp_wait_l 16
              sta a_vram

              lda cols
              clc
              adc #4
              sta cols

              lda ppm_width
              and #$fc
              cmp cols        ; width multiple of 4px reached?
              bne @exit
              lda ppm_width
              sbc cols
              beq @exit       ; skip n rgb values, we need 4px chunks
              tay
  :           jsr fread_byte
              jsr fread_byte
              jsr fread_byte
              inc cols
              dey
              bne :-
@exit:  clc
              rts

rgb_bytes_to_grb:  ; GRB 332 format
              jsr fread_byte  ;R
              bcs @exit
              and #$e0
              lsr
              lsr
              lsr
              sta _i
              jsr fread_byte  ;G
              bcs @exit
              and #$e0
              ora _i
              sta _i
              jsr fread_byte  ;B
              bcs @exit
              rol
              rol
              rol
              and #$03    ;blue - bit 1,0
              ora _i
              clc ; no error
              sta a_vram
              inc cols
@exit:
              rts

set_screen_addr:
              lda cols
              clc
              adc offs_l
              sta a_vreg                 ; A7-A0 vram address low byte
              lda rows
              clc
              adc offs_t
              pha
              and #$3f                   ; A13-A8 vram address highbyte
              ora #WRITE_ADDRESS
              sta a_vreg
              pla                        ; A16-A14 bank select via reg#14
              rol
              rol
              rol
              and #$03
              ora vram_page
              sta a_vreg
              vdp_wait_s 2
              lda #v_reg14
              sta a_vreg
              rts

ppm_parse_header:
              jsr fread_byte
              bcs @l_invalid_ppm
              cmp #'P'
              bne @l_invalid_ppm
              jsr fread_byte
              bcs @l_invalid_ppm
              cmp #'3'
              beq :+
              cmp #'6'
              bne @l_invalid_ppm
              jsr parse_string
:
              jsr parse_until_size  ;not, skip until <width> <height>
              jsr parse_int         ;try parse ppm width
              cmp #<MAX_WIDTH
              bcc @l_invalid_ppm
              sta ppm_width
              sec
              lda #<MAX_WIDTH
              sbc ppm_width
              lsr
              and #$fc
              sta offs_l

              jsr parse_int0  ;height
              cmp #MAX_HEIGHT+1
              bcs @l_invalid_ppm
              sta ppm_height
              sec
              lda #MAX_HEIGHT
              sbc ppm_height
              lsr
              sta offs_t

              jsr parse_int0  ;color depth
              cpy #3
              bne @l_invalid_ppm
              clc
              rts

@l_invalid_ppm:
              sec
              rts

; C=0 parse ok, C=1 on error
parse_int0:
              jsr fread_byte
              bcc parse_int
              rts
parse_int:
              ldy #0
              stz _i
@l_toi:
              cmp #'0'
              bcc @l_exit
              cmp #'9'+1
              bcs @l_exit

              pha    ;(n-1)*10 + n => (n-1)*2 + (n-1)*8 + n
              lda _i
              asl
              sta _i
              asl
              asl
              adc _i
              sta _i
              pla
              sec
              sbc #'0' ; make numeric
              clc
              adc _i
              sta _i
              iny
              phy
              jsr fread_byte
              ply
              bcc @l_toi ; C=1 on error
@l_exit:
              lda _i
              rts

parse_until_size:
              jsr fread_byte
              bcs @l
              cmp #'#'        ; skip comments
              bne @l
              jsr parse_string
              bra parse_until_size
@l:   rts

parse_string:
@l0:  jsr fread_byte
              bcs @le ; C=1 on error
              cmp #$20    ; < $20 - control characters are treat as string delimiter
              bcc @le
              bcs @l0
@le:  rts

.bss
vram_page:  .res 1
fd:         .res 1
offs_t:     .res 1  ; offset top
offs_l:     .res 1  ; offset left
cols:       .res 1
rows:       .res 1
ppm_width:  .res 1
ppm_height: .res 1

yjk_chunk:
  .tag yjk
