# ******************************************************************************************
#   Filename    : Makefile
#
#   Author      : Chalandi Amine
#
#   Owner       : Chalandi Amine
#
#   Date        : 22.11.2022
#
#   Description : Build system
#
# ******************************************************************************************

############################################################################################
# Defines
############################################################################################
_BUILD_TYPE_ = $(shell echo $(BUILD_TYPE) | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z]//g')
PRJ_NAME     = baremetal_esp32p4_nosdk
OUTPUT_DIR   = $(CURDIR)/../Output
OBJ_DIR      = $(OUTPUT_DIR)/obj
LD_SCRIPT    = $(SRC_DIR)/Memory_Map.ld
SRC_DIR      = $(CURDIR)/../Code
ULP_DIR      = $(SRC_DIR)/Coprocessor
ULP_MAKEFILE = $(SRC_DIR)/Coprocessor/ulp.mk
ULP_BIN      = $(SRC_DIR)/Coprocessor/Output/ulp.bin
SBL_DIR      = $(SRC_DIR)/SBL
SBL_MAKEFILE = $(SRC_DIR)/SBL/sbl.mk
SBL_BIN      = $(SRC_DIR)/SBL/Output/SBL.bin
COM_PORT     = COM5
COPROCESSOR  = ULP-RISC-V
PYTHON       = python
ESPTOOL      = esptool

ERR_MSG_FORMATER_SCRIPT = $(CURDIR)/../Tools/scripts/CompilerErrorFormater.py
LINKER_ERR_MSG_FORMATER_SCRIPT = $(CURDIR)/../Tools/scripts/LinkerErrorFormater.py
FORMAT_LINKER_ERR =
REFORMAT_BIN      = $(CURDIR)/../Tools/scripts/ConcatenateDataBlocks.py

############################################################################################
# Toolchain
############################################################################################
TOOLCHAIN = riscv32-esp-elf

ARCH      = -march=rv32imafc_zicsr_zifencei_xesppie \
            -mabi=ilp32f                            \
            -msmall-data-limit=0                    \
            -falign-functions=4                     \
            -fomit-frame-pointer

DEFS      = -DHP_CORES_SMP_MODE


AS      = $(TOOLCHAIN)-gcc
CC      = $(TOOLCHAIN)-gcc
CPP     = $(TOOLCHAIN)-g++
LD      = $(TOOLCHAIN)-gcc
OBJDUMP = $(TOOLCHAIN)-objdump
OBJCOPY = $(TOOLCHAIN)-objcopy
SIZE    = $(TOOLCHAIN)-size
READELF = $(TOOLCHAIN)-readelf

############################################################################################
# Optimization Compiler flags
############################################################################################

OPT_MODIFIED_O2 = -O2                               \
                  -fno-reorder-blocks-and-partition \
                  -fno-reorder-functions

NO_OPT = -O0

OPT = $(OPT_MODIFIED_O2)

############################################################################################
# GCC Compiler verbose flags
############################################################################################

VERBOSE_GCC = -frecord-gcc-switches -fverbose-asm

############################################################################################
# C Compiler flags
############################################################################################

COPS  = $(OPT)                                        \
        $(ARCH)                                       \
        $(DEFS)                                       \
        -ffreestanding                                \
        -MD                                           \
        -Wa,-adhln=$(OBJ_DIR)/$(basename $(@F)).lst   \
        -gdwarf-4 -ggdb                               \
        -Wconversion                                  \
        -Wsign-conversion                             \
        -Wunused-parameter                            \
        -Wuninitialized                               \
        -Wmissing-declarations                        \
        -Wshadow                                      \
        -Wunreachable-code                            \
        -Wmissing-include-dirs                        \
        -x c                                          \
        -std=c11                                      \
        -Wall                                         \
        -Wextra                                       \
        -fomit-frame-pointer                          \
        -gdwarf-2                                     \
        -fno-exceptions

############################################################################################
# C++ Compiler flags
############################################################################################

CPPOPS  = $(OPT)                                        \
          $(ARCH)                                       \
          $(DEFS)                                       \
          -ffreestanding                                \
          -Wa,-adhln=$(OBJ_DIR)/$(basename $(@F)).lst   \
          -gdwarf-4 -ggdb                               \
          -Wconversion                                  \
          -Wsign-conversion                             \
          -Wunused-parameter                            \
          -Wuninitialized                               \
          -Wmissing-declarations                        \
          -Wshadow                                      \
          -Wunreachable-code                            \
          -Wmissing-include-dirs                        \
          -Wall                                         \
          -Wextra                                       \
          -fomit-frame-pointer                          \
          -gdwarf-2                                     \
          -fno-exceptions                               \
          -x c++                                        \
          -fno-rtti                                     \
          -fno-use-cxa-atexit                           \
          -fno-nonansi-builtins                         \
          -fno-threadsafe-statics                       \
          -fno-enforce-eh-specs                         \
          -ftemplate-depth=128                          \
          -Wzero-as-null-pointer-constant

