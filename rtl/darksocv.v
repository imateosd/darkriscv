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
`include "config.vh"

module darksocv(
    input wire       XCLK,      // external clock
    input wire       XRES,      // external reset
    input wire       XBOOTSEL,  // bootsel button

    input wire       UART_RXD,  // UART receive line
    output wire      UART_TXD,  // UART transmit line

    output wire[7:0] CAT,
    output wire[3:0] AN,

    output wire[11:0]LED,       // on-board leds
    output wire[3:0] DEBUG,      // osciloscope (in the case of the basys3, connected to LEDs)
    inout  wire[15:0]GPIO,       // gpio
    
    input wire[15:0] XSW,        // switches
    input wire[2:0]  XBTN,       // buttons
    
    inout wire       I2C_SDA,    // I2C SDA
    inout wire       I2C_SCL,    // I2C SCL
    
    output wire      SPI_CLK,     // SPI CLK 
    input wire       SPI_MISO,    // SPI MISO
    output wire      SPI_MOSI,    // SPI MOSI
    output wire      SPI_CS1,     // SPI CS1
    output wire      SPI_CS2,     // SPI CS2
    output wire      SPI_CS3      // SPI CS3
);

    wire CLK,RES;
        
    darkpll darkpll0(.XCLK(XCLK),.XRES(XRES),.CLK(CLK),.RES(RES));

    // synchronise XBOOTSEL
    wire BOOTSEL;
    synchronizer bootsel_synchronizer (.in(XBOOTSEL), .CLK(CLK), .out(BOOTSEL) );
    
    // debounce XBOOTSEL?
    
    // Synchronize switches
    genvar j;
    wire [15:0] SW;
    generate
    for (j = 0; j < 16; j = j + 1) begin : sw_sync
        synchronizer u_sync_sw (
            .in(XSW[j]),
            .CLK(CLK),
            .out(SW[j])
        );
    end
    endgenerate

    // Synchronize buttons
    wire [2:0] BTN;
    generate
    for (j = 0; j < 3; j = j + 1) begin : btn_sync
        synchronizer u_sync_btn (
            .in(XBTN[j]),
            .CLK(CLK),
            .out(BTN[j])
        );
    end
    endgenerate

    // ro/rw memories
`ifdef __HARVARD__

    reg [31:0] ROM [0:2**`MLEN/4-1]; // ro memory
    reg [31:0] RAM [0:2**`MLEN/4-1]; // rw memory

    // memory initialization

    integer i;
    initial
    begin
        for(i=0;i!=2**`MLEN/4;i=i+1)
        begin
            ROM[i] = 32'd0;
            RAM[i] = 32'd0;
        end

        // workaround for vivado: no path in simulation and .mem extension

    `ifdef XILINX_SIMULATOR
        $readmemh("darksocv.rom.mem",ROM);
        $readmemh("darksocv.ram.mem",RAM);
    `else
        $readmemh("../src/darksocv.rom.mem",ROM);
        $readmemh("../src/darksocv.ram.mem",RAM); 
    `endif
    end

`else


    reg [31:0] MEM [0:2**`MLEN/4-1]; // ro memory

    // memory initialization

    integer i;
    initial
    begin
`ifdef SIMULATION

        for(i=0;i!=2**`MLEN/4;i=i+1)
        begin
            MEM[i] = 32'd0;
        end
`endif

        // workaround for vivado: no path in simulation and .mem extension

    `ifdef XILINX_SIMULATOR
        $readmemh("darksocv.mem",MEM);
	 `elsif MODEL_TECH
		  $readmemh("../src/darksocv.mem",MEM);
    `else
        $readmemh("../src/darksocv.mem",MEM,0);
    `endif
    end

`endif

    // darkriscv bus interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;
    wire [31:0] IDATA;
    wire [31:0] DATAO;
    wire [31:0] DATAI;
    wire        WR,RD;
    wire [3:0]  BE;

