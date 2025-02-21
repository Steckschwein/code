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

;       0       2       4       6       8       a       c       e      10      12      14      16      18      1a              1e  1f
.byte $c7,$d0,$d2,$d2,$d2,$d2,$d2,$d2,$d2,$d2,$d4,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$d0,$d2,$d2,$d2,$d2,$d6,$d8,$d2,$d2,$d2,$d2,$d4 ; 0
.byte $c7,$da,$cc,$cc,$ce,$cc,$cc,$cc,$cc,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$cc,$cc,$ce,$dc,$e1,$cc,$cc,$cc,$cc,$db
.byte $c7,$da,$cc,$e2,$e6,$e4,$cc,$e2,$e4,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$e2,$e4,$cc,$e3,$e5,$cc,$e2,$e4,$cc,$db
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$dc,$e1,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$dc,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$db
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$dc,$e1,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$dc,$ee,$e6,$e6,$e4,$cc,$dc,$e1,$cc,$db ; 4
.byte $c7,$da,$cc,$e3,$e7,$e5,$cc,$e3,$e5,$cc,$e3,$d2,$d2,$d2,$e5,$20,$e3,$d2,$d2,$d2,$e5,$cc,$e3,$e7,$e7,$e7,$e5,$cc,$dc,$e1,$cc,$db ; 5
.byte $c7,$da,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$db
.byte $c7,$da,$cc,$e2,$e6,$e4,$cc,$e2,$e6,$e6,$e6,$e6,$e6,$e6,$e4,$20,$e2,$e6,$e6,$e6,$e4,$cc,$e2,$e4,$cc,$e2,$e6,$e6,$f0,$e1,$cc,$db
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$e3,$e7,$e7,$f1,$ef,$e7,$e7,$e5,$20,$e3,$e7,$e7,$e7,$e5,$cc,$dc,$e1,$cc,$e3,$e7,$e7,$f1,$e1,$cc,$db ; 8
.byte 'H',$da,$cc,$dc,$c7,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$20,$20,$20,$20,$20,$20,$20,$20,$20,$cc,$dc,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$db
.byte 'G',$da,$cc,$dc,$c7,$e1,$cc,$e2,$e4,$cc,$dc,$e1,$20,$e8,$d3,$d3,$d3,$ea,$20,$e2,$e4,$cc,$dc,$e1,$cc,$e2,$e4,$cc,$dc,$e1,$cc,$db ; a
.byte 'I',$da,$cc,$e3,$e7,$e5,$cc,$dc,$e1,$cc,$e3,$e5,$20,$db,$20,$20,$20,$da,$20,$dc,$e1,$cc,$e3,$e5,$cc,$dc,$e1,$cc,$e3,$e5,$cc,$db
.byte 'H',$da,$cc,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$20,$20,$20,$ec,$20,$20,$20,$da,$20,$dc,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$cc,$cc,$cc,$db ; c
.byte $c7,$f2,$e6,$e6,$e6,$e4,$cc,$dc,$ee,$e6,$e6,$e4,$20,$cf,$20,$20,$20,$da,$20,$dc,$ee,$e6,$e6,$e4,$20,$dc,$ee,$e6,$e6,$e4,$cc,$db ; d
.byte $c7,$f3,$e7,$e7,$e7,$e5,$cc,$dc,$ef,$e7,$e7,$e5,$20,$cf,$20,$20,$20,$da,$20,$dc,$ef,$e7,$e7,$e5,$20,$dc,$ef,$e7,$e7,$e5,$cc,$db
.byte $c7,$da,$cc,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$20,$20,$20,$ed,$20,$20,$20,$da,$20,$dc,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$cc,$cc,$cc,$db ; f
.byte $c7,$da,$cc,$e2,$e6,$e4,$cc,$dc,$e1,$cc,$e2,$e4,$20,$db,$20,$20,$20,$da,$20,$dc,$e1,$cc,$e2,$e4,$cc,$dc,$e1,$cc,$e2,$e4,$cc,$db ; 10
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$e3,$e5,$cc,$dc,$e1,$20,$e9,$d2,$d2,$d2,$eb,$20,$e3,$e5,$cc,$dc,$e1,$cc,$e3,$e5,$cc,$dc,$e1,$cc,$db
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$20,$20,$20,$20,$20,$20,$20,$20,$20,$cc,$dc,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$db ; 12
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$e2,$e6,$e6,$f0,$ee,$e6,$e6,$e4,$20,$e2,$e6,$e6,$e6,$e4,$cc,$dc,$e1,$cc,$e2,$e6,$e6,$f0,$e1,$cc,$db
.byte $c7,$da,$cc,$e3,$e7,$e5,$cc,$e3,$e7,$e7,$e7,$e7,$e7,$e7,$e5,$20,$e3,$e7,$e7,$e7,$e5,$cc,$e3,$e5,$cc,$e3,$e7,$e7,$f1,$e1,$cc,$db ; 14
.byte $c7,$da,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$db
.byte $c7,$da,$cc,$e2,$e6,$e4,$cc,$e2,$e4,$cc,$e2,$d3,$d3,$d3,$e4,$20,$e2,$d3,$d3,$d3,$e4,$cc,$e2,$e6,$e6,$e6,$e4,$cc,$dc,$e1,$cc,$db
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$dc,$e1,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$dc,$ef,$e7,$e7,$e5,$cc,$dc,$e1,$cc,$db
.byte $c7,$da,$cc,$dc,$c7,$e1,$cc,$dc,$e1,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$dc,$e1,$cc,$cc,$cc,$cc,$dc,$e1,$cc,$db ; 18
.byte $c7,$da,$cc,$e3,$e7,$e5,$cc,$e3,$e5,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$e3,$e5,$cc,$e2,$e4,$cc,$e3,$e5,$cc,$db
.byte $c7,$da,$cc,$cc,$ce,$cc,$cc,$cc,$cc,$cc,$db,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$da,$cc,$cc,$cc,$ce,$dc,$e1,$cc,$cc,$cc,$cc,$db ; 1a
.byte $c7,$d1,$d3,$d3,$d3,$d3,$d3,$d3,$d3,$d3,$d5,$c7,$c7,$c7,$da,$20,$db,$c7,$c7,$c7,$d1,$d3,$d3,$d3,$d3,$d7,$d9,$d3,$d3,$d3,$d3,$d5 ; 1b