############################################################################################
# Assembler flags
############################################################################################
ifeq ($(AS), $(TOOLCHAIN)-as)
  ASOPS =  $(ARCH)       \
           -alh          \
           -g
else
  ASOPS = $(OPT)                                        \
          $(ARCH)                                       \
          $(DEFS)                                       \
          -MD                                           \
          -Wa,-adhln=$(OBJ_DIR)/$(basename $(@F)).lst   \
          -gdwarf-4 -ggdb                               \
          -Wconversion                                  \
          -Wsign-conversion                             \
          -Wunused-parameter                            \
          -Wuninitialized                               \
          -Wmissing-declarations                        \
          -Wshadow                                      \
          -Wunreachable-code                            \
          -Wmissing-include-dirs                        \
          -x assembler                                  \
          -std=c11                                      \
          -Wall                                         \
          -Wextra                                       \
          -fomit-frame-pointer                          \
          -gdwarf-2                                     \
          -fno-exceptions
endif

############################################################################################
# Linker flags
############################################################################################

ifeq ($(LD), $(TOOLCHAIN)-ld)
  LOPS = -nostartfiles                          \
         -nostdlib                              \
         $(ARCH)                                \
         $(DEFS)                                \
         -e Startup_Init                        \
         --print-memory-usage                   \
         --print-map                            \
         -dT $(LD_SCRIPT)                       \
         -Map=$(OUTPUT_DIR)/$(PRJ_NAME).map     \
         --no-warn-rwx-segments                 \
         -z,max-page-size=4096                  \
         --specs=nano.specs                     \
         --specs=nosys.specs
else
  LOPS = -nostartfiles                          \
         -nostdlib                              \
         -fno-lto                               \
         $(ARCH)                                \
         $(DEFS)                                \
         -e Startup_Init                        \
         -Wl,--print-memory-usage               \
         -Wl,--print-map                        \
         -Wl,-dT $(LD_SCRIPT)                   \
         -Wl,-Map=$(OUTPUT_DIR)/$(PRJ_NAME).map \
         -Wl,--no-warn-rwx-segments             \
         -Wl,-z,max-page-size=4096              \
         --specs=nano.specs                     \
         --specs=nosys.specs
endif

############################################################################################
# Source Files
############################################################################################

SRC_FILES := $(SRC_DIR)/Appli/main.c            \
             $(SRC_DIR)/Mcal/gpio.c             \
             $(SRC_DIR)/Startup/boot.s          \
             $(SRC_DIR)/Startup/intvect.c       \
             $(SRC_DIR)/Startup/Startup.c       \
             $(SRC_DIR)/StdLib/StdLib.c



############################################################################################
# Include Paths
############################################################################################
INC_FILES := $(SRC_DIR)                             \
             $(SRC_DIR)/Appli                       \
             $(SRC_DIR)/Mcal                        \
             $(SRC_DIR)/Startup                     \
             $(SRC_DIR)/StdLib

############################################################################################
# External Libaries
############################################################################################
EXTERNAL_LIB := 

############################################################################################
# Coprocessor build
############################################################################################
ifeq ($(COPROCESSOR), ULP-RISC-V)
  DEFS += -DCOPROCESSOR_ENABLED
endif

############################################################################################
# Rules
############################################################################################

VPATH := $(subst \,/,$(sort $(dir $(SRC_FILES)) $(OBJ_DIR)))
FILES_O := $(addprefix $(OBJ_DIR)/, $(notdir $(addsuffix .o, $(basename $(SRC_FILES)))))

ifeq ($(MAKECMDGOALS), BUILD_STAGE_2)
-include $(subst .o,.d,$(FILES_O))
endif

REBUILD_STAGE_1 : CLEAN PRE_BUILD $(CUSTOM_PRE_BUILD_TARGET)
REBUILD_STAGE_2 : link
REBUILD_STAGE_3 : GENERATE POST_BUILD

BUILD_STAGE_1   : PRE_BUILD $(CUSTOM_POST_BUILD_TARGET)
BUILD_STAGE_2   : link
BUILD_STAGE_3   : GENERATE POST_BUILD $(CUSTOM_POST_BUILD_TARGET)

############################################################################################
# Recipes
############################################################################################
.PHONY : link
link : $(OUTPUT_DIR)/$(PRJ_NAME).elf
	@-echo "" > /dev/null

.PHONY : PRE_BUILD
PRE_BUILD:
ifeq ($(_BUILD_TYPE_), all)
	@make -C $(SBL_DIR) -f $(SBL_MAKEFILE) COPROCESSOR=$(COPROCESSOR) --no-print-directory
#	@false
ifeq ($(COPROCESSOR), ULP-RISC-V)
	@make -C $(ULP_DIR) -f $(ULP_MAKEFILE) --no-print-directory
