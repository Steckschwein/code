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
LIBS:dallas-rtc
LIBS:mini_din
LIBS:w_connectors
LIBS:io-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 4
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
L DB9 Port1
U 1 1 54318EBC
P 6350 3450
F 0 "Port1" H 6350 4000 70  0000 C CNN
F 1 "DB9" H 6350 2900 70  0000 C CNN
F 2 "Connect:DB9MC" H 6350 3450 60  0001 C CNN
F 3 "" H 6350 3450 60  0000 C CNN
	1    6350 3450
	1    0    0    -1  
$EndComp
$Comp
L DB9 Port2
U 1 1 54318F7A
P 6350 5450
F 0 "Port2" H 6350 6000 70  0000 C CNN
F 1 "DB9" H 6350 4900 70  0000 C CNN
F 2 "Connect:DB9MC" H 6350 5450 60  0001 C CNN
F 3 "" H 6350 5450 60  0000 C CNN
	1    6350 5450
	1    0    0    -1  
$EndComp
$Comp
L LTV847 U6
U 1 1 54462383
P 3650 2500
F 0 "U6" H 3350 3400 60  0000 C CNN
F 1 "LTV846" H 3650 1600 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 3650 2500 60  0001 C CNN
F 3 "" H 3650 2500 60  0000 C CNN
	1    3650 2500
	-1   0    0    -1  
$EndComp
Text HLabel 7500 1950 2    60   Input ~ 0
PortSel01
Text HLabel 7500 2550 2    60   Input ~ 0
PortSel02
Text HLabel 1150 2950 0    60   Input ~ 0
J_Right
Text HLabel 1150 2550 0    60   Input ~ 0
J_Left
Text HLabel 1150 3750 0    60   Input ~ 0
J_Up
Text HLabel 1150 4150 0    60   Input ~ 0
J_Down
Text HLabel 1150 4550 0    60   Input ~ 0
J_Fire1
Text HLabel 1150 4950 0    60   Input ~ 0
J_Fire2
$Comp
L LTV847 U8
U 1 1 54B2CF92
P 3650 4500
F 0 "U8" H 3350 5400 60  0000 C CNN
F 1 "LTV846" H 3650 3600 60  0000 C CNN
F 2 "Sockets_DIP:DIP-16__300_ELL" H 3650 4500 60  0001 C CNN
F 3 "" H 3650 4500 60  0000 C CNN
	1    3650 4500
	-1   0    0    -1  
$EndComp
$Comp
L R R15
U 1 1 54B364F6
P 4450 1150
F 0 "R15" V 4530 1150 40  0000 C CNN
F 1 "1K" V 4457 1151 40  0000 C CNN
F 2 "Discret:R3" V 4380 1150 30  0001 C CNN
F 3 "" H 4450 1150 30  0000 C CNN
	1    4450 1150
	-1   0    0    -1  
$EndComp
$Comp
L VCC #PWR48
U 1 1 54B369B1
P 4450 800
F 0 "#PWR48" H 4450 900 30  0001 C CNN
F 1 "VCC" H 4450 900 30  0000 C CNN
F 2 "" H 4450 800 60  0000 C CNN
F 3 "" H 4450 800 60  0000 C CNN
	1    4450 800 
	-1   0    0    -1  
$EndComp
$Comp
L R R16
U 1 1 54B370F0
P 4650 1150
F 0 "R16" V 4730 1150 40  0000 C CNN
F 1 "1K" V 4657 1151 40  0000 C CNN
F 2 "Discret:R3" V 4580 1150 30  0001 C CNN
F 3 "" H 4650 1150 30  0000 C CNN
	1    4650 1150
	-1   0    0    -1  
$EndComp
$Comp
L R R13
U 1 1 54B3772A
P 2700 2050
F 0 "R13" V 2780 2050 40  0000 C CNN
F 1 "220" V 2707 2051 40  0000 C CNN
F 2 "Discret:R3" V 2630 2050 30  0001 C CNN
F 3 "" H 2700 2050 30  0000 C CNN
	1    2700 2050
	0    -1   1    0   
