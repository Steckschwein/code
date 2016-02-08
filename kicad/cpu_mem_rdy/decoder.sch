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
LIBS:gal
LIBS:Lattice
LIBS:65xxx
LIBS:xo-14s
LIBS:osc
LIBS:cpu_mem_rdy-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 3
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
L GAL22V10 U5
U 1 1 544D50CB
P 1850 6050
F 0 "U5" H 1900 6800 60  0000 C CNN
F 1 "GAL22V10" H 1900 5300 60  0000 C CNN
F 2 "Sockets_DIP:DIP-24__300_ELL" H 1850 6050 60  0001 C CNN
F 3 "" H 1850 6050 60  0000 C CNN
	1    1850 6050
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR028
U 1 1 544D50D2
P 1550 6900
F 0 "#PWR028" H 1550 6900 30  0001 C CNN
F 1 "GND" H 1550 6830 30  0001 C CNN
F 2 "" H 1550 6900 60  0000 C CNN
F 3 "" H 1550 6900 60  0000 C CNN
	1    1550 6900
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR029
U 1 1 544D50D8
P 1550 5200
F 0 "#PWR029" H 1550 5300 30  0001 C CNN
F 1 "VCC" H 1550 5300 30  0000 C CNN
F 2 "" H 1550 5200 60  0000 C CNN
F 3 "" H 1550 5200 60  0000 C CNN
	1    1550 5200
	1    0    0    -1  
$EndComp
Entry Wire Line
	950  5300 1050 5400
Entry Wire Line
	950  5400 1050 5500
Entry Wire Line
	950  5500 1050 5600
Entry Wire Line
	950  5600 1050 5700
Entry Wire Line
	950  5700 1050 5800
Entry Wire Line
	950  5800 1050 5900
Entry Wire Line
	950  5900 1050 6000
Entry Wire Line
	950  6000 1050 6100
Text Label 1050 5400 0    60   ~ 0
A15
Text Label 1050 5500 0    60   ~ 0
A14
Text Label 1050 5600 0    60   ~ 0
A13
Text Label 1050 5700 0    60   ~ 0
A12
Text Label 950  5200 0    60   ~ 0
A
Entry Wire Line
	950  6100 1050 6200
Entry Wire Line
	950  6200 1050 6300
Entry Wire Line
	950  6300 1050 6400
Entry Wire Line
	950  6400 1050 6500
Text Label 1050 5800 0    60   ~ 0
A11
Text Label 1050 5900 0    60   ~ 0
A10
Text Label 1050 6000 0    60   ~ 0
A9
Text Label 1050 6100 0    60   ~ 0
A8
Text Label 1050 6200 0    60   ~ 0
A7
Text Label 1050 6300 0    60   ~ 0
A6
Text Label 1050 6400 0    60   ~ 0
A5
Text Label 1050 6500 0    60   ~ 0
A4
Entry Wire Line
	6100 4600 6200 4700
Entry Wire Line
	6100 4700 6200 4800
Entry Wire Line
	6100 4800 6200 4900
Entry Wire Line
	6100 4900 6200 5000
Entry Wire Line
	6100 5000 6200 5100
Entry Wire Line
	6100 5100 6200 5200
Entry Wire Line
	6100 5200 6200 5300
Entry Wire Line
	6100 5300 6200 5400
Text Label 6050 4550 0    60   ~ 0
D
Text Label 6200 4700 0    60   ~ 0
D0
Text Label 6200 4800 0    60   ~ 0
D1
Text Label 6200 4900 0    60   ~ 0
D2
Text Label 6200 5000 0    60   ~ 0
D3
Text Label 6200 5100 0    60   ~ 0
D4
Text Label 6200 5200 0    60   ~ 0
D5
Text Label 6200 5300 0    60   ~ 0
D6
Text Label 6200 5400 0    60   ~ 0
D7
Text HLabel 850  2500 2    60   Input ~ 0
A4
Entry Wire Line
	650  2400 750  2500
Text Label 650  1200 0    60   ~ 0
A[0..15]
Entry Wire Line
	1600 1050 1700 1150
Entry Wire Line
	1600 1250 1700 1350
Entry Wire Line
	1600 1450 1700 1550
Entry Wire Line
	1600 1650 1700 1750
