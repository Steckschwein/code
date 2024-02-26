.autoimport
.segment "JUMPTABLE"    ; "kernel" jumptable
;@module: kernel

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

;@module: filesystem
; filesystem stuff

;@name: "krn_open"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@in: Y, "file mode constants O_RDONLY = $01, O_WRONLY = $02, O_RDWR = $03, O_CREAT = $10, O_TRUNC = $20, O_APPEND = $40, O_EXCL = $80
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@out: X, "index into fd_area of the opened file"
;@desc: "open file regardless of file/dir"
.export krn_open
krn_open:               jmp fat_open      ; file open, regardless of file/dir

;@name: "krn_fopen"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@in: Y, "file mode constants O_RDONLY = $01, O_WRONLY = $02, O_RDWR = $03, O_CREAT = $10, O_TRUNC = $20, O_APPEND = $40, O_EXCL = $80
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@out: X, "index into fd_area of the opened file"
;@desc: "open file regardless of file/dir"
.export krn_fopen
krn_fopen:              jmp fat_fopen     ; file open (not directory)

;@name: "krn_opendir"
;@in: A/X - pointer to string with the file path
;@out: C, "C=0 on success (A=0), C=1 and A=<error code> otherwise"
;@out: X, "index into fd_area of the opened directory"
;@desc: "open directory by given path starting from directory given as file descriptor"
.export krn_opendir
krn_opendir:            jmp fat_opendir   ; open directory

;@name: "krn_chdir"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@out: C, "C=0 on success (A=0), C=1 and A=<error code> otherwise"
;@out: X, "index into fd_area of the opened directory (which is FD_INDEX_CURRENT_DIR)"
;@desc: "change current directory"
.export krn_chdir
krn_chdir:              jmp fat_chdir

;@name: "krn_unlink"
;@in: A, "low byte of pointer to zero terminated string with the file path"
;@in: X, "high byte of pointer to zero terminated string with the file path"
;@out: C, "C=0 on success (A=0), C=1 and A=<error code> otherwise"
;@desc: "unlink (delete) a file denoted by given path in A/X"
.export krn_unlink
krn_unlink:             jmp fat_unlink

;@name: "krn_rmdir"
;@in: A, "low byte of pointer to directory string"
;@in: X, "high byte of pointer to directory string"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "delete a directory entry denoted by given path in A/X"
.export krn_rmdir
krn_rmdir:              jmp fat_rmdir

;@name: "krn_mkdir"
;@in: A, "low byte of pointer to directory string"
;@in: X, "high byte of pointer to directory string"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "create directory denoted by given path in A/X"
.export krn_mkdir
krn_mkdir:              jmp fat_mkdir

;@name: "krn_close"
;@in: X, "index into fd_area of the opened file"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "close file, update dir entry and free file descriptor quietly"
.export krn_close
krn_close:              jmp fat_close

.export krn_close_all
krn_close_all:          jmp fat_close_all

;@name: "krn_fread_byte"
;@in: X, "offset into fd_area"
;@out: C=0 on success and A="received byte", C=1 on error and A="error code" or C=1 and A=0 (EOK) if EOF is reached
;@desc: "read byte from file"
.export krn_fread_byte
krn_fread_byte:         jmp fat_fread_byte

;@name: "krn_write_byte"
;@in: A, "byte to write"
;@in: X, "offset into fs area"
;@out: C, "0 on success, 1 on error"
;@desc: "write byte to file"
.export krn_write_byte
krn_write_byte:         jmp fat_write_byte

;@name: krn_fseek
;@desc: seek n bytes within file denoted by the given FD
;@in: X - offset into fd_area
;@in: A/Y - pointer to seek_struct - @see fat32.inc
;@out: C=0 on success (A=0), C=1 and A=<error code> or C=1 and A=0 (EOK) if EOF reached
.export krn_fseek
krn_fseek:              jmp fat_fseek

;@name: "krn_getcwd"
;@in: A, "low byte of address to write the current work directory string into"
;@in: Y, "high byte address to write the current work directory string into"
;@in: X, "size of result buffer pointet to by A/X"
;@out: C, "0 on success, 1 on error"
;@out: A, "error code"
;@desc: "get current directory"
.export krn_getcwd
krn_getcwd:             jmp fat_get_root_and_pwd

;@name: krn_readdir
;@desc: readdir expects a pointer in A/Y to store the next F32DirEntry structure representing the next FAT32 directory entry in the directory stream pointed of directory X.
;@in: X - file descriptor to fd_area of the directory
;@in: A/Y - pointer to target buffer which must be .sizeof(F32DirEntry)
;@out: C - C = 0 on success (A=0), C = 1 and A = <error code> otherwise. C=1/A=EOK if end of directory is reached
.export krn_readdir
krn_readdir:            jmp fat_readdir

;@name: krn_read_direntry
;@desc: readdir expects a pointer in A/Y to store the F32DirEntry structure representing the requested FAT32 directory entry for the given fd (X).
;@in: X - file descriptor to fd_area of the file
;@in: A/Y - pointer to target buffer which must be .sizeof(F32DirEntry)
;@out: C - C = 0 on success (A=0), C = 1 and A = <error code> otherwise. C=1/A=EOK if end of directory is reached
.export krn_read_direntry
krn_read_direntry:      jmp fat_read_direntry

;@name: fat_update_direntry
;@desc: update direntry given as pointer (A/Y) to FAT32 directory entry structure for file fd (X).
;@in: X - file descriptor to fd_area of the file
;@in: A/Y - pointer to direntry buffer with updated direntry data of type F32DirEntry
;@out: C - C = 0 on success (A=0), C = 1 and A = <error code> otherwise. C=1/A=EOK if end of directory is reached
.export krn_update_direntry
krn_update_direntry:    jmp fat_update_direntry

; display stuff
;@module: video

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

;@module: sdcard

;@name: "krn_sd_write_block"
;@in: lba_addr, "LBA address of block"
;@in: sd_blkptr, "target adress for the block data to be read"
;@out: A, "error code"
;@out: C, "0 - success, 1 - error"
;@clobbers: A,X,Y
;@desc: "Write block to SD Card"
.export krn_sd_write_block
krn_sd_write_block:     jmp sd_write_block
;@name: "krn_sd_read_block"
;@in: lba_addr, "LBA address of block"
;@in: sd_blkptr, "target adress for the block data to be read"
;@out: A, "error code"
;@out: C, "0 - success, 1 - error"
;@clobbers: A,X,Y
;@desc: "Read block from SD Card"
.export krn_sd_read_block
krn_sd_read_block:      jmp sd_read_block

; spi stuff
;@module: spi

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
