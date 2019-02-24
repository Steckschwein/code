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

.include "steckos.inc"
.include "rtc.inc"
appstart $1000
.export char_out=krn_chrout


.importzp ptr1
.import hexout

.code

main:
        lda rtc_systime_t+time_t::tm_sec
        eor rtc_systime_t+time_t::tm_min
        sta seed
        ;jsr hexout

        jsr prnd
        ;jsr hexout

        asl
        tay
        lda fortunes_tab+1,y
        sta ptr1+1
        lda fortunes_tab,y
        sta ptr1

out:

        ldy #0
loop:
        lda (ptr1),y
        beq exit
        jsr krn_chrout
        iny
        bne loop
exit:
		jmp (retvec)

prnd:
        lda seed
        beq doEor
        asl
        beq noEor ;if the input was $80, skip the EOR
        bcc noEor
doEor:  eor #$1d
noEor:  sta seed
        rts

fortunes_tab:
        .word fortune0
        .word fortune1
        .word fortune2
        .word fortune3
        .word fortune4
        .word fortune5
        .word fortune6
        .word fortune7
        .word fortune8
        .word fortune9
        .word fortune10
        .word fortune11
        .word fortune12
        .word fortune13
        .word fortune14
        .word fortune15
        .word fortune16
        .word fortune17
        .word fortune18
        .word fortune19
        .word fortune20
        .word fortune21
        .word fortune22
        .word fortune23
        .word fortune24
        .word fortune25
        .word fortune26
        .word fortune27
        .word fortune28
        .word fortune29
        .word fortune30
        .word fortune31
        .word fortune32
        .word fortune33
        .word fortune34
        .word fortune35
        .word fortune36
        .word fortune37
        .word fortune38
        .word fortune39
        .word fortune40
        .word fortune41
        .word fortune42
        .word fortune43
        .word fortune44
        .word fortune45
        .word fortune46
        .word fortune47
        .word fortune48
        .word fortune49
        .word fortune50
        .word fortune51
        .word fortune52
        .word fortune53
        .word fortune54
        .word fortune55
        .word fortune56
        .word fortune57
        .word fortune58
        .word fortune59
        .word fortune60
        .word fortune61
        .word fortune62
        .word fortune63
        .word fortune64
        .word fortune65
        .word fortune66
        .word fortune67
        .word fortune68
        .word fortune69
        .word fortune70
        .word fortune71
        .word fortune72
        .word fortune73
        .word fortune74
        .word fortune75
        .word fortune76
        .word fortune77
        .word fortune78
        .word fortune79
        .word fortune80
        .word fortune81
        .word fortune82
        .word fortune83
        .word fortune84
        .word fortune85
        .word fortune86
        .word fortune87
        .word fortune88
        .word fortune89
        .word fortune90
        .word fortune91
        .word fortune92
        .word fortune93
        .word fortune94
        .word fortune95
        .word fortune96
        .word fortune97
        .word fortune98
        .word fortune99
        .word fortune100
        .word fortune101
        .word fortune102
        .word fortune103
        .word fortune104
        .word fortune105
        .word fortune106
        .word fortune107
        .word fortune108
        .word fortune109
        .word fortune110
        .word fortune111
        .word fortune112
        .word fortune113
        .word fortune114
        .word fortune115
        .word fortune116
        .word fortune117
        .word fortune118
        .word fortune119
        .word fortune120
        .word fortune121
        .word fortune122
        .word fortune123
        .word fortune124
        .word fortune125
        .word fortune126
        .word fortune127
        .word fortune128
        .word fortune129
        .word fortune130
        .word fortune131
        .word fortune132
        .word fortune133
        .word fortune134
        .word fortune135
        .word fortune136
        .word fortune137
        .word fortune138
        .word fortune139
        .word fortune140
        .word fortune141
        .word fortune142
        .word fortune143
        .word fortune144
        .word fortune145
        .word fortune146
        .word fortune147
        .word fortune148
        .word fortune149
        .word fortune150
        .word fortune151
        .word fortune152
        .word fortune153
        .word fortune154
        .word fortune155
        .word fortune156
        .word fortune157
        .word fortune158
        .word fortune159
        .word fortune160
        .word fortune161
        .word fortune162
        .word fortune163
        .word fortune164
        .word fortune165
        .word fortune166
        .word fortune167
        .word fortune168
        .word fortune169
        .word fortune170
        .word fortune171
        .word fortune172
        .word fortune173
        .word fortune174
        .word fortune175
        .word fortune176
        .word fortune177
        .word fortune178
        .word fortune179
        .word fortune180
        .word fortune181
        .word fortune182
        .word fortune183
        .word fortune184
        .word fortune185
        .word fortune186
        .word fortune187
        .word fortune188
        .word fortune189
        .word fortune190
        .word fortune191
        .word fortune192
        .word fortune193
        .word fortune194
        .word fortune195
        .word fortune196
        .word fortune197
        .word fortune198
        .word fortune199
        .word fortune200
        .word fortune201
        .word fortune202
        .word fortune203
        .word fortune204
        .word fortune205
        .word fortune206
        .word fortune207
        .word fortune208
        .word fortune209
        .word fortune210
        .word fortune211
        .word fortune212
        .word fortune213
        .word fortune214
        .word fortune215
        .word fortune216
        .word fortune217
        .word fortune218
        .word fortune219
        .word fortune220
        .word fortune221
        .word fortune222
        .word fortune223
        .word fortune224
        .word fortune225
        .word fortune226
        .word fortune227
        .word fortune228
        .word fortune229
        .word fortune230
        .word fortune231
        .word fortune232
        .word fortune233
        .word fortune234
        .word fortune235
        .word fortune236
        .word fortune237
        .word fortune238
        .word fortune239
        .word fortune240
        .word fortune241
        .word fortune242
        .word fortune243
        .word fortune244
        .word fortune245
        .word fortune246
        .word fortune247
        .word fortune248
        .word fortune249
        .word fortune250
        .word fortune251
        .word fortune252
        .word fortune253
        .word fortune254
        .word fortune255
seed:    .BYTE 42
.include "fortunes.inc"
