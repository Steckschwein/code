#!/usr/bin/python3

import argparse

def bitmap(colors, line):

  # print ("%s" % line)
  _bt = 0
  bytes = ""
  for x in range(0, len(line)):
    _bt |= colors[line[x]]
    # print ("%x %c %d $%02x" % (x, line[x], colors[line[x]], _bt))
    if x % 4 == 3:
      if x > 4:
        bytes += ", "
      bytes += "${:02x}".format(_bt)
      _bt = 0
    _bt<<=2
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
  print ("; file generated from %s" % (args.filename))
  print ("; .byte $%02x, $%02x ; width, height" % (w>>3, h>>3))
  for ix, ln in enumerate(xpmLines[offset:]):
    bitmap(color_arr, ln.split("\"")[1])
    if ix == h-1:
      break

if __name__ == "__main__":
    main()
