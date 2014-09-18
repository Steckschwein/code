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
LIBS:xo-14s
LIBS:steckschwein-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
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
P 1950 1800
F 0 "U1" H 1950 1800 50  0000 L BNN
F 1 "W65C02SP" H 1550 200 50  0000 L BNN
F 2 "Sockets_DIP:DIP-40__600_ELL" H 1950 1950 50  0001 C CNN
F 3 "" H 1950 1800 60  0000 C CNN
	1    1950 1800
	1    0    0    -1  
$EndComp
Entry Wire Line
	2650 900  2750 800 
Entry Wire Line
	1150 800  1250 900 
Entry Wire Line
	1150 900  1250 1000
Entry Wire Line
	1150 1000 1250 1100
Entry Wire Line
	1150 1100 1250 1200
Entry Wire Line
	1150 1200 1250 1300
Entry Wire Line
	1150 1300 1250 1400
Entry Wire Line
	1150 1400 1250 1500
Entry Wire Line
	1150 1500 1250 1600
Entry Wire Line
	1150 1600 1250 1700
Entry Wire Line
	1150 1700 1250 1800
Entry Wire Line
	1150 1800 1250 1900
Entry Wire Line
	1150 1900 1250 2000
Entry Wire Line
	1150 2000 1250 2100
Entry Wire Line
	1150 2100 1250 2200
Entry Wire Line
	1150 2200 1250 2300
Entry Wire Line
	1150 2300 1250 2400
Entry Wire Line
	2650 1000 2750 900 
Entry Wire Line
	2650 1100 2750 1000
Entry Wire Line
	2650 1200 2750 1100
Entry Wire Line
	2650 1300 2750 1200
Entry Wire Line
	2650 1400 2750 1300
Entry Wire Line
	2650 1500 2750 1400
Entry Wire Line
	2650 1600 2750 1500
NoConn ~ 2550 1800
$Comp
L R R1
U 1 1 54135A46
P 900 3000
F 0 "R1" V 980 3000 40  0000 C CNN
F 1 "3.3k" V 907 3001 40  0000 C CNN
F 2 "Discret:R3" V 830 3000 30  0001 C CNN
F 3 "" H 900 3000 30  0000 C CNN
	1    900  3000
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 54135B17
P 900 2900
F 0 "R2" V 980 2900 40  0000 C CNN
F 1 "3.3k" V 907 2901 40  0000 C CNN
F 2 "Discret:R3" V 830 2900 30  0001 C CNN
F 3 "" H 900 2900 30  0000 C CNN
	1    900  2900
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 54135B4A
P 900 2700
F 0 "R3" V 980 2700 40  0000 C CNN
F 1 "3.3k" V 907 2701 40  0000 C CNN
F 2 "Discret:R3" V 830 2700 30  0001 C CNN
F 3 "" H 900 2700 30  0000 C CNN
	1    900  2700
	0    1    1    0   
$EndComp
$Comp
L R R4
U 1 1 54135B6E
P 3450 2900
F 0 "R4" V 3530 2900 40  0000 C CNN
F 1 "3.3k" V 3457 2901 40  0000 C CNN
F 2 "Discret:R3" V 3380 2900 30  0001 C CNN
F 3 "" H 3450 2900 30  0000 C CNN
	1    3450 2900
	0    1    1    0   
$EndComp
$Comp
L LM555N U2
U 1 1 54135D14
P 2300 6450
F 0 "U2" H 2300 6550 70  0000 C CNN
F 1 "LM555N" H 2300 6350 70  0000 C CNN
F 2 "Sockets_DIP:DIP-8__300_ELL" H 2300 6450 60  0001 C CNN
F 3 "" H 2300 6450 60  0000 C CNN
	1    2300 6450
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR01
U 1 1 5413678B
P 9350 5550
F 0 "#PWR01" H 9350 5650 30  0001 C CNN
F 1 "VCC" H 9350 5650 30  0000 C CNN
F 2 "" H 9350 5550 60  0000 C CNN
F 3 "" H 9350 5550 60  0000 C CNN
	1    9350 5550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 541367AD
P 9350 6100
F 0 "#PWR02" H 9350 6100 30  0001 C CNN
F 1 "GND" H 9350 6030 30  0001 C CNN
F 2 "" H 9350 6100 60  0000 C CNN
F 3 "" H 9350 6100 60  0000 C CNN
	1    9350 6100
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 541367DD
P 9350 5800
F 0 "C1" H 9350 5900 40  0000 L CNN
F 1 "100n" H 9356 5715 40  0000 L CNN
F 2 "Discret:C1" H 9388 5650 30  0001 C CNN
F 3 "" H 9350 5800 60  0000 C CNN
	1    9350 5800
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR03
U 1 1 54136970
P 2700 1950
F 0 "#PWR03" H 2700 2050 30  0001 C CNN
F 1 "VCC" H 2700 2050 30  0000 C CNN
F 2 "" H 2700 1950 60  0000 C CNN
F 3 "" H 2700 1950 60  0000 C CNN
	1    2700 1950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 541369C9
P 2700 2500
F 0 "#PWR04" H 2700 2500 30  0001 C CNN
F 1 "GND" H 2700 2430 30  0001 C CNN
F 2 "" H 2700 2500 60  0000 C CNN
F 3 "" H 2700 2500 60  0000 C CNN
	1    2700 2500
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 54136B39
P 1900 5650
F 0 "R5" V 1980 5650 40  0000 C CNN
F 1 "1M" V 1907 5651 40  0000 C CNN
F 2 "Discret:R3" V 1830 5650 30  0001 C CNN
F 3 "" H 1900 5650 30  0000 C CNN
	1    1900 5650
	0    1    1    0   
$EndComp
$Comp
L R R6
U 1 1 54136D90
P 2700 5650
F 0 "R6" V 2780 5650 40  0000 C CNN
F 1 "1M" V 2707 5651 40  0000 C CNN
F 2 "Discret:R3" V 2630 5650 30  0001 C CNN
F 3 "" H 2700 5650 30  0000 C CNN
	1    2700 5650
	0    1    1    0   
$EndComp
$Comp
L VCC #PWR05
U 1 1 54136DD8
P 2300 5550
F 0 "#PWR05" H 2300 5650 30  0001 C CNN
F 1 "VCC" H 2300 5650 30  0000 C CNN
F 2 "" H 2300 5550 60  0000 C CNN
F 3 "" H 2300 5550 60  0000 C CNN
	1    2300 5550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 541371BF
