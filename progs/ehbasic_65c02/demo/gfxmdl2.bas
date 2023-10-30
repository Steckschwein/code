10 REM MANDELBROT SET
15 SCREEN 6
20 X1=511:Y1=211:Y2=Y1/2
30 C=30:M=4
40 I1=-1.0:I2=1.0:R1=-2.0:R2=1.0
50 S1=(R2-R1)/X1:S2=(I2-I1)/Y1
60 FOR Y=0 TO Y2
70 I3=I1+S2*Y
80 FOR X=0 TO X1
90 R3=R1+S1*X:Z1=R3:Z2=I3
100 FOR N=0 TO C
110 A=Z1*Z1:B=Z2*Z2
120 IF A+B>M GOTO 150
130 Z2=2*Z1*Z2+I3:Z1=A-B+R3
140 NEXT N
150 cl=74+N*2
154 PLOT X,Y,cl
155 PLOT X,Y1-Y,cl
160 NEXT X
170 NEXT Y
180 GET K$:IF K$="" GOTO 180
185 SCREEN 1
190 END
