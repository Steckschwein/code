EESchema Schematic File Version 2
LIBS:tms99xx
LIBS:dram
LIBS:osc
LIBS:mini_din
LIBS:steckschwein
LIBS:yamaha_opl
LIBS:rc4136
LIBS:ttl_ieee
LIBS:v9958-cache
EELAYER 25 0
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
Text GLabel 950  2200 0    60   Input ~ 0
/RW
Text GLabel 1150 2550 0    60   Input ~ 0
/CS_VDP
$Comp
L VCC #PWR01
U 1 1 5A293DA5
P 4550 3850
F 0 "#PWR01" H 4550 3950 30  0001 C CNN
F 1 "VCC" H 4550 3950 30  0000 C CNN
F 2 "" H 4550 3850 60  0000 C CNN
F 3 "" H 4550 3850 60  0000 C CNN
	1    4550 3850
	0    -1   -1   0   
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR02
U 1 1 5A29423B
P 4550 1200
F 0 "#PWR02" H 4550 1200 30  0001 C CNN
F 1 "GND" H 4550 1130 30  0001 C CNN
F 2 "" H 4550 1200 60  0000 C CNN
F 3 "" H 4550 1200 60  0000 C CNN
	1    4550 1200
	0    1    1    0   
$EndComp
$Comp
L Crystal_Small Y1
U 1 1 5A294977
P 5400 600
F 0 "Y1" H 5400 700 50  0000 C CNN
F 1 "21,443Mhz" H 5400 500 50  0000 C CNN
F 2 "Crystals:Crystal_HC49-U_Vertical" H 5400 600 50  0001 C CNN
F 3 "" H 5400 600 50  0001 C CNN
	1    5400 600 
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 5A295482
P 5100 750
F 0 "C1" H 5125 850 50  0000 L CNN
F 1 "22p" H 5125 650 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 5138 600 50  0001 C CNN
F 3 "" H 5100 750 50  0001 C CNN
	1    5100 750 
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 5A2954F6
P 5700 750
F 0 "C2" H 5725 850 50  0000 L CNN
F 1 "22p" H 5725 650 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 5738 600 50  0001 C CNN
F 3 "" H 5700 750 50  0001 C CNN
	1    5700 750 
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR03
U 1 1 5A2957D7
P 5100 900
F 0 "#PWR03" H 5100 900 30  0001 C CNN
F 1 "GND" H 5100 830 30  0001 C CNN
F 2 "" H 5100 900 60  0000 C CNN
F 3 "" H 5100 900 60  0000 C CNN
	1    5100 900 
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR04
U 1 1 5A2958EA
P 5700 900
F 0 "#PWR04" H 5700 900 30  0001 C CNN
F 1 "GND" H 5700 830 30  0001 C CNN
F 2 "" H 5700 900 60  0000 C CNN
F 3 "" H 5700 900 60  0000 C CNN
	1    5700 900 
	1    0    0    -1  
$EndComp
Text Label 6200 3750 0    60   ~ 0
RGB_B
Text Label 6200 3850 0    60   ~ 0
RGB_R
Text Label 6200 3950 0    60   ~ 0
RGB_G
Text GLabel 4550 1600 0    60   Input ~ 0
/RESET
Text GLabel 4550 1700 0    60   Input ~ 0
/IRQ
$Comp
L V9958 U2
U 1 1 5A2996C3
P 5400 2550
F 0 "U2" H 5500 1000 60  0000 C CNN
F 1 "V9958" H 5050 1000 60  0000 C CNN
F 2 "SDIP:SDIP64" H 5750 2600 60  0001 C CNN
F 3 "" H 5750 2600 60  0001 C CNN
	1    5400 2550
	1    0    0    -1  
$EndComp
Text Label 6200 4050 0    60   ~ 0
CSYNC
$Comp
L DRAM_64KX4 U3
U 1 1 5A821A58
P 7550 1450
F 0 "U3" H 7550 1450 50  0000 C CNN
F 1 "DRAM_64KX4" H 7550 950 50  0000 C CNN
F 2 "Housings_DIP:DIP-18_W7.62mm_LongPads" H 7550 1450 50  0001 C CNN
F 3 "" H 7550 1450 50  0000 C CNN
	1    7550 1450
	1    0    0    -1  
$EndComp
$Comp
L DRAM_64KX4 U5
U 1 1 5A821B58
P 9700 1450
F 0 "U5" H 9700 1450 50  0000 C CNN
F 1 "DRAM_64KX4" H 9700 950 50  0000 C CNN
F 2 "Housings_DIP:DIP-18_W7.62mm_LongPads" H 9700 1450 50  0001 C CNN
F 3 "" H 9700 1450 50  0000 C CNN
	1    9700 1450
	1    0    0    -1  
$EndComp
$Comp
L DRAM_64KX4 U4
U 1 1 5A821C38
P 7550 2800
F 0 "U4" H 7550 2800 50  0000 C CNN
F 1 "DRAM_64KX4" H 7550 2300 50  0000 C CNN
F 2 "Housings_DIP:DIP-18_W7.62mm_LongPads" H 7550 2800 50  0001 C CNN
F 3 "" H 7550 2800 50  0000 C CNN
	1    7550 2800
	1    0    0    -1  
