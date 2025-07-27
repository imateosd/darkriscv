`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Irene Mateos Domínguez
// 
// Create Date: 18.10.2024 12:02:20
// Design Name: 
// Module Name: flag_register
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

module flag_register (
    input wire clk,         // Señal de reloj
    input wire rst_n,       // Señal de reset activa a nivel bajo
    input wire flag_in,     // Señal de flag a mantener
    input wire clear,       // Señal de limpieza del registro (activa a nivel alto)
    output reg flag_out     // Registro de salida que mantiene el estado del flag
);

    // El registro mantiene el valor del flag hasta ser limpiado por software
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            flag_out <= 1'b0;         // Resetea el registro cuando se activa el reset
        else if (clear)
            flag_out <= 1'b0;         // Limpieza del registro desde el software
        else if (flag_in)
            flag_out <= 1'b1;         // Mantenimiento del valor del flag
    end

endmodule