$EndComp
$Comp
L GND #PWR34
U 1 1 54B377A1
P 2350 2050
F 0 "#PWR34" H 2350 2050 30  0001 C CNN
F 1 "GND" H 2350 1980 30  0001 C CNN
F 2 "" H 2350 2050 60  0000 C CNN
F 3 "" H 2350 2050 60  0000 C CNN
	1    2350 2050
	0    1    -1   0   
$EndComp
$Comp
L R R14
U 1 1 54B37AF8
P 2700 2450
F 0 "R14" V 2780 2450 40  0000 C CNN
F 1 "220" V 2707 2451 40  0000 C CNN
F 2 "Discret:R3" V 2630 2450 30  0001 C CNN
F 3 "" H 2700 2450 30  0000 C CNN
	1    2700 2450
	0    -1   1    0   
$EndComp
$Comp
L GND #PWR35
U 1 1 54B37B39
P 2350 2450
F 0 "#PWR35" H 2350 2450 30  0001 C CNN
F 1 "GND" H 2350 2380 30  0001 C CNN
F 2 "" H 2350 2450 60  0000 C CNN
F 3 "" H 2350 2450 60  0000 C CNN
	1    2350 2450
	0    1    -1   0   
$EndComp
$Comp
L GND #PWR36
U 1 1 54B39138
P 2950 2850
F 0 "#PWR36" H 2950 2850 30  0001 C CNN
F 1 "GND" H 2950 2780 30  0001 C CNN
F 2 "" H 2950 2850 60  0000 C CNN
F 3 "" H 2950 2850 60  0000 C CNN
	1    2950 2850
	0    1    -1   0   
$EndComp
$Comp
L GND #PWR37
U 1 1 54B39189
P 2950 3250
F 0 "#PWR37" H 2950 3250 30  0001 C CNN
F 1 "GND" H 2950 3180 30  0001 C CNN
F 2 "" H 2950 3250 60  0000 C CNN
F 3 "" H 2950 3250 60  0000 C CNN
	1    2950 3250
	0    1    -1   0   
$EndComp
$Comp
L GND #PWR38
U 1 1 54B391A2
P 2950 4050
F 0 "#PWR38" H 2950 4050 30  0001 C CNN
F 1 "GND" H 2950 3980 30  0001 C CNN
F 2 "" H 2950 4050 60  0000 C CNN
F 3 "" H 2950 4050 60  0000 C CNN
	1    2950 4050
	0    1    -1   0   
$EndComp
$Comp
L GND #PWR39
U 1 1 54B391BB
P 2950 4450
F 0 "#PWR39" H 2950 4450 30  0001 C CNN
F 1 "GND" H 2950 4380 30  0001 C CNN
F 2 "" H 2950 4450 60  0000 C CNN
F 3 "" H 2950 4450 60  0000 C CNN
	1    2950 4450
	0    1    -1   0   
$EndComp
$Comp
L GND #PWR40
U 1 1 54B39318
P 2950 4850
F 0 "#PWR40" H 2950 4850 30  0001 C CNN
F 1 "GND" H 2950 4780 30  0001 C CNN
F 2 "" H 2950 4850 60  0000 C CNN
F 3 "" H 2950 4850 60  0000 C CNN
	1    2950 4850
	0    1    -1   0   
$EndComp
$Comp
L GND #PWR41
U 1 1 54B3933C
P 2950 5250
F 0 "#PWR41" H 2950 5250 30  0001 C CNN
F 1 "GND" H 2950 5180 30  0001 C CNN
F 2 "" H 2950 5250 60  0000 C CNN
F 3 "" H 2950 5250 60  0000 C CNN
	1    2950 5250
	0    1    -1   0   