Text Label 1700 1150 0    60   ~ 0
D7
Text Label 1700 1350 0    60   ~ 0
D5
Text Label 1700 1550 0    60   ~ 0
D3
Text Label 1700 1750 0    60   ~ 0
D1
Text Label 1600 950  0    60   ~ 0
D[0..7]
Entry Wire Line
	1700 1250 1600 1150
Entry Wire Line
	1700 1450 1600 1350
Entry Wire Line
	1700 1650 1600 1550
Entry Wire Line
	1700 1850 1600 1750
Text Label 1800 1250 2    60   ~ 0
D6
Text Label 1800 1450 2    60   ~ 0
D4
Text Label 1800 1650 2    60   ~ 0
D2
Text Label 1800 1850 2    60   ~ 0
D0
Text HLabel 1850 1850 2    60   BiDi ~ 0
D0
Text HLabel 1850 1750 2    60   BiDi ~ 0
D1
Text HLabel 1850 1650 2    60   BiDi ~ 0
D2
Text HLabel 1850 1550 2    60   BiDi ~ 0
D3
Text HLabel 1850 1450 2    60   BiDi ~ 0
D4
Text HLabel 1850 1350 2    60   BiDi ~ 0
D5
Text HLabel 1850 1250 2    60   BiDi ~ 0
D6
Text HLabel 1850 1150 2    60   BiDi ~ 0
D7
Text Label 750  2500 0    60   ~ 0
A4
Entry Wire Line
	650  2300 750  2400
Text HLabel 850  2400 2    60   Input ~ 0
A5
Text Label 750  2400 0    60   ~ 0
A5
Entry Wire Line
	650  2200 750  2300
Entry Wire Line
	650  2100 750  2200
Entry Wire Line
	650  2000 750  2100
Entry Wire Line
	650  1900 750  2000
Entry Wire Line
	650  1800 750  1900
Entry Wire Line
	650  1700 750  1800
Entry Wire Line
	650  1600 750  1700
Entry Wire Line
	650  1500 750  1600
Entry Wire Line
	650  1400 750  1500
Entry Wire Line
	650  1300 750  1400
Text Label 750  2300 0    60   ~ 0
A6
Text Label 750  2200 0    60   ~ 0
A7
Text Label 750  2100 0    60   ~ 0
A8
Text Label 750  2000 0    60   ~ 0
A9
Text Label 750  1900 0    60   ~ 0
A10
Text Label 750  1800 0    60   ~ 0
A11
Text Label 750  1700 0    60   ~ 0
A12
Text Label 750  1600 0    60   ~ 0
A13
Text Label 750  1500 0    60   ~ 0
A14
Text Label 750  1400 0    60   ~ 0
A15
Text HLabel 850  2300 2    60   Input ~ 0
A6
Text HLabel 850  2200 2    60   Input ~ 0
A7
Text HLabel 850  2100 2    60   Input ~ 0
A8
Text HLabel 850  2000 2    60   Input ~ 0
A9
Text HLabel 850  1900 2    60   Input ~ 0
A10
Text HLabel 850  1800 2    60   Input ~ 0
A11
Text HLabel 850  1700 2    60   Input ~ 0
A12
Text HLabel 850  1600 2    60   Input ~ 0
A13
Text HLabel 850  1500 2    60   Input ~ 0
A14
Text HLabel 850  1400 2    60   Input ~ 0
A15
$Comp
L VCC #PWR030
U 1 1 544D6887
P 950 5350
F 0 "#PWR030" H 950 5450 30  0001 C CNN
F 1 "VCC" H 950 5450 30  0000 C CNN
F 2 "" H 950 5350 60  0000 C CNN
F 3 "" H 950 5350 60  0000 C CNN
	1    950  5350
	1    0    0    -1  
$EndComp
$Comp
L 74LS139 U9
U 1 1 544D688D
P 1700 4350
F 0 "U9" H 1700 4450 60  0000 C CNN
F 1 "74LS139" H 1700 4250 60  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm_LongPads" H 1700 4350 60  0001 C CNN
F 3 "" H 1700 4350 60  0000 C CNN
	1    1700 4350
	1    0    0    -1  
$EndComp
Entry Wire Line
	700  4000 800  4100
Entry Wire Line
	700  4150 800  4250
