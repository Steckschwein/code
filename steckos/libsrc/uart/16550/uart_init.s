          .export uart_init

          .include "uart.inc"
          .importzp ptr1
.code
;----------------------------------------------------------------------------------------------
; init UART
;   in: .A/.Y - pointer to parameter structure
;----------------------------------------------------------------------------------------------
uart_init:
      sta ptr1    ; TODO FIXME dedicate pointers for uart ?!? => check zeropage.s
      sty ptr1+1
      
			lda #lcr_DLAB
			sta uart1+uart_lcr
      
			ldy #uart_init::div
			lda (ptr1),y
			sta uart1+uart_dll

			iny
			lda (ptr1),y
			sta uart1+uart_dlh

			ldy #uart_init::lsr
			lda (ptr1),y
			sta uart1+uart_lcr

      ; Enable FIFO, reset tx/rx FIFO
      lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
			sta uart1+uart_fcr

			stz uart1+uart_ier	; polled mode (so far)
			stz uart1+uart_mcr	; reset DTR, RTS

			rts
 