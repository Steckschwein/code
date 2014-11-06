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
LIBS:io-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 4
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
L 7407 U2
U 4 1 542928D0
P 4850 1700
F 0 "U2" H 5000 2050 60  0000 C CNN
F 1 "7407" H 5000 1400 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 4850 1700 60  0001 C CNN
F 3 "" H 4850 1700 60  0000 C CNN
	4    4850 1700
	1    0    0    -1  
$EndComp
$Comp
L 7407 U2
U 6 1 542928D7
P 4850 3150
F 0 "U2" H 5000 3500 60  0000 C CNN
F 1 "7407" H 5000 2850 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 4850 3150 60  0001 C CNN
F 3 "" H 4850 3150 60  0000 C CNN
	6    4850 3150
	1    0    0    -1  
$EndComp
$Comp
L 7407 U2
U 5 1 542928DE
P 4850 2400
F 0 "U2" H 5000 2750 60  0000 C CNN
F 1 "7407" H 5000 2100 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 4850 2400 60  0001 C CNN
F 3 "" H 4850 2400 60  0000 C CNN
	5    4850 2400
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 542928E5
P 5550 1300
F 0 "R1" V 5630 1300 40  0000 C CNN
F 1 "1k" V 5557 1301 40  0000 C CNN
F 2 "Discret:R3" V 5480 1300 30  0001 C CNN
F 3 "" H 5550 1300 30  0000 C CNN
	1    5550 1300
	1    0    0    -1  
$EndComp
$Comp
L 74125 U4
U 1 1 54292908
P 4800 3850
F 0 "U4" H 5050 4100 50  0000 L BNN
F 1 "74125" H 4900 3550 40  0000 L TNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 4800 3850 60  0001 C CNN
F 3 "" H 4800 3850 60  0000 C CNN
	1    4800 3850
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X09 P2
U 1 1 5429290F
P 10800 2050
F 0 "P2" H 10800 2550 50  0000 C CNN
F 1 "SDCARD" V 10900 2050 50  0000 C CNN
F 2 "Sockets:SDCARD-REVERSE" H 10800 2050 60  0001 C CNN
F 3 "" H 10800 2050 60  0000 C CNN
	1    10800 2050
	1    0    0    -1  
$EndComp
$Comp
L LP2950 U5
U 1 1 54292916
P 4850 850
F 0 "U5" H 5000 654 60  0000 C CNN
F 1 "LP2950" H 4850 1050 60  0000 C CNN
F 2 "Housings_TO-92:TO-92-Free-inline-wide" H 4850 850 60  0001 C CNN
F 3 "" H 4850 850 60  0000 C CNN
	1    4850 850 
	1    0    0    -1  
$EndComp
Text HLabel 4050 1700 0    60   Input ~ 0
SPI_CLK
Wire Wire Line
	4050 1700 4300 1700
$Comp
L GND #PWR17
U 1 1 54292A1E
P 4850 1300
F 0 "#PWR17" H 4850 1300 30  0001 C CNN
F 1 "GND" H 4850 1230 30  0001 C CNN
F 2 "" H 4850 1300 60  0000 C CNN
F 3 "" H 4850 1300 60  0000 C CNN
	1    4850 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 1100 4850 1300
$Comp
L VCC #PWR16
U 1 1 54292A61
P 4400 650
F 0 "#PWR16" H 4400 750 30  0001 C CNN
F 1 "VCC" H 4400 750 30  0000 C CNN
F 2 "" H 4400 650 60  0000 C CNN
F 3 "" H 4400 650 60  0000 C CNN
	1    4400 650 
	1    0    0    -1  
$EndComp
Wire Wire Line
	4400 650  4400 800 
Wire Wire Line
	4400 800  4450 800 
Wire Wire Line
	5250 800  10400 800 
Wire Wire Line
	5550 1050 5550 800 
Connection ~ 5550 800 
Wire Wire Line
	5400 1700 9950 1700
Wire Wire Line
	5550 1550 5550 1700
Connection ~ 5550 1700
Wire Wire Line
	4300 2400 4050 2400
Text HLabel 4050 2400 0    60   Input ~ 0
SPI_MOSI
Text HLabel 5550 3850 2    60   Input ~ 0
SPI_MISO
Wire Wire Line
	5300 3850 5550 3850
Text HLabel 4050 3150 0    60   Input ~ 0
SPI_SS1
Wire Wire Line
	4050 3150 4300 3150
Wire Wire Line
	5400 2400 8000 2400
Wire Wire Line
	5950 1050 5950 800 
Connection ~ 5950 800 
Wire Wire Line
	5950 1550 5950 2400
Connection ~ 5950 2400
Wire Wire Line
	6350 1050 6350 800 
Connection ~ 6350 800 
Wire Wire Line
	5400 3150 10300 3150
Wire Wire Line
	6350 1550 6350 3150
