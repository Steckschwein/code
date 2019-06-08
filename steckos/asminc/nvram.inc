nvram_start = $20
nvram_write = $80

.struct nvram
    signature       .byte
    version         .byte
    filename        .byte 11
    uart_baudrate   .byte
    dummy           .byte ; placeholder
    uart_lsr        .byte
.endstruct

nvram_size  = .sizeof(nvram)
