@echo off

start /B openocd -f openocd_esp32p4.cfg

riscv32-esp-elf-gdb -x gdb_esp32p4.cfg ../../Output/baremetal_esp32p4_nosdk.elf
