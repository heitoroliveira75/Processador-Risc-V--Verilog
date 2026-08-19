module bcd_seg7 (
    input  [31:0] valor,
    output [6:0]  hex0,
    output [6:0]  hex1,
    output [6:0]  hex2,
    output [6:0]  hex3
);

    wire [3:0] unidades = valor % 10;
    wire [3:0] dezenas  = (valor / 10)   % 10;
    wire [3:0] centenas = (valor / 100)  % 10;
    wire [3:0] milhares = (valor / 1000) % 10;

    function [6:0] seg7;
        input [3:0] d;
        case (d)
            4'd0: seg7 = 7'b1000000;
            4'd1: seg7 = 7'b1111001;
            4'd2: seg7 = 7'b0100100;
            4'd3: seg7 = 7'b0110000;
            4'd4: seg7 = 7'b0011001;
            4'd5: seg7 = 7'b0010010;
            4'd6: seg7 = 7'b0000010;
            4'd7: seg7 = 7'b1111000;
            4'd8: seg7 = 7'b0000000;
            4'd9: seg7 = 7'b0010000;
            default: seg7 = 7'b1111111;
        endcase
    endfunction

    assign hex0 = seg7(unidades);
    assign hex1 = (valor >= 10)   ? seg7(dezenas)  : 7'h7F;
    assign hex2 = (valor >= 100)  ? seg7(centenas) : 7'h7F;
    assign hex3 = (valor >= 1000) ? seg7(milhares) : 7'h7F;

endmodule