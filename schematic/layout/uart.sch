v 20110115 2
C 40000 40000 0 0 0 title-B.sym
T 50100 40500 9 10 1 0 0 0 2
UART and rs232

C 47000 41800 1 0 0 16550.sym
{
T 47300 50650 5 10 0 0 0 0 1
footprint=DIP40
T 49500 50300 5 10 1 1 0 0 1
refdes=U9
}
C 52100 46500 1 0 0 max232-1.sym
{
T 52400 49550 5 10 0 0 0 0 1
device=MAX232
T 54400 49400 5 10 1 1 0 6 1
refdes=U10
T 52400 49750 5 10 0 0 0 0 1
footprint=DIP16
}
C 40900 42600 1 0 0 74138-2.sym
{
T 41200 46340 5 10 0 0 0 0 1
device=74138
T 41200 46140 5 10 0 0 0 0 1
footprint=DIP16
T 42600 46000 5 10 1 1 0 6 1
refdes=U8
}
C 56300 46400 1 180 0 DB9-2.sym
{
T 55300 43200 5 10 0 0 180 0 1
device=DB9
T 56100 43200 5 10 1 1 180 0 1
refdes=CONN?
}
N 40900 45600 40500 45600 4
{
T 40600 45600 5 10 1 1 0 0 1
netname=RW
}
N 40900 45200 40500 45200 4
N 40900 44800 40500 44800 4
N 40500 45200 40500 44800 4
C 40400 44500 1 0 0 gnd-2.sym
N 40900 44000 40500 44000 4
{
T 40700 44000 5 10 1 1 0 0 1
netname=UART
}
C 40400 43300 1 0 0 gnd-2.sym
N 40500 43600 40900 43600 4
N 40500 43200 40900 43200 4
{
T 40700 43200 5 10 1 1 0 0 1
netname=PHI2
}
N 42900 45600 47000 45600 4
C 46400 45700 1 0 0 gnd-2.sym
N 46500 46000 47000 46000 4
C 46400 42700 1 0 0 gnd-2.sym
N 46500 43000 47000 43000 4
N 42900 45200 43700 45200 4
N 43700 45200 43700 42600 4
N 43700 42600 47000 42600 4
U 46500 50100 46500 48900 10 1
{
T 46300 50000 5 10 1 1 0 0 1
netname=A
}
N 47000 49000 46700 49000 4
{
T 46700 49000 5 10 1 1 0 0 1
netname=A2
}
C 46700 49000 1 90 0 busripper-1.sym
{
T 46300 49000 5 8 0 0 90 0 1
device=none
}
N 47000 49400 46700 49400 4
{
T 46700 49400 5 10 1 1 0 0 1
netname=A1
}
C 46700 49400 1 90 0 busripper-1.sym
{
T 46300 49400 5 8 0 0 90 0 1
device=none
}
N 47000 49800 46700 49800 4
{
T 46700 49800 5 10 1 1 0 0 1
netname=A0
}
C 46700 49800 1 90 0 busripper-1.sym
{
T 46300 49800 5 8 0 0 90 0 1
device=none
}
U 51000 45600 51000 49300 10 -1
{
T 51000 48800 5 10 1 1 0 0 1
netname=D
}
N 50100 48800 50800 48800 4
{
T 50200 48800 5 10 1 1 0 0 1
netname=D0
}
C 50800 48800 1 270 0 busripper-1.sym
{
T 51200 48800 5 8 0 0 270 0 1
device=none
}
N 50100 48400 50800 48400 4
{
T 50200 48400 5 10 1 1 0 0 1
netname=D1
}
C 50800 48400 1 270 0 busripper-1.sym
{
T 51200 48400 5 8 0 0 270 0 1
device=none
}
N 50100 48000 50800 48000 4
{
T 50200 48000 5 10 1 1 0 0 1
netname=D2
}
C 50800 48000 1 270 0 busripper-1.sym
{
T 51200 48000 5 8 0 0 270 0 1
device=none
}
N 50100 47600 50800 47600 4
{
T 50200 47600 5 10 1 1 0 0 1
netname=D3
}
C 50800 47600 1 270 0 busripper-1.sym
{
T 51200 47600 5 8 0 0 270 0 1
device=none
}
N 50100 47200 50800 47200 4
{
T 50200 47200 5 10 1 1 0 0 1
netname=D4
}
C 50800 47200 1 270 0 busripper-1.sym
{
T 51200 47200 5 8 0 0 270 0 1
device=none
}
N 50100 46800 50800 46800 4
{
T 50200 46800 5 10 1 1 0 0 1
netname=D5
}
C 50800 46800 1 270 0 busripper-1.sym
{
T 51200 46800 5 8 0 0 270 0 1
device=none
}
N 50100 46400 50800 46400 4
{
T 50200 46400 5 10 1 1 0 0 1
netname=D6
}
C 50800 46400 1 270 0 busripper-1.sym
{
T 51200 46400 5 8 0 0 270 0 1
device=none
}
N 50100 46000 50800 46000 4
{
T 50200 46000 5 10 1 1 0 0 1
netname=D7
}
C 50800 46000 1 270 0 busripper-1.sym
{
T 51200 46000 5 8 0 0 270 0 1
device=none
}
C 45500 44300 1 0 0 7406-1.sym
{
T 46100 45200 5 10 0 0 0 0 1
device=7406
T 45800 45200 5 10 1 1 0 0 1
refdes=U11
T 46100 47000 5 10 0 0 0 0 1
footprint=DIP14
T 45500 44300 5 10 1 0 0 0 1
slot=6
}
C 50500 44300 1 0 0 7406-1.sym
{
T 51100 45200 5 10 0 0 0 0 1
device=7406
T 50800 45200 5 10 1 1 0 0 1
refdes=U11
T 51100 47000 5 10 0 0 0 0 1
footprint=DIP14
}
N 50500 44800 50100 44800 4
N 51600 44800 52100 44800 4
{
T 51900 44800 5 10 1 1 0 0 1
netname=IRQ
}
C 44300 44700 1 0 0 resistor-2.sym
{
T 44700 45050 5 10 0 0 0 0 1
device=RESISTOR
T 44500 45000 5 10 1 1 0 0 1
refdes=R2
T 44900 44800 5 10 1 1 90 0 1
footprint=R025
}
N 46600 44800 47000 44800 4
N 45200 44800 45500 44800 4
C 44100 44800 1 0 0 vcc-2.sym
N 45500 44800 45500 44100 4
{
T 45500 44600 5 10 1 1 0 0 1
netname=RESET
}
