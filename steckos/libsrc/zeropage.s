
;
; zeropage usage

.include      "zeropage.inc"

; ------------------------------------------------------------------------
; shell related - TODO FIXME away from kernel stuff, conflicts with basic. but after basic start, we dont care about shell zp. maybe if we want to return to shell one day !!!
.exportzp cmdptr    = location_cmdptr
.exportzp paramptr  = location_paramptr

; have to use fixed zp locations to avoid ehbasic clashes
.exportzp vdp_ptr   = location_vdp_ptr
.exportzp vdp_tmp   = location_vdp_tmp


; FAT32
.exportzp filenameptr   = location_filenameptr  ; 2 byte
.exportzp dirptr        = location_dirptr       ; 2 byte

; SDCARD/storage block pointer
.exportzp sd_blkptr    = location_sdblock_ptr

; spi shift register location
.exportzp spi_sr            = location_spi_sr
.exportzp __volatile_ptr    = location___volatile_ptr
.exportzp __volatile_tmp    = location___volatile_tmp

; flags/signals (like ctrl-c, etc)
.exportzp flags     = location_flags

.export retvec      = $fff8

.export lba_addr    = $0280   ; 4 bytes
.export blocks      = $0284   ; 1 byte - blocks to read with max sec/cl (volumeID+VolumeID::BPB_SecPerClus)
.export sys_irr     = $0285   ; 1 byte - interrupt status register - maintained by kernel and holds bits of IRQ sources - IRQ_VDP, IRQ_VIA, IRQ_SND etc.
.export key         = $0286   ; 1 byte - keyboard char
; $0287 free

; video mode register
.export video_mode   = $0288
                ; TODO not implemented/used yet - bit 0-4 - video mode bits - m1-m5 refer to msx spec. - e.g.
                ;   TEXT1 - 00001
                ;   TEXT2 - 01001
                ;   MC    - 00010
                ;   G1    - 00000
                ;   G2    - 00100
                ;   G3    - 01000
                ; bit 6 - text mode with 0 - 40 / 1 - 80 columns
                ; bit 7 - 0 - NTSC / 1 - PAL


; custom isr, aligned with v-blank, called by kernel on each frame
.export user_isr  = $0289
; TEXTUI
.export crs_x      = $028b
.export crs_y      = $028c

.export textui_color = $028d