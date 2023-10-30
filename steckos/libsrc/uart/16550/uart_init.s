       .export uart_init

       .include "uart.inc"
       .include "nvram.inc"
       .importzp __volatile_ptr
.code
;----------------------------------------------------------------------------------------------
; init UART
;  in: .A/.Y - pointer to parameter structure
;----------------------------------------------------------------------------------------------
uart_init:
      pha
      phy
      sta __volatile_ptr   ; TODO FIXME dedicate pointers for uart ?!? => check zeropage.s
      sty __volatile_ptr+1

      lda #lcr_DLAB
      sta uart1+uart_lcr

      ldy #nvram::uart_baudrate
      lda (__volatile_ptr),y
      sta uart1+uart_dll

      stz uart1+uart_dlh ; dlh always 0, we do not support baudrates < 600

      ldy #nvram::uart_lsr
      lda (__volatile_ptr),y
      sta uart1+uart_lcr

      ; Enable FIFO, reset tx/rx FIFO
      lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
      sta uart1+uart_fcr

      stz uart1+uart_ier    ; polled mode (so far)
      lda #1<<uart_mcr_out1 ; reset DTR, RTS, disable joystick
      sta uart1+uart_mcr

      ply
      pla

      rts
