package steckschwein.xpm;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;

/**
 * @author marko.lauke
 *
 */
public class xpmTobitmap {

	static Map<String, Byte> vdpColorMap = new HashMap<String, Byte>();
	static {
		putColor(vdpColorMap, "None", 0);
		putColor(vdpColorMap, "black", 1);
		putColor(vdpColorMap, "#23CB32", 2);
		putColor(vdpColorMap, "#60DD6C", 3);
		putColor(vdpColorMap, "#544EFF", 4);
		putColor(vdpColorMap, "#7D70FF", 5);
		putColor(vdpColorMap, "#D25442", 6);
		putColor(vdpColorMap, "#45EBFF", 7);
		putColor(vdpColorMap, "#FA5948", 8);
		putColor(vdpColorMap, "#FF7C6C", 9);
		putColor(vdpColorMap, "#D3C63C", 0xa);
		putColor(vdpColorMap, "#E5D26D", 0xb);
		putColor(vdpColorMap, "#23B22C", 0x0c);
		putColor(vdpColorMap, "#C85AC6", 0x0d);
		putColor(vdpColorMap, "#CCCCCC", 0x0e);
		putColor(vdpColorMap, "white", 0x0f);
	}

	public static void main(String[] args) throws IOException {

		if (args.length < 1) {
			System.err.println("xpm file not given!");
			return;
		}

		File file = new File(args[0]);
		if (!file.exists() || !file.canRead()) {
			System.err.println("xpm file '" + file
					+ "' does not exist or is not accessible for reading!");
			return;
		}
		BufferedReader reader = new BufferedReader(new InputStreamReader(
				new FileInputStream(file)));
		String[] xpmHeader;
		String[] xpmData;
		String line;

		skip(reader, 2);
		String header = nextLine(reader);
		String[] headerArr = header.split(" ");
		if (headerArr.length < 3) {
			System.err.println("error in xpm file, invalid header '" + header
					+ "' given!");
		}
		int width = toInt(headerArr[0]);
		int height = toInt(headerArr[1]);
		int colors = toInt(headerArr[2]);
		Map<Character, Byte> colorMap = new HashMap<Character, Byte>();
		for (int i = 0; i < colors; i++) {
			line = nextLine(reader);
			if (line == null) {
				System.err
						.println("invalid xpm file given, number of colors expected "
								+ colors + ", but was " + i + "!");
			}
			char colorChar = line.charAt(0);
			String colorCode = line.substring(line.lastIndexOf(' ') + 1,
					line.length());
			Byte vdpColor = vdpColorMap.get(colorCode);
			if (vdpColor == null) {
				System.err.println("no vdp color found for color code '"
						+ colorCode + "'!");
				return;
			}
			colorMap.put(colorChar, vdpColor);
		}

		int row = 0;
		while ((line = nextLine(reader)) != null) {
			int l = line.length();
			if (l % 8 != 0) {
				System.err.println("invalid data length in row " + row + "!");
				return;
			}
			row++;
		}
	}

	private static void putColor(Map<String, Byte> colorMap, String string,
			int i) {
		colorMap.put(string, (byte) i);
	}

	private static String nextLine(BufferedReader reader) throws IOException {
		String line = reader.readLine();
		if (line != null)
			return line.substring(1, line.length() - 2);
		return line;
	}

	private static void skip(BufferedReader reader, int i) throws IOException {
		for (int n = 0; n < i; n++)
			reader.readLine();
	}

	private static int toInt(String string) {
		return Integer.valueOf(string);
	}

