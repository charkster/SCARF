
module scarf_pattern_generator
  ( input  logic        clk,
    input  logic        rst_n_sync,
    input  logic  [7:0] data_in,
    input  logic        data_in_valid,
    input  logic        data_in_finished,
    input  logic  [6:0] slave_id,
    input  logic        rnw,
    output logic  [7:0] read_data_out,
    output logic        pattern_active,
    output logic        pattern_done,
    output logic  [7:0] gpio_pat_gen_out,
    input  logic  [7:0] sram_data,
    output logic [18:0] sram_addr_pat_gen
    );
    
   parameter SLAVE_ID = 7'd01;
   
   logic [23:0] end_address_pat_gen;
   logic        enable_pat_gen;
   logic  [1:0] num_gpio_sel_pat_gen;
   logic  [2:0] timestep_sel_pat_gen;
   logic        repeat_enable_pat_gen;
   logic  [3:0] stage1_count_sel_pat_gen;
   
   scarf_regmap 
   # ( .SLAVE_ID( SLAVE_ID ) )
   u_scarf_regmap_pattern_gen
     ( .clk,                     // input
       .rst_n_sync,              // input
       .data_in,                 // input [7:0]
       .data_in_valid,           // input
       .data_in_finished,        // input
       .slave_id,                // input [6:0]
       .rnw,                     // input
       .read_data_out,           // output [7:0]
       .end_address_pat_gen,     // output [23:0]
       .enable_pat_gen,          // output
       .repeat_enable_pat_gen,   // output
       .num_gpio_sel_pat_gen,    // output [1:0]
       .timestep_sel_pat_gen,    // output [2:0]
       .stage1_count_sel_pat_gen // output [3:0]
      );
      
   pattern_gen u_pattern_gen
     ( .clk,                              // input
       .rst_n               (rst_n_sync), // input
       .enable_pat_gen,                   // input
       .end_address_pat_gen,              // input  [23:0]
       .num_gpio_sel_pat_gen,             // input  [1:0]
       .timestep_sel_pat_gen,             // input  [2:0]
       .stage1_count_sel_pat_gen,         // input  [3:0]
       .repeat_enable_pat_gen,            // input
       .pattern_active,                   // output
       .pattern_done,                     // output
       .gpio_pat_gen_out,                 // output [7:0]
       .sram_data,                        // input  [7:0]
       .sram_addr_pat_gen                 // output [18:0]
       );
       
 endmodule