; MIT License
;
; Copyright (c) 2018 Thomas Woinke, Marko Lauke, www.steckschwein.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.ifndef __UART_INC
.define	__UART_INC "__UART_INC"

; UART address and registers
uart1			  = $0200
uart_rxtx		 = 0
uart_ier		 = 0
uart_dll		 = 0
uart_dlh		 = 1
uart_iir		 = 2
uart_fcr		 = 2
uart_lcr		 = 3
uart_mcr		 = 4
uart_lsr		 = 5
uart_msr		 = 6
uart_scr		 = 7

uart_mcr_out1 = 1<<2

; Register bits
; interrupt enable register
ier_ERBI		  = 1<<0 ; Enable received data available
ier_ETBEI		 = 1<<1 ; Enable transmitter holding register empty
ier_ELSI		  = 1<<2 ; Enable line receiver line status
ier_EDSSI		 = 1<<3 ; Enable modem status interrupt

; interrupt ident. register
iir_ERBI		  = 1<<0 ; 0 if enable received data available interrupt pending
iir_ETBEI		 = 1<<1 ; Enable transmitter holding register empty
iir_ELSI		  = 1<<2 ; Enable line receiver line status
iir_EDSSI		 = 1<<3 ; Enable modem status interrupt

; FIFO control register
fcr_FIFO_enable			= 1<<0 ; FIFO enable
fcr_reset_receiver_FIFO = 1<<1 ; reset receiver FIFO
fcr_reset_transmit_FIFO = 1<<2 ; reset transmitter FIFO
fcr_select_DMA			 = 1<<3 ; DMA mode select
fcr_receiver_trigger_LSB = 1<<6 ; Receiver trigger (LSB)
fcr_receiver_trigger_MSB = 1<<7 ; Receiver trigger (MSB)

; line control register
lcr_WLS0		  = 1<<0 ; word length select bit 0
lcr_WLS1		  = 1<<1 ; word length select bit 1
lcr_STB			= 1<<2 ; number of stop bits
lcr_PEN			= 1<<3 ; parity enable
lcr_EPS			= 1<<4 ; even parity select
lcr_SP			 = 1<<5 ; stick parity
lcr_BC			 = 1<<6 ; break control
lcr_DLAB		  = 1<<7 ; divisor latch access

; modem control register
mcr_DTR			= 1<<0 ; data terminal ready
mcr_RTS			= 1<<1 ; request to send
mcr_OUT1		  = 1<<2 ; OUT1
mcr_OUT2		  = 1<<3 ; OUT2
mcr_LOOP		  = 1<<4 ; Loopback mode

; line status register
lsr_DR			 = 1<<0 ; data ready
lsr_OE			 = 1<<1 ; overrun error
lsr_PE			 = 1<<2 ; parity error
lsr_FE			 = 1<<3 ; framing error
lsr_BI			 = 1<<4 ; break interrupt
lsr_THRE		  = 1<<5 ; transmitter holding register
lsr_TEMT		  = 1<<6 ; transmitter empty
lsr_ERCVR		 = 1<<7 ; Error in RCVR FIFO

; modem status register
msr_dCTS		  = 1<<0 ; delta clear to send
msr_dDSR		  = 1<<1 ; delta data set ready
msr_TERI		  = 1<<2 ; trainling edge ring indicator
msr_dDCD		  = 1<<3 ; delta data carrier detect
msr_CTS			= 1<<4 ; clear to send
msr_DSR			= 1<<5 ; data set ready
msr_RI			 = 1<<6 ; ring indicator
msr_DCD			= 1<<7 ; data carrier detect

.struct uart_init
	 div  .word ;$0d ; 2  bytes  - baudrate divisor value
	 lsr  .byte ;$0f ; 1  byte  - uart lcr value , default %00000011 (8N1)
.endstruct

.endif