Text Label 800  4100 0    60   ~ 0
A5
Text Label 800  4250 0    60   ~ 0
A4
$Comp
L VCC #PWR031
U 1 1 544D68A5
P 1250 3850
F 0 "#PWR031" H 1250 3950 30  0001 C CNN
F 1 "VCC" H 1250 3950 30  0000 C CNN
F 2 "" H 1250 3850 60  0000 C CNN
F 3 "" H 1250 3850 60  0000 C CNN
	1    1250 3850
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR032
U 1 1 544D68AB
P 1250 4850
F 0 "#PWR032" H 1250 4850 30  0001 C CNN
F 1 "GND" H 1250 4780 30  0001 C CNN
F 2 "" H 1250 4850 60  0000 C CNN
F 3 "" H 1250 4850 60  0000 C CNN
	1    1250 4850
	1    0    0    -1  
$EndComp
Text Label 700  3900 0    60   ~ 0
A
Text HLabel 3300 6100 2    60   Output ~ 0
/CS_ROM
Text HLabel 3300 6000 2    60   Output ~ 0
/CS_LORAM
Text HLabel 3300 5900 2    60   Output ~ 0
/CS_HIRAM
Text HLabel 4100 6300 2    60   Input ~ 0
RW
Text HLabel 3300 5800 2    60   Output ~ 0
/CS_UART
Text HLabel 3300 5700 2    60   Output ~ 0
/CS_VIA
Text HLabel 3300 5600 2    60   Output ~ 0
/CS_VDP
Text HLabel 3250 4050 2    60   Output ~ 0
/CS_IO0
Text HLabel 3250 4250 2    60   Output ~ 0
/CS_IO1
Text HLabel 3250 4450 2    60   Output ~ 0
/CS_IO2
Text HLabel 3250 4650 2    60   Output ~ 0
/CS_IO3
$Comp
L VCC #PWR033
U 1 1 544D6F18
P 6750 4500
F 0 "#PWR033" H 6750 4600 30  0001 C CNN
F 1 "VCC" H 6750 4600 30  0000 C CNN
F 2 "" H 6750 4500 60  0000 C CNN
F 3 "" H 6750 4500 60  0000 C CNN
	1    6750 4500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR034
U 1 1 544D700F
P 6750 5950
F 0 "#PWR034" H 6750 5950 30  0001 C CNN
F 1 "GND" H 6750 5880 30  0001 C CNN
F 2 "" H 6750 5950 60  0000 C CNN
F 3 "" H 6750 5950 60  0000 C CNN
	1    6750 5950
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR035
U 1 1 544E9402
P 5800 6600
F 0 "#PWR035" H 5800 6700 30  0001 C CNN
F 1 "VCC" H 5800 6700 30  0000 C CNN
F 2 "" H 5800 6600 60  0000 C CNN
F 3 "" H 5800 6600 60  0000 C CNN
	1    5800 6600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR036
U 1 1 544E9408
P 5800 7150
F 0 "#PWR036" H 5800 7150 30  0001 C CNN
F 1 "GND" H 5800 7080 30  0001 C CNN
F 2 "" H 5800 7150 60  0000 C CNN
F 3 "" H 5800 7150 60  0000 C CNN
	1    5800 7150
	1    0    0    -1  
$EndComp
$Comp
L C C11
U 1 1 544E940E
P 5800 6850
F 0 "C11" H 5800 6950 40  0000 L CNN
F 1 "100n" H 5806 6765 40  0000 L CNN
F 2 "Discret:C1" H 5838 6700 30  0001 C CNN
F 3 "" H 5800 6850 60  0000 C CNN
	1    5800 6850
	1    0    0    -1  
$EndComp
$Comp
L C C12
U 1 1 544E9415
P 6050 6850
F 0 "C12" H 6050 6950 40  0000 L CNN
F 1 "100n" H 6056 6765 40  0000 L CNN
F 2 "Discret:C1" H 6088 6700 30  0001 C CNN
F 3 "" H 6050 6850 60  0000 C CNN
	1    6050 6850
	1    0    0    -1  
$EndComp
$Comp
L C C13
U 1 1 544E941C
P 6300 6850
F 0 "C13" H 6300 6950 40  0000 L CNN
F 1 "100n" H 6306 6765 40  0000 L CNN
F 2 "Discret:C1" H 6338 6700 30  0001 C CNN
F 3 "" H 6300 6850 60  0000 C CNN
	1    6300 6850
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X08 P2
U 1 1 544E9377
P 8200 1950
F 0 "P2" H 8200 2400 50  0000 C CNN
F 1 "CONN_01X08" V 8300 1950 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x08" H 8200 1950 60  0001 C CNN
F 3 "" H 8200 1950 60  0000 C CNN
	1    8200 1950
	0    -1   -1   0   