#	@false
endif
endif
	@-echo +++ Building Baremetal Application Image for ESP32-P4
	@command -v $(ESPTOOL) >/dev/null 2>&1 || pip install $(ESPTOOL)
	@git log -n 1 --decorate-refs=refs/heads/ --pretty=format:"+++ Git branch: %D (%h)" 2>/dev/null || true
	@git log -n 1 --clear-decorations 2> /dev/null > /dev/null || true
	@echo +++ info: "$(shell $(CC) -v 2>&1 | tail -n 1)"
	@echo +++ info: "$(shell make -v 2>&1 | head -n 1)"
	@echo +++ info: "$(shell $(PYTHON) --version 2>&1 | head -n 1)"
	@echo +++ info: "$(shell $(ESPTOOL) version 2>&1 | head -n 1)"
	@$(if $(shell test -d $(OBJ_DIR) && echo yes),,mkdir -p $(subst \,/,$(OBJ_DIR)))


.PHONY : POST_BUILD
POST_BUILD:
	@-echo +++ End


.PHONY : CLEAN
CLEAN :
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).bin     2>/dev/null || true
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).dis     2>/dev/null || true
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).elf     2>/dev/null || true
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).hex     2>/dev/null || true
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).map     2>/dev/null || true
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).readelf 2>/dev/null || true
	@-rm -rf $(OUTPUT_DIR)/$(PRJ_NAME).sym     2>/dev/null || true
	@-rm -rf $(OBJ_DIR)                        2>/dev/null || true
	@-mkdir -p $(subst \,/,$(OUTPUT_DIR))


$(OBJ_DIR)/%.o : %.c
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@-$(CC) $(COPS) $(addprefix -I, $(INC_FILES)) -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR

$(OBJ_DIR)/%.o : %.S
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@-$(CC) $(OPT) $(ARCH) $(DEFS) $(addprefix -I, $(INC_FILES)) -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR

ifeq ($(AS), $(TOOLCHAIN)-as)
$(OBJ_DIR)/%.o : %.s
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@$(AS) $(ASOPS) $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err >$(OBJ_DIR)/$(basename $(@F)).lst
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR
else
$(OBJ_DIR)/%.o : %.s
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@-$(CC) $(OPT) $(ARCH) $(DEFS) $(addprefix -I, $(INC_FILES)) -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR
endif

$(OBJ_DIR)/%.o : %.cpp
	@-echo +++ compile: $(subst \,/,$<) to $(subst \,/,$@)
	@$(CPP) $(CPPOPS) $(addprefix -I, $(INC_FILES)) -c $< -o $(OBJ_DIR)/$(basename $(@F)).o 2> $(OBJ_DIR)/$(basename $(@F)).err
	@-$(PYTHON) $(ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/$(basename $(@F)).err -COLOR

$(OUTPUT_DIR)/$(PRJ_NAME).elf : $(FILES_O) $(LD_SCRIPT)
	@-echo +++ link: $(subst \,/,$@)
ifeq ($(FORMAT_LINKER_ERR), )
	@$(LD) $(LOPS) $(FILES_O) $(EXTERNAL_LIB) -o $(OUTPUT_DIR)/$(PRJ_NAME).elf > $(OUTPUT_DIR)/$(PRJ_NAME).linker.txt 2>&1 || true
	 @cat $(OUTPUT_DIR)/$(PRJ_NAME).linker.txt
	 @rm $(OUTPUT_DIR)/$(PRJ_NAME).linker.txt || true
else
	@$(LD) $(LOPS) $(FILES_O) $(EXTERNAL_LIB) -o $(OUTPUT_DIR)/$(PRJ_NAME).elf 2> $(OBJ_DIR)/linker.err || true
	@-$(PYTHON) $(LINKER_ERR_MSG_FORMATER_SCRIPT) $(OBJ_DIR)/linker.err
endif

.PHONY : GENERATE
GENERATE:
	@-$(if $(wildcard $(OUTPUT_DIR)/$(PRJ_NAME).elf), ,$(error Error: Link not succeeded !))
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

.PHONY : FLASH
FLASH:
ifeq ($(COPROCESSOR), ULP-RISC-V)
	@-echo +++ Flash SBL at address 0x2000, Application at address 0x5000 and ULP at 0x8000
	@-esptool --chip esp32p4 -p $(COM_PORT) -b 460800 --before=default-reset --after=hard-reset write-flash --flash-mode dio --flash-freq 80m --flash-size 32MB 0x2000 $(SBL_BIN) 0x5000 $(OUTPUT_DIR)/$(PRJ_NAME).bin 0x8000 $(ULP_BIN) 1> /dev/null
else
	@-echo +++ Flash SBL at address 0x2000 and Application at address 0x5000
	@-esptool --chip esp32p4 -p $(COM_PORT) -b 460800 --before=default-reset --after=hard-reset write-flash --flash-mode dio --flash-freq 80m --flash-size 32MB 0x2000 $(SBL_BIN) 0x5000 $(OUTPUT_DIR)/$(PRJ_NAME).bin  1> /dev/null
endif
	@-echo +++ End

.PHONY : ERASE_ALL
ERASE_ALL:
	@-echo "+++ Erase all flash (32MB)"
	@-esptool --chip esp32p4 -p COM5 erase-flash || { echo "+++ Erase has failed !";}
	@-echo +++ End

