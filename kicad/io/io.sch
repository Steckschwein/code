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
LIBS:ttl_ieee
LIBS:lp2950l
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 3
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
P 2300 2200
F 0 "U1" H 2300 2200 50  0000 L BNN
F 1 "G65SC22P" H 1900 500 50  0000 L BNN
F 2 "Sockets_DIP:DIP-40__600_ELL" H 2300 2350 50  0001 C CNN
F 3 "" H 2300 2200 60  0000 C CNN
	1    2300 2200
	1    0    0    -1  
$EndComp
$Sheet
S 10000 800  850  2500
U 54287A69
F0 "Connector" 60
F1 "50pin_connector.sch" 60
F2 "A0" I L 10000 900 60 
F3 "A2" I L 10000 1100 60 
F4 "A3" I L 10000 1200 60 
F5 "A1" I L 10000 1000 60 
F6 "D0" I L 10000 1950 60 
F7 "D1" I L 10000 2050 60 
F8 "D2" I L 10000 2150 60 
F9 "D3" I L 10000 2250 60 
F10 "D4" I L 10000 2350 60 
F11 "D5" I L 10000 2450 60 
F12 "D6" I L 10000 2550 60 
F13 "D7" I L 10000 2650 60 
$EndSheet
Entry Wire Line
	9800 800  9900 900 
Entry Wire Line
	9800 900  9900 1000
Entry Wire Line
	9800 1000 9900 1100
Entry Wire Line
	9800 1100 9900 1200
Entry Wire Line
	9800 1850 9900 1950
Entry Wire Line
	9800 1950 9900 2050
Entry Wire Line
	9800 2050 9900 2150
Entry Wire Line
	9800 2150 9900 2250
Entry Wire Line
	9800 2250 9900 2350
Entry Wire Line
	9800 2350 9900 2450
Entry Wire Line
	9800 2450 9900 2550
Entry Wire Line
	9800 2550 9900 2650
Text Label 9900 900  0    60   ~ 0
A0
Text Label 9900 1000 0    60   ~ 0
A1
Text Label 9900 1100 0    60   ~ 0
A2
Text Label 9900 1200 0    60   ~ 0
A3
Text Label 9900 1950 0    60   ~ 0
D0
Text Label 9900 2050 0    60   ~ 0
D1
Text Label 9900 2150 0    60   ~ 0
D2
Text Label 9900 2250 0    60   ~ 0
D3
Text Label 9900 2350 0    60   ~ 0
D4
Text Label 9900 2450 0    60   ~ 0
D5
Text Label 9900 2550 0    60   ~ 0
D6
Text Label 9900 2650 0    60   ~ 0
D7
Entry Wire Line
	1500 1100 1600 1200
Entry Wire Line
	1500 1200 1600 1300
Entry Wire Line
	1500 1300 1600 1400
Entry Wire Line
	1500 1400 1600 1500
Entry Wire Line
	1500 1500 1600 1600
Entry Wire Line
	1500 1600 1600 1700
Entry Wire Line
	1500 1700 1600 1800
Entry Wire Line
	1500 1800 1600 1900
Text Label 1600 1200 0    60   ~ 0
D0
Text Label 1600 1300 0    60   ~ 0
D1
Text Label 1600 1400 0    60   ~ 0
D2
Text Label 1600 1500 0    60   ~ 0
D3
Text Label 1600 1600 0    60   ~ 0
D4
Text Label 1600 1700 0    60   ~ 0
D5
Text Label 1600 1800 0    60   ~ 0
D6
Text Label 1600 1900 0    60   ~ 0
D7
Entry Wire Line
	1500 2000 1600 2100
Entry Wire Line
	1500 2100 1600 2200
Entry Wire Line
	1500 2200 1600 2300
Entry Wire Line
	1500 2300 1600 2400
Text Label 1600 2100 0    60   ~ 0
A0
Text Label 1600 2200 0    60   ~ 0
A1
Text Label 1600 2300 0    60   ~ 0
A2
Text Label 1600 2400 0    60   ~ 0
A3
Text GLabel 1600 2600 0    60   Input ~ 0
/RESET
Text GLabel 1600 2700 0    60   Input ~ 0
/IRQ
Text GLabel 1600 2800 0    60   Input ~ 0
/RW
Text GLabel 1600 2900 0    60   Input ~ 0
PHI2
$Comp
L VCC #PWR01
U 1 1 5428C2B0
P 1650 3200
F 0 "#PWR01" H 1650 3300 30  0001 C CNN
F 1 "VCC" H 1650 3300 30  0000 C CNN
F 2 "" H 1650 3200 60  0000 C CNN
F 3 "" H 1650 3200 60  0000 C CNN
	1    1650 3200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5428C330
P 1650 3800
F 0 "#PWR02" H 1650 3800 30  0001 C CNN
F 1 "GND" H 1650 3730 30  0001 C CNN
F 2 "" H 1650 3800 60  0000 C CNN
F 3 "" H 1650 3800 60  0000 C CNN
	1    1650 3800
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR03
U 1 1 5428C3FC
P 1300 4100
F 0 "#PWR03" H 1300 4200 30  0001 C CNN
F 1 "VCC" H 1300 4200 30  0000 C CNN
F 2 "" H 1300 4100 60  0000 C CNN
F 3 "" H 1300 4100 60  0000 C CNN
	1    1300 4100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 5428C42D