	/* XPM */
	static String[] dgitis_0_9_xpm = {
			"400 72 12 1",
			" 	c None",
			"!	c black",
			"#	c #D25442",
			"$	c #FA5948",
			"%	c #D3C63C",
			"&	c #E5D26D",
			"'	c white",
			"(	c #FF7C6C",
			")	c #C85AC6",
			"*	c #544EFF",
			"+	c #CCCCCC",
			",	c #7D70FF",
			"!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!#!#!!#!!!#!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!#!!#!#!!!!!!!!!!!!!!!!!!!!!!!!!#!#!#!#!!#!#!#!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!!!!",
			"!!!!!!!!!!!!!!!#!!#!!!!!!#!#!!!#!!!!!!!!!!!!!!!!!!!!!#!#!!!#!!!#!#!#!#!#!!!!!!!!!!!!!!!!!#!!#!#!#!!!#!!#!!#!#!#!!!!!!!!!!!!!!!!!!!!!!#!!!!!#!!!!#!!#!#!!#!!!!!!!!!!!!!!#!!#!!#!#!!!#!!!#!!#!!#!#!!!!!!!!!!!!!!!!!!!!!#!!!!!!!!!!!!#!!!!!!!!!!!!!!!!!!!!!!#!#!!#!#!!#!!#!!#!#!#!#!!!!!!!!!!!!!!!!!!#!!#!!!#!!!!#!!#!!#!!!!!!!!!!!!!!!!!!!!!!#!!#!!!#!!#!!#!!#!#!!!!!!!!!!!!!!!!!!!!!#!!!!#!!!!!#!#!!#!!!!!!!!!!!!",
			"!!!!!!!!!!!#!!!!#!!!#!!#!!!!#!!!!!#!!!!!!!!!!!!!!!#!!!!!!#!!!!!!!!#!!!!!#!#!!!!!!!!!!!#!!!#!!!!!!#!!!#!!#!!#!!!#!#!!!!!!!!!!!!!!!!#!!!!!#!!!!!#!!#!!!!!!!!#!!!!!!!!!!#!!!!!#!!#!!$!!!$!!!#!#!!!!#!#!!!!!!!!!!!!!!!#!!!!!#!!!!#!!!!!!!#!!!!!!!!!!!!!!!#!#!!#!#!!#!!#!!!!#!!#!!#!!#!#!!!!!!!!!!!!#!!!!!!!#!!!!#!!#!!#!!!!#!!!!!!!!!!!!!!!!#!!!!#!!#!!!!!#!!#!!!!#!!#!!!!!!!!!!!!!!#!!!!!#!!!#!!!#!!#!!#!!#!!!!!!!!",
			"!!!!!!!!#!!!!#!!!!!!!!!!!#!!!!!#!!!!!!!!!!!!!!!#!!!!#!#!#!!!!!!#!!!!#!!#!!!!#!!!!!!!!#!!#!!#!#!#!!!#!!#!!#!!#!!!!!#!!!!!!!!!!!!!#!!!!!#!!!!!#!!!!!!#!!#!!!!!#!!!!!!!!!!#!$!!$!!$!!#!#!!#!#!!#!#!!!!!#!!!!!!!!!!#!!!!!!#!!!#!!!!!!!#!!!!!!!#!!!!!!!!!!!!!#!!!!#!!#!!!#!!!#!!#!!#!!!!#!!!!!!!!#!!!!!#!#!!!!!!!!!!!!!!!#!!!!#!!!!!!!!!!!#!!!!#!!!#!!!!!!!!!!!!#!!!#!!!#!!!!!!!!!!#!!!!!#!!!!!!!!!!!!!!!!!!!!#!!!!!!",
			"!!!!!!!!!!#!!!!#!#!!!#!!!!#!!#!!!#!#!!!!!!!!!!!!!!#!!!!!!#!!#!!!!!#!!#!!#!#!!!!!!!!!!!#!!#!!#!#!!#!!!!!$!!$!!#!##!!!!!!!!!!!!!#!!!!#!!!!#!#!!!#!!#!!#!!#!#!!!!!!!!!!!#!!!#!#!##!##!#!!#!#!$!$!!$!$!!!!!!!!!!!!!!!!!#!!!!#!!#!!!#!!!!!!!#!!!!!!!!!!!#!!$!!$!$!$!$!!$!!#!#!#!!##!#!#!!#!!!!!!!!!#!#!!!!#!#!!#!!!!#!!#!!!#!!!!!#!!!!!!!!!!#!!!#!!!#!!#!!#!!!#!!#!!!!#!!!!!!!!!!!!!!#!#!!#!#!!!!!!#!#!#!!#!#!!!!!!!!",
			"!!!!!!!!#!!!#!!!!!!#!!!#!!!#!!!#!!#!!!!!!!!!!!!!#!!!#!!#!!!!!!!!#!!#!!!#!!!#!!!!!!!!!!!$!!$!!#!!#!!!#!$!$!!$!$!!!$!!!#!!#!!!!!!!!#!!!#!!!!!#!!!#!!#!!#!!!!#!!!!!!!!!!!!#!!#!#!##!$!!$!$!$!##!#!#!!$!!!!!!!!!!!!!#!!!!#!!!!!!#!!!!!!#!!!!!!#!!!!!!!!!!#!#!!#!#!#!#!!#!!#!#!##!!$!$!$!!!!!!!!!!!!!!!#!!!!!#!!!#!!!#!!!#!!#!#!!!!!!!!!!!!!!!#!!!#!!#!!!!!!#!!#!!!!#!!#!!!!!!!!!!!#!!!!!!!!!!#!!!!!!!!!#!!!!#!!!!!!!",
			"!!!!!!!!!#!#!!#!!#!!!#!!!$!!!$!!#!!#!!!!!!!!!!!!!#!#!#!!$!$!!!!#!#!!#!#!$!$!!!!!!!!!#!#!##!##!##!#!!#$!$!$$!$!$!$!!!!!!!!!!!!!!!#!!#!!!#!#!!#!##!$!$!!$!#!!#!!!!!!!!!#!!##!###########$$####%####!!#!!!!!!!!!!!!!#!#!!!#!#!#!!#!!#!!!#!!#!!!!!!!!!!!!!$!$$!$!$!$!$!!$$!$!$!!$#!#!#!#!!!!!!!!!!#!#!!#!!#!!#!!!#!!!#!!!#!!#!!!!!!!!!!!!!!#!#!#!!#!!!#!!#!!#!!#!#!!#!!#!!!!!!!!!!!$!$!!$!#!!!!!#!!#!#!!#!#!!#!!!!!!",
			"!!!!!!!#!!#!#!!!$!!$!!$!$!!$!!!$!!$!!!!!!!!!!!!$!!$!$!$!##!#!#!$!$!$!$!!!$!$!!!!!!!!!!!$!$$$$######!#####!###!$$!$!!!!!!!!!!!!!!!#!!#!#!$!$!$!$$###!#!#!!$!!!!!!!!!!!!!$!###&&&&&&%%%%&&&&&&&&&&#$!!!!!!!!!!!!!#!!!!!$!!$!$!$$!$!!!#!!#!!!#!!!!!!!!#!#!#!####!#######$$$$!$$!$$!$!$!!#!!!!!!#!!#!#!!$!!$!!$!#!##!!##!!#!!#!!!!!!!!!!!#!!#!#!#!!$!$!$!!#!#!#!#!$!!$!!!!!!!!!!!#!!$!$!!$!##!#!!#!$!!$!!$!$!!!!!!!!",
			"!!!!!!!!#!#!!#!$!!$!$!$!!$!$!$!!$!!$!!!!!!!!!!!!!$!$!$!#!!###!!$!!$!$!$!$!$!!!!!!!!!!####%%#%#%#%#######%%%####!#!#!!!!!!!!!!!#!!!$!!$!!#!##########!#!#!!#!#!!!!!!!!#!!###&&&&&&'%'%%'%'%%%%%%%#!$!!!!!!!!!!!!!!#!$!!$$!$$$$$$!$!#!#!!!#!!!!!!!!!!!!###$#########$#########$#####!#!!!!!!!!!!#!#!#!$!$!$!$!##!!##!!$!$!$!!!!!!!!!!!!!!$!$!$!$!!$!$!$!$!!$!$!$!$!!$!!!!!!!!!!!!$!$!$!!$!!$!!$!!!$!!$!!$!$!!!!!!!",
			"!!!!!!!!#!!#!!!!$!$!$!$$$!$!!!$!!$!!!!!!!!!!!!!!$!!$!!$!####!#!#####!#!$!$!$!!!!!!!!!!!!!%%%%%%%%%%$%%%%%%%&&$$$!$!!!#!!#!!!!!!!$!!$!!$!#####%%%%%######!!$!!!!!!!#!!!#!###&&&&&&%%%&%%%%%%%%%%##!!#!!!!!!!!!!!#!!!#!#!###%%%%%!!!#!!!#!!!#!!!!!!!!#!##%%%%%%%%&%%&&&%%%%%%(%$$$$$$!$!!!!!!!#!!#!#!#!#######$$$$!$!$!#!#!#!!!!!!!!!!!!!!$!!$!########!#####!#!$!$!$!!!!!!!!!!#!#!!#!#!$!$!$!!$!$!$$!$!!$!$!!!!!!",
			"!!!!!!!!!$!!$!$!$!$!$$$$!$!!$!!!#!!#!!!!!!!!!!!!!$$!$!$###%#######!###!$!!!$!!!#!!!!!#!##!####$$#########%##%##!#!!#!!!!!!!!!!!!!$!!$!$!$!$$$$$$%%%!!!!!#!!#!!!!!!!!!!!$!##%%%%%%%%%%%%%%%%%%####!#!!!!!!!!!!#!!!#!!$!$!$$%%%#####!!#!!!#!!!!!!!!!!!!#&&&&&&&'%'%'%''&'&'&&&'%%%%%%!!#!!!!!!!#!!#!!################!$!!!$!!!#!!!!!!!!!$!!$!!$!######!#######!$!!$!!$!!!!!!!!!!!!$!!$!$!########!#!!#!#!!$!!!!!!!",
			"!!!!!!!$!!$!$!!######%%$$$!$!$!$!!$!!!!!!!!!!!!$!$!$$$$%%%%###%$%$%%%%$###!#!!!!!!!!!!#!##!###%##########%%%%$$$!$!!!!!!!!!!!!!#!!$!!$!$###%%%%%%%%#####!#!!!#!!!!!!!$!!$##%%%%%%$$$$###$%%######!!!#!!!!!!!!!!!#!$!!$!$$$%%%%!!!!$!!!$!!!#!!!!!!!!#!##%%%%%%&&&&%%%%'%%%''%%''''####!!!!!!!!!$!$!$!$%%%%%$$%%%%%%$$!$$!!$!!!!!!!!!!!!!$!$$!$%%%%%####%#%#%%#$!$!$!!!!!!!!!!!#!$!$$!$$$%%%%%%%$$$$$!$!$!!$!!!!!!",
			"!!!!!!!!$$!$!$!#####%%%$$$$!$!!!$!!$!!!!!!!!!!!######%%%%###########%%%$$!$!$!!!!!!!!$!$!$!$$$$!$!$$$#####%%%$$!$!!!!#!!#!!!!!!!$!$!$!$!###%%%%#%%%#####!!$!!!!!!!!#!!#!###%%%%##$!$$$$!$#####!#!$!!!!!!!!!!!!#!!#######%%%%######!!$!!!$!!!!!!!!!!!!!#######%%%$$%%%%$%%%%%%%%%%%%!!#!!!!!!$!!$!$$$%%%%####%###%%%%$!$!$!!!!!!!!!!!!$!!$!$$$%%%%#########%%%$$!$!$!!#!!!!!!!!$!$$!$$$%%%$$%%$%%%%####!$!!!!!!!!",
			"!!!!!!!!!$!$!!$!!!!%%%%'#######!$!$!!!!!!!!!!!!!!$$$$$$###!#!###!######$$$!$!!!#!!!!!!$!$!$!$!$!$!$$$#####%%%$$$!$!!!!!!!!!!!!#!!$!$!$!$##%%%%%%%%%%!!!!$!!$!!!!!!!!!!!$!##%%%###$$!$$$!$!####!#!!$!!!!!!!!!!!!#!!!!!!%%%%$$$$$!!!!$!!$!!!#!!!!!!!!!!#!######%$$$$$$%%$$$$$%%%#%%%###!!!!!!!!$!$$!$$%%######%####%%%$$$!!$!!#!!!!!!!!!#!#####%%############%%$$$!!$!!!!!!!!!#!######%%%#########%%####$!$!!!!!!!",
			"!!!!!!!$!$!$!$!$$$$$&&&$$$$!$!!!$!!$!!!!!!!!!!!####%%%%$$!$!$!$!#!#####%%%!!!!!!!!!!!$!$!$!$!$!$!$!$$#####&&&##!#!#!!!!!!!!!!!!!$!$!$!$!$$%%%%%$&&######!$!!!!!!!!!!#!#!###%%%###!$$$!$!$$!$!$$!$!!#!!!!!!!#!!!!#!#####%%%####!#!#!!$!!$!!!#!!!!!!!#!!$!$!$$$$$!$!$$$%######%#%%%%###!!!!!!!!!$!$$$$$$$!$!$$$!$!$$$$%%!%!!!!!!!!!!!!!!!$!$$$$$$$!$!!$#!#!####%%%!%!!!#!!!!!!!!######%%###!#######%%###!$!$!!!!!!",
			"!!!!!!!!$!$!$!$#####&&&%%######!#!#!!!!!!!!!!!!!!%%%%!%!$!$!$!$#!#!####%%######!!!!!!!$!$!$!$!$!$!$!$####%%%%$$!$!!!!#!!#!!!!!#!!$!$!$!$$$%%%%%$%%%#####!!#!#!!!!!!!!!#!###%%%###!$!$$!$!$!$!$!$!$!!!!!!!!!!!!#!!#!!!%%%%%$$!$$!$!$!!$!!$!!!!!!!!!!!!!#!#####!$$!$$$$$$$!$$$$%%%%%!!!#!!!!#!#####%%%####!#!#$$!$!$$$%%%!!%!!#!!!!!!#!#####%%%####!##!$$!$!$$$%%######!!!!!!!!######%%%#####!######%%##$!$!!!!!!!",
			"!!!!!!!$!$!$!$!#####&&&$$$!$!$!!!$!$!!!!!!!!!!!###%%###!$$!$!$!$!$!$!$$%%%%!!!!!!!!!!!!$!$!$!$!$!$!$$####&&&####!#!!!!!!!!!!!!!#!!$!$!$$$%%%%$%$%%######!!$!!!!!!!!!#!!#!#%%%####$!$!$$!$!$!$!$!$!#!!!!!!!!!!!!#!#####%%%#$!$!$!$!!$!!$!!$!!!!!!!!!!!!!$!$!$$!$!$$!$$$!$$!$$$#&&&####!!!!!!!!!!!%%%%$$!$$!$!###!####%%%!%!!!!!!!!!!!!!!!!%%%%##!##!##!$$!$!$$%%%%!!!!!!!!!!!!!!$!$$$$$$!$!$!$!#####%%#$!$!$!!!!!",
			"!!!!!!!!$!$!!$!#####&&&%%######!$!$!!!!!!!!!!!!###%%###!$!$!$!!$!$!$!$$#####!!!!!!!!!$!$!!$!$!$!$!$!$###%%%%##!##!!#!!!!!!!!!!!!$$!$!$!$$%%%$$%$%%%%!!!!$!$!!!!!!#!!!!#!###%%%###!$!$$!$!$!$!$!$!!!!#!!!!!!!!#!!#!###%%%##$$!$$!!$$!$!!$!!#!!!!!!!!#!!$!$!$!$!$$!$!$$$$!$$!$$%%%%%!!!#!!!!!!#####%%#!$$!$!$$!$!$$!$$$$$$!$!!#!!!!!!!!#####%%#$!$$!$!$!$!$!$!$$$$$$$!!!!!!!!!!#####%%##$$!$!$!$!$!$$$$$###!!!!!!!",
			"!#!!!!!$!$!$!!$#####&&&$$$!$!$!#!#!#!!!!!!!!!!!!$$$$$!$!$!!$!$!$!!$!$!$######!!!!!!!!!$!$!$!$!$!$!$$!$$%%%$$$$!$!$!!!!!!!!!!!!#!!$!$!$$$$%%%$$$%%%$$$$$$!#!!#!!!!!!!!$!$!#%%%%###$!$!$$!$!$!$!$!$!#!!!!!!!!#!!!#!####%%%##!$$!$!$!!#!#!!#!!#!!!!!!!!!!!$!$!$!$!!$!$!$!$$!$$$$#&&&####!!!!!!!!!!%%%%%$!$$!$!$!$$!$!$$%%%!%!!!!!!!!!!!!!!!%%%%%!$$!$!$!$!$$!$$$%%%!%!!!#!!!!!#!!####%%##!$$!$!$!#####%%%!##!!#!!!!",
			"!!!!!!!!$!$!$!!#####&&&%%######!!!$!!!!!!!!!!!!!####!#!$!$!!$!$!$!!$!$!#####!!#!!!!!!!!$!$!$!$!$!$!$$##%%%###!$!$!!!!!!!!!!!!!!#!$!$$!$$%%%#####&&######!!$!!!!!!!!#!!#!##%%%####!$!$!$!$$!$!$!$!#!!!!!!!!!!!!#!#!###%%###$!$!$!$!#!#!#!!#!!!!!!!!!!!$!!$!$!$!$$!$!$$$!$$$!$$%%%%%!!!!!!!!#!#####%%#!$$!$!$!$!$!$$!$$$$$!$!!#!!!!!!#!####%%%#$!$$!$!$!$!$!$!$#######!!!!!!!!!####%%###$!$!$!$!$!$!$$$$##!#!!!!!!",
			"!!!!!!!$!$!$!$$#####&&&$$$$$!$!$!$!$!!!!!!!!!!!!!##!#!#!$!$!$!!$!$!$!$$!%%%%!!!!!!!!#!!$!!$!$!$!$$!$$#%%%####!!$!$!!!#!!#!!!!!!!#!#!####%%%####%%%%%!!!!$!$!!!!!!!!!!!#!###%%%###$!$$$!$!!$!$!$!$!#!!!!!!!!!#!!#!###%%%###!$!$!$!$!#!#!#!!#!!!!!!!!!!!!$!$!$!$!$!$!$!$!$!$$$$%%%#####!!!!!!!!!$$$$$$$!$!$$!$!$!$!$$$#####!#!!!!!!!!!!!!!%%%%!$$!$$!$$!$!$!$$$######!!#!!!!!!!!###%####!$!$!$!$!#!#####$$$!!!!!!!",
			"!!!!!!!!$!$!$!!#####&&&'#######!$!$!!!!!!!!!!!!$!!$!!$!$!!$!!$!$!!$!$!$!$$$$!$!!!!!!!!$!$!!$!$!$!$$$$%%%#####!$!$!!!!!!!!!!!!!#!!$!$!$$$%%######%%$$$$$$!#!#!!!!!!!!$!!$!#%%%####!$$!$$!$$!$!$!$!!!#!!!!!!!!!!$!$!##%%####!$$!$!$!$!!$!!$!!#!!!!!!!!!#!!#!#!#!$!$!$!$$$!$$!$$%%%%!!!!!!!!!!!####%%%#$$!$$!$$!$$!$$!$%%%%!!!!!!!!!!!!!$$$$%%$$$!$!$$!$!$$!$$!$!%%%%!!!!!!!!#!!####%####$!$!$!$!$!$$!$$$###!!#!!!!",
			"!#!!!!!!!$!$!$$#####&&&$$$!$!$!!!$!$!!!!!!!!!!!!!#!#!!#!$!!$!$!!$!!$!$$!%%%%!!!#!!!!!!!$!$!$!$$!$!$$$%%######!!$!$!!!!!!!!!!!!!#!$!$!$$$%%######&&######!!$!!!!!!#!!!!#!#$%%%$$$$$!$$!$$$!$!$!$!$$!!!!!!!!!!#!!!###%%%####!$!$!$!$!$!!$!!$!!!!!!!!!!!!$!!$!$!$!$!$!$!$!$!$$$$&&######!!!!!#!!!!%%%%!$$$!$$!$!$!$!$$$######!!#!!!!!!#!!!!%%%%!$$$!$!$!$!!$!$$$##%%####!!!!!!!#!##%%####!$!$!$!!#!#!########!!!!!!",
			"!!!!!#!!$!$!!$!#####&&&%#######!$!$!!!!#!!!!!!!#!!#!!#!!!$!$!!$!!$!$!$!#####!#!!!!!!!$!!$!$!$######%%%%######!$!$!!!!!!!!!!!#!!!$!$!$$$$%%#####%%%%%!!!!$!$!!!!!!!!!#!!###%%%%####$#$$$##$$!$$!$!!#!!!!!!!#!!!#!###%%#####!$$!$!$!!$!$!$!!$!!!!!!!!!!!!!$!!$!!$!$!$!$!$$!$$$$%%%%!!!!!!!!!!!!$!$$$$$$!$$!$$!$!$!$$!$#####!#!!!!!!!!!!####%%##$!$!$$!$!$$!$$!$######!!#!!!!#!!!##%%####!$!$!!$!$!$$!$!$%%!!!!!!!!",
			"!#!!!!!!!$!$!$!####%%%%$$$$$!$!$!$!!$!!!!!!!!!!!!!!$!!$!$!$!$!!$!$!$!$!!%%%%!!!#!!!!!!!$!$!$!!!$!$$$$$$$$!$!!$!$!!$!!!!!!!!!!!#!######%%%#######%%######!$!!$!!!!!!!!#!!##%%%####$$%%%$$$!$$!$$!$!!!#!!!!!!!!#!#!#%%######!$!$!$!$$!$!$!$!!#!!!!!!!!!!$!!$!!$$!$!$!$!$!$$!$$$''######!!!!!!#!!!!%%%%$$!$$!$$$!$$!$$$%%%%!!!!#!!!!!!#!!!!%%%%!$$!$!$$!$!!$!$$$##%%####!!!!!!!#!##%%####!$$!$!!$!#!#########!#!!!!",
			"!!!!!!#!!$!$!!$#####%%%%#######!$!$!!!!!!!!!!!!!!$!!$!!$!!!$!$!$!!$!$!$$$$$$!$!!!!!!!$!!$!$!$#####%%%%#######!$!$!!!!#!!#!!!!!!!!!!%!%%%%#######%%######!!$!!!!!!!#!!!#!##%%%%%%%&&&&&%%%$$$$!$!$!$!!!!!!!!#!!#!##%%%#####!$$!$!$!!$!$!$!$!!!#!!!!!!!!!!$!$$!!$!$!$!$######&&((((!!!!!!!!#!!#!######$$$!$$$!#######%######!!!!!!!!!!#####%%##$!$$!$!$!$$!$$!$!%%%%!!!#!!!!#!!!#%%#####!$!$!$!!$!$!$!$$%%%!!!!!!!",
			"!#!!!!!!!$!$!$!#####%%%$$!$$!$!!$!$!!!!!!!!!!!!#!!#!!#!!$!$!!$!$!$!$!$!%%%%!!!!#!!!!!!!$!$!$!#####&&&$$!$$!$!$!$!$!!!!!!!!!!!#!!######%%###!####$$$$!$!$!$!!$!!!!!!!#!!#!$&&&&&&&&&&&&&&&%%######!!!#!!!!!!!#!!###%%%#####$!$$$!$$$!$!$!$!#!!!!!!!!!!$!!!$!!$!$!!$!$!$!!$$$$$%%######!!!!!!!!#!#####%#######$!$!$$$$%%%!!!!!#!!!!!!!!!!!%%%%!$$!$$!$!$!!$!$$$#%%%####!!!!!!#!#$$$$!$!$!!$!$!$!!$!$$!$$####!#!!!!",
			"#!!!#!!!!$!$!$!#####&&&$$$$!$!$!!$!$!!!#!!!!!!!!!!!$!!$!$!!$!$!!$!$!$!$$$$$$!$!!!!!!!#!!#!#!#!!!&&&&&$$$$!$!$$!$!!!$!!!!!!!!!!#!!$!$$$$$####!###%%######!!$!!!!!!!!!!!#!#$&&&&&&&%(%%%(%%%%%%####!$!!!!!!!#!!#!###%%#############!$$!$!$!!$!!!!!!!!!!!!$!!$$!$!$!$!$!######''####!!!!!!!!!#!!!!%!%%%%#############%%#####!#!!!!!!!!#!####%###$!$!$$!$!$$!$$!$##%%####!!!!#!!#!#%%#####!$!!$!!$!!$!!$!$%%%!!!!!!!",
			"!#!!!!!$!$!$!!$#####%%%$$$$$!$!$!$!!!$!!!!!!!!!!!$!!$!!!!$!$!!$!!$!$!$$%%%%!!!!#!!!!!!!$!$!$!$$$$&&&&%%######!$!$!!!!!!!!!!#!!!######%%%$$!$$$$$%%######!$!!!$!!!!!#!!#!#$&&&&&&$$$$$%$$%%%%%####!!#!!!!!!!!!!(!((%%######$$$%$$$$!$$!$!$!#!!#!!!!!!!!!!$!!$!!$!$!$!$######%%$$$!$!$!!!!!!!#!#!#####%%%##########%%###!##!!#!!!!!!!!!!!!%%%%!$$$!$!$!$!$$!$$!%%%%%!!!#!!!!!#!!#%%#####!$!$!!$!$!$!$!$$#####!#!!!",
			"#!!!!#!!!$!$!$!#####&&&$$$!$$!$!$!$!!!!!!!!!!!!#!!#!!#!$!$!!$!$!$!$!$!$#####!#!!!!!!!#!!#!#!#!!!%%%%%%%%%####!!$!$!!!!!!!!!!!#!!!!!%!%%%####!###%%%%!!!!$!$!!!!!!!!!#!!#!$&&&&&$$######$$%%%%%####!!#!!!!!!!(!!(((%%$$$$%$%%%%%%%$$$$$!$!$!#!!!!!!!!!$!!!$!!$!$!!$!$!######%%####!#!!#!!!!!!!!#!####$%%%%%$$%#%%%%#####!##!!#!!!!!!#!#####%##$!$$!$!$!$!$$!$$#&&&####!!!!#!!!######!!#!!$!$!$!!$!$!$!$%%%!!!!!!!",
			"!#!!!!!!$!$!$!$!$!$$$$$#####!#!$!$!$!!!!!!!!!!!!!#!#!!#!$!$!!$!$!$!$$$$###!#!!!#!!!!!!!$!$!$!$$$!$$$$%%%%%###$$!$!!$!!!!!!!!!!#!$$$$%%%$###!####%%$$$$$$!$!$!!!!!#!!!!#!###%%###########$$$%%%%$$!$!!!!!!!(!!(!(((%%$%%%%%&&&&&&%%%#######!!!#!!!!!!!!!!$!$!$!$!$!$!$#####%%%###!#!#!!!!!!)!#!!##!##$%%%%%%%%%%%%%##$!$$!!$!!!!!!!!!!!!!((((($$$!$!$$!$!$!$$$#&&&####!!!!!#!#!%%%#####!$!!$!!$!!$!$!$!######!!!!",
			"#!!!!!#!!$!$!$!#####%%%$$$!$!$!$!$!!!$!!!!!!!!!!!!#!#!!$!$!$!$!#!##!#######!!#!!!!!!!#!!#!#!#!!##!######%%%##$!$!$!!!#!!#!!!#!!!####%%%########$%%######!!#!!#!!!!!!#!!#!###$######!#######%%%%###!!#!!!!!!!!!&!&&&%%%%&&&&%%%&%&%%%######!#!!!!!!!!!!#!!#!#!!!$!$!$!####%%%%$$$!$!!!#!!!!!!#!#!####$$%%%%%%%%%%%###$$!$$!!!#!!!!!!#!#####%%#$!$$!$!$!$$!$$$$#&&&####!!!!!!#!##%%#####!!$!!$!!$!!$!$!$%%%!!%!!!!",
			"!#!!!!!!!$!$$!$#####&&&%#######!$!$!!!!!!!!!!!!#!!!#!#!!$!$!$!$######%%##!##!!!!!!!!!!!#!#!#!$!$!$!$$#####%%###!#!!#!!!!!!!!!!#!###%%%##$$!$!$$$%%######!$!$!!!!!!!!!#!!#!###!##!$!$!$!$$###%%%##!#!!#!!!!!(!(!(((&&&&&&&$$$$$$$%%%%%%####!!!#!!!!!!!!!!$!$!$!$!$!$!$####%%%%####!!#!!!!!!#!!#!#####%%%&%&&&%%%%%%#####!#!#!!!!!!!!!!!!!!%%%%$$!$$!$$!$!$$!$$&&&&&!!!#!!!#!!#!#%%#####!$!$!!$!!$!$!$!$%%%%!!!!!!",
			"!!!!#!!!!$!$!$!#####&&&$$$$!!$!$!$!$!!!#!!!!!!!!!$!$!!$!$!$!$!$!#!######!##!!#!!!!!!!$!!$!!$!$!!$!$!$!$!$$$$$###!#!!!!!!!!!!#!!!###%%%##!$$!$$$$%%######!#!!!#!!!!!!!!#!#!$!$$!$!$!$!$!$!###%%%%#$!$!!!!!!!!!%!%%%&&&&&$$$#######$%%%%####!#!!!!!!#!!$!!!$!!$!$!!$!$!####%%%%##!##!!#!!!!!!!#!#!####%%%%%$$$%$$$%%$%#####!!#!!!!!!!)!!$!$$$$$$$$$$$!$$$$!$$$$%%%%####!!!!!#!!#%%%%!!!!$!$!$!!$!!$!$!$$$$$!$!$!!!",
			"!#!!!!#!!!$!$!$####&&&&%%######!$!$!!$!!!!!!!!!#!!#!#!#!$!$!$$!####%%%#!##!#!!!#!!!!!!!$!$!!$!$!$!$!$#####%%%##!#!!#!!!!!!!!!!#!###%%%##$!$$!$$$%%######!$!$!!!!!!#!!!!!#!$!$!$!$!$!$!$!$####%%%###!!#!!!!!(!!((((&&&&&###!########%%%%###!!!#!!!!!!!!!!$!$!$!!$!!$!$####%%%####!#!!!!!!!!)!!#!#####%%$$$$$$######%%###!##!!#!!!!!!!#!!#!####%##############%%%%%####!!!!!!$!!$%%$$$$$!$!$!$!!$!$!$!$!%%%%!!!!!!",
			"#!!!!!!!$!$$!$!$$$$$&&&$$$$!$!$!$!$!!!!!!!!!!!!!!!$!!$!$!$!$!$$##%%%###!$!$!!!!!!!!!!!!!$!$!!$!$!$!$!!!$!$$$$###!#!!!#!!#!!!!#!!###%%#####!#####%%######!!#!!#!!!!!!!#!!#!!$!$!$!$!$!$!$!####%%%%#!#!!!!!!!!!&!&&&&&&&####$$!$$!$$##%%%###!$!!!!!!!!!!#!!#!#!$!$!$!$!####&&&#$!$!$!$!#!!!!!#!!!!%%%%%#############%%####!!#!!!!!!!!!!#!!#####%%%###########%%(((((!!!#!!!#!!#!#%%#####!$!$!!$!$!$!$$!$$$$$!$!!!!",
			"!#!!!#!!!$!!$!$#####&&&%#######!!$!$!!!!!!!!!!!!$!!$!$!$!$$!$$$%%%%####!!#!#!#!!!!!#!!#!!#!#!$!!$!$!$######%%####!!#!!!!!!!#!!#!##%%####!$$$!$$$%%######!$!$!!!!!!!!!!#!!$!!$!$!$!$!$!$!$#####%%%##!!#!!!!######''&&&#####!$$!$$!$###%%%##!!#!#!!!!!!!!!#!#!#!$!$!$!$###&&&##$$!$!!!!!!!!#!!#####%%%$#########!###########!!#!!!!!!!!!#!#!###%%%%$$$$####%%%%#%%#####!!!!!!#!##%%#####!$!!$!!$!$!$!$!$%%%!%!!!!!",
			"!!!!!!!$!!$$!$!####&&&&$$$!$!$!$!$!!!$!!!!!!!#!!!$!!$!$!$!$$$$$%%######!$!$!!!!!!!!!!!!$!!$!!$!$!$!$!$!!$!$$$###!#!!!!!!!!!!!!#!###%######!#####%%%!%!!!$!$!!$!!!!!#!!!!#!$!!$!$!$!$!$!$!#####%%%$!$!!!!!!!!!!!&&&''######$!$$!$$$####%%##$!!!!!!!!!!#!!!#!#!$!$!$!$!##%%%%##!##!#!#!!!!!!!!!!!%%%%%####!##!####!########!#!!!!!!!!#!!!!#!###%%&%%%%%$%%%%$%%######!!#!!!#!!#!######!#$!$!$!$!!$!$!$$!$$$$!$!!!!",
			"!#!!!!!!$!!$!$$#####%%%%#######!$!$!!!!!!!!!!!!!!!!$!$!######%%$$$!$!$!#!#!#!!!#!!!!!!!!$!!$!!$!$!$!$!##!####%%!%!!!!#!!#!!!#!!#!#######!$$!$$$$%%$$$$$$!$!$!!!!!!!!!!#!!$!$!!$!$!$!$!$!$!!!!%%%%##!#!!!!!######''%%######!$!$$!$!####&&##!#!#!!!!!!!!!#!!#!!!$!$!$!$###&&###$!$!$!!!#!!!!#!#!#!####$!$$$!$$$$!$$!$$#####!!#!#!!!!!!!!#!!#!##$$%%%%%%%%%%$%$$#####!#!!!!!!#!!##!#####!$$!$!$!$!!$!$!$$%%%!!!!!!!",
			"!!!!#!!!!$!$$!!$$$$$%%%$$$!$$!$!!$!$!!!#!!!!!!!$!!$!$!$#####%%%###!##!#!$!$!!!!!!!!!!$!!!$!!$!!$!!$!$!$!$!$$$$$$!$!$!!!!!!!!!)!!##%%###########%%%######!$!!!$!!!!!!!!!!#!$!$!!$!!!$!$!$!$$$$$$%%##!!#!!!!!!!!((((&&######!$$!$$!$####%%###!#!!!!!!!!!!!!$!!$!$!!$!$$##&&&###!$!$!$!!!!!!!!)!#######!$$!$$!$!$$!$$!$######!!!!!!!!!!#!!!$!$!$####%%%%%%%#####%%######!!!!!!#!!##%#####!$!$!!$!$!$!$$!$#####!#!!!",
			"!#!!!!#!!!$$!$$#####&&&%#######!$!$!!!!!!!!!!!!!!$!$!$!####%%%%$$!$$!$!$!!!$!!!!!!!!!!!$!!$!!$!!$!!$!#!!#####%%!%!!!!#!!#!!!!!########!#$!$$$$$$%#######!$!$!!!!!#!!!!#!!$!!!$!!$!$!$!$!$!!!!%%%%$!$!!!!!!!!!&!&&&&#######$!$$!$$!####%%###!!#!!!!!!!#!!#!#!#!$!$!$!$##&&&###$!$!$!!!#!!!#!!#!######$!$$!$$!$!$!$!$$##%%####!!!!!!!!!!#!!!##!######(($$#####$%%%!%!!!#!!!#!!#!##%%####$!$!$!!$!$!$!$$!####!#!!!!",
			"!!!!!!!!!$!$!$!#####&&&%#######!!$!$!!!!!!!!!#!!!!$!$!$$$$%%%%%$!$!$!$!$!$!!!$!!!!!!!!!!$!!$!!$!!$!$!!$!$!$$$$$$!$!$!!!!!!!!#!!#%#%###########%%%%######!!$!!$!!!!!!!!!!#!$!$!$!$!!$!$!$!$$$$$$%%$$!$!!!!!######''$$$$!$!$!$$!$!$!####%%%###!!#!!!!!!!!!!#!#!!!$!$!$$##%%%###!$!$!!$!!!!!!)!##%#%###!$!$$!$!$!$!$$!$#####!!!#!!!!!!!!!!!$!$!$#!#########!####%%######!!!!!#!!###%%####!$!$!$!!$!$!$!$$%%%!!!!!!!",
			"!#!!#!!$!!$!$!$####&&&&$$$$$!$!$!$!!$!!!!!!!!!!$!!$!$$$##%%%%##$$!$!$!$!$!$!!!!!!!!!!$!!!$!!$!!$!$!!$#!#!####%%!%!!!!#!!#!!!!#!#%%###########%#%%%######!$!$!!!!!!!!#!!!!!$!!$!$!$!$!!$!$!!!!%%%%##!!#!!!!!!!!!&&&%#######!$!$!$!$!$!$$$$$#!#!!!!!!!!!#!!!#!#!$!$!$!$#&&&####!$!!$!!!#!!!!!!####%###!$$!$!$!$!$!$!$!#######!!!!!!!!#!!!!!$!$!!$$!$!$$#######%(((!(!!!!!!!!!#!!##%%####$!$!$!$!!$!$$$!$####!#!!!!",
			"!!!!!!!!!$!$!$!$$$$$&&&&#######!$!$!!!!#!!!!!!!!!$!$!$$##%%%###!$$!$!$!$!!!$!!!!!!!!!!!$!!$!!$!!$!$!!$!$$!$$$$$$!$!$!!!!!!!#!!##%%###########%%%#%%######!#!!#!!!!!!!!!!$!!$!!$!!$!$!$!$!######%%###!!!!!!!!(!(((($$$$!$!$$!$!$!$!####%%%##!!#!!!!!!!!!!$!!$!$!$!$!$$#%%%####!$!$!$!!!!!!!#!!#######$!$$!$!$!$!$!$!$######!#!#!!!!!!!!$!!!$!$$!$!$$!$!$$!$$$$%%######!!!!#!!#!##%%####!$!$!$!$!!$$!$$$###!#!#!!!",
			"!#!!!!!$!!$$$!$####&&&&$$$$$!$!$!$!$!!!!!!!!!!!#!!###!#%%%%####$!$!$!$!!$!$!!!!#!!!!!!!!$!!$!$!$!$!$!#!!#####%%!%!!!!!!!!!!!!#!#%%%%%((%%%%%%%%%%%%#%%##!$!$!!!!!!!!!!#!!$!!$!!$!$!!$!$!$######%%##!!#!!!!!!!%!%%%%#######!$!$!$!$#####%%###!!#!!!!!!#!!!#!!#!$!$$!$$#%%%####!$!$!!!!#!!!!!###%%%###!$!$$!$!$!$!$!$$######!!!!!!!!!!!!!!!$!$!!$!$!$$!$!$!$$$$%%%!!!!!!!!!!#!!!##%%####$!$!$!$!$$!$$!$$####!!!!!!",
			"!!!!#!!!!$!$!$!#####&&&$$$!$$!$!$!$!!!!!!!!!#!!!!$!$!$$#%%#####!$!$!$!$!$!!$!!!!!!!!!!#!!#!#!!$!!!$!$!$!$!$$$$$$!$!$!!!!!!!!#!!##&&&&&&&%&&%&&&%&&&&&&&$$!$!!$!!!!!!!!!!#!$!!$!$!$!$!$!$!!!!!%%%%$$!!!!!!!!(!!(((($$$$!$!$!$$!$!$!#####%%##!#!!!!!!!!!!$!!$!!$!$!$$!$&&&#####!!$!!$!!!!!!)!!!######!$!$!$!$!$!!$!$!$###%%###!!!!!!!!!#!!#!#!#$!$!$!$!######%%%#######!!!!!!!#!##%%####!$!$!!$!!!$!$$$$!##!!#!!!!",
			"!#!!!!!!$!$!$!$####&&&&%#######!!$!$!!!!!!!!!!!!#!#####%%%#####!!$!$!$!$!!$!!!!!!!!!!!!$!$!!$$!$!$!$!!$!$!$$$%%!%!!!!#!!#!!!!!#!##%%%%%%%&%&%&&%&&&&%%%%!$!$!!!!!#!!!!#!!$!$!!$!$!$!$!$!$$$$$$$%%$$!$!!!!!!!!!!&&&%#######!$!$!$!$#####%%#$!!$!!!!!!!!!!$!!$!$!$$!$$$&&&#####!$!$!!$!!!!!!!)##%%%###!$!$!$!$!$!!$!$!######!!#!!!!!!!!!#!!#!#!!$!$!$!$!$!!$$$$$$$!$!!!!!!!!#!!###%%####!$$!$!!$$!$$!$$$####!!#!!!",
			"!!!!!!!$!!$$!$!####&&&&$$$$!$!$!$!$!!$!!!!!!!!#!!$!$$$$&&######!$!$!$!$!$!!$!!!#!!!!!$!!$!$!!!$!$!$!$!#!#####$$$$!$!!!!!!!!!#!!#!$$$$$$$%$$$%$$%&&&$$$$$#!#!!#!!!!!!!!!#!!$!$!$!!$!$!$!$!#####%%%##!!#!!!!######&&$$$!$$!$!$$!$!$!#####%%%##!!#!!!!!!!$!!$!!$!$!$!$$$%%%%!!!!$!$!$!!!#!!!!!!##%%#%##!$$!$!$!$!$!$!$$!#####!!!!!!!!!!!!!#!!#!#!!$!$!$!######&&$$$!$!$!#!!!!!!!!##%%%###$!$!$!$!######%%###!!!!!!!",
			"!#!!!!!!$$!$!$!$$$$$&&&%#######!$!$!!!!!!!!!!!!######&&$$$$$!!$!!$!$!$!!$!$!!!!!!!!!!!$!!$!$$!!$!$!$!######%%%%!%!!!!#!!#!!!!!#!#!############((%%%#####!$!$!!!!!!!#!!!!#!!$!$!$!$!!$!$!$!!!!%%%%$!$!!!!!!!!!!!%%%%#######!$!$!$!$####%%%##!#!!!!!!!!!!!$!$!$!#!#####''$$$$$$!$!$!!!!!!!!#!!###%%###$!$$!$!$!$!$!$!$##%%####!!!!!!!!!!!!$!$!!$!!$!$!$#####%%%####!#!!!!!!!!!#!###%%###!$$$!$!$!!$!$$$$###!#!!!!!",
			"!!!!!!!$!!$$$!$####&&&&$$$$$!$!$!$!$!!!!!!!!!!!!!!!%%%%%%######!$!$!$!$!!$!$!!!!!!!!!!!$!$!$!$$!$!$!$!!$!$$$$$$$!$!$!!!!!!!!!!!!##!#!#####!#####&&######!$!!!$!!!!!!!!#!!$!!$$!$!!$$!$!$!$$$$$%%%##!!#!!!!!!!(!((($$$$!$!$!$!$$!$!#####%%##!!#!!!!!!!!#!!#!#!$!$$!$$$%%%#####!#!!#!#!!!!!!!!!#######!$!$$!$!$!$!$$!$#####!!!!#!!!!!!!#!!!#!#!$!$!$!$!#####&&&$$!$!$!!#!!!!!!!###%%%%##$$!$$!$!$$$$$$%%###!!!#!!!",
			"!#!!!!!!$$!$!$!####&&&&######!#!$!$!!!!#!!!!#!!#####&&&$$$$!$!$!$!$$!$!$!!$!!$!!!!!!!#!#!####!!$!$!$!######%%$$$$!!!!!!!!!!!!!#!$!$!$$!$!$$$!$$$%%%#####!$!$!!!!!!!!!!!!$!###!#!#$!!$!$!$#####%%%$!$!!!!!!!!!!!&&&%%######!$$!$$!$####%%%###!!#!!!!!!!!#!!#!#######&&%%%!%!!!$!$!$!!!#!!!!#!##%%%%##$!$!$!$!!$!$!$$!##%%####!!!!!!!!!!!$!!$!$!$!$!$!$!!!%%%%%###!#!#!!!!!!#!!!###%%%##$$$!$$!$#####%%%###!#!!!!!",
			"!!!!!!!!!$$!$!$####%%%%%#######!!$!$!!!!!!!!!!!#####&&&#######!$!$!$!$!$!$!$!!!!!!!!!#!######!$!$!$!$!$!$!$$$###!#!#!!!!!!!#!!!!$!$$!$!$#!#!####&&######!!$!!!!!!!!!!!#!###!##!#!!$!$$!$!!!!%%%%%$!!$!!!!!!(!(!(((%%######!$!$!$$!####%%###!#!!!!!!!!)!!)!!)!!!!(!((('#######!$!!!$!!!!!!!!!!!(((((($!$$!$!$$!$!$!$$#####!!!!!!!!!!!!!!!$!$!!$!$!$!$!$$$$%%%$$!$$!$!!!!!!!!!!####%%%##$!$$!$$!#####%%%!$$!!!!!!!",
			"!!!!!!!!$!$$!$!$$$$&&&&$$$$!$!$!$!$!!!!!!!!!!!!!!&!&&&&$$$$$!$$!$!$!$!$!$!$!!!!#!!!!!####%%##$!$!$$!$######''####!!!!#!!#!!!!!!!$!$!$!$!$$!$$!$$&&######!$!$!!$$!!!!!!!##$$$$!$!$!!$!$!$$$$$$$%%$##!!#!!!!!!!!!!&&$$$$!$!$!$$!$!$$####%%###!!#!!!!!!!!!#!##!#######&&$$$$!$!!$!!$!!!!#!!!!!####%%%##$$!$!$$!$!$!$$!$######!!#!!!!!!!!!)!!)!)!!$!!$!$$####%%####!##!!#!!!!!!!!!####%%%#$$$$$!$$####%%%####!!#!!!!",
			"!#!!!!!$!$!$!$$#####&&&%#######!$!$!$!!!!!!!!!!$$$$$%%%######!#$$!$$!$$!$!$!$!!!!!!!!!!!&&&&!$!$$!$$!#####%%%$$!$!$!!!!!!!!!!!)!!$!$!$!$!##!####%%######!!$!!!!!!!!!!#!##%%######!$!$$!$!####%%%#!$!!!!!!!!!#!####&&######!!$$$!$!###%%%##!$!!!!!!!!!!!!)!!)!######&&'#######!$!!$!!!!!!!!!!!!!%%%%%$!$$$!$!$!$!$!$$%%%%!!!!!!!!!!!!!!!!#!#!#!!$!$!$!###%%%##!$!$!$!!!!!!!!!#!####%%%%$$$!$$!$####%%%#$$!$!!!!!!",
			"!!!!!!!!$!$!$!!####%%%%$$$$!$!!$!$$!!!!!!!!!!!!!#######$####$$#!$$!$$$!$!$$!!!!!!!!!!####%%%#$$!$$!$$#####%%%###!#!!!!!!!!!!!!!!)!)!)!)!#!##!###%%%!%!!!$$!!$!!!!!!!!!!))&&&!!!!!$!$!$$$$###%%%##$!!$!!!!!!!!!!###&&######!$!$$$$$###%%####!!#!!!!!!!!$!!$!$!!!!!&&&&$$$!$!!$!!$!!$!!#!!!!!!#####%%#$$$!$$!$$!$!$$$$$$$$$$!!#!!!!!!!!!!!)!!)!$!!$!$!$##%%%###$!$!$!!!#!!!!!!!!#####&&&$##$#######%%%#####!!!#!!!",
			"!!!!!!!!!$!$!$!#####&&&$$!$$!$!$!$!$!!!#!!!!!#!###%#%##$######$$!$$$!$!$$!$!$!!!!!!!!!!(!((((###!########%%%##!##!!#!!!!!!!!!!!!$!!$!$!$!$!$!$$$&&######!!$!!!!!!!!!!!#!#&&&$$$$$!$!$$$$!###%%%##!$!!!!!!!)!!!)!))%%%#####!$$$$$$!##%%%###!$!!!!!!!!!!!)!!)!)######''$$$!$!$!$!!$!!!!!!!!!!!!!##########!##!######%%#####!#!!!!!!!!!!!)!!)!!!#!#!#!###%%%####!$!$!$!!!!!!!!!!!######&&%%########%%%%##!$!$!!!!!!",
			"!#!!!!!)!))!)!)#####&&&$$$$!$!$!$!$!!!!!!!!!!!!###&&#####%####%$$##$##$$$$!$!!!#!!!!!)))))&&&%#####%####%%%##$!$!$!!!!!!!!!!!!)!!)!!)!)!#!#!####%%######!$!$!!!!!#!!!!!##&&&&####!#########%%%%##!#!#!!!!!!!!!!####&&&#######%#####%%%####!!!#!!!!!!!)!!)!!)!#####&&&####!#!#!$!!$!!!#!!!!!!!!!%!%%%%%###########%%%###!#!!!#!!!!!!!!!!!)!!)!!$!$!$!$%%%#####!!$!$!$!!!!!!!!!)!$!!$$$$%%%%#%%##%%%####$!$!!!!!!!",
			"!!!!!!!!#!!#!#!#####%%%$$!$$!$!$!$!$!!!!!!!!!!!###&&&##%(%%%%%%%%%%####$$$$!!!!!!!!!!!!!(!(((%%%###%###%%%###!$!$!!$!!!!!!!!!!!!)!)!!)!)!$!$!$$$%%%%!!!!$!$!!$!!!!!!!)!!)#&&&&###)########&&&&###!#!!!!!!!!!!!)!!)##&&&######%##%#%%%%####!$!!!!!!!!!!!!!$!!$!!!!&&&&$$$!$!$!!!$!!$!!!!!!!!!#!#!####%%%%########%%%#####!#!!!!!!!!!!!!!!!)!!)!!$!$!$$%%%#####!$!$!!!!#!!!!!!!!#!##!###'%%%%%%%%%%#####!$$!!$!!!!",
			"!!!!!!!!!!!!)!)######%%$$$!$!$!$!$!!$!!!!!!!!!!####&&&#%%%&%%%%%%%%%$%%$$$$!$!!!!!!!!#!!!####'%'%%%%%%%%%####$!$!$!!!!!!!!!!!!!!!!!$!$!$!##!####&&$$$$$$!$!!!!!!!!!!!!#!!##&&&&#########%%%%%####!!!#!!!!!!!#!!!#!###&&&&#$$$%$$%%&&######!!!#!!!!!!!!)!!!)!)#####&&&$$!$!$!$!$!$!!!!#!!!!!!!)!)!!))%%%%%%$%%%%%%%####!##!#!!!!!!!!!!!)!!!)!!$!!$!$$$%%%!%!!!$!$!$!$!!!!!!!!!!!#!!####$%%%%%%%$$$$!$!$$!$!!!!!!!",
			"!!!!!!!!)!!!!)!!#!#####$$!$!$!$!$!$!!!!!!!!!!!!!!!(((((#######%%%###%%%%%%!!!!!#!!!!!!)!!!)!)##&&&&&&%%######!$!$!!!!#!!#!!!!!!!)!!!!)!)$!$!$$$$%%######!$!$!!!!!!!!!!!)!!!&&&&&&%%%$%%%%&&&#####!$!!!!!!!!!!!!)!!#####&&&&&%%%&&%#####!#!$!!!!!!!!!!!!!)!!!!####&&&&$$$!$!$!$!$!!$!!!!!!!!!!!!!!#!###%%%%%%%%%%####!$$!$!!!#!!!!!!!!!!!!!!!)!#!!####&#######!$!$!$!!!!!!!!!)!!!!)!)!)!#######$$!$$!$!$$!$!!!!!!",
			"!#!!!!!)!!!)!!)!!##!###!$$!$!$!$!$!$!!!#!!!!!#!#!#!########!#########((#####!#!!!!!)!!!!)!!))#####%#%####!#!!$!$!!$!!!!!!!!!!!)!!!!)!!)!!$!$!$$$####!#!!$!$!!$!!!!!!!)!!!####&&&&'&&&&&&&((((!!!!$!!$!!!!!!!!)!!)!!!(!((((%%%%%%$%###!##!#!$!!!!!!!!!)!!!!!)!!!(((((($!$!$!!$!!!$!!!!!!!!!!!)!!)!!)!#!##########!#!#$!!$!$!!!!!!!!!!!!!)!!!!!!!#!#!##$$!$!!$!!$!!$!!!#!!!!!!!!#!!!#!##!#!#!###!$$!$$!$!$!!!$!!!!",
			"!!!!!)!!!)!!))!$$!$!$!$!$!$!$!$!$!$!!!!!!!!!!!!!)!)))))#####!!#!#!########!#!!!!!!!!!)!)!)!)!#!###!##!$!$$!$$!$!$!!!!!!!!!!!!!!!)!)!)!!)!$!$!$$$''######!$!$!!!!!!!!!!!)!)!!)))))&&%%&&&%$$$!$$!$!$!!!!!!!!!!!)!!))!))))))%##%#%##$!$$!$!$!!)!!!!!!!!!!!!)!!)!#!#####!$!$!$!!$!$!!$!!#!!!!!!!)!!!)!)!#!##!##$!$!$!$!$!$!$!!!)!!!!!!!!!!!!!)!)!)!)!)!!$!$!$!!$!$!$!!$!!!!!!!!)!!)!)!)!)$!$!$!!$!!$$!$$!$!$!!!!!!!",
			"!!!!!!!)!))))))))))!!!!$!$$$$$$!$$!!$!!!!!!!!!)!)))))))))))!)!!############!#!!!!!!!!!)!))))))))!!)!)$$$!$$!$$!$!$!!!!!!!!!!!!)!!)!)))))!!!!!%%%'#######!)!!)!!!!!!!!)!!)!)))))))####%###$!$$!$$!)!!)!!!!!!!!!!)!)))))*)))!#!#####)####)##!)!!!!!!!!!!)!)!)!)***#####!!$!$!$$!$!$!!!!!!!!!!!!!)!))))))))!)!!$!$$!$$$!$!$!$!!!!!!!!!!!)!!)!)!)!))!)!)!!$!$!$$$!$$!$!!!!!!!!!!!)!)))))))$$!!!$!$$$!$$!$$$$!$!!!!!!",
			"!!!!!!!!))))))))))!!!)!#)#)###)))))!!)!!!!!!!!!)))))++))))!!!!)##))##)#$$$$!!$!!!!!)!))))))),)))!!!!)#)))#)#)))))!)!!!!!!!!!)!!)))))))*)))!)!!))%)))))))$$$!!!!!!!!!!!)!))),),)))!!#!####))$)$))$!$!!!!!!!!!)!)!)))))))))!!!)!)))))#)#)#)#!!)!!!!!!*!!!)!)))))))!!!!!$$!$$$!$)))!)!)!!!!!!!)!!))))))))))!!!!$$!$$$!$$$$!$!$!!!!!!!!!!!)!)!)))))))!!!!$!$$$$!$$!$$$!$!!!!!!!)!!$)))))))))!!!!)!$)$)$$)$!))!)!!!!!",
			"!!!!!)!))))+)))))!!!!!!))))!)))$$$!$!!!!!!!!!)!))))')'))))!!!!!#))#)#))))))!)!!!!!!!)!)))))))))!!)!!!$))$)$)$$$$!$!$!!!!!!!!!)!!))),,)))!!!!#!##'#######))!)!)!!!!!!)!!)))))))))!)!!)!))))#)))#)))!)!!!!!!!!!)!))))'))))))!#!#!###)))$))$)!$!$!!!!!!)!)))))))))!)!!!!!)))!)))$$$$!$!!#!!!!!!)!))))))))))!!!!!))))))))))))!)!!!!!!!!!*!!)))))))))!)!!!!)))))))))))!)!)!!!!!!!)!)))')))))!)!!!!))$)$))$)$$!$!!!!!!",
			"!!!!!!*!!!*****)!!)!!!!!)!))!)!)!)!!)!!!!!!!!)!!!)!)!))))!!)!!!!)!))!))#!#!#!#!!!!)!!!)!))))))!!!!!!!)!))!)!))!!)!)!!!!!!!!!!!)!!!))))!)!)!!!!!)#*##*#*#!!$!$!!!!!!!!)!!)!))))!)!!$!!$!$!))!))!)!!$!$!!!!!!)!!)!!)!)))!)!!)!!!!))!)!)!)!)!)!)!!!!!!!!!!!,,,,,)))!!)!!)!)))!))!))!)!)!!!!!!)!!)!))))))))!!)!!!)))))))####!#!#!!!!!!!!!)!!)))))****!!!!!!))!)))#####!#!!!!!!)!!)!)))))))!!!!#!!#)!)!)))))!)!)!!!!!",
			"!!!!!!!!)!!!)!!!)!!!!!!$!!!!$!!)!!)!!!!!!!!!!!!)!!)!)!!!!)!!!!!#!#!!#!!!!!)!!!!!!!!!)!!)!!)!!)!)!!!)!!#!!#!#!!)!!)!!!!!!!!!!!!!*!*!!!*!*!!!#!!#!#!#!!#!!)!!)!!!!!!!!!!)!!)!)!!)!)!!#!!#!#!#!#!#!#!)!!!!!!!!!!)!)!)!)!))!)!!#!#!#!#!$!$!$!!$!!!!!!!!!*!)!!)!)!*!!!!!!!!$!!!$!!)!!!!)!!!!!!!!)!!)!!)!)!*!!!!!!#!!!!#!!!)!!)!)!!!!!!!!!!!*!!!*!*!)!!!)!!$!!!$!!!!)!!!)!!)!!!!!!)!!!!!*!!*!)!!!!!!!)!)!!!!!#!!!#!!!!",
			"!!!!!!!!!)!)!!))!!)!!)!!)!)!!)!!)!!!!!!!!!!!!!!!)!!)!))!)!)!!)!!)!)!)!)!)!!!!!!!!!!!!!!)!)!)!!$!!$!!$)!))!)!)!!$!!!!!!!!!!!!!!!!)!)!)!)!#!#!!#!#))!))!)!!)!!!!!!!!!!!!!)!)!)))!)!$!!$$!$$)!)!)!)!!!!!!!!!!!!!!!!)!)!)!))!)#!#!#!##)!)!)!)!!!!!!!!!!!!!!)!!)!)!)!)!!)!)!)!)!)!!)!)!!!!!!!!!!!)!!)!)!)!)!)!)!!!)!)!)!)!!)!!!!!!!!!!!!!!!!!)!!)!)!!)!!!!!)!)!)!)!!!)!!!!!!!!!!!!!)!)!!)!!)!!!!)!)!)!!)!)!!!)!!!!!!!",
			"!!!!!!!)!!!!)!!!)!!!!!!)!)!)!!!!!!!!!!!!!!!!!!!!!!!!)!!)!!!)!!!)!!!)!!!!!!!!!!!!!!!!!!!!!!)!)!!)!!)!!!$!!$!!!#!!!!!!!!!!!!!!!!!!!!!!!)!!)!!)!!)!#!#!!#!!!!!!!!!!!!!!!!!!!!)!!!)!)!#!#!#!!!#!#!!!!#!!!!!!!!!!!!!!!!!)!)!!)!!#!#!#!!#!#!!!!!#!!!!!!!!!!!!!)!!)!!)!!)!!!$!$!$!!$!!!!!!!!!!!!!!!!!!!)!)!!)!)!!)!$!$!$!$!#!!#!!!!!!!!!!!!!*!!!*!!!!)!!)!)!!!)!)!)!!)!!!!!!!!!!!!!!!!!!)!!)!!)!)!!!!)!)!!)!!#!!!!!!!!!",
			"!!!!!!!!!!!!!!!!!!*!!!!!!!!!)!!#!!!!!!!!!!!!!!!!!*!!!!!!!*!!!!!!!)!!)!!!!!!!!!!!!!!!!*!!!!!!!*!!!!!!!!!)!!)!!!!!!!!!!!!!!!!!!!!!!!*!!!!!!*!!!!!!!!!)!!!!#!!!!!!!!!!!!!!!!!!!*!!!!!!!!!!)!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!)!!!!!!!!!!!!!!!!!!*!!!!!!!!!)!!!)!!!)!!)!!!!!!!!!!!!!!!!!!!!!!!!!)!!!)!!!!)!!!)!!!!!!!!!!!!!!!!!!!!!!!!!*!!!*!!!!!#!!#!!!#!!!!!!!!!!!!!!!!!*!!!*!!!!!!!!!)!!!!)!!!!!!!!!!!!!!",
			"!!!!!!!!!!!!!!!*!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*!!!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*!!!!!!!!!!!!)!!!!!!!!!!!!!!!!!!!!!!!!!!!*!!!!!!!)!!!!!!!!!!!!!!!!!",
			"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" };
}