P 3050 7400
F 0 "#PWR06" H 3050 7400 30  0001 C CNN
F 1 "GND" H 3050 7330 30  0001 C CNN
F 2 "" H 3050 7400 60  0000 C CNN
F 3 "" H 3050 7400 60  0000 C CNN
	1    3050 7400
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 54137610
P 600 6900
F 0 "C2" H 600 7000 40  0000 L CNN
F 1 "10n" H 606 6815 40  0000 L CNN
F 2 "Discret:C1" H 638 6750 30  0001 C CNN
F 3 "" H 600 6900 60  0000 C CNN
	1    600  6900
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 54137759
P 1050 6900
F 0 "C3" H 1050 7000 40  0000 L CNN
F 1 "1n" H 1056 6815 40  0000 L CNN
F 2 "Discret:C1" H 1088 6750 30  0001 C CNN
F 3 "" H 1050 6900 60  0000 C CNN
	1    1050 6900
	1    0    0    -1  
$EndComp
$Comp
L CP2 C4
U 1 1 54134E8D
P 3050 6900
F 0 "C4" H 3050 7000 40  0000 L CNN
F 1 "1µ" H 3056 6815 40  0000 L CNN
F 2 "Capacitors_Elko_ThroughHole:Elko_vert_DM5_RM2-5" H 3088 6750 30  0001 C CNN
F 3 "" H 3050 6900 60  0000 C CNN
	1    3050 6900
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 4 1 541351F6
P 3900 6150
F 0 "U3" H 3900 6200 60  0000 C CNN
F 1 "74HCT00" H 3900 6050 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 3900 6150 60  0001 C CNN
F 3 "" H 3900 6150 60  0000 C CNN
	4    3900 6150
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR07
U 1 1 5413551C
P 650 2600
F 0 "#PWR07" H 650 2700 30  0001 C CNN
F 1 "VCC" H 650 2700 30  0000 C CNN
F 2 "" H 650 2600 60  0000 C CNN
F 3 "" H 650 2600 60  0000 C CNN
	1    650  2600
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR08
U 1 1 5413558F
P 3700 2800
F 0 "#PWR08" H 3700 2900 30  0001 C CNN
F 1 "VCC" H 3700 2900 30  0000 C CNN
F 2 "" H 3700 2800 60  0000 C CNN
F 3 "" H 3700 2800 60  0000 C CNN
	1    3700 2800
	1    0    0    -1  
$EndComp
$Comp
L 74LS393 U4
U 1 1 54135D32
P 3400 4600
F 0 "U4" H 3550 4850 60  0000 C CNN
F 1 "74LS393" H 3600 4350 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 3400 4600 60  0001 C CNN
F 3 "" H 3400 4600 60  0000 C CNN
	1    3400 4600
	1    0    0    -1  
$EndComp
$Comp
L C C5
U 1 1 54135F5D
P 9600 5800
F 0 "C5" H 9600 5900 40  0000 L CNN
F 1 "100n" H 9606 5715 40  0000 L CNN
F 2 "Discret:C1" H 9638 5650 30  0001 C CNN
F 3 "" H 9600 5800 60  0000 C CNN
	1    9600 5800
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR09
U 1 1 54136377
P 850 4450
F 0 "#PWR09" H 850 4550 30  0001 C CNN
F 1 "VCC" H 850 4550 30  0000 C CNN
F 2 "" H 850 4450 60  0000 C CNN
F 3 "" H 850 4450 60  0000 C CNN
	1    850  4450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR010
U 1 1 541363D2
P 850 4950
F 0 "#PWR010" H 850 4950 30  0001 C CNN
F 1 "GND" H 850 4880 30  0001 C CNN
F 2 "" H 850 4950 60  0000 C CNN
F 3 "" H 850 4950 60  0000 C CNN
	1    850  4950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR011
U 1 1 5413653F
P 2650 4950
F 0 "#PWR011" H 2650 4950 30  0001 C CNN
F 1 "GND" H 2650 4880 30  0001 C CNN
F 2 "" H 2650 4950 60  0000 C CNN
F 3 "" H 2650 4950 60  0000 C CNN
	1    2650 4950
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR012
U 1 1 5413674B
P 3400 4250
F 0 "#PWR012" H 3400 4350 30  0001 C CNN
F 1 "VCC" H 3400 4350 30  0000 C CNN
F 2 "" H 3400 4250 60  0000 C CNN
F 3 "" H 3400 4250 60  0000 C CNN
	1    3400 4250
	1    0    0    -1  
$EndComp
$Comp
L CONN_02X04 P1
U 1 1 54136830
P 4950 4600
F 0 "P1" H 4950 4850 50  0000 C CNN
F 1 "CONN_02X04" H 4950 4350 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x04" H 4950 3400 60  0001 C CNN
F 3 "" H 4950 3400 60  0000 C CNN
	1    4950 4600
	1    0    0    -1  
$EndComp
$Comp
L CONN_02X04 P2
U 1 1 541368AB
P 4950 4000
F 0 "P2" H 4950 4250 50  0000 C CNN
F 1 "CONN_02X04" H 4950 3750 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x04" H 4950 2800 60  0001 C CNN
F 3 "" H 4950 2800 60  0000 C CNN
	1    4950 4000
	1    0    0    -1  
$EndComp
$Comp
L C C6
U 1 1 541376C2
P 9850 5800
F 0 "C6" H 9850 5900 40  0000 L CNN
F 1 "100n" H 9856 5715 40  0000 L CNN
F 2 "Discret:C1" H 9888 5650 30  0001 C CNN
F 3 "" H 9850 5800 60  0000 C CNN
	1    9850 5800
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X03 P3
U 1 1 541377BD
P 4550 3000
F 0 "P3" H 4550 3200 50  0000 C CNN
F 1 "CONN_01X03" V 4650 3000 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x03" H 4550 3000 60  0001 C CNN
F 3 "" H 4550 3000 60  0000 C CNN
	1    4550 3000
	1    0    0    -1  
$EndComp
$Comp
L GAL22V10 U5
U 1 1 54137BA1
P 4050 1550
F 0 "U5" H 4100 2300 60  0000 C CNN
F 1 "GAL22V10" H 4100 800 60  0000 C CNN
F 2 "Sockets_DIP:DIP-24__300_ELL" H 4050 1550 60  0001 C CNN
F 3 "" H 4050 1550 60  0000 C CNN
	1    4050 1550
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR013
U 1 1 54137C39
P 3750 2400
F 0 "#PWR013" H 3750 2400 30  0001 C CNN
F 1 "GND" H 3750 2330 30  0001 C CNN
F 2 "" H 3750 2400 60  0000 C CNN
F 3 "" H 3750 2400 60  0000 C CNN
	1    3750 2400
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR014
U 1 1 54137DDB
P 3750 700
F 0 "#PWR014" H 3750 800 30  0001 C CNN
F 1 "VCC" H 3750 800 30  0000 C CNN
F 2 "" H 3750 700 60  0000 C CNN
F 3 "" H 3750 700 60  0000 C CNN
	1    3750 700 
	1    0    0    -1  
