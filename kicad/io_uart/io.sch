EESchema Schematic File Version 2
LIBS:io-rescue
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:65xxx
LIBS:ttl_ieee
LIBS:mini_din
LIBS:dallas-rtc
LIBS:lp2950l
LIBS:osc
LIBS:io-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 7
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 10300 650  700  2150
U 54287A69
F0 "Connector" 60
F1 "50pin_connector.sch" 60
F2 "A0" I L 10300 750 60 
F3 "A2" I L 10300 950 60 
F4 "A3" I L 10300 1050 60 
F5 "A1" I L 10300 850 60 
F6 "D0" B L 10300 1800 60 
F7 "D1" B L 10300 1900 60 
F8 "D2" B L 10300 2000 60 
F9 "D3" B L 10300 2100 60 
F10 "D4" B L 10300 2200 60 
F11 "D5" B L 10300 2300 60 
F12 "D6" B L 10300 2400 60 
F13 "D7" B L 10300 2500 60 
F14 "A4" I L 10300 1150 60 
F15 "A5" I L 10300 1250 60 
F16 "RESET_TRIG" I L 10300 2700 60 
$EndSheet
Entry Wire Line
	10100 650  10200 750 
Entry Wire Line
	10100 750  10200 850 
Entry Wire Line
	10100 850  10200 950 
Entry Wire Line
	10100 950  10200 1050
Entry Wire Line
	10100 1700 10200 1800
Entry Wire Line
	10100 1800 10200 1900
Entry Wire Line
	10100 1900 10200 2000
Entry Wire Line
	10100 2000 10200 2100
Entry Wire Line
	10100 2100 10200 2200
Entry Wire Line
	10100 2200 10200 2300
Entry Wire Line
	10100 2300 10200 2400
Entry Wire Line
	10100 2400 10200 2500
Text Label 10200 750  0    60   ~ 0
A0
Text Label 10200 850  0    60   ~ 0
A1
Text Label 10200 950  0    60   ~ 0
A2
Text Label 10200 1050 0    60   ~ 0
A3
Text Label 10200 1800 0    60   ~ 0
D0
Text Label 10200 1900 0    60   ~ 0
D1
Text Label 10200 2000 0    60   ~ 0
D2
Text Label 10200 2100 0    60   ~ 0
D3
Text Label 10200 2200 0    60   ~ 0
D4
Text Label 10200 2300 0    60   ~ 0
D5
Text Label 10200 2400 0    60   ~ 0
D6
Text Label 10200 2500 0    60   ~ 0
D7
Entry Wire Line
	4700 2450 4800 2550
Entry Wire Line
	4700 2550 4800 2650
Entry Wire Line
	4700 2650 4800 2750
Entry Wire Line
	4700 2750 4800 2850
Entry Wire Line
	4700 2850 4800 2950
Entry Wire Line
	4700 2950 4800 3050
Entry Wire Line
	4700 3050 4800 3150
Entry Wire Line
	4700 3150 4800 3250
Text Label 4800 2550 0    60   ~ 0
D0
Text Label 4800 2650 0    60   ~ 0
D1
Text Label 4800 2750 0    60   ~ 0
D2
Text Label 4800 2850 0    60   ~ 0
D3
Text Label 4800 2950 0    60   ~ 0
D4
Text Label 4800 3050 0    60   ~ 0
D5
Text Label 4800 3150 0    60   ~ 0
D6
Text Label 4800 3250 0    60   ~ 0
D7
Entry Wire Line
	4700 3350 4800 3450
Entry Wire Line
	4700 3450 4800 3550
Entry Wire Line
	4700 3550 4800 3650
Entry Wire Line
	4700 3650 4800 3750
