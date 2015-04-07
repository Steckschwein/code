EESchema Schematic File Version 2
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
LIBS:special
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
LIBS:gal
LIBS:UART
LIBS:osc
LIBS:74xgxx
LIBS:ttl_ieee
LIBS:steckschwein-cache
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
L W65C02SP U1
U 1 1 5413569B
P 2000 2550
F 0 "U1" H 2000 2550 50  0000 L BNN
F 1 "W65C02SP" H 1600 950 50  0000 L BNN
F 2 "Sockets_DIP:DIP-40__600_ELL" H 2000 2700 50  0001 C CNN
F 3 "" H 2000 2550 60  0000 C CNN
	1    2000 2550
	1    0    0    -1  
$EndComp
Entry Wire Line
	2700 1650 2800 1550
Entry Wire Line
	1200 1550 1300 1650
Entry Wire Line
	1200 1650 1300 1750
Entry Wire Line
	1200 1750 1300 1850
Entry Wire Line
	1200 1850 1300 1950
Entry Wire Line
	1200 1950 1300 2050
Entry Wire Line
	1200 2050 1300 2150
Entry Wire Line
	1200 2150 1300 2250
Entry Wire Line
	1200 2250 1300 2350
Entry Wire Line
	1200 2350 1300 2450
Entry Wire Line
	1200 2450 1300 2550
Entry Wire Line
	1200 2550 1300 2650
Entry Wire Line
	1200 2650 1300 2750
Entry Wire Line
	1200 2750 1300 2850
Entry Wire Line
	1200 2850 1300 2950
Entry Wire Line
	1200 2950 1300 3050
Entry Wire Line
	1200 3050 1300 3150
Entry Wire Line
	2700 1750 2800 1650
Entry Wire Line
	2700 1850 2800 1750
Entry Wire Line
	2700 1950 2800 1850
Entry Wire Line
	2700 2050 2800 1950
Entry Wire Line
	2700 2150 2800 2050
Entry Wire Line
	2700 2250 2800 2150
Entry Wire Line
	2700 2350 2800 2250
NoConn ~ 2600 2550
$Comp
L R R1
U 1 1 54135A46
P 800 3750
F 0 "R1" V 880 3750 40  0000 C CNN
F 1 "3.3k" V 807 3751 40  0000 C CNN
F 2 "Discret:R3" V 730 3750 30  0001 C CNN
F 3 "" H 800 3750 30  0000 C CNN
	1    800  3750
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 54135B17
P 800 3650
F 0 "R2" V 880 3650 40  0000 C CNN
F 1 "3.3k" V 807 3651 40  0000 C CNN
F 2 "Discret:R3" V 730 3650 30  0001 C CNN
F 3 "" H 800 3650 30  0000 C CNN
	1    800  3650
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 54135B4A
P 800 3450
F 0 "R3" V 880 3450 40  0000 C CNN
F 1 "3.3k" V 807 3451 40  0000 C CNN
F 2 "Discret:R3" V 730 3450 30  0001 C CNN
F 3 "" H 800 3450 30  0000 C CNN
	1    800  3450
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 54135B6E
P 3500 3650
F 0 "R4" V 3580 3650 40  0000 C CNN
F 1 "3.3k" V 3507 3651 40  0000 C CNN
F 2 "Discret:R3" V 3430 3650 30  0001 C CNN
F 3 "" H 3500 3650 30  0000 C CNN
	1    3500 3650
	0    1    1    0   
$EndComp
$Comp
L LM555N U2
U 1 1 54135D14
P 2250 6700
F 0 "U2" H 2250 6800 70  0000 C CNN
F 1 "LM555N" H 2250 6600 70  0000 C CNN
F 2 "Sockets_DIP:DIP-8__300_ELL" H 2250 6700 60  0001 C CNN
F 3 "" H 2250 6700 60  0000 C CNN
	1    2250 6700
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR01
U 1 1 5413678B
P 4900 6950
F 0 "#PWR01" H 4900 7050 30  0001 C CNN
F 1 "VCC" H 4900 7050 30  0000 C CNN
F 2 "" H 4900 6950 60  0000 C CNN
F 3 "" H 4900 6950 60  0000 C CNN
	1    4900 6950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 541367AD
P 4900 7500
F 0 "#PWR02" H 4900 7500 30  0001 C CNN
F 1 "GND" H 4900 7430 30  0001 C CNN
F 2 "" H 4900 7500 60  0000 C CNN
F 3 "" H 4900 7500 60  0000 C CNN
	1    4900 7500
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 541367DD
P 4900 7200
F 0 "C1" H 4900 7300 40  0000 L CNN
F 1 "100n" H 4906 7115 40  0000 L CNN
F 2 "Discret:C1" H 4938 7050 30  0001 C CNN
F 3 "" H 4900 7200 60  0000 C CNN
	1    4900 7200
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR03
U 1 1 54136970
P 2750 2700
F 0 "#PWR03" H 2750 2800 30  0001 C CNN
F 1 "VCC" H 2750 2800 30  0000 C CNN
F 2 "" H 2750 2700 60  0000 C CNN
F 3 "" H 2750 2700 60  0000 C CNN
	1    2750 2700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 541369C9
P 2750 3250
F 0 "#PWR04" H 2750 3250 30  0001 C CNN
F 1 "GND" H 2750 3180 30  0001 C CNN
F 2 "" H 2750 3250 60  0000 C CNN
F 3 "" H 2750 3250 60  0000 C CNN
	1    2750 3250
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 54136B39
P 1850 5900
F 0 "R5" V 1930 5900 40  0000 C CNN
F 1 "1M" V 1857 5901 40  0000 C CNN
F 2 "Discret:R3" V 1780 5900 30  0001 C CNN
F 3 "" H 1850 5900 30  0000 C CNN
	1    1850 5900
	0    1    1    0   
$EndComp
$Comp
L R R6
U 1 1 54136D90
P 2650 5900
F 0 "R6" V 2730 5900 40  0000 C CNN
F 1 "1M" V 2657 5901 40  0000 C CNN
F 2 "Discret:R3" V 2580 5900 30  0001 C CNN
F 3 "" H 2650 5900 30  0000 C CNN
	1    2650 5900
	0    1    1    0   
$EndComp
$Comp
L VCC #PWR05
U 1 1 54136DD8
P 2250 5800
F 0 "#PWR05" H 2250 5900 30  0001 C CNN
F 1 "VCC" H 2250 5900 30  0000 C CNN
F 2 "" H 2250 5800 60  0000 C CNN
F 3 "" H 2250 5800 60  0000 C CNN
	1    2250 5800
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 541371BF
P 3000 7650
F 0 "#PWR06" H 3000 7650 30  0001 C CNN
F 1 "GND" H 3000 7580 30  0001 C CNN
F 2 "" H 3000 7650 60  0000 C CNN
F 3 "" H 3000 7650 60  0000 C CNN
	1    3000 7650
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 54137610
P 800 7150
F 0 "C2" H 800 7250 40  0000 L CNN
F 1 "10n" H 806 7065 40  0000 L CNN
F 2 "Discret:C1" H 838 7000 30  0001 C CNN
F 3 "" H 800 7150 60  0000 C CNN
	1    800  7150
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 54137759
P 1000 7150
F 0 "C3" H 1000 7250 40  0000 L CNN
F 1 "1n" H 1006 7065 40  0000 L CNN
F 2 "Discret:C1" H 1038 7000 30  0001 C CNN
F 3 "" H 1000 7150 60  0000 C CNN
	1    1000 7150
	1    0    0    -1  
