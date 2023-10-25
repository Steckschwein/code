.setcpu "65c02"
.include "vdp.inc"
.include "common.inc"
.include "keyboard.inc"
.include "appstart.inc"
.include "kernel_jumptable.inc"

.autoimport

.importzp retvec

.zeropage
   byteaddr: .res 2  ; = $fc		;fc, fd used

appstart $1000

; Program: Fast Approximate Mandelbrot Set with Integer Math - Marcello of Retro64 Blog 2018

SCREEN_X=256
SCREEN_Y=200
MAX_ITER=31

;      vdp_rgb $40,$20,$40
      sei
      jsr krn_textui_disable

      jsr vdp_mode7_on

      vdp_sreg v_reg9_nt | v_reg9_ln, v_reg9  ; 212px

      lda a_vreg
      jsr     clear_screen

                lda #00
                sta xp          ;initializes high ..byte of x coordinate (unused)


                lda #$00        ;initializes counters for complex numbers
                sta y_im
                sta x_real

                ;sta screen_count
y_loop:
                ldy y_im        ;loads imaginary part of starting value
                lda i0_tab, y
                sta i0+1

                ; sign must be checked. If number is negative, 16 bit complement must be evaluated

                bpl no_16bit_complement_i0

                ; performs 16 bit complement

                lda #$ff
                sta i0

                jmp skip_no_16bit_complement_i0

no_16bit_complement_i0:

                lda #$00
                sta i0                  ;high .byte is 0 (the number is positive)



skip_no_16bit_complement_i0:

x_loop:         lda #$01
                sta k                   ;initializes counter for iterations

                ldx x_real              ;loads real part of starting value
                lda r0_tab, x
                sta r0+1

                bpl no_16bit_complement_r0

                ;performs 16 bit complement

                lda #$ff
                sta r0

                jmp skip_no16bit_complement_r0

no_16bit_complement_r0:

                lda #$00
                sta r0

skip_no16bit_complement_r0:

                lda #$00
                sta real
                sta real+1
                sta im
                sta im+1                ;clears out 16 bit real and imaginary parts



;starts iterations

iter_start:
                ; checks if real is 8 bit or not

                ;jmp skip_fast_real_square

                lda real
                beq fast_real_square
                lda real
                cmp #$ff
                beq take_complement_real_1



                jmp skip_fast_real_square

take_complement_real_1:

                lda real+1
                eor #$ff
                clc
                adc #1
                sta real_module_low
                jmp skip_real_1_module

fast_real_square:
                lda real+1
                sta real_module_low

skip_real_1_module:

                ldx real_module_low

                lda squares_low, x
                sta sum+1
                lda squares_high,x
                sta sum

                ;no offset divide, already in tables for squares

                lda sum
                sta r2

                lda sum+1
                sta r2+1



                jmp skip_slow_square_real

skip_fast_real_square:

                lda real
                sta multiplicand
                lda real+1
                sta multiplicand+1
                lda real
                sta multiplier
                lda real+1
                sta multiplier+1

                jsr multiply_ab

                lda sum
                sta r2                  ;high byte

                lda sum+1
                sta r2+1                ;low byte

                                        ;computes R2 = real * real (16 bit) !!test real*im
skip_slow_square_real:


                ; checks if imaginary is 8 bit or not

                ;jmp skip_fast_im_square


                lda im
                beq fast_im_square
                lda im
                cmp #$ff
                beq take_complement_im_1



                jmp skip_fast_im_square

take_complement_im_1:

                lda im+1
                eor #$ff
                clc
                adc #1
                sta im_module_low
                jmp skip_im_1_module

fast_im_square:
                lda im+1
                sta im_module_low



skip_im_1_module:

                ldx im_module_low

                lda squares_low, x
                sta sum+1
                lda squares_high,x
                sta sum

                ; no offset divide, already in tables for squares

                lda sum
                sta i2

                lda sum+1
                sta i2+1




                jmp skip_slow_square_im

