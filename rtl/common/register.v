`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2025 21:27:53
// Design Name: 
// Module Name: register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ConfigurableRegister #(
    parameter WIDTH = 32  // Number of bits (can be any value)
)(
    input  wire              clk,
    input  wire              rst,    // Active-high synchronous reset
    input  wire              en,   // Load enable signal
    input  wire [WIDTH-1:0]  data_in,
    output reg  [WIDTH-1:0]  data_out
);

    always @(posedge clk) begin
        if (rst) begin
            data_out <= {WIDTH{1'b0}};
        end else if (en) begin
            data_out <= data_in;
        end
    end

endmodule