$EndComp
$Comp
L CP2 C4
U 1 1 54134E8D
P 3000 7150
F 0 "C4" H 3000 7250 40  0000 L CNN
F 1 "1µ" H 3006 7065 40  0000 L CNN
F 2 "Capacitors_Elko_ThroughHole:Elko_vert_DM5_RM2-5" H 3038 7000 30  0001 C CNN
F 3 "" H 3000 7150 60  0000 C CNN
	1    3000 7150
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 4 1 541351F6
P 3850 6400
F 0 "U3" H 3850 6450 60  0000 C CNN
F 1 "74HCT00" H 3850 6300 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 3850 6400 60  0001 C CNN
F 3 "" H 3850 6400 60  0000 C CNN
	4    3850 6400
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR07
U 1 1 5413551C
P 550 3350
F 0 "#PWR07" H 550 3450 30  0001 C CNN
F 1 "VCC" H 550 3450 30  0000 C CNN
F 2 "" H 550 3350 60  0000 C CNN
F 3 "" H 550 3350 60  0000 C CNN
	1    550  3350
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR08
U 1 1 5413558F
P 3750 3550
F 0 "#PWR08" H 3750 3650 30  0001 C CNN
F 1 "VCC" H 3750 3650 30  0000 C CNN
F 2 "" H 3750 3550 60  0000 C CNN
F 3 "" H 3750 3550 60  0000 C CNN
	1    3750 3550
	1    0    0    -1  
$EndComp
$Comp
L 74LS393 U4
U 1 1 54135D32
P 3300 4900
F 0 "U4" H 3450 5150 60  0000 C CNN
F 1 "74LS393" H 3500 4650 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 3300 4900 60  0001 C CNN
F 3 "" H 3300 4900 60  0000 C CNN
	1    3300 4900
	1    0    0    -1  
$EndComp
$Comp
L C C5
U 1 1 54135F5D
P 5150 7200
F 0 "C5" H 5150 7300 40  0000 L CNN
F 1 "100n" H 5156 7115 40  0000 L CNN
F 2 "Discret:C1" H 5188 7050 30  0001 C CNN
F 3 "" H 5150 7200 60  0000 C CNN
	1    5150 7200
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR09
U 1 1 54136377
P 750 4750
F 0 "#PWR09" H 750 4850 30  0001 C CNN
F 1 "VCC" H 750 4850 30  0000 C CNN
F 2 "" H 750 4750 60  0000 C CNN
F 3 "" H 750 4750 60  0000 C CNN
	1    750  4750
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR010
U 1 1 541363D2
P 750 5250
F 0 "#PWR010" H 750 5250 30  0001 C CNN
F 1 "GND" H 750 5180 30  0001 C CNN
F 2 "" H 750 5250 60  0000 C CNN
F 3 "" H 750 5250 60  0000 C CNN
	1    750  5250
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR011
U 1 1 5413653F
P 2550 5250
F 0 "#PWR011" H 2550 5250 30  0001 C CNN
F 1 "GND" H 2550 5180 30  0001 C CNN
F 2 "" H 2550 5250 60  0000 C CNN
F 3 "" H 2550 5250 60  0000 C CNN
	1    2550 5250
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR012
U 1 1 5413674B
P 3300 4550
F 0 "#PWR012" H 3300 4650 30  0001 C CNN
F 1 "VCC" H 3300 4650 30  0000 C CNN
F 2 "" H 3300 4550 60  0000 C CNN
F 3 "" H 3300 4550 60  0000 C CNN
	1    3300 4550
	1    0    0    -1  
$EndComp
$Comp
L CONN_02X04 P1
U 1 1 54136830
P 4450 4900
F 0 "P1" H 4450 5150 50  0000 C CNN
F 1 "CONN_02X04" H 4450 4650 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x04" H 4450 3700 60  0001 C CNN
F 3 "" H 4450 3700 60  0000 C CNN
	1    4450 4900
	-1   0    0    -1  
$EndComp
$Comp
L C C6
U 1 1 541376C2
P 5400 7200
F 0 "C6" H 5400 7300 40  0000 L CNN
F 1 "100n" H 5406 7115 40  0000 L CNN
F 2 "Discret:C1" H 5438 7050 30  0001 C CNN
F 3 "" H 5400 7200 60  0000 C CNN
	1    5400 7200
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X03 P3
U 1 1 541377BD
P 4600 3950
F 0 "P3" H 4600 4150 50  0000 C CNN
F 1 "CONN_01X03" V 4700 3950 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 4600 3950 60  0001 C CNN
F 3 "" H 4600 3950 60  0000 C CNN
	1    4600 3950
	1    0    0    1   
$EndComp
Text Label 1300 1650 0    60   ~ 0
A0
$Comp
L C C7
U 1 1 54138302
P 5650 7200
F 0 "C7" H 5650 7300 40  0000 L CNN
F 1 "100n" H 5656 7115 40  0000 L CNN
F 2 "Discret:C1" H 5688 7050 30  0001 C CNN
F 3 "" H 5650 7200 60  0000 C CNN
	1    5650 7200
	1    0    0    -1  
$EndComp
Text Label 1300 1750 0    60   ~ 0
A1
Text Label 1300 1850 0    60   ~ 0
A2
Text Label 1300 1950 0    60   ~ 0
A3
Text Label 1300 2050 0    60   ~ 0
A4
Text Label 1300 2150 0    60   ~ 0
A5
Text Label 1300 2250 0    60   ~ 0
A6
Text Label 1300 2350 0    60   ~ 0
A7
Text Label 1300 2450 0    60   ~ 0
A8
Text Label 1300 2550 0    60   ~ 0
A9
Text Label 1300 2650 0    60   ~ 0
A10
Text Label 1300 2750 0    60   ~ 0
A11
Text Label 1300 2850 0    60   ~ 0
A12
Text Label 1300 2950 0    60   ~ 0
A13
Text Label 1300 3050 0    60   ~ 0
A14
Text Label 1300 3150 0    60   ~ 0
A15
$Comp
L 74HCT00 U3
U 1 1 5413BC11
P 8600 6200
F 0 "U3" H 8600 6250 60  0000 C CNN
F 1 "74HCT00" H 8600 6100 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 8600 6200 60  0001 C CNN
F 3 "" H 8600 6200 60  0000 C CNN
	1    8600 6200
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 2 1 5413BCDA
P 9900 5550
F 0 "U3" H 9900 5600 60  0000 C CNN
F 1 "74HCT00" H 9900 5450 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 9900 5550 60  0001 C CNN
F 3 "" H 9900 5550 60  0000 C CNN
	2    9900 5550
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 3 1 5413BEE8
P 9900 6100
F 0 "U3" H 9900 6150 60  0000 C CNN
F 1 "74HCT00" H 9900 6000 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 9900 6100 60  0001 C CNN
F 3 "" H 9900 6100 60  0000 C CNN
	3    9900 6100
	1    0    0    -1  
$EndComp
Text Label 2600 1650 0    60   ~ 0
D0
Text Label 2600 1750 0    60   ~ 0
D1
Text Label 2600 1850 0    60   ~ 0
D2
Text Label 2600 1950 0    60   ~ 0
D3
Text Label 2600 2050 0    60   ~ 0
D4
Text Label 2600 2150 0    60   ~ 0
D5
Text Label 2600 2250 0    60   ~ 0
D6
Text Label 2600 2350 0    60   ~ 0
D7
$Comp
L C C8
U 1 1 5413E45B
P 5900 7200
F 0 "C8" H 5900 7300 40  0000 L CNN
F 1 "100n" H 5906 7115 40  0000 L CNN
F 2 "Discret:C1" H 5938 7050 30  0001 C CNN
F 3 "" H 5900 7200 60  0000 C CNN
	1    5900 7200
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR013
U 1 1 5413EA26
P 7000 2550
F 0 "#PWR013" H 7000 2650 30  0001 C CNN
F 1 "VCC" H 7000 2650 30  0000 C CNN
F 2 "" H 7000 2550 60  0000 C CNN
F 3 "" H 7000 2550 60  0000 C CNN
	1    7000 2550
	1    0    0    -1  
