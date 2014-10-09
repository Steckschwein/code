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
Sheet 1 2
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
P 750 3000
F 0 "R1" V 830 3000 40  0000 C CNN
F 1 "3.3k" V 757 3001 40  0000 C CNN
F 2 "Discret:R3" V 680 3000 30  0001 C CNN
F 3 "" H 750 3000 30  0000 C CNN
	1    750  3000
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 54135B17
P 750 2900
F 0 "R2" V 830 2900 40  0000 C CNN
F 1 "3.3k" V 757 2901 40  0000 C CNN
F 2 "Discret:R3" V 680 2900 30  0001 C CNN
F 3 "" H 750 2900 30  0000 C CNN
	1    750  2900
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 54135B4A
P 750 2700
F 0 "R3" V 830 2700 40  0000 C CNN
F 1 "3.3k" V 757 2701 40  0000 C CNN
F 2 "Discret:R3" V 680 2700 30  0001 C CNN
F 3 "" H 750 2700 30  0000 C CNN
	1    750  2700
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
P 8900 5600
F 0 "#PWR01" H 8900 5700 30  0001 C CNN
F 1 "VCC" H 8900 5700 30  0000 C CNN
F 2 "" H 8900 5600 60  0000 C CNN
F 3 "" H 8900 5600 60  0000 C CNN
	1    8900 5600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 541367AD
P 8900 6150
F 0 "#PWR02" H 8900 6150 30  0001 C CNN
F 1 "GND" H 8900 6080 30  0001 C CNN
F 2 "" H 8900 6150 60  0000 C CNN
F 3 "" H 8900 6150 60  0000 C CNN
	1    8900 6150
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 541367DD
P 8900 5850
F 0 "C1" H 8900 5950 40  0000 L CNN
F 1 "100n" H 8906 5765 40  0000 L CNN
F 2 "Discret:C1" H 8938 5700 30  0001 C CNN
F 3 "" H 8900 5850 60  0000 C CNN
	1    8900 5850
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
P 500 2600
F 0 "#PWR07" H 500 2700 30  0001 C CNN
F 1 "VCC" H 500 2700 30  0000 C CNN
F 2 "" H 500 2600 60  0000 C CNN
F 3 "" H 500 2600 60  0000 C CNN
	1    500  2600
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
P 9150 5850
F 0 "C5" H 9150 5950 40  0000 L CNN
F 1 "100n" H 9156 5765 40  0000 L CNN
F 2 "Discret:C1" H 9188 5700 30  0001 C CNN
F 3 "" H 9150 5850 60  0000 C CNN
	1    9150 5850
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
	1    0    0    -1  
$EndComp
$Comp
L C C6
U 1 1 541376C2
P 9400 5850
F 0 "C6" H 9400 5950 40  0000 L CNN
F 1 "100n" H 9406 5765 40  0000 L CNN
F 2 "Discret:C1" H 9438 5700 30  0001 C CNN
F 3 "" H 9400 5850 60  0000 C CNN
	1    9400 5850
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
P 9650 5850
F 0 "C7" H 9650 5950 40  0000 L CNN
F 1 "100n" H 9656 5765 40  0000 L CNN
F 2 "Discret:C1" H 9688 5700 30  0001 C CNN
F 3 "" H 9650 5850 60  0000 C CNN
	1    9650 5850
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
$Comp
L R R8
U 1 1 5413B2B6
P 5450 1250
F 0 "R8" V 5530 1250 40  0000 C CNN
F 1 "10k" V 5457 1251 40  0000 C CNN
F 2 "Discret:R3" V 5380 1250 30  0001 C CNN
F 3 "" H 5450 1250 30  0000 C CNN
	1    5450 1250
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
P 9900 5850
F 0 "C8" H 9900 5950 40  0000 L CNN
F 1 "100n" H 9906 5765 40  0000 L CNN
F 2 "Discret:C1" H 9938 5700 30  0001 C CNN
F 3 "" H 9900 5850 60  0000 C CNN
	1    9900 5850
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR016
U 1 1 5413EA26
P 7000 2550
F 0 "#PWR016" H 7000 2650 30  0001 C CNN
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
P 10150 5850
F 0 "C9" H 10150 5950 40  0000 L CNN
F 1 "100n" H 10156 5765 40  0000 L CNN
F 2 "Discret:C1" H 10188 5700 30  0001 C CNN
F 3 "" H 10150 5850 60  0000 C CNN
	1    10150 5850
	1    0    0    -1  
