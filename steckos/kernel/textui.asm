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
.include "kernel.inc"
.include "keyboard.inc"
.include "vdp.inc"

ROWS=24
CURSOR_BLANK=' '
CURSOR_CHAR=$db ; invert blank char - @see charset_6x8.asm

STATE_BUFFER_DIRTY  =1<<0
STATE_CURSOR_OFF    =1<<1
STATE_CURSOR_BLINK  =1<<2
STATE_TEXTUI_ENABLED=1<<3

.segment "OS_CACHE"
.export screen_buffer;
.export color_buffer;
screen_buffer:
color_buffer=screen_buffer+$0800  ;+80x25

.code
.export textui_init0, textui_init, textui_update_screen, textui_chrout, textui_put

.ifdef TEXTUI_STROUT
.export textui_strout
.endif

.ifdef TEXTUI_PRIMM
.export textui_primm
.endif

.export textui_enable, textui_disable, textui_blank, textui_update_crs_ptr, textui_crsxy, textui_scroll_up, textui_cursor_onoff, textui_setmode

.import vdp_bgcolor
.import vdp_memcpy
.import vdp_text_on
.import vdp_display_off

_screen_dirty:
        lda #STATE_BUFFER_DIRTY
        tsb screen_status ;set dirty
        rts
        
textui_decy:
        lda    crs_y
        bne    @l1
        rts
@l1:    dec    crs_y            ; go on with textui_update_crs_ptr below
        bra    textui_update_crs_ptr

textui_incx:
        lda    crs_x
        cmp    max_cols 
        bne @l1
        rts                    ;TODO should we move to next row automatically ?!?
@l1:    inc    crs_x
        bra    textui_update_crs_ptr

textui_decx:
        lda    crs_x
        bne    @l1
        rts
@l1:    dec    crs_x            ; go on with textui_update_crs_ptr below
textui_update_crs_ptr:          ; updates the 16 bit pointer crs_p upon crs_x, crs_y values
        pha

        lda saved_char          ;restore saved char
        sta (crs_ptr)
        lda #STATE_CURSOR_BLINK
        trb screen_status       ;reset cursor state

        ;use the crs_ptr as tmp variable
        stz crs_ptr+1
        lda crs_y
        asl                        ; y*2
        asl                        ; y*4
        asl                        ; y*8

        bit max_cols
        bvc @l40
                                  ; crs_y*64 + crs_y*16 (crs_ptr) => y*80
        asl                       ; y*16
        sta crs_ptr
        php                       ; save carry
        rol crs_ptr+1             ; save carry if overflow
        bra @lae
@l40:
        ; crs_y*32 + crs_y*8  (crs_ptr) => y*40
        sta crs_ptr                ; save
        php                        ; save carry
@lae:
        asl
        rol crs_ptr+1           ; save carry if overflow
        asl
        rol crs_ptr+1            ; save carry if overflow

        plp                        ; restore carry from overflow above
        bcc @l0
        inc crs_ptr+1
        clc

@l0:    adc crs_ptr                ;
        bcc @l1
        inc crs_ptr+1        ; overflow inc page count
        clc                ;
@l1:    adc crs_x
        sta crs_ptr
        lda #>screen_buffer
        adc crs_ptr+1        ; add carry and page to address high byte
        sta crs_ptr+1

        lda (crs_ptr)
        sta saved_char        ;save char at new position

        pla
        rts

textui_init0:
        jsr vdp_display_off                 ;display off
        SetVector screen_buffer, crs_ptr    ;set crs ptr initial to screen buffer
        
.ifdef COLS80
        lda #TEXT_MODE_80
.else
        lda #TEXT_MODE_40
.endif
textui_setmode:
        cmp #TEXT_MODE_80
        beq @setmode
        lda #TEXT_MODE_40
@setmode:
        sta max_cols
        jsr textui_blank
        
textui_init:
        stz screen_write_lock               ;reset write lock
        jsr textui_enable
        jmp vdp_text_on

textui_blank:
        ldx #0
        lda #CURSOR_BLANK
        sta saved_char
