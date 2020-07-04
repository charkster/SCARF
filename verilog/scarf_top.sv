
module scarf_top
  ( input  logic        clk,              // 12MHz clock
    input  logic        reset,            // button
    input  logic        sclk,             // SPI CLK
    input  logic        ss_n,             // SPI CS_N
    input  logic        mosi,             // SPI MOSI
    output logic        miso,             // SPI MISO
    output logic [18:0] sram_addr,        // ext sram address
    inout  logic  [7:0] sram_data,        // ext sram data (bidir)
    output logic        sram_oen,         // ext sram output enable (active low)
    output logic        sram_wen,         // ext sram write enable  (active low)
    output logic        sram_cen,         // ext sram chip enable   (active low)
    output logic  [7:0] gpio_pat_gen_out, // pattern generation outputs 
    output logic        pattern_done,     // indicator to software that pattern has completed
    input  logic        gpio_0_in,        // edge counter 0
    input  logic        gpio_1_in,        // edge counter 1
    input  logic        gpio_2_in,        // edge counter 2
    input  logic        gpio_3_in         // edge counter 3
    );

   logic        rst_n;
   logic        rst_n_sync;
   logic  [7:0] read_data_in;
   logic  [7:0] read_data_out_pat_gen;
   logic  [7:0] read_data_out_sram;
   logic  [7:0] read_data_out_edge;
   logic  [7:0] sram_wdata;
   logic  [7:0] data_out;
   logic        data_out_valid;
   logic        data_out_finished;
   logic  [6:0] slave_id;
   logic        rnw;
   logic        rd_en_sram;
   logic [18:0] sram_addr_scarf;
   logic        sram_oen_scarf;
   logic        sram_cen_scarf;
   logic        sram_wen_scarf;
   logic [18:0] sram_addr_pat_gen;
   logic        pattern_active;
   
   assign rst_n     = ~reset;
   assign sram_data = (sram_oen) ? sram_wdata : 'z;
   
   scarf u_scarf
     ( .sclk,                // input
       .mosi,                // input
       .miso,                // output
       .ss_n,                // input
       .clk,                 // input
       .rst_n,               // input
       .read_data_in,        // input  [7:0]
       .rst_n_sync,          // output
       .data_out,            // output [7:0]
       .data_out_valid,      // output
       .data_out_finished,   // output
       .slave_id,            // output [6:0]
       .rnw                  // output
      );
   
   always_comb begin
     sram_addr = (pattern_active) ? sram_addr_pat_gen : sram_addr_scarf;
     sram_oen  = (pattern_active) ? 1'b0              : sram_oen_scarf;
     sram_cen  = (pattern_active) ? 1'b0              : sram_cen_scarf;
     sram_wen  = (pattern_active) ? 1'b1              : sram_wen_scarf;
   end
       
   scarf_pattern_generator 
   # ( .SLAVE_ID(7'h01) )
   u_scarf_pattern_generator
     ( .clk,                                      // input
       .rst_n_sync,                               // input
       .data_in          (data_out),              // input [7:0]
       .data_in_valid    (data_out_valid),        // input
       .data_in_finished (data_out_finished),     // input
       .slave_id,                                 // input [6:0]
       .rnw,                                      // input
       .read_data_out    (read_data_out_pat_gen), // output [7:0]
       .pattern_active,                           // output
       .pattern_done,                             // output
       .gpio_pat_gen_out,                         // output [7:0]
       .sram_data,                                // input  [7:0]
       .sram_addr_pat_gen                         // output [18:0]
       );
             
   assign read_data_in = read_data_out_pat_gen | read_data_out_sram | read_data_out_edge;
             
   scarf_ext_sram 
   # ( .SLAVE_ID(7'h02) )
   u_scarf_ext_sram
     ( .clk,                                        // input
       .rst_n_sync,                                 // input
       .data_in             (data_out),             // input [7:0]
       .data_in_valid       (data_out_valid),       // input
       .data_in_finished    (data_out_finished),    // input
       .slave_id,                                   // input
       .rnw,                                        // input
       .read_data_out       (read_data_out_sram),   // output [7:0]
       .sram_data_in        (sram_data),            // input  [7:0]
       .sram_data_out       (sram_wdata),           // output [7:0]
       .sram_addr           (sram_addr_scarf),      // output [18:0]
       .sram_oen            (sram_oen_scarf),       // output
       .sram_wen            (sram_wen_scarf),       // output
       .sram_cen            (sram_cen_scarf)        // output
      );
      
   scarf_4_edge_counters
   # ( .SLAVE_ID(7'h03) )
   u_scarf_4_edge_counters
     (  .clk,                                    // input
        .rst_n_sync,                             // input
        .data_in           (data_out),           // input  [7:0]
        .data_in_valid     (data_out_valid),     // input
        .data_in_finished  (data_out_finished),  // input
        .slave_id,                               // input  [6:0] 
        .rnw,                                    // input          
        .read_data_out     (read_data_out_edge), // output [7:0] 
        .gpio_0_in,                              // input
        .gpio_1_in,                              // input
        .gpio_2_in,                              // input
        .gpio_3_in                               // input
       );
         
endmodule
