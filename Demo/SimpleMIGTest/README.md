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

## Prerequisities
1. [Java SE Development Kit 8 (JDK8)](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
2. [ZTEX EZ-USB SDK](http://www.ztex.de/downloads/#firmware_kit) Release 160513
(Newer releases aren't currently support due to major API change, see [API changes in releases 20160129 and 20160818](http://wiki.ztex.de/doku.php?id=en:software:api_changes))

## Usage
1. Edit ZTEXPREFIX variable in the Makefile and the batch/shell script to the path
to your Ztex's SDK
2. Build the java console application using the Makefile
```
make
```
3. Execute the script. The script will upload the bit stream to the FPGA and display
results to your console