skip_fast_im_square:



                lda im
                sta multiplicand
                lda im+1
                sta multiplicand+1
                lda im
                sta multiplier
                lda im+1
                sta multiplier+1

                jsr multiply_ab

                lda sum
                sta i2                  ;high byte

                lda sum+1
                sta i2+1                ;low byte

                                        ;computes I2 = im * im (16 bit)

skip_slow_square_im:

                clc
                lda r2+1
                adc i2+1
                sta r2_plus_i2+1

                lda i2
                adc r2
                sta r2_plus_i2          ;computes I2 + R2





                ;4 * offset is 4 * 64 = 256
                ;if 256 < r2_plus_i2 then mf = 0:rn = k-1: goto ...
                ;as we need greater than (NOT including equal), we must revert the condition
                ;so that we can use BCC

                lda #>256
                cmp r2_plus_i2
                bcc no_mandelbrot_set
                bne skip_no_mandelbrot_set
                lda #<256
                cmp r2_plus_i2+1
                bcc no_mandelbrot_set   ;16 bit comparison, mandelbrot set condition

                jmp skip_no_mandelbrot_set

no_mandelbrot_set:

                lda x_real
                ;asl
                sta xp+1

                lda #$00
                sta xp

                clc
;                lda xp+1
;                adc #34         ;must be even
;                sta xp+1
;                bcc skip_inc_hi_xp
                                ;instead of "adc #$00"
;                inc xp

skip_inc_hi_xp:
                lda y_im
                sta yp

                lda #(SCREEN_Y-1);
                sec
                sbc yp
                sta yp_mirrored ;computes mirrored y coordinate for plotting

                dec k

                lda k
                cmp #9
                bcs no_adjust   ;don't set colors of very outer points

                lda #2
                sta k

no_adjust:      ldx k
                lda color_table1,x
;                beq skip_plot1
                pha

                ldx xp+1
                ldy yp
                jsr vdp_mode7_set_pixel        ;no mandelbrot set = plot first bit of multicolor point

                pla
                ldx xp+1
                ldy yp_mirrored
                jsr vdp_mode7_set_pixel        ;plots mirrored point

skip_plot1:
;                ldx k

;                lda color_table2,x
;                beq skip_plot2

;                inc xp+1        ;only low byte is enough, since steps are 0 > 1... 254> 255
                                ;255 + 1 does not take place

;                ldx k
;                lda color_table2,x
;                jsr plot        ;no mandelbrot set = plot second bit of multicolor point

;                lda yp_mirrored ;mirroring of second point (same mirroring as the first one)
;                sta yp

;                jsr plot        ;plots mirrored point

                ;no need to restore old value of yp here, as yp value is determined before each plot
skip_plot2:

                jmp next_loop


skip_no_mandelbrot_set:

                ; selects between 8 bit multiplication or 16 bit

                lda real
                beq check_other         ;if high byte of real is 0, then it is 8 bit, then check other factor

                cmp #$ff
                beq check_other         ;if high byte of real is $ff, it is 8 bit negative, then check other factor

                jmp slow_multiply
                                        ;if it is not 0 nor $ff, then it is 16 bit so use 16 bit multiply
check_other:     lda im
                beq fast_multiply       ;if high byte of imaginary is 0, at this point both factors are 8 bit
                                        ;so 8 bit faster multiply can be performed

                cmp #$ff
                beq fast_multiply       ;if high byte of imaginary is $ff, then it is an 8 bit negative number
                                        ;at this point 8 bit faster multiply can be performed

                jmp slow_multiply       ;if either one or both factors are not 8 bit, then perform 16 bit multiply


                ; COMPUTES I = 2 * R * I using 8 bit multiplication (offset is 32 so it actually performs R * I)

