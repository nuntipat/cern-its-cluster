# Timing Result

This directory contains several timing diagrams captured from the logic analyzer. 

Three active-high signals (D0, D1 and D2) were measured from pin A3, A4 and A5 of ZTEX 2.14b
USB-FPGA module. These signal asserted when the system write to memory, read from memory and
when every operations was done respectively.

Time used to write 16MB of data to memory was measured to be 12.4ms or ~1290MB/s.
Time used to read 16MB of data from memory was measured to be 276.2ms or ~58MB/s.