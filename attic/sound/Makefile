
%.bin: %.a
	acme -vv -f plain --cpu 65c02 -o $@ $<

all: imfplayer.bin 

clean:
	rm -f *.bin
soundtest: soundtest.bin
	../xmodem.sh soundtest.bin

synth: synth.bin
	../xmodem.sh synth.bin    
    
imfplayer: imfplayer.bin
	../xmodem.sh imfplayer.bin    

transfer: all
#	../xmodem.sh synth.bin
#	../xmodem.sh soundtest.bin
	../xmodem.sh imfplayer.bin 