$EndComp
$Comp
L DRAM_64KX4 U6
U 1 1 5A821D05
P 9700 2800
F 0 "U6" H 9700 2800 50  0000 C CNN
F 1 "DRAM_64KX4" H 9700 2300 50  0000 C CNN
F 2 "Housings_DIP:DIP-18_W7.62mm_LongPads" H 9700 2800 50  0001 C CNN
F 3 "" H 9700 2800 50  0000 C CNN
	1    9700 2800
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR05
U 1 1 5A824C6E
P 8250 1900
F 0 "#PWR05" H 8250 1900 30  0001 C CNN
F 1 "GND" H 8250 1830 30  0001 C CNN
F 2 "" H 8250 1900 60  0000 C CNN
F 3 "" H 8250 1900 60  0000 C CNN
	1    8250 1900
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR06
U 1 1 5A825093
P 10450 1950
F 0 "#PWR06" H 10450 1950 30  0001 C CNN
F 1 "GND" H 10450 1880 30  0001 C CNN
F 2 "" H 10450 1950 60  0000 C CNN
F 3 "" H 10450 1950 60  0000 C CNN
	1    10450 1950
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR07
U 1 1 5A8252B2
P 8300 3250
F 0 "#PWR07" H 8300 3250 30  0001 C CNN
F 1 "GND" H 8300 3180 30  0001 C CNN
F 2 "" H 8300 3250 60  0000 C CNN
F 3 "" H 8300 3250 60  0000 C CNN
	1    8300 3250
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR08
U 1 1 5A8253E1
P 10450 3300
F 0 "#PWR08" H 10450 3300 30  0001 C CNN
F 1 "GND" H 10450 3230 30  0001 C CNN
F 2 "" H 10450 3300 60  0000 C CNN
F 3 "" H 10450 3300 60  0000 C CNN
	1    10450 3300
	1    0    0    -1  
$EndComp
Entry Wire Line
	10600 1350 10700 1250
Entry Wire Line
	10600 1250 10700 1150
Entry Wire Line
	10600 1150 10700 1050
Entry Wire Line
	10600 1050 10700 950 
Text Label 10700 900  0    60   ~ 0
RD0..RD7
Entry Wire Line
	10600 2700 10700 2600
Entry Wire Line
	10600 2600 10700 2500
Entry Wire Line
	10600 2500 10700 2400
Entry Wire Line
	10600 2400 10700 2300
Text Label 10700 2250 0    60   ~ 0
RD0..RD7
Entry Wire Line
	6350 2300 6450 2200
Entry Wire Line
	6350 2200 6450 2100
Entry Wire Line
	6350 2100 6450 2000
Entry Wire Line
	6350 2000 6450 1900
Entry Wire Line
	6350 2700 6450 2600
Entry Wire Line
	6350 2600 6450 2500
Entry Wire Line
	6350 2500 6450 2400
Entry Wire Line
	6350 2400 6450 2300
NoConn ~ 6200 1750
$Sheet
S 1700 3700 800  1850
U 5A81FDB5
F0 "50pin connector" 60
F1 "50pin_connector.sch" 60
F2 "A0" I L 1700 3800 60 
F3 "A2" I L 1700 4000 60 
F4 "A4" I L 1700 4200 60 
F5 "A3" I L 1700 4100 60 
F6 "A1" I L 1700 3900 60 
F7 "D0" I L 1700 4450 60 
F8 "D1" I L 1700 4550 60 
F9 "D2" I L 1700 4650 60 
F10 "D3" I L 1700 4750 60 
F11 "D4" I L 1700 4850 60 
F12 "D5" I L 1700 4950 60 
F13 "D6" I L 1700 5050 60 
F14 "D7" I L 1700 5150 60 
F15 "A5" I L 1700 4300 60 
F16 "RESET_TRIG" I L 1700 5400 60 
$EndSheet
NoConn ~ 1700 4300
NoConn ~ 1700 4200
NoConn ~ 1700 4100
NoConn ~ 1700 4000
Text Label 1500 3800 0    60   ~ 0
A0
Text Label 1500 3900 0    60   ~ 0
A1
Text Label 4500 2450 0    60   ~ 0
A0
Text Label 4500 2350 0    60   ~ 0
A1
Entry Wire Line
	4400 3550 4500 3650
Entry Wire Line
	4400 3450 4500 3550
Entry Wire Line
	4400 3350 4500 3450
Entry Wire Line
	4400 3250 4500 3350
Entry Wire Line
	4400 3150 4500 3250
Entry Wire Line
	4400 3050 4500 3150
Entry Wire Line
	4400 2950 4500 3050
Entry Wire Line
	4400 2850 4500 2950
Text Label 4400 2850 0    60   ~ 0
D0..D7
NoConn ~ 1700 5400
$Comp
L JUMPER JP1
U 1 1 5A825872
P 4000 1800
F 0 "JP1" H 4000 1950 50  0000 C CNN
F 1 "JUMPER" H 4000 1720 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x02" H 4000 1800 50  0001 C CNN
F 3 "" H 4000 1800 50  0000 C CNN
	1    4000 1800
	1    0    0    -1  
