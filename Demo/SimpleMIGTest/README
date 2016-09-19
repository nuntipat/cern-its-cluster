# SimpleMIGTest

This example test the configuration of the Xilinx's MIG core by write 1 byte of
data to the onboard DDR3 memory and read it back. The data read will be trasmitted
back to the host PC in order to compare with the predefined value via the low speed
interface of default firmware (i.e. it runs with default firmware).

The core of the low speed interface can be found in
$(ZTEXPREFIX)/default/fpga-fx3/ezusb_io.v (for FX3) and
$(ZTEXPREFIX)/default/fpga-fx2/ezusb_io.v (for FX2), respectively.
It has an SRAM like port with a 8 bit address and 32 bit data width.

The host software read one 128bits number from address 2 to 5 of the low speed interface.
Address #0 contains the done flag which will assert after the data has been read from 
the memory. Address #1 contains the error flag which will assert if the data read is not 
match with the predefined data.

User should edit the $(ZTEXPREFIX) variable in the Makefile and the batch/shell
script to match the ZTEX SDK installation directory in their development machine.