Text Label 4800 3450 0    60   ~ 0
A0
Text Label 4800 3550 0    60   ~ 0
A1
Text Label 4800 3650 0    60   ~ 0
A2
Text Label 4800 3750 0    60   ~ 0
A3
Text GLabel 4800 3950 0    60   Input ~ 0
/RESET
Text GLabel 4800 4050 0    60   Input ~ 0
/IRQ
Text GLabel 4800 4150 0    60   Input ~ 0
/RW
Text GLabel 4800 4250 0    60   Input ~ 0
PHI2
$Comp
L VCC #PWR01
U 1 1 5428C2B0
P 4850 4550
F 0 "#PWR01" H 4850 4650 30  0001 C CNN
F 1 "VCC" H 4850 4650 30  0000 C CNN
F 2 "" H 4850 4550 60  0000 C CNN
F 3 "" H 4850 4550 60  0000 C CNN
	1    4850 4550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5428C330
P 4850 5150
F 0 "#PWR02" H 4850 5150 30  0001 C CNN
F 1 "GND" H 4850 5080 30  0001 C CNN
F 2 "" H 4850 5150 60  0000 C CNN
F 3 "" H 4850 5150 60  0000 C CNN
	1    4850 5150
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR03
U 1 1 5428C3FC
P 4350 6950
F 0 "#PWR03" H 4350 7050 30  0001 C CNN
F 1 "VCC" H 4350 7050 30  0000 C CNN
F 2 "" H 4350 6950 60  0000 C CNN
F 3 "" H 4350 6950 60  0000 C CNN
	1    4350 6950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 5428C42D
P 4350 7400
F 0 "#PWR04" H 4350 7400 30  0001 C CNN
F 1 "GND" H 4350 7330 30  0001 C CNN
F 2 "" H 4350 7400 60  0000 C CNN
F 3 "" H 4350 7400 60  0000 C CNN
	1    4350 7400
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5428C484
P 4350 7150
F 0 "C1" H 4350 7250 40  0000 L CNN
F 1 "100nF" H 4356 7065 40  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L4_W2.5_P2.5" H 4388 7000 30  0001 C CNN
F 3 "" H 4350 7150 60  0000 C CNN
	1    4350 7150
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR05
U 1 1 5428D273
P 6250 4900
F 0 "#PWR05" H 6250 5000 30  0001 C CNN
F 1 "VCC" H 6250 5000 30  0000 C CNN
F 2 "" H 6250 4900 60  0000 C CNN
F 3 "" H 6250 4900 60  0000 C CNN
	1    6250 4900
	1    0    0    -1  
$EndComp
Text GLabel 6350 5050 2    60   Input ~ 0
/CS_VIA
$Sheet
S 1300 750  1000 1350
U 542907F9
F0 "SD Card" 60
F1 "sd_card.sch" 60
F2 "SPI_CLK" I L 1300 850 60 
F3 "SPI_MOSI" I L 1300 1000 60 
F4 "SPI_MISO" O L 1300 1150 60 
F5 "SPI_SS1" I L 1300 1300 60 
F6 "SD_CARD_DETECT" O L 1300 1750 60 
F7 "SD_WRITE_PROTECT" O L 1300 1600 60 
$EndSheet
Text Label 6500 3450 0    60   ~ 0
SPI_CLK
Text Label 6500 3550 0    60   ~ 0
~SPI_SS1
Text Label 6500 3650 0    60   ~ 0
~SPI_SS2
Text Label 6500 4150 0    60   ~ 0
SPI_MOSI
Text Label 6500 4750 0    60   ~ 0
SPI_MISO
$Comp
L C C2
U 1 1 545C1C49
P 4650 7150
F 0 "C2" H 4650 7250 40  0000 L CNN
F 1 "100nF" H 4656 7065 40  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L4_W2.5_P2.5" H 4688 7000 30  0001 C CNN
F 3 "" H 4650 7150 60  0000 C CNN
	1    4650 7150
	1    0    0    -1  
$EndComp
Text Label 6500 3750 0    60   ~ 0
~SPI_SS3
$Comp
L C C3
U 1 1 548DF92D
P 4950 7150
F 0 "C3" H 4950 7250 40  0000 L CNN
F 1 "100nF" H 4956 7065 40  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L4_W2.5_P2.5" H 4988 7000 30  0001 C CNN
F 3 "" H 4950 7150 60  0000 C CNN
	1    4950 7150
	1    0    0    -1  
