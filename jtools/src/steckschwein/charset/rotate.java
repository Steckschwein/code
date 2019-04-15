package steckschwein.charset;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

/**
 * @author marko.lauke
 */
public class rotate {

   public static void main(String[] args) throws IOException {

      File dir = new File("/development/steckschwein-code/games/pacman");
      File file = new File(dir, "pacman.tiles.bin");
      if (!file.exists() && !file.canRead()) {
         System.err.println("file " + file + " cannot be accessed for reading!");
         System.exit(1);
      }
      FileInputStream fileIn = new FileInputStream(file);
      int chrn = 0;
      int r;
      byte[] bytes = new byte[8];
      while ((r = fileIn.read(bytes)) != -1) {
         if (r < 8) {
            System.err.println("invalid file length, not a multiple of 8!");
            break;
         }
         byte[] result = { 0, 0, 0, 0, 0, 0, 0, 0 };
         for (int i = 0; i <= 7; i++) {
            for (int x = 0; x <= 7; x++) {
               byte b = (byte) ((bytes[x] & (1 << i)) == 0 ? 0 : 1 << (7 - x));
               result[i] |= b;
            }
         }
         System.out.print(".byte ");
         for (int x = 0; x <= 7; x++) {
            System.out.print("$" + Integer.toHexString(result[x] & 0xff) + (x < 7 ? "," : "; " + " ($" + Integer.toHexString(chrn) + ")"));
         }
         System.out.println();
         for (int x = 0; x <= 7; x++) {
            System.out.println(//
                  String.format(";%8s", Integer.toBinaryString(result[x] & 0xff)).replace(' ', '.').replace('0', '.').replace('1', '#'));
         }
         chrn++;
         // break;
      }
      fileIn.close();
   }
}
