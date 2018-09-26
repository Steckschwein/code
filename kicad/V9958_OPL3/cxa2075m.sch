EESchema Schematic File Version 2
LIBS:tms99xx
LIBS:dram
LIBS:osc
LIBS:mini_din
LIBS:steckschwein
LIBS:yamaha_opl
LIBS:rc4136
LIBS:v9958-cache
EELAYER 25 0
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
L R-RESCUE-v9958 R1
U 1 1 5B035EEB
P 4300 3500
F 0 "R1" V 4380 3500 40  0000 C CNN
F 1 "470" V 4307 3501 40  0000 C CNN
F 2 "Discret:R3" V 4230 3500 30  0001 C CNN
F 3 "" H 4300 3500 30  0000 C CNN
	1    4300 3500
	-1   0    0    1   
$EndComp
$Comp
L R-RESCUE-v9958 R2
U 1 1 5B035EF2
P 4450 3500
F 0 "R2" V 4530 3500 40  0000 C CNN
F 1 "470" V 4457 3501 40  0000 C CNN
F 2 "Discret:R3" V 4380 3500 30  0001 C CNN
F 3 "" H 4450 3500 30  0000 C CNN
	1    4450 3500
	-1   0    0    1   
$EndComp
$Comp
L R-RESCUE-v9958 R3
U 1 1 5B035EF9
P 4600 3500
F 0 "R3" V 4680 3500 40  0000 C CNN
F 1 "470" V 4607 3501 40  0000 C CNN
F 2 "Discret:R3" V 4530 3500 30  0001 C CNN
F 3 "" H 4600 3500 30  0000 C CNN
	1    4600 3500
	-1   0    0    1   
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR025
U 1 1 5B035F00
P 4450 3850
F 0 "#PWR025" H 4450 3850 30  0001 C CNN
F 1 "GND" H 4450 3780 30  0001 C CNN
F 2 "" H 4450 3850 60  0000 C CNN
F 3 "" H 4450 3850 60  0000 C CNN
	1    4450 3850
	1    0    0    -1  
$EndComp
$Comp
L cxa2075M U7
U 1 1 5B035F06
P 6050 4000
F 0 "U7" H 6050 4000 60  0000 C CNN
F 1 "cxa2075M" H 6250 3400 60  0000 C CNN
F 2 "Housings_SOIC:SOIC-24_7.5x15.4mm_Pitch1.27mm" H 6050 3300 60  0001 C CNN
F 3 "" H 6050 3300 60  0000 C CNN
	1    6050 4000
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR026
U 1 1 5B035F0D
P 5300 4300
F 0 "#PWR026" H 5300 4300 30  0001 C CNN
F 1 "GND" H 5300 4230 30  0001 C CNN
F 2 "" H 5300 4300 60  0000 C CNN
F 3 "" H 5300 4300 60  0000 C CNN
	1    5300 4300
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR027
U 1 1 5B035F13
P 7200 3300
F 0 "#PWR027" H 7200 3300 30  0001 C CNN
F 1 "GND" H 7200 3230 30  0001 C CNN
F 2 "" H 7200 3300 60  0000 C CNN
F 3 "" H 7200 3300 60  0000 C CNN
	1    7200 3300
	-1   0    0    1   
$EndComp
$Comp
L VCC #PWR028
U 1 1 5B035F19
P 4900 4600
F 0 "#PWR028" H 4900 4700 30  0001 C CNN
F 1 "VCC" H 4900 4700 30  0000 C CNN
F 2 "" H 4900 4600 60  0000 C CNN
F 3 "" H 4900 4600 60  0000 C CNN
	1    4900 4600
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR029
U 1 1 5B035F1F
P 7950 4000
F 0 "#PWR029" H 7950 4100 30  0001 C CNN
F 1 "VCC" H 7950 4100 30  0000 C CNN
F 2 "" H 7950 4000 60  0000 C CNN
F 3 "" H 7950 4000 60  0000 C CNN
	1    7950 4000
	0    1    1    0   
