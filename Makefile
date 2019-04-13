TITLE_ID = VITATESTR
TARGET = VitaTester
OBJS   = font.o main.o

LIBS = -lvita2d -lSceDisplay_stub -lSceGxm_stub -lSceCtrl_stub \
	-lSceTouch_stub -lSceSysmodule_stub -lSceCommonDialog_stub -lfreetype -lpng -lz -lm

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
CFLAGS  = -Wl,-q -Wall -O3 -std=c99
ASFLAGS = $(CFLAGS)

all: $(TARGET).vpk

%.vpk: eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE_ID) "$(TARGET)" param.sfo
	vita-pack-vpk -s param.sfo -b eboot.bin \
	-a icons/analog.png=icons/analog.png -a icons/background.png=icons/background.png \
	-a icons/circle.png=icons/circle.png -a icons/cross.png=icons/cross.png \
	-a icons/dpad.png=icons/dpad.png -a icons/finger_blue.png=icons/finger_blue.png \
	-a icons/finger_gray.png=icons/finger_gray.png -a icons/ltrigger.png=icons/ltrigger.png \
	-a icons/rtrigger.png=icons/rtrigger.png -a icons/select.png=icons/select.png \
	-a icons/square.png=icons/square.png -a icons/start.png=icons/start.png \
	-a icons/triangle.png=icons/triangle.png $@

eboot.bin: $(TARGET).velf
	vita-make-fself -s $< eboot.bin

%.velf: %.elf
	vita-elf-create $< $@

%.elf: $(OBJS)
	$(CC) $(CFLAGS) $^ $(LIBS) -o $@

clean:
	@rm -rf *.velf *.elf *.vpk $(OBJS) param.sfo eboot.bin

vpksend: $(TARGET).vpk
	curl -T $(TARGET).vpk ftp://$(PSVITAIP):1337/ux0:/
	@echo "Sent."

send: eboot.bin
	curl -T eboot.bin ftp://$(PSVITAIP):1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent."