$EndComp
Text GLabel 3600 1800 0    60   Input ~ 0
RDY
Text Label 6300 1450 0    60   ~ 0
/RAS
Text Label 8250 3150 0    60   ~ 0
/RAS
Text Label 8200 1800 0    60   ~ 0
/RAS
Text Label 10400 1800 0    60   ~ 0
/RAS
Text Label 10400 3150 0    60   ~ 0
/RAS
Text Label 6350 1850 0    60   ~ 0
R/W
Text Label 8300 1500 0    60   ~ 0
R/W
Text Label 8250 2850 0    60   ~ 0
R/W
Text Label 10450 2850 0    60   ~ 0
R/W
Text Label 10450 1500 0    60   ~ 0
R/W
Text Label 6300 1550 0    60   ~ 0
/CAS0
Text Label 8200 1700 0    60   ~ 0
/CAS0
Text Label 8250 3050 0    60   ~ 0
/CAS0
Text Label 6300 1650 0    60   ~ 0
/CAS1
Text Label 10400 1700 0    60   ~ 0
/CAS1
Text Label 10400 3050 0    60   ~ 0
/CAS1
Text Label 10400 1050 0    60   ~ 0
RD0
Text Label 10400 1150 0    60   ~ 0
RD1
Text Label 10400 1250 0    60   ~ 0
RD2
Text Label 10400 1350 0    60   ~ 0
RD3
Text Label 6200 2000 0    60   ~ 0
RD0
Text Label 6200 2100 0    60   ~ 0
RD1
Text Label 6200 2200 0    60   ~ 0
RD2
Text Label 6200 2300 0    60   ~ 0
RD3
Text Label 6200 2400 0    60   ~ 0
RD4
Text Label 6200 2500 0    60   ~ 0
RD5
Text Label 6200 2600 0    60   ~ 0
RD6
Text Label 6200 2700 0    60   ~ 0
RD7
Entry Wire Line
	8450 1350 8550 1250
Entry Wire Line
	8450 1250 8550 1150
Entry Wire Line
	8450 1150 8550 1050
Entry Wire Line
	8450 1050 8550 950 
Text Label 8550 900  0    60   ~ 0
RD0..RD7
Text Label 8250 1050 0    60   ~ 0
RD0
Text Label 8250 1150 0    60   ~ 0
RD1
Text Label 8250 1250 0    60   ~ 0
RD2
Text Label 8250 1350 0    60   ~ 0
RD3
Text Label 10400 2400 0    60   ~ 0
RD4
Text Label 10400 2500 0    60   ~ 0
RD5
Text Label 10400 2600 0    60   ~ 0
RD6
Text Label 10400 2700 0    60   ~ 0
RD7
Entry Wire Line
	8450 2700 8550 2600
Entry Wire Line
	8450 2600 8550 2500
Entry Wire Line
	8450 2500 8550 2400
Entry Wire Line
	8450 2400 8550 2300
Text Label 8550 2250 0    60   ~ 0
RD0..RD7
Text Label 8250 2400 0    60   ~ 0
RD4
Text Label 8250 2500 0    60   ~ 0
RD5
Text Label 8250 2600 0    60   ~ 0
RD6
Text Label 8250 2700 0    60   ~ 0
RD7
Entry Wire Line
	6450 2800 6350 2900
Entry Wire Line
	6450 2900 6350 3000
Entry Wire Line
	6450 3000 6350 3100
Entry Wire Line
	6450 3100 6350 3200
Entry Wire Line
	6450 3200 6350 3300
Entry Wire Line
	6450 3300 6350 3400
Entry Wire Line
	6450 3400 6350 3500
Entry Wire Line
	6450 3500 6350 3600
Text Label 6450 2800 2    60   ~ 0
A0..A7
Text Label 6350 2900 2    60   ~ 0
AD0
Text Label 6350 3000 2    60   ~ 0
AD1
Text Label 6350 3100 2    60   ~ 0
AD2
Text Label 6350 3200 2    60   ~ 0
AD3
Text Label 6350 3300 2    60   ~ 0
AD4
Text Label 6350 3400 2    60   ~ 0
AD5
Text Label 6350 3500 2    60   ~ 0
AD6
Text Label 6350 3600 2    60   ~ 0
AD7
Text Label 4550 3650 0    60   ~ 0
D0
Text Label 4550 3550 0    60   ~ 0
D1
Text Label 4550 3450 0    60   ~ 0
D2
Text Label 4550 3350 0    60   ~ 0
D3
Text Label 4550 3250 0    60   ~ 0
D4
Text Label 4550 3150 0    60   ~ 0
D5
Text Label 4550 3050 0    60   ~ 0
D6
Text Label 4550 2950 0    60   ~ 0
D7
Entry Wire Line
	1450 4550 1550 4450
Entry Wire Line
	1450 4650 1550 4550
Entry Wire Line
	1450 4750 1550 4650
Entry Wire Line
	1450 4850 1550 4750
Entry Wire Line
	1450 4950 1550 4850
Entry Wire Line
	1450 5050 1550 4950
Entry Wire Line
	1450 5150 1550 5050
Entry Wire Line
	1450 5250 1550 5150
