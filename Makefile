.DEFAULT_GOAL := all
.PHONY := all build rebuild clean run

PROG_NAME = hello_world
RES_DIR = res

CC = zcc
CC_FLAGS = +zx -Wall -O2
C_FILES =
ASM_FILES = main.asm

LIBS = -lndos

INCLUDE =

# ----------------------------------------------------------
# --- Targets ----------------------------------------------
# ----------------------------------------------------------

all : build

run : build
	fuse $(PROG_NAME).tap

build :
	$(call padEcho,linking $(PROG_NAME)...)
	$(CC) $(CC_FLAGS) $(INCLUDE) $(LIBS) -o $(PROG_NAME) -create-app $(ASM_FILES) $(C_FILES)
	$(call padEcho,done!)

rebuild : clean build

clean :
	$(call padEcho,deleting temporary files...)
	$(RM) *~
	$(RM) $(PROG_NAME)
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