$EndComp
Text Label 1250 900  0    60   ~ 0
A0
$Comp
L C C7
U 1 1 54138302
P 10100 5800
F 0 "C7" H 10100 5900 40  0000 L CNN
F 1 "100n" H 10106 5715 40  0000 L CNN
F 2 "Discret:C1" H 10138 5650 30  0001 C CNN
F 3 "" H 10100 5800 60  0000 C CNN
	1    10100 5800
	1    0    0    -1  
$EndComp
Text Label 1250 1000 0    60   ~ 0
A1
Text Label 1250 1100 0    60   ~ 0
A2
Text Label 1250 1200 0    60   ~ 0
A3
Text Label 1250 1300 0    60   ~ 0
A4
Text Label 1250 1400 0    60   ~ 0
A5
Text Label 1250 1500 0    60   ~ 0
A6
Text Label 1250 1600 0    60   ~ 0
A7
Text Label 1250 1700 0    60   ~ 0
A8
Text Label 1250 1800 0    60   ~ 0
A9
Text Label 1250 1900 0    60   ~ 0
A10
Text Label 1250 2000 0    60   ~ 0
A11
Text Label 1250 2100 0    60   ~ 0
A12
Text Label 1250 2200 0    60   ~ 0
A13
Text Label 1250 2300 0    60   ~ 0
A14
Text Label 1250 2400 0    60   ~ 0
A15
Entry Wire Line
	3150 800  3250 900 
Entry Wire Line
	3150 900  3250 1000
Entry Wire Line
	3150 1000 3250 1100
Entry Wire Line
	3150 1100 3250 1200
Entry Wire Line
	3150 1200 3250 1300
Entry Wire Line
	3150 1300 3250 1400
Entry Wire Line
	3150 1400 3250 1500
Entry Wire Line
	3150 1500 3250 1600
Text Label 3250 900  0    60   ~ 0
A15
Text Label 3250 1000 0    60   ~ 0
A14
Text Label 3250 1100 0    60   ~ 0
A13
Text Label 3250 1200 0    60   ~ 0
A12
Text Label 3250 1300 0    60   ~ 0
A8
Text Label 3250 1400 0    60   ~ 0
A9
Text Label 3250 1500 0    60   ~ 0
A10
Text Label 3250 1600 0    60   ~ 0
A11
$Comp
L R R8
U 1 1 5413B2B6
P 3000 1650
F 0 "R8" V 3080 1650 40  0000 C CNN
F 1 "10k" V 3007 1651 40  0000 C CNN
F 2 "Discret:R3" V 2930 1650 30  0001 C CNN
F 3 "" H 3000 1650 30  0000 C CNN
	1    3000 1650
	-1   0    0    1   
$EndComp
$Comp
L VCC #PWR015
U 1 1 5413B569
P 3000 1250
F 0 "#PWR015" H 3000 1350 30  0001 C CNN
F 1 "VCC" H 3000 1350 30  0000 C CNN
F 2 "" H 3000 1250 60  0000 C CNN
F 3 "" H 3000 1250 60  0000 C CNN
	1    3000 1250
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 1 1 5413BC11
P 6450 6150
F 0 "U3" H 6450 6200 60  0000 C CNN
F 1 "74HCT00" H 6450 6050 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 6450 6150 60  0001 C CNN
F 3 "" H 6450 6150 60  0000 C CNN
	1    6450 6150
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 2 1 5413BCDA
P 7750 5500
F 0 "U3" H 7750 5550 60  0000 C CNN
F 1 "74HCT00" H 7750 5400 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 7750 5500 60  0001 C CNN
F 3 "" H 7750 5500 60  0000 C CNN
	2    7750 5500
	1    0    0    -1  
$EndComp
$Comp
L 74HCT00 U3
U 3 1 5413BEE8
P 7750 6050
F 0 "U3" H 7750 6100 60  0000 C CNN
F 1 "74HCT00" H 7750 5950 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 7750 6050 60  0001 C CNN
F 3 "" H 7750 6050 60  0000 C CNN
	3    7750 6050
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR016
U 1 1 5413C360
P 5600 6250
F 0 "#PWR016" H 5600 6350 30  0001 C CNN
F 1 "VCC" H 5600 6350 30  0000 C CNN
F 2 "" H 5600 6250 60  0000 C CNN
F 3 "" H 5600 6250 60  0000 C CNN
	1    5600 6250
	1    0    0    -1  
$EndComp
$Comp
L 28C256 U6
U 1 1 5413DDC9
P 7000 2000
F 0 "U6" H 7200 3000 70  0000 C CNN
F 1 "28C256" H 7300 1000 70  0000 C CNN
F 2 "Sockets_DIP:DIP-28__600_ELL" H 7000 2000 60  0001 C CNN
F 3 "" H 7000 2000 60  0000 C CNN
	1    7000 2000
	1    0    0    -1  
$EndComp
Text Label 2550 900  0    60   ~ 0
D0
Text Label 2550 1000 0    60   ~ 0
D1
Text Label 2550 1100 0    60   ~ 0
D2
Text Label 2550 1200 0    60   ~ 0
D3
Text Label 2550 1300 0    60   ~ 0
D4
Text Label 2550 1400 0    60   ~ 0
D5
Text Label 2550 1500 0    60   ~ 0
D6
Text Label 2550 1600 0    60   ~ 0
D7
$Comp
L C C8
U 1 1 5413E45B
P 10350 5800
F 0 "C8" H 10350 5900 40  0000 L CNN
F 1 "100n" H 10356 5715 40  0000 L CNN
F 2 "Discret:C1" H 10388 5650 30  0001 C CNN
F 3 "" H 10350 5800 60  0000 C CNN
	1    10350 5800
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR017
U 1 1 5413EA26
P 5900 2300
F 0 "#PWR017" H 5900 2400 30  0001 C CNN
F 1 "VCC" H 5900 2400 30  0000 C CNN
F 2 "" H 5900 2300 60  0000 C CNN
F 3 "" H 5900 2300 60  0000 C CNN
	1    5900 2300
	1    0    0    -1  
$EndComp
Text Label 8050 850  0    60   ~ 0
D
Entry Wire Line
	7850 1100 7950 1000
Entry Wire Line
	7850 1200 7950 1100
Entry Wire Line
	7850 1300 7950 1200
Entry Wire Line
	7850 1400 7950 1300
Entry Wire Line
	7850 1500 7950 1400
