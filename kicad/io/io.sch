EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:memory
LIBS:special
LIBS:texas
LIBS:audio
LIBS:interface
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:65xxx
LIBS:lp2950l
LIBS:ttl_ieee
LIBS:mini_din
LIBS:io-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L G65SC22P U1
U 1 1 542879F7
P 1550 2700
F 0 "U1" H 1550 2700 50  0000 L BNN
F 1 "G65SC22P" H 1150 1000 50  0000 L BNN
F 2 "Sockets_DIP:DIP-40__600_ELL" H 1550 2850 50  0001 C CNN
F 3 "" H 1550 2700 60  0000 C CNN
	1    1550 2700
	1    0    0    -1  
$EndComp
$Sheet
S 5750 5150 850  2500
U 54287A69
F0 "Connector" 60
F1 "50pin_connector.sch" 60
F2 "A0" I L 5750 5250 60 
F3 "A2" I L 5750 5450 60 
F4 "A3" I L 5750 5550 60 
F5 "A1" I L 5750 5350 60 
F6 "D0" I L 5750 6300 60 
F7 "D1" I L 5750 6400 60 
F8 "D2" I L 5750 6500 60 
F9 "D3" I L 5750 6600 60 
F10 "D4" I L 5750 6700 60 
F11 "D5" I L 5750 6800 60 
F12 "D6" I L 5750 6900 60 
F13 "D7" I L 5750 7000 60 
F14 "A4" I L 5750 5650 60 
F15 "A5" I L 5750 5750 60 
F16 "RESET_TRIG" I L 5750 7200 60 
$EndSheet
Entry Wire Line
	5550 5150 5650 5250
Entry Wire Line
	5550 5250 5650 5350
Entry Wire Line
	5550 5350 5650 5450
Entry Wire Line
	5550 5450 5650 5550
Entry Wire Line
	5550 6200 5650 6300
Entry Wire Line
	5550 6300 5650 6400
Entry Wire Line
	5550 6400 5650 6500
Entry Wire Line
	5550 6500 5650 6600
Entry Wire Line
	5550 6600 5650 6700
Entry Wire Line
	5550 6700 5650 6800
Entry Wire Line
	5550 6800 5650 6900
Entry Wire Line
	5550 6900 5650 7000
Text Label 5650 5250 0    60   ~ 0
A0
Text Label 5650 5350 0    60   ~ 0
A1
Text Label 5650 5450 0    60   ~ 0
A2
Text Label 5650 5550 0    60   ~ 0
A3
Text Label 5650 6300 0    60   ~ 0
D0
Text Label 5650 6400 0    60   ~ 0
D1
Text Label 5650 6500 0    60   ~ 0
D2
Text Label 5650 6600 0    60   ~ 0
D3
Text Label 5650 6700 0    60   ~ 0
D4
Text Label 5650 6800 0    60   ~ 0
D5
Text Label 5650 6900 0    60   ~ 0
D6
Text Label 5650 7000 0    60   ~ 0
D7
Entry Wire Line
	750  1600 850  1700
Entry Wire Line
	750  1700 850  1800
Entry Wire Line
	750  1800 850  1900
Entry Wire Line
	750  1900 850  2000
Entry Wire Line
	750  2000 850  2100
Entry Wire Line
	750  2100 850  2200
Entry Wire Line
	750  2200 850  2300
Entry Wire Line
	750  2300 850  2400
Text Label 850  1700 0    60   ~ 0
D0
Text Label 850  1800 0    60   ~ 0
D1
Text Label 850  1900 0    60   ~ 0
D2
Text Label 850  2000 0    60   ~ 0
D3
Text Label 850  2100 0    60   ~ 0
D4
Text Label 850  2200 0    60   ~ 0
D5
Text Label 850  2300 0    60   ~ 0
D6
Text Label 850  2400 0    60   ~ 0
D7
Entry Wire Line
	750  2500 850  2600
Entry Wire Line
	750  2600 850  2700
Entry Wire Line
	750  2700 850  2800
Entry Wire Line
	750  2800 850  2900