$EndComp
Text Label 9050 750  0    60   ~ 0
D[0..7]
Entry Wire Line
	8950 1050 9050 950 
Entry Wire Line
	8950 1150 9050 1050
Entry Wire Line
	8950 1250 9050 1150
Entry Wire Line
	8950 1350 9050 1250
Entry Wire Line
	8950 1450 9050 1350
Entry Wire Line
	8950 1550 9050 1450
Entry Wire Line
	8950 1650 9050 1550
Text Label 8850 1050 0    60   ~ 0
D0
Text Label 8850 1150 0    60   ~ 0
D1
Text Label 8850 1250 0    60   ~ 0
D2
Text Label 8850 1350 0    60   ~ 0
D3
Text Label 8850 1450 0    60   ~ 0
D4
Text Label 8850 1550 0    60   ~ 0
D5
Text Label 8850 1650 0    60   ~ 0
D6
Text Label 8850 1750 0    60   ~ 0
D7
Entry Wire Line
	7150 950  7250 1050
Entry Wire Line
	7150 1050 7250 1150
Entry Wire Line
	7150 1150 7250 1250
Entry Wire Line
	7150 1250 7250 1350
Entry Wire Line
	7150 1350 7250 1450
Entry Wire Line
	7150 1450 7250 1550
Entry Wire Line
	7150 1550 7250 1650
Entry Wire Line
	7150 1650 7250 1750
Entry Wire Line
	7150 1750 7250 1850
Entry Wire Line
	7150 1850 7250 1950
Entry Wire Line
	7150 1950 7250 2050
Entry Wire Line
	7150 2150 7250 2250
Entry Wire Line
	7150 2050 7250 2150
$Comp
L HM62256BLP-7 U7
U 1 1 5414173B
P 6650 4250
F 0 "U7" H 6350 5150 50  0000 C CNN
F 1 "HM62256BLP-7" H 7050 3450 50  0000 C CNN
F 2 "Sockets_DIP:DIP-28__600_ELL" H 6650 4250 30  0000 C CIN
F 3 "" H 6650 4250 60  0000 C CNN
	1    6650 4250
	1    0    0    -1  
$EndComp
Entry Wire Line
	5900 3400 6000 3500
Entry Wire Line
	5900 3500 6000 3600
Entry Wire Line
	5900 3600 6000 3700
Entry Wire Line
	5900 3700 6000 3800
Entry Wire Line
	5900 3800 6000 3900
Entry Wire Line
	5900 3900 6000 4000
Entry Wire Line
	5900 4000 6000 4100
Entry Wire Line
	5900 4100 6000 4200
Entry Wire Line
	5900 4200 6000 4300
Entry Wire Line
	5900 4300 6000 4400
Entry Wire Line
	5900 4400 6000 4500
Entry Wire Line
	5900 4500 6000 4600
Entry Wire Line
	5900 4600 6000 4700
Entry Wire Line
	5900 4700 6000 4800
Entry Wire Line
	5900 4800 6000 4900
Entry Wire Line
	7350 3500 7450 3400
Entry Wire Line
	7350 3600 7450 3500
Entry Wire Line
	7350 3700 7450 3600
Entry Wire Line
	7350 3800 7450 3700
Entry Wire Line
	7350 3900 7450 3800
Entry Wire Line
	7350 4000 7450 3900
Entry Wire Line
	7350 4100 7450 4000
Entry Wire Line
	7350 4200 7450 4100
$Comp
L C C9
U 1 1 54146339
P 6150 7200
F 0 "C9" H 6150 7300 40  0000 L CNN
F 1 "100n" H 6156 7115 40  0000 L CNN
F 2 "Discret:C1" H 6188 7050 30  0001 C CNN
F 3 "" H 6150 7200 60  0000 C CNN
	1    6150 7200
	1    0    0    -1  
$EndComp
$Comp
L C C10
U 1 1 54146372
P 6400 7200
F 0 "C10" H 6400 7300 40  0000 L CNN
F 1 "100n" H 6406 7115 40  0000 L CNN
F 2 "Discret:C1" H 6438 7050 30  0001 C CNN
F 3 "" H 6400 7200 60  0000 C CNN
	1    6400 7200
	1    0    0    -1  
$EndComp
$Comp
L SW_PUSH SW1
U 1 1 54147B44
P 3200 7150
F 0 "SW1" H 3350 7260 50  0000 C CNN
F 1 "SW_PUSH" H 3200 7070 50  0000 C CNN
F 2 "Discret:PUSH_BUTT_SHAPE1" H 3200 7150 60  0001 C CNN
F 3 "" H 3200 7150 60  0000 C CNN
	1    3200 7150
	0    1    1    0   
$EndComp
Text Label 7300 1050 0    60   ~ 0
A0
Text Label 7300 1150 0    60   ~ 0
A1
Text Label 7300 1250 0    60   ~ 0
A2
Text Label 7300 1350 0    60   ~ 0
A3
Text Label 7300 1450 0    60   ~ 0
A4
Text Label 7300 1550 0    60   ~ 0
A5
Text Label 7300 1650 0    60   ~ 0
A6
Text Label 7300 1750 0    60   ~ 0
A7
Text Label 7300 1850 0    60   ~ 0
A8
Text Label 7300 1950 0    60   ~ 0
A9
Text Label 7300 2050 0    60   ~ 0
A10
Text Label 7300 2150 0    60   ~ 0
A11
Text Label 7300 2250 0    60   ~ 0
A12
Text Label 6000 3500 0    60   ~ 0
A0
Text Label 6000 3600 0    60   ~ 0
A1
Text Label 6000 3700 0    60   ~ 0
A2
Text Label 6000 3800 0    60   ~ 0
A3
Text Label 6000 3900 0    60   ~ 0
A4
Text Label 6000 4000 0    60   ~ 0
A5
Text Label 6000 4100 0    60   ~ 0
A6
Text Label 6000 4200 0    60   ~ 0
A7
Text Label 6000 4300 0    60   ~ 0
A8
Text Label 6000 4400 0    60   ~ 0
A9
Text Label 6000 4500 0    60   ~ 0
A10
Text Label 6000 4600 0    60   ~ 0
A11
Text Label 6000 4700 0    60   ~ 0
A12
Text Label 6000 4800 0    60   ~ 0
A13
Text Label 6000 4900 0    60   ~ 0
A14
Text Label 7250 3500 0    60   ~ 0
D0
Text Label 7250 3600 0    60   ~ 0
D1
Text Label 7250 3700 0    60   ~ 0
D2
Text Label 7250 3800 0    60   ~ 0
D3
Text Label 7250 3900 0    60   ~ 0
D4
Text Label 7250 4000 0    60   ~ 0
D5
Text Label 7250 4100 0    60   ~ 0
D6
Text Label 7250 4200 0    60   ~ 0
D7
$Comp
L HM62256BLP-7 U8
U 1 1 5414AE2F
P 8750 4250
F 0 "U8" H 8450 5150 50  0000 C CNN
F 1 "HM62256BLP-7" H 9150 3450 50  0000 C CNN
F 2 "Sockets_DIP:DIP-28__600_ELL" H 8750 4250 30  0000 C CIN
F 3 "" H 8750 4250 60  0000 C CNN
	1    8750 4250
	1    0    0    -1  
