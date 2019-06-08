          .export uart_init

          .include "uart.inc"
          .include "nvram.inc"
          .importzp ptr1
.code
;----------------------------------------------------------------------------------------------
; init UART
;   in: .A/.Y - pointer to parameter structure
;----------------------------------------------------------------------------------------------
uart_init:
        pha
        phy
        sta ptr1    ; TODO FIXME dedicate pointers for uart ?!? => check zeropage.s
        sty ptr1+1

        lda #lcr_DLAB
        sta uart1+uart_lcr

        ldy #nvram::uart_baudrate
        lda (ptr1),y
        sta uart1+uart_dll

        stz uart1+uart_dlh ; dlh always 0, we do not support baudrates < 600

        ldy #nvram::uart_lsr
        lda (ptr1),y
        sta uart1+uart_lcr

        ; Enable FIFO, reset tx/rx FIFO
        lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
        sta uart1+uart_fcr

        stz uart1+uart_ier	; polled mode (so far)
        stz uart1+uart_mcr	; reset DTR, RTS

        ply
        pla

        rts