@l1:    sta screen_buffer+$000,x    ;4 pages, 40x24
        sta screen_buffer+$100,x
        sta screen_buffer+$200,x
        sta screen_buffer+$300,x

        sta screen_buffer+$400,x    ;additional 4 pages for 80 cols
        sta screen_buffer+$500,x
        sta screen_buffer+$600,x
        sta screen_buffer+$700,x
        stz color_buffer,x
        inx
        bne @l1

        stz crs_x
        stz crs_y
        jsr textui_update_crs_ptr

        jmp _screen_dirty
        
textui_cursor:
        lda screen_write_lock
        bne @l_exit
        lda screen_frames
        and #$0f
        bne @l_exit

        lda screen_status
        and #STATE_CURSOR_OFF
        bne @l_exit

        lda #STATE_CURSOR_BLINK
        tsb screen_status
        beq @l1
        trb screen_status
        lda #CURSOR_CHAR
        bra @l2
@l1:     lda saved_char
@l2:     sta (crs_ptr)
        jmp _screen_dirty
@l_exit:
        rts

textui_update_screen:
;        lda    #Dark_Green
 ;       jsr    vdp_bgcolor

        lda screen_status
        and #STATE_TEXTUI_ENABLED
        beq @l1

        inc screen_frames

        jsr textui_cursor

        lda screen_status
        and #STATE_BUFFER_DIRTY
        beq @l1    ;exit if not dirty

        vdp_sreg <ADDRESS_TEXT_COLOR, (WRITE_ADDRESS + >ADDRESS_TEXT_COLOR)
        lda #<color_buffer         ; copy back buffer to video ram
        ldy #>color_buffer
        ldx #1
        jsr vdp_memcpy
        vdp_sreg <ADDRESS_TEXT_SCREEN, (WRITE_ADDRESS + >ADDRESS_TEXT_SCREEN)
        lda #<screen_buffer         ; copy back buffer to video ram
        ldy #>screen_buffer
        ldx #$08
        jsr vdp_memcpy

        lda screen_status        ;clean dirty
        and #<(~STATE_BUFFER_DIRTY)
        sta screen_status

@l1:
        lda #Medium_Green<<4|Black
        ;jsr    vdp_bgcolor
        rts

textui_scroll_up:
        phx
        
        ldx #0
        bit max_cols
        bvc @scroll_40
        
@l0:    lda color_buffer+10,x
        sta color_buffer+00,x
        inx
        cpx #$100-10
        bne @l0
        
        ldx #0
@l1:    lda    screen_buffer+$000+80,x
        sta    screen_buffer+$000,x
        inx
        bne    @l1
@l2:    lda    screen_buffer+$100+80,x
        sta    screen_buffer+$100,x
        inx
        bne    @l2
@l3:    lda    screen_buffer+$200+80,x
        sta    screen_buffer+$200,x
        inx
        bne    @l3
@l4:    lda    screen_buffer+$300+80,x
        sta    screen_buffer+$300,x
        inx
        bne    @l4
@l5:    lda    screen_buffer+$400+80,x
        sta    screen_buffer+$400,x
        inx
        bne    @l5
@l6:    lda    screen_buffer+$500+80,x
        sta    screen_buffer+$500,x
        inx
        bne    @l6
@l7:    lda    screen_buffer+$600+80,x
        sta    screen_buffer+$600,x
        inx
        bne    @l7
@le:    lda    screen_buffer+$700+80,x
        sta    screen_buffer+$700,x
        inx
        cpx #<(80 * ROWS)
        bne @le
        bra @exit
@scroll_40:
        lda screen_buffer+$000+40,x
        sta screen_buffer+$000,x
        inx
        bne @scroll_40
@l40_1: lda screen_buffer+$100+40,x
        sta screen_buffer+$100,x
        inx
        bne @l40_1
@l40_2: lda screen_buffer+$200+40,x
        sta screen_buffer+$200,x
        inx
        bne @l40_2
@l40_e: lda screen_buffer+$300+40,x
        sta screen_buffer+$300,x
        inx
        cpx #<(40 * ROWS)
        bne @l40_e        
@exit:
        plx
        rts

textui_inc_cursor_y:
        lda crs_y
        cmp    #ROWS-1            ;last line
        bne    @l1

        lda saved_char          ;restore saved char
        sta (crs_ptr)
        lda #CURSOR_BLANK
        sta saved_char          ;reset saved_char to blank, cause we scrolled up
        lda #STATE_CURSOR_BLINK
        trb screen_status       ;reset cursor state
        jsr textui_scroll_up    ; scroll and exit
        jmp textui_update_crs_ptr