$EndComp
$Comp
L R R8
U 1 1 54B39601
P 1500 1150
F 0 "R8" V 1580 1150 40  0000 C CNN
F 1 "12K-27K" V 1507 1151 40  0000 C CNN
F 2 "Discret:R3" V 1430 1150 30  0001 C CNN
F 3 "" H 1500 1150 30  0000 C CNN
	1    1500 1150
	-1   0    0    -1  
$EndComp
$Comp
L R R7
U 1 1 54B3B295
P 1350 1150
F 0 "R7" V 1430 1150 40  0000 C CNN
F 1 "12K-27K" V 1357 1151 40  0000 C CNN
F 2 "Discret:R3" V 1280 1150 30  0001 C CNN
F 3 "" H 1350 1150 30  0000 C CNN
	1    1350 1150
	-1   0    0    -1  
$EndComp
$Comp
L R R12
U 1 1 54B3B478
P 2100 1150
F 0 "R12" V 2180 1150 40  0000 C CNN
F 1 "12K-27K" V 2107 1151 40  0000 C CNN
F 2 "Discret:R3" V 2030 1150 30  0001 C CNN
F 3 "" H 2100 1150 30  0000 C CNN
	1    2100 1150
	-1   0    0    -1  
$EndComp
$Comp
L R R11
U 1 1 54B3B47E
P 1950 1150
F 0 "R11" V 2030 1150 40  0000 C CNN
F 1 "12K-27K" V 1957 1151 40  0000 C CNN
F 2 "Discret:R3" V 1880 1150 30  0001 C CNN
F 3 "" H 1950 1150 30  0000 C CNN
	1    1950 1150
	-1   0    0    -1  
$EndComp
$Comp
L R R10
U 1 1 54B3B484
P 1800 1150
F 0 "R10" V 1880 1150 40  0000 C CNN
F 1 "12K-27K" V 1807 1151 40  0000 C CNN
F 2 "Discret:R3" V 1730 1150 30  0001 C CNN
F 3 "" H 1800 1150 30  0000 C CNN
	1    1800 1150
	-1   0    0    -1  
$EndComp
$Comp
L R R9
U 1 1 54B3B48A
P 1650 1150
F 0 "R9" V 1730 1150 40  0000 C CNN
F 1 "12K-27K" V 1657 1151 40  0000 C CNN
F 2 "Discret:R3" V 1580 1150 30  0001 C CNN
F 3 "" H 1650 1150 30  0000 C CNN
	1    1650 1150
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7500 1950 7400 1950
Wire Wire Line
	7500 2550 7400 2550
Wire Wire Line
	4450 1750 4300 1750
Wire Wire Line
	4450 900  4450 800 
Wire Wire Line
	4650 1400 4650 2150
Wire Wire Line
	4650 2150 4300 2150
Wire Wire Line
	1350 900  1500 900 
Wire Wire Line
	1500 900  1650 900 
Wire Wire Line
	1650 900  1800 900 
Wire Wire Line
	1800 900  1950 900 
Wire Wire Line
	1950 900  2100 900 
Wire Wire Line
	2100 900  4450 900 
Wire Wire Line
	4450 900  4650 900 
Wire Wire Line
	4650 900  5450 900 
Wire Wire Line
	2950 1750 3050 1750
Wire Wire Line
	3050 2050 2950 2050
Wire Wire Line
	2450 2050 2350 2050
Wire Wire Line
	3050 2450 2950 2450
Wire Wire Line
	2450 2450 2350 2450
Wire Wire Line
	2200 2150 3050 2150
Wire Wire Line
	5900 3850 5750 3850
Wire Wire Line
	5750 3850 5750 4050
Wire Wire Line
	5750 4050 5750 5850
Wire Wire Line
	5750 5850 5900 5850
Wire Wire Line
	5650 5750 5900 5750
Wire Wire Line
	5650 3750 5650 4850
Wire Wire Line
	5650 4850 5650 5750
Wire Wire Line
	5650 3750 5900 3750
Wire Wire Line
	5900 3650 5550 3650
Wire Wire Line
	5550 3650 5550 4450
