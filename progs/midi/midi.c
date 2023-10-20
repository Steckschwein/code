#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <math.h>
#include <stdint.h>
#include <errno.h>

#include <ym3812.h>
#include <steckschwein.h>


struct midi_channel {
    int inum;
    unsigned char ins[11];
    int vol;
    int nshift;
    int on;
  };

struct midi_track {
    unsigned long tend;
    unsigned long spos;
    unsigned long pos;
    unsigned long iwait;
    char on;
    unsigned char pv;
};

/* logarithmic relationship between midi and FM volumes */
static int my_midi_fm_vol_table[128] = {
   0,  11, 16, 19, 22, 25, 27, 29, 32, 33, 35, 37, 39, 40, 42, 43,
   45, 46, 48, 49, 50, 51, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62,
   64, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 75, 76, 77,
   78, 79, 80, 80, 81, 82, 83, 83, 84, 85, 86, 86, 87, 88, 89, 89,
   90, 91, 91, 92, 93, 93, 94, 95, 96, 96, 97, 97, 98, 99, 99, 100,
   101, 101, 102, 103, 103, 104, 104, 105, 106, 106, 107, 107, 108,
   109, 109, 110, 110, 111, 112, 112, 113, 113, 114, 114, 115, 115,
   116, 117, 117, 118, 118, 119, 119, 120, 120, 121, 121, 122, 122,
   123, 123, 124, 124, 125, 125, 126, 126, 127
};

/*
const unsigned char sbi[]={
    0x53,0x42,0x49,0x1d,
    0x4A,0x75,0x63,0x65,0x4F,0x50,0x4C,0x56,0x53,0x54,0x69,0x20,0x69,0x6E,0x73,0x74,
    0x72,0x75,0x6D,0x65,0x6E,0x74,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x00,
    
    0x03,0x00,0x1B,0x00,0xFB,0xF4,0xAA,0xFA,0x00,0x00,0x00,

    0x20,0x20,0x20,0x20,0x20       
};
const unsigned char SBI_SIGN[] = {'S', 'B', 'I', 0x1d};//workaround
const unsigned char sbi_regs[] = {0x20, 0x23, 0x40, 0x43, 0x60, 0x63, 0x80, 0x83, 0xe0, 0xe3, 0xc0};
*/
// Map CMF drum channels 11 - 15 to corresponding AdLib drum channels
const int percussion_map[] = { 6, 7, 8, 8, 7 };

const unsigned int fnums[] = {
        0x16B	,//277.2	C#
        0x181	,//293.7	D
        0x198	,//311.1	D#
        0x1B0	,//329.6	E
        0x1CA	,//349.2	F
        0x1E5	,//370.0	F#
        0x202	,//392.0	G
        0x220	,//415.3	G#
        0x241	,//440.0	A
        0x263	,//466.2	A#
        0x287	,//493.9	B
        0x2AE	//523.3	C    
};

const char sbi_files[][9] = {
    "snare\0",
    "RighBass\0",
    "Lead\0",
    "HH\0",
    "Flute\0",
    "BD\0",
    "Basstrin\0",
    "bass1\0",
    "ArpSynth\0"
};

#define midiprintf printf
// AdLib melodic and rhythm mode defines
#define ADLIB_MELODIC	0
#define ADLIB_RYTHM	1

#define LUCAS_STYLE   1
#define CMF_STYLE     2
#define MIDI_STYLE    4
#define SIERRA_STYLE  8

// File types
#define FILE_LUCAS      1
#define FILE_MIDI       2
#define FILE_CMF        3
#define FILE_SIERRA     4
#define FILE_ADVSIERRA  5
#define FILE_OLDLUCAS   6

struct midi_channel ch[16];
int chp[18][3];
struct midi_track track[16];
unsigned char myinsbank[128][16]; //, smyinsbank[128][16];
unsigned char curtrack;
unsigned long flen;
unsigned long pos;
unsigned char *data;

unsigned long iwait;
int type,tins,stins;
unsigned char adlib_data[256];
int adlib_style;
int adlib_mode;

long deltas;
long msqtr;
unsigned char fwait;

