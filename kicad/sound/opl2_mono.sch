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
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:audio
LIBS:contrib
LIBS:y3014b
LIBS:ym3812
LIBS:rc4136
LIBS:osc
LIBS:yamaha_opl
EELAYER 25 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 1 2
Title "OPL2-Board YM3812"
Date "01.01.2015"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Label 14650 2750 2    60   ~ 0
A_OUT
$Comp
L GND #PWR01
U 1 1 50462CD9
P 9850 2150
F 0 "#PWR01" H 9850 2150 30  0001 C CNN
F 1 "GND" H 9850 2080 30  0001 C CNN
F 2 "" H 9850 2150 60  0001 C CNN
F 3 "" H 9850 2150 60  0001 C CNN
	1    9850 2150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR02
U 1 1 5044EFAD
P 14050 3450
F 0 "#PWR02" H 14050 3450 30  0001 C CNN
F 1 "GND" H 14050 3380 30  0001 C CNN
F 2 "" H 14050 3450 60  0001 C CNN
F 3 "" H 14050 3450 60  0001 C CNN
	1    14050 3450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR03
U 1 1 5044EE11
P 12850 3450
F 0 "#PWR03" H 12850 3450 30  0001 C CNN
F 1 "GND" H 12850 3380 30  0001 C CNN
F 2 "" H 12850 3450 60  0001 C CNN
F 3 "" H 12850 3450 60  0001 C CNN
	1    12850 3450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR04
U 1 1 5044EA91
P 14050 1950
F 0 "#PWR04" H 14050 1950 30  0001 C CNN
F 1 "GND" H 14050 1880 30  0001 C CNN
F 2 "" H 14050 1950 60  0001 C CNN
F 3 "" H 14050 1950 60  0001 C CNN
	1    14050 1950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR05
U 1 1 5044E8FF
P 12850 1950
F 0 "#PWR05" H 12850 1950 30  0001 C CNN
F 1 "GND" H 12850 1880 30  0001 C CNN
F 2 "" H 12850 1950 60  0001 C CNN
F 3 "" H 12850 1950 60  0001 C CNN
	1    12850 1950
	1    0    0    -1  
$EndComp
$Comp
L RC4136 U8
U 4 1 5043185F
P 13700 2750
F 0 "U8" H 13700 2750 60  0000 C CNN
F 1 "RC4136" H 13650 2450 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 13700 2750 60  0001 C CNN
F 3 "" H 13700 2750 60  0001 C CNN
	4    13700 2750
	1    0    0    -1  
$EndComp
$Comp
L RC4136 U8
U 3 1 5043185D
P 10800 1950
F 0 "U8" H 10800 1950 60  0000 C CNN
F 1 "RC4136" H 10750 1650 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 10800 1950 60  0001 C CNN
F 3 "" H 10800 1950 60  0001 C CNN
	3    10800 1950
	1    0    0    -1  
$EndComp
$Comp
L RC4136 U8
U 2 1 50431858
P 10800 1250
F 0 "U8" H 10800 1250 60  0000 C CNN
F 1 "RC4136" H 10750 950 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 10800 1250 60  0001 C CNN
F 3 "" H 10800 1250 60  0001 C CNN
	2    10800 1250
	1    0    0    -1  
$EndComp
$Comp
L RC4136 U8
U 1 1 50431856
P 13700 1250
F 0 "U8" H 13700 1250 60  0000 C CNN
F 1 "RC4136" H 13650 950 60  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 13700 1250 60  0001 C CNN
F 3 "" H 13700 1250 60  0001 C CNN
	1    13700 1250
	1    0    0    -1  
$EndComp
Text Label 7750 1350 0    60   ~ 0
DAC_DATA
Text Label 7750 1250 0    60   ~ 0
DAC_SYNC
Text Label 7750 1150 0    60   ~ 0
DAC_CLK
$Comp
L Y3014B U7
U 1 1 50431497
P 8950 1350
F 0 "U7" H 8950 1400 60  0000 C CNN
F 1 "Y3014B" H 8950 1300 60  0000 C CNN
F 2 "Sockets_DIP:DIP-8__300_ELL" H 8950 1350 60  0001 C CNN
F 3 "" H 8950 1350 60  0001 C CNN
	1    8950 1350
	1    0    0    -1  
