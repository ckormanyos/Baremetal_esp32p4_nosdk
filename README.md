Bare Metal ESP32-P4 Project
============================

[![Build Status](https://github.com/chalandi/Baremetal_esp32p4_nosdk/actions/workflows/Baremetal_esp32p4_nosdk.yml/badge.svg)](https://github.com/chalandi/Baremetal_esp32p4_nosdk/actions)

This repository implements a fully from scratch bare-metal project for the ESP32-P4 multicore RISC-V SoC without using Espressif's SDK.

Features:

- Custom Second Stage Bootloader (SBL).
- Dual-core High-Performance RISC-V support.
- ULP-RISC-V coprocessor support.
- PSRAM support.
- User code execution from Flash and PSRAM via MMU mapping.

A clear, easy-to-understand implementation in C11 and Assembly, combined with a build system based on GNU Make, makes this project both fun and educational. 

This repository provides valuable insights into starting a bare-metal ESP32-P4 project from the ground up.

## The Custom Second Stage Bootloader (SBL)

This project implements a custom SBL developed from scratch.

During a cold boot, the ESP32-P4's bootROM loads the custom SBL from Flash address 0x2000 into the internal memory HP_TCM.

The SBL runs on HP core 0 and responsible for the following:

- Disabling all active watchdog timers.
- Initializing the HP core clock to 400 MHz.
- Initializing the LP core clock to 40 MHz.
- Initializing the PSRAM interface.
- Configuring the MMU to map the Flash and PSRAM address spaces (Full 64MB flat mapping is supported).
- Waking HP core 1, as well as the LP core (if the Makefile variable COPROCESSOR is set to ULP-RISC-V).
- Booting the HP cores from Flash address 0x5000 (mapped to MMU space 0x40005000).
- Booting the LP core from Flash address 0x8000 (mapped to MMU space 0x40008000).


## Details on the Application

Because both HP cores boot from the same entry point (0x40005000), the application implements a pure SMP boot flow.

The low-level startup process begins on HP Core 0, which initializes the C/C++ runtime environment. During this phase, HP Core 1 is held in a spin loop, waiting for Core 0 to complete the initialization sequence.

Since the RISC-V architecture lacks native WFE/SEV instructions for SMP synchronization, Core 0 notifies Core 1 that the runtime environment setup is complete via the machine software interrupt pending flag in the CLINT of Core 1 to emulate a cross-core event trigger.

Once synchronized, both cores execute the main() function, enable global interrupts, and enter an idle loop. Each core then toggles its own LED at a 1 Hz frequency, driven by its respective private timer interrupt.

## Co-Processor image

To build the coprocessor (ULP-RISC-V) image, define the following variable in the Makefile:

```sh
COPROCESSOR = ULP-RISC-V
```

## Building the Application image

To build the application image, you need an installed RISC-V GCC compiler (riscv32-esp-elf) you can download it from link below in Tools section.

Run the following commands :

```sh
cd ./Build
Rebuild.sh
```

## Building the full binary image (SBL, ULP and Application)

To build the project, you need an installed RISC-V GCC compiler (riscv32-esp-elf) you can download it from link below in Tools section.

Run the following commands :

```sh
cd ./Build
Rebuild.sh all
```

The build process generates the following artifacts in the `Output` directory :

  - ELF file
  - HEX mask
  - Assembly listing
  - MAP file
  - Binary file for flashing to ESP32-P4 QSPI memory

## Flashing the final binary

To flash the application update the make variable COM_PORT to match yours and run the following command:

```sh
cd ./Build
Flash.sh
```

## Tools

The following tools are needed to build, flash and debug this project:

| Tool                | Link                                                |
| ------------------- | --------------------------------------------------- |
| RISC-V GCC compiler | https://github.com/espressif/crosstool-NG/releases  |
| OpenOCD for ESP32   | https://github.com/espressif/openocd-esp32/releases |
| GDB for ESP32       | https://github.com/espressif/binutils-gdb/releases  |
| esptool             | run this command: pip install esptool               |

## Continuous Integration

CI runs on pushes and pull-requests with a simple build and result verification on `ubuntu-latest` using GitHub Actions.