Wire Wire Line
	5550 4450 5550 5650
Wire Wire Line
	5550 5650 5900 5650
Wire Wire Line
	5450 5550 5900 5550
Wire Wire Line
	5450 900  5450 3550
Wire Wire Line
	5450 3550 5450 5550
Wire Wire Line
	5450 3550 5900 3550
Wire Wire Line
	5350 3450 5900 3450
Wire Wire Line
	5350 2850 5350 3450
Wire Wire Line
	5350 3450 5350 5450
Wire Wire Line
	5350 5450 5900 5450
Wire Wire Line
	5250 5250 5900 5250
Wire Wire Line
	5250 3250 5250 5250
Wire Wire Line
	4300 3250 5250 3250
Wire Wire Line
	5250 3250 5900 3250
Wire Wire Line
	5900 3150 5150 3150
Wire Wire Line
	5150 3150 5150 5150
Wire Wire Line
	5150 5150 5900 5150
Wire Wire Line
	5050 5050 5900 5050
Wire Wire Line
	5050 3050 5050 5050
Wire Wire Line
	5050 3050 5900 3050
Wire Wire Line
	3050 2850 2950 2850
Wire Wire Line
	3050 3250 2950 3250
Wire Wire Line
	3050 4050 2950 4050
Wire Wire Line
	3050 4450 2950 4450
Wire Wire Line
	3050 4850 2950 4850
Wire Wire Line
	3050 5250 2950 5250
Wire Wire Line
	4450 1400 4450 1750
Wire Wire Line
	2950 1750 2950 1550
Wire Wire Line
	2950 1550 5750 1550
Wire Wire Line
	5750 3350 5900 3350
Wire Wire Line
	2200 2150 2200 1450
Wire Wire Line
	2200 1450 5850 1450
Wire Wire Line
	5850 1450 5850 5350
Wire Wire Line
	5850 5350 5900 5350
Wire Wire Line
	1150 2550 2100 2550
Wire Wire Line
	2100 2550 3050 2550
Wire Wire Line
	2100 2550 2100 1400
Wire Wire Line
	1950 1400 1950 2950
Wire Wire Line
	1150 2950 1950 2950
Wire Wire Line
	1950 2950 3050 2950
Wire Wire Line
	1800 1400 1800 3750
Wire Wire Line
	1150 3750 1800 3750
Wire Wire Line
	1800 3750 3050 3750
Wire Wire Line
	1650 1400 1650 4150
Wire Wire Line
	1150 4150 1650 4150
Wire Wire Line
	1650 4150 3050 4150
Wire Wire Line
	1500 1400 1500 4550
Wire Wire Line
	1150 4550 1500 4550
Wire Wire Line
	1500 4550 3050 4550
Wire Wire Line
	1150 4950 1350 4950
Wire Wire Line
	1350 4950 3050 4950
Wire Wire Line
	1350 4950 1350 1400
Connection ~ 1500 900 
Connection ~ 1650 900 
Connection ~ 1800 900 
Connection ~ 1950 900 
Connection ~ 4450 900 
Connection ~ 2100 900 
Wire Wire Line
	4300 2450 6200 2450
Connection ~ 1950 2950
Connection ~ 1800 3750
Connection ~ 1650 4150
Connection ~ 1500 4550
Connection ~ 1350 4950
Connection ~ 2100 2550
Connection ~ 4650 900 
Connection ~ 5450 3550
$Comp
L VCC #PWR43
U 1 1 54B37887
P 4400 2950
F 0 "#PWR43" H 4400 3050 30  0001 C CNN
F 1 "VCC" H 4400 3050 30  0000 C CNN
F 2 "" H 4400 2950 60  0000 C CNN
F 3 "" H 4400 2950 60  0000 C CNN
	1    4400 2950
	0    1    -1   0   
$EndComp
Wire Wire Line
	4300 2950 4400 2950
