#!/usr/bin/python

import spidev
import time
from scarf_slave          import scarf_slave

spi              = spidev.SpiDev(0,0)
spi.max_speed_hz = 1000000
spi.mode         = 0b00
ss               = scarf_slave(slave_id=0x01, num_addr_bytes=1, spidev=spi ,debug=False)

for ss_id in range(1,128):
	ss.slave_id = ss_id
	if (ss.read_id() != 0x00):
		print "Found scarf slave at 0x%02x" % ss.slave_id