Text Label 850  2600 0    60   ~ 0
A0
Text Label 850  2700 0    60   ~ 0
A1
Text Label 850  2800 0    60   ~ 0
A2
Text Label 850  2900 0    60   ~ 0
A3
Text GLabel 850  3100 0    60   Input ~ 0
/RESET
Text GLabel 850  3200 0    60   Input ~ 0
/IRQ
Text GLabel 850  3300 0    60   Input ~ 0
/RW
Text GLabel 850  3400 0    60   Input ~ 0
PHI2
$Comp
L VCC #PWR01
U 1 1 5428C2B0
P 900 3700
F 0 "#PWR01" H 900 3800 30  0001 C CNN
F 1 "VCC" H 900 3800 30  0000 C CNN
F 2 "" H 900 3700 60  0000 C CNN
F 3 "" H 900 3700 60  0000 C CNN
	1    900  3700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5428C330
P 900 4300
F 0 "#PWR02" H 900 4300 30  0001 C CNN
F 1 "GND" H 900 4230 30  0001 C CNN
F 2 "" H 900 4300 60  0000 C CNN
F 3 "" H 900 4300 60  0000 C CNN
	1    900  4300
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR03
U 1 1 5428C3FC
P 8750 5650
F 0 "#PWR03" H 8750 5750 30  0001 C CNN
F 1 "VCC" H 8750 5750 30  0000 C CNN
F 2 "" H 8750 5650 60  0000 C CNN
F 3 "" H 8750 5650 60  0000 C CNN
	1    8750 5650
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 5428C42D
P 8750 6200
F 0 "#PWR04" H 8750 6200 30  0001 C CNN
F 1 "GND" H 8750 6130 30  0001 C CNN
F 2 "" H 8750 6200 60  0000 C CNN
F 3 "" H 8750 6200 60  0000 C CNN
	1    8750 6200
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5428C484
P 8750 5900
F 0 "C1" H 8750 6000 40  0000 L CNN
F 1 "100nF" H 8756 5815 40  0000 L CNN
F 2 "Discret:C1" H 8788 5750 30  0001 C CNN
F 3 "" H 8750 5900 60  0000 C CNN
	1    8750 5900
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR05
U 1 1 5428D273
P 2300 4050
F 0 "#PWR05" H 2300 4150 30  0001 C CNN
F 1 "VCC" H 2300 4150 30  0000 C CNN
F 2 "" H 2300 4050 60  0000 C CNN
F 3 "" H 2300 4050 60  0000 C CNN
	1    2300 4050
	1    0    0    -1  
$EndComp
Text GLabel 2400 4200 2    60   Input ~ 0
/CS_VIA
Wire Wire Line
	2150 3300 3250 3300
Wire Wire Line
	2150 2800 2650 2800
Wire Wire Line
	2150 2700 3050 2700
Wire Wire Line
	2150 2600 3700 2600
Connection ~ 8750 6100
Connection ~ 9050 6100
Connection ~ 9350 6100
Connection ~ 9350 5700
Connection ~ 9050 5700
Connection ~ 8750 5700
Wire Wire Line
	8750 6100 9950 6100
Wire Wire Line
	8750 5700 9950 5700
Wire Wire Line
	2150 4200 2400 4200
Wire Wire Line
	2150 3900 3500 3900
Wire Wire Line
	2300 3800 2150 3800
Wire Wire Line
	8750 5650 8750 5700
Wire Wire Line
	8750 6100 8750 6200
Wire Wire Line
	900  4200 900  4300
Wire Wire Line
	950  4200 900  4200
Wire Wire Line
	900  3800 950  3800
Wire Wire Line
	900  3700 900  3800
Wire Wire Line
	850  3400 950  3400
Wire Wire Line
	850  3300 950  3300
Wire Wire Line
	850  3200 950  3200
Wire Wire Line
	850  3100 950  3100
Wire Wire Line
	850  2900 950  2900
Wire Wire Line
	950  2800 850  2800
Wire Wire Line
	850  2700 950  2700
Wire Wire Line
	850  2600 950  2600
Wire Bus Line
	750  2400 750  2900
Wire Wire Line
	950  2400 850  2400
Wire Wire Line
	850  2300 950  2300
