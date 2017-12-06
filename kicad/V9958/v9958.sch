EESchema Schematic File Version 2
LIBS:v9958-rescue
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
LIBS:tms99xx
LIBS:v9958-cache
EELAYER 25 0
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
L BC547 Q1
U 1 1 5A230CB7
P 9550 1200
F 0 "Q1" H 9550 1051 40  0000 R CNN
F 1 "BC547" H 9550 1350 40  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-92_Molded_Wide" H 9450 1302 29  0000 C CNN
F 3 "" H 9550 1200 60  0000 C CNN
	1    9550 1200
	1    0    0    -1  
$EndComp
$Comp
L BC547 Q2
U 1 1 5A230D30
P 9550 2650
F 0 "Q2" H 9550 2501 40  0000 R CNN
F 1 "BC547" H 9550 2800 40  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-92_Molded_Wide" H 9450 2752 29  0000 C CNN
F 3 "" H 9550 2650 60  0000 C CNN
	1    9550 2650
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R6
U 1 1 5A230EAF
P 9650 3150
F 0 "R6" V 9730 3150 40  0000 C CNN
F 1 "220" V 9657 3151 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9580 3150 30  0001 C CNN
F 3 "" H 9650 3150 30  0000 C CNN
	1    9650 3150
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R2
U 1 1 5A230EF6
P 9300 3150
F 0 "R2" V 9380 3150 40  0000 C CNN
F 1 "1K" V 9307 3151 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9230 3150 30  0001 C CNN
F 3 "" H 9300 3150 30  0000 C CNN
	1    9300 3150
	-1   0    0    1   
$EndComp
$Comp
L R-RESCUE-v9958 R1
U 1 1 5A230F47
P 9050 1200
F 0 "R1" V 9130 1200 40  0000 C CNN
F 1 "1K" V 9057 1201 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 8980 1200 30  0001 C CNN
F 3 "" H 9050 1200 30  0000 C CNN
	1    9050 1200
	0    1    1    0   
$EndComp
$Comp
L R-RESCUE-v9958 R5
U 1 1 5A230F7B
P 9650 1700
F 0 "R5" V 9730 1700 40  0000 C CNN
F 1 "220" V 9657 1701 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9580 1700 30  0001 C CNN
F 3 "" H 9650 1700 30  0000 C CNN
	1    9650 1700
	-1   0    0    1   
$EndComp
$Comp
L VCC #PWR8
U 1 1 5A231049
P 9650 2400
F 0 "#PWR8" H 9650 2500 30  0001 C CNN
F 1 "VCC" H 9650 2500 30  0000 C CNN
F 2 "" H 9650 2400 60  0000 C CNN
F 3 "" H 9650 2400 60  0000 C CNN
	1    9650 2400
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR6
U 1 1 5A231127
P 9650 950
F 0 "#PWR6" H 9650 1050 30  0001 C CNN
F 1 "VCC" H 9650 1050 30  0000 C CNN
F 2 "" H 9650 950 60  0000 C CNN
F 3 "" H 9650 950 60  0000 C CNN
	1    9650 950 
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR9
U 1 1 5A2311D6
P 9650 3450
F 0 "#PWR9" H 9650 3450 30  0001 C CNN
F 1 "GND" H 9650 3380 30  0001 C CNN
F 2 "" H 9650 3450 60  0000 C CNN
F 3 "" H 9650 3450 60  0000 C CNN
	1    9650 3450
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR3
U 1 1 5A231200
P 9300 3450
F 0 "#PWR3" H 9300 3450 30  0001 C CNN
F 1 "GND" H 9300 3380 30  0001 C CNN
F 2 "" H 9300 3450 60  0000 C CNN
F 3 "" H 9300 3450 60  0000 C CNN
	1    9300 3450
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR7
U 1 1 5A231211
P 9650 2000
F 0 "#PWR7" H 9650 2000 30  0001 C CNN
F 1 "GND" H 9650 1930 30  0001 C CNN
F 2 "" H 9650 2000 60  0000 C CNN
F 3 "" H 9650 2000 60  0000 C CNN
	1    9650 2000
	1    0    0    -1  
