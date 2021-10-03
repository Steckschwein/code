
10 screen 7
15 scnclr

20 pt=-10
30 raw = 0
40 radius = 32
50 px = 120
60 py = 100
62 grb=255
63 c=grb
64 o=0
70 dim tx$(8)
80 dim ty$(8)
90 dim bx$(8)
100 dim by$(8)

200 yoffs=cos(pt)*sqr(radius*radius*2)/2
201 yrotate=radius*sin(pt)

202 tx(o+0)=sin(yaw+0)*radius+px
203 ty(o+0)=cos(yaw+0)*yrotate+yoffs+py
204 tx(o+1)=sin(yaw+1.5708)*radius+px
205 ty(o+1)=cos(yaw+1.5708)*yrotate+yoffs+py
206 tx(o+2)=sin(yaw+3.14159)*radius+px
207 ty(o+2)=cos(yaw+3.14159)*yrotate+yoffs+py
208 tx(o+3)=sin(yaw+4.71239)*radius+px
209 ty(o+3)=cos(yaw+4.71239)*yrotate+yoffs+py

210 bx(o+0)=sin(yaw+0)*radius+px
211 by(o+0)=cos(yaw+0)*yrotate-yoffs+py
212 bx(o+1)=sin(yaw+1.5708)*radius+px
213 by(o+1)=cos(yaw+1.5708)*yrotate-yoffs+py
214 bx(o+2)=sin(yaw+3.14159)*radius+px
215 by(o+2)=cos(yaw+3.14159)*yrotate-yoffs+py
216 bx(o+3)=sin(yaw+4.71239)*radius+px
217 by(o+3)=cos(yaw+4.71239)*yrotate-yoffs+py

220 o=4-o
221 c=grb-c
223 gosub 300
225 c=grb-c
226 o=4-o
228 gosub 300
230 o=4-o
232 yaw=yaw+0.1
233 pt=pt+0.01
234 get a$
236 if a$ = "" then 200

250 screen 0
251 end

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

400 line tx(4), ty(4), tx(5), ty(5), c
401 line tx(5), ty(5), tx(6), ty(6), c
402 line tx(6), ty(6), tx(7), ty(7), c
403 line tx(7), ty(7), tx(4), ty(4), c
410 line bx(4), by(4), bx(5), by(5), c
411 line bx(5), by(5), bx(6), by(6), c
412 line bx(6), by(6), bx(7), by(7), c
413 line bx(7), by(7), bx(4), by(4), c
414 line tx(4), ty(4), bx(4), by(4), c
415 line tx(5), ty(5), bx(5), by(5), c
416 line tx(6), ty(6), bx(6), by(6), c
417 line tx(7), ty(7), bx(7), by(7), c
420 return