$EndComp
Text Label 7300 2750 2    60   ~ 0
~IRQ
Text Label 5100 2850 0    60   ~ 0
~RESET
Text Label 5100 2450 0    60   ~ 0
~CSW
Text Label 5100 2350 0    60   ~ 0
~CSR
Text Label 5100 2150 0    60   ~ 0
CS
Text Label 5100 2650 0    60   ~ 0
YM_CLK
Text Label 7500 1350 2    60   ~ 0
DAC_DATA
Text Label 7500 1250 2    60   ~ 0
DAC_SYNC
Text Label 7500 1150 2    60   ~ 0
DAC_CLK
Text Label 5100 1950 0    60   ~ 0
A0
Text Label 5100 1750 0    60   ~ 0
D7
Text Label 5100 1650 0    60   ~ 0
D6
Text Label 5100 1550 0    60   ~ 0
D5
Text Label 5100 1450 0    60   ~ 0
D4
Text Label 5100 1350 0    60   ~ 0
D3
Text Label 5100 1250 0    60   ~ 0
D2
Text Label 5100 1150 0    60   ~ 0
D1
Text Label 5100 1050 0    60   ~ 0
D0
$Comp
L YM3812 U6
U 1 1 5042F888
P 6300 1950
F 0 "U6" H 6300 2000 60  0000 C CNN
F 1 "YM3812" H 6300 1900 60  0000 C CNN
F 2 "Sockets_DIP:DIP-24__600_ELL" H 6300 1950 60  0001 C CNN
F 3 "" H 6300 1950 60  0001 C CNN
	1    6300 1950
	1    0    0    -1  
$EndComp
$Comp
L CP1 C15
U 1 1 5042B676
P 9850 1850
F 0 "C15" H 9900 1950 50  0000 L CNN
F 1 "10uF" H 9900 1750 50  0000 L CNN
F 2 "Capacitors_Elko_ThroughHole:Elko_vert_11x5mm_RM2.5" H 9850 1850 60  0001 C CNN
F 3 "" H 9850 1850 60  0001 C CNN
	1    9850 1850
	1    0    0    -1  
$EndComp
$Comp
L C C23
U 1 1 5042B65A
P 12450 2450
F 0 "C23" H 12500 2550 50  0000 L CNN
F 1 "4.7nF" H 12500 2350 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 12450 2450 60  0001 C CNN
F 3 "" H 12450 2450 60  0001 C CNN
	1    12450 2450
	0    -1   -1   0   
$EndComp
$Comp
L C C24
U 1 1 5042B658
P 12850 3050
F 0 "C24" H 12900 3150 50  0000 L CNN
F 1 "4.7nF" H 12900 2950 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 12850 3050 60  0001 C CNN
F 3 "" H 12850 3050 60  0001 C CNN
	1    12850 3050
	1    0    0    -1  
$EndComp
$Comp
L C C21
U 1 1 5042B656
P 12450 950
F 0 "C21" H 12500 1050 50  0000 L CNN
F 1 "4.7nF" H 12500 850 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 12450 950 60  0001 C CNN
F 3 "" H 12450 950 60  0001 C CNN
	1    12450 950 
	0    -1   -1   0   
$EndComp
$Comp
L C C22
U 1 1 5042B654
P 12850 1550
F 0 "C22" H 12900 1650 50  0000 L CNN
F 1 "4.7nF" H 12900 1450 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 12850 1550 60  0001 C CNN
F 3 "" H 12850 1550 60  0001 C CNN
	1    12850 1550
	1    0    0    -1  
$EndComp
$Comp
L R R14
U 1 1 5042B5AB
P 13700 3150
F 0 "R14" V 13780 3150 50  0000 C CNN
F 1 "1.5k" V 13700 3150 50  0000 C CNN
F 2 "Discret:R3" H 13700 3150 60  0001 C CNN
F 3 "" H 13700 3150 60  0001 C CNN
	1    13700 3150
	0    1    1    0   