$EndComp
Text HLabel 7950 5550 3    60   Output ~ 0
BANK1
Text HLabel 8050 5550 3    60   Output ~ 0
BANK2
Entry Wire Line
	10350 4600 10250 4700
Entry Wire Line
	10350 4700 10250 4800
Entry Wire Line
	10350 4800 10250 4900
Entry Wire Line
	10350 4900 10250 5000
Entry Wire Line
	10350 5000 10250 5100
Entry Wire Line
	10350 5100 10250 5200
Entry Wire Line
	10350 5200 10250 5300
Entry Wire Line
	10350 5300 10250 5400
Text Label 10400 4550 2    60   ~ 0
D
Text Label 10250 4700 2    60   ~ 0
D0
Text Label 10250 4800 2    60   ~ 0
D1
Text Label 10250 4900 2    60   ~ 0
D2
Text Label 10250 5000 2    60   ~ 0
D3
Text Label 10250 5100 2    60   ~ 0
D4
Text Label 10250 5200 2    60   ~ 0
D5
Text Label 10250 5300 2    60   ~ 0
D6
Text Label 10250 5400 2    60   ~ 0
D7
Text Label 7900 4700 0    60   ~ 0
/ROMOFF
Text Label 3350 6200 0    60   ~ 0
/ROMOFF
$Comp
L 74LS139 U9
U 2 1 548A0B1E
P 5050 5500
F 0 "U9" H 5050 5600 60  0000 C CNN
F 1 "74LS139" H 5050 5400 60  0000 C CNN
F 2 "Housings_DIP:DIP-16_W7.62mm_LongPads" H 5050 5500 60  0001 C CNN
F 3 "" H 5050 5500 60  0000 C CNN
	2    5050 5500
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR037
U 1 1 548A1DBF
P 9450 4500
F 0 "#PWR037" H 9450 4600 30  0001 C CNN
F 1 "VCC" H 9450 4600 30  0000 C CNN
F 2 "" H 9450 4500 60  0000 C CNN
F 3 "" H 9450 4500 60  0000 C CNN
	1    9450 4500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR038
U 1 1 548A1EB2
P 9450 5950
F 0 "#PWR038" H 9450 5950 30  0001 C CNN
F 1 "GND" H 9450 5880 30  0001 C CNN
F 2 "" H 9450 5950 60  0000 C CNN
F 3 "" H 9450 5950 60  0000 C CNN
	1    9450 5950
	1    0    0    -1  
$EndComp
$Comp
L 74LS273 U11
U 1 1 544D56DD
P 7050 5200
F 0 "U11" H 7050 5050 60  0000 C CNN
F 1 "74LS273" H 7050 4850 60  0000 C CNN
F 2 "Sockets_DIP:DIP-20__300_ELL" H 7050 5200 60  0001 C CNN
F 3 "" H 7050 5200 60  0000 C CNN
	1    7050 5200
	1    0    0    -1  
$EndComp
$Comp
L 74LS244 U12
U 1 1 54AD6087
P 9450 5200
F 0 "U12" H 9500 5000 60  0000 C CNN
F 1 "74LS244" H 9550 4800 60  0000 C CNN
F 2 "Sockets_DIP:DIP-20__300_ELL" H 9450 5200 60  0001 C CNN
F 3 "" H 9450 5200 60  0000 C CNN
	1    9450 5200
	1    0    0    -1  
$EndComp
Text GLabel 4100 5250 0    60   Input ~ 0
PHI2
NoConn ~ 5900 5400
Text HLabel 6200 5700 0    60   Input ~ 0
/RESET
$Comp
L LED D7
U 1 1 54C39194
P 9600 3050
F 0 "D7" H 9600 3150 50  0000 C CNN
F 1 "LED" H 9600 2950 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 3050 60  0001 C CNN
F 3 "" H 9600 3050 60  0000 C CNN
	1    9600 3050
	1    0    0    -1  
$EndComp
$Comp
L LED D6
U 1 1 54C391D7
P 9600 2800
F 0 "D6" H 9600 2900 50  0000 C CNN
F 1 "LED" H 9600 2700 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 2800 60  0001 C CNN
F 3 "" H 9600 2800 60  0000 C CNN
	1    9600 2800
	1    0    0    -1  