$EndComp
$Comp
L R-RESCUE-v9958 R10
U 1 1 5B035F25
P 7000 4200
F 0 "R10" V 7080 4200 40  0000 C CNN
F 1 "2.61k/10%" V 7007 4201 40  0000 C CNN
F 2 "Discret:R3" V 6930 4200 30  0001 C CNN
F 3 "" H 7000 4200 30  0000 C CNN
	1    7000 4200
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R11
U 1 1 5B035F2C
P 7000 4300
F 0 "R11" V 7000 4400 40  0000 C CNN
F 1 "75" V 7007 4301 40  0000 C CNN
F 2 "Discret:R3" V 6930 4300 30  0001 C CNN
F 3 "" H 7000 4300 30  0000 C CNN
	1    7000 4300
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R12
U 1 1 5B035F33
P 7000 4400
F 0 "R12" V 7000 4500 40  0000 C CNN
F 1 "75" V 7007 4401 40  0000 C CNN
F 2 "Discret:R3" V 6930 4400 30  0001 C CNN
F 3 "" H 7000 4400 30  0000 C CNN
	1    7000 4400
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R8
U 1 1 5B035F3A
P 7000 3800
F 0 "R8" V 7000 3900 40  0000 C CNN
F 1 "75" V 7007 3801 40  0000 C CNN
F 2 "Discret:R3" V 6930 3800 30  0001 C CNN
F 3 "" H 7000 3800 30  0000 C CNN
	1    7000 3800
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R7
U 1 1 5B035F41
P 7000 3700
F 0 "R7" V 7000 3800 40  0000 C CNN
F 1 "75" V 7007 3701 40  0000 C CNN
F 2 "Discret:R3" V 6930 3700 30  0001 C CNN
F 3 "" H 7000 3700 30  0000 C CNN
	1    7000 3700
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R6
U 1 1 5B035F48
P 7000 3600
F 0 "R6" V 7000 3700 40  0000 C CNN
F 1 "75" V 7007 3601 40  0000 C CNN
F 2 "Discret:R3" V 6930 3600 30  0001 C CNN
F 3 "" H 7000 3600 30  0000 C CNN
	1    7000 3600
	0    -1   -1   0   
$EndComp
$Comp
L R-RESCUE-v9958 R9
U 1 1 5B035F4F
P 7000 3900
F 0 "R9" V 7000 4000 40  0000 C CNN
F 1 "43" V 7007 3901 40  0000 C CNN
F 2 "Discret:R3" V 6930 3900 30  0001 C CNN
F 3 "" H 7000 3900 30  0000 C CNN
	1    7000 3900
	0    -1   -1   0   
$EndComp
$Comp
L CP C17
U 1 1 5B035F56
P 7450 3400
F 0 "C17" H 7475 3500 50  0000 L CNN
F 1 "220µF" H 7475 3300 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D6.3_L11.2_P2.5" H 7488 3250 50  0001 C CNN
F 3 "" H 7450 3400 50  0000 C CNN
	1    7450 3400
	-1   0    0    1   
$EndComp
$Comp
L CP C20
U 1 1 5B035F5D
P 7700 3400
F 0 "C20" H 7725 3500 50  0000 L CNN
F 1 "220µF" H 7725 3300 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D6.3_L11.2_P2.5" H 7738 3250 50  0001 C CNN
F 3 "" H 7700 3400 50  0000 C CNN
	1    7700 3400
	-1   0    0    1   
$EndComp
$Comp
L CP C22
U 1 1 5B035F64
P 7950 3400
F 0 "C22" H 7975 3500 50  0000 L CNN
F 1 "220µF" H 7975 3300 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D6.3_L11.2_P2.5" H 7988 3250 50  0001 C CNN
F 3 "" H 7950 3400 50  0000 C CNN
	1    7950 3400
	-1   0    0    1   
$EndComp
$Comp
L CP C23
U 1 1 5B035F6B
P 8200 3400
F 0 "C23" H 8225 3500 50  0000 L CNN
F 1 "220µF" H 8225 3300 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D6.3_L11.2_P2.5" H 8238 3250 50  0001 C CNN
F 3 "" H 8200 3400 50  0000 C CNN
	1    8200 3400
	-1   0    0    1   
