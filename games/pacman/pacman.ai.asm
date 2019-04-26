

    .include "pacman.inc"
    
    .export ai_blinky
    .export ai_inky
    .export ai_pinky
    .export ai_clyde
    
.code
  
    
  ;  short distance, same distance => order: up, left, down, right.

ai_ghost:
      
ai_blinky:
      tya
      tax
;      lda 
      rts
      
ai_inky:
ai_pinky:
ai_clyde:
      rts

.data