$EndComp
$Comp
L LED D4
U 1 1 54C39200
P 9600 2300
F 0 "D4" H 9600 2400 50  0000 C CNN
F 1 "LED" H 9600 2200 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 2300 60  0001 C CNN
F 3 "" H 9600 2300 60  0000 C CNN
	1    9600 2300
	1    0    0    -1  
$EndComp
$Comp
L LED D5
U 1 1 54C3922E
P 9600 2550
F 0 "D5" H 9600 2650 50  0000 C CNN
F 1 "LED" H 9600 2450 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 2550 60  0001 C CNN
F 3 "" H 9600 2550 60  0000 C CNN
	1    9600 2550
	1    0    0    -1  
$EndComp
$Comp
L LED D11
U 1 1 54C39263
P 9600 4050
F 0 "D11" H 9600 4150 50  0000 C CNN
F 1 "LED" H 9600 3950 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 4050 60  0001 C CNN
F 3 "" H 9600 4050 60  0000 C CNN
	1    9600 4050
	1    0    0    -1  
$EndComp
$Comp
L LED D10
U 1 1 54C39293
P 9600 3800
F 0 "D10" H 9600 3900 50  0000 C CNN
F 1 "LED" H 9600 3700 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 3800 60  0001 C CNN
F 3 "" H 9600 3800 60  0000 C CNN
	1    9600 3800
	1    0    0    -1  
$EndComp
$Comp
L LED D8
U 1 1 54C392CE
P 9600 3300
F 0 "D8" H 9600 3400 50  0000 C CNN
F 1 "LED" H 9600 3200 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 3300 60  0001 C CNN
F 3 "" H 9600 3300 60  0000 C CNN
	1    9600 3300
	1    0    0    -1  
$EndComp
$Comp
L LED D9
U 1 1 54C39306
P 9600 3550
F 0 "D9" H 9600 3650 50  0000 C CNN
F 1 "LED" H 9600 3450 50  0000 C CNN
F 2 "LEDs:LED-3MM" H 9600 3550 60  0001 C CNN
F 3 "" H 9600 3550 60  0000 C CNN
	1    9600 3550
	1    0    0    -1  
$EndComp
$Comp
L R R11
U 1 1 54C39330
P 9050 2550
F 0 "R11" V 9130 2550 40  0000 C CNN
F 1 "270" V 9057 2551 40  0000 C CNN
F 2 "Discret:R3" V 8980 2550 30  0001 C CNN
F 3 "" H 9050 2550 30  0000 C CNN
	1    9050 2550
	0    1    1    0   
$EndComp
$Comp
L R R13
U 1 1 54C393FC
P 9050 3050
F 0 "R13" V 9130 3050 40  0000 C CNN
F 1 "270" V 9057 3051 40  0000 C CNN
F 2 "Discret:R3" V 8980 3050 30  0001 C CNN
F 3 "" H 9050 3050 30  0000 C CNN
	1    9050 3050
	0    1    1    0   
$EndComp
$Comp
L R R16
U 1 1 54C39453
P 9050 3800
F 0 "R16" V 9130 3800 40  0000 C CNN
F 1 "270" V 9057 3801 40  0000 C CNN
F 2 "Discret:R3" V 8980 3800 30  0001 C CNN
F 3 "" H 9050 3800 30  0000 C CNN
	1    9050 3800
	0    1    1    0   
$EndComp
$Comp
L R R12
U 1 1 54C39489
P 9050 2800
F 0 "R12" V 9130 2800 40  0000 C CNN
F 1 "270" V 9057 2801 40  0000 C CNN
F 2 "Discret:R3" V 8980 2800 30  0001 C CNN
F 3 "" H 9050 2800 30  0000 C CNN
	1    9050 2800
	0    1    1    0   
$EndComp
$Comp
L R R14
U 1 1 54C394D1
P 9050 3300
F 0 "R14" V 9130 3300 40  0000 C CNN
F 1 "270" V 9057 3301 40  0000 C CNN
F 2 "Discret:R3" V 8980 3300 30  0001 C CNN
F 3 "" H 9050 3300 30  0000 C CNN
	1    9050 3300
	0    1    1    0   
$EndComp
$Comp
L R R15
U 1 1 54C3950D
P 9050 3550
F 0 "R15" V 9130 3550 40  0000 C CNN
F 1 "270" V 9057 3551 40  0000 C CNN
F 2 "Discret:R3" V 8980 3550 30  0001 C CNN
F 3 "" H 9050 3550 30  0000 C CNN
	1    9050 3550
	0    1    1    0   
