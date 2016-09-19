# fxclk_in, 26 MHz (period of 38.75ns makes Vivado happy)
create_clock -period 38.750 -name fxclk_in [get_ports fxclk_in]
set_property PACKAGE_PIN P15 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

# IFCLK, 104 MHz
create_clock -period 9.615 -name ifclk_in [get_ports ifclk_in]
set_property PACKAGE_PIN P17 [get_ports ifclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]

# GPIO
set_property PACKAGE_PIN V10 [get_ports {gpio_n[0]}]
set_property PACKAGE_PIN T14 [get_ports {gpio_n[1]}]
set_property PACKAGE_PIN V15 [get_ports {gpio_n[2]}]
set_property PACKAGE_PIN R16 [get_ports {gpio_n[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_n[*]}]
set_property DRIVE 4 [get_ports {gpio_n[*]}]
set_property PULLUP true [get_ports {gpio_n[3]}]
set_property PULLUP true [get_ports {gpio_n[2]}]
set_property PULLUP true [get_ports {gpio_n[1]}]
set_property PULLUP true [get_ports {gpio_n[0]}]

# Debug pins (pin number A3-A8 of ztex 2.14 fpga board)
set_property PACKAGE_PIN K16 [get_ports {debug[0]}]
set_property PACKAGE_PIN K15 [get_ports {debug[1]}]
set_property PACKAGE_PIN J15 [get_ports {debug[2]}]
set_property PACKAGE_PIN H15 [get_ports {debug[3]}]
set_property PACKAGE_PIN J14 [get_ports {debug[4]}]
set_property PACKAGE_PIN H17 [get_ports {debug[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug[*]}]

# reset
set_property PACKAGE_PIN V16 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
# from lsif
set_property PULLUP true [get_ports reset]

# location constraints
#set_property LOC PLLE2_ADV_X1Y1 [get_cells dram_fifo_inst/dram_fifo_pll_inst]

# lsi_clk
set_property PACKAGE_PIN U14 [get_ports lsi_clk]
set_property IOSTANDARD LVCMOS33 [get_ports lsi_clk]

# lsi_data
set_property PACKAGE_PIN T15 [get_ports lsi_data]
set_property IOSTANDARD LVCMOS33 [get_ports lsi_data]
set_property DRIVE 4 [get_ports lsi_data]
set_property PULLUP true [get_ports lsi_data]

# lsi_stop
set_property PACKAGE_PIN U16 [get_ports lsi_stop]
set_property IOSTANDARD LVCMOS33 [get_ports lsi_stop]

# bitstream settings
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]

#set_false_path -from [get_clocks clk_pll_i] -to [get_clocks fxclk_in]