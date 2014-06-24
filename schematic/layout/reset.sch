v 20110115 2
C 40000 40000 0 0 0 title-B.sym
C 46400 44400 1 0 0 lm555-1.sym
{
T 48700 46800 5 10 0 0 0 0 1
device=LM555
T 48200 44400 5 10 1 1 0 0 1
refdes=U1
T 47000 44100 5 10 0 1 0 0 1
footprint=DIP8
}
C 48400 47900 1 0 0 resistor-2.sym
{
T 48800 48250 5 10 0 0 0 0 1
device=RESISTOR
T 48600 48200 5 10 1 1 0 0 1
refdes=R1
T 48800 47700 5 10 0 1 0 0 1
footprint=R025
}
C 45900 47900 1 0 0 resistor-2.sym
{
T 46300 48250 5 10 0 0 0 0 1
device=RESISTOR
T 46100 48200 5 10 1 1 0 0 1
refdes=R2
T 46500 48000 5 10 0 1 90 0 1
footprint=R025
}
C 45300 45900 1 270 0 capacitor-1.sym
{
T 46000 45700 5 10 0 0 270 0 1
device=CAPACITOR
T 46200 45700 5 10 0 0 270 0 1
symversion=0.1
T 45700 45600 5 10 0 0 90 0 1
value=10n
T 45800 45700 5 10 1 1 270 0 1
refdes=C4
T 45600 45400 5 10 0 1 90 0 1
footprint=C200
}
C 48800 44600 1 270 0 capacitor-1.sym
{
T 49500 44400 5 10 0 0 270 0 1
device=CAPACITOR
T 49700 44400 5 10 0 0 270 0 1
symversion=0.1
T 49300 44400 5 10 1 1 270 0 1
refdes=C1
T 49000 44200 5 10 0 1 0 0 1
footprint=C200
T 48800 44600 5 10 0 1 0 0 1
value=1n
}
C 49300 45900 1 270 0 capacitor-4.sym
{
T 50400 45700 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 50000 45700 5 10 0 0 270 0 1
symversion=0.1
T 49300 45900 5 10 0 0 270 0 1
value=1uF
T 49800 45700 5 10 1 1 270 0 1
refdes=C2
T 49500 45600 5 10 0 1 270 0 1
footprint=RADIAL_CAN 200
}
C 49400 43200 1 0 0 gnd-2.sym
C 51600 44100 1 0 0 7400-1.sym
{
T 52100 45000 5 10 0 0 0 0 1
device=7400
T 52100 46350 5 10 0 0 0 0 1
footprint=DIP14
T 51900 45000 5 10 1 1 0 0 1
refdes=U2
T 52200 44700 5 10 0 1 0 0 1
slot=4
}
N 51600 44100 51600 44800 4
{
T 51600 43800 5 10 1 1 0 0 1
netname=/RESET
}
C 43400 44900 1 90 0 switch-pushbutton-nc-1.sym
{
T 43600 44450 5 10 0 0 90 0 1
device=SWITCH_PUSHBUTTON_NC
T 43050 45300 5 10 1 1 90 0 1
refdes=S1
}
N 52900 44600 53400 44600 4
{
T 52900 44600 5 10 1 1 0 0 1
netname=RESET
}
T 50000 40700 9 10 1 0 0 0 1
RESET circuit
C 47800 48500 1 0 0 vcc-2.sym
N 48000 48500 48000 47200 4
N 46800 48000 48000 48000 4
N 47200 48000 47200 47200 4
N 48400 48000 48000 48000 4
N 48700 45900 49500 45900 4
N 49500 45900 49500 48000 4
N 49500 48000 49300 48000 4
N 48700 46300 49500 46300 4
N 48700 44800 51600 44800 4
N 49500 43500 49500 45000 4
N 46400 44800 46400 43500 4
N 45500 43500 49500 43500 4
N 45900 48000 45500 48000 4
N 45500 48000 45500 45900 4
N 43300 45900 46400 45900 4
N 48700 45500 49000 45500 4
N 49000 45500 49000 44600 4
N 49000 43700 49000 43500 4
N 45500 45000 45500 43500 4
N 43300 44900 43300 44800 4
N 43300 44800 45500 44800 4
C 49100 48800 1 0 0 gnd-2.sym
C 49000 50100 1 270 0 capacitor-1.sym
{
T 49700 49900 5 10 0 0 270 0 1
device=CAPACITOR
T 49900 49900 5 10 0 0 270 0 1
symversion=0.1
T 49400 49800 5 10 0 0 90 0 1
value=100n
T 49500 49900 5 10 1 1 270 0 1
refdes=C8
T 49100 49600 5 10 0 1 0 0 1
footprint=C200
}
C 49000 50200 1 0 0 vcc-2.sym
N 49200 50200 49200 50100 4
N 49200 49100 49200 49200 4
