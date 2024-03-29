.DEFAULT_GOAL := all
.PHONY := all build rebuild clean run

PROG_NAME = catastrophe
TEST_PROG_TAP = keyboardTest.tap physicsTest.tap gameLogicTest.tap aiTest.tap
TEST_PROG_BIN = keyboardTest.bin physicsTest.bin gameLogicTest.bin aiTest.bin
RES_DIR = res

ASM = pasmo
ASM_FLAGS = --bin
MAIN_FILE = main.asm
ASM_FILES = defines.asm input.asm physics.asm ai.asm collision.asm draw.asm \
gameLogic.asm render.asm testUtil.asm music-loadingScreen.asm

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

build_test : $(TEST_PROG_TAP)
	$(call padEcho,done!)

$(PROG_NAME).tap : $(PROG_NAME).bin
	$(call padEcho,Appmaking $(PROG_NAME).tap...)
	$(APPMAKE) $(APPMAKE_FLAGS) -o $(PROG_NAME).tap -b $(PROG_NAME).bin

$(PROG_NAME).bin : $(MAIN_FILE) $(ASM_FILES)
	$(call padEcho,Assembling $(PROG_NAME)...)
	$(ASM) $(ASM_FLAGS) $(MAIN_FILE) $(PROG_NAME).bin

$(TEST_PROG_TAP): %.tap : %.bin
	$(call padEcho,Appmaking $@...)
	$(APPMAKE) $(APPMAKE_FLAGS) -o $@ -b $<

$(TEST_PROG_BIN): %.bin : %.asm $(ASM_FILES)
	$(call padEcho,Assembling $<...)
	$(ASM) $(ASM_FLAGS) $< $@

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
	$(RM) $(TEST_PROG_TAP)
	$(RM) $(TEST_PROG_BIN)

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
