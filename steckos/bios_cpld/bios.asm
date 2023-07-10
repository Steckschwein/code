.include "bios.inc"

.import xmodem_upload
.import crc16_table_init

.export crc16_lo=BUFFER_0
.export crc16_hi=BUFFER_1
.export crc16_init=crc16_table_init
.export xmodem_rcvbuffer=BUFFER_2
.export xmodem_startaddress=startaddr

.export uart_tx,uart_rx_nowait
.export char_out ;=uart_tx

uart_cpb = $0200
;uart_cpb = uart1
startaddr = $0380

.code
do_reset:
		; disable interrupt
		sei

		; clear decimal flag
		cld

		; init stack pointer
		ldx #$ff
		txs

;		lda ctrl_port
;		ora #%11111000
;		sta ctrl_port

		jsr uart_init

		jsr xmodem_upload

		ldx #$ff
		txs
		jmp (startaddr)

@loop:
        ldx #'0'
@lx:
		txa
		jsr uart_tx
    inx
    cpx #'9'+1
    bne @lx

		bra	@loop

uart_tx:
		pha
		lda #lsr_THRE
@l0:
		bit uart_cpb+uart_lsr
		beq @l0

		pla
    sta uart_cpb+uart_rxtx
		rts

uart_init:
    lda #lcr_DLAB
    sta uart_cpb+uart_lcr

    lda #$01 ;115200
    sta uart_cpb+uart_dll
    stz uart_cpb+uart_dlh ; dlh always 0, we do not support baudrates < 600
    lda #$03 ;8N1
    sta uart_cpb+uart_lcr

		lda #fcr_FIFO_enable | fcr_reset_receiver_FIFO | fcr_reset_transmit_FIFO
		sta uart_cpb+uart_fcr
		stz uart_cpb+uart_ier	; polled mode (so far)
		stz uart_cpb+uart_mcr	; reset DTR, RTS
		rts

uart_rx_nowait:
		lda #lsr_DR
		bit uart_cpb+uart_lsr
		beq @l
		lda uart_cpb+uart_rxtx
		sec
		rts
@l:
		clc
		rts

char_out:
		rts

bios_irq:
	    rti

.segment "VECTORS"
;----------------------------------------------------------------------------------------------
; Interrupt vectors
;----------------------------------------------------------------------------------------------
; $FFFA/$FFFB NMI Vector
.word bios_irq
; $FFFC/$FFFD reset vector
;*= $fffc
.word do_reset
; $FFFE/$FFFF IRQ vector
;*= $fffe
.word bios_irq