$EndComp
Entry Wire Line
	8000 3400 8100 3500
Entry Wire Line
	8000 3500 8100 3600
Entry Wire Line
	8000 3600 8100 3700
Entry Wire Line
	8000 3700 8100 3800
Entry Wire Line
	8000 3800 8100 3900
Entry Wire Line
	8000 3900 8100 4000
Entry Wire Line
	8000 4000 8100 4100
Entry Wire Line
	8000 4100 8100 4200
Entry Wire Line
	8000 4200 8100 4300
Entry Wire Line
	8000 4300 8100 4400
Entry Wire Line
	8000 4400 8100 4500
Entry Wire Line
	8000 4500 8100 4600
Entry Wire Line
	8000 4600 8100 4700
Entry Wire Line
	8000 4700 8100 4800
Entry Wire Line
	8000 4800 8100 4900
Entry Wire Line
	9450 3500 9550 3400
Entry Wire Line
	9450 3600 9550 3500
Entry Wire Line
	9450 3700 9550 3600
Entry Wire Line
	9450 3800 9550 3700
Entry Wire Line
	9450 3900 9550 3800
Entry Wire Line
	9450 4000 9550 3900
Entry Wire Line
	9450 4100 9550 4000
Entry Wire Line
	9450 4200 9550 4100
Text Label 8100 3500 0    60   ~ 0
A0
Text Label 8100 3600 0    60   ~ 0
A1
Text Label 8100 3700 0    60   ~ 0
A2
Text Label 8100 3800 0    60   ~ 0
A3
Text Label 8100 3900 0    60   ~ 0
A4
Text Label 8100 4000 0    60   ~ 0
A5
Text Label 8100 4100 0    60   ~ 0
A6
Text Label 8100 4200 0    60   ~ 0
A7
Text Label 8100 4300 0    60   ~ 0
A8
Text Label 8100 4400 0    60   ~ 0
A9
Text Label 8100 4500 0    60   ~ 0
A10
Text Label 8100 4600 0    60   ~ 0
A11
Text Label 8100 4700 0    60   ~ 0
A12
Text Label 8100 4800 0    60   ~ 0
A13
Text Label 8100 4900 0    60   ~ 0
A14
Text Label 9350 3500 0    60   ~ 0
D0
Text Label 9350 3600 0    60   ~ 0
D1
Text Label 9350 3700 0    60   ~ 0
D2
Text Label 9350 3800 0    60   ~ 0
D3
Text Label 9350 3900 0    60   ~ 0
D4
Text Label 9350 4000 0    60   ~ 0
D5
Text Label 9350 4100 0    60   ~ 0
D6
Text Label 9350 4200 0    60   ~ 0
D7
Text GLabel 1050 3550 0    60   Input ~ 0
/RESET
Text GLabel 4250 3950 0    60   Input ~ 0
PHI2
Text GLabel 7200 2750 0    60   Input ~ 0
/OE
Text GLabel 7350 4350 2    60   Input ~ 0
/OE
Text GLabel 7350 4450 2    60   Input ~ 0
/WE
Text GLabel 9450 4350 2    60   Input ~ 0
/OE
Text GLabel 9450 4450 2    60   Input ~ 0
/WE
Text GLabel 1050 3850 0    60   Input ~ 0
/RW
Text GLabel 7750 5850 0    60   Input ~ 0
/RW
Text GLabel 9100 5850 0    60   Input ~ 0
PHI2
Text GLabel 10700 5550 2    60   Input ~ 0
/OE
Text GLabel 10700 6100 2    60   Input ~ 0
/WE
Text GLabel 4550 6400 2    60   Input ~ 0
/RESET
NoConn ~ 2250 5050
NoConn ~ 2600 3450
NoConn ~ 2600 3750
NoConn ~ 1400 3350
NoConn ~ 1400 3950
NoConn ~ 10000 5650
$Comp
L CONN_02X02 P4
U 1 1 541492CC
P 3000 3600
F 0 "P4" H 3000 3750 50  0000 C CNN
F 1 "CONN_02X02" H 3000 3450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x02" H 3000 2400 60  0001 C CNN
F 3 "" H 3000 2400 60  0000 C CNN
	1    3000 3600
	1    0    0    1   
$EndComp
$Comp
L GND #PWR014
U 1 1 5414A44F
P 3400 3450
F 0 "#PWR014" H 3400 3450 30  0001 C CNN
F 1 "GND" H 3400 3380 30  0001 C CNN
F 2 "" H 3400 3450 60  0000 C CNN
F 3 "" H 3400 3450 60  0000 C CNN
	1    3400 3450
	1    0    0    -1  
$EndComp
Text Label 7150 800  0    60   ~ 0
A[0..15]
Text Label 5900 3400 0    60   ~ 0
A
Text Label 8000 3350 0    60   ~ 0
A
Text Label 1200 1350 0    60   ~ 0
A
Text Label 2800 1550 0    60   ~ 0
D
Text Label 7450 3350 0    60   ~ 0
D
Text Label 9550 3400 0    60   ~ 0
D
$Comp
L OSC X1
U 1 1 541F2AC6
P 1550 4900
F 0 "X1" H 1550 5200 70  0000 C CNN
F 1 "OSC" H 1550 4900 70  0000 C CNN
F 2 "Oscillator-Modules:OSCILLATOR_KXO-200_LargePads" H 1550 4900 60  0001 C CNN
F 3 "" H 1550 4900 60  0000 C CNN
	1    1550 4900
	1    0    0    -1  
$EndComp
Entry Wire Line
	9850 1700 9950 1800
Text Label 9700 1650 0    60   ~ 0
A[0..15]
Text Label 9950 1800 0    60   ~ 0
A0
Entry Wire Line
	9850 1800 9950 1900
Entry Wire Line
	9850 1900 9950 2000
Entry Wire Line
	9850 2000 9950 2100
Entry Wire Line
	9850 2100 9950 2200
Text Label 9950 1900 0    60   ~ 0
A1
Text Label 9950 2000 0    60   ~ 0
A2
Text Label 9950 2100 0    60   ~ 0
A3
Text Label 9950 2200 0    60   ~ 0
A4
Entry Wire Line
	9900 2800 9800 2700
Entry Wire Line
	9900 2900 9800 2800
Entry Wire Line
	9900 3000 9800 2900
Entry Wire Line
	9900 3100 9800 3000
Entry Wire Line
	9900 3200 9800 3100
Entry Wire Line
	9900 3300 9800 3200
Entry Wire Line
	9900 3400 9800 3300
Entry Wire Line
	9900 3500 9800 3400
Text Label 9800 2650 2    60   ~ 0
D
$Comp
L 28C256 U6
U 1 1 5413DDC9
P 8100 1950
F 0 "U6" H 8300 2950 70  0000 C CNN
F 1 "28C256" H 8400 950 70  0000 C CNN
F 2 "Sockets_DIP:DIP-28__600_ELL" H 8100 1950 60  0001 C CNN
F 3 "" H 8100 1950 60  0000 C CNN
	1    8100 1950
	1    0    0    -1  
$EndComp
Text Label 9900 2800 0    60   ~ 0
D0
Text Label 9900 2900 0    60   ~ 0
D1
Text Label 9900 3000 0    60   ~ 0
D2
Text Label 9900 3100 0    60   ~ 0
D3
Text Label 9900 3200 0    60   ~ 0
D4
Text Label 9900 3300 0    60   ~ 0
D5
Text Label 9900 3400 0    60   ~ 0
D6
Text Label 9900 3500 0    60   ~ 0
D7
Text GLabel 1150 4100 3    60   Input ~ 0
/NMI
Text GLabel 1300 4100 3    60   Input ~ 0
/IRQ
Text GLabel 1150 3350 1    60   Input ~ 0
RDY
Entry Wire Line
	9850 2200 9950 2300
