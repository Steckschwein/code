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

;@module: textui

.include "common.inc"
.include "kernel.inc"
.include "keyboard.inc"
.include "vdp.inc"

; TEXTUI_COLOR=Medium_Green<<4|Black
TEXTUI_COLOR=White<<4|Black
ROWS=24
CURSOR_BLANK=' '
CURSOR_CHAR=$db ; invert blank char - @see charset_6x8.asm

STATE_TEXTUI_LOCK     =1<<0
STATE_CURSOR_BLINK    =1<<2
STATE_CURSOR_OFF      =1<<6
STATE_TEXTUI_ENABLED  =1<<7

.code
.export textui_init, textui_reset, textui_update_screen, textui_chrout, textui_put

.ifdef TEXTUI_STROUT
.export textui_strout
.endif

.ifdef TEXTUI_PRIMM
.export textui_primm
.endif

.export textui_enable, textui_disable, textui_blank, textui_update_crs_ptr, textui_crsxy, textui_cursor_onoff, textui_setmode, textui_status

.import vdp_fill
.import vdp_text_on

.import textui_color

textui_scroll_up:
  php
  sei  ; critical section, we use the vdp regs
  phx
  phy

  lda #<ADDRESS_TEXT_SCREEN
  clc
  bit video_mode
  bvc :+
  adc #40
: adc #40
  sta a_r
  lda #>ADDRESS_TEXT_SCREEN
  sta a_r+1
  SetVector (ADDRESS_TEXT_SCREEN+(WRITE_ADDRESS<<8)), a_w  ; offset first row as "write address"

  ; 40/80 col mode, 10/20 * 100 calc pages to copy
  ldy #10
  bit video_mode
  bvc @l1
  ldy #20
@l1:
  lda a_r+0  ; 4cl
  sta a_vreg
  ldx #scroll_buffer_size-1
  lda a_r+1
  vdp_wait_s
  sta a_vreg
  vdp_wait_l
@vram_read:
  vdp_wait_l 18
  lda a_vram
  sta scroll_buffer,x  ; 4cl
  inc a_r+0  ; 6cl
  bne :+    ; 3cl
  inc a_r+1
: dex          ; 2cl
  bpl @vram_read ;3cl
@write:
  ldx #scroll_buffer_size-1
  lda a_w+0  ; 3cl
  sta a_vreg
  lda a_w+1
  vdp_wait_s 4
  sta a_vreg
  vdp_wait_l
@vram_write:
  vdp_wait_l 18
  lda scroll_buffer,x  ;4
  sta a_vram
  inc a_w+0  ; 6cl
  bne :+     ; 3cl
  inc a_w+1  ;
:  dex ; 2cl
  bpl @vram_write ;3cl
  dey
  bne @l1

  ldx #80 ; write address is already setup from loop above
  lda #' '
@l5:
  vdp_wait_l 4
  sta a_vram
  dex
  bne @l5

  ply
  plx
  plp
  ; fall through

;@name: textui_update_crs_ptr
;@desc: update to new cursor position given in crs_x and crs_y zeropage locations
;@in: -
textui_update_crs_ptr:
  jsr _vram_crs_ptr_write_saved ; restore saved char at old position
  lda #STATE_CURSOR_BLINK
  trb screen_status             ; reset cursor state

  ;use the vdp_ptr as tmp variable
  php
  sei
  stz vdp_ptr+1
  lda crs_y
  asl              ; y*2
  asl              ; y*4
  asl              ; y*8
  sta vdp_ptr          ; save for add below

  asl                 ; y*16
  rol vdp_ptr+1       ; shift carry to address high byte
  asl                 ; y*32
  rol vdp_ptr+1       ; shift carry to address high byte

  adc vdp_ptr         ; y*40 = y*8+y*32
  bcc :+
  inc vdp_ptr+1       ; overflow inc page count
  clc

: bit video_mode
  bvc :+
  asl                 ; y*80 => y*40*2
  rol vdp_ptr+1       ; shift carry to address high byte

: adc crs_x           ; add cursor x
  sta a_vreg
  sta vdp_ptr

  lda #>ADDRESS_TEXT_SCREEN
  adc vdp_ptr+1          ; add carry (above) and page to address high byte
  sta a_vreg
  sta vdp_ptr+1
  vdp_wait_l 3
  lda a_vram
  sta saved_char          ; save char at new position
  plp
  rts


;@name: textui_status
;@desc: get internal textui status flags
;@in: -
;@out: - N (negative) flag set if textui is enabled, not set otherwise (textui enabled)
;@out: - V (overflow) flag set if cursor is disabled, not set otherwise (cursor on)
textui_status:
  bit screen_status
  rts

;@name: textui_update_screen
;@desc: update internal state - is called on v-blank
;@in: -
textui_update_screen:
    inc screen_frames
    lda screen_status
    bmi textui_cursor
    rts

textui_cursor:
    lda screen_write_lock
    bne _l_exit
    lda screen_frames
    and #$0f
    bne _l_exit

    bit screen_status
    bvs _l_exit

    lda #STATE_CURSOR_BLINK
    tsb screen_status
    beq _vram_crs_ptr_write_saved
    trb screen_status
    lda #CURSOR_CHAR
    bra _vram_crs_ptr_write
