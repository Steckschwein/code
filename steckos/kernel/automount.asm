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
.ifdef DEBUG_AUTOMOUNT
      debug_enabled=1
.endif

      .export __automount
      .export __automount_init
      
      .import primm
      .import sdcard_init
      .import sdcard_detect
      .import fat_mount
      .import krn_chrout
      
      .include "system.inc"
      .include "via.inc"
      .include "vdp.inc"
      
      .include "debug.inc"
.code

MOUNT_RETRIES=6

__automount_init:
      jsr sdcard_detect
      bne sdcard_err_detect
__automount:
      jsr sdcard_detect
      bne reset_retry     ; no card, reset retry and exit
      lda sdcard_retry    ; should we try?
      beq exit            ; no, exit
      
      jsr sdcard_init     ; yes, try init
      debug8 "init", sdcard_retry
      bne sdcard_err_init
@mount:
      stz sdcard_retry    ; ok, no further retries
      jsr fat_mount
      beq exit            ; init and mount ok, exit
      pha
      jsr primm
      .byte "mount error (",0
      pla
      and #$0f
      ora #'0'
      jsr krn_chrout
      jsr primm
      .byte ")",CODE_LF,0
exit:
      rts
msg_sdcard:
      jsr primm
      .byte "SD card ",0
      rts
sdcard_err_detect:
      jsr msg_sdcard
      jsr primm
      .byte "not found!",CODE_LF,0
reset_retry:
      lda #MOUNT_RETRIES              ; yes, try init and mount otherwise
      sta sdcard_retry
      rts
sdcard_err_init:          
      dec sdcard_retry  ; dec retry
      bne exit         ; .. and exit
      jsr msg_sdcard    ; or fail if retries exhausted
      jsr primm
      .byte "init failed!",CODE_LF,0
      rts
sdcard_retry: .res 1,1; initial with 1, during boot only one try