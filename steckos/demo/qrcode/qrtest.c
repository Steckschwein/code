
// QR code demo for 8-bit computers.
// https://8bitworkshop.com/docs/posts/2022/8bit-qr-code.html
// Uses qrtiny:
// - https://github.com/danielgjackson/qrtiny
// - Copyright (c) 2020, Dan Jackson. All rights reserved.

#include "qrtiny.h"
//#link "qrtiny.c"

#include <stdio.h>

#include <graphics.h>

const char* URLstring = "www.steckschwein.de";

#define QR_CODE_SIZE 21

void main() {
  
  // Use a (26 byte) buffer for holding the encoded payload and ECC calculations
  uint8_t buffer[1024];
  // uint8_t buffer[QRTINY_BUFFER_SIZE];
  
  // Choose a format for the QR Code: a mask pattern (binary `000` to `111`) and an error correction level (`LOW`, `MEDIUM`, `QUARTILE`, `HIGH`).
  uint16_t formatInfo = QRTINY_FORMATINFO_MASK_000_ECC_MEDIUM;
  
  // Encode one or more segments text to the buffer
  size_t payloadLength = 0;
  bool result;
  
  puts("Computing...\n");
  payloadLength += QrTinyWriteAlphanumeric(buffer, payloadLength, URLstring);
//  payloadLength += QrTinyWriteNumeric(buffer, payloadLength, "1234567890");
//  payloadLength += QrTinyWrite8Bit(buffer, payloadLength, "!");
  
  // Compute the remaining buffer contents: any required padding and the calculated error-correction information
  result = QrTinyGenerate(buffer, payloadLength, formatInfo);
  printf("Done! result = %d\n", result);

  // draw to screen using TGI driver
  if (result) {
    uint8_t x,y;
    uint8_t x0;
    uint8_t y0;
    uint8_t module;
    
    initgraph(NULL, 7, NULL);
    cleardevice();

    x0 = getmaxx() / 2 - QR_CODE_SIZE + 9;
    y0 = getmaxy() / 2 - QR_CODE_SIZE + 9;

    setbkcolor(BLACK);
    setcolor(WHITE);

    graphics_bar(x0-2, y0-2, x0+QR_CODE_SIZE+2, y0+QR_CODE_SIZE+2);

    for (y=0; y<QR_CODE_SIZE; y++) {
      for (x=0; x<QR_CODE_SIZE; x++) {
        module = QrTinyModuleGet(buffer, formatInfo, x, y);       

        putpixel(x+x0, y+y0, module ? BLACK : WHITE);
      }
    }
    getch();
    closegraph();
  }
  return;
}