$EndComp
$Comp
L CP C16
U 1 1 5B035F72
P 7300 4600
F 0 "C16" H 7325 4700 50  0000 L CNN
F 1 "220µF" H 7325 4500 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D6.3_L11.2_P2.5" H 7338 4450 50  0001 C CNN
F 3 "" H 7300 4600 50  0000 C CNN
	1    7300 4600
	1    0    0    -1  
$EndComp
$Comp
L CP C18
U 1 1 5B035F79
P 7550 4600
F 0 "C18" H 7575 4700 50  0000 L CNN
F 1 "220µF" H 7575 4500 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D6.3_L11.2_P2.5" H 7588 4450 50  0001 C CNN
F 3 "" H 7550 4600 50  0000 C CNN
	1    7550 4600
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R13
U 1 1 5B035F80
P 8200 4150
F 0 "R13" V 8200 4100 40  0000 C CNN
F 1 "240" V 8200 4250 40  0000 C CNN
F 2 "Discret:R3" V 8130 4150 30  0001 C CNN
F 3 "" H 8200 4150 30  0000 C CNN
	1    8200 4150
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR030
U 1 1 5B035F87
P 8200 4500
F 0 "#PWR030" H 8200 4500 30  0001 C CNN
F 1 "GND" H 8200 4430 30  0001 C CNN
F 2 "" H 8200 4500 60  0000 C CNN
F 3 "" H 8200 4500 60  0000 C CNN
	1    8200 4500
	1    0    0    -1  
$EndComp
$Comp
L C C14
U 1 1 5B035F8D
P 5250 3250
F 0 "C14" H 5275 3350 50  0000 L CNN
F 1 "100n" H 5275 3150 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 5288 3100 50  0001 C CNN
F 3 "" H 5250 3250 50  0001 C CNN
	1    5250 3250
	1    0    0    -1  
$EndComp
$Comp
L C C12
U 1 1 5B035F94
P 5050 3250
F 0 "C12" H 5075 3350 50  0000 L CNN
F 1 "100n" H 5075 3150 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 5088 3100 50  0001 C CNN
F 3 "" H 5050 3250 50  0001 C CNN
	1    5050 3250
	1    0    0    -1  
$EndComp
$Comp
L C C11
U 1 1 5B035F9B
P 4850 3250
F 0 "C11" H 4875 3350 50  0000 L CNN
F 1 "100n" H 4875 3150 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 4888 3100 50  0001 C CNN
F 3 "" H 4850 3250 50  0001 C CNN
	1    4850 3250
	1    0    0    -1  
$EndComp
$Comp
L OSC X1
U 1 1 5B035FA2
P 3750 4150
F 0 "X1" H 3750 4450 70  0000 C CNN
F 1 "OSC" H 3750 4150 70  0000 C CNN
F 2 "Oscillators:KXO-200_LargePads" H 3750 4150 60  0001 C CNN
F 3 "" H 3750 4150 60  0000 C CNN
	1    3750 4150
	1    0    0    -1  
$EndComp
$Comp
L R-RESCUE-v9958 R4
U 1 1 5B035FA9
P 5050 4000
F 0 "R4" V 5130 4000 40  0000 C CNN
F 1 "2.2k" V 5057 4001 40  0000 C CNN
F 2 "Discret:R3" V 4980 4000 30  0001 C CNN
F 3 "" H 5050 4000 30  0000 C CNN
	1    5050 4000
	0    -1   -1   0   
$EndComp
$Comp
L C C15
U 1 1 5B035FB0
P 5300 4800
F 0 "C15" H 5325 4900 50  0000 L CNN
F 1 "100n" H 5325 4700 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 5338 4650 50  0001 C CNN
F 3 "" H 5300 4800 50  0001 C CNN
	1    5300 4800
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR031
U 1 1 5B035FB7
P 5300 5100
F 0 "#PWR031" H 5300 5100 30  0001 C CNN
F 1 "GND" H 5300 5030 30  0001 C CNN
F 2 "" H 5300 5100 60  0000 C CNN
F 3 "" H 5300 5100 60  0000 C CNN
	1    5300 5100
	1    0    0    -1  