Text Label 9950 2300 0    60   ~ 0
A5
$Comp
L VCC #PWR015
U 1 1 543745A2
P 8100 850
F 0 "#PWR015" H 8100 950 30  0001 C CNN
F 1 "VCC" H 8100 950 30  0000 C CNN
F 2 "" H 8100 850 60  0000 C CNN
F 3 "" H 8100 850 60  0000 C CNN
	1    8100 850 
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR016
U 1 1 543748B3
P 8100 3000
F 0 "#PWR016" H 8100 3000 30  0001 C CNN
F 1 "GND" H 8100 2930 30  0001 C CNN
F 2 "" H 8100 3000 60  0000 C CNN
F 3 "" H 8100 3000 60  0000 C CNN
	1    8100 3000
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR017
U 1 1 54374D46
P 6650 3300
F 0 "#PWR017" H 6650 3400 30  0001 C CNN
F 1 "VCC" H 6650 3400 30  0000 C CNN
F 2 "" H 6650 3300 60  0000 C CNN
F 3 "" H 6650 3300 60  0000 C CNN
	1    6650 3300
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR018
U 1 1 54374E0E
P 8750 3300
F 0 "#PWR018" H 8750 3400 30  0001 C CNN
F 1 "VCC" H 8750 3400 30  0000 C CNN
F 2 "" H 8750 3300 60  0000 C CNN
F 3 "" H 8750 3300 60  0000 C CNN
	1    8750 3300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR019
U 1 1 54375105
P 6650 5100
F 0 "#PWR019" H 6650 5100 30  0001 C CNN
F 1 "GND" H 6650 5030 30  0001 C CNN
F 2 "" H 6650 5100 60  0000 C CNN
F 3 "" H 6650 5100 60  0000 C CNN
	1    6650 5100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR020
U 1 1 54375267
P 8750 5100
F 0 "#PWR020" H 8750 5100 30  0001 C CNN
F 1 "GND" H 8750 5030 30  0001 C CNN
F 2 "" H 8750 5100 60  0000 C CNN
F 3 "" H 8750 5100 60  0000 C CNN
	1    8750 5100
	1    0    0    -1  
$EndComp
$Sheet
S 10050 600  650  2950
U 54206EE0
F0 "Connector" 60
F1 "50pin_connector.sch" 60
F2 "A0" I L 10050 1800 60 
F3 "A1" I L 10050 1900 60 
F4 "A2" I L 10050 2000 60 
F5 "A3" I L 10050 2100 60 
F6 "A4" I L 10050 2200 60 
F7 "D0" I L 10050 2800 60 
F8 "D1" I L 10050 2900 60 
F9 "D2" I L 10050 3000 60 
F10 "D3" I L 10050 3100 60 
F11 "D4" I L 10050 3200 60 
F12 "D5" I L 10050 3300 60 
F13 "D6" I L 10050 3400 60 
F14 "D7" I L 10050 3500 60 
F15 "A5" I L 10050 2300 60 
F16 "RESET_TRIG" I L 10050 1250 60 
$EndSheet
$Sheet
S 3550 700  1300 2400
U 544D4EDE
F0 "decoder" 60
F1 "decoder.sch" 60
F2 "A4" I L 3550 2750 60 
F3 "D0" I L 3550 1500 60 
F4 "D1" I L 3550 1400 60 
F5 "D2" I L 3550 1300 60 
F6 "D3" I L 3550 1200 60 
F7 "D4" I L 3550 1100 60 
F8 "D5" I L 3550 1000 60 
F9 "D6" I L 3550 900 60 
F10 "D7" I L 3550 800 60 
F11 "A5" I L 3550 2650 60 
F12 "A6" I L 3550 2550 60 
F13 "A7" I L 3550 2450 60 
F14 "A8" I L 3550 2350 60 
F15 "A9" I L 3550 2250 60 
F16 "A10" I L 3550 2150 60 
F17 "A11" I L 3550 2050 60 
F18 "A12" I L 3550 1950 60 
F19 "A13" I L 3550 1850 60 
F20 "A14" I L 3550 1750 60 
F21 "A15" I L 3550 1650 60 
F22 "/CS_ROM" O R 4850 800 60 
F23 "/CS_LORAM" O R 4850 900 60 
F24 "/CS_HIRAM" O R 4850 1000 60 
F25 "RW" I L 3550 2900 60 
F26 "/CS_UART" O R 4850 1100 60 
F27 "/CS_VIA" O R 4850 1200 60 
F28 "/CS_VDP" O R 4850 1300 60 
F29 "/CS_IO0" O R 4850 1400 60 
F30 "/CS_IO1" O R 4850 1500 60 
F31 "/CS_IO2" O R 4850 1600 60 
F32 "/CS_IO3" O R 4850 1700 60 
F33 "/RESET" I L 3550 3000 60 
F34 "BANK1" O R 4850 1850 60 
F35 "BANK2" O R 4850 1950 60 
$EndSheet
Text GLabel 3400 2900 0    60   Input ~ 0
/RW
Text GLabel 3400 3000 0    60   Input ~ 0
/RESET
Entry Wire Line
	3100 700  3200 800 
Entry Wire Line
	3100 800  3200 900 
Entry Wire Line
	3100 900  3200 1000
Entry Wire Line
	3100 1000 3200 1100
Entry Wire Line
	3100 1100 3200 1200
Entry Wire Line
	3100 1200 3200 1300
Entry Wire Line
	3100 1300 3200 1400
Entry Wire Line
	3100 1400 3200 1500
Wire Bus Line
	1200 1400 1200 3050
Wire Bus Line
	2800 1450 2800 2250
Wire Wire Line
	1300 3150 1400 3150
Wire Wire Line
	1300 3050 1400 3050
Wire Wire Line
	1300 2950 1400 2950
Wire Wire Line
	1300 2850 1400 2850
Wire Wire Line
	1300 2750 1400 2750
Wire Wire Line
	1300 2650 1400 2650
Wire Wire Line
	1300 2550 1400 2550
Wire Wire Line
	1300 2450 1400 2450
Wire Wire Line
	1300 2350 1400 2350
Wire Wire Line
	1300 2250 1400 2250
Wire Wire Line
	1300 2150 1400 2150
Wire Wire Line
	1300 2050 1400 2050
Wire Wire Line
	1300 1950 1400 1950
Wire Wire Line
	1300 1850 1400 1850
Wire Wire Line
	1300 1750 1400 1750
Wire Wire Line
	1300 1650 1400 1650
Wire Wire Line
	2600 1650 2700 1650
Wire Wire Line
	2600 1750 2700 1750
Wire Wire Line
	2600 1850 2700 1850
Wire Wire Line
	2600 1950 2700 1950
Wire Wire Line
	2600 2050 2700 2050
Wire Wire Line
	2600 2150 2700 2150
Wire Wire Line
	2600 2250 2700 2250
Wire Wire Line
	2600 2350 2700 2350
Wire Wire Line
	1050 3450 1400 3450
Wire Wire Line
	1050 3650 1400 3650
Wire Wire Line
	1050 3750 1400 3750
Wire Wire Line
	3250 6300 3250 6500
Wire Wire Line
	3250 6500 2950 6500
Wire Wire Line
	1050 3550 1400 3550
Wire Wire Line
	4450 6400 4550 6400
Wire Wire Line
	4900 6950 4900 7000
Wire Wire Line
	4900 7400 4900 7500