$EndComp
NoConn ~ 10300 1150
NoConn ~ 10300 1250
Text Label 9750 2700 0    60   ~ 0
RESET_TRIG
Text Label 6500 3850 0    60   ~ 0
~SPI_SS4
Text Label 6500 3950 0    60   ~ 0
~SD_WRITE_PROTECT
Text Label 6500 4050 0    60   ~ 0
~SD_CARD_DETECT
$Comp
L CP C4
U 1 1 54B14D65
P 5250 7150
F 0 "C4" H 5250 7250 40  0000 L CNN
F 1 "100µF" H 5256 7065 40  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L11.5_P3.5" H 5288 7000 30  0001 C CNN
F 3 "" H 5250 7150 60  0000 C CNN
	1    5250 7150
	1    0    0    -1  
$EndComp
$Comp
L CONN_02X03 P2
U 1 1 54B176A0
P 1600 4950
F 0 "P2" H 1600 5150 50  0000 C CNN
F 1 "SPI4" H 1600 4750 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 1600 3750 60  0001 C CNN
F 3 "" H 1600 3750 60  0000 C CNN
	1    1600 4950
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR013
U 1 1 54B17C97
P 1950 4700
F 0 "#PWR013" H 1950 4800 30  0001 C CNN
F 1 "VCC" H 1950 4800 30  0000 C CNN
F 2 "" H 1950 4700 60  0000 C CNN
F 3 "" H 1950 4700 60  0000 C CNN
	1    1950 4700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR014
U 1 1 54B17DD5
P 1950 5150
F 0 "#PWR014" H 1950 5150 30  0001 C CNN
F 1 "GND" H 1950 5080 30  0001 C CNN
F 2 "" H 1950 5150 60  0000 C CNN
F 3 "" H 1950 5150 60  0000 C CNN
	1    1950 5150
	1    0    0    -1  
$EndComp
Text Label 1000 4850 0    60   ~ 0
SPI_MISO
Text Label 1000 4950 0    60   ~ 0
SPI_CLK
Text Label 1000 5050 0    60   ~ 0
~SPI_SS4
$Comp
L C C5
U 1 1 54B17E82
P 5550 7150
F 0 "C5" H 5550 7250 40  0000 L CNN
F 1 "100nF" H 5556 7065 40  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L4_W2.5_P2.5" H 5588 7000 30  0001 C CNN
F 3 "" H 5550 7150 60  0000 C CNN
	1    5550 7150
	1    0    0    -1  
$EndComp
$Comp
L G65SC22P U1
U 1 1 542879F7
P 5500 3550
F 0 "U1" H 5500 3550 50  0000 L BNN
F 1 "G65SC22P" H 5100 1850 50  0000 L BNN
F 2 "Housings_DIP:DIP-40_W15.24mm_LongPads" H 5500 3700 50  0001 C CNN
F 3 "" H 5500 3550 60  0000 C CNN
	1    5500 3550
	1    0    0    -1  
$EndComp
Text Label 6200 2550 0    60   ~ 0
PA0
Text Label 6200 2650 0    60   ~ 0
PA1
Text Label 6200 2750 0    60   ~ 0
PA2
Text Label 6200 2850 0    60   ~ 0
PA3
Text Label 6200 2950 0    60   ~ 0
PA4
Text Label 6350 4350 0    60   ~ 0
CA1
Text Label 6350 4450 0    60   ~ 0
CA2
Wire Wire Line
	6100 4150 6900 4150
Wire Wire Line
	6100 3650 6900 3650
Wire Wire Line
	6100 3550 6900 3550
Wire Wire Line
	6100 3450 6900 3450
Connection ~ 4350 7300
Connection ~ 4650 7300
Connection ~ 4950 7300
Connection ~ 4950 7000
Connection ~ 4650 7000
Connection ~ 4350 7000
Wire Wire Line
	4350 7300 5550 7300
Wire Wire Line
	4350 7000 5550 7000
