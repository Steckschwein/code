package steckschwein.crc;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.BlockJUnit4ClassRunner;

import static org.junit.Assert.assertEquals;

/**
 *
 */
@RunWith(BlockJUnit4ClassRunner.class)
public class _crc7Test {

   //@Test
   public void testBounds() {
      byte crc = crc7.crc7(null);
      assertEquals(0, crc);

      byte[] data = {};
      crc = crc7.crc7(data);
      assertEquals(0, crc);

      data = new byte[] { 0x1 };
      crc = crc7.crc7(data);
      assertEquals(0x09, crc);
   }

   //@Test
   public void testBounds_Polynome() {
      byte[] data = { crc7.polynom_crc7_0x89 };
      byte crc = crc7.crc7(crc7.polynom_crc7_0x89, data);
      assertEquals(0x0, crc);

      data = new byte[] { crc7.polynom_crc7_0x91 };
      //crc = crc7.crc7(crc7.polynom_crc7_0x91, data);
      //assertEquals(0x0, crc);
   }

   //@Test
   public void testCrc7_0x20() {
     byte[] data = { 0x20 };
     byte crc = crc7.crc7(data);
     assertEquals(0x32, crc);
   }

   @Test
   public void testCrc7_0x89_2Bytes() {
     byte[] data = { 'A', 'B' };
     byte crc = crc7.crc7(data);
     assertEquals(0x10, crc);
   }

   //@Test
   public void testCrc7_0x89() {
     byte[] data = { 'B' };
     byte crc = crc7.crc7(data);
     assertEquals(0x76, crc);


     data = new byte[] { ' ' };
     crc = crc7.crc7(data);
     assertEquals(0x32, crc);

      data = new byte[] { 'H', 'A', 'L', 'L', 'O', ' ', 'T', 'H', 'O', 'M', 'A', 'S' };
      crc = crc7.crc7(data);
      assertEquals(0x78, crc);

      data = new byte[] { (byte) 0xde, (byte) 0xad, (byte) 0xbe, (byte) 0xef };
      crc = crc7.crc7(data);
      assertEquals(0x6c, crc);
   }

   //@Test
   public void testCrc7_0x91() {
      byte[] data = new byte[] { (byte) 0xde, (byte) 0xad, (byte) 0xbe, (byte) 0xef };
      byte crc = crc7.crc7(crc7.polynom_crc7_0x91, data);
      assertEquals(0x5d, crc);
   }
}