$EndComp
$Comp
L R R3
U 1 1 5042B5A7
P 13700 3350
F 0 "R3" V 13780 3350 50  0000 C CNN
F 1 "10k" V 13700 3350 50  0000 C CNN
F 2 "Discret:R3" H 13700 3350 60  0001 C CNN
F 3 "" H 13700 3350 60  0001 C CNN
	1    13700 3350
	0    1    1    0   
$EndComp
$Comp
L R R11
U 1 1 5042B5A5
P 12500 2750
F 0 "R11" V 12580 2750 50  0000 C CNN
F 1 "2.2k" V 12500 2750 50  0000 C CNN
F 2 "Discret:R3" H 12500 2750 60  0001 C CNN
F 3 "" H 12500 2750 60  0001 C CNN
	1    12500 2750
	0    1    1    0   
$EndComp
$Comp
L R R10
U 1 1 5042B5A3
P 11800 2750
F 0 "R10" V 11880 2750 50  0000 C CNN
F 1 "2.2k" V 11800 2750 50  0000 C CNN
F 2 "Discret:R3" H 11800 2750 60  0001 C CNN
F 3 "" H 11800 2750 60  0001 C CNN
	1    11800 2750
	0    1    1    0   
$EndComp
$Comp
L R R1
U 1 1 5042B5A0
P 13700 1650
F 0 "R1" V 13780 1650 50  0000 C CNN
F 1 "12k" V 13700 1650 50  0000 C CNN
F 2 "Discret:R3" H 13700 1650 60  0001 C CNN
F 3 "" H 13700 1650 60  0001 C CNN
	1    13700 1650
	0    1    1    0   
$EndComp
$Comp
L R R2
U 1 1 5042B599
P 13700 1850
F 0 "R2" V 13780 1850 50  0000 C CNN
F 1 "10k" V 13700 1850 50  0000 C CNN
F 2 "Discret:R3" H 13700 1850 60  0001 C CNN
F 3 "" H 13700 1850 60  0001 C CNN
	1    13700 1850
	0    1    1    0   
$EndComp
$Comp
L R R8
U 1 1 5042B588
P 11800 1250
F 0 "R8" V 11880 1250 50  0000 C CNN
F 1 "2.2k" V 11800 1250 50  0000 C CNN
F 2 "Discret:R3" H 11800 1250 60  0001 C CNN
F 3 "" H 11800 1250 60  0001 C CNN
	1    11800 1250
	0    1    1    0   
$EndComp
$Comp
L R R9
U 1 1 5042B585
P 12500 1250
F 0 "R9" V 12580 1250 50  0000 C CNN
F 1 "2.2k" V 12500 1250 50  0000 C CNN
F 2 "Discret:R3" H 12500 1250 60  0001 C CNN
F 3 "" H 12500 1250 60  0001 C CNN
	1    12500 1250
	0    1    1    0   
$EndComp
$Sheet
S 600  600  500  1450
U 549DAACF
F0 "Sheet549DAACE" 60
F1 "50pin_connector.sch" 60
F2 "A0" I R 1100 700 60 
F3 "D0" I R 1100 1300 60 
F4 "D1" I R 1100 1400 60 
F5 "D2" I R 1100 1500 60 
F6 "D3" I R 1100 1600 60 
F7 "D4" I R 1100 1700 60 
F8 "D5" I R 1100 1800 60 
F9 "D6" I R 1100 1900 60 
F10 "D7" I R 1100 2000 60 
$EndSheet
Text GLabel 4900 2150 0    60   Input ~ 0
/CS_IO0
Text GLabel 4850 2850 0    60   Input ~ 0
/RESET
Connection ~ 9850 1550
Wire Wire Line
	9850 1550 9850 1700
Wire Wire Line
	14150 2750 14650 2750
Wire Wire Line
	9750 1150 10350 1150
Wire Wire Line
	14050 3350 14050 3450
Wire Wire Line
	13850 3350 14050 3350