$EndComp
$Comp
L CP C13
U 1 1 5B035FBD
P 5050 4800
F 0 "C13" H 5075 4900 50  0000 L CNN
F 1 "47µF" H 5075 4700 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D5_L11_P2.5" H 5088 4650 50  0001 C CNN
F 3 "" H 5050 4800 50  0000 C CNN
	1    5050 4800
	1    0    0    -1  
$EndComp
$Comp
L C C21
U 1 1 5B035FC4
P 7900 4200
F 0 "C21" H 7925 4300 50  0000 L CNN
F 1 "100n" H 7925 4100 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Disc_D3_P2.5" H 7938 4050 50  0001 C CNN
F 3 "" H 7900 4200 50  0001 C CNN
	1    7900 4200
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR032
U 1 1 5B035FCB
P 7900 4500
F 0 "#PWR032" H 7900 4500 30  0001 C CNN
F 1 "GND" H 7900 4430 30  0001 C CNN
F 2 "" H 7900 4500 60  0000 C CNN
F 3 "" H 7900 4500 60  0000 C CNN
	1    7900 4500
	1    0    0    -1  
$EndComp
$Comp
L CP C19
U 1 1 5B035FD1
P 7650 4200
F 0 "C19" H 7675 4300 50  0000 L CNN
F 1 "47µF" H 7675 4100 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D5_L11_P2.5" H 7688 4050 50  0001 C CNN
F 3 "" H 7650 4200 50  0000 C CNN
	1    7650 4200
	1    0    0    -1  
$EndComp
$Comp
L VCC #PWR033
U 1 1 5B035FD8
P 2900 3800
F 0 "#PWR033" H 2900 3900 30  0001 C CNN
F 1 "VCC" H 2900 3900 30  0000 C CNN
F 2 "" H 2900 3800 60  0000 C CNN
F 3 "" H 2900 3800 60  0000 C CNN
	1    2900 3800
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR034
U 1 1 5B035FDE
P 2900 4650
F 0 "#PWR034" H 2900 4650 30  0001 C CNN
F 1 "GND" H 2900 4580 30  0001 C CNN
F 2 "" H 2900 4650 60  0000 C CNN
F 3 "" H 2900 4650 60  0000 C CNN
	1    2900 4650
	1    0    0    -1  
$EndComp
NoConn ~ 4450 4300
$Comp
L R-RESCUE-v9958 R5
U 1 1 5B035FE5
P 5050 4400
F 0 "R5" V 5130 4400 40  0000 C CNN
F 1 "2.2k" V 5057 4401 40  0000 C CNN
F 2 "Discret:R3" V 4980 4400 30  0001 C CNN
F 3 "" H 5050 4400 30  0000 C CNN
	1    5050 4400
	0    -1   -1   0   
$EndComp
Text Label 7450 3300 1    60   ~ 0
R_OUT
Text Label 7700 3300 1    60   ~ 0
G_OUT
Text Label 7950 3300 1    60   ~ 0
B_OUT
Text Label 8200 3350 1    60   ~ 0
CV_OUT
Text Label 7300 5000 1    60   ~ 0
C_OUT
Text Label 7550 5000 1    60   ~ 0
Y_OUT
$Comp
L CONN_01X02 P4
U 1 1 5B036007
P 8950 2800
F 0 "P4" H 8950 2950 50  0000 C CNN
F 1 "SYNC/C" V 9050 2800 50  0000 C CNN
F 2 "w_conn_av:rca_black" H 8950 2800 50  0001 C CNN
F 3 "" H 8950 2800 50  0000 C CNN
	1    8950 2800
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR035
U 1 1 5B036020
P 8650 3050
F 0 "#PWR035" H 8650 3050 30  0001 C CNN
F 1 "GND" H 8650 2980 30  0001 C CNN
F 2 "" H 8650 3050 60  0000 C CNN
F 3 "" H 8650 3050 60  0000 C CNN
	1    8650 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	3450 3050 5050 3050
Wire Wire Line
	4300 3050 4300 3250
Wire Wire Line
	4450 2950 4450 3250
Wire Wire Line
	4600 2850 4600 3250
Wire Wire Line
	4300 3750 4300 3800
Wire Wire Line
	4300 3800 4600 3800
Wire Wire Line
	4600 3800 4600 3750