Wire Wire Line
	6100 5050 6350 5050
Wire Wire Line
	6100 4750 7450 4750
Wire Wire Line
	6250 4650 6100 4650
Wire Wire Line
	4350 6950 4350 7000
Wire Wire Line
	4350 7300 4350 7400
Wire Wire Line
	4850 5050 4850 5150
Wire Wire Line
	4900 5050 4850 5050
Wire Wire Line
	4850 4650 4900 4650
Wire Wire Line
	4850 4550 4850 4650
Wire Wire Line
	4800 4250 4900 4250
Wire Wire Line
	4800 4150 4900 4150
Wire Wire Line
	4800 4050 4900 4050
Wire Wire Line
	4800 3950 4900 3950
Wire Wire Line
	4800 3750 4900 3750
Wire Wire Line
	4900 3650 4800 3650
Wire Wire Line
	4800 3550 4900 3550
Wire Wire Line
	4800 3450 4900 3450
Wire Bus Line
	4700 3250 4700 3750
Wire Wire Line
	4900 3250 4800 3250
Wire Wire Line
	4800 3150 4900 3150
Wire Wire Line
	4900 3050 4800 3050
Wire Wire Line
	4800 2950 4900 2950
Wire Wire Line
	4900 2850 4800 2850
Wire Wire Line
	4800 2750 4900 2750
Wire Wire Line
	4900 2650 4800 2650
Wire Wire Line
	4800 2550 4900 2550
Wire Bus Line
	4700 2350 4700 3150
Wire Wire Line
	10300 2500 10200 2500
Wire Wire Line
	10200 2400 10300 2400
Wire Wire Line
	10300 2300 10200 2300
Wire Wire Line
	10200 2200 10300 2200
Wire Wire Line
	10300 2100 10200 2100
Wire Wire Line
	10200 2000 10300 2000
Wire Wire Line
	10300 1900 10200 1900
Wire Wire Line
	10200 1800 10300 1800
Wire Bus Line
	10100 1600 10100 2400
Wire Wire Line
	10200 1050 10300 1050
Wire Wire Line
	10300 950  10200 950 
Wire Wire Line
	10200 850  10300 850 
Wire Wire Line
	10200 750  10300 750 
Wire Bus Line
	10100 550  10100 1050
Wire Wire Line
	6250 4650 6250 3450
Connection ~ 6250 3450
Wire Wire Line
	6100 3750 6900 3750
Wire Wire Line
	9700 2700 10300 2700
Wire Wire Line
	6100 3850 6900 3850
Wire Wire Line
	6100 3950 6900 3950
Wire Wire Line
	6100 4050 6900 4050
Wire Wire Line
	6100 4950 6250 4950
Wire Wire Line
	6250 4950 6250 4900
Wire Wire Line
	1850 5050 1950 5050
Wire Wire Line
	1950 5050 1950 5150
Wire Wire Line
	1850 4850 1950 4850
Wire Wire Line
	1950 4850 1950 4700
Wire Wire Line
	1850 4950 2150 4950
Wire Wire Line
	1350 4850 950  4850
Wire Wire Line
	950  4950 1350 4950
Wire Wire Line
	950  5050 1350 5050
Connection ~ 5250 7000
Connection ~ 5250 7300
Wire Wire Line
	6500 2750 6100 2750
Wire Wire Line
	6500 2850 6100 2850
Wire Wire Line
	6100 2950 6500 2950
Wire Wire Line
	6500 3250 6100 3250
Wire Wire Line
	6500 2550 6100 2550
Wire Wire Line
	6100 4350 6500 4350
Wire Wire Line
	6100 4450 6500 4450