P 1300 4650
F 0 "#PWR04" H 1300 4650 30  0001 C CNN
F 1 "GND" H 1300 4580 30  0001 C CNN
F 2 "" H 1300 4650 60  0000 C CNN
F 3 "" H 1300 4650 60  0000 C CNN
	1    1300 4650
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5428C484
P 1300 4350
F 0 "C1" H 1300 4450 40  0000 L CNN
F 1 "100nF" H 1306 4265 40  0000 L CNN
F 2 "Discret:C1" H 1338 4200 30  0001 C CNN
F 3 "" H 1300 4350 60  0000 C CNN
	1    1300 4350
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR05
U 1 1 5428D273
P 3150 3550
F 0 "#PWR05" H 3150 3650 30  0001 C CNN
F 1 "VCC" H 3150 3650 30  0000 C CNN
F 2 "" H 3150 3550 60  0000 C CNN
F 3 "" H 3150 3550 60  0000 C CNN
	1    3150 3550
	1    0    0    -1  
$EndComp
Text GLabel 3150 3700 2    60   Input ~ 0
/CS_VIA
Wire Wire Line
	2900 2800 3400 2800
Wire Wire Line
	2900 2300 3400 2300
Wire Wire Line
	2900 2200 3400 2200
Wire Wire Line
	2900 2100 3400 2100
Connection ~ 1300 4550
Connection ~ 1600 4550
Connection ~ 1900 4550
Connection ~ 1900 4150
Connection ~ 1600 4150
Connection ~ 1300 4150
Wire Wire Line
	1300 4550 2150 4550
Wire Wire Line
	1300 4150 2150 4150
Wire Wire Line
	2900 3700 3150 3700
Wire Wire Line
	3150 3600 3150 3500
Wire Wire Line
	2900 3600 3150 3600
Wire Wire Line
	2900 3400 3400 3400
Wire Wire Line
	3050 3300 2900 3300
Wire Wire Line
	1300 4100 1300 4150
Wire Wire Line
	1300 4550 1300 4650
Wire Wire Line
	1650 3700 1650 3800
Wire Wire Line
	1700 3700 1650 3700
Wire Wire Line
	1650 3300 1700 3300
Wire Wire Line
	1650 3200 1650 3300
Wire Wire Line
	1600 2900 1700 2900
Wire Wire Line
	1600 2800 1700 2800
Wire Wire Line
	1600 2700 1700 2700
Wire Wire Line
	1600 2600 1700 2600
Wire Wire Line
	1600 2400 1700 2400
Wire Wire Line
	1700 2300 1600 2300
Wire Wire Line
	1600 2200 1700 2200
Wire Wire Line
	1600 2100 1700 2100
Wire Bus Line
	1500 1900 1500 2400
Wire Wire Line
	1700 1900 1600 1900
Wire Wire Line
	1600 1800 1700 1800
Wire Wire Line
	1700 1700 1600 1700
Wire Wire Line
	1600 1600 1700 1600
Wire Wire Line
	1700 1500 1600 1500
Wire Wire Line
	1600 1400 1700 1400
Wire Wire Line
	1700 1300 1600 1300
Wire Wire Line
	1600 1200 1700 1200
Wire Bus Line
	1500 1000 1500 1800
Wire Wire Line
	10000 2650 9900 2650
Wire Wire Line
	9900 2550 10000 2550
Wire Wire Line
	10000 2450 9900 2450
Wire Wire Line
	9900 2350 10000 2350
Wire Wire Line
	10000 2250 9900 2250
Wire Wire Line
	9900 2150 10000 2150
Wire Wire Line
	10000 2050 9900 2050
Wire Wire Line
	9900 1950 10000 1950
Wire Bus Line
	9800 1750 9800 2550
Wire Wire Line
	9900 1200 10000 1200
Wire Wire Line
	10000 1100 9900 1100
Wire Wire Line
	9900 1000 10000 1000
Wire Wire Line
	9900 900  10000 900 
Wire Bus Line
	9800 700  9800 1200
Text HLabel 3400 2100 2    60   Input ~ 0
SPI_CLK
Text HLabel 3400 2200 2    60   Input ~ 0
SPI_SS1
Text HLabel 3400 2800 2    60   Input ~ 0
SPI_MOSI
Text HLabel 3400 3400 2    60   Input ~ 0
SPI_MISO
Wire Wire Line
	3050 3300 3050 2100
Connection ~ 3050 2100
$Sheet
S 8000 800  1400 1700
U 542907F9
F0 "SD Card" 60
F1 "sd_card.sch" 60
F2 "SPI_CLK" I L 8000 1250 60 
F3 "SPI_MOSI" I L 8000 1400 60 
F4 "SPI_MISO" I L 8000 1550 60 
F5 "SPI_SS1" I L 8000 1700 60 
$EndSheet
$EndSCHEMATC