Wire Wire Line
	950  2200 850  2200
Wire Wire Line
	850  2100 950  2100
Wire Wire Line
	950  2000 850  2000
Wire Wire Line
	850  1900 950  1900
Wire Wire Line
	950  1800 850  1800
Wire Wire Line
	850  1700 950  1700
Wire Bus Line
	750  1500 750  2300
Wire Wire Line
	5750 7000 5650 7000
Wire Wire Line
	5650 6900 5750 6900
Wire Wire Line
	5750 6800 5650 6800
Wire Wire Line
	5650 6700 5750 6700
Wire Wire Line
	5750 6600 5650 6600
Wire Wire Line
	5650 6500 5750 6500
Wire Wire Line
	5750 6400 5650 6400
Wire Wire Line
	5650 6300 5750 6300
Wire Bus Line
	5550 6100 5550 6900
Wire Wire Line
	5650 5550 5750 5550
Wire Wire Line
	5750 5450 5650 5450
Wire Wire Line
	5650 5350 5750 5350
Wire Wire Line
	5650 5250 5750 5250
Wire Bus Line
	5550 5050 5550 5550
Wire Wire Line
	2300 3800 2300 2600
Connection ~ 2300 2600
$Sheet
S 3700 2150 1400 1700
U 542907F9
F0 "SD Card" 60
F1 "sd_card.sch" 60
F2 "SPI_CLK" I L 3700 2600 60 
F3 "SPI_MOSI" I L 3700 2750 60 
F4 "SPI_MISO" I L 3700 2900 60 
F5 "SPI_SS1" I L 3700 3050 60 
$EndSheet
Text Label 2550 2600 0    60   ~ 0
SPI_CLK
Text Label 2550 2700 0    60   ~ 0
~SPI_SS1
Text Label 2550 2800 0    60   ~ 0
~SPI_SS2
Text Label 2550 3300 0    60   ~ 0
SPI_MOSI
Text Label 2550 3900 0    60   ~ 0
SPI_MISO
Wire Wire Line
	3250 3300 3250 2750
Wire Wire Line
	3250 2750 3700 2750
Wire Wire Line
	3050 2700 3050 3050
Wire Wire Line
	3050 3050 3700 3050
Wire Wire Line
	3500 3900 3500 2900
Wire Wire Line
	3500 2900 3700 2900
Wire Wire Line
	2150 1700 2250 1700
Wire Wire Line
	2350 1800 2150 1800
$Comp
L VCC #PWR06
U 1 1 545BCE2C
P 6550 600
F 0 "#PWR06" H 6550 700 30  0001 C CNN
F 1 "VCC" H 6550 700 30  0000 C CNN
F 2 "" H 6550 600 60  0000 C CNN
F 3 "" H 6550 600 60  0000 C CNN
	1    6550 600 
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 600  6550 1150
$Comp
L R R6
U 1 1 545BD877
P 5300 1000
F 0 "R6" V 5380 1000 40  0000 C CNN
F 1 "10k" V 5307 1001 40  0000 C CNN
F 2 "Discret:R3" V 5230 1000 30  0001 C CNN
F 3 "" H 5300 1000 30  0000 C CNN
	1    5300 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5300 1250 5300 1450
Wire Wire Line
	5300 1450 5650 1450
Wire Wire Line
	5300 750  9200 750 
Connection ~ 6550 750 
Wire Wire Line
	7550 1950 8600 1950
Wire Wire Line
	7550 1650 9350 1650
Text Label 7700 1950 0    60   ~ 0
SPI_CLK
Text Label 7700 1650 0    60   ~ 0
~SPI_SS2
Text GLabel 7750 2250 2    60   Output ~ 0
/NMI
Wire Wire Line
	7550 3050 8400 3050
$Comp
L C C6
U 1 1 545C1C49
P 9050 5900
F 0 "C6" H 9050 6000 40  0000 L CNN
F 1 "100nF" H 9056 5815 40  0000 L CNN
F 2 "Discret:C1" H 9088 5750 30  0001 C CNN
F 3 "" H 9050 5900 60  0000 C CNN
	1    9050 5900
	1    0    0    -1  