Connection ~ 4900 2550
Connection ~ 4900 2650
Connection ~ 4900 2750
Connection ~ 4900 2850
Connection ~ 4900 2950
Connection ~ 4900 3050
Connection ~ 4900 3150
Connection ~ 4900 3250
Connection ~ 4900 3450
Connection ~ 4900 3550
Connection ~ 4900 3650
Connection ~ 4900 3750
Connection ~ 4900 3950
Connection ~ 4900 4050
Connection ~ 4900 4150
Connection ~ 4900 4250
Connection ~ 4900 4650
$Sheet
S 8050 650  750  1750
U 58B9FFEA
F0 "Uart" 60
F1 "uart.sch" 60
F2 "D0" B L 8050 1600 60 
F3 "D1" B L 8050 1700 60 
F4 "D2" B L 8050 1800 60 
F5 "D3" B L 8050 1900 60 
F6 "D4" B L 8050 2000 60 
F7 "D5" B L 8050 2100 60 
F8 "D6" B L 8050 2200 60 
F9 "D7" B L 8050 2300 60 
F10 "A0" I L 8050 800 60 
F11 "A1" I L 8050 900 60 
F12 "A2" I L 8050 1000 60 
F13 "/OUT1" O L 8050 1250 60 
$EndSheet
Entry Wire Line
	7850 1500 7950 1600
Entry Wire Line
	7850 1600 7950 1700
Entry Wire Line
	7850 1700 7950 1800
Entry Wire Line
	7850 1800 7950 1900
Entry Wire Line
	7850 1900 7950 2000
Entry Wire Line
	7850 2000 7950 2100
Entry Wire Line
	7850 2100 7950 2200
Entry Wire Line
	7850 2200 7950 2300
Text Label 7950 1600 0    60   ~ 0
D0
Text Label 7950 1700 0    60   ~ 0
D1
Text Label 7950 1800 0    60   ~ 0
D2
Text Label 7950 1900 0    60   ~ 0
D3
Text Label 7950 2000 0    60   ~ 0
D4
Text Label 7950 2100 0    60   ~ 0
D5
Text Label 7950 2200 0    60   ~ 0
D6
Text Label 7950 2300 0    60   ~ 0
D7
Wire Wire Line
	8050 2300 7950 2300
Wire Wire Line
	7950 2200 8050 2200
Wire Wire Line
	8050 2100 7950 2100
Wire Wire Line
	7950 2000 8050 2000
Wire Wire Line
	8050 1900 7950 1900
Wire Wire Line
	7950 1800 8050 1800
Wire Wire Line
	8050 1700 7950 1700
Wire Wire Line
	7950 1600 8050 1600
Wire Bus Line
	7850 1400 7850 2200
Entry Wire Line
	7850 700  7950 800 
Entry Wire Line
	7850 800  7950 900 
Entry Wire Line
	7850 900  7950 1000
Text Label 7950 800  0    60   ~ 0
A0
Text Label 7950 900  0    60   ~ 0
A1
Text Label 7950 1000 0    60   ~ 0
A2
Wire Wire Line
	8050 1000 7950 1000
Wire Wire Line
	7950 900  8050 900 
Wire Wire Line
	7950 800  8050 800 
Wire Bus Line
	7850 600  7850 1100
Text Label 2050 4950 0    60   ~ 0
SPI_MOSI
$Sheet
S 8300 5050 1100 1250
U 54318D23
F0 "Joystick Ports" 60
F1 "joystick.sch" 60
F2 "J_Right" I L 8300 5600 60 
F3 "J_Left" I L 8300 5450 60 
F4 "J_Up" I L 8300 5150 60 
F5 "J_Down" I L 8300 5300 60 
F6 "J_Fire" I L 8300 5750 60 
F7 "/JOYPORT_ENABLE" I L 8300 6000 60 
F8 "JOYPORT_SELECT" I L 8300 6200 60 
$EndSheet
Wire Wire Line
	8050 1250 7200 1250
Wire Wire Line
	8300 6000 7500 6000
$Comp
L CONN_02X06 P?
U 1 1 58E669F2
P 10450 5800
F 0 "P?" H 10450 6150 50  0000 C CNN
F 1 "USERPORT" H 10450 5450 50  0000 C CNN
F 2 "" H 10450 4600 50  0000 C CNN
F 3 "" H 10450 4600 50  0000 C CNN
	1    10450 5800
	1    0    0    -1  
