`timescale 1ns / 1ps

module display_driver(
    input  wire [3:0] value,       // valor del n�mero a representar en el display
    input  wire       enable,          // encendido del display
    input  wire       point,       // punto decimal
    output wire       AN,
    output wire [7:0] CAT        
);
    // Encendido del display    
    assign AN = !enable;
    
    //     a
    //    ---
    // f |   | b
    //    -g-
    // e |   | c
    //    ---
    //     d
    assign CAT[7] = !point;
     
    reg [6:0] seg;

    always @(*) begin
        case (value)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111; // all off
        endcase
    end

    assign CAT[6:0] = seg;
 
endmodule