Wire Wire Line
	2600 2750 2750 2750
Wire Wire Line
	2750 2750 2750 2700
Wire Wire Line
	2600 3150 2750 3150
Wire Wire Line
	2750 3150 2750 3250
Wire Wire Line
	2100 5900 2400 5900
Connection ~ 2250 5900
Wire Wire Line
	2900 5900 3000 5900
Wire Wire Line
	3000 5900 3000 6950
Wire Wire Line
	3000 6700 2950 6700
Wire Wire Line
	3000 6900 2950 6900
Connection ~ 3000 6700
Wire Wire Line
	1550 7000 1250 7000
Wire Wire Line
	1250 7000 1250 6100
Wire Wire Line
	1250 6100 2250 6100
Connection ~ 2250 6100
Wire Wire Line
	800  5900 1600 5900
Wire Wire Line
	800  5900 800  6950
Wire Wire Line
	500  6500 1550 6500
Connection ~ 800  6500
Wire Wire Line
	1550 6750 1000 6750
Wire Wire Line
	1000 6750 1000 6950
Wire Wire Line
	800  7350 800  7500
Wire Wire Line
	800  7500 3000 7500
Wire Wire Line
	1000 7350 1000 7500
Connection ~ 1000 7500
Wire Wire Line
	3000 7350 3000 7650
Connection ~ 3000 6900
Connection ~ 3000 7500
Wire Wire Line
	550  3350 550  3750
Connection ~ 550  3650
Connection ~ 550  3450
Wire Wire Line
	4900 7000 6750 7000
Wire Wire Line
	4900 7400 6750 7400
Wire Wire Line
	2550 5050 2550 5250
Wire Wire Line
	2550 5050 2600 5050
Wire Wire Line
	3300 5100 3300 5200
Wire Wire Line
	3300 5200 2550 5200
Connection ~ 2550 5200
Wire Wire Line
	3300 4550 3300 4700
Wire Wire Line
	4000 4750 4200 4750
Wire Wire Line
	4000 4850 4200 4850
Wire Wire Line
	4000 4950 4200 4950
Wire Wire Line
	4000 5050 4200 5050
Connection ~ 4700 4950
Connection ~ 4700 4850
Connection ~ 4700 5050
Wire Wire Line
	2600 3950 2800 3950
Wire Wire Line
	2600 3850 4400 3850
Wire Wire Line
	1400 3850 1050 3850
Wire Wire Line
	7750 5850 8000 5850
Wire Wire Line
	8000 5450 8000 6300
Wire Wire Line
	9200 6200 9300 6200
Wire Wire Line
	9300 5450 8000 5450
Connection ~ 8000 5850
Wire Wire Line
	9300 5650 9300 6000
Wire Wire Line
	9300 5850 9100 5850
Connection ~ 9300 5850
Wire Wire Line
	10500 5550 10700 5550
Wire Wire Line
	10500 6100 10700 6100
Wire Wire Line
	7000 2650 7400 2650
Wire Wire Line
	7400 2750 7200 2750
Wire Bus Line
	9050 750  9050 1650
Wire Wire Line
	8950 1750 8800 1750
Wire Wire Line
	8950 1650 8800 1650
Wire Wire Line
	8950 1550 8800 1550
Wire Wire Line
	8950 1450 8800 1450
Wire Wire Line
	8950 1350 8800 1350
Wire Wire Line
	8800 1250 8950 1250
Wire Wire Line
	8800 1150 8950 1150
Wire Wire Line
	8800 1050 8950 1050
Wire Bus Line
	7150 750  7150 2150
Wire Wire Line
	7250 2250 7400 2250
Wire Wire Line
	7250 2150 7400 2150
Wire Wire Line
	7250 2050 7400 2050
Wire Wire Line
	7250 1950 7400 1950
Wire Wire Line
	7250 1850 7400 1850
Wire Wire Line
	7250 1750 7400 1750
Wire Wire Line
	7250 1650 7400 1650
Wire Wire Line
	7250 1550 7400 1550
Wire Wire Line
	7250 1450 7400 1450
Wire Wire Line
	7250 1350 7400 1350
Wire Wire Line
	7250 1250 7400 1250
Wire Wire Line
	7250 1150 7400 1150
Wire Wire Line
	7250 1050 7400 1050
Wire Bus Line
	5900 3300 5900 4800
Wire Wire Line
	6000 4900 6100 4900
Wire Wire Line
	6000 4800 6100 4800
Wire Wire Line
	6000 4700 6100 4700
Wire Wire Line
	6000 4600 6100 4600
Wire Wire Line
	6000 4500 6100 4500
Wire Wire Line
	6000 4400 6100 4400
Wire Wire Line
	6000 4300 6100 4300
Wire Wire Line
	6000 4200 6100 4200
Wire Wire Line
	6000 4100 6100 4100
Wire Wire Line
	6000 4000 6100 4000
Wire Wire Line
	6000 3900 6100 3900
Wire Wire Line
	6000 3800 6100 3800
Wire Wire Line
	6000 3700 6100 3700
Wire Wire Line
	6000 3600 6100 3600
Wire Wire Line
	6000 3500 6100 3500
Wire Bus Line
	7450 3300 7450 4100
Wire Wire Line
	7200 3500 7350 3500
Wire Wire Line
	7200 3600 7350 3600
Wire Wire Line
	7200 3700 7350 3700
Wire Wire Line
	7200 3800 7350 3800
Wire Wire Line
	7200 3900 7350 3900
Wire Wire Line
	7200 4000 7350 4000
Wire Wire Line
	7200 4100 7350 4100
Wire Wire Line
	7200 4200 7350 4200
Wire Wire Line
	7200 4350 7350 4350
Wire Wire Line
	7200 4450 7350 4450
Wire Wire Line
	7200 4600 7350 4600
Connection ~ 5150 7000
Connection ~ 5400 7000
Connection ~ 5650 7000
Connection ~ 5900 7000
Connection ~ 5900 7400
Connection ~ 5650 7400
Connection ~ 5400 7400
Connection ~ 5150 7400
Connection ~ 6150 7000
Connection ~ 6400 7000
Connection ~ 6400 7400
Connection ~ 6150 7400
Wire Bus Line
	8000 3300 8000 4800
Wire Wire Line
	8100 4900 8200 4900
Wire Wire Line
	8100 4800 8200 4800
Wire Wire Line
	8100 4700 8200 4700
Wire Wire Line
	8100 4600 8200 4600
Wire Wire Line
	8100 4500 8200 4500
Wire Wire Line
	8100 4400 8200 4400
Wire Wire Line
	8100 4300 8200 4300
Wire Wire Line
	8100 4200 8200 4200
Wire Wire Line
	8100 4100 8200 4100
Wire Wire Line
	8100 4000 8200 4000
Wire Wire Line
	8100 3900 8200 3900
Wire Wire Line
	8100 3800 8200 3800
Wire Wire Line
	8100 3700 8200 3700
Wire Wire Line
	8100 3600 8200 3600
Wire Wire Line
	8100 3500 8200 3500
Wire Bus Line
	9550 3300 9550 4100
Wire Wire Line
	9300 3500 9450 3500
Wire Wire Line
	9300 3600 9450 3600
Wire Wire Line
	9300 3700 9450 3700
Wire Wire Line
	9300 3800 9450 3800
Wire Wire Line
	9300 3900 9450 3900
Wire Wire Line
	9300 4000 9450 4000
Wire Wire Line
	9300 4100 9450 4100
Wire Wire Line
	9300 4200 9450 4200
Wire Wire Line
	9300 4350 9450 4350
Wire Wire Line
	9300 4450 9450 4450
