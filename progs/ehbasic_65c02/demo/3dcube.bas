10 screen 7
15 scnclr

20 pt=-10
30 raw = 0
40 radius = 64
50 px = 120
60 py = 100
62 grb=255

70 dim tx$(8)
80 dim ty$(8)
90 dim bx$(8)
100 dim by$(8)

200 yoffs=cos(pt)*(sqr(radius*radius<<1)>>1)
201 yrotate=radius*sin(pt)

205 yp=yoffs+py
206 yn=-(yoffs<<1)

210 tx(o)=sin(yaw)*radius+px
212 ty(o)=cos(yaw)*yrotate+yp
214 tx(o+1)=sin(yaw+1.5708)*radius+px
216 ty(o+1)=cos(yaw+1.5708)*yrotate+yp
218 tx(o+2)=sin(yaw+3.14159)*radius+px
220 ty(o+2)=cos(yaw+3.14159)*yrotate+yp
222 tx(o+3)=sin(yaw+4.71239)*radius+px
224 ty(o+3)=cos(yaw+4.71239)*yrotate+yp

230 bx(o)=tx(o)
232 by(o)=ty(o)+yn
234 bx(o+1)=tx(o+1)
236 by(o+1)=ty(o+1)+yn
238 bx(o+2)=tx(o+2)
240 by(o+2)=ty(o+2)+yn
242 bx(o+3)=tx(o+3)
244 by(o+3)=ty(o+3)+yn

250 c=0
251 o=4-o
252 SCNWAIT
253 gosub 300
255 c=grb
256 o=4-o
258 gosub 300
260 o=4-o
262 yaw=yaw+0.1
263 pt=pt+0.01
264 get a$
266 if a$ = "" then 200

280 screen 0
281 end

300 line tx(o), ty(o), tx(o+1), ty(o+1), c
301 line tx(o+1), ty(o+1), tx(o+2), ty(o+2), c
302 line tx(o+2), ty(o+2), tx(o+3), ty(o+3), c
303 line tx(o+3), ty(o+3), tx(o), ty(o), c
310 line bx(o), by(o), bx(o+1), by(o+1), c
311 line bx(o+1), by(o+1), bx(o+2), by(o+2), c
312 line bx(o+2), by(o+2), bx(o+3), by(o+3), c
313 line bx(o+3), by(o+3), bx(o), by(o), c
314 line tx(o), ty(o), bx(o), by(o), c
315 line tx(o+1), ty(o+1), bx(o+1), by(o+1), c
316 line tx(o+2), ty(o+2), bx(o+2), by(o+2), c
317 line tx(o+3), ty(o+3), bx(o+3), by(o+3), c
320 return