void midi_write_adlib(unsigned int r, unsigned char v);
void midi_fm_instrument(int voice, unsigned char *inst);
void midi_fm_percussion(int ch, unsigned char *inst);
void midi_fm_volume(int voice, int volume);
void midi_fm_playnote(int voice, int note, int volume);
void midi_fm_endnote(int voice);
void midi_fm_reset();

void midi_write_adlib(unsigned int r, unsigned char v){
    opl2_write(v, r);
}

void midi_fm_instrument(int voice, unsigned char *inst){

}

void midi_fm_percussion(int ch, unsigned char *inst){

}

void midi_fm_playnote(int voice, int note, int volume){

}

void midi_fm_endnote(int voice){

}

unsigned char datalook(long pos){

    if (pos<0 || pos >= flen) return(0);
    return(data[pos]);
}

unsigned long getnext(unsigned long num){

	unsigned long v=0;
	unsigned long i;

    for (i=0; i<num; i++){
        v<<=8;
        v+=datalook(pos); pos++;
    }
    return(v);
}

unsigned long getval()
{
	unsigned long b, v = 0;
	do {
		b = getnext(1);
		v = (v << 7) + (b & 0x7f);
	} while (b & 0x80);
	return v & 0x0fffffff; // limit value to allowed range
}

#define true 1
#define false 0

unsigned char load(FILE *fd)
{
    int good;
    unsigned char s[6];
    uint32_t size;

    f->readString((char *)s, 6);
    size = u32_unaligned(s); // size of FILE_OLDLUCAS
    good=0;
    subsongs=0;
    switch(s[0])
        {
        case 'A':
            if (s[1]=='D' && s[2]=='L') good=FILE_LUCAS;
            break;
        case 'M':
            if (s[1]=='T' && s[2]=='h' && s[3]=='d') good=FILE_MIDI;
            break;
        case 'C':
            if (s[1]=='T' && s[2]=='M' && s[3]=='F') good=FILE_CMF;
            break;
        case 0x84:
	  if (s[1]==0x00 && load_sierra_ins(filename, fp)) {
	    if (s[2]==0xf0)
	      good=FILE_ADVSIERRA;
	    else
	      good=FILE_SIERRA;
	  }
	  break;
        default:
            if (size == fp.filesize(f) && s[4]=='A' && s[5]=='D') good=FILE_OLDLUCAS;
            break;
        }

    if (good!=0)
		subsongs=1;
    else {
      fp.close(f);
      return false;
    }

    type=good;
    f->seek(0);
    flen = fp.filesize(f);
    data = new unsigned char [flen];
    f->readString((char *)data, flen);

    fp.close(f);
    rewind(0);
    return true;
}

