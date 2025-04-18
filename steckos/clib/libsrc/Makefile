TARGET=steckschwein-clib
#TARGET_SYS=-t steckschwein

DEFINES+=-DV9958

.PHONY: all mostlyclean clean install zip lib $(TARGET)

.SUFFIXES:

$(if $(value CC65_HOME),,$(error CC65_HOME environment variable is not set!))

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


all: ../lib/$(TARGET).a

clean:
	rm -f ../lib/$(TARGET).a
	$(call RMDIR,../libwrk)

mostlyclean:
	$(call RMDIR,../libwrk)


CA65FLAGS = --cpu 65c02 -I ../../ $(DEFINES)
# several bugs exists for static locals
# https://github.com/cc65/cc65/issues/263
# https://github.com/cc65/cc65/issues/632
CC65FLAGS = --cpu 65c02 -W error -I ../include -Os

SRCDIR=.
SRCDIRS = $(SRCDIR)
SRCDIRS += common
SRCDIRS += t99xx
SRCDIRS += graphics
SRCDIRS += joystick
SRCDIRS += ym3812
SRCDIRS += vdp
SRCDIRS += opl2
SRCDIRS += util
SRCDIRS += rom
SRCDIRS += sdcard
SRCDIRS += xmodem
SRCDIRS +=  $(CC65_HOME)/libsrc/conio       \
      $(CC65_HOME)/libsrc/runtime     \
      $(CC65_HOME)/libsrc/zlib    \
      $(CC65_HOME)/libsrc/common \
      $(CC65_HOME)/libsrc/dbg      \
			$(CC65_HOME)/libsrc/zlib
#    $(CC65_HOME)/libsrc/serial   \
#    $(CC65_HOME)/libsrc/tgi      \
#       $(CC65_HOME)/libsrc/em       \
#       $(CC65_HOME)/libsrc/joystick \
#       $(CC65_HOME)/libsrc/mouse    \

vpath %.s $(SRCDIRS)
vpath %.c $(SRCDIRS)

OBJS := $(patsubst %.s,%.o,$(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.s)))
OBJS += $(patsubst %.c,%.o,$(foreach dir,$(SRCDIRS),$(wildcard $(dir)/*.c)))

OBJS := $(addprefix ../libwrk/$(TARGET)/,$(sort $(notdir $(OBJS))))

DEPS = $(OBJS:.o=.d)

AR65 := $(if $(wildcard ../bin/ar65*),../bin/ar65,ar65)
CA65 := $(if $(wildcard ../bin/ca65*),../bin/ca65,ca65)
CC65 := $(if $(wildcard ../bin/cc65*),../bin/cc65,cc65)
LD65 := $(if $(wildcard ../bin/ld65*),../bin/ld65,ld65)

# set from environment
# export CC65_HOME := $(abspath ..)

define ASSEMBLE_recipe
$(if $(QUIET),,@echo $(TARGET) - $<)
@$(CA65) $(TARGET_SYS) $(CA65FLAGS) --create-dep $(@:.o=.d) -o $@ $<
endef # ASSEMBLE_recipe

define COMPILE_recipe
$(if $(QUIET),,@echo $(TARGET) - $<)
@$(CC65) $(TARGET_SYS) $(CC65FLAGS) --create-dep $(@:.o=.d) --dep-target $@ -o $(@:.o=.s) $<
@$(CA65) $(TARGET_SYS) -o $@ $(@:.o=.s)
endef # COMPILE_recipe

../libwrk/$(TARGET)/%.o: %.s | ../libwrk/$(TARGET)
	$(ASSEMBLE_recipe)

../libwrk/$(TARGET)/%.o: %.c | ../libwrk/$(TARGET)
	$(COMPILE_recipe)

../lib/$(TARGET).a: $(OBJS) | ../lib
	$(AR65) a $@ $?

../libwrk/$(TARGET) ../lib ../target/$(TARGET)/util:
	@$(call MKDIR,$@)

-include $(DEPS)