$EndComp
$Comp
L ATMEGA8-P IC1
U 1 1 548C6233
P 6550 2550
F 0 "IC1" H 5800 3850 40  0000 L BNN
F 1 "ATMEGA8-P" H 7050 1100 40  0000 L BNN
F 2 "Sockets_DIP:DIP-28__300_ELL" H 6550 2550 30  0000 C CIN
F 3 "" H 6550 2550 60  0000 C CNN
	1    6550 2550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR07
U 1 1 548C790B
P 6550 4200
F 0 "#PWR07" H 6550 4200 30  0001 C CNN
F 1 "GND" H 6550 4130 30  0001 C CNN
F 2 "" H 6550 4200 60  0000 C CNN
F 3 "" H 6550 4200 60  0000 C CNN
	1    6550 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 4050 6550 4200
$Comp
L GND #PWR08
U 1 1 548C7BC7
P 10700 3750
F 0 "#PWR08" H 10700 3750 30  0001 C CNN
F 1 "GND" H 10700 3680 30  0001 C CNN
F 2 "" H 10700 3750 60  0000 C CNN
F 3 "" H 10700 3750 60  0000 C CNN
	1    10700 3750
	1    0    0    -1  
$EndComp
$Comp
L DS1306 U7
U 1 1 548D7417
P 2050 6650
F 0 "U7" H 1650 7450 50  0000 L BNN
F 1 "DS1306" H 1650 5750 50  0000 L BNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 2050 6800 50  0001 C CNN
F 3 "" H 2050 6650 60  0000 C CNN
	1    2050 6650
	1    0    0    -1  
$EndComp
$Comp
L CRYSTAL_SMD X1
U 1 1 548DB6D8
P 1100 6350
F 0 "X1" H 1100 6440 30  0000 C CNN
F 1 "CRYSTAL_SMD" H 1130 6240 30  0000 L CNN
F 2 "Crystals:Crystal_Round_Vertical_3mm_BigPad" H 1100 6350 60  0001 C CNN
F 3 "" H 1100 6350 60  0000 C CNN
	1    1100 6350
	1    0    0    -1  
$EndComp
Wire Wire Line
	1300 6350 1450 6350
Wire Wire Line
	1450 6550 850  6550
Wire Wire Line
	850  6550 850  6350
Wire Wire Line
	850  6350 900  6350
$Comp
L GND #PWR09
U 1 1 548DBB2D
P 1400 7550
F 0 "#PWR09" H 1400 7550 30  0001 C CNN
F 1 "GND" H 1400 7480 30  0001 C CNN
F 2 "" H 1400 7550 60  0000 C CNN
F 3 "" H 1400 7550 60  0000 C CNN
	1    1400 7550
	1    0    0    -1  
$EndComp
Wire Wire Line
	1450 7350 1400 7350
Wire Wire Line
	1400 7350 1400 7550
$Comp
L GND #PWR010
U 1 1 548DBCBD
P 1350 6050
F 0 "#PWR010" H 1350 6050 30  0001 C CNN
F 1 "GND" H 1350 5980 30  0001 C CNN
F 2 "" H 1350 6050 60  0000 C CNN
F 3 "" H 1350 6050 60  0000 C CNN
	1    1350 6050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1450 5950 1350 5950
Wire Wire Line
	1350 5950 1350 6050
$Comp
L VCC #PWR011
U 1 1 548DC396
P 2850 5750
F 0 "#PWR011" H 2850 5850 30  0001 C CNN
F 1 "VCC" H 2850 5850 30  0000 C CNN
F 2 "" H 2850 5750 60  0000 C CNN
F 3 "" H 2850 5750 60  0000 C CNN
	1    2850 5750
	1    0    0    -1  
$EndComp
Wire Wire Line
	2650 5950 2850 5950
Wire Wire Line
	2850 5750 2850 7350
Wire Wire Line
	2850 6350 2650 6350
Connection ~ 2850 5950
Wire Wire Line
	2650 6750 3150 6750
Wire Wire Line
	2650 6950 3150 6950
Wire Wire Line
	2850 7350 2650 7350