$EndComp
$Comp
L C C10
U 1 1 54146372
P 10400 5850
F 0 "C10" H 10400 5950 40  0000 L CNN
F 1 "100n" H 10406 5765 40  0000 L CNN
F 2 "Discret:C1" H 10438 5700 30  0001 C CNN
F 3 "" H 10400 5850 60  0000 C CNN
	1    10400 5850
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
Text GLabel 1000 2800 0    60   Input ~ 0
/RESET
Text GLabel 4250 2900 0    60   Input ~ 0
PH0-IN
Text GLabel 4250 3000 0    60   Input ~ 0
PHI2
Text GLabel 4700 5300 3    60   Input ~ 0
PH0-IN
Text GLabel 7200 2750 0    60   Input ~ 0
/OE
Text GLabel 7200 2850 0    60   Input ~ 0
/CS_ROM
Text GLabel 7350 4350 2    60   Input ~ 0
/OE
Text GLabel 7350 4450 2    60   Input ~ 0
/WE
Text GLabel 9450 4350 2    60   Input ~ 0
/OE
Text GLabel 9450 4450 2    60   Input ~ 0
/WE
Text GLabel 9450 4600 2    60   Input ~ 0
/CS_HIRAM
Text GLabel 1000 3100 0    60   Input ~ 0
/RW
Text GLabel 4800 1800 2    60   Input ~ 0
/RW
Text GLabel 5600 5800 0    60   Input ~ 0
/RW
Text GLabel 6950 5800 0    60   Input ~ 0
PHI2
Text GLabel 8550 5500 2    60   Input ~ 0
/OE
Text GLabel 8550 6050 2    60   Input ~ 0
/WE
Text GLabel 4800 1100 2    60   Output ~ 0
/CS_VDP
Text GLabel 4800 900  2    60   Output ~ 0
/CS_IO
Text GLabel 4800 1200 2    60   Output ~ 0
/CS_VIA
Text GLabel 4800 1300 2    60   Output ~ 0
/CS_UART
Text GLabel 4800 1400 2    60   Output ~ 0
/CS_HIRAM
Text GLabel 4800 1600 2    60   Output ~ 0
/CS_ROM
Text GLabel 4600 6150 2    60   Input ~ 0
/RESET
Text GLabel 5500 1700 2    60   Input ~ 0
/ROMOFF
NoConn ~ 2250 5050
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
L GND #PWR017
U 1 1 5414A44F
P 3350 2700
F 0 "#PWR017" H 3350 2700 30  0001 C CNN
F 1 "GND" H 3350 2630 30  0001 C CNN
F 2 "" H 3350 2700 60  0000 C CNN
F 3 "" H 3350 2700 60  0000 C CNN
	1    3350 2700
	1    0    0    -1  
$EndComp
Text GLabel 2750 3200 2    60   Input ~ 0
PH0-IN
Text Label 7150 800  0    60   ~ 0
A[0..15]
Text Label 5900 3400 0    60   ~ 0
A
Text Label 8000 3350 0    60   ~ 0
A
Text Label 1150 600  0    60   ~ 0
A
Text Label 3150 700  0    60   ~ 0
A
Text Label 2750 800  0    60   ~ 0
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
$Sheet
S 10050 600  750  2950
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
$EndSheet
Text GLabel 1100 3350 3    60   Input ~ 0
/NMI
Text GLabel 1250 3350 3    60   Input ~ 0
/IRQ
Text GLabel 1100 2600 1    60   Input ~ 0
RDY
Text GLabel 4800 1500 2    60   Output ~ 0
/CS_LORAM
Entry Wire Line
	3150 1600 3250 1700
Entry Wire Line
	3150 1700 3250 1800
Entry Wire Line
	3150 1800 3250 1900
Entry Wire Line
	3150 1900 3250 2000
Text Label 3250 1300 0    60   ~ 0
A11
Text Label 3250 1400 0    60   ~ 0
A10
Text Label 3250 1500 0    60   ~ 0
A9
Text Label 3250 1600 0    60   ~ 0
A8
Text Label 3250 1700 0    60   ~ 0
A7
Text Label 3250 1800 0    60   ~ 0
A6
Text Label 3250 1900 0    60   ~ 0
A5
Text Label 3250 2000 0    60   ~ 0
A4
Text GLabel 4800 1000 2    60   Output ~ 0
/CS_SND
$Comp
L VCC #PWR018
U 1 1 54356A21
P 5450 700
F 0 "#PWR018" H 5450 800 30  0001 C CNN
F 1 "VCC" H 5450 800 30  0000 C CNN
F 2 "" H 5450 700 60  0000 C CNN
F 3 "" H 5450 700 60  0000 C CNN
	1    5450 700 
	1    0    0    -1  