Text Label 1450 5250 0    60   ~ 0
D0..D7
Text Label 1600 4450 0    60   ~ 0
D0
Text Label 1600 4550 0    60   ~ 0
D1
Text Label 1600 4650 0    60   ~ 0
D2
Text Label 1600 4750 0    60   ~ 0
D3
Text Label 1600 4850 0    60   ~ 0
D4
Text Label 1600 4950 0    60   ~ 0
D5
Text Label 1600 5050 0    60   ~ 0
D6
Text Label 1600 5150 0    60   ~ 0
D7
$Comp
L VCC #PWR09
U 1 1 5A8492E5
P 6300 1050
F 0 "#PWR09" H 6300 1150 30  0001 C CNN
F 1 "VCC" H 6300 1150 30  0000 C CNN
F 2 "" H 6300 1050 60  0000 C CNN
F 3 "" H 6300 1050 60  0000 C CNN
	1    6300 1050
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR010
U 1 1 5A849B3A
P 800 650
F 0 "#PWR010" H 800 750 30  0001 C CNN
F 1 "VCC" H 800 750 30  0000 C CNN
F 2 "" H 800 650 60  0000 C CNN
F 3 "" H 800 650 60  0000 C CNN
	1    800  650 
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR011
U 1 1 5A849BF6
P 800 1250
F 0 "#PWR011" H 800 1250 30  0001 C CNN
F 1 "GND" H 800 1180 30  0001 C CNN
F 2 "" H 800 1250 60  0000 C CNN
F 3 "" H 800 1250 60  0000 C CNN
	1    800  1250
	1    0    0    -1  
$EndComp
$Comp
L C C3
U 1 1 5A84A455
P 1000 900
F 0 "C3" H 1025 1000 50  0000 L CNN
F 1 "100n" H 1025 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 1038 750 50  0001 C CNN
F 3 "" H 1000 900 50  0001 C CNN
	1    1000 900 
	1    0    0    -1  
$EndComp
$Comp
L C C4
U 1 1 5A84B161
P 1300 900
F 0 "C4" H 1325 1000 50  0000 L CNN
F 1 "100n" H 1325 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 1338 750 50  0001 C CNN
F 3 "" H 1300 900 50  0001 C CNN
	1    1300 900 
	1    0    0    -1  
$EndComp
$Comp
L C C5
U 1 1 5A84B232
P 1600 900
F 0 "C5" H 1625 1000 50  0000 L CNN
F 1 "100n" H 1625 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 1638 750 50  0001 C CNN
F 3 "" H 1600 900 50  0001 C CNN
	1    1600 900 
	1    0    0    -1  
$EndComp
$Comp
L C C6
U 1 1 5A84B308
P 1900 900
F 0 "C6" H 1925 1000 50  0000 L CNN
F 1 "100n" H 1925 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 1938 750 50  0001 C CNN
F 3 "" H 1900 900 50  0001 C CNN
	1    1900 900 
	1    0    0    -1  
$EndComp
$Comp
L C C7
U 1 1 5A84B3DF
P 2200 900
F 0 "C7" H 2225 1000 50  0000 L CNN
F 1 "100n" H 2225 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 2238 750 50  0001 C CNN
F 3 "" H 2200 900 50  0001 C CNN
	1    2200 900 
	1    0    0    -1  
$EndComp
$Comp
L C C8
U 1 1 5A84B731
P 2500 900
F 0 "C8" H 2525 1000 50  0000 L CNN
F 1 "100n" H 2525 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 2538 750 50  0001 C CNN
F 3 "" H 2500 900 50  0001 C CNN
	1    2500 900 
	1    0    0    -1  
$EndComp
Text Label 850  750  0    60   ~ 0
VCC
Text Label 800  1050 0    60   ~ 0
GND
NoConn ~ 6200 1300
$Comp
L GND-RESCUE-v9958 #PWR012
U 1 1 5A860600
P 4550 2000
F 0 "#PWR012" H 4550 2000 30  0001 C CNN
F 1 "GND" H 4550 1930 30  0001 C CNN
F 2 "" H 4550 2000 60  0000 C CNN
F 3 "" H 4550 2000 60  0000 C CNN
	1    4550 2000
	0    1    1    0   
$EndComp
$Comp
L VCC #PWR013
U 1 1 5A86085E
P 4550 2100
F 0 "#PWR013" H 4550 2200 30  0001 C CNN
F 1 "VCC" H 4550 2200 30  0000 C CNN
F 2 "" H 4550 2100 60  0000 C CNN
F 3 "" H 4550 2100 60  0000 C CNN
	1    4550 2100
	0    -1   -1   0   
$EndComp
Text Label 6450 2050 0    60   ~ 0
RD0..RD7
Entry Wire Line
	6650 1000 6750 1100
Entry Wire Line
	6650 1100 6750 1200
Entry Wire Line
	6650 1200 6750 1300
Entry Wire Line
	6650 1300 6750 1400
Entry Wire Line
	6650 1400 6750 1500
Entry Wire Line
	6650 1500 6750 1600
Entry Wire Line
	6650 1600 6750 1700
Entry Wire Line
	6650 1700 6750 1800
Text Label 6650 1000 0    60   ~ 0
A0..A7
Text Label 6750 1100 0    60   ~ 0
AD0
Text Label 6750 1200 0    60   ~ 0
AD1
Text Label 6750 1300 0    60   ~ 0
AD2
Text Label 6750 1400 0    60   ~ 0
AD3
Text Label 6750 1500 0    60   ~ 0
AD4
Text Label 6750 1600 0    60   ~ 0
AD5
Text Label 6750 1700 0    60   ~ 0
AD6
Text Label 6750 1800 0    60   ~ 0
AD7
Entry Wire Line
	6650 2350 6750 2450
Entry Wire Line
	6650 2450 6750 2550
Entry Wire Line
	6650 2550 6750 2650
Entry Wire Line
	6650 2650 6750 2750
Entry Wire Line
	6650 2750 6750 2850
Entry Wire Line
	6650 2850 6750 2950
