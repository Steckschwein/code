#!/usr/bin/python3

import argparse

_bit_1 = "1"
_bit_0 = "0"
  
def main():
  parser = argparse.ArgumentParser(description='xpm to resource ca65 res include file')
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
  colors=int(xpmLines[2].split(" ")[2])
  offset = colors+3
  
#  print ("%s %s" % (colors, offset))
  
  _2ndcol_arr=[]
  for ix, ln in enumerate(xpmLines[offset:]):
    if ix % 16 == 0:
      for r in _2ndcol_arr:
        print (".byte %%%s" % (r.replace("!", _bit_1).replace(" ", _bit_0)))
      _2ndcol_arr=[]
    print (".byte %%%s" % (ln[1:9].replace("!", _bit_1).replace(" ", _bit_0)))
    _2ndcol_arr.append(ln[9:17])
    
if __name__ == "__main__":
    main()