$EndComp
$Comp
L BC547 Q3
U 1 1 5A231D76
P 9550 4000
F 0 "Q3" H 9550 3851 40  0000 R CNN
F 1 "BC547" H 9550 4150 40  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-92_Molded_Wide" H 9450 4102 29  0000 C CNN
F 3 "" H 9550 4000 60  0000 C CNN
	1    9550 4000
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R7
U 1 1 5A231D7C
P 9650 4500
F 0 "R7" V 9730 4500 40  0000 C CNN
F 1 "220" V 9657 4501 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9580 4500 30  0001 C CNN
F 3 "" H 9650 4500 30  0000 C CNN
	1    9650 4500
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R3
U 1 1 5A231D82
P 9300 4500
F 0 "R3" V 9380 4500 40  0000 C CNN
F 1 "1K" V 9307 4501 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9230 4500 30  0001 C CNN
F 3 "" H 9300 4500 30  0000 C CNN
	1    9300 4500
	-1   0    0    1   
$EndComp
$Comp
L VCC #PWR10
U 1 1 5A231D8C
P 9650 3750
F 0 "#PWR10" H 9650 3850 30  0001 C CNN
F 1 "VCC" H 9650 3850 30  0000 C CNN
F 2 "" H 9650 3750 60  0000 C CNN
F 3 "" H 9650 3750 60  0000 C CNN
	1    9650 3750
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR11
U 1 1 5A231D93
P 9650 4800
F 0 "#PWR11" H 9650 4800 30  0001 C CNN
F 1 "GND" H 9650 4730 30  0001 C CNN
F 2 "" H 9650 4800 60  0000 C CNN
F 3 "" H 9650 4800 60  0000 C CNN
	1    9650 4800
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR4
U 1 1 5A231D99
P 9300 4800
F 0 "#PWR4" H 9300 4800 30  0001 C CNN
F 1 "GND" H 9300 4730 30  0001 C CNN
F 2 "" H 9300 4800 60  0000 C CNN
F 3 "" H 9300 4800 60  0000 C CNN
	1    9300 4800
	1    0    0    -1  
$EndComp
$Comp
L BC547 Q4
U 1 1 5A231E8E
P 9550 5250
F 0 "Q4" H 9550 5101 40  0000 R CNN
F 1 "BC547" H 9550 5400 40  0000 R CNN
F 2 "TO_SOT_Packages_THT:TO-92_Molded_Wide" H 9450 5352 29  0000 C CNN
F 3 "" H 9550 5250 60  0000 C CNN
	1    9550 5250
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R8
U 1 1 5A231E94
P 9650 5750
F 0 "R8" V 9730 5750 40  0000 C CNN
F 1 "220" V 9657 5751 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9580 5750 30  0001 C CNN
F 3 "" H 9650 5750 30  0000 C CNN
	1    9650 5750
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R4
U 1 1 5A231E9A
P 9300 5750
F 0 "R4" V 9380 5750 40  0000 C CNN
F 1 "1K" V 9307 5751 40  0000 C CNN
F 2 "Resistors_ThroughHole:R_Axial_DIN0207_L6.3mm_D2.5mm_P15.24mm_Horizontal" V 9230 5750 30  0001 C CNN
F 3 "" H 9300 5750 30  0000 C CNN
	1    9300 5750
	-1   0    0    1   