fast_multiply:   lda real+1
                sta multiplicand8
                lda im+1
                sta multiplier8

                jsr multiply_ab8

                lda multiplier8
                sta im
                lda sum8
                sta im+1                ;I = R * I


                jmp skip_slow_multiply



                ; COMPUTES I = ((R * I)*2) + I0(which is 2 * real * im + i0)


slow_multiply:


                lda real
                sta multiplicand
                lda real+1
                sta multiplicand+1
                lda im
                sta multiplier
                lda im+1
                sta multiplier+1

                jsr multiply_ab

                lda sum
                sta im
                lda sum+1
                sta im+1                ; I = R * I

                asl im+1
                rol im                  ; I = 2 * R * I         ;multiplies by two after R * I so that
                                                                ;factors for multiplication are smaller


skip_slow_multiply:

                clc

                lda im+1
                adc i0+1
                sta im+1

                lda im
                adc i0
                sta im                  ; I = I + i0 = (2 * R) * I + i0



                ; computes R = R2-I2 + r0

                sec
                lda r2+1
                sbc i2+1
                sta real+1

                lda r2
                sbc i2
                sta real                ; R = R2 - I2


                clc
                lda real+1
                adc r0+1
                sta real+1

                lda real
                adc r0
                sta real                ; R = R + r0 = R2-I2 +r0

                inc k

                lda k
                cmp #MAX_ITER               ; number of iterations
                bne jump_iter_start



mandelbrot_set:
                ; should plot mandelbrot set point = don't plot on hi-res bitmap

                jmp next_loop

jump_iter_start: jmp iter_start


next_loop:

                inc x_real

continue:       lda x_real
                cmp #(SCREEN_X-1)
                bne x_loop_jump              ;next x loop (x has been already incremented). replaced bne with bcc!

                lda #$00
                sta x_real                   ;resets x counter

                inc y_im

                lda y_im
                cmp #(SCREEN_Y>>1)                     ;y is halved for mirroring!
                bne y_loop_jump              ;next y loop

;end:           jmp end

               cli
:              jsr fetchkey
               cmp #KEY_ESCAPE
               bne :-
               jsr krn_textui_init
               jmp (retvec)

x_loop_jump:   jmp x_loop

y_loop_jump:   jmp y_loop


                ; routine: signed 16 bit multiply - "16 bit" result (lower bytes of result discarded)



multiply_ab:    lda	#$00
		          sta	sum
                sta     sum+1

                sta     multiplicand_sign
                                        ;multiplicand sign positive
                sta     multiplier_sign ;multiplier sign positive

		ldx	#16		;number of bits

                lda     multiplicand    ;checks sign on high byte
                bpl     skip_multiplicand_comp

                sec

                lda     #<65536
                sbc     multiplicand+1
                sta     multiplicand+1  ;takes complement of multiplicand (low byte first)
                lda     #>65536
                sbc     multiplicand
                sta     multiplicand    ;high byte


                inc     multiplicand_sign
                                        ;multiplicand sign set to negative


skip_multiplicand_comp:

                lda     multiplier
                bpl     loop            ;checks sign on high byte

                sec

                lda     #<65536
                sbc     multiplier+1
                sta     multiplier+1    ;takes complement of multiplier (low byte first)
                lda     #>65536
                sbc     multiplier
                sta     multiplier      ;high byte



                inc     multiplier_sign
                                        ;multiplier sign set to negative

loop:
		asl	sum+1
                rol     sum
		rol	multiplier+1
                rol     multiplier
		bcc	skip_add


		clc
		lda	sum+1
		adc	multiplicand+1
                sta     sum+1
                lda     sum
                adc     multiplicand
                sta     sum


skip_add:
      dex
		bne	loop

                                        ;sum is high bite, sum+1 is lower byte
                                        ;lower bytes are simply discarded

                ; divide by offset (64)

                lsr sum
                ror sum+1
                lsr sum
                ror sum+1
                lsr sum
                ror sum+1
                lsr sum
                ror sum+1
                lsr sum
                ror sum+1
                lsr sum
                ror sum+1


                ; sign of product evaluation

                lda multiplicand_sign
                eor multiplier_sign


                beq skip_product_complement
                                        ;if product is positive, skip product complement

                sec
                lda #< 65536
                sbc sum+1
                sta sum+1
                lda #> 65536
                sbc sum
                sta sum          ;takes 2 complement of product (16 bit)



