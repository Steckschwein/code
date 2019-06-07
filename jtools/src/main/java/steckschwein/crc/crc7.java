package steckschwein.crc;

public class crc7 {

   static byte polynom_crc7_0x89 = (byte) (1 << 7 | 1 << 3 | 1 << 0);// 0x89

   static byte polynom_crc7_0x91 = (byte) (1 << 7 | 1 << 4 | 1 << 0); // 0x91

   public static byte crc7(byte[] data) {
      return crc7(polynom_crc7_0x89, data);
   }

   /**
    * @param data
    * @param offset
    * @param len
    */
   public static byte crc7(byte polynom, byte[] data) {

      byte crc = 0;
      if (data == null)
         return 0;
      for (int i = 0, len = data.length; i < len; i++) {
         for (int x = 7; x >= 0; x--) {
            crc <<= 1;
            crc |= ((data[i] >> x) & 1);
            if ((crc & 0x80) == 0x80) {
               crc ^= polynom;
            }
         }
      }

      for (int x = 0; x < 7; x++) {
         crc <<= 1;
         if ((crc & 0x80) == 0x80) {
            crc ^= polynom;
         }
      }
      return crc;
   }
}