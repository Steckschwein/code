
// QR code demo for 8-bit computers.
// https://8bitworkshop.com/docs/posts/2022/8bit-qr-code.html
// Uses qrtiny:
// - https://github.com/danielgjackson/qrtiny
// - Copyright (c) 2020, Dan Jackson. All rights reserved.

#include <stdio.h>
#include <graphics.h>
#include "qrtiny.h"


const char* URLstring = "www.steckschwein.de";

uint8_t buffer[1024];

// void main(int argc, char *argv[])
void main()
{
  
  // Use a (26 byte) buffer for holding the encoded payload and ECC calculations
  // uint8_t buffer[QRTINY_BUFFER_SIZE];
  
  // Choose a format for the QR Code: a mask pattern (binary `000` to `111`) and an error correction level (`LOW`, `MEDIUM`, `QUARTILE`, `HIGH`).
  uint16_t formatInfo = QRTINY_FORMATINFO_MASK_000_ECC_MEDIUM;
  
  uint8_t x,y;
  uint8_t x0;
  uint8_t y0;
  uint8_t module;

  // Encode one or more segments text to the buffer
  size_t payloadLength = 0;
  bool result;
  
  /*
  if (argc != 2)
  {
    return;
  }
  
  if (strlen(argv[1]) > 19)
  {
    printf("Max. 19 bytes.\n");
    return;
  }
  */
  
  puts("Computing...\n");
  payloadLength += QrTinyWriteAlphanumeric(buffer, payloadLength, URLstring);
//  payloadLength += QrTinyWriteNumeric(buffer, payloadLength, "1234567890");
//  payloadLength += QrTinyWrite8Bit(buffer, payloadLength, "!");
  
  // Compute the remaining buffer contents: any required padding and the calculated error-correction information
  result = QrTinyGenerate(buffer, payloadLength, formatInfo);
  printf("Done! result = %d\n", result);

  // draw to screen using TGI driver
  if (!result) 
  {
    return;
  }
    
  initgraph(NULL, 3, NULL);
  cleardevice();

  x0 = getmaxx() / 2 - QRTINY_DIMENSION + 9;
  y0 = getmaxy() / 2 - QRTINY_DIMENSION + 9;

  setbkcolor(BLACK);

  // graphics_bar(x0-2, y0-2, x0+QRTINY_DIMENSION+2, y0+QRTINY_DIMENSION+2);

  for (y=0; y<QRTINY_DIMENSION; y++) {
    for (x=0; x<QRTINY_DIMENSION; x++) {
      module = QrTinyModuleGet(buffer, formatInfo, x, y);       

      putpixel(x+x0, y+y0, module ? BLACK : WHITE);
    }
  }
  getch();
  closegraph();
  
  return;
}