Connection ~ 2850 6350
Wire Wire Line
	2150 2900 2650 2900
Text Label 2550 2900 0    60   ~ 0
~SPI_SS3
Text Label 3000 6950 0    60   ~ 0
SPI_CLK
$Comp
L 74HC04 U8
U 1 1 548DD841
P 3450 7150
F 0 "U8" H 3600 7250 40  0000 C CNN
F 1 "74HC04" H 3650 7050 40  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 3450 7150 60  0001 C CNN
F 3 "" H 3450 7150 60  0000 C CNN
	1    3450 7150
	-1   0    0    1   
$EndComp
Wire Wire Line
	2650 7150 3000 7150
Wire Wire Line
	3900 7150 4700 7150
Text Label 4800 6000 0    60   ~ 0
~SPI_SS3
Wire Wire Line
	7550 1750 9100 1750
Text Label 7650 1750 0    60   ~ 0
SPI_MOSI
Wire Wire Line
	7550 1850 8550 1850
$Comp
L BATTERY BT1
U 1 1 548DEF73
P 650 6500
F 0 "BT1" H 650 6700 50  0000 C CNN
F 1 "BATTERY" H 650 6310 50  0000 C CNN
F 2 "Discret:CR2032H" H 650 6500 60  0001 C CNN
F 3 "" H 650 6500 60  0000 C CNN
	1    650  6500
	0    1    1    0   
$EndComp
Wire Wire Line
	650  6150 1450 6150
$Comp
L GND #PWR012
U 1 1 548DF281
P 650 6950
F 0 "#PWR012" H 650 6950 30  0001 C CNN
F 1 "GND" H 650 6880 30  0001 C CNN
F 2 "" H 650 6950 60  0000 C CNN
F 3 "" H 650 6950 60  0000 C CNN
	1    650  6950
	1    0    0    -1  
$EndComp
Wire Wire Line
	650  6800 650  6800
Wire Wire Line
	650  6800 650  6950
$Comp
L C C7
U 1 1 548DF92D
P 9350 5900
F 0 "C7" H 9350 6000 40  0000 L CNN
F 1 "100nF" H 9356 5815 40  0000 L CNN
F 2 "Discret:C1" H 9388 5750 30  0001 C CNN
F 3 "" H 9350 5900 60  0000 C CNN
	1    9350 5900
	1    0    0    -1  
$EndComp
Text Label 3050 6750 0    60   ~ 0
SPI_MOSI
NoConn ~ 5750 5650
NoConn ~ 5750 5750
Wire Wire Line
	7550 2850 8300 2850
Wire Wire Line
	7550 2150 8000 2150
Wire Wire Line
	5750 7200 5450 7200
Text Label 7650 2150 0    60   ~ 0
RESET_TRIG
Text Label 5200 7200 0    60   ~ 0
RESET_TRIG
Wire Wire Line
	5550 750  5550 1750
Connection ~ 5550 750 
NoConn ~ 5650 2150
NoConn ~ 5650 2350
NoConn ~ 7550 1450
NoConn ~ 7550 1550
Wire Wire Line
	7550 2250 7750 2250
NoConn ~ 7550 2350
NoConn ~ 7550 2450
NoConn ~ 7550 2550
NoConn ~ 7550 2650
NoConn ~ 7550 2950
NoConn ~ 7550 3150
NoConn ~ 7550 3250
NoConn ~ 7550 3350
NoConn ~ 7550 3450
NoConn ~ 7550 3550
Wire Wire Line
	5550 1750 5650 1750
Wire Wire Line
	5650 1850 5550 1850
Wire Wire Line
	5550 1850 5550 4050
Wire Wire Line
	5550 4050 6550 4050
NoConn ~ 1450 6750
NoConn ~ 1450 6950
NoConn ~ 1450 7150
NoConn ~ 2650 6150
Wire Wire Line
	5650 1650 5550 1650
Connection ~ 5550 1650
$Comp
L CONN_02X03 P3
U 1 1 54B00157
P 8700 1950
F 0 "P3" H 8700 2150 50  0000 C CNN
F 1 "ISP" H 8700 1750 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 8700 750 60  0001 C CNN
F 3 "" H 8700 750 60  0000 C CNN
	1    8700 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 1450 5650 1100