skip_product_complement:
		rts



                ;SUBROUTINE: computes 2 * R * I (R * I with offset 32) using 8 bit numbers when possible

multiply_ab8:	lda	#$00
		sta	sum8

                sta     multiplicand_sign8
                                        ;multiplicand8 sign positive
                sta     multiplier_sign8 ;multiplier8 sign positive

		ldx	#8		;number of bits

                lda     multiplicand8    ;checks sign on high byte
                bpl     skip_multiplicand_comp8

                sec

                lda     #<256
                sbc     multiplicand8
                sta     multiplicand8  ;takes complement of multiplicand8

                inc     multiplicand_sign8
                                        ;multiplicand8 sign set to negative

skip_multiplicand_comp8:

                lda     multiplier8
                bpl     loop8            ;checks sign on high byte

                sec

                lda     #<256
                sbc     multiplier8
                sta     multiplier8      ;takes complement of multiplier8


                inc     multiplier_sign8
                                        ;multiplier8 sign set to negative

loop8:
		asl	sum8
		rol	multiplier8
		bcc	skip_add8


		clc
		lda	sum8
		adc	multiplicand8
                sta     sum8
                lda     multiplier8
                bcc     skip_add8
                inc     multiplier8


skip_add8:	dex
		bne	loop8

                                        ;sum8 is high bite, sum8+1 is lower byte
                                        ;lower bytes are simply discarded

                ; divide by offset (32, 2*R*I /64 = R*I/32)


                lsr multiplier8
                ror sum8
                lsr multiplier8
                ror sum8
                lsr multiplier8
                ror sum8
                lsr multiplier8
                ror sum8
                lsr multiplier8
                ror sum8                 ;/32


                ; sign of product evaluation

                lda multiplicand_sign8
                eor multiplier_sign8


                beq skip_product_complement8
                                        ;if product is positive, skip product complement

                sec
                lda #< 65536
                sbc sum8
                sta sum8
                lda #> 65536
                sbc multiplier8
                sta multiplier8         ;takes 2 complement of product (16 bit)



skip_product_complement8:
		rts


                ;storage locations for 16 bit multiply


multiplicand_sign8:
                .byte    0
multiplier_sign8:
                .byte    0

multiplicand8: .byte	0
multiplier8:	.byte	0               ;high .byte of product
sum8:		.byte	0               ;low .byte of product


;subroutine: plot a point (codebase64.org)

plot:
                ;bmpscreen = start of bitmap screen
                ;byteaddr = address of the byte where the point to plot lies

                ldx xp+1
                ldy yp
                jmp vdp_mode7_set_pixel

; clear bitmap screen
clear_screen:
      ldy #0
      jsr vdp_mode7_blank

      rts

                ;storage locations for plot routine


                xp:		.byte	0,0
                yp:		.byte	0
                bit_table:	.byte	128,64,32,16,8,4,2,1
                temp:		.byte	0
                ;temp2		.byte	0,0
                byteaddr_y:	.byte	0,0
                yp_old:		.byte	0
                xp_old:		.byte	0,0


                ;storage locations for 16 bit multiply

multiplicand:	.byte	0,0
multiplier:	   .byte	0,0             ;high bytes of product ?
sum:		      .byte	0,0             ;low bytes of product (unused)?
multiplicand_sign:
                .byte    0
multiplier_sign: .byte    0
product_sign:    .byte    0


                ;result on multiplier and sum



                ;storage locations for main program


.bss

i0:              .byte    0,0
r0:              .byte    0,0

y_im:            .byte    0
x_real:          .byte    0