Connection ~ 6350 3150
$Comp
L R R2
U 1 1 542931DC
P 5950 1300
F 0 "R2" V 6030 1300 40  0000 C CNN
F 1 "1k" V 5957 1301 40  0000 C CNN
F 2 "Discret:R3" V 5880 1300 30  0001 C CNN
F 3 "" H 5950 1300 30  0000 C CNN
	1    5950 1300
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 54293212
P 6350 1300
F 0 "R3" V 6430 1300 40  0000 C CNN
F 1 "1k" V 6357 1301 40  0000 C CNN
F 2 "Discret:R3" V 6280 1300 30  0001 C CNN
F 3 "" H 6350 1300 30  0000 C CNN
	1    6350 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	4300 3950 4200 3950
Wire Wire Line
	4200 3950 4200 4300
Wire Wire Line
	4200 4300 9950 4300
Wire Wire Line
	9950 1700 9950 2050
Wire Wire Line
	8000 2400 8000 1750
Wire Wire Line
	10300 3150 10300 1650
Wire Wire Line
	10300 1650 10600 1650
Wire Wire Line
	8000 1750 10600 1750
Wire Wire Line
	9950 2050 10600 2050
Wire Wire Line
	10600 1850 10500 1850
Wire Wire Line
	10500 1850 10500 3250
Wire Wire Line
	10600 2150 10500 2150
Connection ~ 10500 2150
$Comp
L GND #PWR18
U 1 1 54293655
P 10500 3250
F 0 "#PWR18" H 10500 3250 30  0001 C CNN
F 1 "GND" H 10500 3180 30  0001 C CNN
F 2 "" H 10500 3250 60  0000 C CNN
F 3 "" H 10500 3250 60  0000 C CNN
	1    10500 3250
	1    0    0    -1  
$EndComp
Wire Wire Line
	10400 800  10400 1950
Wire Wire Line
	10400 1950 10600 1950
Wire Wire Line
	9950 4300 9950 2250
Wire Wire Line
	9950 2250 10600 2250
$Comp
L C C3
U 1 1 542937DA
P 5350 1000
F 0 "C3" H 5350 1100 40  0000 L CNN
F 1 "100nF" H 5356 915 40  0000 L CNN
F 2 "Discret:C1" H 5388 850 30  0001 C CNN
F 3 "" H 5350 1000 60  0000 C CNN
	1    5350 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 800  5350 800 
Connection ~ 5350 800 
Wire Wire Line
	4400 1200 5350 1200
Connection ~ 4850 1200
$Comp
L CP2 C2
U 1 1 542939AF
P 4400 1000
F 0 "C2" H 4400 1100 40  0000 L CNN
F 1 "10µF" H 4406 915 40  0000 L CNN
F 2 "Capacitors_Elko_ThroughHole:Elko_vert_DM6-3_RM2-5_CopperClear" H 4438 850 30  0001 C CNN
F 3 "" H 4400 1000 60  0000 C CNN
	1    4400 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4300 3750 4200 3750
Wire Wire Line
	4200 3750 4200 3150
Connection ~ 4200 3150
$Comp
L C C4
U 1 1 5429B6F0
P 2250 900
F 0 "C4" H 2250 1000 40  0000 L CNN
F 1 "100nF" H 2256 815 40  0000 L CNN
F 2 "Discret:C1" H 2288 750 30  0001 C CNN
F 3 "" H 2250 900 60  0000 C CNN
	1    2250 900 
	1    0    0    -1  
$EndComp
$Comp
L C C5
U 1 1 5429B734
P 2550 900
F 0 "C5" H 2550 1000 40  0000 L CNN
F 1 "100nF" H 2556 815 40  0000 L CNN
F 2 "Discret:C1" H 2588 750 30  0001 C CNN
F 3 "" H 2550 900 60  0000 C CNN
	1    2550 900 
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR14
U 1 1 5429B75D
P 2000 650
F 0 "#PWR14" H 2000 750 30  0001 C CNN
F 1 "VCC" H 2000 750 30  0000 C CNN
F 2 "" H 2000 650 60  0000 C CNN
F 3 "" H 2000 650 60  0000 C CNN
	1    2000 650 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR15
U 1 1 5429B775
P 2000 1250
F 0 "#PWR15" H 2000 1250 30  0001 C CNN
F 1 "GND" H 2000 1180 30  0001 C CNN
F 2 "" H 2000 1250 60  0000 C CNN
F 3 "" H 2000 1250 60  0000 C CNN
	1    2000 1250
	1    0    0    -1  
$EndComp
Wire Wire Line
	2000 650  2550 650 
Wire Wire Line
	2550 650  2550 700 
Wire Wire Line
	2550 1200 2550 1100
Wire Wire Line
	2000 1200 2550 1200
Wire Wire Line
	2000 1200 2000 1250
Wire Wire Line
	2250 1100 2250 1200
Connection ~ 2250 1200
Wire Wire Line
	2250 700  2250 650 
Connection ~ 2250 650 
$EndSCHEMATC
