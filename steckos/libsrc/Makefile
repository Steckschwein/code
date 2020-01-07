TARGET=steckschwein
TARGET_SYS=none

DEFINES+=-DV9958

# debug fat32
#DEBUG += -DDEBUG_FAT32
#DEBUG += -DDEBUG_SDCARD

.PHONY: all mostlyclean clean install zip lib $(TARGET)

.SUFFIXES:

ifdef CMD_EXE
  DIRLIST = $(strip $(foreach dir,$1,$(wildcard $(dir))))
  MKDIR = mkdir $(subst /,\,$1)
  RMDIR = $(if $(DIRLIST),rmdir /s /q $(subst /,\,$(DIRLIST)))
else
  MKDIR = mkdir -p $1
  RMDIR = $(RM) -r $1
endif

# Every target requires its individual vpath setting but the vpath directive
# acts globally. Therefore each target is built in a separate make instance.

ifeq ($(words $(MAKECMDGOALS)),1)
  ifeq ($(MAKECMDGOALS),$(filter $(MAKECMDGOALS),$(TARGETS)))
    TARGET = $(MAKECMDGOALS)
  endif
endif

all: ../lib/$(TARGET).a runtests

clean:
	rm -f ../lib/$(TARGET).a
	$(call RMDIR,../libwrk)

mostlyclean:
	$(call RMDIR,../libwrk)

CA65FLAGS = --cpu 65c02 --include-dir ../asminc --include-dir ../../asmunit $(DEFINES) $(DEBUG)
CC65FLAGS = -Or -W error

SRCDIR=.
SRCDIRS = $(SRCDIR)
SRCDIRS +=  t99xx
SRCDIRS +=  joystick
SRCDIRS +=  ym3812
SRCDIRS +=  nvram
SRCDIRS +=  uart/16550
SRCDIRS +=  spi
SRCDIRS +=  sdcard
SRCDIRS +=  fat32
SRCDIRS +=  via
SRCDIRS +=  debug
SRCDIRS +=  util/crc7

vpath %.s $(SRCDIRS)
vpath %.c $(SRCDIRS)

OBJS := $(patsubst %.s,%.o,$(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.s)))
OBJS += $(patsubst %.c,%.o,$(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c)))
OBJS := $(addprefix ../libwrk/$(TARGET)/,$(sort $(notdir $(OBJS))))

# sub directory named test per convention
TEST_SRCDIRS := $(foreach dir,$(SRCDIRS),$(dir)/test)
vpath %.s $(TEST_SRCDIRS)
TEST_OBJS := $(patsubst %.s,%.o,$(foreach dir,$(TEST_SRCDIRS),$(wildcard $(dir)/*.s)))
TEST_OBJS := $(addprefix ../libwrk/$(TARGET)/,$(sort $(notdir $(TEST_OBJS))))
TEST_BINS := $(patsubst %.s,%.bin,$(foreach dir,$(TEST_SRCDIRS),$(wildcard $(dir)/*.s)))# from source names
TEST_BINS := $(addprefix ../libwrk/$(TARGET)/,$(sort $(notdir $(TEST_BINS))))
TEST_LIBS := ../../asmunit/asmunit.a
TEST_LDFLAGS=-C ../../asmunit/asmunit.cfg $(TEST_LIBS) ../lib/$(TARGET).a

DEPS = $(OBJS:.o=.d)
DEPS_TEST = $(OBJS_TEST:.o=.d)

AR65 := $(if $(wildcard ../bin/ar65*),../bin/ar65,ar65)
CA65 := $(if $(wildcard ../bin/ca65*),../bin/ca65,ca65)
CC65 := $(if $(wildcard ../bin/cc65*),../bin/cc65,cc65)
LD65 := $(if $(wildcard ../bin/ld65*),../bin/ld65,ld65)

define ASSEMBLE_recipe
$(if $(QUIET),,@echo $(TARGET) - $<)
@$(CA65) -t $(TARGET_SYS) $(CA65FLAGS) --create-dep $(@:.o=.d) -o $@ $<
endef # ASSEMBLE_recipe

define COMPILE_recipe
$(if $(QUIET),,@echo $(TARGET) - $<)
@$(CC65) -t $(TARGET_SYS) $(CC65FLAGS) --create-dep $(@:.o=.d) --dep-target $@ -o $(@:.o=.s) $<
@$(CA65) -t $(TARGET_SYS) -o $@ $(@:.o=.s)
endef # COMPILE_recipe

define RUNTEST_recipe
	@$(LD65) $< $(TEST_LDFLAGS) -o $@
  	TARGET_DIR=. ../../asmunit/asmunit_wrapper.sh $@ 1000
endef

../libwrk/$(TARGET)/%.o: %.s | ../libwrk/$(TARGET)
	$(ASSEMBLE_recipe)

../libwrk/$(TARGET)/%.o: %.c | ../libwrk/$(TARGET)
	$(COMPILE_recipe)

../libwrk/$(TARGET)/%.bin: ../libwrk/$(TARGET)/%.o | ../libwrk/$(TARGET)
	$(RUNTEST_recipe)

../libwrk/$(TARGET) ../lib:
	@$(call MKDIR,$@)

../lib/$(TARGET).a: $(OBJS) | ../lib
	$(AR65) a $@ $?

../../asmunit/asmunit.a:
	(cd ../../asmunit ; make)

runtests: $(TEST_BINS)

-include $(DEPS)
-include $(DEPS_TEST)
