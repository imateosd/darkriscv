`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Irene Mateos Dom�nguez
//////////////////////////////////////////////////////////////////////////////////

module synchronizer(
    input wire in,
    input wire CLK,
    output wire out
    );
    reg in_sync_0, in_sync_1;
    always @(posedge CLK) begin
        in_sync_0 <= in;
        in_sync_1 <= in_sync_0;
    end
    assign out = in_sync_1;
endmodule