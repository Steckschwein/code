;i/o
      .export io_init
      .export io_detect_joystick
      .export io_joystick_read
      .export io_player_direction
      .export io_getkey
      .export io_irq
      .export io_exit
      
.code
io_init:
      rts

io_exit:
      rts
      
io_irq:
      lda #$80
      
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
      