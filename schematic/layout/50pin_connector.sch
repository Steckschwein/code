v 20110115 2
C 40000 40000 0 0 0 title-B.sym
C 44300 50600 1 180 0 header50-2.sym
{
T 44050 40100 5 10 0 1 180 0 1
device=COMPACT_FLASH
T 43700 40500 5 10 1 1 180 0 1
refdes=J1
T 44100 39500 5 10 0 1 180 0 1
footprint=CONNECTOR 25 2
}
C 42800 40100 1 0 0 gnd-2.sym
N 42900 40400 42900 50400 4
U 45200 47800 45200 50700 10 1
{
T 45000 50600 5 10 1 1 0 0 1
netname=D
}
C 45000 47600 1 0 0 busripper-1.sym
{
T 45000 48000 5 8 0 0 0 0 1
device=none
}
C 45000 48000 1 0 0 busripper-1.sym
{
T 45000 48400 5 8 0 0 0 0 1
device=none
}
C 45000 48400 1 0 0 busripper-1.sym
{
T 45000 48800 5 8 0 0 0 0 1
device=none
}
C 45000 48800 1 0 0 busripper-1.sym
{
T 45000 49200 5 8 0 0 0 0 1
device=none
}
C 45000 49200 1 0 0 busripper-1.sym
{
T 45000 49600 5 8 0 0 0 0 1
device=none
}
C 45000 49600 1 0 0 busripper-1.sym
{
T 45000 50000 5 8 0 0 0 0 1
device=none
}
C 45000 50000 1 0 0 busripper-1.sym
{
T 45000 50400 5 8 0 0 0 0 1
device=none
}
C 45000 50400 1 0 0 busripper-1.sym
{
T 45000 50800 5 8 0 0 0 0 1
device=none
}
T 44800 47600 5 10 1 1 0 0 1
netname=D7
T 44800 48000 5 10 1 1 0 0 1
netname=D6
T 44800 48400 5 10 1 1 0 0 1
netname=D5
T 44800 48800 5 10 1 1 0 0 1
netname=D4
T 44800 49200 5 10 1 1 0 0 1
netname=D3
T 44800 49600 5 10 1 1 0 0 1
netname=D2
T 44800 50000 5 10 1 1 0 0 1
netname=D1
T 44800 50400 5 10 1 1 0 0 1
netname=D0
N 45000 50400 44300 50400 4
N 44300 50000 45000 50000 4
N 44300 49600 45000 49600 4
N 44300 49200 45000 49200 4
N 44300 48800 45000 48800 4
N 44300 48400 45000 48400 4
N 44300 48000 45000 48000 4
N 44300 47600 45000 47600 4
U 45200 47500 45200 45900 10 1
{
T 45400 47500 5 10 1 1 0 6 1
netname=A
}
N 44300 46000 45000 46000 4
{
T 45000 46000 5 10 1 1 0 6 1
netname=A3
}
C 45000 46000 1 270 1 busripper-1.sym
{
T 45400 46000 5 8 0 0 90 2 1
device=none
}
N 44300 46400 45000 46400 4
{
T 45000 46400 5 10 1 1 0 6 1
netname=A2
}
C 45000 46400 1 270 1 busripper-1.sym
{
T 45400 46400 5 8 0 0 90 2 1
device=none
}
N 44300 46800 45000 46800 4
{
T 45000 46800 5 10 1 1 0 6 1
netname=A1
}
C 45000 46800 1 270 1 busripper-1.sym
{
T 45400 46800 5 8 0 0 90 2 1
device=none
}
N 44300 47200 45000 47200 4
{
T 45000 47200 5 10 1 1 0 6 1
netname=A0
}
C 45000 47200 1 270 1 busripper-1.sym
{
T 45400 47200 5 8 0 0 90 2 1
device=none
}
N 44300 44400 45000 44400 4
{
T 44300 44400 5 10 1 1 0 0 1
netname=RESET
}
N 44300 44800 45000 44800 4
{
T 44300 44800 5 10 1 1 0 0 1
netname=RW
}
N 44300 44000 45000 44000 4
{
T 44300 44000 5 10 1 1 0 0 1
netname=IRQ
}
N 44300 43600 45000 43600 4
{
T 44300 43600 5 10 1 1 0 0 1
netname=NMI
}
N 44300 43200 45000 43200 4
{
T 44300 43200 5 10 1 1 0 0 1
netname=CS_VIA
}
N 44300 42800 45000 42800 4
{
T 44300 42800 5 10 1 1 0 0 1
netname=RW_UART
}
N 44300 42400 45000 42400 4
{
T 44300 42400 5 10 1 1 0 0 1
netname=RD_UART
}
N 44300 42000 45000 42000 4
{
T 44300 42000 5 10 1 1 0 0 1
netname=CSW_VDP
}
N 44300 41600 45000 41600 4
{
T 44300 41600 5 10 1 1 0 0 1
netname=CSR_VDP
}
N 44300 41200 45000 41200 4
{
T 44300 41200 5 10 1 1 0 0 1
netname=E_LCD
}
N 44300 40800 45000 40800 4
C 48400 47700 1 0 0 connector4-1.sym
{
T 50200 48600 5 10 0 0 0 0 1
device=CONNECTOR_4
T 48400 49100 5 10 1 1 0 0 1
refdes=CONN1
T 48400 47700 5 10 1 0 0 0 1
footprint=CONNECTOR 4 1
}
N 50100 48500 50100 48200 4
N 50100 48200 50500 48200 4
{
T 50100 48200 5 10 1 1 0 0 1
netname=GND
}
N 50100 47900 50500 47900 4
{
T 50100 47900 5 10 1 1 0 0 1
netname=VCC
}
C 50500 48100 1 270 0 vcc-2.sym
