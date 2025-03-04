/*******************************************************************************

-- File Type:    Verilog HDL 
-- Tool Version: VHDL2verilog 20.51
-- Input file was: divider16x16b.vhd
-- Command line was: C:\SynaptiCAD\bin\win32\vhdl2verilog.exe divider16x16b.vhd divider16x16b.v
-- Date Created: Sun Mar 02 14:23:58 2025

*******************************************************************************/

`define false 1'b 0
`define FALSE 1'b 0
`define true 1'b 1
`define TRUE 1'b 1

`timescale 1 ns / 1 ns // timescale for following modules


module divider16x16b_new (
   clk,
   dividend,
   divider,
   quotient,
   remainder,
   wr_valid,
   rd_valid);
 
parameter WIDTH = 8;

input   clk; 
input   [WIDTH - 1:0] dividend; 
input   [WIDTH - 1:0] divider; 
output   [WIDTH - 1:0] quotient; 
output   [WIDTH - 1:0] remainder; 
input   wr_valid; 
output   rd_valid; 

reg     [WIDTH - 1:0] quotient; 
reg     [WIDTH - 1:0] remainder; 
reg     rd_valid; 
reg     [WIDTH - 1:0] up; 
reg     [WIDTH - 1:0] down; 
reg     [WIDTH - 1:0] temp; 
reg     [WIDTH - 1:0] res_temp; 
reg     [WIDTH - 1:0] result; 
wire    [WIDTH - 1:0] remain; 
reg     rd_valid_tmp; 
reg     rd_valid_tmp2; 
reg     rd_valid_tmp3; 
reg     [3:0] b; 
reg     [WIDTH - 1:0] quotient_temp; 
reg     [WIDTH - 1:0] remainder_temp; 


always @(posedge clk)
   begin : process_1
   if (wr_valid === 1'b 1)
      begin
      up <= dividend;   
      down <= divider;   
      result <= {(WIDTH){1'b 0}};   
      temp <= {(WIDTH){1'b 0}};   
      b <= 0;   
      res_temp <= {(WIDTH){1'b 0}};   
      rd_valid_tmp <= 1'b 0;   
      rd_valid_tmp2 <= 1'b 0;   
      rd_valid_tmp3 <= 1'b 0;   
      end
   else
      begin
      if (b < WIDTH)
         begin
         if (temp < down)
            begin
            temp <= {temp[WIDTH - 2:0], up[WIDTH - b - 
      1]};   
//  shift in bits MSB first from up into temp register while temp < down
            b <= b + 1;   
            end
         else
            begin
            result[WIDTH - b - 1] <= 1'b 1;   
//  set to 1 respective bits in result register
            temp <= temp - down;   
//  subtraction down from temp register
            end
         rd_valid_tmp <= 1'b 0;   
         end
      else
         begin
         if (temp >= down)
            begin
            result <= {result[WIDTH - 2:0], 1'b 1};   
            temp <= temp - down;   
            end
         else
            begin
            result <= {result[WIDTH - 2:0], 1'b 0};   
            end
         rd_valid_tmp <= 1'b 1;   
         rd_valid_tmp2 <= rd_valid_tmp;   
         end
      rd_valid_tmp3 <= rd_valid_tmp & ~rd_valid_tmp2;   
//  rd_valid pulse one cycle width generation
      quotient_temp <= result;   
      remainder_temp <= temp;   
      end
   end


always @(posedge clk)
   begin : output_gen
   if (clk === 1'b 1)
      begin
      if (rd_valid_tmp3 === 1'b 1)
         begin
         quotient <= quotient_temp;   
         remainder <= remainder_temp;   
         rd_valid <= 1'b 1;   
         end
      else
         begin
         rd_valid <= 1'b 0;   
         end
      end
   end


endmodule // module divider16x16b_new

