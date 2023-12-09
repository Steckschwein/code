.include "uart.inc"
.export uart_rx_nowait
.export uart_getkey
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

uart_getkey:
		jsr uart_rx_nowait
		beq exit 
		sec 
		rts
exit:
    clc
    rts