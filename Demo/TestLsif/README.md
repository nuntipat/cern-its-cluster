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