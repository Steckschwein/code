.autoimport
.segment "JUMPTABLE"    ; "kernel" jumptable

.export krn_rmdir
krn_rmdir:              jmp fat_rmdir
.export krn_mkdir
krn_mkdir:              jmp fat_mkdir
.export krn_execv
krn_execv:              jmp execv

.export krn_uart_rx_nowait
krn_uart_rx_nowait:        jmp uart_rx_nowait

.export krn_mount
krn_mount:                jmp fat_mount

.export krn_open
krn_open:            jmp fat_fopen

.export krn_chdir
krn_chdir:            jmp fat_chdir

.export krn_unlink
krn_unlink:         jmp fat_unlink

.export krn_close
krn_close:            jmp fat_close
.export krn_close_all
krn_close_all:          jmp fat_close_all

.export krn_read
krn_read:            jmp fat_read

.export krn_fread
krn_fread:             jmp fat_fread

.export krn_find_first
krn_find_first:        jmp fat_find_first
.export krn_find_next
krn_find_next:          jmp fat_find_next
.export krn_textui_init
krn_textui_init:        jmp  textui_init
.export krn_textui_enable
krn_textui_enable:      jmp  textui_enable
.export krn_textui_disable
krn_textui_disable:      jmp textui_disable      ;disable textui

.export krn_display_off
krn_display_off:        jmp vdp_display_off

.export krn_getkey
krn_getkey:            jmp getkey

.export krn_chrout
krn_chrout:            jmp textui_chrout
.export krn_putchar
krn_putchar:          jmp textui_put

.export krn_strout
krn_strout:            jmp strout

.export krn_textui_crsxy
krn_textui_crsxy:        jmp textui_crsxy

.export krn_textui_update_crs_ptr
krn_textui_update_crs_ptr:  jmp textui_update_crs_ptr

.export krn_textui_clrscr_ptr
krn_textui_clrscr_ptr:    jmp textui_blank

;.export krn_fseek
;krn_fseek:            jmp fat_fseek
.export krn_textui_setmode
krn_textui_setmode:    jmp textui_setmode

.export krn_textui_crs_onoff
krn_textui_crs_onoff:  jmp textui_cursor_onoff

.export krn_init_sdcard
krn_init_sdcard:    jmp sdcard_init

.export krn_upload
krn_upload:        jmp do_upload

; .export krn_spi_select_rtc
krn_spi_select_rtc:    .res 3

.export krn_spi_deselect
krn_spi_deselect:     jmp spi_deselect

.export krn_spi_rw_byte
krn_spi_rw_byte:    jmp spi_rw_byte

.export krn_spi_r_byte
krn_spi_r_byte:      jmp spi_r_byte

.export krn_uart_tx
krn_uart_tx:      jmp uart_tx

.export krn_uart_rx
krn_uart_rx:      jmp uart_rx

.export krn_primm
krn_primm:        jmp primm

.export krn_getcwd
krn_getcwd:        jmp fat_get_root_and_pwd

.export krn_spi_select_device
krn_spi_select_device:    jmp spi_select_device

.export krn_write
krn_write:       jmp fat_write

.export krn_sd_write_block
krn_sd_write_block:     jmp sd_write_block

.export krn_sd_read_block
krn_sd_read_block:     jmp sd_read_block

.export krn_fread_byte
krn_fread_byte:         jmp fat_fread_byte

;.import uart_rx_nowait
;.export krn_uart_rx_nowait
;krn_uart_rx_nowait:     jmp uart_rx_nowait