Entry Wire Line
	6650 2950 6750 3050
Entry Wire Line
	6650 3050 6750 3150
Text Label 6650 2350 0    60   ~ 0
A0..A7
Text Label 6750 2450 0    60   ~ 0
AD0
Text Label 6750 2550 0    60   ~ 0
AD1
Text Label 6750 2650 0    60   ~ 0
AD2
Text Label 6750 2750 0    60   ~ 0
AD3
Text Label 6750 2850 0    60   ~ 0
AD4
Text Label 6750 2950 0    60   ~ 0
AD5
Text Label 6750 3050 0    60   ~ 0
AD6
Text Label 6750 3150 0    60   ~ 0
AD7
Entry Wire Line
	8800 1000 8900 1100
Entry Wire Line
	8800 1100 8900 1200
Entry Wire Line
	8800 1200 8900 1300
Entry Wire Line
	8800 1300 8900 1400
Entry Wire Line
	8800 1400 8900 1500
Entry Wire Line
	8800 1500 8900 1600
Entry Wire Line
	8800 1600 8900 1700
Entry Wire Line
	8800 1700 8900 1800
Text Label 8800 1000 0    60   ~ 0
A0..A7
Text Label 8900 1100 0    60   ~ 0
AD0
Text Label 8900 1200 0    60   ~ 0
AD1
Text Label 8900 1300 0    60   ~ 0
AD2
Text Label 8900 1400 0    60   ~ 0
AD3
Text Label 8900 1500 0    60   ~ 0
AD4
Text Label 8900 1600 0    60   ~ 0
AD5
Text Label 8900 1700 0    60   ~ 0
AD6
Text Label 8900 1800 0    60   ~ 0
AD7
Entry Wire Line
	8800 2350 8900 2450
Entry Wire Line
	8800 2450 8900 2550
Entry Wire Line
	8800 2550 8900 2650
Entry Wire Line
	8800 2650 8900 2750
Entry Wire Line
	8800 2750 8900 2850
Entry Wire Line
	8800 2850 8900 2950
Entry Wire Line
	8800 2950 8900 3050
Entry Wire Line
	8800 3050 8900 3150
Text Label 8800 2350 0    60   ~ 0
A0..A7
Text Label 8900 2450 0    60   ~ 0
AD0
Text Label 8900 2550 0    60   ~ 0
AD1
Text Label 8900 2650 0    60   ~ 0
AD2
Text Label 8900 2750 0    60   ~ 0
AD3
Text Label 8900 2850 0    60   ~ 0
AD4
Text Label 8900 2950 0    60   ~ 0
AD5
Text Label 8900 3050 0    60   ~ 0
AD6
Text Label 8900 3150 0    60   ~ 0
AD7
Text Label 2500 1200 1    60   ~ 0
VSS
$Comp
L 74LS139 U1
U 1 1 5A930A3D
P 2300 2300
F 0 "U1" H 2300 2400 50  0000 C CNN
F 1 "74HCT139" H 2300 2200 50  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm_LongPads" H 2300 2300 50  0001 C CNN
F 3 "" H 2300 2300 50  0000 C CNN
	1    2300 2300
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR014
U 1 1 5A93119E
P 1100 2050
F 0 "#PWR014" H 1100 2050 30  0001 C CNN
F 1 "GND" H 1100 1980 30  0001 C CNN
F 2 "" H 1100 2050 60  0000 C CNN
F 3 "" H 1100 2050 60  0000 C CNN
	1    1100 2050
	0    1    1    0   
$EndComp
NoConn ~ 3150 2400
NoConn ~ 3150 2600
$Comp
L YMF262 U8
U 1 1 5B02C1D0
P 5350 6600
F 0 "U8" H 5350 6650 60  0000 C CNN
F 1 "YMF262" H 5350 6550 60  0000 C CNN
F 2 "Housings_SOIC:SOIC-24_7.5x15.4mm_Pitch1.27mm" H 5350 6600 60  0001 C CNN
F 3 "" H 5350 6600 60  0000 C CNN
	1    5350 6600
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U1
U 2 1 5B02D66D
P 2800 7100
F 0 "U1" H 2800 7200 50  0000 C CNN
F 1 "74HCT139" H 2800 7000 50  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm_LongPads" H 2800 7100 50  0001 C CNN
F 3 "" H 2800 7100 50  0000 C CNN
	2    2800 7100
	1    0    0    -1  
$EndComp
NoConn ~ 3350 7200
NoConn ~ 3350 7350
NoConn ~ 4550 7200
Text GLabel 2150 7350 0    60   Input ~ 0
/CS_IO0
Text GLabel 4500 7050 0    60   Input ~ 0
/CS_IO0
Text GLabel 2150 7000 0    60   Input ~ 0
/RW
$Sheet
S 9450 3650 1550 1250
U 5B0355D1
F0 "cxa2075m" 60
F1 "cxa2075m.sch" 60
F2 "RGB_B" I L 9450 3800 60 
F3 "RGB_R" I L 9450 3900 60 
F4 "RGB_G" I L 9450 4000 60 
F5 "CSYNC" I L 9450 4100 60 
$EndSheet
Text Label 9150 3800 0    60   ~ 0
RGB_B
Text Label 9150 3900 0    60   ~ 0
RGB_R
Text Label 9150 4000 0    60   ~ 0
RGB_G
Text Label 9150 4100 0    60   ~ 0
CSYNC
Entry Wire Line
	4300 5800 4400 5700