Entry Wire Line
	7850 1600 7950 1500
Entry Wire Line
	7850 1700 7950 1600
Entry Wire Line
	7850 1800 7950 1700
Text Label 7750 1100 0    60   ~ 0
D0
Text Label 7750 1200 0    60   ~ 0
D1
Text Label 7750 1300 0    60   ~ 0
D2
Text Label 7750 1400 0    60   ~ 0
D3
Text Label 7750 1500 0    60   ~ 0
D4
Text Label 7750 1600 0    60   ~ 0
D5
Text Label 7750 1700 0    60   ~ 0
D6
Text Label 7750 1800 0    60   ~ 0
D7
Entry Wire Line
	6050 1000 6150 1100
Entry Wire Line
	6050 1100 6150 1200
Entry Wire Line
	6050 1200 6150 1300
Entry Wire Line
	6050 1300 6150 1400
Entry Wire Line
	6050 1400 6150 1500
Entry Wire Line
	6050 1500 6150 1600
Entry Wire Line
	6050 1600 6150 1700
Entry Wire Line
	6050 1700 6150 1800
Entry Wire Line
	6050 1800 6150 1900
Entry Wire Line
	6050 1900 6150 2000
Entry Wire Line
	6050 2000 6150 2100
Entry Wire Line
	6050 2200 6150 2300
Entry Wire Line
	6050 2100 6150 2200
$Comp
L HM62256BLP-7 U7
U 1 1 5414173B
P 7000 4250
F 0 "U7" H 6700 5150 50  0000 C CNN
F 1 "HM62256BLP-7" H 7400 3450 50  0000 C CNN
F 2 "Sockets_DIP:DIP-28__600_ELL" H 7000 4250 30  0000 C CIN
F 3 "" H 7000 4250 60  0000 C CNN
	1    7000 4250
	1    0    0    -1  
$EndComp
Entry Wire Line
	6250 3400 6350 3500
Entry Wire Line
	6250 3500 6350 3600
Entry Wire Line
	6250 3600 6350 3700
Entry Wire Line
	6250 3700 6350 3800
Entry Wire Line
	6250 3800 6350 3900
Entry Wire Line
	6250 3900 6350 4000
Entry Wire Line
	6250 4000 6350 4100
Entry Wire Line
	6250 4100 6350 4200
Entry Wire Line
	6250 4200 6350 4300
Entry Wire Line
	6250 4300 6350 4400
Entry Wire Line
	6250 4400 6350 4500
Entry Wire Line
	6250 4500 6350 4600
Entry Wire Line
	6250 4600 6350 4700
Entry Wire Line
	6250 4700 6350 4800
Entry Wire Line
	6250 4800 6350 4900
Entry Wire Line
	7700 3500 7800 3400
Entry Wire Line
	7700 3600 7800 3500
Entry Wire Line
	7700 3700 7800 3600
Entry Wire Line
	7700 3800 7800 3700
Entry Wire Line
	7700 3900 7800 3800
Entry Wire Line
	7700 4000 7800 3900
Entry Wire Line
	7700 4100 7800 4000
Entry Wire Line
	7700 4200 7800 4100
Text Label 7550 4600 0    60   ~ 0
A15
$Comp
L C C9
U 1 1 54146339
P 10600 5800
F 0 "C9" H 10600 5900 40  0000 L CNN
F 1 "100n" H 10606 5715 40  0000 L CNN
F 2 "Discret:C1" H 10638 5650 30  0001 C CNN
F 3 "" H 10600 5800 60  0000 C CNN
	1    10600 5800
	1    0    0    -1  
$EndComp
$Comp
L C C10
U 1 1 54146372
P 10850 5800
F 0 "C10" H 10850 5900 40  0000 L CNN
F 1 "100n" H 10856 5715 40  0000 L CNN
F 2 "Discret:C1" H 10888 5650 30  0001 C CNN
F 3 "" H 10850 5800 60  0000 C CNN
	1    10850 5800
	1    0    0    -1  
$EndComp
$Comp
L SW_PUSH SW1
U 1 1 54147B44
P 800 6800
F 0 "SW1" H 950 6910 50  0000 C CNN
F 1 "SW_PUSH" H 800 6720 50  0000 C CNN
F 2 "Discret:PUSH_BUTT_SHAPE1" H 800 6800 60  0001 C CNN
F 3 "" H 800 6800 60  0000 C CNN
	1    800  6800
	0    1    1    0   
$EndComp
Text Label 6200 1100 0    60   ~ 0
A0
Text Label 6200 1200 0    60   ~ 0
A1
Text Label 6200 1300 0    60   ~ 0
A2
Text Label 6200 1400 0    60   ~ 0
A3
Text Label 6200 1500 0    60   ~ 0
A4
Text Label 6200 1600 0    60   ~ 0
A5
Text Label 6200 1700 0    60   ~ 0
A6
Text Label 6200 1800 0    60   ~ 0
A7
Text Label 6200 1900 0    60   ~ 0
A8
Text Label 6200 2000 0    60   ~ 0
A9
Text Label 6200 2100 0    60   ~ 0
A10
Text Label 6200 2200 0    60   ~ 0
A11
Text Label 6200 2300 0    60   ~ 0
A12
Text Label 6350 3500 0    60   ~ 0
A0
Text Label 6350 3600 0    60   ~ 0
A1
Text Label 6350 3700 0    60   ~ 0
A2
Text Label 6350 3800 0    60   ~ 0
A3
Text Label 6350 3900 0    60   ~ 0
A4
Text Label 6350 4000 0    60   ~ 0
A5
Text Label 6350 4100 0    60   ~ 0
A6
Text Label 6350 4200 0    60   ~ 0
A7
Text Label 6350 4300 0    60   ~ 0
A8
Text Label 6350 4400 0    60   ~ 0
A9
Text Label 6350 4500 0    60   ~ 0
A10
Text Label 6350 4600 0    60   ~ 0
A11
Text Label 6350 4700 0    60   ~ 0
A12
Text Label 6350 4800 0    60   ~ 0
A13
Text Label 6350 4900 0    60   ~ 0
A14
Text Label 7600 3500 0    60   ~ 0
D0
Text Label 7600 3600 0    60   ~ 0
D1
Text Label 7600 3700 0    60   ~ 0
D2
Text Label 7600 3800 0    60   ~ 0
D3
Text Label 7600 3900 0    60   ~ 0
D4
Text Label 7600 4000 0    60   ~ 0
D5
Text Label 7600 4100 0    60   ~ 0
D6
Text Label 7600 4200 0    60   ~ 0
D7
$Comp
L HM62256BLP-7 U8
U 1 1 5414AE2F
P 8800 4250
F 0 "U8" H 8500 5150 50  0000 C CNN
F 1 "HM62256BLP-7" H 9200 3450 50  0000 C CNN
F 2 "Sockets_DIP:DIP-28__600_ELL" H 8800 4250 30  0000 C CIN
F 3 "" H 8800 4250 60  0000 C CNN
	1    8800 4250
	1    0    0    -1  