Wire Wire Line
	5650 1100 8300 1100
Wire Wire Line
	8300 1100 8300 2050
Wire Wire Line
	8300 2050 8450 2050
Wire Wire Line
	9200 750  9200 3100
Wire Wire Line
	9200 1850 8950 1850
Wire Wire Line
	9100 1750 9100 1950
Wire Wire Line
	9100 1950 8950 1950
$Comp
L GND #PWR013
U 1 1 54B01595
P 9100 2250
F 0 "#PWR013" H 9100 2250 30  0001 C CNN
F 1 "GND" H 9100 2180 30  0001 C CNN
F 2 "" H 9100 2250 60  0000 C CNN
F 3 "" H 9100 2250 60  0000 C CNN
	1    9100 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	8950 2050 9100 2050
Wire Wire Line
	9100 2050 9100 2250
Wire Wire Line
	2150 3000 2650 3000
Wire Wire Line
	2150 3100 2650 3100
Wire Wire Line
	2150 3200 2650 3200
Text Label 2550 3000 0    60   ~ 0
~SPI_SS4
Text Label 2550 3100 0    60   ~ 0
~SPI_SS5
Text Label 2550 3200 0    60   ~ 0
~SPI_SS6
$Comp
L MINI_DIN_6 P1
U 1 1 54B06BFD
P 9850 3200
F 0 "P1" H 9450 3725 50  0000 L BNN
F 1 "PS/2 Keyboard" H 9850 3725 50  0000 L BNN
F 2 "Steckschwein:mini_din-M_DIN6" H 9850 3350 50  0001 C CNN
F 3 "" H 9850 3200 60  0000 C CNN
	1    9850 3200
	1    0    0    -1  
$EndComp
Connection ~ 9200 750 
Wire Wire Line
	10450 3100 10700 3100
Wire Wire Line
	10700 3100 10700 3750
Wire Wire Line
	8400 3050 8400 2550
Wire Wire Line
	8400 2550 10700 2550
Wire Wire Line
	10700 2550 10700 3000
Wire Wire Line
	10700 3000 10350 3000
NoConn ~ 9350 3000
NoConn ~ 9250 3300
Wire Wire Line
	9200 3100 9250 3100
Connection ~ 9200 1850
Wire Wire Line
	9850 3600 9850 3650
Wire Wire Line
	9200 3650 10700 3650
Connection ~ 10700 3650
Wire Wire Line
	10350 3400 10350 3650
Wire Wire Line
	10350 3650 10300 3650
Connection ~ 10350 3650
Wire Wire Line
	9350 3400 9200 3400
Wire Wire Line
	9200 3400 9200 3650
Connection ~ 9850 3650
Wire Wire Line
	10450 3300 10550 3300
Wire Wire Line
	10550 3300 10550 3750
Wire Wire Line
	10550 3750 8300 3750
Wire Wire Line
	8300 3750 8300 2850
$Comp
L 74125 U4
U 2 1 54AFFC85
P 10200 1600
F 0 "U4" H 10450 1850 50  0000 L BNN
F 1 "74125" H 10300 1300 40  0000 L TNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 10200 1600 60  0001 C CNN
F 3 "" H 10200 1600 60  0000 C CNN
	2    10200 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	10700 1600 11000 1600
Text Label 10850 1600 0    60   ~ 0
SPI_MISO
Wire Wire Line
	9350 1650 9350 1500
Wire Wire Line
	9350 1500 9700 1500
Wire Wire Line
	9700 1700 8450 1700
Wire Wire Line
	8450 1700 8450 1850
Connection ~ 8450 1850
$Comp
L 74125 U4
U 3 1 54B01627
P 4050 6450
F 0 "U4" H 4300 6700 50  0000 L BNN
F 1 "74125" H 4150 6150 40  0000 L TNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 4050 6450 60  0001 C CNN
F 3 "" H 4050 6450 60  0000 C CNN
	3    4050 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2650 6550 3550 6550
Wire Wire Line
	3550 6350 3450 6350
Wire Wire Line
	3450 6350 3450 6000
