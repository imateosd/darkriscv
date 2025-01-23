`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2024 18:24:41
// Design Name: 
// Module Name: I2Csim
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
`timescale 1ns / 1ps
`include "../rtl/config.vh"


module I2Csim;

    reg CLK = 0;
    
    reg RES = 1;
    
    reg [31:0] IADDR;
    reg [31:0] DADDR;
    reg [31:0] IDATA;
    reg [31:0] DATAO;
    reg [31:0] DATAI;
    reg        WR,RD;
    reg [3:0]  BE;  


    // For I2C Master
    reg  [23:0] i_byte_len;
    reg  [7:0]  slave_addr;
    reg  [15:0] i_sub_addr;
    reg  [7:0]  i_data_write;

    reg HLT;

    initial while(1) #(500e6/`BOARD_CK) CLK = !CLK; // clock generator w/ freq defined by config.vh

    integer i;

    initial
    begin
`ifdef __ICARUS__
        $dumpfile("darksocv.vcd");
        $dumpvars();

    `ifdef __REGDUMP__
    
    
    
        for(i=0;i!=`RLEN;i=i+1)
        begin
            $dumpvars(0,soc0.core0.REGS[i]);
        end
    `endif
`endif
        $display("reset (startup)");
        #1e3 RES = 0;            // wait 1us in reset state
        #1e3 RES = 1;            // run  1ms
        #1e3 RES = 0;            // run  1ms
        $display("reset (restart)");
        #1 DADDR = 32'h80000018;
        #1 DATAO = 32'h03620D01;
        #6000e3 WR = 1;            // run  6s
//        #1e3    RES = 0;            // wait 1us in reset state
        #1000e3 $finish();          // run  1s
    end
    
    i2c_master
    i2c_master0
    (
        .i_clk(CLK),
        .reset_n(!RES),
        .i_addr_w_rw( DATAO[23:16] ),       //7 bit address, LSB is the read write bit, with 0 being write, 1 being read
        .i_sub_addr( DATAO[15:8] ),        //contains sub addr to send to slave, partition is decided on bit_sel
        .i_sub_len( 1'b0 ),          //denotes whether working with an 8 bit or 16 bit sub_addr, 0 is 8bit, 1 is 16 bit
        .i_byte_len( {24'd0, DATAO[31:24]} ),        //denotes whether a single or sequential read or write will be performed (denotes number of bytes to read or write)
        .i_data_write( DATAO[7:0] ),           //Data to write if performing write action              
        .req_trans(WR&&DADDR[31]&&DADDR[4:0]==5'b11000),

        /** For Reads **/
        .data_out(data_out),
        .valid_out(valid_out),
   
         /** I2C Lines **/
        .scl_o(I2C_SCL),
        .sda_o(I2C_SDA),
        
        /** Comms to Master Module **/
        .req_data_chunk(req_data_chunk),//Request master to send new data chunk in i_data_write
        .busy(busy),                    //denotes whether module is currently communicating with a slave
        .nack(nack)
    );
endmodule
