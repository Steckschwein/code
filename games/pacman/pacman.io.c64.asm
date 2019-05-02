;i/o
      .export io_init
      .export io_detect_joystick
      .export io_joystick_read
      
        
io_init:
      rts
      
io_detect_joystick:
      lda #2
      rts

io_joystick_read:
      rts
      