Wire Wire Line
	3450 6000 5050 6000
Wire Wire Line
	4700 7150 4700 6000
Wire Wire Line
	4550 6450 5000 6450
Wire Wire Line
	650  6200 650  6150
Text Label 4850 6450 0    60   ~ 0
SPI_MISO
Wire Wire Line
	2150 4100 2300 4100
Wire Wire Line
	2300 4100 2300 4050
$Comp
L CP2 C8
U 1 1 54B14D65
P 9650 5900
F 0 "C8" H 9650 6000 40  0000 L CNN
F 1 "100µF" H 9656 5815 40  0000 L CNN
F 2 "Capacitors_Elko_ThroughHole:Elko_vert_11.5x8mm_RM3.5" H 9688 5750 30  0001 C CNN
F 3 "" H 9650 5900 60  0000 C CNN
	1    9650 5900
	1    0    0    -1  
$EndComp
Connection ~ 4700 6000
$Comp
L CONN_02X03 P4
U 1 1 54B176A0
P 3350 4600
F 0 "P4" H 3350 4800 50  0000 C CNN
F 1 "SPI4" H 3350 4400 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 3350 3400 60  0001 C CNN
F 3 "" H 3350 3400 60  0000 C CNN
	1    3350 4600
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR014
U 1 1 54B17C97
P 3700 4350
F 0 "#PWR014" H 3700 4450 30  0001 C CNN
F 1 "VCC" H 3700 4450 30  0000 C CNN
F 2 "" H 3700 4350 60  0000 C CNN
F 3 "" H 3700 4350 60  0000 C CNN
	1    3700 4350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR015
U 1 1 54B17DD5
P 3700 4800
F 0 "#PWR015" H 3700 4800 30  0001 C CNN
F 1 "GND" H 3700 4730 30  0001 C CNN
F 2 "" H 3700 4800 60  0000 C CNN
F 3 "" H 3700 4800 60  0000 C CNN
	1    3700 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 4700 3700 4700
Wire Wire Line
	3700 4700 3700 4800
Wire Wire Line
	3600 4500 3700 4500
Wire Wire Line
	3700 4500 3700 4350
Wire Wire Line
	3600 4600 3900 4600
Wire Wire Line
	3100 4500 2700 4500
Wire Wire Line
	2700 4600 3100 4600
Wire Wire Line
	2700 4700 3100 4700
Text Label 3650 4600 0    60   ~ 0
SPI_MOSI
Text Label 2750 4500 0    60   ~ 0
SPI_MISO
Text Label 2750 4600 0    60   ~ 0
SPI_CLK
Text Label 2750 4700 0    60   ~ 0
~SPI_SS4
$Comp
L CONN_02X03 P7
U 1 1 54B1904A
P 6250 4600
F 0 "P7" H 6250 4800 50  0000 C CNN
F 1 "SPI6" H 6250 4400 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 6250 3400 60  0001 C CNN
F 3 "" H 6250 3400 60  0000 C CNN
	1    6250 4600
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR016
U 1 1 54B19050
P 6600 4350
F 0 "#PWR016" H 6600 4450 30  0001 C CNN
F 1 "VCC" H 6600 4450 30  0000 C CNN
F 2 "" H 6600 4350 60  0000 C CNN
F 3 "" H 6600 4350 60  0000 C CNN
	1    6600 4350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR017
U 1 1 54B19056
P 6600 4800
F 0 "#PWR017" H 6600 4800 30  0001 C CNN
F 1 "GND" H 6600 4730 30  0001 C CNN
F 2 "" H 6600 4800 60  0000 C CNN
F 3 "" H 6600 4800 60  0000 C CNN
	1    6600 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	6500 4700 6600 4700
Wire Wire Line
	6600 4700 6600 4800
Wire Wire Line
	6500 4500 6600 4500
Wire Wire Line
	6600 4500 6600 4350
Wire Wire Line
	6500 4600 6800 4600
Wire Wire Line
	6000 4500 5600 4500
Wire Wire Line
	5600 4600 6000 4600
Wire Wire Line
	5600 4700 6000 4700
