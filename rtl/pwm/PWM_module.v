`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Irene Mateos Domínguez
//////////////////////////////////////////////////////////////////////////////////

module PWM_module(
    input  wire clk,
    input  wire [7:0] pwm_duty,
    input  wire rst,
    output wire pwm_pin1,
    output wire pwm_pin2,
    output wire pwm_pin3,
    output wire pwm_pin4
    );
    
    reg [7:0] count = 0;
always @(posedge clk)
begin 
     if (!rst)begin
        count <= 0;
    end else begin
         if(count < 8'hFF)
            count <= count + 1;
         else
            count <= 0;
    end
end

assign pwm_pin1 = count < pwm_duty;
assign pwm_pin2 = ~(count < pwm_duty);

endmodule
