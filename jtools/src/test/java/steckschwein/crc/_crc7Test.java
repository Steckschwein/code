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

   @Test
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

   @Test
   public void testCrc7() {
      byte[] data = { 'B' };
      byte crc = crc7.crc7(data);
      assertEquals(0x76, crc);

      data = new byte[] { 'H', 'A', 'L', 'L', 'O', ' ', 'T', 'H', 'O', 'M', 'A', 'S' };
      crc = crc7.crc7(data);
      assertEquals(0x78, crc);
   }
}
