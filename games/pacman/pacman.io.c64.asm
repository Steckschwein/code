;i/o
      .include "pacman.c64.inc"

      .export io_init
      .export io_detect_joystick
      .export io_joystick_read
      .export io_player_direction
      .export io_getkey
      .export io_irq
      .export io_irq_on
      .export io_exit
      
.code
io_init:
      rts

io_irq_on:
      lda #LORAM | IOEN ;disable kernel rom to setup irq
      sta $01           ;PLA
      
      lda #250                           ;Bei STARTBLACK soll ein
      sta VIC_HLINE                      ;Raster-IRQ ausgelöst werden

      lda VIC_CTRL1                      
      and #%01111111                     
      sta VIC_CTRL1                      

      lda VIC_IMR                        
      ora #%00000001                     
      sta VIC_IMR
      rts
      
io_exit:
      rts
      
io_irq:
      lda VIC_IRR
      bpl @rts
      sta VIC_IRR
      lda #$80    ;
      rts
@rts: lda $dc0d
      rts
      
io_player_direction:
      rts
      
io_getkey:
      ;map c64 keys to ascii
      
      rts
      
io_detect_joystick:
      lda #2
      rts

io_joystick_read:
      rts
      