Wire Wire Line
	9300 4600 9450 4600
Wire Wire Line
	750  4750 850  4750
Wire Wire Line
	750  5050 750  5250
Wire Wire Line
	2250 4750 2600 4750
Wire Wire Line
	750  5050 850  5050
Wire Wire Line
	2600 3650 2750 3650
Wire Wire Line
	2600 3550 2750 3550
Wire Wire Line
	3750 3550 3750 3650
Wire Wire Line
	3250 3550 3250 3400
Wire Wire Line
	3250 3400 3400 3400
Wire Wire Line
	3400 3400 3400 3450
Wire Bus Line
	9850 1500 9850 2200
Wire Wire Line
	9950 1800 10050 1800
Wire Wire Line
	9950 1900 10050 1900
Wire Wire Line
	9950 2000 10050 2000
Wire Wire Line
	9950 2100 10050 2100
Wire Bus Line
	9800 2600 9800 3400
Wire Wire Line
	9900 2800 10050 2800
Wire Wire Line
	10050 2900 9900 2900
Wire Wire Line
	9900 3000 10050 3000
Wire Wire Line
	10050 3100 9900 3100
Wire Wire Line
	9900 3200 10050 3200
Wire Wire Line
	10050 3300 9900 3300
Wire Wire Line
	9900 3400 10050 3400
Wire Wire Line
	10050 3500 9900 3500
Wire Wire Line
	1150 4100 1150 3650
Connection ~ 1150 3650
Wire Wire Line
	1300 4100 1300 3750
Connection ~ 1300 3750
Wire Wire Line
	1150 3350 1150 3450
Connection ~ 1150 3450
Connection ~ 8000 6100
Wire Wire Line
	7000 2550 7000 2650
Connection ~ 6650 7000
Connection ~ 6650 7400
Wire Wire Line
	9950 2200 10050 2200
Wire Wire Line
	9950 2300 10050 2300
Wire Wire Line
	8100 3000 8100 2900
Wire Wire Line
	6650 5000 6650 5100
Wire Wire Line
	8750 5000 8750 5100
Wire Wire Line
	2250 5800 2250 6300
Wire Wire Line
	3400 2900 3550 2900
Wire Wire Line
	3400 3000 3550 3000
Wire Bus Line
	3100 550  3100 1450
Wire Wire Line
	3200 800  3550 800 
Wire Wire Line
	3200 900  3550 900 
Wire Wire Line
	3200 1000 3550 1000
Wire Wire Line
	3200 1100 3550 1100
Wire Wire Line
	3200 1200 3550 1200
Wire Wire Line
	3200 1300 3550 1300
Wire Wire Line
	3200 1400 3550 1400
Wire Wire Line
	3200 1500 3550 1500
Text Label 3150 600  0    60   ~ 0
D
Text Label 3200 800  0    60   ~ 0
D7
Text Label 3200 900  0    60   ~ 0
D6
Text Label 3200 1000 0    60   ~ 0
D5
Text Label 3200 1100 0    60   ~ 0
D4
Text Label 3200 1200 0    60   ~ 0
D3
Text Label 3200 1300 0    60   ~ 0
D2
Text Label 3200 1400 0    60   ~ 0
D1
Text Label 3200 1500 0    60   ~ 0
D0
Wire Bus Line
	3100 1500 3100 2700
Entry Wire Line
	3100 1550 3200 1650
Entry Wire Line
	3100 1650 3200 1750
Entry Wire Line
	3100 1750 3200 1850
Entry Wire Line
	3100 1850 3200 1950
Entry Wire Line
	3100 1950 3200 2050
Entry Wire Line
	3100 2050 3200 2150
Entry Wire Line
	3100 2150 3200 2250
Entry Wire Line
	3100 2250 3200 2350
Entry Wire Line
	3100 2350 3200 2450
Entry Wire Line
	3100 2450 3200 2550
Entry Wire Line
	3100 2550 3200 2650
Entry Wire Line
	3100 2650 3200 2750
Wire Wire Line
	3200 1650 3550 1650
Wire Wire Line
	3200 1750 3550 1750
Wire Wire Line
	3200 1850 3550 1850
Wire Wire Line
	3200 1950 3550 1950
Wire Wire Line
	3200 2050 3550 2050
Wire Wire Line
	3200 2150 3550 2150
Wire Wire Line
	3200 2250 3550 2250
Wire Wire Line
	3200 2350 3550 2350
Wire Wire Line
	3200 2450 3550 2450
Wire Wire Line
	3200 2550 3550 2550
Wire Wire Line
	3200 2650 3550 2650
Wire Wire Line
	3200 2750 3550 2750
Text Label 3100 1550 0    60   ~ 0
A
Text Label 3200 1650 0    60   ~ 0
A15
Text Label 3200 1750 0    60   ~ 0
A14
Text Label 3200 1850 0    60   ~ 0
A13
Text Label 3200 1950 0    60   ~ 0
A12
Text Label 3200 2050 0    60   ~ 0
A11
Text Label 3200 2150 0    60   ~ 0
A10
Text Label 3200 2250 0    60   ~ 0
A9
Text Label 3200 2350 0    60   ~ 0
A8
Text Label 3200 2450 0    60   ~ 0
A7
Text Label 3200 2550 0    60   ~ 0
A6
Text Label 3200 2650 0    60   ~ 0
A5
Text Label 3200 2750 0    60   ~ 0
A4
Text Label 7350 4600 0    60   ~ 0
/CS_LORAM
Text Label 9450 4600 0    60   ~ 0
/CS_HIRAM
Wire Wire Line
	4850 900  5150 900 
Wire Wire Line
	4850 1000 5150 1000
Text Label 5100 900  0    60   ~ 0
/CS_LORAM
Text Label 5100 1000 0    60   ~ 0
/CS_HIRAM
Wire Wire Line
	4850 1100 5150 1100
Wire Wire Line
	4850 1200 5150 1200
Wire Wire Line
	4850 1300 5150 1300
Wire Wire Line
	4850 1400 5150 1400
Wire Wire Line
	4850 1500 5150 1500
Wire Wire Line
	4850 1600 5150 1600
NoConn ~ 4850 1700
Text GLabel 5150 1100 2    60   Output ~ 0
/CS_UART
Text GLabel 5150 1200 2    60   Output ~ 0
/CS_VIA
Text GLabel 5150 1300 2    60   Output ~ 0
/CS_VDP
Text GLabel 5150 1400 2    60   Output ~ 0
/CS_IO0
Text GLabel 5150 1500 2    60   Output ~ 0
/CS_IO1
Text GLabel 5150 1600 2    60   Output ~ 0
/CS_IO2
Wire Wire Line
	4250 3950 4400 3950
Wire Wire Line
	2800 3950 2800 4050
Wire Wire Line
	2800 4050 4400 4050
Wire Wire Line
	4700 4350 4400 4350
Wire Wire Line
	4400 4350 4400 4050
Connection ~ 4700 4750
Wire Wire Line
	4700 4350 4700 5050
Wire Wire Line
	4850 1850 6200 1850
Wire Wire Line
	6200 1850 6200 2350
Wire Wire Line
	6200 2350 7400 2350
Wire Wire Line
	7400 2450 6100 2450
Wire Wire Line
	6100 2450 6100 1950
Wire Wire Line
	6100 1950 4850 1950
$Comp
L CP2 C16
U 1 1 546AA0E1
P 6650 7200
F 0 "C16" H 6650 7300 40  0000 L CNN
F 1 "CP2" H 6656 7115 40  0000 L CNN
F 2 "Capacitors_Elko_ThroughHole:Elko_vert_11.2x7.5mm_RM2.5" H 6688 7050 30  0001 C CNN
F 3 "" H 6650 7200 60  0000 C CNN
	1    6650 7200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 2850 7400 2850
