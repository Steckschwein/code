spi65             = $250  ; slot 0
spi65_data        = spi65 + 0
spi65_status      = spi65 + 1
spi65_ctrl        = spi65 + 1
spi65_div         = spi65 + 2
spi65_ss          = spi65 + 3

; constants
TC        = 1<<7 ; Transmission Complete – This flag is set when the last bit has been
                 ; shifted and is cleared when the SPI Data register is accessed.

IER       = 1<<6 ; Interrupt Enable – Interrupts are enabled when this is set to 1 and
                 ; disabled when set to 0.

BSY       = 1<<5 ; SPI Busy – This is 1 when data is written to the SPI data register and
                 ; will stay high until the last bit is shifted.

FRX       = 1<<4 ; Fast Receive mode – When set to 1, fast receive mode triggers shifting
                 ; upon reading or writing the SPI Data register. When set to 0, shifting
                 ; is only triggered by writing the SPI data register.

TMO       = 1<<3 ; Tri-state MOSI - When set to 1, the MOSI pin will be tri-stated. When
                 ; set to 0, the MOSI pin will have an active output. Tri-state will allow
                 ; some three-wire interfaces to work properly.

ECE       = 1<<2 ; External Clock Enable
CPOL      = 1<<1 ; Clock Polarity - 0 = Rising edge; 1 = Falling edge
CPHA      = 1<<0 ; Clock Phase - 0 = Leading edge; 1 = Trailing edge


spi65_device_sdcard	  = %00001110
spi65_device_deselect = %00001111 ; deselect any device