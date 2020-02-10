    .export upload

    .import uart_rx, uart_tx
    .import vdp_chrout, print_crlf, hexout, primm

    .include "bios.inc"
    .include "uart.inc"
.zeropage
ptr_upload_addr:  .res 2
.code
;----------------------------------------------------------------------------------------------
upload:
		print "Serial upload.."
		; load start address
		jsr uart_rx
      sta startaddr
      jsr uart_rx
      sta startaddr+1

		jsr hexout
		lda startaddr
		jsr hexout

		lda #' '
		jsr vdp_chrout

		jsr upload_ok

		; load number of bytes to be uploaded
		jsr uart_rx
		sta length

		jsr uart_rx
		sta length+1

		; calculate end address
		clc
		lda length
		adc startaddr
		sta endaddr

		lda length+1
		adc startaddr+1
		sta endaddr+1

		jsr hexout
		lda endaddr
		jsr hexout

		lda #' '
		jsr vdp_chrout

        lda startaddr
		sta ptr_upload_addr
		lda startaddr+1
		sta ptr_upload_addr+1

		jsr upload_ok

		ldy #0
@l1:
		jsr uart_rx
		sta (ptr_upload_addr),y

		iny
		bne @l2
		inc ptr_upload_addr+1
@l2:
		; msb of current address equals msb of end address?
		lda ptr_upload_addr+1
		cmp endaddr+1
		bne @l1 ; no? read next byte

		; yes? compare y to lsb of endaddr
		cpy endaddr
		bne @l1 ; no? read next byte

		; yes? write OK
		jsr upload_ok

		print "OK"
		rts

upload_ok:
		lda #'O'
		jsr uart_tx
		lda #'K'
		jmp uart_tx
