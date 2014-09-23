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
LIBS:UART
LIBS:osc
LIBS:uart-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 2
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
L CONN_02X25 P5
U 1 1 542071FB
P 5550 3750
F 0 "P5" H 5550 5050 50  0000 C CNN
F 1 "CONN_02X25" V 5550 3750 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Angled_2x25" H 5550 3000 60  0001 C CNN
F 3 "" H 5550 3000 60  0000 C CNN
	1    5550 3750
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR014
U 1 1 54207202
P 5200 2400
F 0 "#PWR014" H 5200 2500 30  0001 C CNN
F 1 "VCC" H 5200 2500 30  0000 C CNN
F 2 "" H 5200 2400 60  0000 C CNN
F 3 "" H 5200 2400 60  0000 C CNN
	1    5200 2400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 2400 5200 2550
Wire Wire Line
	5200 2550 5300 2550
Wire Wire Line
	5800 2550 5850 2550
Text GLabel 5850 2550 2    60   Input ~ 0
/RESET
Text GLabel 5850 2650 2    60   Input ~ 0
/IRQ
Wire Wire Line
	5800 2650 5850 2650
Wire Wire Line
	5300 2650 5250 2650
Text GLabel 5250 2650 0    60   Input ~ 0
/NMI
Wire Bus Line
	4850 2700 4850 3050
Entry Wire Line
	4850 2750 4950 2850
Entry Wire Line
	4850 2850 4950 2950
Entry Wire Line
	4850 2950 4950 3050
Entry Wire Line
	4850 3050 4950 3150
Wire Wire Line
	4950 2850 5300 2850
Wire Wire Line
	4950 2950 5300 2950
Wire Wire Line
	4950 3050 5300 3050
Wire Wire Line
	4950 3150 5300 3150
Text Label 4950 2850 0    60   ~ 0
D7
Text Label 4950 2950 0    60   ~ 0
D5
Text Label 4950 3050 0    60   ~ 0
D3
Text Label 4950 3150 0    60   ~ 0
D1
Wire Bus Line
	6300 2700 6300 3050
Entry Wire Line
	6200 2850 6300 2750
Entry Wire Line
	6200 2950 6300 2850
Entry Wire Line
	6200 3050 6300 2950
Entry Wire Line
	6200 3150 6300 3050
Wire Wire Line
	5800 2850 6200 2850
Wire Wire Line
	5800 2950 6200 2950
Wire Wire Line
	5800 3050 6200 3050
Wire Wire Line
	5800 3150 6200 3150
Wire Wire Line
	5800 3250 5850 3250
Text GLabel 5850 3250 2    60   Input ~ 0
/RW
Text GLabel 5850 3350 2    60   Input ~ 0
RDY
Wire Wire Line
	5800 3350 5850 3350
Wire Wire Line
	5300 3550 5250 3550
Text GLabel 5250 3550 0    60   Input ~ 0
E_LCD
Wire Wire Line
	5800 3550 5850 3550
Text GLabel 5850 3550 2    60   Input ~ 0
/CS_VIA
Text GLabel 5250 3650 0    60   Input ~ 0
/CS_UART
Wire Wire Line
	5300 3650 5250 3650
Text GLabel 5850 3650 2    60   Input ~ 0
/CSR_VDP
Text GLabel 5250 3750 0    60   Input ~ 0
/CSW_VDP
Wire Wire Line
	5250 3750 5300 3750
Wire Wire Line
	5800 3650 5850 3650
Wire Bus Line
	6450 3650 6450 4050
Entry Wire Line
	6350 3750 6450 3650
Entry Wire Line
	6350 3850 6450 3750
Entry Wire Line
	6350 3950 6450 3850
Wire Wire Line
	5800 3750 6350 3750
Wire Wire Line
	5800 3850 6350 3850
Wire Wire Line
	5800 3950 6350 3950
Wire Bus Line
	4650 3750 4650 4000
Entry Wire Line
	4650 3750 4750 3850
Entry Wire Line
	4650 3850 4750 3950
Wire Wire Line
	4750 3850 5300 3850
Wire Wire Line
	4750 3950 5300 3950
$Comp
L GND #PWR015
U 1 1 54207240
P 4700 4100
F 0 "#PWR015" H 4700 4100 30  0001 C CNN
F 1 "GND" H 4700 4030 30  0001 C CNN
F 2 "" H 4700 4100 60  0000 C CNN
F 3 "" H 4700 4100 60  0000 C CNN
	1    4700 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 4100 4700 4050
Wire Wire Line
	4700 4050 5300 4050
$Comp
L GND #PWR016
U 1 1 54207248
P 6350 4100
F 0 "#PWR016" H 6350 4100 30  0001 C CNN
F 1 "GND" H 6350 4030 30  0001 C CNN
F 2 "" H 6350 4100 60  0000 C CNN
F 3 "" H 6350 4100 60  0000 C CNN
	1    6350 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 4050 6350 4050
Wire Wire Line
	6350 4050 6350 4100
Wire Wire Line
	5300 4150 5250 4150
Wire Wire Line
	5300 4250 5250 4250
Wire Wire Line
	5800 4150 5850 4150