; P(x1,y1) P(x2,y2) => dist=a²=b²+c² => a=sqrt(b²+c²) => it's sufficient to calculate the sum of |x1-x2| + |y1-y2| to sort the distances
; e.g. P($2,$1) P($1f,$1b) => |$02-$1f| + |$01-$1b| = $1d + $1a = $37
;
; CREDIT  0   HIGH      c7

; 1UP      c7 HIGH      c7
;##########################
;#           ##           #
;# ### ##### ## ##### ### #
;# # # #   # ## #   # # # #
;# ### ##### ## ##### ### #
;#                        #
;# ### ## ######## ## ### #
;# ### ## ######## ## ### #
;#     ##    ##    ##     #
;##### ##### ## ##### #####
;    # ##### ## ##### #
;    # ##  RRRRRR  ## #
;    # ## ######## ## #
;##### ## #      # ## #####
;TTTTT    #      #    TTTTT
;##### ## #      # ## #####
;    # ## ######## ## #
;    # ##          ## #
;    # ## ######## ## #
;##### ## ######## ## #####
;#           ##           #
;# ### ##### ## ##### ### #
;# ### ##### ## ##### ### #
;#  ##     RRRRRR     ##  #
;## ## ## ######## ## ## ##    ^
;## ## ## ######## ## ## ##  --|
;#     ##    ##    ##     #
;# ######### ## ######### #
;# ######### ## ######### #
;#                        #
;##########################

;R => red zone, consider char $cc vs. $8c and $07 vs. $60, or use position
;T => tunnel, consider $07 vs. $a0 (bit 7)
