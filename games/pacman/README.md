
TODO:
  - fix pacman can turn if stopped on wall
  - "cruise elroy" 1 / 2
  - per ghost dot cnt logic
  - intermission after level 2 (im1), 5 (im2), 9,13,17 (im3)
  - use fn pointer for game loop


pacman/ghost speed percentage/frames
  LEVEL      NORM  NORM-DOTS  FRIGHT  FRIGHT-DOTS   NORM   FRIGHT	 TUNNEL
  1           80%	      71%   90%/54	    79%     75%/45      50%  	  40%
  2 - 4    90%/54	      79%   95%/57	    83%     85%/51      55%	    45%
  5 - 20	100%/60	      87%  100%/60      87%     95%/57      60%	    50%
  21+	     90%/54	      79%     -	         -      95%/57       -	    50%

100% => 75,75757625 px/s +1px/4
 95% => 72px/s +1px/5
 90% => 68px/s +1px/7
 85% => 64px/s +1px/15
 80% => 60px/s 0
 75% => 57px/s -1px/20
 60% => 45px/s -1px/4
 55% => 42px/s -1px/3
 50% => 38px/s -1px/2
 45% => 34px/s -1px/2
 40% => 30px/s -1px/2

----

notes:
  solve: https://www.youtube.com/watch?v=Bin0vu8Hp0g
  intermission: https://www.youtube.com/watch?v=v8BT43ZWSTY


---------------------------------------------------
| pacman (6510)                                    |
----------------------------------------------------
| pacman.game (6510)                               |
----------------------------------------------------
| pacman.gfx.sts (65c02)  | pacman.gfx.c64 (6510)  |
| pacman.sound.sts        | pacman.sound.c64       |
--------------------------| pacman.hw.c64 (6510)   |
| steckschwein.lib        |                        |
---------------------------------------------------

video:
  - mode 4 (V9938/58) with NTSC (60Hz) and open border hack (overscan)
  - original paxman, namco May 22nd, 1980
    - 224x288 => 28x36 => 28x31 -5 (score)    => 1px 196x252

  - steckschwein
    - 256x212(240) overscan => vert. display 240x256 => 30x32 :/ +2/-4
      - rotate the game entirely 90 degree counter clockwise, screen must be turned 90 degree clockwise ;)
      -4 chars x - rm blank lines -2, rm credit line -1, shrink score line -1
      +2 chars y - lives, bonus on right border

      ;1101 0100 11 01 00 111
      ;1010      11
      ;


                $08  $09  $0a  $0b  $0c  $0d  $0e  $0f
               1000 1001 1010 1011 1100 1101 1110 1111
      11 00 =>  pt                   c    bt
      11 01 =>  pt                   c    bt
            eor 111
      10 00 =>  bt              c    pt
      10 01 =>  bt              c    pt
                              1100 1011 1010 1001 1000

                $07  $06  $05  $04  $03  $02
               0111 0110 0101 0100 0011 0010
      01 10 =>
      01 11
      00 10 =>  pt   pt              c
      00 11 =>  pt



;pacman cornering
  left > right
  12,16  20,24 02 03
  ------------------
  12,15  20,23 02 02
  12,14  20,22 02 02
  12,13  20,21 02 02
  12,12  20,20 02 02                  l>r         r>l
  12,11  20,19 02 02  c       10011   011 eor 111 100
  12,10  20,18 02 02  bt      10010   010 eor 111 101
  12,09  20,17 02 02  bt      10001   001 eor 111 110
  12,08  20,16 02 02  bt      10000   000 eor 111 111
  ------------------
  12,07  20,15 02 01  pt      01111   111 eor 111 000
  12,06  20,14 02 01  pt      01110   110 ..      001
  12,05  20,13 02 01  pt      01101   101         010
  12,04  20,12 02 01  pt      01100   100         011 <=3 pre-turn
  12,03  20,11 02 01  c       01011   011 ...     100
  12,02  20,10 02 01          01010   010         101

  bit 2-0 turn?
  bit 3   center?

  right > left
  12,04  20,12 02 01  c       01100
  12,05  20,13 02 01  bt      01101
  12,06  20,14 02 01  bt      01110
  12,07  20,15 02 01  bt      01111
  ------------------
  12,08  20,16 02 02  pt      10000
  12,09  20,17 02 02  pt      10001
  12,10  20,18 02 02  pt      10010
  12,11  20,19 02 02  pt      10011
  12,12  20,20 02 02  c       10100
  12,13  20,21 02 02  bt      10101
  12,14  20,22 02 02  bt      10110
  12,15  20,23 02 02  bt      10111
  ------------------
  12,16  20,24 02 03  pt      11000