Wire Wire Line
	4450 3750 4450 3850
Connection ~ 4450 3800
Wire Wire Line
	5300 3500 5400 3500
Wire Wire Line
	6700 3500 7200 3500
Wire Wire Line
	4900 4600 5400 4600
Wire Wire Line
	6700 4000 7950 4000
Wire Wire Line
	6700 4200 6750 4200
Wire Wire Line
	7250 4200 7250 4000
Connection ~ 7250 4000
Wire Wire Line
	7200 3500 7200 3300
Wire Wire Line
	6700 3600 6750 3600
Wire Wire Line
	6700 3700 6750 3700
Wire Wire Line
	6700 3800 6750 3800
Wire Wire Line
	6700 4300 6750 4300
Wire Wire Line
	6700 4400 6750 4400
Wire Wire Line
	6700 3900 6750 3900
Wire Wire Line
	7250 3600 7450 3600
Wire Wire Line
	7450 3600 7450 3550
Wire Wire Line
	7250 3700 7700 3700
Wire Wire Line
	7700 3700 7700 3550
Wire Wire Line
	7250 3800 7950 3800
Wire Wire Line
	7950 3800 7950 3550
Wire Wire Line
	7250 3900 8200 3900
Wire Wire Line
	8200 3900 8200 3550
Wire Wire Line
	8200 4400 8200 4400
Wire Wire Line
	7250 4400 7300 4400
Wire Wire Line
	7300 4400 7300 4450
Wire Wire Line
	7250 4300 7550 4300
Wire Wire Line
	7550 4300 7550 4450
Wire Wire Line
	5400 3600 5250 3600
Wire Wire Line
	5250 3600 5250 3400
Wire Wire Line
	5400 3700 5050 3700
Wire Wire Line
	5050 3700 5050 3400
Wire Wire Line
	5400 3800 4850 3800
Wire Wire Line
	4850 3800 4850 3400
Wire Wire Line
	5300 3500 5300 4300
Wire Wire Line
	5400 4100 5300 4100
Connection ~ 5300 4100
Wire Wire Line
	4450 4000 4800 4000
Wire Wire Line
	5300 4000 5400 4000
Wire Wire Line
	5300 4950 5300 5100
Wire Wire Line
	5050 4950 5050 5000
Wire Wire Line
	5050 5000 5300 5000
Connection ~ 5300 5000
Wire Wire Line
	7900 4350 7900 4500
Wire Wire Line
	7650 4350 7650 4400
Wire Wire Line
	7650 4400 7900 4400
Connection ~ 7900 4400
Wire Wire Line
	8200 4400 8200 4500
Wire Wire Line
	2900 3800 2900 4000
Wire Wire Line
	2900 4000 3050 4000
Wire Wire Line
	3050 4300 2900 4300
Wire Wire Line
	2900 4300 2900 4650
Wire Wire Line
	5300 4400 5400 4400
Wire Wire Line
	4800 4400 4700 4400
Wire Wire Line
	7450 1850 7450 3250
Wire Wire Line
	7700 1650 7700 3250
Wire Wire Line
	7950 1450 7950 3250
Wire Wire Line
	7550 4750 7550 5000
Wire Wire Line
	7300 4750 7300 5000
NoConn ~ 5400 4200
Wire Wire Line
	5050 4650 5050 4600
Connection ~ 5050 4600
Wire Wire Line
	5300 4650 5300 4600
Connection ~ 5300 4600
Wire Wire Line
	7650 4000 7650 4050
Connection ~ 7650 4000
Wire Wire Line
	7900 4000 7900 4050
Connection ~ 7900 4000
Connection ~ 4300 3050
Wire Wire Line
	3450 2950 5250 2950
Connection ~ 4450 2950
Wire Wire Line
	3450 2850 4850 2850
Connection ~ 4600 2850
Wire Wire Line
	5050 3050 5050 3100
Wire Wire Line
	3450 3150 4700 3150
Wire Wire Line
	4700 3150 4700 4400
Wire Wire Line
	5250 2950 5250 3100
Wire Wire Line
	4850 2850 4850 3100
