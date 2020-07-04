
module tb_spi_slave_lbus ();

   parameter EXT_CLK_PERIOD_NS = 83;
   parameter SCLK_PERIOD_NS = 83;

   wire [18:0] sram_addr;
   wire [7:0]  sram_data;
   wire        sram_cen;
   wire        sram_wen;
   wire        sram_oen;
   reg         clk;
   reg         reset;
   reg         sclk;
   reg         ss_n;
   reg         mosi;
   wire        miso;
   integer     error_count;

   initial begin
      clk = 1'b0;
      forever
        #(EXT_CLK_PERIOD_NS/2) clk = ~clk;
   end

   task send_byte (input [7:0] byte_val);
      begin
         $display("Called send_byte task: given byte_val is %h",byte_val);
         sclk  = 1'b0;
         for (int i=7; i >= 0; i=i-1) begin
            $display("Inside send_byte for loop, index is %d",i);
            mosi = byte_val[i];
            #(SCLK_PERIOD_NS/2);
            sclk  = 1'b1;
            #(SCLK_PERIOD_NS/2);
            sclk  = 1'b0;
         end
      end
   endtask
   
   task check_byte (input [7:0] send_byte_val, input [7:0] check_byte_val);
      begin
         $display("Called send_byte_check_byte task: send_byte_val is %h, check_byte_val is %h",send_byte_val,check_byte_val);
         sclk  = 1'b0;
         for (int i=7; i >= 0; i=i-1) begin
           //$display("Inside send_byte for loop, index is %d",i);
           mosi = send_byte_val[i];
           #(SCLK_PERIOD_NS/2);
           sclk  = 1'b1;
           if (miso != check_byte_val[i]) begin
              $display("Miscompare of MISO bit #%d, expected %b, actual is %b",i,check_byte_val[i],miso);
              error_count = error_count + 1;
           end
           #(SCLK_PERIOD_NS/2);
           sclk  = 1'b0;
         end
      end
   endtask

   initial begin
      error_count = 'd0;
      reset = 1'b1;
      sclk  = 1'b0;
      ss_n  = 1'b1;
      mosi  = 1'b0;
      #SCLK_PERIOD_NS;
      reset = 1'b0;
      #(SCLK_PERIOD_NS*8);
      $display("Load the SRAM with the pattern data");
      $display("Write a 3 bytes to sram address 0x00000");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h02); // {1'b0,7'd2}, rnw = 0, slave_id = 2
      send_byte(8'h00); // this is the upper  byte of sram address
      send_byte(8'h00); // this is the middle byte of sram address
      send_byte(8'h00); // this is the lower  byte of sram address
      send_byte(8'h34); // 1st write bytye
      send_byte(8'h42); // 2nd write bytye
      send_byte(8'hA1); // 3rd write bytye
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      $display("Verify that the pattern data was loaded");
      $display("Read 3 bytes from sram address 0x00000");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h82);        // {1'b1,7'd2}, rnw = 1, slave_id = 2
      send_byte(8'h00);        // this is the upper  byte of sram address
      send_byte(8'h00);        // this is the middle byte of sram address
      send_byte(8'h00);        // this is the lower  byte of sram address
      check_byte(8'h00,8'h02); // echoed slave_id comes out
      check_byte(8'h00,8'h34); // 1st byte comes out
      check_byte(8'h00,8'h42); // 2nd byte comes out
      check_byte(8'h00,8'hA1); // 3rd byte comes out
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      $display("Configure the pattern generator, stop_address=0x000002");
      $display("Write 3 bytes byte to slave_id 0x01 address 0x02");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01); // {1'b0,7'd1}, rnw = 0, slave_id = 1
      send_byte(8'h02); // single byte address
      send_byte(8'h00); // upper stop address
      send_byte(8'h00); // mid   stop address
      send_byte(8'h02); // lower stop address
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      $display("Verify that the pattern generator stop address was configured");
      $display("Read 3 bytes byte to slave_id 0x01 address 0x02");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h81);        // {1'b1,7'd1}, rnw = 1, slave_id = 1
      send_byte(8'h02);        // address
      check_byte(8'h00,8'h01); // echoed slave_id comes out
      check_byte(8'h00,8'h00); // 1st byte comes out
      check_byte(8'h00,8'h00); // 2nd byte
      check_byte(8'h00,8'h02); // 3rd byte
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      $display("Read from a slave_id that does not exist in design");
      $display("Read 1 bytes byte to slave_id 0x04 address 0x0A");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h84);        // {1'b1,7'd1}, rnw = 1, slave_id = 1
      send_byte(8'h0A);        //  address
      check_byte(8'h00,8'h00); // slave_id is not echoed
      check_byte(8'h00,8'h00); // 1st byte comes out, zeros
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      $display("Configure the pattern generator, num_pins=4, timescale=0");
      $display("Write 1 bytes byte to slave_id 0x01 address 0x01");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01); // {1'b0,7'd1}, rnw = 0, slave_id = 1
      send_byte(8'h01); // single byte address
      send_byte(8'h02); // value at address 0x00
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      $display("Configure the pattern generator, stage1=4'd12, enable the pattern no repeat");
      $display("Write 1 bytes byte to slave_id 0x01 address 0x00");
      ss_n  = 1'b0;
      mosi  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      send_byte(8'h01); // {1'b0,7'd1}, rnw = 0, slave_id = 1
      send_byte(8'h00); // single byte address
      send_byte(8'hC1); // 4'hC = 12 decimal, enable = 1
      ss_n  = 1'b1;
      #(SCLK_PERIOD_NS * 8);
      #10us;
      $finish;
   end

   // dump waveforms
   initial begin
      $shm_open("waves.shm");
      $shm_probe("MAS");
   end

   logic [7:0] gpio_pat_gen_out;


   scarf_top u_scarf_top
     ( .clk,                                  // input
       .reset,                                // input
       .sclk,                                 // input
       .ss_n,                                 // input
       .mosi,                                 // input
       .miso,                                 // output
       .sram_addr,                            // output [18:0]
       .sram_data,                            // inout  [7:0]
       .sram_oen,                             // output
       .sram_wen,                             // output
       .sram_cen,                             // output
       .gpio_pat_gen_out,                     // output [7:0]
       .pattern_done   (),                    // output
       .gpio_0_in      (gpio_pat_gen_out[0]), // input
       .gpio_1_in      (gpio_pat_gen_out[1]), // input
       .gpio_2_in      (gpio_pat_gen_out[2]), // input
       .gpio_3_in      (gpio_pat_gen_out[3])  // input
       );

   ram_model u_ram_model
     ( .sram_addr, // input [18:0]
       .sram_data, // inout [7:0]
       .sram_cen,  // input
       .sram_wen,  // input
       .sram_oen   // input
       );

endmodule