Wire Wire Line
	13250 2850 13150 2850
Wire Wire Line
	13150 2850 13150 3350
Wire Wire Line
	13150 3350 13550 3350
Wire Wire Line
	13850 1850 14050 1850
Connection ~ 12150 2750
Wire Wire Line
	12150 2450 12300 2450
Wire Wire Line
	12150 2450 12150 2750
Connection ~ 12850 2750
Wire Wire Line
	12850 2650 12850 2900
Wire Wire Line
	11950 2750 12350 2750
Wire Wire Line
	14150 1250 14550 1250
Wire Wire Line
	12150 950  12300 950 
Connection ~ 12150 1250
Wire Wire Line
	12150 950  12150 1250
Connection ~ 13150 1650
Wire Wire Line
	13150 1350 13150 1850
Wire Wire Line
	13850 1650 14250 1650
Wire Wire Line
	12650 1250 12850 1250
Wire Wire Line
	11950 1250 12350 1250
Connection ~ 10150 2350
Wire Wire Line
	10150 2350 10150 2050
Wire Wire Line
	10150 2050 10350 2050
Wire Wire Line
	8150 1550 8050 1550
Wire Wire Line
	11350 1250 11350 1650
Wire Wire Line
	11350 1650 10250 1650
Wire Wire Line
	10250 1650 10250 1350
Wire Wire Line
	10250 1350 10350 1350
Wire Wire Line
	8150 1250 7750 1250
Wire Wire Line
	4900 2150 5500 2150
Wire Wire Line
	5500 2450 5100 2450
Wire Wire Line
	4850 2850 5500 2850
Wire Wire Line
	7100 1250 7500 1250
Wire Wire Line
	5500 1950 5100 1950
Wire Wire Line
	5500 1050 5100 1050
Wire Wire Line
	5500 1150 5100 1150
Wire Wire Line
	5500 1250 5100 1250
Wire Wire Line
	5500 1350 5100 1350
Wire Wire Line
	5500 1450 5100 1450
Wire Wire Line
	5500 1550 5100 1550
Wire Wire Line
	5500 1650 5100 1650
Wire Wire Line
	5500 1750 5100 1750
Wire Wire Line
	7100 1150 7500 1150
Wire Wire Line
	7100 1350 7500 1350
Wire Wire Line
	5500 2650 4400 2650
Wire Wire Line
	5500 2350 5100 2350
Wire Wire Line
	7100 2750 7350 2750
Wire Wire Line
	8150 1150 7750 1150
Wire Wire Line
	8150 1350 7750 1350
Wire Wire Line
	11250 1950 11350 1950
Wire Wire Line
	11350 1950 11350 2350
Wire Wire Line
	11350 2350 8050 2350
Wire Wire Line
	8050 2350 8050 1550
Wire Wire Line
	11250 1250 11650 1250
Connection ~ 11350 1250
Wire Wire Line
	12850 1700 12850 1950
Wire Wire Line
	12850 1150 12850 1400
Wire Wire Line
	12850 1150 13250 1150
Connection ~ 12850 1250
Wire Wire Line
	13150 1350 13250 1350
Wire Wire Line
	13150 1650 13550 1650
Wire Wire Line
	14050 1850 14050 1950
Wire Wire Line
	14250 1650 14250 950 
Connection ~ 14250 1250
Wire Wire Line
	14250 950  12600 950 
Wire Wire Line
	11450 2750 11650 2750
Wire Wire Line
	11450 2750 11450 2150
Wire Wire Line
	11450 2150 14550 2150
Wire Wire Line
	14550 2150 14550 1250
Wire Wire Line
	12650 2750 12850 2750
Wire Wire Line
	12850 2650 13250 2650
Wire Wire Line
	12850 3200 12850 3450
Wire Wire Line
	12600 2450 14250 2450
Wire Wire Line
	13150 1850 13550 1850
Wire Wire Line
	13150 3150 13550 3150
Connection ~ 13150 3150
Wire Wire Line
	13850 3150 14250 3150
Wire Wire Line
	14250 3150 14250 2450
