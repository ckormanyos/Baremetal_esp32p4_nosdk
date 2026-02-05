/******************************************************************************************
  Filename    : coprocessor.ld
  
  Core        : RISC-V
  
  MCU         : ESP32-P4
    
  Author      : Chalandi Amine
 
  Owner       : Chalandi Amine
  
  Date        : 24.02.2025
  
  Description : Linker description file script for ESP32-P4 co-processor (ULP-RISC-V)
  
******************************************************************************************/

/******************************************************************************************
 ELF Entrypoint
******************************************************************************************/
ENTRY(_start)

/******************************************************************************************
 Globals
******************************************************************************************/
__STACK_SIZE = 1K;

/******************************************************************************************
 Memory configuration
******************************************************************************************/

MEMORY
{
  FLASH(rx)     : ORIGIN = 0x40008000, LENGTH = 1M
  RAM(rwx)      : ORIGIN = 0x49F00000, LENGTH = 1M
  HP_L2MEM(rwx) : ORIGIN = 0x4FF00000, LENGTH = 768K
  LP_SRAM(rwx)  : ORIGIN = 0x50108000, LENGTH = 32K
}

/******************************************************************************************
 Sections definition
******************************************************************************************/
SECTIONS
{
  /* Program code (text) */
  .text : ALIGN(4)
  {
    PROVIDE(__CODE_BASE_ADDRESS = .);
    *(.boot)
    *(.text)
    . = ALIGN(4);
  } > FLASH

  /* Read-only data (.rodata) */
  .rodata : ALIGN(4)
  {
    PROVIDE(__RODATA_BASE_ADDRESS = .);
    *(.rodata)
  } > FLASH

 /* Section for constructors */
  .ctors : ALIGN(4)
  {
    PROVIDE(__CTOR_LIST__  = .);
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array))
    LONG(-1) ;
    PROVIDE(__CTOR_END__  = .);
    . = ALIGN(4);
  }  > FLASH


  /* Section for destructors */
  .dtors : ALIGN(4)
  {
    PROVIDE(__DTOR_LIST__  = .);
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array))
    LONG(-1) ;
    PROVIDE(__DTOR_END__  = .);
    . = ALIGN(4);
  } > FLASH

  /* Runtime clear table */
  .clear_sec : ALIGN(4)
  {
    PROVIDE(__RUNTIME_CLEAR_TABLE = .) ;
    LONG(0 + ADDR(.bss));   LONG(SIZEOF(.bss));
    LONG(-1);                 LONG(-1);
    . = ALIGN(4);
  } > FLASH

  /* Runtime copy table */
  .copy_sec : ALIGN(4)
  {
    PROVIDE(__RUNTIME_COPY_TABLE = .) ;
    LONG(LOADADDR(.data));   LONG(0 + ADDR(.data));   LONG(SIZEOF(.data));
    LONG(-1);                LONG(-1);                LONG(-1);
    . = ALIGN(4);
    PROVIDE(__CODE_END_ADDRESS = .);
  } > FLASH 

  /* The ROM-to-RAM initialized data sections */
  .data : ALIGN(4) 
  {
    *(.data)
    *(.data*)
    . = ALIGN(4);
  } > RAM  AT>FLASH
  
  /* The uninitialized (zero-cleared) data sections */
  .bss : ALIGN(4)
  {
    *(.bss)
    *(.bss*)
    . = ALIGN(4);
  } > RAM

  /* stack definition */
  .stack :
  {
    PROVIDE(__STACK_BOTTOM = .) ;
    . = ALIGN(MAX(__STACK_SIZE , .), 8);
    PROVIDE(__STACK_TOP = .) ;
  } > RAM

  /* ROM APIs */
  printf = 0x4fc00024;

}