$EndComp
Entry Wire Line
	8050 3400 8150 3500
Entry Wire Line
	8050 3500 8150 3600
Entry Wire Line
	8050 3600 8150 3700
Entry Wire Line
	8050 3700 8150 3800
Entry Wire Line
	8050 3800 8150 3900
Entry Wire Line
	8050 3900 8150 4000
Entry Wire Line
	8050 4000 8150 4100
Entry Wire Line
	8050 4100 8150 4200
Entry Wire Line
	8050 4200 8150 4300
Entry Wire Line
	8050 4300 8150 4400
Entry Wire Line
	8050 4400 8150 4500
Entry Wire Line
	8050 4500 8150 4600
Entry Wire Line
	8050 4600 8150 4700
Entry Wire Line
	8050 4700 8150 4800
Entry Wire Line
	8050 4800 8150 4900
Entry Wire Line
	9500 3500 9600 3400
Entry Wire Line
	9500 3600 9600 3500
Entry Wire Line
	9500 3700 9600 3600
Entry Wire Line
	9500 3800 9600 3700
Entry Wire Line
	9500 3900 9600 3800
Entry Wire Line
	9500 4000 9600 3900
Entry Wire Line
	9500 4100 9600 4000
Entry Wire Line
	9500 4200 9600 4100
Text Label 8150 3500 0    60   ~ 0
A0
Text Label 8150 3600 0    60   ~ 0
A1
Text Label 8150 3700 0    60   ~ 0
A2
Text Label 8150 3800 0    60   ~ 0
A3
Text Label 8150 3900 0    60   ~ 0
A4
Text Label 8150 4000 0    60   ~ 0
A5
Text Label 8150 4100 0    60   ~ 0
A6
Text Label 8150 4200 0    60   ~ 0
A7
Text Label 8150 4300 0    60   ~ 0
A8
Text Label 8150 4400 0    60   ~ 0
A9
Text Label 8150 4500 0    60   ~ 0
A10
Text Label 8150 4600 0    60   ~ 0
A11
Text Label 8150 4700 0    60   ~ 0
A12
Text Label 8150 4800 0    60   ~ 0
A13
Text Label 8150 4900 0    60   ~ 0
A14
Text Label 9400 3500 0    60   ~ 0
D0
Text Label 9400 3600 0    60   ~ 0
D1
Text Label 9400 3700 0    60   ~ 0
D2
Text Label 9400 3800 0    60   ~ 0
D3
Text Label 9400 3900 0    60   ~ 0
D4
Text Label 9400 4000 0    60   ~ 0
D5
Text Label 9400 4100 0    60   ~ 0
D6
Text Label 9400 4200 0    60   ~ 0
D7
$Comp
L TCXO3 X1
U 1 1 54143582
P 1650 4600
F 0 "X1" H 1650 4900 70  0000 C CNN
F 1 "TCXO3" H 1650 4600 70  0000 C CNN
F 2 "Discret:OSC_DIP8" H 1650 4600 60  0001 C CNN
F 3 "" H 1650 4600 60  0000 C CNN
	1    1650 4600
	1    0    0    -1  
$EndComp
Text GLabel 1150 2800 0    60   Input ~ 0
/RESET
Text GLabel 4250 2900 0    60   Input ~ 0
PH0-IN
Text GLabel 4250 3000 0    60   Input ~ 0
PHI2
Text GLabel 5200 5000 3    60   Input ~ 0
PH0-IN
Text GLabel 5200 3700 1    60   Input ~ 0
CLK1
Text GLabel 6100 2800 0    60   Input ~ 0
/OE
Text GLabel 6100 2900 0    60   Input ~ 0
/CS_ROM
Text GLabel 7700 4350 2    60   Input ~ 0
/OE
Text GLabel 7700 4450 2    60   Input ~ 0
/WE
Text GLabel 9500 4350 2    60   Input ~ 0
/OE
Text GLabel 9500 4450 2    60   Input ~ 0
/WE
Text GLabel 9500 4600 2    60   Input ~ 0
/CS_HIRAM
Text GLabel 1150 3100 0    60   Input ~ 0
/RW
Text GLabel 3300 1700 0    60   Input ~ 0
/RW
Text GLabel 5600 5800 0    60   Input ~ 0
/RW
Text GLabel 6950 5800 0    60   Input ~ 0
PHI2
Text GLabel 8550 5500 2    60   Input ~ 0
/OE
Text GLabel 8550 6050 2    60   Input ~ 0
/WE
Text GLabel 5150 900  2    60   Output ~ 0
/CS_RES02
Text GLabel 5150 1000 2    60   Output ~ 0
/CSW_VDP
Text GLabel 5150 1100 2    60   Output ~ 0
/CSR_VDP
Text GLabel 5150 1200 2    60   Output ~ 0
E_LCD
Text GLabel 5150 1300 2    60   Output ~ 0
/CS_VIA
Text GLabel 5150 1400 2    60   Output ~ 0
/CS_UART
Text GLabel 5150 1500 2    60   Output ~ 0
/CS_HIRAM
Text GLabel 5150 1600 2    60   Output ~ 0
/CS_RES01
Text GLabel 5150 1700 2    60   Output ~ 0
/CS_RES00
Text GLabel 5150 1800 2    60   Output ~ 0
/CS_ROM
Text GLabel 4600 6150 2    60   Input ~ 0
/RESET
Text GLabel 3300 1800 0    60   Input ~ 0
PHI2
Text GLabel 3300 1900 0    60   Input ~ 0
CLK1
Text GLabel 3000 2000 3    60   Input ~ 0
/ROMOFF
NoConn ~ 2350 4750
NoConn ~ 2550 2700
NoConn ~ 2550 3000
NoConn ~ 1350 2600
NoConn ~ 1350 3200
NoConn ~ 7850 5600
$Comp
L CONN_02X02 P4
U 1 1 541492CC
P 2950 2850
F 0 "P4" H 2950 3000 50  0000 C CNN
F 1 "CONN_02X02" H 2950 2700 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x02" H 2950 1650 60  0001 C CNN
F 3 "" H 2950 1650 60  0000 C CNN
	1    2950 2850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR018
