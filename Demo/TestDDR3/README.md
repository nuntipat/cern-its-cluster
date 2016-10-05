# TestDDR3

This example fills the onboard DDR3 memory with data from the random number generator
and read the data back in order to verify and benchmark the memory and the memory controller. 
Since the onboard memory has 16bits bus width and the memory controller is operated with
burst length = 8, the data is written and read back 128bits at a time.

The low speed interface is used to transmit flag and test result to the host PC 
Address #0 : done flag (Active-high asserted when done)
Address #1 : error flag (Active-high asserted when there is an error)
Address #2-5 : last data retreive from random number generator when done or error
Address #6-9 : last data read from memory when done or error

In addition to the low speed interface, pin A3 is used as a write flag (active-high) which
will asserted when data is written to the memory and pin A4 is used as a read flag (active-high)
which will asserted when data is being read from the memory.

The core of the low speed interface can be found in
$(ZTEXPREFIX)/default/fpga-fx3/ezusb_io.v (for FX3) and
$(ZTEXPREFIX)/default/fpga-fx2/ezusb_io.v (for FX2), respectively.
It has an SRAM like port with a 8 bit address and 32 bit data width.

User should edit the $(ZTEXPREFIX) variable in the Makefile and the batch/shell
script to match the ZTEX SDK installation directory in their development machine.

## preliminary result

* Write ~1303 MB/s
* Read ~1413 MB/s