$EndComp
$Comp
L R R17
U 1 1 54C39576
P 9050 4050
F 0 "R17" V 9130 4050 40  0000 C CNN
F 1 "270" V 9057 4051 40  0000 C CNN
F 2 "Discret:R3" V 8980 4050 30  0001 C CNN
F 3 "" H 9050 4050 30  0000 C CNN
	1    9050 4050
	0    1    1    0   
$EndComp
$Comp
L R R10
U 1 1 54C395B4
P 9050 2300
F 0 "R10" V 9130 2300 40  0000 C CNN
F 1 "270" V 9057 2301 40  0000 C CNN
F 2 "Discret:R3" V 8980 2300 30  0001 C CNN
F 3 "" H 9050 2300 30  0000 C CNN
	1    9050 2300
	0    1    1    0   
$EndComp
$Comp
L GND #PWR039
U 1 1 54C3A7FA
P 9900 4200
F 0 "#PWR039" H 9900 4200 30  0001 C CNN
F 1 "GND" H 9900 4130 30  0001 C CNN
F 2 "" H 9900 4200 60  0000 C CNN
F 3 "" H 9900 4200 60  0000 C CNN
	1    9900 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1550 6750 1550 6900
Wire Wire Line
	1550 5200 1550 5350
Wire Bus Line
	950  5200 950  6400
Wire Wire Line
	1050 5400 1150 5400
Wire Wire Line
	1050 5500 1150 5500
Wire Wire Line
	1050 5600 1150 5600
Wire Wire Line
	1050 5700 1150 5700
Wire Wire Line
	1050 5800 1150 5800
Wire Wire Line
	1050 5900 1150 5900
Wire Wire Line
	1050 6000 1150 6000
Wire Wire Line
	1050 6100 1150 6100
Wire Wire Line
	1150 6200 1050 6200
Wire Wire Line
	1150 6300 1050 6300
Wire Wire Line
	1050 6400 1150 6400
Wire Wire Line
	1050 6500 1150 6500
Wire Wire Line
	2550 6300 4100 6300
Wire Wire Line
	7850 6200 2550 6200
Wire Wire Line
	2550 6100 3300 6100
Wire Wire Line
	2550 6000 3300 6000
Wire Wire Line
	2550 5900 3300 5900
Wire Wire Line
	2550 5800 3300 5800
Wire Wire Line
	2550 5700 3300 5700
Wire Wire Line
	2550 5600 3300 5600
Wire Bus Line
	6100 4550 6100 5300
Wire Wire Line
	6200 4700 6350 4700
Wire Wire Line
	6200 4800 6350 4800
Wire Wire Line
	6200 4900 6350 4900
Wire Wire Line
	6200 5000 6350 5000
Wire Wire Line
	6200 5100 6350 5100
Wire Wire Line
	6200 5200 6350 5200
Wire Wire Line
	6200 5300 6350 5300
Wire Wire Line
	6200 5400 6350 5400
Wire Wire Line
	7750 4700 8750 4700
Wire Wire Line
	750  2500 850  2500
Wire Bus Line
	1600 950  1600 1750
Wire Wire Line
	1700 1150 1850 1150
Wire Wire Line
	1700 1350 1850 1350
Wire Wire Line
	1700 1550 1850 1550
Wire Wire Line
	1700 1750 1850 1750
Wire Wire Line
	1850 1250 1700 1250
Wire Wire Line
	1850 1450 1700 1450
Wire Wire Line
	1850 1650 1700 1650
Wire Wire Line
	1850 1850 1700 1850
Wire Wire Line
	750  2400 850  2400
Wire Wire Line
	750  1400 850  1400
Wire Wire Line
	750  1500 850  1500
Wire Wire Line
	750  1600 850  1600
Wire Wire Line
	750  1700 850  1700
Wire Wire Line
	750  1800 850  1800
Wire Wire Line
	750  1900 850  1900
Wire Wire Line
	750  2000 850  2000
Wire Wire Line
	750  2100 850  2100
Wire Wire Line
	750  2200 850  2200
Wire Wire Line
	750  2300 850  2300
Wire Bus Line
	700  3900 700  4200
Wire Wire Line
	800  4100 850  4100
Wire Wire Line
	800  4250 850  4250