Text GLabel 5250 4150 0    60   Input ~ 0
/OE
Text GLabel 5250 4250 0    60   Input ~ 0
PHI2
Text GLabel 5850 4150 2    60   Input ~ 0
/WE
Text Label 6100 2850 0    60   ~ 0
D6
Text Label 6100 2950 0    60   ~ 0
D4
Text Label 6100 3050 0    60   ~ 0
D2
Text Label 6100 3150 0    60   ~ 0
D0
Text Label 6250 3950 0    60   ~ 0
A0
Text Label 6250 3850 0    60   ~ 0
A2
Text Label 6250 3750 0    60   ~ 0
A4
Text Label 4750 3950 0    60   ~ 0
A1
Text Label 4750 3850 0    60   ~ 0
A3
Text Label 6300 2700 0    60   ~ 0
D
Text Label 4850 2700 0    60   ~ 0
D
Text Label 4350 3750 0    60   ~ 0
A[0..15]
Text GLabel 5250 4350 0    60   Input ~ 0
/OE2
Text GLabel 5850 4350 2    60   Input ~ 0
/WE2
Wire Wire Line
	5850 4350 5800 4350
Wire Wire Line
	5250 4350 5300 4350
NoConn ~ 5300 3250
NoConn ~ 5300 3350
NoConn ~ 5300 3450
NoConn ~ 5800 4250
NoConn ~ 5300 4450
NoConn ~ 5300 4550
NoConn ~ 5300 4650
NoConn ~ 5300 4750
NoConn ~ 5300 4850
NoConn ~ 5300 4950
NoConn ~ 5800 4450
NoConn ~ 5800 4550
NoConn ~ 5800 4650
NoConn ~ 5800 4750
NoConn ~ 5800 4850
NoConn ~ 5800 4950
Wire Wire Line
	5800 3450 5850 3450
Text GLabel 5850 3450 2    60   Input ~ 0
/CS_RES02
Text HLabel 3550 4900 2    60   Input ~ 0
A0
Entry Wire Line
	3350 4800 3450 4900
Text HLabel 3550 4700 2    60   Input ~ 0
A2
Text HLabel 3550 4500 2    60   Input ~ 0
A4
Entry Wire Line
	3350 4500 3450 4600
Entry Wire Line
	3350 4400 3450 4500
Wire Wire Line
	3450 4500 3550 4500
Entry Wire Line
	3450 4700 3350 4600
Text HLabel 3550 4600 2    60   Input ~ 0
A3
Entry Wire Line
	3450 4800 3350 4700
Text HLabel 3550 4800 2    60   Input ~ 0
A1
Wire Bus Line
	3350 4100 3350 4950
Text Label 3350 4150 0    60   ~ 0
A[0..15]
Wire Wire Line
	3450 4900 3550 4900
Wire Wire Line
	3450 4800 3550 4800
Wire Wire Line
	3450 4600 3550 4600
Wire Wire Line
	3550 4700 3450 4700
Wire Bus Line
	3350 2700 3350 3750
Entry Wire Line
	3350 3050 3450 3150
Entry Wire Line
	3350 3250 3450 3350
Entry Wire Line
	3350 3450 3450 3550
Entry Wire Line
	3350 3650 3450 3750
Wire Wire Line
	3450 3150 3600 3150
Wire Wire Line
	3450 3350 3600 3350
Wire Wire Line
	3450 3550 3600 3550
Wire Wire Line
	3450 3750 3600 3750
Text Label 3450 3150 0    60   ~ 0
D7
Text Label 3450 3350 0    60   ~ 0
D5
Text Label 3450 3550 0    60   ~ 0
D3
Text Label 3450 3750 0    60   ~ 0
D1
Text Label 3350 2650 0    60   ~ 0
D[0..7]
Entry Wire Line
	3450 3250 3350 3150
Entry Wire Line
	3450 3450 3350 3350
Entry Wire Line
	3450 3650 3350 3550
Entry Wire Line
	3450 3850 3350 3750
Wire Wire Line
	3600 3250 3450 3250
Wire Wire Line
	3600 3450 3450 3450
Wire Wire Line
	3600 3650 3450 3650
Wire Wire Line
	3600 3850 3450 3850
Text Label 3550 3250 2    60   ~ 0
D6
Text Label 3550 3450 2    60   ~ 0
D4
Text Label 3550 3650 2    60   ~ 0
D2
Text Label 3550 3850 2    60   ~ 0
D0
Text HLabel 3600 3850 2    60   Input ~ 0
D0
Text HLabel 3600 3750 2    60   Input ~ 0
D1
Text HLabel 3600 3650 2    60   Input ~ 0
D2
Text HLabel 3600 3550 2    60   Input ~ 0
D3
Text HLabel 3600 3450 2    60   Input ~ 0
D4
Text HLabel 3600 3350 2    60   Input ~ 0
D5
Text HLabel 3600 3250 2    60   Input ~ 0
D6
Text HLabel 3600 3150 2    60   Input ~ 0
D7
Text Label 3450 4900 0    60   ~ 0
A0
Text Label 3450 4800 0    60   ~ 0
A1
Text Label 3450 4700 0    60   ~ 0
A2
Text Label 3450 4600 0    60   ~ 0
A3
Text Label 3450 4500 0    60   ~ 0
A4
NoConn ~ 5800 2750
NoConn ~ 5300 2750
$EndSCHEMATC