U 1 1 5414A44F
P 3350 2700
F 0 "#PWR018" H 3350 2700 30  0001 C CNN
F 1 "GND" H 3350 2630 30  0001 C CNN
F 2 "" H 3350 2700 60  0000 C CNN
F 3 "" H 3350 2700 60  0000 C CNN
	1    3350 2700
	1    0    0    -1  
$EndComp
Text GLabel 2750 3200 2    60   Input ~ 0
PH0-IN
Wire Bus Line
	1150 650  1150 2300
Wire Bus Line
	2750 700  2750 1500
Wire Wire Line
	1250 2400 1350 2400
Wire Wire Line
	1250 2300 1350 2300
Wire Wire Line
	1250 2200 1350 2200
Wire Wire Line
	1250 2100 1350 2100
Wire Wire Line
	1250 2000 1350 2000
Wire Wire Line
	1250 1900 1350 1900
Wire Wire Line
	1250 1800 1350 1800
Wire Wire Line
	1250 1700 1350 1700
Wire Wire Line
	1250 1600 1350 1600
Wire Wire Line
	1250 1500 1350 1500
Wire Wire Line
	1250 1400 1350 1400
Wire Wire Line
	1250 1300 1350 1300
Wire Wire Line
	1250 1200 1350 1200
Wire Wire Line
	1250 1100 1350 1100
Wire Wire Line
	1250 1000 1350 1000
Wire Wire Line
	1250 900  1350 900 
Wire Wire Line
	2550 900  2650 900 
Wire Wire Line
	2550 1000 2650 1000
Wire Wire Line
	2550 1100 2650 1100
Wire Wire Line
	2550 1200 2650 1200
Wire Wire Line
	2550 1300 2650 1300
Wire Wire Line
	2550 1400 2650 1400
Wire Wire Line
	2550 1500 2650 1500
Wire Wire Line
	2550 1600 2650 1600
Wire Wire Line
	1150 2700 1350 2700
Wire Wire Line
	1150 2900 1350 2900
Wire Wire Line
	1150 3000 1350 3000
Wire Wire Line
	3300 6050 3300 6250
Wire Wire Line
	3300 6250 3000 6250
Wire Wire Line
	1150 2800 1350 2800
Wire Wire Line
	4500 6150 4600 6150
Wire Wire Line
	9350 5550 9350 5600
Wire Wire Line
	9350 6000 9350 6100
Wire Wire Line
	2550 2000 2700 2000
Wire Wire Line
	2700 2000 2700 1950
Wire Wire Line
	2550 2400 2700 2400
Wire Wire Line
	2700 2400 2700 2500
Wire Wire Line
	2300 5550 2300 6050
Wire Wire Line
	2150 5650 2450 5650
Connection ~ 2300 5650
Wire Wire Line
	2950 5650 3050 5650
Wire Wire Line
	3050 5650 3050 6700
Wire Wire Line
	3050 6450 3000 6450
Wire Wire Line
	3050 6650 3000 6650
Connection ~ 3050 6450
Wire Wire Line
	1600 6750 1300 6750
Wire Wire Line
	1300 6750 1300 5850
Wire Wire Line
	1300 5850 2300 5850
Connection ~ 2300 5850
Wire Wire Line
	600  5650 1650 5650
Wire Wire Line
	600  5650 600  6700
Wire Wire Line
	600  6250 1600 6250
Connection ~ 600  6250
Wire Wire Line
	1600 6500 1050 6500
Wire Wire Line
	1050 6500 1050 6700
Wire Wire Line
	600  7100 600  7250
Wire Wire Line
	600  7250 3050 7250
Wire Wire Line
	1050 7100 1050 7250
Connection ~ 1050 7250
Wire Wire Line
	3050 7100 3050 7400
Connection ~ 3050 6650
Connection ~ 3050 7250
Wire Wire Line
	650  2600 650  3000
Connection ~ 650  2900
Connection ~ 650  2700
Wire Wire Line
	9350 5600 10950 5600
Wire Wire Line
	9350 6000 10950 6000
Wire Wire Line
	2650 4750 2650 4950
Wire Wire Line
	2650 4750 2700 4750
Wire Wire Line
	3400 4800 3400 4900
Wire Wire Line
	3400 4900 2650 4900
Connection ~ 2650 4900
Wire Wire Line
	3400 4250 3400 4400
Wire Wire Line
	4100 4450 4700 4450
Wire Wire Line
	4100 4550 4700 4550
Wire Wire Line
	4100 4650 4700 4650
Wire Wire Line
	4100 4750 4700 4750
Wire Wire Line
	4700 4150 4550 4150
Wire Wire Line
	4550 4150 4550 4750
Connection ~ 4550 4750
Wire Wire Line
	4700 4050 4450 4050
Wire Wire Line
	4450 4050 4450 4650
Connection ~ 4450 4650
Wire Wire Line
	4700 3950 4350 3950
Wire Wire Line
	4350 3950 4350 4550
Connection ~ 4350 4550
Wire Wire Line
	4700 3850 4250 3850
Wire Wire Line
	4250 3850 4250 4450
Connection ~ 4250 4450
Wire Wire Line
	5200 3700 5200 4150
Connection ~ 5200 4050
Connection ~ 5200 3950
Connection ~ 5200 3850
Wire Wire Line
	5200 4450 5200 5000
Connection ~ 5200 4650
Connection ~ 5200 4550
Connection ~ 5200 4750
Wire Wire Line
	2550 3200 2750 3200
Wire Wire Line
	2550 3100 4350 3100
Wire Wire Line
	4350 2900 4250 2900
Wire Wire Line
	4350 3000 4250 3000
Wire Wire Line
	3750 2250 3750 2400
Wire Wire Line
	3750 700  3750 850 
Wire Bus Line
	3150 700  3150 1500
Wire Wire Line
	3250 900  3350 900 
Wire Wire Line
	3250 1000 3350 1000
Wire Wire Line
	3250 1100 3350 1100
Wire Wire Line
	3250 1200 3350 1200
Wire Wire Line
	3250 1300 3350 1300
Wire Wire Line
	3250 1400 3350 1400
Wire Wire Line
	3250 1500 3350 1500
Wire Wire Line
	3250 1600 3350 1600
Wire Wire Line
	4750 1800 5150 1800
Wire Wire Line
	4750 1700 5150 1700
Wire Wire Line
	4750 1600 5150 1600
Wire Wire Line
	4750 1500 5150 1500
Wire Wire Line
	4750 1400 5150 1400
Wire Wire Line
	4750 1300 5150 1300
Wire Wire Line
	4750 1200 5150 1200
Wire Wire Line
	4750 1100 5150 1100
Wire Wire Line
	4750 1000 5150 1000
Wire Wire Line
	4750 900  5150 900 
Wire Wire Line
	1350 3100 1150 3100