$EndComp
Text GLabel 7350 4600 2    60   Input ~ 0
/CS_LORAM
$Comp
L GND #PWR019
U 1 1 54357F26
P 7300 2550
F 0 "#PWR019" H 7300 2550 30  0001 C CNN
F 1 "GND" H 7300 2480 30  0001 C CNN
F 2 "" H 7300 2550 60  0000 C CNN
F 3 "" H 7300 2550 60  0000 C CNN
	1    7300 2550
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U9
U 1 1 5436D776
P 4050 3850
F 0 "U9" H 4050 3950 60  0000 C CNN
F 1 "74LS139" H 4050 3750 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 4050 3850 60  0001 C CNN
F 3 "" H 4050 3850 60  0000 C CNN
	1    4050 3850
	1    0    0    -1  
$EndComp
Entry Wire Line
	3050 3500 3150 3600
Entry Wire Line
	3050 3650 3150 3750
Text Label 3150 3600 0    60   ~ 0
A1
Text Label 3150 3750 0    60   ~ 0
A0
Text GLabel 3050 4100 0    60   Input ~ 0
/CS_IO
Text GLabel 5050 3550 2    60   Output ~ 0
/CS_IO0
Text GLabel 5050 3750 2    60   Output ~ 0
/CS_IO1
Text GLabel 5050 3950 2    60   Output ~ 0
/CS_IO2
Text GLabel 5050 4150 2    60   Output ~ 0
/CS_IO3
$Comp
L C C11
U 1 1 543709F1
P 10650 5850
F 0 "C11" H 10650 5950 40  0000 L CNN
F 1 "100n" H 10656 5765 40  0000 L CNN
F 2 "Discret:C1" H 10688 5700 30  0001 C CNN
F 3 "" H 10650 5850 60  0000 C CNN
	1    10650 5850
	1    0    0    -1  
$EndComp
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
	1000 2700 1350 2700
Wire Wire Line
	1000 2900 1350 2900
Wire Wire Line
	1000 3000 1350 3000
Wire Wire Line
	3300 6050 3300 6250
Wire Wire Line
	3300 6250 3000 6250
Wire Wire Line
	1000 2800 1350 2800
Wire Wire Line
	4500 6150 4600 6150
Wire Wire Line
	8900 5600 8900 5650
Wire Wire Line
	8900 6050 8900 6150
Wire Wire Line
	2550 2000 2700 2000
Wire Wire Line
	2700 2000 2700 1950
Wire Wire Line
	2550 2400 2700 2400
Wire Wire Line
	2700 2400 2700 2500
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
	500  2600 500  3000
Connection ~ 500  2900
Connection ~ 500  2700
Wire Wire Line
	8900 5650 10750 5650
Wire Wire Line
	8900 6050 10750 6050
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
Wire Wire Line
	4700 4750 4700 5300
Connection ~ 4700 4950
Connection ~ 4700 4850
Connection ~ 4700 5050
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
	3150 700  3150 1900
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
	1350 3100 1000 3100
Wire Wire Line
	3350 1700 3250 1700
Wire Wire Line
	3350 1800 3250 1800
Wire Wire Line
	3000 1250 3000 1400
Wire Wire Line
	5600 5800 5850 5800
Wire Wire Line
	5850 5400 5850 6250
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
	7000 2650 7400 2650
Wire Wire Line
	7400 2750 7200 2750
Wire Wire Line
	7400 2850 7200 2850
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
Connection ~ 9150 5650
Connection ~ 9400 5650
Connection ~ 9650 5650
Connection ~ 9900 5650
Connection ~ 9900 6050
Connection ~ 9650 6050
Connection ~ 9400 6050
Connection ~ 9150 6050
Connection ~ 10150 5650
Connection ~ 10400 5650
Connection ~ 10400 6050
Connection ~ 10150 6050
Wire Wire Line
	800  6500 800  6250
Connection ~ 800  6250
Wire Wire Line
	800  7100 800  7250
Connection ~ 800  7250
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
	1100 3350 1100 2900
Connection ~ 1100 2900
Wire Wire Line
	1250 3350 1250 3000
Connection ~ 1250 3000
Wire Wire Line
	1100 2600 1100 2700
Connection ~ 1100 2700
Connection ~ 5850 6050
Wire Wire Line
	3250 1900 3350 1900
Wire Wire Line
	3250 2000 3350 2000
Wire Wire Line
	4750 1800 4800 1800
Wire Wire Line
	4750 1700 5500 1700
Wire Wire Line
	4750 1600 4800 1600
Wire Wire Line
	4750 1500 4800 1500
Wire Wire Line
	4750 1400 4800 1400
Wire Wire Line
	4750 1300 4800 1300
Wire Wire Line
	4750 1200 4800 1200
Wire Wire Line
	4750 1100 4800 1100