Entry Wire Line
	4300 5900 4400 5800
Entry Wire Line
	4300 6000 4400 5900
Entry Wire Line
	4300 6100 4400 6000
Entry Wire Line
	4300 6200 4400 6100
Entry Wire Line
	4300 6300 4400 6200
Entry Wire Line
	4300 6400 4400 6300
Entry Wire Line
	4300 6500 4400 6400
Text Label 4000 6450 0    60   ~ 0
D0..D7
Text Label 4450 5700 0    60   ~ 0
D0
Text Label 4450 5800 0    60   ~ 0
D1
Text Label 4450 5900 0    60   ~ 0
D2
Text Label 4450 6000 0    60   ~ 0
D3
Text Label 4450 6100 0    60   ~ 0
D4
Text Label 4450 6200 0    60   ~ 0
D5
Text Label 4450 6300 0    60   ~ 0
D6
Text Label 4450 6400 0    60   ~ 0
D7
Text Label 4450 6550 0    60   ~ 0
A0
Text Label 4450 6650 0    60   ~ 0
A1
$Comp
L OSC X2
U 1 1 5B03C695
P 5350 5200
F 0 "X2" H 5350 5500 70  0000 C CNN
F 1 "OSC" H 5350 5200 70  0000 C CNN
F 2 "Oscillators:KXO-200_LargePads" H 5350 5200 60  0001 C CNN
F 3 "" H 5350 5200 60  0000 C CNN
	1    5350 5200
	1    0    0    -1  
$EndComp
NoConn ~ 6050 5350
$Comp
L VCC #PWR015
U 1 1 5B03DBE3
P 4600 4850
F 0 "#PWR015" H 4600 4950 30  0001 C CNN
F 1 "VCC" H 4600 4950 30  0000 C CNN
F 2 "" H 4600 4850 60  0000 C CNN
F 3 "" H 4600 4850 60  0000 C CNN
	1    4600 4850
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR016
U 1 1 5B03DD31
P 4600 5450
F 0 "#PWR016" H 4600 5450 30  0001 C CNN
F 1 "GND" H 4600 5380 30  0001 C CNN
F 2 "" H 4600 5450 60  0000 C CNN
F 3 "" H 4600 5450 60  0000 C CNN
	1    4600 5450
	1    0    0    -1  
$EndComp
$Sheet
S 9500 5650 1100 700 
U 5B03F723
F0 "yac512" 60
F1 "yac512.sch" 60
F2 "DIN" I L 9500 5800 60 
F3 "CLK" I L 9500 5900 60 
F4 "SMP1" I L 9500 6000 60 
F5 "SMP2" I L 9500 6100 60 
$EndSheet
$Comp
L C C9
U 1 1 5B040F41
P 2800 900
F 0 "C9" H 2825 1000 50  0000 L CNN
F 1 "100n" H 2825 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 2838 750 50  0001 C CNN
F 3 "" H 2800 900 50  0001 C CNN
	1    2800 900 
	1    0    0    -1  
$EndComp
$Comp
L C C10
U 1 1 5B04100B
P 3100 900
F 0 "C10" H 3125 1000 50  0000 L CNN
F 1 "100n" H 3125 800 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 3138 750 50  0001 C CNN
F 3 "" H 3100 900 50  0001 C CNN
	1    3100 900 
	1    0    0    -1  
$EndComp
Text GLabel 4500 7500 0    60   Input ~ 0
/RESET
Text GLabel 6350 7500 2    60   Input ~ 0
/IRQ
Text Label 6150 5800 0    60   ~ 0
CLK
Text Label 9150 5900 0    60   ~ 0
CLK
Text Label 6150 6000 0    60   ~ 0
DOAB
Text Label 9150 5800 0    60   ~ 0
DOAB
Text Label 6150 6100 0    60   ~ 0
SMPAC
Text Label 9150 6100 0    60   ~ 0
SMPAC
Text Label 6150 6200 0    60   ~ 0
SMPBD
Text Label 9150 6000 0    60   ~ 0
SMPBD
NoConn ~ 6150 5900
$Comp
L 7400 U11
U 1 1 5BB118B9
P 1350 6600
F 0 "U11" H 1600 6900 50  0000 C CNN
F 1 "74HCT00" H 1550 6300 50  0000 C CNN
F 2 "Housings_DIP:DIP-14_W7.62mm_Socket_LongPads" H 1350 6600 60  0001 C CNN
F 3 "" H 1350 6600 60  0001 C CNN
	1    1350 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	4550 3850 4700 3850
Wire Wire Line
	4650 3850 4650 3950
Connection ~ 4650 3850
Wire Wire Line
	4550 1200 4650 1200
Wire Wire Line
	5550 600  5550 900 
Wire Wire Line
	5250 900  5250 600 
Wire Wire Line
	5100 600  5300 600 
Wire Wire Line
	5500 600  5700 600 
Connection ~ 5250 600 
Connection ~ 5550 600 
Wire Wire Line
	3650 2700 4650 2700
Wire Wire Line
	4650 2600 3800 2600
Wire Wire Line
	4550 1700 4650 1700
Wire Wire Line
	4550 1600 4650 1600
Wire Wire Line
	10650 1800 10350 1800
Wire Wire Line
	10650 3150 10350 3150
Wire Wire Line
	8450 3150 8200 3150