Wire Wire Line
	3350 1700 3300 1700
Wire Wire Line
	3350 1800 3300 1800
Wire Wire Line
	3350 1900 3300 1900
Wire Wire Line
	3000 2000 3350 2000
Wire Wire Line
	3000 1900 3000 2000
Wire Wire Line
	3000 1250 3000 1400
Wire Wire Line
	5600 5800 5850 5800
Wire Wire Line
	5850 5400 5850 6050
Wire Wire Line
	5850 6250 5600 6250
Wire Wire Line
	7050 6150 7150 6150
Wire Wire Line
	7150 5400 5850 5400
Connection ~ 5850 5800
Wire Wire Line
	7150 5600 7150 5950
Wire Wire Line
	7150 5800 6950 5800
Connection ~ 7150 5800
Wire Wire Line
	8350 5500 8550 5500
Wire Wire Line
	8350 6050 8550 6050
Wire Wire Line
	6300 2400 5900 2400
Wire Wire Line
	5900 2500 6300 2500
Wire Wire Line
	5900 2300 5900 2700
Connection ~ 5900 2400
Wire Wire Line
	5900 2700 6300 2700
Wire Wire Line
	6300 2800 6100 2800
Wire Wire Line
	6300 2900 6100 2900
Wire Bus Line
	7950 800  7950 1700
Wire Wire Line
	7850 1800 7700 1800
Wire Wire Line
	7850 1700 7700 1700
Wire Wire Line
	7850 1600 7700 1600
Wire Wire Line
	7850 1500 7700 1500
Wire Wire Line
	7850 1400 7700 1400
Wire Wire Line
	7700 1300 7850 1300
Wire Wire Line
	7700 1200 7850 1200
Wire Wire Line
	7700 1100 7850 1100
Wire Bus Line
	6050 800  6050 2200
Wire Wire Line
	6150 2300 6300 2300
Wire Wire Line
	6150 2200 6300 2200
Wire Wire Line
	6150 2100 6300 2100
Wire Wire Line
	6150 2000 6300 2000
Wire Wire Line
	6150 1900 6300 1900
Wire Wire Line
	6150 1800 6300 1800
Wire Wire Line
	6150 1700 6300 1700
Wire Wire Line
	6150 1600 6300 1600
Wire Wire Line
	6150 1500 6300 1500
Wire Wire Line
	6150 1400 6300 1400
Wire Wire Line
	6150 1300 6300 1300
Wire Wire Line
	6150 1200 6300 1200
Wire Wire Line
	6150 1100 6300 1100
Wire Bus Line
	6250 3300 6250 4800
Wire Wire Line
	6350 4900 6450 4900
Wire Wire Line
	6350 4800 6450 4800
Wire Wire Line
	6350 4700 6450 4700
Wire Wire Line
	6350 4600 6450 4600
Wire Wire Line
	6350 4500 6450 4500
Wire Wire Line
	6350 4400 6450 4400
Wire Wire Line
	6350 4300 6450 4300
Wire Wire Line
	6350 4200 6450 4200
Wire Wire Line
	6350 4100 6450 4100
Wire Wire Line
	6350 4000 6450 4000
Wire Wire Line
	6350 3900 6450 3900
Wire Wire Line
	6350 3800 6450 3800
Wire Wire Line
	6350 3700 6450 3700
Wire Wire Line
	6350 3600 6450 3600
Wire Wire Line
	6350 3500 6450 3500
Wire Bus Line
	7800 3300 7800 4100
Wire Wire Line
	7550 3500 7700 3500
Wire Wire Line
	7550 3600 7700 3600
Wire Wire Line
	7550 3700 7700 3700
Wire Wire Line
	7550 3800 7700 3800
Wire Wire Line
	7550 3900 7700 3900
Wire Wire Line
	7550 4000 7700 4000
Wire Wire Line
	7550 4100 7700 4100
Wire Wire Line
	7550 4200 7700 4200
Wire Wire Line
	7550 4350 7700 4350
Wire Wire Line
	7550 4450 7700 4450
Wire Wire Line
	7550 4600 7700 4600
Connection ~ 9600 5600
Connection ~ 9850 5600
Connection ~ 10100 5600
Connection ~ 10350 5600
Connection ~ 10350 6000
Connection ~ 10100 6000
Connection ~ 9850 6000
Connection ~ 9600 6000
Connection ~ 10600 5600
Connection ~ 10850 5600
Connection ~ 10850 6000
Connection ~ 10600 6000
Wire Wire Line
	800  6500 800  6250
Connection ~ 800  6250
Wire Wire Line
	800  7100 800  7250
Connection ~ 800  7250
Wire Bus Line
	8050 3300 8050 4800
Wire Wire Line
	8150 4900 8250 4900
Wire Wire Line
	8150 4800 8250 4800
Wire Wire Line
	8150 4700 8250 4700
Wire Wire Line
	8150 4600 8250 4600
Wire Wire Line
	8150 4500 8250 4500
Wire Wire Line
	8150 4400 8250 4400
Wire Wire Line
	8150 4300 8250 4300
Wire Wire Line
	8150 4200 8250 4200
Wire Wire Line
	8150 4100 8250 4100
Wire Wire Line
	8150 4000 8250 4000
Wire Wire Line
	8150 3900 8250 3900
Wire Wire Line
	8150 3800 8250 3800
Wire Wire Line
	8150 3700 8250 3700
Wire Wire Line
	8150 3600 8250 3600
Wire Wire Line
	8150 3500 8250 3500
Wire Bus Line
	9600 3300 9600 4100
Wire Wire Line
	9350 3500 9500 3500
Wire Wire Line
	9350 3600 9500 3600
Wire Wire Line
	9350 3700 9500 3700
Wire Wire Line
	9350 3800 9500 3800
Wire Wire Line
	9350 3900 9500 3900
Wire Wire Line
	9350 4000 9500 4000
Wire Wire Line
	9350 4100 9500 4100
Wire Wire Line
	9350 4200 9500 4200
Wire Wire Line
	9350 4350 9500 4350
Wire Wire Line
	9350 4450 9500 4450
Wire Wire Line
	9350 4600 9500 4600
Wire Wire Line
	850  4450 950  4450
Wire Wire Line
	850  4750 850  4950
Wire Wire Line
	2350 4450 2700 4450
Wire Wire Line
	850  4750 950  4750
Connection ~ 5900 2500
Wire Wire Line
	2550 2900 2700 2900
Wire Wire Line
	2550 2800 2700 2800
Wire Wire Line
	3700 2800 3700 2900
Wire Wire Line
	3200 2800 3200 2650
Wire Wire Line
	3200 2650 3350 2650
