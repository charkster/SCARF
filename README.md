# SCARF
![picture](https://github.com/charkster/SCARF/blob/master/docs/SCARF.png)

**SCARF** - “**S**carf **C**onnects **A** **R**aspberry pi to **F**pga”

**UART** and **SPI** data streams can be **difficult** to organize when a Host (Raspberry Pi or PC) communicates with a FPGA slave. **I2C** is very **structured** in how it allows a single Host to communicate with **multiple slaves**. I wanted to **merge** the **structured aspects** of I2C with the **high-throughput** and **full-duplex** capabilities of **UART** and **SPI**. This is what **SCARF is, I2C like communication over UART and SPI buses.** I provide the simple RTL and Python code to talk to it.

**SCARF** really **shines** when the FPGA board has a **USB-UART** bridge chip, allowing the board to have **both power and communication on the same cable.** 

The **first byte** sent to the FPGA contains the **Slave ID and Read-not-Write bit**. The most significant bit is the **RNW bit** and the lower 7bits are the **Slave ID**. The **Slave ID** allows different blocks on the FPGA to **ignore** bus traffic when their ID is not given. The provided RTL has the **Slave ID** defined as a parameter.

The next bytes are the **address data**. The provided RTL allows for a **parameterized** number of address bytes. A SDIO memory interface block might need many address bytes and a simple trigger block might just need a few bits from one byte of address data. The **number of address bytes is flexible**, but the RTL specified Slave ID and number of address bytes needs to be correctly transferred to the Python script.

The next bytes are either the **write data** or in the case of a **read, filler bytes** to keep the chip select active (**SPI**). When doing a read, if 5 bytes are wanted, 6 filler bytes need to be written to the FPGA. As **UART does not have a chip select**, I have a **SCARF** version where the **number of bytes** to read is used instead of filler bytes. The Python code fully takes care of these **finer details**, while remaining **easy to read** and **understand.**

The **maximum number** of read/write data bytes is **determined by the hardware SPI or UART master.** The provided RTL has **no limit.** If the FPGA board’s **USB-UART** bridge is used, the TX and RX buffers are **fixed in size** and must not be exceeded. If **SPI** is used, the **SPI** master’s transmit and receive byte **limits** also must be followed. The provided Python code has places for these limits to be specified.

When read data returns to the Host, the **first byte sent by the FPGA will be the RNW bit and Slave ID.** This can be used similar to how a I2C master can quickly **query all slaves connected** to the bus. This byte can be safely discarded.

That’s it. My **Raspberry Pi** can reliably run a **SPI** clock of **12MHz**, and most FPGA on-board **USB-UART** bridges can run at **1M baud or faster.** 
