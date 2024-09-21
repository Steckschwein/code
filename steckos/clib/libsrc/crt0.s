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
; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------
;
; Startup code for Steckschwein

.include "zeropage.inc"  ;cc65 default zp
.include "asminc/zeropage.inc"  ; FIXME kernel vs default zp ?!?
.include "asminc/appstart.inc"

.export  _init, _exit

.export  __STARTUP__ : absolute = 1      ; Mark as startup
.import  __RAM_START__, __RAM_SIZE__     ; Linker generated

.import    copydata, zerobss, initlib, donelib
.import    moveinit
.import    callmain
.import    __MAIN_START__, __MAIN_SIZE__  ; Linker generated
.import    __STACKSIZE__             ; from configure file
.importzp  ST

appstart  ; app start address to $1000, see appstart.inc

; ---------------------------------------------------------------------------
; Place the startup code in a special segment
.segment  "STARTUP"
_init:

; ---------------------------------------------------------------------------
; A little light 6502 housekeeping

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer
    LDA    #<(__RAM_START__ + __RAM_SIZE__)
    STA    sp
    LDA    #>(__RAM_START__ + __RAM_SIZE__)
    STA    sp+1

; ---------------------------------------------------------------------------
; Initialize memory storage
      JSR    zerobss              ; Clear BSS segment
      JSR    copydata        ; Initialize DATA segment
      JSR    initlib        ; Run constructors

; ---------------------------------------------------------------------------
; Call main()
      jsr  callmain

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break

_exit:
      JSR    donelib        ; Run destructors
      jmp    (retvec)
