.autoimport
.segment "JUMPTABLE"    ; "kernel" jumptable
;@module: jumptable

; basic kernel stuff
;@name: krn_getkey
;@out: A, "fetched key"
;@out:  C, "1 - key was fetched, 0 - nothing fetched"
;@desc: "get byte from keyboard buffer"
.export krn_getkey
krn_getkey:             jmp getkey

;@name: krn_chrout
;@in: A, "character to output"
;@desc: "output character"
.export krn_chrout
krn_chrout:             jmp char_out

;@name: krn_upload
;@desc: "jump to kernel XMODEM upload"
.export krn_upload
krn_upload:             jmp do_upload
;@name: krn_execv
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@out: A error code on error
;out:  C=1 on error 
;@desc: "load PRG file at path and execute it"
.export krn_execv
krn_execv:              jmp execv

; filesystem stuff
.export krn_open
krn_open:               jmp fat_open      ; file open, regardless of file/dir
.export krn_fopen
krn_fopen:              jmp fat_fopen     ; file open (not directory)
.export krn_opendir
krn_opendir:            jmp fat_opendir   ; open directory
.export krn_chdir
krn_chdir:              jmp fat_chdir
.export krn_unlink
krn_unlink:             jmp fat_unlink
.export krn_rmdir
krn_rmdir:              jmp fat_rmdir
.export krn_mkdir
krn_mkdir:              jmp fat_mkdir
.export krn_close
krn_close:              jmp fat_close
.export krn_close_all
krn_close_all:          jmp fat_close_all
.export krn_fread_byte
krn_fread_byte:         jmp fat_fread_byte
.export krn_write_byte
krn_write_byte:         jmp fat_write_byte
.export krn_fseek
krn_fseek:              jmp fat_fseek
.export krn_getcwd
krn_getcwd:             jmp fat_get_root_and_pwd
.export krn_readdir
krn_readdir:            jmp fat_readdir
.export krn_read_direntry
krn_read_direntry:      jmp fat_read_direntry
.export krn_update_direntry
krn_update_direntry:    jmp fat_update_direntry

; display stuff
.export krn_textui_init
krn_textui_init:        jmp  textui_init
.export krn_textui_enable
krn_textui_enable:      jmp  textui_enable
.export krn_textui_disable
krn_textui_disable:     jmp textui_disable
.export krn_textui_update_crs_ptr
krn_textui_update_crs_ptr:  jmp textui_update_crs_ptr
.export krn_textui_setmode
krn_textui_setmode:     jmp textui_setmode
.export krn_textui_crs_onoff
krn_textui_crs_onoff:   jmp textui_cursor_onoff


; sd card stuff
.export krn_sd_write_block
krn_sd_write_block:     jmp sd_write_block
.export krn_sd_read_block
krn_sd_read_block:      jmp sd_read_block

; spi stuff
;@name: krn_spi_select_device
;@in; A, "spi device, one of devices see spi.inc"
;@out: Z = 1 spi for given device could be selected (not busy), Z=0 otherwise
;@desc: select spi device given in A. the method is aware of the current processor state, especially the interrupt flag

.export krn_spi_select_device
krn_spi_select_device:  jmp spi_select_device
;@name: "krn_spi_deselect"
;@desc: "deselect all SPI devices"
.export krn_spi_deselect
krn_spi_deselect:       jmp spi_deselect
;@name: "spi_rw_byte"
;@in: A, "byte to transmit"
;@out: A, "received byte"
;@clobbers: A,X,Y
;@desc: "transmit byte via SPI"
.export krn_spi_rw_byte
krn_spi_rw_byte:        jmp spi_rw_byte
;@name: "spi_r_byte"
;@out: A, "received byte"
;@clobbers: A,X
;@desc: "read byte via SPI"
.export krn_spi_r_byte
krn_spi_r_byte:         jmp spi_r_byte

; serial stuff
;@name: "uart_tx"
;@in: A, "byte to send"
;@desc: "send byte via serial interface"
.export krn_uart_tx
krn_uart_tx:            jmp uart_tx
;@name: "uart_rx"
;@out: A, "received byte"
;@desc: "receive byte via serial interface"
.export krn_uart_rx
krn_uart_rx:            jmp uart_rx
