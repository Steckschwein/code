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

__automount_init:
      jsr sdcard_detect
      beq sdinit
      jsr primm
      .byte "No SD card!",CODE_LF,0
      rts
__automount:
      jsr sdcard_detect
      bne reset_retry    ; no card, reset retry and exit
      lda sdcard_retry   ; should we try?
      beq exit
sdinit:
      jsr sdcard_init
      beq @mount
      dec sdcard_retry
      bne exit
      jsr primm
      .byte "SD card init failed!",CODE_LF,0
      rts
@mount:
      stz sdcard_retry
      jsr fat_mount
      beq exit
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
reset_retry:
      lda #3              ; yes, try init and mount otherwise
      sta sdcard_retry
      rts
      
sdcard_retry: .res 1,1; initial with 1, during boot only one try