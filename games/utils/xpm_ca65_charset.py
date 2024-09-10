#!/usr/bin/python3

import argparse
import re

def bitmap(colors, line):

  # print ("%s" % line)
  _bt = 0
  bytes = ""
  for x in range(0, len(line)):
    _bt |= colors[line[x]] == 0 or 1
    print ("%x %c %d $%02x" % (x, line[x], colors[line[x]], _bt))
    if x % 8 == 1:
      if x > 8:
        bytes += ", "
      bytes += "${:02x}".format(_bt)
      _bt = 0
    _bt<<=1
  print (".byte %s" % bytes)

#  print (".byte %%%s" % (line.replace("!", _bit_1).replace(" ", _bit_0)))

def main():
  parser = argparse.ArgumentParser(description='xpm to ca65 compatible include file')
  parser.add_argument('filename', help="file to transform")
  args = parser.parse_args()
  try:
    with open(args.filename, newline='\n') as xpm_file:
      xpm_content = xpm_file.read()
    xpm_file.close()
  except IOError:
    print("%s: file '%s' not found\n" % (sys.argv[0], args.filename, ))
    sys.exit(1)

  xpmLines = xpm_content.split("\n")

  if len(xpmLines) < 3:
    sys.exit(1)
  cols = xpmLines[2].split(" ")
  w = int(cols[0][1:])
  h = int(cols[1])
  colors=int(cols[2]) # determine color count

  offset = 3+colors
#  print ("%sx%s %s %s" % (w, h, colors, offset))

  color_arr= dict()
  for i in range(0, colors):
    color_arr.update({xpmLines[3+i][1]:i})

#  print ("colors: %s" % color_arr)
  print ("; charset resource file generated from %s" % (args.filename))
  char_bytes = []
  char_lines = []
  for ix, ln in enumerate(xpmLines[offset:]):
    byt = 0
    ln = ln.split("\"")[1]
    line = ";"
    for i,b in enumerate(ln):
      byt |= 0 if color_arr[b] == 0 else (1<<(7-i))
      # print ("%s $%02x $%02x $%02x" % (b, byt, color_arr[b], (1<<(7-i))))
      line += "." if color_arr[b] == 0 else "#"
    char_lines.append(line)
    char_bytes.append(byt)
    if ix != 0 and ix % 8 == 7:
      print (".byte " + ",".join(["${:02x}".format(e) for e in char_bytes]) + " ; (${:02x})".format(ix+1>>3))
      for ln in char_lines:
        print(ln)
      char_bytes.clear()
      char_lines.clear()
    if ix == h-1:
      break

if __name__ == "__main__":
    main()