Text Label 6950 2950 0    60   ~ 0
/CS_ROM
Wire Wire Line
	4850 800  6300 800 
Text Label 5150 800  0    60   ~ 0
/CS_ROM
Wire Wire Line
	6300 800  6300 2850
$Comp
L 74LS393 U4
U 2 1 54AFD26E
P 5550 5700
F 0 "U4" H 5700 5950 60  0000 C CNN
F 1 "74LS393" H 5750 5450 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 5550 5700 60  0001 C CNN
F 3 "" H 5550 5700 60  0000 C CNN
	2    5550 5700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 54AFD8A6
P 4800 6100
F 0 "#PWR021" H 4800 6100 30  0001 C CNN
F 1 "GND" H 4800 6030 30  0001 C CNN
F 2 "" H 4800 6100 60  0000 C CNN
F 3 "" H 4800 6100 60  0000 C CNN
	1    4800 6100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4800 5550 4800 6100
Wire Wire Line
	4800 5550 4850 5550
Wire Wire Line
	4850 5850 4800 5850
Connection ~ 4800 5850
Wire Wire Line
	5550 5900 5550 6000
Wire Wire Line
	5550 6000 4800 6000
Connection ~ 4800 6000
$Comp
L VCC #PWR022
U 1 1 54AFEDDA
P 5550 5350
F 0 "#PWR022" H 5550 5450 30  0001 C CNN
F 1 "VCC" H 5550 5450 30  0000 C CNN
F 2 "" H 5550 5350 60  0000 C CNN
F 3 "" H 5550 5350 60  0000 C CNN
	1    5550 5350
	1    0    0    -1  
$EndComp
Wire Wire Line
	5550 5500 5550 5350
NoConn ~ 6250 5550
NoConn ~ 6250 5650
NoConn ~ 6250 5750
NoConn ~ 6250 5850
Wire Wire Line
	10050 1250 9550 1250
Text Label 9550 1250 0    60   ~ 0
RESET_TRIG
Text Label 500  6500 0    60   ~ 0
RESET_TRIG
$Comp
L GND #PWR023
U 1 1 54B14888
P 3200 7650
F 0 "#PWR023" H 3200 7650 30  0001 C CNN
F 1 "GND" H 3200 7580 30  0001 C CNN
F 2 "" H 3200 7650 60  0000 C CNN
F 3 "" H 3200 7650 60  0000 C CNN
	1    3200 7650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3200 7450 3200 7650
Wire Wire Line
	3200 6850 3200 6600
Text Label 3200 6700 0    60   ~ 0
RESET_TRIG
Wire Wire Line
	6650 3300 6650 3400
Wire Wire Line
	8100 850  8100 1000
Wire Wire Line
	8750 3300 8750 3400
$Comp
L CONN_01X04 P6
U 1 1 54B57D9B
P 2300 950
F 0 "P6" H 2300 1200 50  0000 C CNN
F 1 "POWER" V 2400 950 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_1x04" H 2300 950 60  0001 C CNN
F 3 "" H 2300 950 60  0000 C CNN
	1    2300 950 
	1    0    0    1   
$EndComp
$Comp
L VCC #PWR024
U 1 1 54B581D7
P 2000 1100
F 0 "#PWR024" H 2000 1200 30  0001 C CNN
F 1 "VCC" H 2000 1200 30  0000 C CNN
F 2 "" H 2000 1100 60  0000 C CNN
F 3 "" H 2000 1100 60  0000 C CNN
	1    2000 1100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR025
U 1 1 54B5858D
P 1900 1200
F 0 "#PWR025" H 1900 1200 30  0001 C CNN
F 1 "GND" H 1900 1130 30  0001 C CNN
F 2 "" H 1900 1200 60  0000 C CNN
F 3 "" H 1900 1200 60  0000 C CNN
	1    1900 1200
	1    0    0    -1  
$EndComp
Wire Wire Line
	2100 900  1900 900 
Wire Wire Line
	1900 900  1900 1200
Wire Wire Line
	2100 1000 1900 1000
Connection ~ 1900 1000
$Comp
L LED D1
U 1 1 54C38B5D
P 5700 2250
F 0 "D1" H 5700 2350 50  0000 C CNN
F 1 "LED" H 5700 2150 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 5700 2250 60  0001 C CNN
F 3 "" H 5700 2250 60  0000 C CNN
	1    5700 2250
	1    0    0    -1  
$EndComp
$Comp
L LED D2
U 1 1 54C38C62
P 5700 2550
F 0 "D2" H 5700 2650 50  0000 C CNN
F 1 "LED" H 5700 2450 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 5700 2550 60  0001 C CNN
F 3 "" H 5700 2550 60  0000 C CNN
	1    5700 2550
	1    0    0    -1  
$EndComp
$Comp
L LED D3
U 1 1 54C38D3E
P 5700 2850
F 0 "D3" H 5700 2950 50  0000 C CNN
F 1 "LED" H 5700 2750 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 5700 2850 60  0001 C CNN
F 3 "" H 5700 2850 60  0000 C CNN
	1    5700 2850
	1    0    0    -1  
$EndComp
$Comp
L R R7
U 1 1 54C39594
P 5200 2250
F 0 "R7" V 5280 2250 40  0000 C CNN
F 1 "270" V 5207 2251 40  0000 C CNN
F 2 "Discret:R3" V 5130 2250 30  0001 C CNN
F 3 "" H 5200 2250 30  0000 C CNN
	1    5200 2250
	0    1    1    0   
$EndComp
$Comp
L R R8
U 1 1 54C3A498
P 5200 2550
F 0 "R8" V 5280 2550 40  0000 C CNN
F 1 "270" V 5207 2551 40  0000 C CNN
F 2 "Discret:R3" V 5130 2550 30  0001 C CNN
F 3 "" H 5200 2550 30  0000 C CNN
	1    5200 2550
	0    1    1    0   
$EndComp
$Comp
L R R9
U 1 1 54C3A4DF
P 5200 2850
F 0 "R9" V 5280 2850 40  0000 C CNN
F 1 "270" V 5207 2851 40  0000 C CNN
F 2 "Discret:R3" V 5130 2850 30  0001 C CNN
F 3 "" H 5200 2850 30  0000 C CNN
	1    5200 2850
	0    1    1    0   
$EndComp
Wire Wire Line
	4950 2100 4950 2850
$Comp
L VCC #PWR026
U 1 1 54C3BFBB
P 4950 2100
F 0 "#PWR026" H 4950 2200 30  0001 C CNN
F 1 "VCC" H 4950 2200 30  0000 C CNN
F 2 "" H 4950 2100 60  0000 C CNN
F 3 "" H 4950 2100 60  0000 C CNN
	1    4950 2100
	1    0    0    -1  
$EndComp
Connection ~ 4950 2250
Wire Wire Line
	5450 2250 5500 2250
Wire Wire Line
	5450 2550 5500 2550
Wire Wire Line
	5450 2850 5500 2850
Wire Wire Line
	5900 2250 6050 2250
Wire Wire Line
	5900 2550 6050 2550
Wire Wire Line
	5900 2850 6050 2850
Text Label 6000 2250 0    60   ~ 0
/CS_ROM
Text Label 6000 2550 0    60   ~ 0
/CS_LORAM
Text Label 6000 2850 0    60   ~ 0
/CS_HIRAM
Connection ~ 4950 2550
Connection ~ 4950 2850
NoConn ~ 2100 800 
Wire Wire Line
	2000 1100 2100 1100
$EndSCHEMATC