$EndComp
$Comp
L VCC #PWR12
U 1 1 5A231EA4
P 9650 5000
F 0 "#PWR12" H 9650 5100 30  0001 C CNN
F 1 "VCC" H 9650 5100 30  0000 C CNN
F 2 "" H 9650 5000 60  0000 C CNN
F 3 "" H 9650 5000 60  0000 C CNN
	1    9650 5000
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR13
U 1 1 5A231EAB
P 9650 6050
F 0 "#PWR13" H 9650 6050 30  0001 C CNN
F 1 "GND" H 9650 5980 30  0001 C CNN
F 2 "" H 9650 6050 60  0000 C CNN
F 3 "" H 9650 6050 60  0000 C CNN
	1    9650 6050
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR5
U 1 1 5A231EB1
P 9300 6050
F 0 "#PWR5" H 9300 6050 30  0001 C CNN
F 1 "GND" H 9300 5980 30  0001 C CNN
F 2 "" H 9300 6050 60  0000 C CNN
F 3 "" H 9300 6050 60  0000 C CNN
	1    9300 6050
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J1
U 1 1 5A23214A
P 7650 800
F 0 "J1" H 7650 900 50  0000 C CNN
F 1 "Conn_01x01" H 7650 700 50  0000 C CNN
F 2 "Connect:1pin" H 7650 800 50  0001 C CNN
F 3 "" H 7650 800 50  0001 C CNN
	1    7650 800 
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J2
U 1 1 5A232262
P 7650 1100
F 0 "J2" H 7650 1200 50  0000 C CNN
F 1 "Conn_01x01" H 7650 1000 50  0000 C CNN
F 2 "Connect:1pin" H 7650 1100 50  0001 C CNN
F 3 "" H 7650 1100 50  0001 C CNN
	1    7650 1100
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR1
U 1 1 5A2324A6
P 7450 750
F 0 "#PWR1" H 7450 850 30  0001 C CNN
F 1 "VCC" H 7450 850 30  0000 C CNN
F 2 "" H 7450 750 60  0000 C CNN
F 3 "" H 7450 750 60  0000 C CNN
	1    7450 750 
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR2
U 1 1 5A2324DB
P 7450 1150
F 0 "#PWR2" H 7450 1150 30  0001 C CNN
F 1 "GND" H 7450 1080 30  0001 C CNN
F 2 "" H 7450 1150 60  0000 C CNN
F 3 "" H 7450 1150 60  0000 C CNN
	1    7450 1150
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x04 J3
U 1 1 5A232C31
P 7650 1900
F 0 "J3" H 7650 2100 50  0000 C CNN
F 1 "Conn_01x04" H 7650 1600 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04_Pitch2.54mm" H 7650 1900 50  0001 C CNN
F 3 "" H 7650 1900 50  0001 C CNN
	1    7650 1900
	-1   0    0    1   
$EndComp
$Comp
L Conn_01x04 J4
U 1 1 5A232CDD
P 10900 1750
F 0 "J4" H 10900 1950 50  0000 C CNN
F 1 "Conn_01x04" H 10900 1450 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x04_Pitch2.54mm" H 10900 1750 50  0001 C CNN
F 3 "" H 10900 1750 50  0001 C CNN
	1    10900 1750
	1    0    0    -1  
$EndComp
Text Label 8650 5250 0    60   ~ 0
RGB_B
Text Label 8700 4000 0    60   ~ 0
RGB_G
Text Label 8750 2650 0    60   ~ 0
RGB_R
Wire Wire Line
	9650 2850 9650 2900
Wire Wire Line
	8600 2650 9350 2650
Wire Wire Line
	9650 1450 9650 1400
Wire Wire Line
	9650 950  9650 1000
Wire Wire Line
	9650 1950 9650 2000
Wire Wire Line
	9650 1450 10300 1450
Wire Wire Line
	9300 3400 9300 3450
Wire Wire Line
	9650 3400 9650 3450
Wire Wire Line
	8600 1200 8800 1200
Wire Wire Line
	9650 2900 10300 2900
Wire Wire Line
	9650 4200 9650 4250
Wire Wire Line
	9300 4250 9300 4000
Wire Wire Line
	9000 4000 9350 4000
Connection ~ 9300 4000
Wire Wire Line
	9300 4750 9300 4800
