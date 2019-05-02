;i/o
      .include "joystick.inc"
      .include "keyboard.inc"

      .export io_init
      .export io_detect_joystick
      .export io_joystick_read
      
        
      .import joystick_on
      .import joystick_detect
      .import joystick_read
              

io_init:
      jsr joystick_on
      ;TODO ...
      rts
      
io_detect_joystick:
      jsr joystick_detect
      beq @rts
      sta joystick_port
@rts: rts

io_joystick_read:
        lda joystick_port
        jmp joystick_read

.data
      joystick_port:  .res 1, JOY_PORT2
      