;Use SNES controllers connected to the Steckschwein user port:
;
; /---------------------
;| 7  6  5 | 4  3  2  1 |
; \---------------------
;
;Pin Description
;1   +5V
;2  CLK
;3  LATCH
;4  DATA
;5  –
;6  –
;7  GND
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
;controller1 = $00 ; 3 bytes
;controller2 = $03 ; 3 bytes

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