$EndComp
$Comp
L R R?
U 1 1 58E669F9
P 10400 3750
F 0 "R?" V 10400 3700 50  0000 C CNN
F 1 "1k" V 10400 3800 50  0000 C CNN
F 2 "" V 10330 3750 50  0000 C CNN
F 3 "" H 10400 3750 50  0000 C CNN
	1    10400 3750
	0    1    1    0   
$EndComp
Wire Wire Line
	10550 4200 10950 4200
Wire Wire Line
	10550 4650 10950 4650
Wire Wire Line
	10550 4050 10950 4050
Wire Wire Line
	10550 3900 10950 3900
Wire Wire Line
	10550 4500 10950 4500
Wire Wire Line
	10550 4800 10950 4800
Wire Wire Line
	10550 4950 10950 4950
Wire Wire Line
	10550 5100 10950 5100
Wire Wire Line
	10200 5550 9850 5550
Wire Wire Line
	10700 5550 11000 5550
Wire Wire Line
	10200 5650 9850 5650
Wire Wire Line
	10700 5650 11000 5650
Wire Wire Line
	10200 5750 9850 5750
Wire Wire Line
	10700 5750 11000 5750
Wire Wire Line
	10200 5850 9850 5850
Wire Wire Line
	10700 5850 11000 5850
Wire Wire Line
	10200 5950 9850 5950
Wire Wire Line
	10700 5950 11000 5950
$Comp
L GND #PWR?
U 1 1 58E66B3D
P 10700 6250
F 0 "#PWR?" H 10700 6000 50  0001 C CNN
F 1 "GND" H 10700 6100 50  0000 C CNN
F 2 "" H 10700 6250 50  0000 C CNN
F 3 "" H 10700 6250 50  0000 C CNN
	1    10700 6250
	1    0    0    -1  
$EndComp
Wire Wire Line
	10700 6050 10700 6250
Text Label 7500 6000 0    60   ~ 0
/JOYPORT_ENABLE
Text Label 7200 1250 0    60   ~ 0
/JOYPORT_ENABLE
Wire Wire Line
	6100 3050 6500 3050
Wire Wire Line
	6100 3150 6500 3150
Wire Wire Line
	6100 2650 6500 2650
Text Label 6200 3050 0    60   ~ 0
PA5
Text Label 6200 3150 0    60   ~ 0
PA6
Text Label 6200 3250 0    60   ~ 0
PA7
Wire Wire Line
	10250 3750 9950 3750
Wire Wire Line
	10250 3900 9950 3900
Wire Wire Line
	9950 4050 10250 4050
Wire Wire Line
	9950 4200 10250 4200
Wire Wire Line
	9950 4350 10250 4350
Wire Wire Line
	9950 4500 10250 4500
Wire Wire Line
	9950 4650 10250 4650
Wire Wire Line
	9950 4800 10250 4800
Wire Wire Line
	9950 4950 10250 4950
Wire Wire Line
	9950 5100 10250 5100
Text Label 10000 3750 0    60   ~ 0
PA0
Text Label 10000 3900 0    60   ~ 0
PA1
Text Label 10000 4050 0    60   ~ 0
PA2
Text Label 10000 4200 0    60   ~ 0
PA3
Text Label 10000 4350 0    60   ~ 0
PA4
Text Label 10000 4500 0    60   ~ 0
PA5
Text Label 10000 4800 0    60   ~ 0
PA7
Text Label 10000 4650 0    60   ~ 0
PA6
Text Label 10000 4950 0    60   ~ 0
CA1
Text Label 10000 5100 0    60   ~ 0
CA2
$Comp
L VCC #PWR?
U 1 1 58E539E2
P 9750 5450
F 0 "#PWR?" H 9750 5550 30  0001 C CNN
F 1 "VCC" H 9750 5550 30  0000 C CNN
F 2 "" H 9750 5450 60  0000 C CNN
F 3 "" H 9750 5450 60  0000 C CNN
	1    9750 5450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 5450 9750 6050