Wire Wire Line
	8450 1800 8200 1800
Wire Wire Line
	6200 1550 6450 1550
Wire Wire Line
	8450 1700 8200 1700
Wire Wire Line
	8450 3050 8200 3050
Wire Wire Line
	6200 1650 6450 1650
Wire Wire Line
	10650 1700 10350 1700
Wire Wire Line
	10650 3050 10350 3050
Wire Wire Line
	6200 1850 6450 1850
Wire Wire Line
	10650 2850 10350 2850
Wire Wire Line
	10350 1500 10650 1500
Wire Wire Line
	8450 2850 8200 2850
Wire Wire Line
	8200 1500 8450 1500
Wire Wire Line
	8200 1600 8250 1600
Wire Wire Line
	8250 1600 8250 1900
Wire Wire Line
	10350 1600 10450 1600
Wire Wire Line
	10450 1600 10450 1950
Wire Wire Line
	8200 2950 8300 2950
Wire Wire Line
	8300 2950 8300 3250
Wire Wire Line
	10350 2950 10450 2950
Wire Wire Line
	10450 2950 10450 3300
Wire Bus Line
	10700 900  10700 1250
Wire Bus Line
	10700 2250 10700 2600
Wire Bus Line
	6450 1900 6450 2600
Wire Wire Line
	1400 3900 1700 3900
Wire Wire Line
	1700 3800 1400 3800
Wire Wire Line
	4400 2350 4650 2350
Wire Wire Line
	4650 2450 4400 2450
Wire Bus Line
	4400 2850 4400 3550
Wire Wire Line
	4300 1800 4650 1800
Wire Wire Line
	3600 1800 3700 1800
Wire Wire Line
	6200 1450 6450 1450
Wire Wire Line
	10350 1050 10600 1050
Wire Wire Line
	10350 1150 10600 1150
Wire Wire Line
	10600 1250 10350 1250
Wire Wire Line
	10350 1350 10600 1350
Wire Wire Line
	6200 2000 6350 2000
Wire Wire Line
	6200 2100 6350 2100
Wire Wire Line
	6200 2200 6350 2200
Wire Wire Line
	6200 2300 6350 2300
Wire Wire Line
	6200 2400 6350 2400
Wire Wire Line
	6200 2500 6350 2500
Wire Wire Line
	6200 2600 6350 2600
Wire Wire Line
	6350 2700 6200 2700
Wire Bus Line
	8550 900  8550 1250
Wire Wire Line
	8200 1050 8450 1050
Wire Wire Line
	8200 1150 8450 1150
Wire Wire Line
	8450 1250 8200 1250
Wire Wire Line
	8200 1350 8450 1350
Wire Wire Line
	10350 2700 10600 2700
Wire Wire Line
	10350 2600 10600 2600
Wire Wire Line
	10350 2500 10600 2500
Wire Wire Line
	10350 2400 10600 2400
Wire Bus Line
	8550 2250 8550 2600
Wire Wire Line
	8200 2700 8450 2700
Wire Wire Line
	8200 2600 8450 2600
Wire Wire Line
	8200 2500 8450 2500
Wire Wire Line
	8200 2400 8450 2400
Wire Bus Line
	6450 2800 6450 3500
Wire Wire Line
	6350 2900 6200 2900
Wire Wire Line
	6350 3000 6200 3000
Wire Wire Line
	6350 3100 6200 3100
Wire Wire Line
	6350 3200 6200 3200
Wire Wire Line
	6350 3300 6200 3300
Wire Wire Line
	6350 3400 6200 3400
Wire Wire Line
	6350 3500 6200 3500
Wire Wire Line
	6200 3600 6350 3600
Wire Wire Line
	4500 2950 4650 2950
Wire Wire Line
	4500 3050 4650 3050
Wire Wire Line
	4650 3150 4500 3150
Wire Wire Line
	4500 3250 4650 3250
Wire Wire Line
	4500 3350 4650 3350
Wire Wire Line
	4500 3450 4650 3450
Wire Wire Line
	4500 3550 4650 3550
Wire Wire Line
	4500 3650 4650 3650
Wire Bus Line
	1450 4550 1450 5250
Wire Wire Line
	1550 5150 1700 5150
Wire Wire Line
	1550 5050 1700 5050
Wire Wire Line
	1700 4950 1550 4950
Wire Wire Line
	1550 4850 1700 4850
Wire Wire Line
	1550 4750 1700 4750
Wire Wire Line
	1550 4650 1700 4650
Wire Wire Line
	1550 4550 1700 4550
Wire Wire Line
	1550 4450 1700 4450
Wire Wire Line
	6300 1050 6300 1200
Wire Wire Line
	6300 1200 6200 1200
Wire Wire Line
	800  1250 800  1050
Wire Wire Line
	800  1050 3100 1050
Connection ~ 1000 1050
Wire Wire Line
	800  650  800  750 
Wire Wire Line
	800  750  3100 750 
Connection ~ 1000 750 
Connection ~ 1300 750 
Connection ~ 1600 750 
Connection ~ 1900 750 
Connection ~ 2200 750 
Connection ~ 1300 1050
Connection ~ 1600 1050
Connection ~ 1900 1050
Connection ~ 2200 1050
Wire Wire Line
	4550 2000 4650 2000
Wire Wire Line
	4550 2100 4650 2100
Wire Bus Line
	6650 1000 6650 1700
