
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include <errno.h>

typedef struct __attribute__((packed, scalar_storage_order("big-endian"))) {
    unsigned char signature[4];
    uint32_t iLength;
    uint16_t iType;
    uint16_t iNumTracks;
    uint16_t iTicksPerQuarterNote;
} MIDI_Head;

typedef struct __attribute__((packed, scalar_storage_order("big-endian"))) {
    unsigned char signature[4];
    uint32_t iLength;
} MIDI_Track;

typedef struct {//__attribute__((packed, scalar_storage_order("big-endian"))) {
	uint16_t iInstrumentBlockOffset;
	uint16_t iMusicOffset;
	uint16_t iTicksPerQuarterNote;
	uint16_t iTicksPerSecond;
	uint16_t iTagOffsetTitle;
	uint16_t iTagOffsetComposer;
	uint16_t iTagOffsetRemarks;
	uint8_t iChannelsInUse[16];
	uint16_t iNumInstruments;
	uint16_t iTempo;
} CMFHEADER;

typedef struct {
	uint8_t iCharMult;
	uint8_t iScalingOutput;
	uint8_t iAttackDecay;
	uint8_t iSustainRelease;
	uint8_t iWaveSel;
} OPERATOR;

typedef struct {
	OPERATOR op[2]; // 0 == modulator, 1 == carrier
	uint8_t iConnection;
    char padding[5];
} SBI;

typedef struct {
    char signature[4];//	"SBI" followed by 0x1A
    char name[32];
    SBI sbi;
} SBI_FILE;

unsigned char CMF[]="CTMF\x1\x1";

void skipMetaEvent(FILE *fd){
    
}

int main (int argc, const char* argv[]){

    FILE *fd;
    FILE *fd_midi;
    FILE *fd_out;
    unsigned char i = 0;
    unsigned char j = 0;
    size_t r;

    MIDI_Head midiheader;
    MIDI_Track miditrack;
    CMFHEADER cmfheader;
    SBI_FILE sbi_file[16];
    uint8_t buffer[256];

    unsigned char cmf_file[64];

    if(argc < 2){
        fprintf(stderr, "input midi file expected!\n");
        return EXIT_FAILURE;
    }
    if(argc < 3){
        fprintf(stderr, "input sbi file(s) expected!\n");
        return EXIT_FAILURE;
    }

    cmfheader.iInstrumentBlockOffset = sizeof(CMF) + sizeof(CMFHEADER) - 1;
    cmfheader.iMusicOffset = sizeof(CMF) + sizeof(CMFHEADER) - 1 + (argc-2) * 16;
    cmfheader.iTagOffsetTitle = 0;
    cmfheader.iTagOffsetComposer = 0;
    cmfheader.iTagOffsetRemarks = 0;
    cmfheader.iNumInstruments = (argc-2);
    cmfheader.iTicksPerQuarterNote = 0; 
    cmfheader.iTicksPerSecond = 2000; // TODO
    cmfheader.iTempo = 0;//0xa2;//TODO

    for(i=2;i<argc && i-2<16;i++){
        printf("loading sbi %s to channel %d\n", argv[i], i-2);
        fd = fopen(argv[i], "r");
        if(!fd){
            fprintf(stderr, "cannot open file '%s'\n", argv[i]);
            return EXIT_FAILURE;
        }
        r = fread(&sbi_file[i-2], 1, sizeof(SBI_FILE), fd);
        if (r != sizeof(SBI_FILE)) {
            fprintf(stderr, "read error '%s': %s\n", argv[i], strerror(errno));
            fclose(fd);
            return EXIT_FAILURE;
        }
        fclose(fd);
        cmfheader.iChannelsInUse[i-2] = 1;
    }

    fd_midi = fopen(argv[1], "r");
    if(!fd_midi){
        fprintf(stderr, "cannot open midi file '%s'\n", argv[1]);
        return EXIT_FAILURE;
    }
    r = fread(&midiheader, 1, sizeof(MIDI_Head), fd_midi);
    if (r != sizeof(MIDI_Head)) {
        fprintf(stderr, "read error '%s': %s\n",argv[1], strerror(errno));
        fclose(fd_midi);
        return EXIT_FAILURE;
    }

    printf("midi type: %x\n", midiheader.iType);
    printf("midi tracks: %x\n", midiheader.iNumTracks);
    printf("midi header: %x\n", midiheader.iLength);

    if(midiheader.iNumTracks != 1 && midiheader.iType != 0){
        fprintf(stderr, "only single track midi format is supported, but has %d tracks\n",midiheader.iNumTracks);
        fclose(fd_midi);
        return EXIT_FAILURE;
    }
    cmfheader.iTicksPerQuarterNote = midiheader.iTicksPerQuarterNote;

    r = fread(&miditrack, 1, sizeof(MIDI_Track), fd_midi);
    if (r != sizeof(MIDI_Track)) {
        fprintf(stderr, "read error '%s': %s\n",argv[1], strerror(errno));
        fclose(fd_midi);
        return EXIT_FAILURE;
    }
    printf("midi track: %x\n", miditrack.iLength);

    snprintf(cmf_file, sizeof(cmf_file), "%s.cmf", argv[1]);
    printf("%s\n", cmf_file);
    fd_out = fopen(cmf_file, "w+b");
    if(!fd_out){
        fprintf(stderr, "cannot create output file '%s'\n", argv[1]);
        return EXIT_FAILURE;
    }
    
    fwrite("CTMF\x1\x1", 6, 1, fd_out);
    fwrite(&cmfheader, sizeof(cmfheader), 1, fd_out);
    for(j=0;j<i-2;j++){
        printf("%d %lu %32s\n", j, sizeof(SBI), sbi_file[j].name);
        fwrite(&sbi_file[j].sbi, sizeof(SBI), 1, fd_out);
    }

    skipMetaEvent(fd_midi);
    fread(&buffer, 1, 215, fd_midi);

    while((r = fread(&buffer, sizeof(uint8_t), sizeof(buffer), fd_midi)) > 0){
        //printf("read: %x\n", (unsigned)r);
        fwrite(&buffer, r, 1, fd_out);
    }
    
    fclose(fd_midi);
    fclose(fd_out);
}