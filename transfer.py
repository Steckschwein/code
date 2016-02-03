#!/usr/bin/python

import argparse
import serial
import sys
import os
import struct

devicerequired=False

device=None
try:
	device = os.environ['TRANSFER_DEVICE']
except KeyError:
	devicerequired=True

parser = argparse.ArgumentParser(description='transfer binary via serial interface')
parser.add_argument('-d', '--device', help="serial device. can also be set with environment variable TRANSFER_DEVICE.", required=devicerequired)
parser.add_argument('-b', '--baudrate', type=int, help="baud rate. default 115200", required=False, default=115200)
parser.add_argument('-s', '--startaddr', help="start address. default 0x1000", required=False, type=int, default=0x1000)
parser.add_argument('filename', help="file to transfer")

args = parser.parse_args()

print args

try:

	with open(args.filename, 'r') as content_file:
		content = content_file.read()

	length = len(content)


	ser = serial.Serial(
		#port='/dev/tty.usbserial-FTGXH8UA',
		#port='/dev/cu.usbserial-FTAJMAUJ', 
		port=args.device,
		baudrate=args.baudrate,
		bytesize=8, 
		parity=serial.PARITY_NONE, 
		stopbits=1,
		xonxoff=0, 
		rtscts=0,
		timeout=5
	)
	

	print "Startaddress : 0x%04x (%d)" % (startaddr, startaddr)
	print "Length    	: %d bytes" % (length)

	ser.flushOutput()

	bytes = ser.write(struct.pack('<H', startaddr))
	if ser.read(2) == 'OK':
		print "Start address %d bytes" % (bytes, )

	bytes = ser.write(struct.pack('<H', length))
	if ser.read(2) == 'OK':
		print "Length %d bytes" % (bytes, )
		
	bytes = ser.write(content)
	if ser.read(2) == 'OK':
		print "Length %d bytes" % (bytes, )
		print "Bytes transferred: %d" % (bytes, )

	ser.close()

except IndexError:
	print "%s <filename>" % (sys.argv[0],)
	sys.exit(1)
except IOError:	
	print "%s: file '%s' not found" % (sys.argv[0], args.filename, )
	sys.exit(1)



