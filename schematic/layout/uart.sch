v 20110115 2
C 40000 40000 0 0 0 title-B.sym
T 50100 40500 9 10 1 0 0 0 2
UART and rs232

C 45800 42200 1 0 0 16550.sym
{
T 46100 51050 5 10 0 0 0 0 1
footprint=DIP40
T 48300 50700 5 10 1 1 0 0 1
refdes=U9
T 45800 42200 5 10 1 1 0 0 1
device=16550
}
C 52800 47500 1 0 0 max232-1.sym
{
T 53100 50550 5 10 0 0 0 0 1
device=MAX232
T 55100 50400 5 10 1 1 0 6 1
refdes=U10
T 53100 50750 5 10 0 0 0 0 1
footprint=DIP16
}
C 55000 44900 1 90 0 DB9-2.sym
{
T 51800 45900 5 10 0 0 90 0 1
device=DB9
T 51800 45100 5 10 1 1 90 0 1
refdes=CONN1
T 55000 44900 5 10 1 0 0 0 1
footprint=DB9M
}
N 45300 46000 45800 46000 4
{
T 44900 45700 5 10 1 1 0 0 1
netname=WE
}
C 45200 46100 1 0 0 gnd-2.sym
N 45300 46400 45800 46400 4
C 45200 43100 1 0 0 gnd-2.sym
N 45300 43400 45800 43400 4
N 45300 43000 45800 43000 4
{
T 44900 42800 5 10 1 1 0 0 1
netname=OE
}
U 45300 50500 45300 49300 10 1
{
T 45100 50400 5 10 1 1 0 0 1
netname=A
}
N 45800 49400 45500 49400 4
{
T 45500 49400 5 10 1 1 0 0 1
netname=A2
}
C 45500 49400 1 90 0 busripper-1.sym
{
T 45100 49400 5 8 0 0 90 0 1
device=none
}
N 45800 49800 45500 49800 4
{
T 45500 49800 5 10 1 1 0 0 1
netname=A1
}
C 45500 49800 1 90 0 busripper-1.sym
{
T 45100 49800 5 8 0 0 90 0 1
device=none
}
N 45800 50200 45500 50200 4
{
T 45500 50200 5 10 1 1 0 0 1
netname=A0
}
C 45500 50200 1 90 0 busripper-1.sym
{
T 45100 50200 5 8 0 0 90 0 1
device=none
}
U 49800 46000 49800 49700 10 -1
{
T 49800 49200 5 10 1 1 0 0 1
netname=D
}
N 48900 49200 49600 49200 4
{
T 49000 49200 5 10 1 1 0 0 1
netname=D0
}
C 49600 49200 1 270 0 busripper-1.sym
{
T 50000 49200 5 8 0 0 270 0 1
device=none
}
N 48900 48800 49600 48800 4
{
T 49000 48800 5 10 1 1 0 0 1
netname=D1
}
C 49600 48800 1 270 0 busripper-1.sym
{
T 50000 48800 5 8 0 0 270 0 1
device=none
}
N 48900 48400 49600 48400 4
{
T 49000 48400 5 10 1 1 0 0 1
netname=D2
}
C 49600 48400 1 270 0 busripper-1.sym
{
T 50000 48400 5 8 0 0 270 0 1
device=none
}
N 48900 48000 49600 48000 4
{
T 49000 48000 5 10 1 1 0 0 1
netname=D3
}
C 49600 48000 1 270 0 busripper-1.sym
{
T 50000 48000 5 8 0 0 270 0 1
device=none
}
N 48900 47600 49600 47600 4
{
T 49000 47600 5 10 1 1 0 0 1
netname=D4
}
C 49600 47600 1 270 0 busripper-1.sym
{
T 50000 47600 5 8 0 0 270 0 1
device=none
}
N 48900 47200 49600 47200 4
{
T 49000 47200 5 10 1 1 0 0 1
netname=D5
}
C 49600 47200 1 270 0 busripper-1.sym
{
T 50000 47200 5 8 0 0 270 0 1
device=none
}
N 48900 46800 49600 46800 4
{
T 49000 46800 5 10 1 1 0 0 1
netname=D6
}
C 49600 46800 1 270 0 busripper-1.sym
{
T 50000 46800 5 8 0 0 270 0 1
device=none
}
N 48900 46400 49600 46400 4
{
T 49000 46400 5 10 1 1 0 0 1
netname=D7
}
C 49600 46400 1 270 0 busripper-1.sym
{
T 50000 46400 5 8 0 0 270 0 1
device=none
}
C 49300 44700 1 0 0 7406-1.sym
{
T 49900 45600 5 10 0 0 0 0 1
device=7406
T 49600 45600 5 10 1 1 0 0 1
refdes=U11
T 49900 47400 5 10 0 0 0 0 1
footprint=DIP14
}
N 49300 45200 48900 45200 4
N 50400 45200 50900 45200 4
{
T 50700 45200 5 10 1 1 0 0 1
netname=IRQ
}
N 45400 45200 45800 45200 4
{
T 45400 45200 5 10 1 1 0 0 1
netname=/RESET
}
N 55400 47800 56000 47800 4
{
T 55700 47800 5 10 1 1 0 0 1
netname=RXD_TTL
}
N 55400 48100 56000 48100 4
{
T 55600 48100 5 10 1 1 0 0 1
netname=TXD_TTL
}
N 55400 48400 56000 48400 4
{
T 55700 48400 5 10 1 1 0 0 1
netname=RTS_TTL
}
N 55400 48700 56000 48700 4
{
T 55700 48700 5 10 1 1 0 0 1
netname=CTS_TTL
}
N 55400 49000 56600 49000 4
N 55400 49300 56800 49300 4
C 52800 50100 1 180 0 capacitor-4.sym
{
T 52600 49000 5 10 0 0 180 0 1
device=POLARIZED_CAPACITOR
T 52600 49600 5 10 1 1 180 0 1
refdes=C12
T 52600 49400 5 10 0 0 180 0 1
symversion=0.1
T 52800 50100 5 10 1 1 0 0 1
footprint=RADIAL_CAN 200
}
C 52800 49200 1 180 0 capacitor-4.sym
{
T 52600 48100 5 10 0 0 180 0 1
device=POLARIZED_CAPACITOR
T 52600 48700 5 10 1 1 180 0 1
refdes=C15
T 52600 48500 5 10 0 0 180 0 1
symversion=0.1
T 52800 49200 5 10 1 1 0 0 1
footprint=RADIAL_CAN 200
}
C 51700 49800 1 180 0 capacitor-4.sym
{
T 51500 48700 5 10 0 0 180 0 1
device=POLARIZED_CAPACITOR
T 51500 49300 5 10 1 1 180 0 1
refdes=C13
T 51500 49100 5 10 0 0 180 0 1
symversion=0.1
T 51700 49800 5 10 1 1 0 0 1
footprint=RADIAL_CAN 200
}
N 51700 49600 52800 49600 4
C 51400 48200 1 0 0 capacitor-4.sym
{
T 51600 49300 5 10 0 0 0 0 1
device=POLARIZED_CAPACITOR
T 51600 48700 5 10 1 1 0 0 1
refdes=C14
T 51600 48900 5 10 0 0 0 0 1
symversion=0.1
T 51400 48200 5 10 1 1 0 0 1
footprint=RADIAL_CAN 200
}
N 52300 48400 52800 48400 4
N 51900 49900 51900 49300 4
N 51900 49300 52800 49300 4
C 50800 49400 1 90 0 vcc-2.sym
C 51100 48500 1 270 0 gnd-2.sym
N 51900 49000 51900 48700 4
N 51900 48700 52800 48700 4
C 53300 46100 1 90 0 resistor-2.sym
{
T 52950 46500 5 10 0 0 90 0 1
device=RESISTOR
T 53000 46300 5 10 1 1 90 0 1
refdes=R8
T 53200 46700 5 10 1 1 180 0 1
footprint=R025
}
N 48900 44000 49600 44000 4
N 45200 47200 45900 47200 4
{
T 45000 47300 5 10 1 1 0 0 1
netname=CTS_TTL
}
N 49600 43600 48900 43600 4
{
T 49500 43600 5 10 1 1 0 0 1
netname=TXD_TTL
}
N 45300 44000 45800 44000 4
{
T 45600 44000 5 10 1 1 0 0 1
netname=RXD_TTL
}
N 52800 47800 52600 47800 4
N 52600 47800 52600 46100 4
N 52900 46100 52900 46600 4
N 52900 46600 52000 46600 4
N 52000 46600 52000 48100 4
N 52000 48100 52800 48100 4
N 53200 47000 53200 47300 4
N 53200 47300 50700 47300 4
N 51700 49600 51700 48900 4
N 51700 48900 50700 48900 4
N 50700 48900 50700 47300 4
N 56800 49300 56800 46800 4
N 56800 46800 54100 46800 4
N 54100 46800 54100 46100 4
N 56600 49000 56600 46500 4
N 56600 46500 54400 46500 4
N 54400 46500 54400 46100 4
C 53600 46900 1 180 0 gnd-2.sym
N 53500 46600 53500 46100 4
C 46500 40500 1 0 1 XTAL-1.sym
{
T 46100 43300 5 10 0 0 0 6 1
device=XTAL
T 44900 41900 5 10 1 1 0 6 1
refdes=X2
T 46105 42700 5 10 0 0 0 6 1
footprint=OSC14
}
N 46500 41200 47000 41200 4
N 47000 41200 47000 42300 4
N 48900 50200 49200 50200 4
N 49200 50200 49200 50900 4
N 45800 44800 44000 44800 4
N 44000 44800 44000 50900 4
N 44000 50900 49200 50900 4
C 44100 40400 1 0 0 gnd-2.sym
C 44200 41500 1 90 0 vcc-2.sym
C 44900 48600 1 0 0 vcc-2.sym
N 45100 48600 45800 48600 4
N 45800 48200 45800 48600 4
N 45800 47800 45200 47800 4
{
T 45000 47900 5 10 1 1 0 0 1
netname=CSUART
}