Wire Wire Line
	3350 2650 3350 2700
Text Label 6050 850  0    60   ~ 0
A
Text Label 6250 3400 0    60   ~ 0
A
Text Label 8050 3350 0    60   ~ 0
A
Text Label 1150 600  0    60   ~ 0
A
Text Label 3150 700  0    60   ~ 0
A
Text Label 2750 800  0    60   ~ 0
D
Text Label 7800 3350 0    60   ~ 0
D
Text Label 9600 3400 0    60   ~ 0
D
$Comp
L CONN_02X25 P?
U 1 1 5419EC50
P 10000 2100
F 0 "P?" H 10000 3400 50  0000 C CNN
F 1 "CONN_02X25" V 10000 2100 50  0000 C CNN
F 2 "" H 10000 1350 60  0000 C CNN
F 3 "" H 10000 1350 60  0000 C CNN
	1    10000 2100
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR?
U 1 1 5419EC57
P 9650 750
F 0 "#PWR?" H 9650 850 30  0001 C CNN
F 1 "VCC" H 9650 850 30  0000 C CNN
F 2 "" H 9650 750 60  0000 C CNN
F 3 "" H 9650 750 60  0000 C CNN
	1    9650 750 
	1    0    0    -1  
$EndComp
Wire Wire Line
	9650 750  9650 900 
Wire Wire Line
	9650 900  9750 900 
Wire Wire Line
	10250 900  10300 900 
Text GLabel 10300 900  2    60   Input ~ 0
/RESET
Text GLabel 10300 1000 2    60   Input ~ 0
/IRQ
Wire Wire Line
	10250 1000 10300 1000
Wire Wire Line
	9750 1000 9700 1000
Text GLabel 9700 1000 0    60   Input ~ 0
/NMI
Wire Bus Line
	9300 1050 9300 1400
Entry Wire Line
	9300 1100 9400 1200
Entry Wire Line
	9300 1200 9400 1300
Entry Wire Line
	9300 1300 9400 1400
Entry Wire Line
	9300 1400 9400 1500
Wire Wire Line
	9400 1200 9750 1200
Wire Wire Line
	9400 1300 9750 1300
Wire Wire Line
	9400 1400 9750 1400
Wire Wire Line
	9400 1500 9750 1500
Text Label 9400 1200 0    60   ~ 0
D7
Text Label 9400 1300 0    60   ~ 0
D5
Text Label 9400 1400 0    60   ~ 0
D3
Text Label 9400 1500 0    60   ~ 0
D1
Wire Bus Line
	10750 1050 10750 1400
Entry Wire Line
	10650 1200 10750 1100
Entry Wire Line
	10650 1300 10750 1200
Entry Wire Line
	10650 1400 10750 1300
Entry Wire Line
	10650 1500 10750 1400
Wire Wire Line
	10250 1200 10650 1200
Wire Wire Line
	10250 1300 10650 1300
Wire Wire Line
	10250 1400 10650 1400
Wire Wire Line
	10250 1500 10650 1500
Wire Wire Line
	10250 1600 10300 1600
Text GLabel 10300 1600 2    60   Input ~ 0
/RW
Text GLabel 10300 1700 2    60   Input ~ 0
RDY
Wire Wire Line
	10250 1700 10300 1700
Wire Wire Line
	9750 1900 9700 1900
Text GLabel 9700 1900 0    60   Input ~ 0
E_LCD
Wire Wire Line
	10250 1900 10300 1900
Text GLabel 10300 1900 2    60   Input ~ 0
/CS_VIA
Text GLabel 9700 2000 0    60   Input ~ 0
/CS_UART
Wire Wire Line
	9750 2000 9700 2000
Text GLabel 10300 2000 2    60   Input ~ 0
/CSR_VDP
Text GLabel 9700 2100 0    60   Input ~ 0
/CSW_VDP
Wire Wire Line
	9700 2100 9750 2100
Wire Wire Line
	10250 2000 10300 2000
Wire Bus Line
	10900 2000 10900 2400
Entry Wire Line
	10800 2100 10900 2000
Entry Wire Line
	10800 2200 10900 2100
Entry Wire Line
	10800 2300 10900 2200
Wire Wire Line
	10250 2100 10800 2100
Wire Wire Line
	10250 2200 10800 2200
Wire Wire Line
	10250 2300 10800 2300
Wire Bus Line
	9100 2100 9100 2350
Entry Wire Line
	9100 2100 9200 2200
Entry Wire Line
	9100 2200 9200 2300
Wire Wire Line
	9200 2200 9750 2200
Wire Wire Line
	9200 2300 9750 2300
$Comp
L GND #PWR?
U 1 1 5419EC95
P 9150 2450
F 0 "#PWR?" H 9150 2450 30  0001 C CNN
F 1 "GND" H 9150 2380 30  0001 C CNN
F 2 "" H 9150 2450 60  0000 C CNN
F 3 "" H 9150 2450 60  0000 C CNN
	1    9150 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9150 2450 9150 2400
Wire Wire Line
	9150 2400 9750 2400
$Comp
L GND #PWR?
U 1 1 5419EC9D
P 10800 2450
F 0 "#PWR?" H 10800 2450 30  0001 C CNN
F 1 "GND" H 10800 2380 30  0001 C CNN
F 2 "" H 10800 2450 60  0000 C CNN
F 3 "" H 10800 2450 60  0000 C CNN
	1    10800 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	10250 2400 10800 2400
Wire Wire Line
	10800 2400 10800 2450
Wire Wire Line
	9750 2500 9700 2500
Wire Wire Line
	9750 2600 9700 2600
Wire Wire Line
	10250 2500 10300 2500
Text GLabel 9700 2500 0    60   Input ~ 0
/OE
Text GLabel 9700 2600 0    60   Input ~ 0
PHI2
Text GLabel 10300 2500 2    60   Input ~ 0
/WE
Text Label 10550 1200 0    60   ~ 0
D6
Text Label 10550 1300 0    60   ~ 0
D4
Text Label 10550 1400 0    60   ~ 0
D2
Text Label 10550 1500 0    60   ~ 0
D0
Text Label 10700 2300 0    60   ~ 0
A0
Text Label 10700 2200 0    60   ~ 0
A2
Text Label 10700 2100 0    60   ~ 0
A4
Text Label 9200 2300 0    60   ~ 0
A1
Text Label 9200 2200 0    60   ~ 0
A3
Text Label 10750 1050 0    60   ~ 0
D
Text Label 9300 1050 0    60   ~ 0
D
Text Label 9050 2150 0    60   ~ 0
A
Text Label 10900 2000 0    60   ~ 0
A
$EndSCHEMATC
