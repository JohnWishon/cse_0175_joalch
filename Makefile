.DEFAULT_GOAL := all
.PHONY := all build rebuild clean run

PROG_NAME = catastrophe
RES_DIR = res

ASM = pasmo
ASM_FLAGS = --bin
MAIN_FILE = main.asm
ASM_FILES = defines.asm keyboarddisp.asm update.asm

APPMAKE = appmake
APPMAKE_FLAGS = +zx --org 32768


# ----------------------------------------------------------
# --- Targets ----------------------------------------------
# ----------------------------------------------------------

all : build

run : build
	fuse $(PROG_NAME).tap

build : $(PROG_NAME).tap
	$(call padEcho,done!)

$(PROG_NAME).tap : $(PROG_NAME).bin
	$(call padEcho,Appmaking $(PROG_NAME).tap...)
	$(APPMAKE) $(APPMAKE_FLAGS) -o $(PROG_NAME).tap -b $(PROG_NAME).bin

$(PROG_NAME).bin : $(MAIN_FILE) $(ASM_FILES)
	$(call padEcho,Assembling $(PROG_NAME)...)
	$(ASM) $(ASM_FLAGS) $(MAIN_FILE) $(PROG_NAME).bin

rebuild : clean build

clean :
	$(call padEcho,deleting temporary files...)
	$(RM) *~
	$(RM) *.err
	$(RM) $(PROG_NAME)
	$(RM) $(PROG_NAME).o
	$(RM) $(PROG_NAME).bin
	$(RM) $(PROG_NAME).tap

# ----------------------------------------------------------
# --- Functions --------------------------------------------
# ----------------------------------------------------------

define padEcho
@echo
@echo --------------------------------------------------------------------------------
@echo $(1)
@echo --------------------------------------------------------------------------------
@echo
endef