mf:              .byte    0

real:            .byte    0,0
im:              .byte    0,0

r2:              .byte    0,0
i2:              .byte    0,0

r2_plus_i2:      .byte    0,0


k:               .byte    0

;screen_count    .byte    0

temp1:           .byte    0

temp2:           .byte    0,0

to_square:       .byte    0

real_module_low: .byte    0
im_module_low:   .byte    0

yp_copy:         .byte    0
yp_mirrored:     .byte    0


                ; tables

                ; 01 = 8
                ; 10 = 9
                ; 11 = 7

_r=1
_g=1
_b=1

.data
color_table1:
   .repeat MAX_ITER,i
;      vdp_rgb <((i*_r)),<((i*_g)),<((i*_b))
      .byte (32+i)
   .endrep

                ; fractal input values tables should be 16 bit in two's complement form - they are 8 bit complement instead
                ; so, 8 bit 2's complement numbers are converted to 16 bit 2's complement on the code

i0_tab:         .byte  185 , 186 , 187 , 187 , 188
                .byte  189 , 189 , 190 , 191 , 191
                .byte  192 , 193 , 194 , 194 , 195
                .byte  196 , 196 , 197 , 198 , 198
                .byte  199 , 200 , 201 , 201 , 202
                .byte  203 , 203 , 204 , 205 , 206
                .byte  206 , 207 , 208 , 208 , 209
                .byte  210 , 210 , 211 , 212 , 213
                .byte  213 , 214 , 215 , 215 , 216
                .byte  217 , 217 , 218 , 219 , 220
                .byte  220 , 221 , 222 , 222 , 223
                .byte  224 , 225 , 225 , 226 , 227
                .byte  227 , 228 , 229 , 229 , 230
                .byte  231 , 232 , 232 , 233 , 234
                .byte  234 , 235 , 236 , 236 , 237
                .byte  238 , 239 , 239 , 240 , 241
                .byte  241 , 242 , 243 , 244 , 244
                .byte  245 , 246 , 246 , 247 , 248
                .byte  248 , 249 , 250 , 251 , 251
                .byte  252 , 253 , 253 , 254 , 255
                ;***************************

                ;other values are now omitted as the fractal is mirrored


r0_tab:
               .repeat (SCREEN_X>>1)+60,i
                  .byte (255-(SCREEN_X>>1+60))+i
               .endrep
               .repeat (SCREEN_X>>2),i
                  .byte 0+i
               .endrep

                .byte  129 , 131 , 132 , 133 , 134
                .byte  136 , 137 , 138 , 140 , 141
                .byte  142 , 143 , 145 , 146 , 147
                .byte  148 , 150 , 151 , 152 , 153
                .byte  155 , 156 , 157 , 159 , 160
                .byte  161 , 162 , 164 , 165 , 166
                .byte  167 , 169 , 170 , 171 , 172
                .byte  174 , 175 , 176 , 177 , 179
                .byte  180 , 181 , 183 , 184 , 185
                .byte  186 , 188 , 189 , 190 , 191
                .byte  193 , 194 , 195 , 196 , 198
                .byte  199 , 200 , 202 , 203 , 204
                .byte  205 , 207 , 208 , 209 , 210
                .byte  212 , 213 , 214 , 215 , 217
                .byte  218 , 219 , 220 , 222 , 223
                .byte  224 , 226 , 227 , 228 , 229
                .byte  231 , 232 , 233 , 234 , 236
                .byte  237 , 238 , 239 , 241 , 242
                .byte  243 , 245 , 246 , 247 , 248
                .byte  250 , 251 , 252 , 253 , 255
                ;***************************
                .byte  0 , 1 , 2 , 4 , 5
                .byte  6 , 7 , 9 , 10 , 11
                .byte  13 , 14 , 15 , 16 , 18
                .byte  19 , 20 , 21 , 23 , 24
                .byte  25 , 26 , 28 , 29 , 30