Text HLabel 3450 2850 0    60   Input ~ 0
RGB_B
Text HLabel 3450 2950 0    60   Input ~ 0
RGB_R
Text HLabel 3450 3050 0    60   Input ~ 0
RGB_G
Text HLabel 3450 3150 0    60   Input ~ 0
CSYNC
$Comp
L MINI_DIN_4 X?
U 1 1 5B038CC4
P 7550 5850
AR Path="/5B038CC4" Ref="X?"  Part="1" 
AR Path="/5B0355D1/5B038CC4" Ref="X3"  Part="1" 
F 0 "X3" H 7150 6375 50  0000 L BNN
F 1 "S-VIDEO" H 7550 6375 50  0000 L BNN
F 2 "mini_din:mini_din-M_DIN4" H 7550 6000 50  0001 C CNN
F 3 "" H 7550 5850 60  0000 C CNN
	1    7550 5850
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR036
U 1 1 5B038CCB
P 6900 5850
F 0 "#PWR036" H 6900 5850 30  0001 C CNN
F 1 "GND" H 6900 5780 30  0001 C CNN
F 2 "" H 6900 5850 60  0000 C CNN
F 3 "" H 6900 5850 60  0000 C CNN
	1    6900 5850
	1    0    0    -1  
$EndComp
$Comp
L GND-RESCUE-v9958 #PWR037
U 1 1 5B038CD1
P 8200 5850
F 0 "#PWR037" H 8200 5850 30  0001 C CNN
F 1 "GND" H 8200 5780 30  0001 C CNN
F 2 "" H 8200 5850 60  0000 C CNN
F 3 "" H 8200 5850 60  0000 C CNN
	1    8200 5850
	1    0    0    -1  
$EndComp
Wire Wire Line
	6900 5850 6900 5750
Wire Wire Line
	6900 5750 6950 5750
Wire Wire Line
	8150 5750 8200 5750
Wire Wire Line
	8200 5750 8200 5850
Wire Wire Line
	7050 5650 6750 5650
Wire Wire Line
	8050 5650 8350 5650
Text Label 8300 5650 2    60   ~ 0
Y_OUT
Text Label 7000 5650 2    60   ~ 0
C_OUT
Wire Wire Line
	7050 6050 7050 6250
Wire Wire Line
	7050 6250 8050 6250
Wire Wire Line
	8050 6250 8050 6050
Connection ~ 7550 6250
$Comp
L GND-RESCUE-v9958 #PWR038
U 1 1 5B038CE4
P 7550 6350
F 0 "#PWR038" H 7550 6350 30  0001 C CNN
F 1 "GND" H 7550 6280 30  0001 C CNN
F 2 "" H 7550 6350 60  0000 C CNN
F 3 "" H 7550 6350 60  0000 C CNN
	1    7550 6350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7550 6250 7550 6350
$Comp
L DB9 J1
U 1 1 5B2FF0C6
P 9200 1850
F 0 "J1" H 9200 2400 50  0000 C CNN
F 1 "DB9" H 9200 1300 50  0000 C CNN
F 2 "Connect:DB9FC" H 9200 1850 50  0001 C CNN
F 3 "" H 9200 1850 50  0000 C CNN
	1    9200 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	8750 1850 7450 1850
Wire Wire Line
	8750 1650 7700 1650
Wire Wire Line
	8750 1450 7950 1450
Wire Wire Line
	7950 3050 7950 3050
$Comp
L GND-RESCUE-v9958 #PWR039
U 1 1 5B2FF2BC
P 8650 2450
F 0 "#PWR039" H 8650 2450 30  0001 C CNN
F 1 "GND" H 8650 2380 30  0001 C CNN
F 2 "" H 8650 2450 60  0000 C CNN
F 3 "" H 8650 2450 60  0000 C CNN
	1    8650 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	8750 2250 8650 2250
Wire Wire Line
	8650 2250 8650 2450
Wire Wire Line
	8750 1950 8200 1950
Wire Wire Line
	8200 1950 8200 3250
Connection ~ 8200 3250
Wire Wire Line
	8750 2850 8650 2850
Wire Wire Line
	8650 2850 8650 3050
Wire Wire Line
	8750 2750 8200 2750
Connection ~ 8200 2750
$EndSCHEMATC