Wire Wire Line
	2550 4250 3250 4250
Wire Wire Line
	2550 4450 3250 4450
Wire Wire Line
	2550 4650 3250 4650
Wire Wire Line
	1250 3850 1250 3950
Wire Wire Line
	1250 4750 1250 4850
Wire Wire Line
	850  4600 750  4600
Wire Wire Line
	750  4600 750  5050
Wire Wire Line
	750  5050 2700 5050
Wire Wire Line
	2700 5050 2700 5400
Wire Wire Line
	2700 5400 2550 5400
Wire Wire Line
	6750 5750 6750 5950
Wire Wire Line
	5800 7050 5800 7150
Wire Wire Line
	5800 6650 6800 6650
Wire Wire Line
	5800 7050 6800 7050
Connection ~ 6050 6650
Connection ~ 6300 6650
Connection ~ 6300 7050
Connection ~ 6050 7050
Wire Wire Line
	7750 4800 8750 4800
Wire Wire Line
	7750 4900 8750 4900
Wire Wire Line
	7750 5000 8750 5000
Wire Wire Line
	7750 5100 8750 5100
Wire Wire Line
	7750 5200 8750 5200
Wire Wire Line
	7750 5300 8750 5300
Wire Wire Line
	7750 5400 8750 5400
Wire Wire Line
	7950 2150 7950 5550
Connection ~ 7950 4800
Wire Wire Line
	8050 2150 8050 5550
Connection ~ 8050 4900
Wire Bus Line
	10350 4550 10350 5300
Wire Wire Line
	10250 4700 10150 4700
Wire Wire Line
	10250 4800 10150 4800
Wire Wire Line
	10250 4900 10150 4900
Wire Wire Line
	10250 5000 10150 5000
Wire Wire Line
	10250 5100 10150 5100
Wire Wire Line
	10250 5200 10150 5200
Wire Wire Line
	10250 5300 10150 5300
Wire Wire Line
	10250 5400 10150 5400
Wire Wire Line
	3900 5500 3900 5750
Wire Wire Line
	2550 5500 3900 5500
Wire Wire Line
	7850 2150 7850 6200
Connection ~ 7850 4700
Wire Wire Line
	7950 4800 7900 4800
Wire Wire Line
	8150 2150 8150 5000
Connection ~ 8150 5000
Wire Wire Line
	8250 2150 8250 5100
Connection ~ 8250 5100
Wire Wire Line
	8350 2150 8350 5200
Connection ~ 8350 5200
Wire Wire Line
	8450 2150 8450 5300
Connection ~ 8450 5300
Wire Wire Line
	8550 2150 8550 5400
Connection ~ 8550 5400
Wire Wire Line
	3900 5750 4200 5750
Wire Wire Line
	4200 5250 4100 5250
Wire Wire Line
	9450 4500 9450 4650
Wire Wire Line
	9450 5750 9450 5950
Wire Wire Line
	4200 5400 4050 5400
Wire Wire Line
	4050 5400 4050 6300
Connection ~ 4050 6300
Wire Wire Line
	6200 5800 6200 6050
Wire Wire Line
	8650 6050 6200 6050
Wire Wire Line
	8750 5600 8650 5600
Wire Wire Line
	8650 5600 8650 6050
Wire Wire Line
	8750 5700 8650 5700
Connection ~ 8650 5700
Wire Wire Line
	6200 5800 5900 5800
Wire Wire Line
	5900 5600 6350 5600
Wire Wire Line
	6200 5700 6350 5700
Wire Wire Line
	5800 6650 5800 6600
Wire Wire Line
	6750 4500 6750 4650
Wire Wire Line
	9800 2300 9900 2300
Wire Wire Line
	9300 2550 9400 2550
Wire Wire Line
	9300 2800 9400 2800
Wire Wire Line
	9300 3050 9400 3050
Wire Wire Line
	9300 3300 9400 3300
Wire Wire Line
	9300 3550 9400 3550
Wire Wire Line
	9300 3800 9400 3800
Wire Wire Line
	9300 4050 9400 4050
Wire Wire Line
	9900 2300 9900 4200
Connection ~ 9900 2550
Connection ~ 9900 2800
Connection ~ 9900 3050
Connection ~ 9900 3300
Connection ~ 9900 3550
Connection ~ 9900 3800
Connection ~ 9900 4050
Connection ~ 7850 2300
Wire Wire Line
	8800 2550 7950 2550