; color palette
; 0,0,0
; red ff,0,0   => "shadow" "blinky" (red)
; de,97,51
; ff,b8,ff     => "speedy", "pinky" ()
; 0,0,0
; 0,ff,ff      => "bashful"/"inky" (cyan)
; 47,b8,ff  =>
; ff,b8,51  255,184,81, => "pokey" "clyde" (orange)
; 0,0,0
; ff,ff,0   => yellow
; 0,0,0
; 21,21,ff  => blue => ghosts "scared"
; 0,ff,0    => green
; 47,b8,ae  =>        (71,184,174)
; ff,b8,ae  => "food" (255,184,174)
; de,de,ff  => gray => ghosts "scared"

; ghosts:
  -  By level 19, the ghosts stop turning blue altogether and can no longer be eaten for additional points.

; scoring
  - perfect score of 3,333,360 at Pac-Man,
  -  all four ghosts are captured at all four energizers => additional 12,000

  per level
    228 food      x 10                    2280
      4 superfood x 50                     200
    200           x 4 (per super food)     800
    400                                   1600
    600                                   2400
   1000                                   4000
   ~ 10.000 x 256 = 2.560.000


original maze 224x288px 28x36

 0123456789012345678901234567
0  1UP   HIGH SCORE
1    00
2
3############################
4#            ##            #
5# #### ##### ## ##### #### #
6# #  # #   # ## #   # #  # #
7# #### ##### ## ##### #### #
8#                          #
9# #### ## ######## ## #### #
0# #### ## ######## ## #### #
1#      ##    ##    ##      #
2###### ##### ## ##### ######
3     # ##### ## ##### #
4     # ##          ## #
5     # ## ######## ## #
6###### ## #      # ## ######
7          #      #
8###### ## #      # ## ######
9     # ## ######## ## #
0     # ##          ## #
1     # ## ######## ## #
2###### ## ######## ## ######
3#            ##            #
4# #### ##### ## ##### #### #
5# #### ##### ## ##### #### #
6#   ##                ##   #
7### ## ## ######## ## ## ###
8### ## ## ######## ## ## ###
9#      ##    ##    ##      #
0# ########## ## ########## #
1# ########## ## ########## #
2#                          #
3############################
4
5 # # # lives     # # # bonus

steckschwein maze adaption

 01234567890123456789012345   28x32
0  1UP   HIGH SCORE
1##########################
2#           ##           #
3# ### ##### ## ##### ### #
4# # # #   # ## #   # # # #
5# ### ##### ## ##### ### #
6#                        #
7# ### ## ######## ## ### #
8# ### ## ######## ## ### #
9#     ##    ##    ##     #
0##### ##### ## ##### #####
1    # ##### ## ##### #
2    # ##          ## #
3    # ## ######## ## #
4##### ## #      # ## #####
5         #      #
6##### ## #      # ## #####
7    # ## ######## ## #
8    # ##          ## #
9    # ## ######## ## #
0##### ## ######## ## #####
1#           ##           #
2# ### ##### ## ##### ### #
3# ### ##### ## ##### ### #
4#  ##                ##  #
5## ## ## ######## ## ## ##
6## ## ## ######## ## ## ##
7#     ##    ##    ##     #
8# ######### ## ######### #
9# ######### ## ######### #
0#                        #
1##########################
