package steckschwein.crc;

import java.util.Arrays;

public class crc7 {

   static byte polynom_crc7_0x89 = (byte) (1 << 7 | 1 << 3 | 1 << 0);// 0x89

   static byte polynom_crc7_0x91 = (byte) (1 << 7 | 1 << 4 | 1 << 0); // 0x91

   public static byte crc7(byte[] data) {
      return crc7(polynom_crc7_0x89, data);
   }

   static final byte crc7(byte polynom, byte[] data) {

     byte crc = 0;
     if (data == null)
        return crc;

     byte p_shift = (byte) (polynom << 1 & 0xff);

     for (byte i = 0; i < data.length; i++) {
        crc ^= data[i];
        for (byte j = 0; j < 8; j++) {
         crc = (byte) ((crc & 0x80) != 0 ? ((crc << 1) ^ (p_shift)) : (crc << 1));
       }
     }
     return (byte) ((crc & 0xff) >> 1);
   }

   /**
    * @param data
    * @param offset
    * @param len
    */
   public static byte crc7_2(byte polynom, byte[] data) {

      byte crc = 0;
      if (data == null)
         return 0;
      System.out.println("crc 0: 0x" + Integer.toHexString(polynom) + " ");
      for (int i = 0, len = data.length; i < len; i++) {
         System.out.println("i: " + i + " 0x" + Integer.toHexString(data[i]) + " crc: 0x" + crc);
         for (int x = 7; x >= 0; x--) {
            crc <<= 1;
            System.out.println("1: 0x" + Integer.toHexString(crc) + " x: " + x);
            crc |= ((data[i] >> x) & 1);
            System.out.println("2: 0x" + Integer.toHexString(crc));
            if ((crc & 0x80) == 0x80) {
               crc ^= polynom;
               System.out.println("3: 0x" + Integer.toHexString(crc));
            }
         }
      }

      System.out.println("crc 1: 0x" + Integer.toHexString(crc));
      for (int x = 0; x < 7; x++) {
         crc <<= 1;
         if ((crc & 0x80) == 0x80) {
            crc ^= polynom;
         }
      }
      System.out.println("crc 2: 0x" + Integer.toHexString(crc));
      return crc;
   }
}