Text Label 6550 4600 0    60   ~ 0
SPI_MOSI
Text Label 5650 4500 0    60   ~ 0
SPI_MISO
Text Label 5650 4600 0    60   ~ 0
SPI_CLK
Text Label 5650 4700 0    60   ~ 0
~SPI_SS6
$Comp
L CONN_02X03 P6
U 1 1 54B1948A
P 4800 4600
F 0 "P6" H 4800 4800 50  0000 C CNN
F 1 "SPI5" H 4800 4400 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x03" H 4800 3400 60  0001 C CNN
F 3 "" H 4800 3400 60  0000 C CNN
	1    4800 4600
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR018
U 1 1 54B19490
P 5150 4350
F 0 "#PWR018" H 5150 4450 30  0001 C CNN
F 1 "VCC" H 5150 4450 30  0000 C CNN
F 2 "" H 5150 4350 60  0000 C CNN
F 3 "" H 5150 4350 60  0000 C CNN
	1    5150 4350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR019
U 1 1 54B19496
P 5150 4800
F 0 "#PWR019" H 5150 4800 30  0001 C CNN
F 1 "GND" H 5150 4730 30  0001 C CNN
F 2 "" H 5150 4800 60  0000 C CNN
F 3 "" H 5150 4800 60  0000 C CNN
	1    5150 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	5050 4700 5150 4700
Wire Wire Line
	5150 4700 5150 4800
Wire Wire Line
	5050 4500 5150 4500
Wire Wire Line
	5150 4500 5150 4350
Wire Wire Line
	5050 4600 5350 4600
Wire Wire Line
	4550 4500 4150 4500
Wire Wire Line
	4150 4600 4550 4600
Wire Wire Line
	4150 4700 4550 4700
Text Label 5100 4600 0    60   ~ 0
SPI_MOSI
Text Label 4200 4500 0    60   ~ 0
SPI_MISO
Text Label 4200 4600 0    60   ~ 0
SPI_CLK
Text Label 4200 4700 0    60   ~ 0
~SPI_SS5
$Comp
L C C9
U 1 1 54B17E82
P 9950 5900
F 0 "C9" H 9950 6000 40  0000 L CNN
F 1 "100nF" H 9956 5815 40  0000 L CNN
F 2 "Discret:C1" H 9988 5750 30  0001 C CNN
F 3 "" H 9950 5900 60  0000 C CNN
	1    9950 5900
	1    0    0    -1  
$EndComp
Connection ~ 9650 5700
Connection ~ 9650 6100
Wire Wire Line
	2250 1700 2250 750 
Wire Wire Line
	2250 750  3700 750 
Wire Wire Line
	2350 1800 2350 900 
Wire Wire Line
	2350 900  3700 900 
Wire Wire Line
	3700 1050 2450 1050
Wire Wire Line
	2450 1050 2450 1900
Wire Wire Line
	2450 1900 2150 1900
Wire Wire Line
	3700 1200 2550 1200
Wire Wire Line
	2550 1200 2550 2000
Wire Wire Line
	2550 2000 2150 2000
$Sheet
S 3700 650  1400 1250
U 54318D23
F0 "Joystick Ports" 60
F1 "joystick.sch" 60
F2 "PortSel01" I L 3700 1650 60 
F3 "PortSel02" I L 3700 1800 60 
F4 "J_Right" I L 3700 1200 60 
F5 "J_Left" I L 3700 1050 60 
F6 "J_Up" I L 3700 750 60 
F7 "J_Down" I L 3700 900 60 
F8 "J_Fire1" I L 3700 1350 60 
F9 "J_Fire2" I L 3700 1500 60 
$EndSheet
Wire Wire Line
	2150 2100 2650 2100
Wire Wire Line
	2650 2100 2650 1350
Wire Wire Line
	2650 1350 3700 1350
Wire Wire Line
	2150 2300 2950 2300
Wire Wire Line
	2950 2300 2950 1650
Wire Wire Line
	2950 1650 3700 1650
Wire Wire Line
	3700 1800 3050 1800
Wire Wire Line
	3050 1800 3050 2400
Wire Wire Line
	3050 2400 2150 2400
$EndSCHEMATC