$Comp
L VCC #PWR42
U 1 1 54B37932
P 4400 2550
F 0 "#PWR42" H 4400 2650 30  0001 C CNN
F 1 "VCC" H 4400 2650 30  0000 C CNN
F 2 "" H 4400 2550 60  0000 C CNN
F 3 "" H 4400 2550 60  0000 C CNN
	1    4400 2550
	0    1    -1   0   
$EndComp
Wire Wire Line
	4300 2550 4400 2550
$Comp
L VCC #PWR44
U 1 1 54B37957
P 4400 3750
F 0 "#PWR44" H 4400 3850 30  0001 C CNN
F 1 "VCC" H 4400 3850 30  0000 C CNN
F 2 "" H 4400 3750 60  0000 C CNN
F 3 "" H 4400 3750 60  0000 C CNN
	1    4400 3750
	0    1    -1   0   
$EndComp
Wire Wire Line
	4300 3750 4400 3750
$Comp
L VCC #PWR45
U 1 1 54B3797C
P 4400 4150
F 0 "#PWR45" H 4400 4250 30  0001 C CNN
F 1 "VCC" H 4400 4250 30  0000 C CNN
F 2 "" H 4400 4150 60  0000 C CNN
F 3 "" H 4400 4150 60  0000 C CNN
	1    4400 4150
	0    1    -1   0   
$EndComp
Wire Wire Line
	4300 4150 4400 4150
$Comp
L VCC #PWR46
U 1 1 54B379A1
P 4400 4550
F 0 "#PWR46" H 4400 4650 30  0001 C CNN
F 1 "VCC" H 4400 4650 30  0000 C CNN
F 2 "" H 4400 4550 60  0000 C CNN
F 3 "" H 4400 4550 60  0000 C CNN
	1    4400 4550
	0    1    -1   0   
$EndComp
Wire Wire Line
	4300 4550 4400 4550
$Comp
L VCC #PWR47
U 1 1 54B37B79
P 4400 4950
F 0 "#PWR47" H 4400 5050 30  0001 C CNN
F 1 "VCC" H 4400 5050 30  0000 C CNN
F 2 "" H 4400 4950 60  0000 C CNN
F 3 "" H 4400 4950 60  0000 C CNN
	1    4400 4950
	0    1    -1   0   
$EndComp
Wire Wire Line
	4300 4950 4400 4950
Wire Wire Line
	5750 4050 4300 4050
Connection ~ 5750 4050
Wire Wire Line
	5550 4450 4300 4450
Connection ~ 5550 4450
Wire Wire Line
	4300 2850 5350 2850
Connection ~ 5350 3450
Connection ~ 5250 3250
Wire Wire Line
	4300 4850 5650 4850
Connection ~ 5650 4850
Wire Wire Line
	5750 1550 5750 3350
Wire Wire Line
	4300 2050 6200 2050
$Comp
L 7400 U3
U 1 1 54B45DBD
P 6800 1950
F 0 "U3" H 6800 2000 60  0000 C CNN
F 1 "7400" H 6800 1850 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 6800 1950 60  0001 C CNN
F 3 "" H 6800 1950 60  0000 C CNN
	1    6800 1950
	-1   0    0    1   
$EndComp
$Comp
L 7400 U3
U 4 1 54B45E28
P 6800 2550
F 0 "U3" H 6800 2600 60  0000 C CNN
F 1 "7400" H 6800 2450 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 6800 2550 60  0001 C CNN
F 3 "" H 6800 2550 60  0000 C CNN
	4    6800 2550
	-1   0    0    -1  
$EndComp
Wire Wire Line
	7400 2450 7400 2550
Wire Wire Line
	7400 2550 7400 2650
Connection ~ 7400 2550
Wire Wire Line
	7400 1850 7400 1950
Wire Wire Line
	7400 1950 7400 2050
Connection ~ 7400 1950
Wire Wire Line
	6200 2050 6200 1950
Wire Wire Line
	6200 2450 6200 2550
NoConn ~ 4300 5250
$EndSCHEMATC