Connection ~ 14250 2750
Wire Wire Line
	10350 1850 10150 1850
Wire Wire Line
	10150 1850 10150 1550
Wire Wire Line
	10150 1550 9750 1550
Wire Wire Line
	9850 2000 9850 2150
Wire Wire Line
	1300 700  1100 700 
Wire Wire Line
	1300 1300 1100 1300
Wire Wire Line
	1300 1400 1100 1400
Wire Wire Line
	1300 1500 1100 1500
Wire Wire Line
	1300 1600 1100 1600
Wire Wire Line
	1300 1700 1100 1700
Wire Wire Line
	1300 1800 1100 1800
Wire Wire Line
	1300 1900 1100 1900
Wire Wire Line
	1300 2000 1100 2000
Text Label 1150 700  0    60   ~ 0
A0
Text Label 1150 1300 0    60   ~ 0
D0
Text Label 1150 1400 0    60   ~ 0
D1
Text Label 1150 1500 0    60   ~ 0
D2
Text Label 1150 1600 0    60   ~ 0
D3
Text Label 1150 1700 0    60   ~ 0
D4
Text Label 1150 1800 0    60   ~ 0
D5
Text Label 1150 1900 0    60   ~ 0
D6
Text Label 1150 2000 0    60   ~ 0
D7
Text GLabel 7350 2750 2    60   Input ~ 0
/IRQ
$Comp
L OSC X1
U 1 1 56325C95
P 3700 2800
F 0 "X1" H 3700 3100 70  0000 C CNN
F 1 "OSC" H 3700 2800 70  0000 C CNN
F 2 "Sockets_DIP:DIP-14__300_ELL" H 3700 2800 60  0001 C CNN
F 3 "" H 3700 2800 60  0000 C CNN
	1    3700 2800
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR06
U 1 1 56326AC6
P 2950 3000
F 0 "#PWR06" H 2950 3000 30  0001 C CNN
F 1 "GND" H 2950 2930 30  0001 C CNN
F 2 "" H 2950 3000 60  0001 C CNN
F 3 "" H 2950 3000 60  0001 C CNN
	1    2950 3000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 2950 2950 2950
Wire Wire Line
	2950 2950 2950 3000
$Comp
L VCC #PWR07
U 1 1 56326E87
P 2950 2450
F 0 "#PWR07" H 2950 2300 60  0001 C CNN
F 1 "VCC" H 2950 2600 60  0000 C CNN
F 2 "" H 2950 2450 60  0000 C CNN
F 3 "" H 2950 2450 60  0000 C CNN
	1    2950 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 2650 2950 2650
Wire Wire Line
	2950 2650 2950 2450
$Comp
L 74LS139 U?
U 2 1 5BD59D2E
P 4400 3900
F 0 "U?" H 4400 4000 50  0000 C CNN
F 1 "74LS139" H 4400 3800 50  0000 C CNN
F 2 "" H 4400 3900 50  0001 C CNN
F 3 "" H 4400 3900 50  0001 C CNN
	2    4400 3900
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 5BD59F5A
P 3000 3750
F 0 "#PWR?" H 3000 3750 30  0001 C CNN
F 1 "GND" H 3000 3680 30  0001 C CNN
F 2 "" H 3000 3750 60  0001 C CNN
F 3 "" H 3000 3750 60  0001 C CNN
	1    3000 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	3000 3750 3000 3650
Wire Wire Line
	3000 3650 3550 3650
Text GLabel 3400 3800 0    60   Input ~ 0
/RW
Wire Wire Line
	3400 3800 3550 3800
Text GLabel 3400 4150 0    60   Input ~ 0
/CS_IO0
Wire Wire Line
	3400 4150 3550 4150
Wire Wire Line
	5250 3600 5500 3600
Wire Wire Line
	5250 3800 5500 3800
Text Label 5350 3800 0    60   ~ 0
~CSR
Text Label 5350 3600 0    60   ~ 0
~CSW
NoConn ~ 5250 4000
NoConn ~ 5250 4200
NoConn ~ 4400 2950
$EndSCHEMATC
