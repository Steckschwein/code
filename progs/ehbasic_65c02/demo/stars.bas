10 rem starfield
15 screen 7
20 dim x(100),y(100):a=rnd(1)
25 xc=128:yc=106:n=16:v=1/8
30 for i=1 to n:gosub200:next
40 for i=1 to n
55 plot x(i),y(i),0
60 dx=x(i)-xc:dy=y(i)-yc
62 c=(abs(dx)>>5)*73 or ((abs(dy)>>5)+1)*73 or 73
65 x1=x(i)+v*dx+x0:y1=y(i)+v*dy+y0
67 x2=abs(x1-x(i)):y2=abs(y1-y(i)):if (x2+y2<3*abs(v)) then gosub 200:goto 60
70 if (x1<0) or (y1<0) or (x1>255) or (y1>211) then gosub 200:dx=0:dy=0:goto65
75 plot x1,y1,c and 255
76 x(i)=x1:y(i)=y1
80 next
90 get a$
100 if a$="h" then x0=x0-3:goto 40
110 if a$="j" then x0=x0+3:goto 40
120 if a$="u" then y0=y0-3:goto 40
130 if a$="n" then y0=y0+3:goto 40
133 if a$="a" then v=v+1/32
135 if a$="s" then v=v-1/32
140 if a$<>"q" then 40
150 screen 0:end
200 x(i)=216*rnd(0)+20:y(i)=182*rnd(0)+15:return

rem 111 111 11
rem 110 110 11
rem 100 100 10
rem 010 010 01  $49