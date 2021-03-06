# SCARF
SCARF - “Scarf Connects A Raspberry pi to Fpga”

SCARF is a bare-bones SPI slave written in systemverilog, which clock-crosses input and output data
to the FPGA clock domain. It’s goal is to provide a simple, uniform interface to FPGA designs,
allowing them to be easily controlled from a single external SPI master (A Raspberry pi).

SCARF comes with python drivers and example code.

Whether you have a single design to implement in the FPGA or several, they all can share a single 4pin
SPI interface. For simplicity the SPI slave works only with CPOL=0 and CPHA=0.

Why use SCARF? If you want to send data to/from your FPGA using a Raspberry Pi, the SPI bus is
fast and has low overhead. The SCARF block is less than 60 flipflops and the interface is very simple.
Once you see how easy it is to interface to your FPGA designs, say good-bye to custom interfaces.
SCARF has a mechanism for individual designs to respond to a generic query command, which can be
used to see all SCARF slaves on the bus. In my bench FPGA I have 20 or more designs implemented
and SCARF keeps them all organized for me, just as if they were all individual ICs connected on a
circuit board.

My FPGA development board is a Digilent CMOD A7-35t, and I included the pin constraint file which I used
to implement a sample SCARF design. This board has an external SRAM which is used in the verilog and python
examples. I wanted to show that SCARF can be used to interface to memories directly.

In the verilog directory scarf_top.sv is the top-level.

In the docs directory I am missing a document describing how edge_counter.sv works... I should be adding
that soon. I use a single SCARF register map to control 4 instances of edge_counters.

SCARF can also be used as an emulation channel for mixed-signal ASICs or mixed-signal blocks on SOCs. This is 
when the ASIC or SOC digital block is implemented in an FPGA. A SCARF register map can be implemented in the FPGA
and loaded with DAC values which correspond to analog voltages and currents. ADC, autocal and comparator models can 
be controlled with the loaded DAC values, and use-cases can be emulated (including fault conditions). This can be 
very useful when testing firmware drivers for the ASIC or SOC before it tapes-out.
