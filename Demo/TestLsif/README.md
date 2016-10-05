# TestLsif

This example demonstrates the usage of the low speed interface of
default firmware (i.e. it runs with default firmware).

The core of the low speed interface can be found in
$(ZTEXPREFIX)/default/fpga-fx3/ezusb_io.v (for FX3) and
$(ZTEXPREFIX)/default/fpga-fx2/ezusb_io.v (for FX2), respectively.
It has an SRAM like port with a 8 bit address and 32 bit data width.

The host software writes 2 numbers to address 0 and 1, the FPGA sum these
numbers. The result can be read back from the host through address 2 of the
low speed interface.

User should edit the $(ZTEXPREFIX) variable in the Makefile and the batch/shell
script to match the ZTEX SDK installation directory in their development machine.