Wire Wire Line
	6750 1100 6900 1100
Wire Wire Line
	6750 1200 6900 1200
Wire Wire Line
	6750 1300 6900 1300
Wire Wire Line
	6750 1400 6900 1400
Wire Wire Line
	6750 1500 6900 1500
Wire Wire Line
	6750 1600 6900 1600
Wire Wire Line
	6750 1700 6900 1700
Wire Wire Line
	6900 1800 6750 1800
Wire Bus Line
	6650 2350 6650 3050
Wire Wire Line
	6750 2450 6900 2450
Wire Wire Line
	6750 2550 6900 2550
Wire Wire Line
	6750 2650 6900 2650
Wire Wire Line
	6750 2750 6900 2750
Wire Wire Line
	6750 2850 6900 2850
Wire Wire Line
	6750 2950 6900 2950
Wire Wire Line
	6750 3050 6900 3050
Wire Wire Line
	6900 3150 6750 3150
Wire Bus Line
	8800 1000 8800 1700
Wire Wire Line
	8900 1100 9050 1100
Wire Wire Line
	8900 1200 9050 1200
Wire Wire Line
	8900 1300 9050 1300
Wire Wire Line
	8900 1400 9050 1400
Wire Wire Line
	8900 1500 9050 1500
Wire Wire Line
	8900 1600 9050 1600
Wire Wire Line
	8900 1700 9050 1700
Wire Wire Line
	9050 1800 8900 1800
Wire Bus Line
	8800 2350 8800 3050
Wire Wire Line
	8900 2450 9050 2450
Wire Wire Line
	8900 2550 9050 2550
Wire Wire Line
	8900 2650 9050 2650
Wire Wire Line
	8900 2750 9050 2750
Wire Wire Line
	8900 2850 9050 2850
Wire Wire Line
	8900 2950 9050 2950
Wire Wire Line
	8900 3050 9050 3050
Wire Wire Line
	9050 3150 8900 3150
Wire Wire Line
	2500 1050 2500 1250
Wire Wire Line
	1150 2550 1450 2550
Wire Wire Line
	950  2200 1450 2200
Wire Wire Line
	1100 2050 1450 2050
Wire Wire Line
	3150 2000 3800 2000
Wire Wire Line
	3800 2000 3800 2600
Wire Wire Line
	3150 2200 3650 2200
Wire Wire Line
	3650 2200 3650 2700
Wire Wire Line
	3350 6850 4550 6850
Wire Wire Line
	3350 7000 3500 7000
Wire Wire Line
	3500 7000 3500 6950
Wire Wire Line
	3500 6950 4550 6950
Wire Wire Line
	2150 7350 2250 7350
Wire Wire Line
	4500 7050 4550 7050
Wire Wire Line
	2150 7000 2250 7000
Wire Wire Line
	6200 3750 6500 3750
Wire Wire Line
	6200 3850 6500 3850
Wire Wire Line
	6200 3950 6500 3950
Wire Wire Line
	6200 4050 6500 4050
Wire Wire Line
	9150 3800 9450 3800
Wire Wire Line
	9150 3900 9450 3900
Wire Wire Line
	9150 4000 9450 4000
Wire Wire Line
	9150 4100 9450 4100
Wire Bus Line
	4300 5800 4300 6500
Wire Wire Line
	4400 6400 4550 6400
Wire Wire Line
	4400 6300 4550 6300
Wire Wire Line
	4550 6200 4400 6200
Wire Wire Line
	4400 6100 4550 6100
Wire Wire Line
	4400 6000 4550 6000
Wire Wire Line
	4400 5900 4550 5900
Wire Wire Line
	4400 5800 4550 5800
Wire Wire Line
	4400 5700 4550 5700
Wire Wire Line
	4550 6550 4300 6550
Wire Wire Line
	4550 6650 4300 6650
Wire Wire Line
	6050 5050 6300 5050
Wire Wire Line
	6300 5050 6300 5700
Wire Wire Line
	6300 5700 6150 5700
Wire Wire Line
	4600 5450 4600 5350
Wire Wire Line
	4600 5350 4650 5350
Wire Wire Line
	4600 4850 4600 5050
Wire Wire Line
	4600 5050 4650 5050
Connection ~ 2500 750 
Connection ~ 2800 750 
Connection ~ 2500 1050
Wire Wire Line
	3100 1050 3100 1100
Connection ~ 2800 1050
Wire Wire Line
	4500 7500 4550 7500
Wire Wire Line
	6150 7500 6350 7500
Wire Wire Line
	6150 5800 6350 5800
Wire Wire Line
	6150 6000 6350 6000
Wire Wire Line
	6150 6100 6350 6100
Wire Wire Line
	6150 6200 6350 6200
Wire Wire Line
	9500 5800 9150 5800
Wire Wire Line
	9500 5900 9150 5900
Wire Wire Line
	9150 6000 9500 6000
Wire Wire Line
	9500 6100 9150 6100
Text GLabel 800  6700 0    60   Input ~ 0
RDY
Text GLabel 800  6500 0    60   Input ~ 0
PHI2
Wire Wire Line
	800  6500 850  6500
Wire Wire Line
	800  6700 850  6700
Wire Wire Line
	1850 6600 2000 6600
Wire Wire Line
	2000 6600 2000 6850
Wire Wire Line
	2000 6850 2250 6850
$EndSCHEMATC
