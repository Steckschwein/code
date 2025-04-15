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

.autoimport

.include "asmunit.inc"
.include "debug.inc"

.export dev_read_block=         mock_read_block
.export dev_write_block=        mock_write_block

.export __rtc_systime_update=   mock_not_implemented

.import asmunit_chrout

.export debug_chrout=asmunit_chrout

debug_enabled=1

.macro setup testname
    test testname
    stz read_call
    stz write_call
    jsr blklayer_init
.endmacro

.code

; -------------------
setup "read block layer"
    jsr blklayer_read_block

    assert8 1, read_call
    assert8 0, write_call


setup "write block layer"
    jsr blklayer_read_block
    assert8 1, read_call
    assert8 0, write_call
    jsr blklayer_write_block_buffered
    assert8 1, read_call
    assert8 0, write_call
    jsr blklayer_read_block
    assert8 1, read_call
    assert8 0, write_call

    inc lba_addr
    jsr blklayer_read_block
    assert8 2, read_call
    assert8 1, write_call

test_end

mock_read_block:
    tax ; mock X destruction
    debug32 "mock_read_block lba", lba_addr
    debug32 "mock_read_block ptr", sd_blkptr
    inc read_call
    rts

mock_write_block:
    tax ; mock destruction of X
    debug32 "mock_write_block lba", lba_addr
    debug16 "mock_write_block ptr", sd_blkptr
    inc write_call
    rts

mock_not_implemented:
    fail "unexpected mock call!"

.bss
    read_call: .res 1
    write_call: .res 1