Wire Wire Line
	4750 1000 4800 1000
Wire Wire Line
	4750 900  4800 900 
Wire Wire Line
	5450 700  5450 1000
Wire Wire Line
	5450 1500 5450 1700
Connection ~ 5450 1700
Wire Wire Line
	7400 2350 7300 2350
Wire Wire Line
	7300 2350 7300 2550
Wire Wire Line
	7400 2450 7300 2450
Connection ~ 7300 2450
Wire Wire Line
	7000 2550 7000 2650
Wire Bus Line
	3050 3400 3050 3700
Wire Wire Line
	3150 3600 3200 3600
Wire Wire Line
	3150 3750 3200 3750
Wire Wire Line
	3050 4100 3200 4100
Wire Wire Line
	4900 3550 5050 3550
Wire Wire Line
	4900 3750 5050 3750
Wire Wire Line
	4900 3950 5050 3950
Wire Wire Line
	4900 4150 5050 4150
Connection ~ 10650 5650
Connection ~ 10650 6050
Wire Wire Line
	9950 2200 10050 2200
Entry Wire Line
	9850 2200 9950 2300
Wire Wire Line
	9950 2300 10050 2300
Text Label 9950 2300 0    60   ~ 0
A5
$Comp
L VCC #PWR020
U 1 1 54373583
P 3600 3350
F 0 "#PWR020" H 3600 3450 30  0001 C CNN
F 1 "VCC" H 3600 3450 30  0000 C CNN
F 2 "" H 3600 3350 60  0000 C CNN
F 3 "" H 3600 3350 60  0000 C CNN
	1    3600 3350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR021
U 1 1 543735FE
P 3600 4350
F 0 "#PWR021" H 3600 4350 30  0001 C CNN
F 1 "GND" H 3600 4280 30  0001 C CNN
F 2 "" H 3600 4350 60  0000 C CNN
F 3 "" H 3600 4350 60  0000 C CNN
	1    3600 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 3350 3600 3450
Wire Wire Line
	3600 4250 3600 4350
$Comp
L VCC #PWR022
U 1 1 543745A2
P 8100 700
F 0 "#PWR022" H 8100 800 30  0001 C CNN
F 1 "VCC" H 8100 800 30  0000 C CNN
F 2 "" H 8100 700 60  0000 C CNN
F 3 "" H 8100 700 60  0000 C CNN
	1    8100 700 
	1    0    0    -1  
$EndComp
Wire Wire Line
	8100 700  8100 1000
$Comp
L GND #PWR023
U 1 1 543748B3
P 8100 3000
F 0 "#PWR023" H 8100 3000 30  0001 C CNN
F 1 "GND" H 8100 2930 30  0001 C CNN
F 2 "" H 8100 3000 60  0000 C CNN
F 3 "" H 8100 3000 60  0000 C CNN
	1    8100 3000
	1    0    0    -1  
$EndComp
Wire Wire Line
	8100 3000 8100 2900
$Comp
L VCC #PWR024
U 1 1 54374D46
P 6650 3300
F 0 "#PWR024" H 6650 3400 30  0001 C CNN
F 1 "VCC" H 6650 3400 30  0000 C CNN
F 2 "" H 6650 3300 60  0000 C CNN
F 3 "" H 6650 3300 60  0000 C CNN
	1    6650 3300
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR025
U 1 1 54374E0E
P 8750 3300
F 0 "#PWR025" H 8750 3400 30  0001 C CNN
F 1 "VCC" H 8750 3400 30  0000 C CNN
F 2 "" H 8750 3300 60  0000 C CNN
F 3 "" H 8750 3300 60  0000 C CNN
	1    8750 3300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 3300 6650 3400
Wire Wire Line
	8750 3300 8750 3400
$Comp
L GND #PWR026
U 1 1 54375105
P 6650 5100
F 0 "#PWR026" H 6650 5100 30  0001 C CNN
F 1 "GND" H 6650 5030 30  0001 C CNN
F 2 "" H 6650 5100 60  0000 C CNN
F 3 "" H 6650 5100 60  0000 C CNN
	1    6650 5100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR027
U 1 1 54375267
P 8750 5100
F 0 "#PWR027" H 8750 5100 30  0001 C CNN
F 1 "GND" H 8750 5030 30  0001 C CNN
F 2 "" H 8750 5100 60  0000 C CNN
F 3 "" H 8750 5100 60  0000 C CNN
	1    8750 5100
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 5000 6650 5100
Wire Wire Line
	8750 5000 8750 5100
NoConn ~ 4900 3950
NoConn ~ 4900 4150
Wire Wire Line
	2300 5550 2300 6050
$EndSCHEMATC
