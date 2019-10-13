.include "uart.inc"
.export uart_rx_nowait
;----------------------------------------------------------------------------------------------
; receive byte, no wait, set carry and store in A when received
;----------------------------------------------------------------------------------------------
uart_rx_nowait:
		  lda #lsr_DR
		  bit uart1+uart_lsr
		  beq @l
		  lda uart1+uart_rxtx
		  sec
		  rts
@l:
		  clc
		  rts
