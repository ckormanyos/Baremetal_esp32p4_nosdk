# ******************************************************************************************
#   Filename    : Makefile
#
#   Author      : Chalandi Amine
#
#   Owner       : Chalandi Amine
#
#   Date        : 25.01.2026
#
#   Description : Build system
#
# ******************************************************************************************

############################################################################################
# Defines
############################################################################################
PRJ_NAME     = ulp
OUTPUT_DIR   = $(CURDIR)/Output
OBJ_DIR      = $(OUTPUT_DIR)/obj
LD_SCRIPT    = $(CURDIR)/$(PRJ_NAME).ld
SRC_DIR      = $(CURDIR)
PYTHON       = python

ERR_MSG_FORMATER_SCRIPT = $(CURDIR)/../../Tools/scripts/CompilerErrorFormater.py

############################################################################################
# Toolchain
############################################################################################
TOOLCHAIN = riscv32-esp-elf

AS      = $(TOOLCHAIN)-gcc
CC      = $(TOOLCHAIN)-gcc
CPP     = $(TOOLCHAIN)-g++
LD      = $(TOOLCHAIN)-gcc
OBJDUMP = $(TOOLCHAIN)-objdump
OBJCOPY = $(TOOLCHAIN)-objcopy
SIZE    = $(TOOLCHAIN)-size
READELF = $(TOOLCHAIN)-readelf

ARCH      = -march=rv32imc_zicsr_zifencei           \
            -mabi=ilp32                             \
            -msmall-data-limit=0                    \
            -falign-functions=4                     \
            -fomit-frame-pointer

CFLAG = $(ARCH)           \
        -O0               \
        -ffreestanding    \
        -gdwarf-4         \
        -ggdb

LDFLAG = -march=rv32imafc                       \
         -mabi=ilp32f                           \
         -nostartfiles                          \
         -nostdlib                              \
         -e _start                              \
         -Wl,--no-warn-rwx-segments             \
         -Wl,--print-memory-usage               \
         -Wl,--print-map                        \
         -Wl,-Map=$(OUTPUT_DIR)/$(PRJ_NAME).map \
         -Wl,-dT $(LD_SCRIPT)

DEFS = 

############################################################################################
# Source Files
############################################################################################

SRC_FILES := $(SRC_DIR)/boot.s               \
             $(SRC_DIR)/intvect.s            \
             $(SRC_DIR)/../Startup/Startup.c \
             $(SRC_DIR)/main.c



############################################################################################
# Include Paths
############################################################################################
INC_FILES := $(SRC_DIR)          \
             $(SRC_DIR)/../Mcal


############################################################################################
# Rules
############################################################################################
.PHONY : ALL
.PHONY : LINK
.PHONY : PRE
.PHONY : GENERATE

VPATH := $(subst \,/,$(sort $(dir $(SRC_FILES)) $(OBJ_DIR)))
FILES_O := $(addprefix $(OBJ_DIR)/, $(notdir $(addsuffix .o, $(basename $(SRC_FILES)))))

ALL : PRE LINK GENERATE

PRE:
	@-echo +++ Building Baremetal Coprocessor Image for ESP32-P4
	@-rm -rf $(OUTPUT_DIR)  2>/dev/null || true && mkdir -p $(subst \,/,$(OBJ_DIR))

############################################################################################
# Recipes
############################################################################################
LINK : $(FILES_O) $(LD_SCRIPT)
	@-echo +++ link: $(OUTPUT_DIR)/$(PRJ_NAME).elf
	@-$(LD) $(LDFLAG) $(FILES_O) -o $(OUTPUT_DIR)/$(PRJ_NAME).elf > linker_output.txt 2>&1 || true
	@cat linker_output.txt
	@rm linker_output.txt || true

GENERATE :
	@-echo +++ generate: $(OUTPUT_DIR)/$(PRJ_NAME).readelf
	@$(READELF) -WhS $(OUTPUT_DIR)/$(PRJ_NAME).elf > $(OUTPUT_DIR)/$(PRJ_NAME).readelf
	@-cat $(OUTPUT_DIR)/$(PRJ_NAME).map >> $(OUTPUT_DIR)/$(PRJ_NAME).readelf
	@-echo +++ generate: $(OUTPUT_DIR)/$(PRJ_NAME).sym
	@$(READELF) -Ws $(OUTPUT_DIR)/$(PRJ_NAME).elf >> $(OUTPUT_DIR)/$(PRJ_NAME).readelf
	@-echo +++ generate: $(OUTPUT_DIR)/$(PRJ_NAME).dis
	@$(OBJDUMP) -d --visualize-jumps --wide $(OUTPUT_DIR)/$(PRJ_NAME).elf >> $(OUTPUT_DIR)/$(PRJ_NAME).readelf
	@-echo +++ generate: $(OUTPUT_DIR)/$(PRJ_NAME).hex
	@$(OBJCOPY) $(OUTPUT_DIR)/$(PRJ_NAME).elf -O ihex $(OUTPUT_DIR)/$(PRJ_NAME).hex
	@-echo +++ generate: $(OUTPUT_DIR)/$(PRJ_NAME).bin
	@$(OBJCOPY) $(OUTPUT_DIR)/$(PRJ_NAME).elf -O binary $(OUTPUT_DIR)/$(PRJ_NAME).bin
	@-echo +++ End
	@-echo



$(OBJ_DIR)/%.o : %.c
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@-$(CC) $(CFLAG) $(DEFS) $(addprefix -I, $(INC_FILES)) -x c -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR



$(OBJ_DIR)/%.o : %.S
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@-$(CC) $(ARCH) $(DEFS) $(addprefix -I, $(INC_FILES)) -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR



$(OBJ_DIR)/%.o : %.s
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@-$(AS) $(CFLAG) $(addprefix -I, $(INC_FILES)) -x assembler -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR



$(OBJ_DIR)/%.o : %.cpp
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@$(CPP) $(CPPFLAG) $(DEFS) $(addprefix -I, $(INC_FILES)) -x c++ -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR

