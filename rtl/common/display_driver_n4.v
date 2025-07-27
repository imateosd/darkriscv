`timescale 1ns / 1ps

module display_driver_4x (
    input  wire [31:0] SSDISP_REG_FF,  // Registro de entrada con la información de los 4 displays
    input  wire CLK,                   // Reloj del sistema
    output wire [3:0] AN,             // Salidas para habilitar los displays (ánodos)
    output wire [7:0] CAT             // Salidas para controlar los segmentos (cátodos)
);

    // Extraer valores, encendido del punto decimal y habilitación del display para cada display
    wire [3:0] SSDISP_NUM1 = SSDISP_REG_FF[3:0];
    wire       SSDISP_PT1  = SSDISP_REG_FF[4];
    wire       SSDISP_EN1  = SSDISP_REG_FF[7];

    wire [3:0] SSDISP_NUM2 = SSDISP_REG_FF[11:8];
    wire       SSDISP_PT2  = SSDISP_REG_FF[12];
    wire       SSDISP_EN2  = SSDISP_REG_FF[15];

    wire [3:0] SSDISP_NUM3 = SSDISP_REG_FF[19:16];
    wire       SSDISP_PT3  = SSDISP_REG_FF[20];
    wire       SSDISP_EN3  = SSDISP_REG_FF[23];

    wire [3:0] SSDISP_NUM4 = SSDISP_REG_FF[27:24];
    wire       SSDISP_PT4  = SSDISP_REG_FF[28];
    wire       SSDISP_EN4  = SSDISP_REG_FF[31];

    // Salidas de los controladores de cada display
    wire AN1, AN2, AN3, AN4;
    wire [7:0] CAT1, CAT2, CAT3, CAT4;

    // Instanciación de los controladores de display
    display_driver driver1(
        .value(SSDISP_NUM1),   // Valor del número a mostrar
        .enable(SSDISP_EN1),   // Habilitación del display
        .point(SSDISP_PT1),    // Punto decimal
        .AN(AN1),
        .CAT(CAT1)
    );

    display_driver driver2(
        .value(SSDISP_NUM2),
        .enable(SSDISP_EN2),
        .point(SSDISP_PT2),
        .AN(AN2),
        .CAT(CAT2)
    );

    display_driver driver3(
        .value(SSDISP_NUM3),
        .enable(SSDISP_EN3),
        .point(SSDISP_PT3),
        .AN(AN3),
        .CAT(CAT3)
    );

    display_driver driver4(
        .value(SSDISP_NUM4),
        .enable(SSDISP_EN4),
        .point(SSDISP_PT4),
        .AN(AN4),
        .CAT(CAT4)
    );

    // Lógica para el refresco del display (multiplexado)
    parameter REFRESH_RATE =  `BOARD_CK / 1000;     // Tasa de refresco para cambiar de dígito (~1ms)

    reg [1:0] mux_sel = 0;            // Selector de display actual
    reg [31:0] refresh_counter = 0;   // Contador de ciclos para refresco
    reg [3:0] AN_mux;                 // Señal de salida de AN multiplexada
    reg [7:0] CAT_mux;                // Señal de salida de CAT multiplexada

    // Contador de refresco basado en el reloj
    always @(posedge CLK) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == REFRESH_RATE) begin
            refresh_counter <= 0;
            mux_sel <= mux_sel + 1;  // Cambiar al siguiente display
        end
    end

    // Selección de señales a mostrar dependiendo del display activo
    always @(*) begin
        AN_mux = 4'b1111;  // Todos apagados inicialmente (activo bajo)
        case (mux_sel)
            2'd0: begin AN_mux[0] = AN1; CAT_mux = CAT1; end  // Display 1
            2'd1: begin AN_mux[1] = AN2; CAT_mux = CAT2; end  // Display 2
            2'd2: begin AN_mux[2] = AN3; CAT_mux = CAT3; end  // Display 3
            2'd3: begin AN_mux[3] = AN4; CAT_mux = CAT4; end  // Display 4
        endcase
    end

    // Asignación final de salidas
    assign AN = AN_mux;
    assign CAT = CAT_mux;

endmodule