Wire Wire Line
	9750 6050 10200 6050
Wire Wire Line
	10550 4350 10950 4350
Wire Wire Line
	10550 3750 10950 3750
Text Label 10700 3750 0    60   ~ 0
PA0'
Text Label 10700 3900 0    60   ~ 0
PA1'
Text Label 10700 4050 0    60   ~ 0
PA2'
Text Label 10700 4200 0    60   ~ 0
PA3'
Text Label 10700 4350 0    60   ~ 0
PA4'
Text Label 10700 4500 0    60   ~ 0
PA5'
Text Label 10700 4650 0    60   ~ 0
PA6'
Text Label 10700 4800 0    60   ~ 0
PA7'
Text Label 10700 4950 0    60   ~ 0
CA1'
Text Label 10700 5100 0    60   ~ 0
CA2'
Text Label 9950 5550 0    60   ~ 0
PA0'
Text Label 10750 5550 0    60   ~ 0
PA1'
Text Label 9950 5650 0    60   ~ 0
PA2'
Text Label 10750 5650 0    60   ~ 0
PA3'
Text Label 9950 5750 0    60   ~ 0
PA4'
Text Label 10750 5750 0    60   ~ 0
PA5'
Text Label 9950 5850 0    60   ~ 0
PA6'
Text Label 10750 5850 0    60   ~ 0
PA7'
Text Label 9950 5950 0    60   ~ 0
CA1'
Text Label 10750 5950 0    60   ~ 0
CA2'
Wire Wire Line
	8300 5150 7800 5150
Wire Wire Line
	8300 5300 7800 5300
Wire Wire Line
	8300 5450 7800 5450
Wire Wire Line
	8300 5600 7800 5600
Wire Wire Line
	8300 5750 7800 5750
Wire Wire Line
	8300 6200 7800 6200
Text Label 7850 6200 0    60   ~ 0
PA7'
Text Label 7850 5150 0    60   ~ 0
PA0'
Text Label 7850 5300 0    60   ~ 0
PA1'
Text Label 7850 5450 0    60   ~ 0
PA2'
Text Label 7850 5600 0    60   ~ 0
PA3'
Text Label 7850 5750 0    60   ~ 0
PA4'
$Comp
L R R?
U 1 1 58E5F674
P 10400 3900
F 0 "R?" V 10400 3850 50  0000 C CNN
F 1 "1k" V 10400 3950 50  0000 C CNN
F 2 "" V 10330 3900 50  0000 C CNN
F 3 "" H 10400 3900 50  0000 C CNN
	1    10400 3900
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E5F7AD
P 10400 4050
F 0 "R?" V 10400 4000 50  0000 C CNN
F 1 "1k" V 10400 4100 50  0000 C CNN
F 2 "" V 10330 4050 50  0000 C CNN
F 3 "" H 10400 4050 50  0000 C CNN
	1    10400 4050
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E5F8E9
P 10400 4200
F 0 "R?" V 10400 4150 50  0000 C CNN
F 1 "1k" V 10400 4250 50  0000 C CNN
F 2 "" V 10330 4200 50  0000 C CNN
F 3 "" H 10400 4200 50  0000 C CNN
	1    10400 4200
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E5FA24
P 10400 4350
F 0 "R?" V 10400 4300 50  0000 C CNN
F 1 "1k" V 10400 4400 50  0000 C CNN
F 2 "" V 10330 4350 50  0000 C CNN
F 3 "" H 10400 4350 50  0000 C CNN
	1    10400 4350
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E5FD96
P 10400 4500
F 0 "R?" V 10400 4450 50  0000 C CNN
F 1 "1k" V 10400 4550 50  0000 C CNN
F 2 "" V 10330 4500 50  0000 C CNN
F 3 "" H 10400 4500 50  0000 C CNN
	1    10400 4500
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E5FED7
P 10400 4650
F 0 "R?" V 10400 4600 50  0000 C CNN
F 1 "1k" V 10400 4700 50  0000 C CNN
F 2 "" V 10330 4650 50  0000 C CNN
F 3 "" H 10400 4650 50  0000 C CNN
	1    10400 4650
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E6001B
P 10400 4800
F 0 "R?" V 10400 4750 50  0000 C CNN
F 1 "1k" V 10400 4850 50  0000 C CNN
F 2 "" V 10330 4800 50  0000 C CNN
F 3 "" H 10400 4800 50  0000 C CNN
	1    10400 4800
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E60166
P 10400 4950
F 0 "R?" V 10400 4900 50  0000 C CNN
F 1 "1k" V 10400 5000 50  0000 C CNN
F 2 "" V 10330 4950 50  0000 C CNN
F 3 "" H 10400 4950 50  0000 C CNN
	1    10400 4950
	0    1    1    0   