`ifdef __FLEXBUZZ__
    wire [31:0] XATAO;
    wire [31:0] XATAI;
    wire [ 2:0] DLEN;
    wire        RW;
`endif

    wire [31:0] IOMUX [0:11];

    reg  [15:0] GPIO_OUT_FF = 0;
    reg  [15:0] GPIO_IN_FF;
    reg  [15:0] GPIO_CTRL_FF = 0; // 0 input, 1 output
    reg  [15:0] GPIO_DATA_FF = 0;
    reg  [15:0] GPIO_FNCTN_FF = 0; // Control uso normal = 0, PWM = 1 
    reg  [32:0] PWM_CTRL_FF = 0; // [31:24] pwm4 duty cycle, [23:16] pwm3 duty cycle, [15:8] pwm2 duty cycle, [7:0] pwm1 duty cycle
    reg  [15:0] SW_DATA_FF  = 0;
    reg  [15:0] BTN_DATA_FF = 0;
    
    reg  [15:0] LEDFF  = 0;


    // For I2C Master
    reg  [23:0] i_byte_len;
    reg  [7:0]  slave_addr;
    reg  [15:0] i_sub_addr;
    reg  [7:0]  i_data_write;

    wire HLT;

    // instruction bus

    reg [31:0] ROMFF;

    wire IHIT = !ITACK;

    reg [1:0] ITACK = 0;

    reg [31:0] ROMFF2 = 0;
    reg        HLT2   = 0;

    always@(posedge CLK) // stage #0.5
    begin
        ITACK <= RES ? 0 : ITACK ? ITACK-1 : 0;
        if(HLT^HLT2)
        begin
            ROMFF2 <= ROMFF;
        end

        HLT2 <= HLT;
    end

    assign IDATA = HLT2 ? ROMFF2 : ROMFF;

    always@(posedge CLK) // stage #0.5
    begin
`ifdef __HARVARD__
        ROMFF <= ROM[IADDR[`MLEN-1:2]];
`else
        ROMFF <= MEM[IADDR[`MLEN-1:2]];
`endif
    end

    // data bus

`ifdef __FLEXBUZZ__

    // must work just exactly as the default interface, since we have no
    // flexbuzz devices available yet (i.e., all devices are 32-bit now)

    assign XATAI = DLEN[0] ? ( DADDR[1:0]==3 ? DATAI[31:24] :
                               DADDR[1:0]==2 ? DATAI[23:16] :
                               DADDR[1:0]==1 ? DATAI[15: 8] :
                                               DATAI[ 7: 0] ):
                   DLEN[1] ? ( DADDR[1]==1   ? DATAI[31:16] :
                                               DATAI[15: 0] ):
                                               DATAI;

    assign DATAO = DLEN[0] ? ( DADDR[1:0]==3 ? {        XATAO[ 7: 0], 24'hx } :
                               DADDR[1:0]==2 ? {  8'hx, XATAO[ 7: 0], 16'hx } :
                               DADDR[1:0]==1 ? { 16'hx, XATAO[ 7: 0],  8'hx } :
                                               { 24'hx, XATAO[ 7: 0]        } ):
                   DLEN[1] ? ( DADDR[1]==1   ? { XATAO[15: 0], 16'hx } :
                                               { 16'hx, XATAO[15: 0] } ):
                                                 XATAO;

    assign RD = DLEN&&RW==1;
    assign WR = DLEN&&RW==0;

    assign BE =    DLEN[0] ? ( DADDR[1:0]==3 ? 4'b1000 : // 8-bit
                               DADDR[1:0]==2 ? 4'b0100 :
                               DADDR[1:0]==1 ? 4'b0010 :
                                               4'b0001 ) :
                   DLEN[1] ? ( DADDR[1]==1   ? 4'b1100 : // 16-bit
                                               4'b0011 ) :
                                               4'b1111;  // 32-bit

`endif

    reg [31:0] RAMFF;

    // for single phase clock: 1 wait state in read op always required!

    reg [1:0] DTACK = 0;

    wire WHIT = 1;
    wire DHIT = !((RD
            `ifdef __RMW_CYCLE__
                    ||WR		// worst code ever! but it is 3:12am...
            `endif
                    ) && DTACK!=1); // the WR operatio does not need ws. in this config.

    always@(posedge CLK) // stage #1.0
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : (RD
            `ifdef __RMW_CYCLE__
                    ||WR		// 2nd worst code ever!
            `endif
                    ) ? 1 : 0; // wait-states
    end

    always@(posedge CLK) // stage #1.5
    begin
`ifdef __HARVARD__
        RAMFF <= RAM[DADDR[`MLEN-1:2]];
`else
        RAMFF <= MEM[DADDR[`MLEN-1:2]];
`endif
    end

    //assign DATAI = DADDR[31] ? IOMUX  : RAM[DADDR[`MLEN-1:2]];

    reg [31:0] IOMUXFF = 0;
    reg [31:0] XADDR   = 0;

    //individual byte/word/long selection, thanks to HYF!

    always@(posedge CLK)
    begin

`ifdef __RMW_CYCLE__

        // read-modify-write operation w/ 1 wait-state:

        if(!HLT&&WR&&DADDR[31]==0/*&&DADDR[`MLEN-1]==1*/)
        begin
    `ifdef __HARVARD__
            RAM[DADDR[`MLEN-1:2]] <=
    `else
            MEM[DADDR[`MLEN-1:2]] <=
    `endif
                                {
                                    BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
                                    BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
                                    BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
                                    BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
                                };
        end

`else
        // write-only operation w/ 0 wait-states:
    `ifdef __HARVARD__
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[3]) RAM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[2]) RAM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[1]) RAM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[0]) RAM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
    `else
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[3]) MEM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[2]) MEM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[1]) MEM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[0]) MEM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
    `endif
`endif

        XADDR <= DADDR; // 1 clock delayed
        IOMUXFF <= IOMUX[DADDR[4:2]==3'b100 ? 3'b100 : DADDR[3:2]]; // read w/ 2 wait-states
    end

    //assign DATAI = DADDR[31] ? IOMUX[DADDR[3:2]]  : RAMFF;
    //assign DATAI = DADDR[31] ? IOMUXFF : RAMFF;
//    assign DATAI = XADDR[31] ? IOMUX[ XADDR[4] == 1 ? XADDR[4:2] == 3'b111 ? 3'b101 : XADDR[4:2] : XADDR[3:2]] : RAMFF;
//    assign DATAI = XADDR[31] ? IOMUX[ XADDR[4] == 1 ? XADDR[4:2] : XADDR[3:2]] : RAMFF;
    assign DATAI = XADDR[31] ? IOMUX[ XADDR[5:2] ] : RAMFF;


    // io for debug
   
    reg [7:0] IREQ = 0;
    reg [7:0] IACK = 0;

    reg [31:0] TIMERFF = 0;
    reg [31:0] TIMEUS = 0;

    wire [7:0] BOARD_IRQ;

    wire   [7:0] BOARD_ID = `BOARD_ID;              // board id
    wire   [7:0] BOARD_CM = (`BOARD_CK/2000000);    // board clock (MHz)

`ifdef __THREADS__
    wire [`__THREADS__-1:0] TPTR;
    wire   [7:0] CORE_ID = TPTR;                    // core id