unsigned char update(){

    long w,v,note,vel,ctrl,nv,x,l,lnum;
    int i=0,j,c;
    int on,onl,numchan;
    int ret;
    char doing = 1;
    unsigned char tmp;

    if (doing == 1) {
        // just get the first wait and ignore it :>
        for (curtrack=0; curtrack<16; curtrack++)
            if (track[curtrack].on)
            {
                pos=track[curtrack].pos;
//                if (type != FILE_SIERRA && type !=FILE_ADVSIERRA)
  //                  track[curtrack].iwait+=getval();
    //            else
                    track[curtrack].iwait+=getnext(1);
                track[curtrack].pos=pos;
            }
        doing=0;
    }

    iwait=0;
    ret=1;

    while (iwait==0 && ret==1)
        {
        for (curtrack=0; curtrack<16; curtrack++)
        if (track[curtrack].on && track[curtrack].iwait==0 &&
            track[curtrack].pos < track[curtrack].tend)
        {
        pos=track[curtrack].pos;

		v=getnext(1);

        //  This is to do implied MIDI events.
        if (v<0x80) {v=track[curtrack].pv; pos--;}
        track[curtrack].pv=(unsigned char)v;

		c=v&0x0f;
        midiprintf ("[%2lX]",v);
        switch(v&0xf0)
            {
			case 0x80: /*note off*/
				note=getnext(1); vel=getnext(1);
                for (i=0; i<9; i++)
                    if (chp[i][0]==c && chp[i][1]==note)
                        {
                        midi_fm_endnote(i);
                        chp[i][0]=-1;
                        }
                break;
            case 0x90: /*note on*/
              //  doing=0;
                note=getnext(1); vel=getnext(1);

		if(adlib_mode == ADLIB_RYTHM)
		  numchan = 6;
		else
		  numchan = 9;

                if (ch[c].on!=0)
                {
		  for (i=0; i<18; i++)
                    chp[i][2]++;

		  if(c < 11 || adlib_mode == ADLIB_MELODIC) {
		    j=0;
		    on=-1;onl=0;
		    for (i=0; i<numchan; i++)
		      if (chp[i][0]==-1 && chp[i][2]>onl)
			{ onl=chp[i][2]; on=i; j=1; }

		    if (on==-1)
		      {
			onl=0;
			for (i=0; i<numchan; i++)
			  if (chp[i][2]>onl)
			    { onl=chp[i][2]; on=i; }
		      }

		    if (j==0)
		      midi_fm_endnote(on);
		  } else
		    on = percussion_map[c - 11];

                  if (vel!=0 && ch[c].inum>=0 && ch[c].inum<128) {
                    if (adlib_mode == ADLIB_MELODIC || c < 12) // 11 == bass drum, handled like a normal instrument, on == channel 6 thanks to percussion_map[] above
		      midi_fm_instrument(on,ch[c].ins);
		    else
 		      midi_fm_percussion(c, ch[c].ins);

                    if (adlib_style & MIDI_STYLE) {
                        nv=((ch[c].vol*vel)/128);
                        if ((adlib_style&LUCAS_STYLE)!=0) nv*=2;
                        if (nv>127) nv=127;
                        nv=my_midi_fm_vol_table[nv];
                        //if ((adlib_style&LUCAS_STYLE)!=0)
                          //  nv=(int)((float)sqrt((float)nv)*11);
                    } else if (adlib_style & CMF_STYLE) {
                        // CMF doesn't support note velocity (even though some files have them!)
                        nv = 127;
                    } else {
                        nv=vel;
                    }

		    midi_fm_playnote(on,note+ch[c].nshift,nv*2); // sets freq in rhythm mode
                    chp[on][0]=c;
                    chp[on][1]=note;
                    chp[on][2]=0;

		    if(adlib_mode == ADLIB_RYTHM && c >= 11) {
		      // Still need to turn off the perc instrument before playing it again,
		      // as not all songs send a noteoff.
		      midi_write_adlib(0xbd, adlib_data[0xbd] & ~(0x10 >> (c - 11)));
		      // Play the perc instrument
		      midi_write_adlib(0xbd, adlib_data[0xbd] | (0x10 >> (c - 11)));
		    }

                  } else {
                    if (vel==0) { //same code as end note
		        if (adlib_mode == ADLIB_RYTHM && c >= 11) {
		            // Turn off the percussion instrument
		            midi_write_adlib(0xbd, adlib_data[0xbd] & ~(0x10 >> (c - 11)));
                            //midi_fm_endnote(percussion_map[c]);
                            chp[percussion_map[c - 11]][0]=-1;
                        } else {
                            for (i=0; i<9; i++) {
                                if (chp[i][0]==c && chp[i][1]==note) {
                                    // midi_fm_volume(i,0);  // really end the note
                                    midi_fm_endnote(i);
                                    chp[i][0]=-1;
                                }
                            }
                        }
                    } else {
                        // i forget what this is for.
                        chp[on][0]=-1;
                        chp[on][2]=0;
                    }
                  }
                  midiprintf(" [%d:%d:%ld:%ld]\n",c,ch[c].inum,note,vel);
                }
                else
                midiprintf ("off");
                break;
            case 0xa0: /*key after touch */
                note=getnext(1); vel=getnext(1);
                /*  //this might all be good
                for (i=0; i<9; i++)
                    if (chp[i][0]==c & chp[i][1]==note)
                        
midi_fm_playnote(i,note+cnote[c],my_midi_fm_vol_table[(cvols[c]*vel)/128]*2);
                */
                break;
            case 0xb0: /*control change .. pitch bend? */
                ctrl=getnext(1); vel=getnext(1);

                switch(ctrl)
                    {
                    case 0x07:
                        midiprintf ("(pb:%d: %ld %ld)",c,ctrl,vel);
                        ch[c].vol=vel;
                        midiprintf("vol");
                        break;
                    case 0x63:
                        if (adlib_style & CMF_STYLE) {
                            // Custom extension to allow CMF files to switch the
                            // AM+VIB depth on and off (officially this is on,
                            // and there's no way to switch it off.)  Controller
                            // values:
                            //   0 == AM+VIB off
                            //   1 == VIB on
                            //   2 == AM on
                            //   3 == AM+VIB on
                            midi_write_adlib(0xbd, (adlib_data[0xbd] & ~0xC0) | (vel << 6));
                            midiprintf(" AM+VIB depth change - AM %s, VIB %s\n",
                                (adlib_data[0xbd] & 0x80) ? "on" : "off",
                                (adlib_data[0xbd] & 0x40) ? "on" : "off"
                            );
                        }
                        break;
                    case 0x67:
                        midiprintf("Rhythm mode: %ld\n", vel);
                        if ((adlib_style&CMF_STYLE)!=0) {
			  adlib_mode=vel;
			  if(adlib_mode == ADLIB_RYTHM)
			    midi_write_adlib(0xbd, adlib_data[0xbd] | (1 << 5));
			  else
			    midi_write_adlib(0xbd, adlib_data[0xbd] & ~(1 << 5));
			}
                        break;
                    }
                break;
            case 0xc0: /*patch change*/
	      x=getnext(1);
	      ch[c].inum = x & 0x7f;
	      for (j=0; j<11; j++)
		ch[c].ins[j]=myinsbank[ch[c].inum][j];
	      break;
            case 0xd0: /*chanel touch*/
                x=getnext(1);
                break;
            case 0xe0: /*pitch wheel*/
                x=getnext(1);
                x=getnext(1);
                break;
            case 0xf0:
                switch(v)
                    {
                    case 0xf0:
                    case 0xf7: /*sysex*/
		      l=getval();
		      if (datalook(pos+l)==0xf7)
			i=1;
		      midiprintf("{%ld}",l);
		      midiprintf("\n");

                        if (datalook(pos)==0x7d &&
                            datalook(pos+1)==0x10 &&
                            datalook(pos+2)<16)
							{
                            adlib_style=LUCAS_STYLE|MIDI_STYLE;
							for (i=0; i<l; i++)
								{
                                midiprintf ("%x ",datalook(pos+i));
                                if ((i-3)%10 == 0) midiprintf("\n");
								}
                            midiprintf ("\n");
                            getnext(1);
                            getnext(1);
                            c = getnext(1) & 0x0f;
							getnext(1);

                          //  getnext(22); //temp
                            tmp = getnext(1) << 4;
                            ch[c].ins[0] = tmp + getnext(1);
                            tmp = getnext(1) << 4;
                            ch[c].ins[2] = 0xff - ((tmp + getnext(1)) & 0x3f);
                            tmp = getnext(1) << 4;
                            ch[c].ins[4] = 0xff - (tmp + getnext(1));
                            tmp = getnext(1) << 4;
                            ch[c].ins[6] = 0xff-(tmp + getnext(1));
                            tmp = getnext(1) << 4;
                            ch[c].ins[8] = tmp + getnext(1);
                            tmp = getnext(1) << 4;
                            ch[c].ins[1] = tmp + getnext(1);
                            tmp = getnext(1) << 4;
                            ch[c].ins[3] = 0xff - ((tmp + getnext(1)) & 0x3f);
                            tmp = getnext(1) << 4;
                            ch[c].ins[5] = 0xff - (tmp + getnext(1));
                            tmp = getnext(1) << 4;
                            ch[c].ins[7] = 0xff - (tmp + getnext(1));
                            tmp = getnext(1) << 4;
                            ch[c].ins[9] = tmp + getnext(1);

                            i = getnext(1) << 4;
                            ch[c].ins[10] = (i += getnext(1));

                            //if ((i&1)==1) ch[c].ins[10]=1;

                            midiprintf ("\n%d: ",c);
							for (i=0; i<11; i++)
                                midiprintf ("%2X ",ch[c].ins[i]);
                            getnext(l-26);
							}
                            else
                            {
                            midiprintf("\n");
                            for (j=0; j<l; j++)
                                midiprintf ("%2lX ",getnext(1));
                            }

                        midiprintf("\n");
						if(i==1)
							getnext(1);
                        break;
                    case 0xf1:
                        break;
                    case 0xf2:
                        getnext(2);
                        break;
                    case 0xf3:
                        getnext(1);
                        break;
                    case 0xf4:
                        break;
                    case 0xf5:
                        break;
                    case 0xf6: /*something*/
                    case 0xf8:
                    case 0xfa:
                    case 0xfb:
                    case 0xfc:
                        //this ends the track for sierra.
                        if (type == FILE_SIERRA ||
                            type == FILE_ADVSIERRA)
                            {
                            track[curtrack].tend=pos;
                            midiprintf ("endmark: %lu -- %lx\n",pos,pos);
                            }
                        break;
                    case 0xfe:
                        break;
                    case 0xfd:
                        break;
                    case 0xff:
                        v=getnext(1);
                        l=getval();
                        midiprintf ("\n");
                        midiprintf("{%lX_%lX}",v,l);
                        if (v==0x51)
                            {
                            lnum=getnext(l);
                            msqtr=lnum; /*set tempo*/
                            midiprintf ("(qtr=%ld)",msqtr);
                            }
                            else
                            {
                            for (i=0; i<l; i++)
                                midiprintf ("%2lX ",getnext(1));
                            }
                        break;
					}
                break;
            default: midiprintf("%lX!",v); /* if we get down here, a error occurred */
			break;
            }

        if (pos < track[curtrack].tend)
            {
            if (type != FILE_SIERRA && type !=FILE_ADVSIERRA)
                w=getval();
                else
                w=getnext(1);
            track[curtrack].iwait=w;
            /*
            if (w!=0)
                {
                midiprintf("\n<%d>",w);
                f = 
((float)w/(float)deltas)*((float)msqtr/(float)1000000);
                if (doing==1) f=0; //not playing yet. don't wait yet
                }
                */
            }
            else
            track[curtrack].iwait=0;

        track[curtrack].pos=pos;
        }


        ret=0; //end of song.
        iwait=0;
        for (curtrack=0; curtrack<16; curtrack++)
            if (track[curtrack].on == 1 &&
                track[curtrack].pos < track[curtrack].tend)
                ret=1;  //not yet..

        if (ret==1)
            {
            iwait = ~0UL;  // bigger than any wait can be!
            for (curtrack=0; curtrack<16; curtrack++)
               if (track[curtrack].on == 1 &&
                   track[curtrack].pos < track[curtrack].tend &&
                   track[curtrack].iwait < iwait)
                   iwait=track[curtrack].iwait;
            }
        }


    if (iwait !=0 && ret==1)
        {
        for (curtrack=0; curtrack<16; curtrack++)
            if (track[curtrack].on)
                track[curtrack].iwait-=iwait;

        
fwait=50; //1.0f/(((float)iwait/(float)deltas)*((float)msqtr/(float)1000000));
        }
        else
        fwait=50;  // 1/50th of a second

    midiprintf ("\n");
    for (i=0; i<16; i++)
      if (track[i].on) {
	if (track[i].pos < track[i].tend)
	  midiprintf ("<%lu>",track[i].iwait);
	else
	  midiprintf("stop");
      }

    /*
    if (ret==0 && type==FILE_ADVSIERRA)
        if (datalook(sierra_pos-2)!=0xff)
            {
            midiprintf ("next sectoin!");
            sierra_next_section(p);
            fwait=50;
            ret=1;
            }
    */

	if(ret)
		return true;
	else
		return false;
}

int main (int argc, char* argv[]){

    FILE *fd;

    if(argc < 2){
       fprintf(stderr, "midi file expected!\n");
       return EXIT_FAILURE;
    }
    opl2_init();

    fd = fopen(argv[1], "r");
    if(!fd){
        fprintf(stderr, "cannot open file '%s'\n", argv[1]);
        return EXIT_FAILURE;
    }
    load(fd);
    

    return EXIT_SUCCESS;
}