Connection ~ 7950 2550
Wire Wire Line
	8800 2800 8050 2800
Connection ~ 8050 2800
Wire Wire Line
	8800 3050 8150 3050
Connection ~ 8150 3050
Wire Wire Line
	8800 3300 8250 3300
Connection ~ 8250 3300
Wire Wire Line
	8800 3550 8350 3550
Connection ~ 8350 3550
Wire Wire Line
	8800 3800 8450 3800
Connection ~ 8450 3800
Wire Wire Line
	8800 4050 8550 4050
Connection ~ 8550 4050
Wire Wire Line
	8800 2300 7850 2300
Wire Wire Line
	9300 2300 9400 2300
Wire Wire Line
	9800 2550 9900 2550
Wire Wire Line
	9800 2800 9900 2800
Wire Wire Line
	9800 3050 9900 3050
Wire Wire Line
	9800 3300 9900 3300
Wire Wire Line
	9800 3550 9900 3550
Wire Wire Line
	9800 3800 9900 3800
Wire Wire Line
	9800 4050 9900 4050
NoConn ~ 5900 5200
$Comp
L GAL16V8 U14
U 1 1 56AA876B
P 4400 7100
F 0 "U14" H 4050 7750 50  0000 L CNN
F 1 "GAL16V8" H 4450 7750 50  0000 L CNN
F 2 "Housings_DIP:DIP-20_W7.62mm_LongPads" H 4400 7100 50  0001 C CNN
F 3 "" H 4400 7100 50  0000 C CNN
	1    4400 7100
	1    0    0    -1  
$EndComp
Text GLabel 3600 6600 0    60   Input ~ 0
PHI2
Wire Wire Line
	3600 6600 3900 6600
Wire Wire Line
	2700 6800 2700 5800
Connection ~ 2700 5800
Wire Wire Line
	2800 6700 2800 5600
Connection ~ 2800 5600
Wire Wire Line
	2550 4050 3250 4050
Wire Wire Line
	3200 7000 3200 4050
Connection ~ 3200 4050
Wire Wire Line
	2700 7400 3900 7400
Wire Wire Line
	2700 7500 3900 7500
Text HLabel 5100 7300 2    60   3State ~ 0
RDY
Wire Wire Line
	4900 7300 5100 7300
$Comp
L C C14
U 1 1 56AAB09B
P 6550 6850
F 0 "C14" H 6550 6950 40  0000 L CNN
F 1 "100n" H 6556 6765 40  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Rect_L4_W2.5_P2.5" H 6588 6700 30  0001 C CNN
F 3 "" H 6550 6850 60  0000 C CNN
	1    6550 6850
	1    0    0    -1  
$EndComp
Wire Wire Line
	2800 6700 3900 6700
Wire Wire Line
	2600 6900 2600 6100
Connection ~ 2600 6100
Connection ~ 6550 6650
Connection ~ 6550 7050
Wire Bus Line
	650  1200 650  2400
Wire Wire Line
	3100 7100 3100 4250
Connection ~ 3100 4250
Wire Wire Line
	3000 7200 3000 4450
Connection ~ 3000 4450
$Comp
L VCC #PWR040
U 1 1 56B9A31D
P 2700 7300
F 0 "#PWR040" H 2700 7400 30  0001 C CNN
F 1 "VCC" H 2700 7400 30  0000 C CNN
F 2 "" H 2700 7300 60  0000 C CNN
F 3 "" H 2700 7300 60  0000 C CNN
	1    2700 7300
	1    0    0    -1  
$EndComp
Wire Wire Line
	2700 7300 2700 7500
Connection ~ 2700 7400
Connection ~ 4600 4950
Wire Wire Line
	2700 6800 3900 6800
Wire Wire Line
	3900 6900 2600 6900
Wire Wire Line
	3200 7000 3900 7000
Wire Wire Line
	3100 7100 3900 7100
Wire Wire Line
	3000 7200 3900 7200
Wire Wire Line
	3900 7300 2900 7300
Wire Wire Line
	2900 7300 2900 4650
Connection ~ 2900 4650
NoConn ~ 4900 7200
NoConn ~ 4900 7100
NoConn ~ 4900 7000
NoConn ~ 4900 6900
NoConn ~ 4900 6800
NoConn ~ 4900 6700
NoConn ~ 4900 6600
$EndSCHEMATC