_vram_crs_ptr_write_saved:
    lda saved_char
_vram_crs_ptr_write:
    php
    sei
    pha
    lda vdp_ptr
    sta a_vreg
    vdp_wait_s 5
    lda vdp_ptr+1
    ora #WRITE_ADDRESS
    sta a_vreg
    pla
    vdp_wait_l 3
    sta a_vram
    plp
_l_exit:
    rts

;@name: textui_init
;@desc: init the text ui if used for the first time. like kernel start or kind of
;@in: -
textui_init:
    lda #VIDEO_MODE_80_COLS
.ifdef COLS80
    tsb video_mode
.else
    trb video_mode
.endif
    bra textui_reset


;@name: textui_setmode
;@desc: set desired text mode which is either 40 (MSX TEXT 1) or 80 columns (MSX TEXT 2)
;@in: A - the desired mode, either VIDEO_MODE_80_COLS or 0 to reset to 40 column mode
textui_setmode:
    and #VIDEO_MODE_80_COLS
    bne :+
    lda #VIDEO_MODE_80_COLS
    trb video_mode
    bra @blank
:   tsb video_mode
@blank:
    jsr textui_blank

;@name: textui_reset
;@desc: reset text ui by setting the internal state accordingly.
;@in: -
textui_reset:
    stz screen_write_lock          ;reset write lock
    jsr textui_enable

.ifndef DISABLE_VDPINIT
    lda textui_color
    jsr vdp_text_on
.endif
    rts

;@name: textui_enable
;@desc: enable text ui
;@in: -
textui_enable:
    lda #STATE_TEXTUI_ENABLED
    sta screen_status     ;set enable
    rts

;@name: textui_disable
;@desc: disable text ui - cursor will be disabled
;@in: -
textui_disable:
    stz screen_status
    jmp _vram_crs_ptr_write_saved ;restore char


;@name: textui_cursor_onoff
;@desc: toggle the blinking cursor on if off or off if on
;@in: -
textui_cursor_onoff:
    lda screen_status
    eor #STATE_CURSOR_OFF
    sta screen_status
    rts

textui_put:
    sta saved_char
    rts

textui_chrout:
  cmp #0
  beq @l1            ; \0 char
  php
  sei
  pha                ; save char
  inc screen_write_lock     ; write on
  jsr __textui_dispatch_char
  stz screen_write_lock     ; write off
  pla                ; restore a
  plp
@l1:
  rts

;@name: textui_blank
;@desc: blank screen, set cursor to top left corner
;@in: -
textui_blank:
  ldx #4  ;pages to blank
  bit video_mode
  bvc :+
  ldx #8
: php
  sei
  vdp_vram_w ADDRESS_TEXT_SCREEN
  lda #CURSOR_BLANK
  sta saved_char
  jsr vdp_fill
  plp

  ldx #0
  ldy #0
  ; set crs x and y position absolutely - 0..32/0..23 or 0..39/0..23 40 char mode
textui_crsxy:
              stx crs_x
              sty crs_y
              jmp textui_update_crs_ptr

__textui_dispatch_char:
              cmp #KEY_CR  ;carriage return?
              bne @lfeed
              stz crs_x
              jmp textui_update_crs_ptr
@lfeed:
              cmp #KEY_LF  ;line feed
              beq @l5
              cmp #KEY_BACKSPACE
              bne @l4              ; normal char
              lda crs_x
              bne @l3
              lda crs_y            ; cursor y=0, no dec
              beq @exit
              dec crs_y
              lda #40
              bit video_mode          ; set x to max-cols
              bvc @l3
              asl ; 80 col
@l3:
              dec               ; -1 which is end of the previous line
              sta crs_x
              jsr textui_update_crs_ptr
              lda #CURSOR_BLANK        ; blank the saved char
              sta saved_char
@exit:        rts
@l4:          sta saved_char          ; the trick, simple set saved value to plot as saved char, will be print by textui_update_crs_ptr
              lda crs_x
              ina
              bit video_mode
              bvs :+
              cmp #40
              beq @l5
:             cmp #80
              beq @l5
              sta crs_x
              jmp textui_update_crs_ptr
@l5:          stz crs_x
              lda crs_y
              cmp #ROWS-1          ; last line
              bne @l6

              jsr _vram_crs_ptr_write_saved  ; restore saved char
              lda #CURSOR_BLANK
              sta saved_char         ; reset saved_char to blank, cause we scroll up
              jmp textui_scroll_up  ; scroll and exit

@l6:          inc crs_y
              jmp textui_update_crs_ptr

.bss
scroll_buffer_size = 100 ; 40/80 col mode => 1000/2000 chars to copy
scroll_buffer:      .res scroll_buffer_size
screen_status:      .res 1
screen_write_lock:     .res 1
screen_frames:      .res 1
saved_char:        .res 1
a_r:          .res 2
a_w:          .res 2