$EndComp
$Comp
L R R?
U 1 1 58E602B4
P 10400 5100
F 0 "R?" V 10400 5050 50  0000 C CNN
F 1 "1k" V 10400 5150 50  0000 C CNN
F 2 "" V 10330 5100 50  0000 C CNN
F 3 "" H 10400 5100 50  0000 C CNN
	1    10400 5100
	0    1    1    0   
$EndComp
Wire Wire Line
	1300 850  700  850 
Wire Wire Line
	700  1000 1300 1000
Wire Wire Line
	700  1150 1300 1150
Wire Wire Line
	700  1300 1300 1300
Wire Wire Line
	700  1600 1300 1600
Wire Wire Line
	700  1750 1300 1750
Text Label 800  850  0    60   ~ 0
SPI_CLK
Text Label 800  1300 0    60   ~ 0
~SPI_SS1
Text Label 750  1000 0    60   ~ 0
SPI_MOSI
Text Label 750  1150 0    60   ~ 0
SPI_MISO
Text Label 750  1600 0    60   ~ 0
~SD_WRITE_PROTECT
Text Label 750  1750 0    60   ~ 0
~SD_CARD_DETECT
$Sheet
S 1550 2400 700  750 
U 58E79100
F0 "RTC" 60
F1 "rtc.sch" 60
F2 "SPI_MISO" O L 1550 2550 60 
F3 "SPI_MOSI" I L 1550 2700 60 
F4 "SPI_CLK" I L 1550 2850 60 
F5 "SPI_SS" I L 1550 3000 60 
$EndSheet
Wire Wire Line
	1550 2550 1050 2550
Wire Wire Line
	1050 2700 1550 2700
Wire Wire Line
	1050 2850 1550 2850
Wire Wire Line
	1050 3000 1550 3000
Text Label 1100 2850 0    60   ~ 0
SPI_CLK
Text Label 1100 3000 0    60   ~ 0
~SPI_SS3
Text Label 1100 2700 0    60   ~ 0
SPI_MOSI
Text Label 1100 2550 0    60   ~ 0
SPI_MISO
$Sheet
S 1550 3350 700  950 
U 58E7E6C3
F0 "PS/2 Controller" 60
F1 "ps2.sch" 60
F2 "SPI_MISO" I L 1550 3450 60 
F3 "~SPI_SS" I L 1550 3900 60 
F4 "SPI_MOSI" I L 1550 3600 60 
F5 "SPI_CLK" I L 1550 3750 60 
F6 "RESET_TRIG" O L 1550 4200 60 
$EndSheet
Wire Wire Line
	1550 3450 1050 3450
Wire Wire Line
	1050 3600 1550 3600
Wire Wire Line
	1050 3750 1550 3750
Wire Wire Line
	1050 3900 1550 3900
Text Label 1100 3750 0    60   ~ 0
SPI_CLK
Text Label 1100 3900 0    60   ~ 0
~SPI_SS2
Text Label 1100 3600 0    60   ~ 0
SPI_MOSI
Text Label 1100 3450 0    60   ~ 0
SPI_MISO
Text Label 1000 4200 0    60   ~ 0
RESET_TRIG
Wire Wire Line
	1000 4200 1550 4200
$EndSCHEMATC