Wire Wire Line
	9650 4750 9650 4800
Wire Wire Line
	9650 4250 10400 4250
Wire Wire Line
	9650 5450 9650 5500
Wire Wire Line
	9300 5500 9300 5250
Wire Wire Line
	8500 5250 9350 5250
Connection ~ 9300 5250
Wire Wire Line
	9300 6000 9300 6050
Wire Wire Line
	9650 6000 9650 6050
Wire Wire Line
	9650 5500 10450 5500
Wire Wire Line
	9300 1200 9350 1200
Wire Wire Line
	9650 2400 9650 2450
Wire Wire Line
	9650 5000 9650 5050
Wire Wire Line
	7450 1100 7450 1150
Wire Wire Line
	7450 800  7450 750 
Wire Wire Line
	7850 1900 8550 1900
Wire Wire Line
	8550 1900 8550 4000
Wire Wire Line
	8550 4000 9300 4000
Wire Wire Line
	7850 2000 8500 2000
Wire Wire Line
	8500 2000 8500 5250
Wire Wire Line
	9300 2900 9300 2650
Wire Wire Line
	8600 2650 8600 1800
Wire Wire Line
	8600 1800 7850 1800
Text Label 8600 1200 0    60   ~ 0
CSYNC
Wire Wire Line
	7850 1700 8600 1700
Wire Wire Line
	8600 1700 8600 1200
Wire Wire Line
	10300 1450 10300 1650
Wire Wire Line
	10300 1650 10700 1650
Wire Wire Line
	10700 1750 10300 1750
Wire Wire Line
	10300 1750 10300 2900
Wire Wire Line
	10400 4250 10400 1850
Wire Wire Line
	10400 1850 10700 1850
Wire Wire Line
	10700 1950 10450 1950
Wire Wire Line
	10450 1950 10450 5500
Connection ~ 9300 2650
Wire Wire Line
	9650 3750 9650 3800
$Comp
L V9958 U1
U 1 1 5A26A502
P 5850 2500
F 0 "U1" H 5950 950 60  0000 C CNN
F 1 "V9958" H 5500 950 60  0000 C CNN
F 2 "" H 6200 2550 60  0001 C CNN
F 3 "" H 6200 2550 60  0001 C CNN
	1    5850 2500
	1    0    0    -1  
$EndComp
$Comp
L 7400 U?
U 1 1 5A27A3A8
P 1250 2650
F 0 "U?" H 1250 2700 50  0000 C CNN
F 1 "7400" H 1250 2550 50  0000 C CNN
F 2 "" H 1250 2650 50  0001 C CNN
F 3 "" H 1250 2650 50  0001 C CNN
	1    1250 2650
	1    0    0    -1  
$EndComp
$Comp
L 7400 U?
U 2 1 5A27A6C7
P 2600 2550
F 0 "U?" H 2600 2600 50  0000 C CNN
F 1 "7400" H 2600 2450 50  0000 C CNN
F 2 "" H 2600 2550 50  0001 C CNN
F 3 "" H 2600 2550 50  0001 C CNN
	2    2600 2550
	1    0    0    -1  
$EndComp
$Comp
L 7400 U?
U 3 1 5A27A724
P 1300 3300
F 0 "U?" H 1300 3350 50  0000 C CNN
F 1 "7400" H 1300 3200 50  0000 C CNN
F 2 "" H 1300 3300 50  0001 C CNN
F 3 "" H 1300 3300 50  0001 C CNN
	3    1300 3300
	1    0    0    -1  
$EndComp
$Comp
L 7400 U?
U 4 1 5A27A7E1
P 2600 3200
F 0 "U?" H 2600 3250 50  0000 C CNN
F 1 "7400" H 2600 3100 50  0000 C CNN
F 2 "" H 2600 3200 50  0001 C CNN
F 3 "" H 2600 3200 50  0001 C CNN
	4    2600 3200
	1    0    0    -1  
$EndComp
$EndSCHEMATC