@l1:    inc crs_y
        jmp textui_update_crs_ptr

textui_enable:
        lda #STATE_TEXTUI_ENABLED
        sta screen_status       ;set enable
        rts
textui_disable:
        stz screen_status
        lda saved_char          ;restore char
        sta (crs_ptr)
        rts

textui_cursor_onoff:
        lda screen_status
        eor #STATE_CURSOR_OFF
        sta screen_status
        rts

.ifdef TEXTUI_STROUT
;----------------------------------------------------------------------------------------------
; Output string on screen
; in:
;   A - lowbyte  of string address
;   X - highbyte of string address
;----------------------------------------------------------------------------------------------
textui_strout:
        sta krn_ptr3        ;init for output below
        stx krn_ptr3+1

        inc screen_write_lock    ;write lock on
        ldy    #$00
@l1:    lda    (krn_ptr3),y
        beq    @l2
        jsr textui_dispatch_char
        iny
        bne    @l1
@l2:    stz    screen_write_lock    ;write lock off
        jmp _screen_dirty
.endif

;----------------------------------------------------------------------------------------------
; Put the string following in-line until a NULL out to the console
; jsr primm
; .byte "Example Text!",$00
;----------------------------------------------------------------------------------------------
.ifdef TEXTUI_PRIMM
textui_primm:
        pla                        ; Get the low part of "return" address
        sta     krn_ptr3
        pla                        ; Get the high part of "return" address
        sta     krn_ptr3+1

        inc screen_write_lock
        ; Note: actually we're pointing one short
PSINB:    inc     krn_ptr3             ; update the pointer
        bne     PSICHO          ; if not, we're pointing to next character
        inc     krn_ptr3+1             ; account for page crossing
PSICHO:    lda     (krn_ptr3)            ; Get the next string character
        beq     PSIX1           ; don't print the final NULL
        jsr     textui_dispatch_char        ; write it out
        bra     PSINB           ; back around
PSIX1:    inc     krn_ptr3             ;
        bne     PSIX2           ;
        inc     krn_ptr3+1             ; account for page crossing
PSIX2:
        stz screen_write_lock
        jsr _screen_dirty

        jmp     (krn_ptr3)           ; return to byte following final NULL
.endif

textui_put:
        pha
        inc screen_write_lock   ;write lock on
        sta saved_char
        jsr _screen_dirty
        stz screen_write_lock   ;write lock off
        pla
        rts

textui_chrout:
        cmp #0
        beq @l1    ; \0 char
        pha        ; safe char
        inc screen_write_lock    ;write on
        jsr textui_dispatch_char
        stz screen_write_lock    ;write off
        jsr _screen_dirty

        pla                    ; restore a
@l1:    rts



; set crs x and y position absolutely - 0..32/0..23 or 0..39/0..23 40 char mode
;
textui_crsxy:
        stx crs_x
        sty crs_y
        jmp textui_update_crs_ptr

textui_dispatch_char:
        cmp    #KEY_CR            ;carriage return?
        bne    @lfeed
        stz    crs_x
        jmp textui_update_crs_ptr
@lfeed:
        cmp    #KEY_LF            ;line feed
        bne    @l1
        stz crs_x
        jmp    textui_inc_cursor_y
@l1:    cmp    #KEY_BACKSPACE
        bne    @l4
        lda    crs_x
        bne    @l3
        lda    crs_y            ; cursor y=0, no dec
        beq    @lupdate
        dec    crs_y
        lda    max_cols            ; set x to end of line above
        sta    crs_x
@l2:    jsr    textui_update_crs_ptr
        lda    #CURSOR_BLANK            ;blank the saved char
        sta    saved_char
        rts
@l3:    dec    crs_x
        bra @l2
@l4:
        sta    saved_char         ; the trick, simple set saved value to plot as saved char, will be print by textui_update_crs_ptr
        lda    crs_x
        cmp    max_cols
        beq @l5
        inc    crs_x
@lupdate:
        jmp    textui_update_crs_ptr
@l5:    stz    crs_x
        jmp    textui_inc_cursor_y

screen_status:      .res 1
screen_write_lock:  .res 1
screen_frames:      .res 1
saved_char:         .res 1