`else
    wire   [7:0] CORE_ID = 0;                       // core id
`endif

    //For I2C Master
    wire [7:0]  i2c_rdata;
    wire        i2c_valid_out;
    wire        i2c_valid_out_latched;
    wire        i2c_req_data_chunk;
    wire        i2c_req_data_latched;
    wire        i2c_busy;
    wire        i2c_nack;
    wire [7:0]  i2c_wdata;
    wire [15:0] i2c_subaddress;
    wire [7:0]  i2c_slave_address;
    `ifdef DEBUG
    wire [3:0]  i2c_master_state;
    wire [3:0]  i2c_master_next_state;
    wire        i2c_reg_sda_o;
    wire [7:0]  i2c_address;
    wire        i2c_rw;
    wire [15:0] i2c_sub_addr;
    wire        i2c_sub_len;
    wire [23:0] i2c_byte_len;
    wire        i2c_en_scl;
    wire        i2c_byte_sent;
    wire [23:0] i2c_num_byte_sent;
    wire [2:0]  i2c_cntr;
    wire [7:0]  i2c_byte_sr;
    wire        i2c_read_sub_addr_sent_flag;
    wire [7:0]  i2c_data_to_write;
    wire [7:0]  i2c_data_in_sr;
 
    //400KHz clock generation
    wire i2c_clk_i2c;
    wire [15:0] i2c_clk_i2c_cntr;
    
    //sampling sda and scl
    wire        i2c_sda_prev;
    wire [1:0]  i2c_sda_curr;
    wire        i2c_scl_prev;
    wire        i2c_scl_curr;
    wire        i2c_ack_in_prog;
    wire        i2c_ack_nack;
    wire        i2c_en_end_indicator;
    wire        i2c_grab_next_data;
    wire        i2c_scl_is_high;
    wire        i2c_scl_is_low;
    `endif
    
    
    // For SPI Master
    wire        spi_tx_ready;
    wire        spi_tx_ready_latched;
    wire        spi_rx_data_ready;
    wire        spi_rx_data_ready_latched;
    wire [7:0]  spi_rx_byte;
    wire [1:0]  spi_rx_count; // [$clog2(MAX_BYTES_PER_CS+1)-1:0] en este caso con lo que hay escrito en la instanciación [1:0]
    wire        spi_cs;

    // For PWM modules
    wire [15:0] PWM_OUT;
    wire        PWM1_OUT1, PWM1_OUT2;
    wire        PWM2_OUT1, PWM2_OUT2;
    wire        PWM3_OUT1, PWM3_OUT2;
    wire        PWM4_OUT1, PWM4_OUT2;

    // For 7seg display driver;
    wire [3:0]  SSDISP_NUM1;
    wire        SSDISP_EN1;
    wire        SSDISP_PT1;
    wire [3:0]  SSDISP_NUM2;
    wire        SSDISP_EN2;
    wire        SSDISP_PT2;
    wire [3:0]  SSDISP_NUM3;
    wire        SSDISP_EN3;
    wire        SSDISP_PT3;
    wire [3:0]  SSDISP_NUM4;
    wire        SSDISP_EN4;
    wire        SSDISP_PT4;
    
    wire [7:0]  CAT1;
    wire [7:0]  CAT2;
    wire [7:0]  CAT3;
    wire [7:0]  CAT4;
    
    reg  [31:0] SSDISP_REG_FF;

    assign IOMUX[0] = { BOARD_IRQ, CORE_ID, BOARD_CM, BOARD_ID };
    //assign IOMUX[1] = from UART!
    assign IOMUX[2] = {GPIO_DATA_FF, LEDFF };
    assign IOMUX[3] = TIMERFF;
    assign IOMUX[4] = TIMEUS;
    assign IOMUX[5] = {8'd0, spi_tx_ready_latched, spi_rx_byte, spi_rx_data_ready_latched, spi_rx_count, 12'd0}; // SPI
    assign IOMUX[6] = {i2c_slave_address, i2c_subaddress, i2c_rdata}; // I2C data
    `ifdef DEBUG
    assign IOMUX[7] = {3'd0, i2c_cntr, i2c_grab_next_data ,i2c_data_in_sr, i2c_master_next_state, i2c_master_state, i2c_busy, i2c_req_data_latched, i2c_nack, i2c_valid_out_latched, 5'd0}; // I2C ctrl
    `else
    assign IOMUX[7] = {23'd0, i2c_busy, i2c_req_data_latched, i2c_nack, i2c_valid_out_latched, 5'd0}; // I2C ctrl
    `endif
    assign IOMUX[8] = { 16'd0, GPIO_CTRL_FF }; // GPIO
    assign IOMUX[9] = { 32'd0 }; // MUX_CNTRL reg
    assign IOMUX[10] = { BTN_DATA_FF, SW_DATA_FF }; // BTN and SWITCHES states
    assign IOMUX[11] = { SSDISP_REG_FF }; // BTN and SWITCHES states

    reg [31:0] TIMER = 0;

    reg XTIMER = 0;

    always@(posedge CLK)
    begin
        if(RES) begin
            TIMERFF <= (`BOARD_CK/1000000)-1; // timer set to 1MHz by default
            IREQ <= 0;
            IACK <= 0;
            LEDFF <= 16'h00;
            GPIO_CTRL_FF <= 16'hff; // Default to all outputs
            GPIO_OUT_FF <= 16'h00;
            GPIO_IN_FF <= 16'h00;
            SSDISP_REG_FF <= 16'h00;
            PWM_CTRL_FF <= 16'h00;
        end else
        begin
            // Write operations
            if (WR)
            begin
                case (DADDR)
                    32'h8000_0003: begin
                            //$display("clear io.irq = %x (ireq=%x, iack=%x)",DATAO[32:24],IREQ,IACK);

                            IACK[7] <= DATAO[7+24] ? IREQ[7] : IACK[7];
                            IACK[6] <= DATAO[6+24] ? IREQ[6] : IACK[6];
                            IACK[5] <= DATAO[5+24] ? IREQ[5] : IACK[5];
                            IACK[4] <= DATAO[4+24] ? IREQ[4] : IACK[4];
                            IACK[3] <= DATAO[3+24] ? IREQ[3] : IACK[3];
                            IACK[2] <= DATAO[2+24] ? IREQ[2] : IACK[2];
                            IACK[1] <= DATAO[1+24] ? IREQ[1] : IACK[1];
                            IACK[0] <= DATAO[0+24] ? IREQ[0] : IACK[0];
                        end 
                    32'h8000_0008: LEDFF <= DATAO[15:0];    // Write to LEDFF (outputs)
                    32'h8000_000a: GPIO_OUT_FF <= DATAO[31:16]; // Write to GPIO_OUT_FF outputs    
                    32'h8000_000c: TIMERFF <= DATAO[31:0];
                    32'h8000_0020: GPIO_CTRL_FF <= DATAO[15:0]; // Set GPIO direction
                    32'h8000_0022: GPIO_FNCTN_FF <= DATAO[31:16]; // Set GPIO functionality
                    32'h8000_0024: PWM_CTRL_FF <= DATAO[31:0];    // Set PWM duty cycle
                    32'h8000_002C: SSDISP_REG_FF <= DATAO[31:0];  // Set 7 seg display configuration
                endcase
            end

     
            if(TIMERFF)
            begin
                TIMER <= TIMER ? TIMER-1 : TIMERFF;
    
                if(TIMER==0 && IREQ==IACK)
                begin
                    IREQ[7] <= !IACK[7];
    
                    //$display("timr0 set");
                end
    
                XTIMER  <= XTIMER+(TIMER==0);
                TIMEUS <= (TIMER == TIMERFF) ? TIMEUS + 1'b1 : TIMEUS;
            end
            
            // Capture input values only for pins configured as inputs
            GPIO_IN_FF <= GPIO & ~GPIO_CTRL_FF;
            // Actualizar el FF de estado de los GPIO (recoje el estado de entrada y de salida de los pines)                         
            GPIO_DATA_FF <= (GPIO_OUT_FF & GPIO_CTRL_FF) | (GPIO_IN_FF & ~GPIO_CTRL_FF);
            BTN_DATA_FF <= { 12'd0, BTN, BOOTSEL} ;
            SW_DATA_FF <= SW;

       end
    end

    assign BOARD_IRQ = IREQ^IACK;

    assign HLT = !IHIT||!DHIT||!WHIT;

    // darkuart

    wire [3:0] UDEBUG;

    wire FINISH_REQ;

    darkuart
//    #(
//      .BAUD((`BOARD_CK/115200))
//    )
    uart0
    (
      .CLK(CLK),
      .RES(RES),
      .RD(!HLT&&RD&&DADDR[31]&&DADDR[4:2]==1),
      .WR(!HLT&&WR&&DADDR[31]&&DADDR[4:2]==1),
      .BE(BE),
      .DATAI(DATAO),
      .DATAO(IOMUX[1]),
      //.IRQ(UART_IRQ),

`ifndef TESTMODE
      .RXD(UART_RXD),
      .TXD(UART_TXD),
`endif		
		`ifdef SIMULATION
      .FINISH_REQ(FINISH_REQ),
`endif
      .DEBUG(UDEBUG)
    );
    
    
    ConfigurableRegister #(
        .WIDTH(8)
    ) i2c_wdata_register (
        .clk(CLK),
        .rst(RES),
        .en(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b11000),
        .data_in(DATAO[7:0]),
        .data_out(i2c_wdata)
    );

    ConfigurableRegister #(
        .WIDTH(16)
    ) i2c_subaddress_register (
        .clk(CLK),
        .rst(RES),
        .en(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b11000),
        .data_in(DATAO[23:8]),
        .data_out(i2c_subaddress)
    );
    
    ConfigurableRegister #(
        .WIDTH(16)
    ) i2c_slave_address_register (
        .clk(CLK),
        .rst(RES),
        .en(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b11000),
        .data_in(DATAO[31:24]),
        .data_out(i2c_slave_address)
    );
    
        
    i2c_master
    i2c_master0
    (
        .i_clk(CLK),
        .reset_n(!RES),
        .i_addr_w_rw( i2c_slave_address ),       //7 bit address, LSB is the read write bit, with 0 being write, 1 being read
        .i_sub_addr( i2c_subaddress ),           //contains sub addr to send to slave, partition is decided on bit_sel
        .i_sub_len( DATAO[4] ),                  //denotes whether working with an 8 bit or 16 bit sub_addr, 0 no use of subaddress, 1 is 8bit subaddress, and 2 is 16 bit
        .i_byte_len( {21'd0, DATAO[3:1]} ),      //denotes whether a single or sequential read or write will be performed (denotes number of bytes to read or write)
        .i_data_write( i2c_wdata ),              //Data to write if performing write action              
        .req_trans(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b11100 && DATAO[0]), // When the 'start' bit of the i2c register is written, the transaction is requested to start

        /** For Reads **/
        .data_out(i2c_rdata ),
        .valid_out(i2c_valid_out),
   
         /** I2C Lines **/
        .scl_o(I2C_SCL),
        .sda_o(I2C_SDA),
        
        /** Comms to Master Module **/
        .req_data_chunk(i2c_req_data_chunk), //Request master to send new data chunk in i_data_write
        .busy(i2c_busy),                     //denotes whether module is currently communicating with a slave
        .nack(i2c_nack)
        
        // For debug 
       `ifdef DEBUG
       ,
        .state(i2c_master_state),
        .next_state(i2c_master_next_state),
        .reg_sda_o(i2c_reg_sda_o),
        .addr(i2c_address),
        .rw(i2c_rw),
        .sub_addr(i2c_sub_addr),
        .sub_len(i2c_sub_len),
        .byte_len(i2c_byte_len),
        .en_scl(i2c_en_scl),
        .byte_sent(i2c_byte_sent),
        .num_byte_sent(i2c_num_byte_sent),
        .cntr(i2c_cntr),
        .byte_sr(i2c_byte_sr),
        .read_sub_addr_sent_flag(i2c_read_sub_addr_sent_flag),
        .data_to_write(i2c_data_to_write),
        .data_in_sr(i2c_data_in_sr),
        //400KHz clock generation
         .clk_i2c(i2c_clk_i2c),
         .clk_i2c_cntr(i2c_clk_i2c_cntr),
                  
         //sampling sda and scl
        .sda_prev(i2c_sda_prev),
        .sda_curr(i2c_sda_curr),
        .scl_prev(i2c_scl_prev),
        .scl_curr(i2c_scl_curr),
        .ack_in_prog(i2c_ack_in_prog),
        .ack_nack(i2c_ack_nack),
        .en_end_indicator(i2c_en_end_indicator),
        .grab_next_data(i2c_grab_next_data),
        .scl_is_high(i2c_scl_is_high),
        .scl_is_low(i2c_scl_is_low)
        `endif
    );
    
    flag_register
    i2c_valid_out_flag_register
    (
        .clk(CLK),
        .rst_n(!RES),
        .flag_in(i2c_valid_out),
        .clear(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b11000 && DATAO[28]), // clear via writing 1 to the bit on software
        .flag_out(i2c_valid_out_latched)
    );
    
    flag_register
    i2c_req_data_flag_register
    (
        .clk(CLK),
        .rst_n(!RES),
        .flag_in(i2c_req_data_chunk),
        .clear(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b11000 && DATAO[30]), // clear via writing 1 to the bit on software
        .flag_out(i2c_req_data_latched)
    );
    
    
    // Instantiation of SPI_Master_With_Single_CS
    SPI_Master_With_Single_CS #(
        .SPI_MODE(0),               // SPI Mode: 0, 1, 2, or 3 // TODO make configurable
        .CLKS_PER_HALF_BIT(50),     // Number of clock cycles per half bit (baud rate control) -- Set SPI_CLL to 1MHz
                                    // CLKS_PER_HALF_BIT - Sets frequency of o_SPI_Clk.  o_SPI_Clk is
                                    // derived from i_Clk.  Set to integer number of clocks for each
                                    // half-bit of SPI data.  E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2
                                    // would create o_SPI_CLK of 25 MHz.  Must be >= 2
        .MAX_BYTES_PER_CS(2),        // Maximum number of bytes per CS low period ? This doesn't work?
        .CS_INACTIVE_CLKS(1)         // Number of clocks CS remains inactive between transfers
    ) 
    spi_master0(
        // Control/Data Signals
        .i_Rst_L(!RES),              // Active-low reset signal
        .i_Clk(CLK),                 // Clock signal
    
        // TX (MOSI) Signals
        .i_TX_Count(DATAO[10:8]),       // Number of bytes to transmit when CS is low
        .i_TX_Byte(DATAO[7:0]),         // Data byte to transmit over MOSI
        .i_TX_DV(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b10100 && DATAO[11]), // Data valid signal indicating a new byte is ready to be sent
        .o_TX_Ready(spi_tx_ready),       // Output signal indicating the module is ready for the next byte
    
        // RX (MISO) Signals
        .o_RX_Count(spi_rx_count),       // Output signal indicating how many bytes have been received
        .o_RX_DV(spi_rx_data_ready),     // Data valid pulse (1 clock cycle). Output signal indicating a valid byte is received
        .o_RX_Byte(spi_rx_byte),         // Received byte from MISO
    
        // SPI Interface
        .o_SPI_Clk(SPI_CLK),         // SPI clock output
        .i_SPI_MISO(SPI_MISO),       // SPI MISO input (Master In, Slave Out)
        .o_SPI_MOSI(SPI_MOSI),       // SPI MOSI output (Master Out, Slave In)
        .o_SPI_CS_n(spi_cs)          // Chip select output (active low)
    );
    
    // Para tener más de un chip select
    // DATAO[25:24] es slave_select
    reg [1:0] slave_select = 2'b00;
    always @(posedge CLK or negedge RES) begin
        if (RES)
            slave_select <= 2'b00;         // Resetear el register a 0
        else if( (!HLT && WR) && (DATAO[11] && (DADDR[31]&&DADDR[4:0]==5'b10100) ) )      // DADDR[4:0]==5'b10100 indica que el contenido de DATAO se refiere al módulo SPI.
            slave_select <= DATAO[25:24];  
    end

    assign SPI_CS1 = (spi_cs | ~(slave_select == 2'b01) );
    assign SPI_CS2 = (spi_cs | ~(slave_select == 2'b10) );
    assign SPI_CS3 = (spi_cs | ~(slave_select == 2'b11) );

    flag_register
    spi_tx_ready_flag_register
    (
        .clk(CLK),
        .rst_n(!RES),
        .flag_in(spi_tx_ready),
        .clear(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b10100 && DATAO[23]), // borrado escribiendo un 1 en software al bit correspondiente
        .flag_out(spi_tx_ready_latched)
    );
    
    flag_register
    spi_rx_data_ready_flag_register
    (
        .clk(CLK),
        .rst_n(!RES),
        .flag_in(spi_rx_data_ready),
        .clear(!HLT&&WR&&DADDR[31]&&DADDR[4:0]==5'b10100 && DATAO[14]), // borrado escribiendo un 1 en software al bit correspondiente
        .flag_out(spi_rx_data_ready_latched)
    );

    // PWM 
    PWM_module pwm1_module(
        .clk(CLK),
        .pwm_duty(PWM_CTRL_FF[7:0]),
        .rst(!RES),
        .pwm_pin1(PWM1_OUT1),
        .pwm_pin2(PWM1_OUT2)
    );
    
    PWM_module pwm2_module(
        .clk(CLK),
        .pwm_duty(PWM_CTRL_FF[15:8]),
        .rst(!RES),
        .pwm_pin1(PWM2_OUT1),
        .pwm_pin2(PWM2_OUT2)
    );
    
     PWM_module pwm3_module(
        .clk(CLK),
        .pwm_duty(PWM_CTRL_FF[23:16]),
        .rst(!RES),
        .pwm_pin1(PWM3_OUT1),
        .pwm_pin2(PWM3_OUT2)
    );
    
     PWM_module pwm4_module(
        .clk(CLK),
        .pwm_duty(PWM_CTRL_FF[31:24]),
        .rst(!RES),
        .pwm_pin1(PWM4_OUT1),
        .pwm_pin2(PWM4_OUT2)
    );

    // Connect PWM outputs to PWM buffer
    assign PWM_OUT[3:0] = {PWM1_OUT2, PWM1_OUT1, PWM1_OUT2, PWM1_OUT1};
    assign PWM_OUT[7:4] = {PWM2_OUT2, PWM2_OUT1, PWM2_OUT2, PWM2_OUT1};
    assign PWM_OUT[11:8] = {PWM3_OUT2, PWM3_OUT1, PWM3_OUT2, PWM3_OUT1};
    assign PWM_OUT[15:12] = {PWM4_OUT2, PWM4_OUT1, PWM4_OUT2, PWM4_OUT1};

    // Instanciación del controlador de displays
    display_driver_4x display_ctrl_inst(
        .SSDISP_REG_FF(SSDISP_REG_FF),  // Conecta el registro de entrada
        .CLK(CLK),                      // Conecta el reloj del sistema
        .AN(AN),                        // Salida: señales de ánodo
        .CAT(CAT)                       // Salida: señales de cátodo (segmentos)
    );

    // darkriscv
    wire [3:0] KDEBUG;

    wire IDLE;

    darkriscv
//    #(
//        .RESET_PC(32'h00000000),
//        .RESET_SP(32'h00002000)
//    )
    core0
    (
        .CLK(CLK),
        .RES(RES),
        .HLT(HLT),
`ifdef __THREADS__
        .TPTR(TPTR),
`endif
`ifdef __INTERRUPT__
        .INT(|BOARD_IRQ),
`endif
        .IDATA(IDATA),
        .IADDR(IADDR),
        .DADDR(DADDR),

`ifdef __FLEXBUZZ__
        .DATAI(XATAI),
        .DATAO(XATAO),
        .DLEN(DLEN),
        .RW(RW),
`else
        .DATAI(DATAI),
        .DATAO(DATAO),
        .BE(BE),
        .WR(WR),
        .RD(RD),
`endif

        .IDLE(IDLE),

        .DEBUG(KDEBUG)
    );

`ifdef TESTMODE
	 
    // tips to port darkriscv for a new target:
	 // 
	 // - 1st of all, test the blink code to confirms the reset
	 //   polarity, i.e. the LEDs must blink at startup when
	 //   the reset button *is not pressed*
	 // - 2nd check the blink rate: the 31-bit counter that starts
	 //   with BOARD_CK value and counts to zero, blinking w/
	 //   50% of this period

	 reg [31:0] BLINK = 0;
	 
	 always@(posedge CLK)
	 begin
        BLINK <= RES ? 0 : BLINK ? BLINK-1 : `BOARD_CK;
	 end
	 
	 assign LED[3:0] = (BLINK < (`BOARD_CK/2)) ? -1 : 0;
	 assign UART_TXD = UART_RXD;
`else
    assign LED   = LEDFF[11:0];
`endif
	 
    assign DEBUG = { XTIMER, KDEBUG[2:0] }; // UDEBUG;
    
    // GPIO Pin Control
//    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin : gpio_loop
            assign GPIO[j] = GPIO_CTRL_FF[j] ? (GPIO_FNCTN_FF[j] ? PWM_OUT[j] : GPIO_OUT_FF[j]): 1'bz; // Tristate logic for output
        end
    endgenerate
    

`ifdef SIMULATION

    `ifdef __PERFMETER__

        integer clocks=0, running=0, load=0, store=0, flush=0, halt=0;

    `ifdef __THREADS__
        integer thread[0:(2**`__THREADS__)-1],curtptr=0,cnttptr=0;
        integer j;

        initial for(j=0;j!=(2**`__THREADS__);j=j+1) thread[j] = 0;
    `endif

        always@(posedge CLK)
        begin
            if(!RES)
            begin
                clocks = clocks+1;

                if(HLT)
                begin
                         if(WR)	store = store+1;
                    else if(RD)	load  = load +1;
                    else 		halt  = halt +1;
                end
                else
                if(IDLE)
                begin
                    flush=flush+1;
                end
                else
                begin

        `ifdef __THREADS__
                    for(j=0;j!=(2**`__THREADS__);j=j+1)
                            thread[j] = thread[j]+(j==TPTR?1:0);

                    if(TPTR!=curtptr)
                    begin
                        curtptr = TPTR;
                        cnttptr = cnttptr+1;
                    end
        `endif
                    running = running +1;
                end

                if(FINISH_REQ)
                begin
                    $display("****************************************************************************");
                    $display("DarkRISCV Pipeline Report (%0d clocks):",clocks);

                    $display("core0: %0d%% run, %0d%% wait (%0d%% i-bus, %0d%% d-bus/rd, %0d%% d-bus/wr), %0d%% idle",
                        100.0*running/clocks,
                        100.0*(load+store+halt)/clocks,
                        100.0*halt/clocks,
                        100.0*load/clocks,
                        100.0*store/clocks,
                        100.0*flush/clocks);

         `ifdef __THREADS__
                    for(j=0;j!=(2**`__THREADS__);j=j+1) $display("  thread%0d: %0d%% running",j,100.0*thread[j]/clocks);

                    $display("%0d thread switches, %0d clocks/threads",cnttptr,clocks/cnttptr);
         `endif
                    $display("****************************************************************************");
                    $finish();
                end
            end
        end
    `else
        always@(posedge CLK) if(FINISH_REQ) $finish();
    `endif

`endif

endmodule
