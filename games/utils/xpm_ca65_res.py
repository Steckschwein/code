#!/usr/bin/python3

import argparse
import sys

_bit_1 = "1"
_bit_0 = "0"

def spriteline(line):
  print (".byte %%%s" % (line.replace("!", _bit_1).replace(" ", _bit_0)))

def spritelines(lines):
  for line in lines:
    spriteline(line)

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

  xpmLines = xpm_content.replace("%",'').replace('"','').replace('}','').replace(';','').split("\n")

  if len(xpmLines) < 3:
    sys.exit(1)

  cols = xpmLines[2].split(" ")

  w = int(cols[0])
  h = int(cols[1])
  colors=int(cols[2]) # determine color count

  offset = 3+colors

  bits = 8

#  print("%s" % bits)
#  print ("%s %s" % (colors, offset))

  _2ndcol_arr=[]
  for ix, ln in enumerate(xpmLines[offset:]):
    #print("%d" % len(ln))
    if ix % bits == 0:
      spritelines(_2ndcol_arr)
      _2ndcol_arr=[]
    spriteline(ln[1:9])
    _2ndcol_arr.append(ln[9:17])
    _2ndcol_arr.append(ln[17:25])
  spritelines(_2ndcol_arr)

if __name__ == "__main__":
    main()