;squares 0...255 high bytes

squares_high:
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
;***************************

.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 1 , 1 , 1
.byte  1 , 1 , 2 , 2 , 2
.byte  2 , 2 , 2 , 2 , 2
.byte  2 , 2 , 2 , 2 , 2
.byte  2 , 2 , 2 , 2 , 2
;***************************

.byte  2 , 2 , 2 , 2 , 2
.byte  2 , 2 , 2 , 2 , 2
.byte  2 , 2 , 2 , 2 , 2
.byte  2 , 2 , 2 , 2 , 2
.byte  2 , 2 , 3 , 3 , 3
.byte  3 , 3 , 3 , 3 , 3
.byte  3 , 3 , 3 , 3 , 3
.byte  3 , 3 , 3 , 3 , 3
.byte  3 , 3 , 3 , 3 , 3
.byte  3 , 3 , 3 , 3 , 3
.byte  3 , 3 , 3 , 3 , 3
.byte  3

;***************************

;squares 0...255 low bytes

squares_low:

.byte  0 , 0 , 0 , 0 , 0
.byte  0 , 0 , 0 , 1 , 1
.byte  1 , 1 , 2 , 2 , 3
.byte  3 , 4 , 4 , 5 , 5
.byte  6 , 6 , 7 , 8 , 9
.byte  9 , 10 , 11 , 12 , 13
.byte  14 , 15 , 16 , 17 , 18
.byte  19 , 20 , 21 , 22 , 23
.byte  25 , 26 , 27 , 28 , 30
.byte  31 , 33 , 34 , 36 , 37
.byte  39 , 40 , 42 , 43 , 45
.byte  47 , 49 , 50 , 52 , 54
.byte  56 , 58 , 60 , 62 , 64
.byte  66 , 68 , 70 , 72 , 74
.byte  76 , 78 , 81 , 83 , 85
.byte  87 , 90 , 92 , 95 , 97
.byte  100 , 102 , 105 , 107 , 110
.byte  112 , 115 , 118 , 121 , 123
.byte  126 , 129 , 132 , 135 , 138
.byte  141 , 144 , 147 , 150 , 153
;***************************


.byte  156 , 159 , 162 , 165 , 169
.byte  172 , 175 , 178 , 182 , 185
.byte  189 , 192 , 196 , 199 , 203
.byte  206 , 210 , 213 , 217 , 221
.byte  225 , 228 , 232 , 236 , 240
.byte  244 , 248 , 252 , 0 , 4
.byte  8 , 12 , 16 , 20 , 24
.byte  28 , 33 , 37 , 41 , 45
.byte  50 , 54 , 59 , 63 , 68
.byte  72 , 77 , 81 , 86 , 90
.byte  95 , 100 , 105 , 109 , 114
.byte  119 , 124 , 129 , 134 , 139
.byte  144 , 149 , 154 , 159 , 164
.byte  169 , 174 , 179 , 185 , 190
.byte  195 , 200 , 206 , 211 , 217
.byte  222 , 228 , 233 , 239 , 244
.byte  250 , 255 , 5 , 11 , 17
.byte  22 , 28 , 34 , 40 , 46
.byte  52 , 58 , 64 , 70 , 76
.byte  82 , 88 , 94 , 100 , 106
;***************************

.byte  113 , 119 , 125 , 131 , 138
.byte  144 , 151 , 157 , 164 , 170
.byte  177 , 183 , 190 , 196 , 203
.byte  210 , 217 , 223 , 230 , 237
.byte  244 , 251 , 2 , 9 , 16
.byte  23 , 30 , 37 , 44 , 51
.byte  58 , 65 , 73 , 80 , 87
.byte  94 , 102 , 109 , 117 , 124
.byte  132 , 139 , 147 , 154 , 162
.byte  169 , 177 , 185 , 193 , 200
.byte  208 , 216 , 224 , 232 , 240
.byte  248
