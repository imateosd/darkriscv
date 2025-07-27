/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

`timescale 1ns / 1ps
`include "../rtl/config.vh"

// clock and reset logic

module darksimv;

    reg CLK = 0;
    
    reg RES = 1;
    
    
    // SPI signals from your master
    wire sck;        // SPI clock
    wire mosi;       // Master Out Slave In
    wire miso;       // Master In Slave Out
    wire cs1_n;       // Chip select (active-low)
    wire cs2_n;       // Chip select (active-low)
    wire cs3_n;       // Chip select (active-low)
    
    assign miso = mosi;

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
        #6000e3 RES = 0;            // run  6s
//        #1e3    RES = 0;            // wait 1us in reset state
        #1000e3 $finish();          // run  1s
    end

    wire TX;
    wire RX = 1;
    
    darksocv soc0
    (
        .XCLK(CLK),
        .XRES(|RES),
        .UART_RXD(RX),
        .UART_TXD(TX),
        // SPI signals
        .SPI_CLK   (sck),
        .SPI_MOSI  (mosi),
        .SPI_MISO  (miso),     // MISO input to master
        .SPI_CS1  (cs1_n),
        .SPI_CS2  (cs2_n),
        .SPI_CS3  (cs3_n)
//        .GPIO(GPIO), // Connect GPIO signal
//        .LED(LED)    // Connect LED signal
    );

endmodule
