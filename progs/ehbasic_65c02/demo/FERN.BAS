100  LET YY(1) = .16
110  XX(2) =    .85:XY(2) = .04
120  YX(2) =  - .04:YY(2) = .85
130  LET Y(2) = 1.6
140  XX(3) = .20:XY(3) =  - .26
150  YX(3) = .23:YY(3) =    .22
160  LET Y(3) = 1.6
170  XX(4) =  - .15:XY(4) = .28
180  YX(4) =    .26:YY(4) = .24
190  LET Y(4) = .44
200  SCREEN 6
220  LET X = 0:Y = 0
230  FOR I = 1 TO 100000
240      R = INT(RND(0) * 100)
250      F = ((R < 7 AND 1)) + ((R < 14 AND 1)) + 2
260      F = F - ((R = 99) AND 1)
270      X = XX(F) * X + XY(F) * Y
280      Y = YX(F) * X + YY(F) * Y
290      Y = Y + Y(F)
300      X1 = 62 + X * 27.9
320      Y1 = 192 - Y * 19.1
325      P=POINT(X1*2+1,Y1)
326      C=P+(P < 5 AND 1) OR 2
330      PLOT X1 * 2 + 1,Y1,C
335      REM PRINT R, X1 * 2 + 1,Y1,255
340  NEXT
350 GET A$ : IF A$ = "" THEN 350
360 SCREEN 1
