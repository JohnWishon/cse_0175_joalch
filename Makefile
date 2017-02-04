.DEFAULT_GOAL := all
.PHONY := all build rebuild clean run

PROG_NAME = catastrophe
TEST_PROG_NAME = keyboardTest
RES_DIR = res

ASM = pasmo
ASM_FLAGS = --bin
MAIN_FILE = main.asm
TEST_MAIN_FILE = keyboardTest.asm
ASM_FILES = defines.asm input.asm physics.asm ai.asm collision.asm draw.asm

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

build_test : $(TEST_PROG_NAME).tap
	$(call padEcho,done!)

$(PROG_NAME).tap : $(PROG_NAME).bin
	$(call padEcho,Appmaking $(PROG_NAME).tap...)
	$(APPMAKE) $(APPMAKE_FLAGS) -o $(PROG_NAME).tap -b $(PROG_NAME).bin

$(PROG_NAME).bin : $(MAIN_FILE) $(ASM_FILES)
	$(call padEcho,Assembling $(PROG_NAME)...)
	$(ASM) $(ASM_FLAGS) $(MAIN_FILE) $(PROG_NAME).bin

$(TEST_PROG_NAME).tap : $(TEST_PROG_NAME).bin
	$(call padEcho,Appmaking $(TEST_PROG_NAME).tap...)
	$(APPMAKE) $(APPMAKE_FLAGS) -o $(TEST_PROG_NAME).tap -b $(TEST_PROG_NAME).bin

$(TEST_PROG_NAME).bin : $(TEST_MAIN_FILE) $(ASM_FILES)
	$(call padEcho,Assembling $(TEST_PROG_NAME)...)
	$(ASM) $(ASM_FLAGS) $(TEST_MAIN_FILE) $(TEST_PROG_NAME).bin

rebuild : clean build

rebuild_test : clean build_test

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
