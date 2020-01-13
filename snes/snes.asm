.include "steckos.inc"
.include "via.inc"
.include "joystick.inc"
appstart $1000
.export char_out=krn_chrout
.import hexout


;Use SNES controllers connected to the Steckschwein user port:
;
; /---------------------
;| 7  6  5 | 4  3  2  1 |
; \---------------------
;
;Pin Description
;1   +5V
;2 	CLK
;3 	LATCH
;4 	DATA
;5 	–
;6 	–
;7 	GND
;
;User Port:
;          |---PA2 (DATA1)
;          | |-PA0 (CLK)
;o o X o o o o
;o o X o o o o
;          | |-PA1 (LATCH)
;          |---PA3 (DATA2)
;

nes_data = via1porta
nes_ddr  = via1ddra
; zero page
controller1 = $00 ; 3 bytes
controller2 = $03 ; 3 bytes

bit_clk   = %00000001 ; PA0 : CLK   (both controllers)
bit_latch = %00000010 ; PA1 : LATCH (both controllers)
bit_data1 = %00000100 ; PA2 : DATA  (controller #1)
bit_data2 = %00001000 ; PA3 : DATA  (controller #2)

; byte 0:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;         NES  | A | B |SEL|STA|UP |DN |LT |RT |
;         SNES | B | Y |SEL|STA|UP |DN |LT |RT |
;
; byte 1:      | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;         NES  | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
;         SNES | A | X | L | R | 1 | 1 | 1 | 1 |
; byte 2:
;         $00 = controller present
;         $FF = controller not present

snes_button_b       = %01111111
snes_button_y       = %10111111
snes_button_sel     = %11011111
snes_button_sta     = %11101111
snes_up             = %11110111
snes_down           = %11111011
snes_left           = %11111101
snes_right          = %11111110



main:
    joy_off ; disable joystick ports

loop:
    jsr query_controllers
    ;jsr hexout
    ;lda controller1+1
    ;jsr hexout
    ;lda controller1+2
    ;jsr hexout
    rol controller1
    bcs foo1
    lda #'B'
    jsr char_out
foo1:
    rol controller1
    bcs foo2
    lda #'Y'
    jsr char_out
foo2:
    rol controller1
    bcs foo3
    lda #'S'
    jsr char_out
foo3:
    rol controller1
    bcs foo4
    lda #'T'
    jsr char_out
foo4:
    rol controller1
    bcs foo5
    lda #'U'
    jsr char_out
foo5:
    rol controller1
    bcs foo6
    lda #'D'
    jsr char_out
foo6:
    rol controller1
    bcs foo7
    lda #'L'
    jsr char_out
foo7:
    rol controller1
    bcs foo8
    lda #'R'
    jsr char_out
foo8:
    rol controller1+1
    bcs foo9
    lda #'A'
    jsr char_out
foo9:
    rol controller1+1
    bcs foo10
    lda #'X'
    jsr char_out
foo10:
    rol controller1+1
    bcs foo11
    lda #'l'
    jsr char_out
foo11:
    rol controller1+1
    bcs foo12
    lda #'r'
    jsr char_out
foo12:

;    crlf
    jmp loop



query_controllers:
    lda #$ff-bit_data1-bit_data2
    sta nes_ddr
    lda #$00
    sta nes_data

    ; pulse latch
    lda #bit_latch
    sta nes_data
    lda #0
    sta nes_data

    ; read 3x 8 bits
    ldx #0
l2: ldy #8
l1: lda nes_data
    cmp #bit_data2
    rol controller2,x
    and #bit_data1
    cmp #bit_data1
    rol controller1,x
    ;lda #bit_clk
    ;sta nes_data
    inc nes_data
    ;lda #0
    ;sta nes_data
    stz nes_data

    dey
    bne l1
    inx
    cpx #3
    bne l2
    rts

