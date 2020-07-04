#!/usr/bin/python

import spidev
import time
from scarf_slave          import scarf_slave
from scarf_pat_gen        import scarf_pat_gen
from scarf_4_edge_counter import scarf_4_edge_counter

spi              = spidev.SpiDev(0,0)
spi.max_speed_hz = 12000000
spi.mode         = 0b00
sram    = scarf_slave         (slave_id=0x02, spidev=spi, num_addr_bytes=3, debug=False)
pat_gen = scarf_pat_gen       (slave_id=0x01, spidev=spi,                   debug=False)
counter = scarf_4_edge_counter(slave_id=0x03, spidev=spi,                   debug=True)

print "sram slave id is 0x%02x" % sram.read_id()
print "pat_gen slave id is 0x%02x" % pat_gen.scarf_slave.read_id()

sram.write_list(addr=0x000000, write_byte_list=[0b01110110, 0b11110010, 0x38])
pat_gen.cfg_sram_end_addr(end_addr=0x000001)
pat_gen.cfg_pat_gen(timestep=0, num_gpio=1)
pat_gen.cfg_stage1_count(stage1_count=12)
counter.counter_enable(enable_nibble=0x01) # enable the counter to capture the high duration on gpio1
pat_gen.cfg_enable()
time.sleep(1)
print "high duration was %g us" % (counter.get_count_val(1,1) * (1.0/12.0))

read_data = sram.read_list(addr=0x000000,num_bytes=3)
address = 0
for read_byte in read_data:
	print "SRAM Byte #%d Read data 0x%02x" % (address,read_byte)
	address += 1

pat_gen.read_all_regmap()
