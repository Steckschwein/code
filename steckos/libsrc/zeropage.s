;
; zeropage usage

.include		  "zeropage.inc"

; ------------------------------------------------------------------------
.zeropage

; defined by linker upon zp config within used linker config file
;
ptr1:			  .res 2
ptr2:			  .res 2
ptr3:			  .res 2
ptr4:			  .res 2
ptr5:			  .res 2
; ptr6:			  .res 2
tmp1:			  .res 1
tmp2:			  .res 1
tmp3:			  .res 1
tmp4:			  .res 1
;spi_sr:           .res 1
tmp:           .res 1

;zp_end = *

; shell related - TODO FIXME away from kernel stuff, conflicts with basic. but after basic start, we dont care about shell zp. maybe if we want to return to shell one day !!!
.exportzp cmdptr    = $d6
.exportzp paramptr  = $d8
.exportzp retvec    = $da

; TEXTUI
.exportzp crs_ptr   = $e0

; kernel pointer (internally used)
.exportzp krn_ptr1	= $e2	; 2 bytes
.exportzp krn_ptr2	= $e4	; 2 bytes
.exportzp krn_ptr3	= $e6	; 2 bytes

.exportzp krn_tmp	= $e8
.exportzp krn_tmp2	= krn_tmp+1	; single byte
.exportzp krn_tmp3	= krn_tmp+2	; single byte

; have to use fixed zp locations to avoid ehbasic clashes
.exportzp vdp_ptr   :=$ec
.exportzp vdp_tmp   :=$ee

; FAT32
.exportzp filenameptr   = $f0	; 2 byte
.exportzp dirptr		= $f2	; 2 byte

; SDCARD/storage block pointer
.exportzp read_blkptr  	= $f4
.exportzp write_blkptr 	= $f6
.exportzp sd_tmp		= $f8

; spi shift register location
.exportzp spi_sr        = $f9
;.exportzp ansi_state			 = $f9
;.exportzp ansi_index			 = $fa
;.exportzp ansi_param1			= $fb
;.exportzp ansi_param2			= $fc
