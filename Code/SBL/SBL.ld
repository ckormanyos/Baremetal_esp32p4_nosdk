/******************************************************************************************
  Filename    : linker.ld
  
  Core        : RISC-V
  
  MCU         : ESP32-P4
    
  Author      : Chalandi Amine
 
  Owner       : Chalandi Amine
  
  Date        : 25.01.2026
  
  Description : SBL linker file
  
******************************************************************************************/

ENTRY(_start)


MEMORY
{
  HP_TCM(rwx)  : ORIGIN = 0x30100000, LENGTH = 8k
}


SECTIONS
{
   .text : { *(.boot) *(.rodata) } > HP_TCM
}

/***************************************
  Const
 ***************************************/
__app_entry_point = 0x40005000;
__ulp_entry_point = 0x40008000;

/***************************************
  Peripheral Address
 ***************************************/
SPIMEM2       = 0x5008E000;
SPIMEM3       = 0x5008F000;
LPPERI        = 0x50120000;
HP_SYS_CLKRST = 0x500E6000;

/***************************************
  ROM APIs
 ***************************************/
ets_printf              = 0x4fc00024;
esp_rom_spi_set_op_mode = 0x4fc00110;
esp_rom_spi_cmd_config  = 0x4fc00108;
esp_rom_spi_cmd_start   = 0x4fc0010c;
ets_clk_get_xtal_freq   = 0x4fc0055c;
ets_clk_get_cpu_freq    = 0x4fc00560;