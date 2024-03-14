.include "uart.inc"
.export uart_rx_nowait
;@module: uart
;----------------------------------------------------------------------------------------------
; receive byte, no wait, set carry and store in A when received
;----------------------------------------------------------------------------------------------
;@name: "uart_rx_nowait"
;@out: A, "received byte"
;@out: C, "0 - no byte received, 1 - received byte"
;@desc: "receive byte, no wait"
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
