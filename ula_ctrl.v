
module ula_ctrl (
    input  [1:0] ula_op,
    input  [5:0] funct6,
    input  [2:0] funct3,
    output reg [3:0] ctrl
);
    always @(*) begin
        case (ula_op)
            2'b00: ctrl = 4'b0000; // ADD
				2'b01: ctrl = 4'b0001; // SUB
            2'b11: ctrl = 4'b0001; // SUB
            2'b10: begin
                case ({funct6, funct3})
                    9'b000000_000: ctrl = 4'b0000; // ADD
                    9'b010000_000: ctrl = 4'b0001; // SUB
                    9'b000001_000: ctrl = 4'b0010; // MUL
                    9'b000100_100: ctrl = 4'b0011; // DIV
                    9'b000110_110: ctrl = 4'b0100; // REM
                    9'b000000_100: ctrl = 4'b0101; // XOR
                    9'b000000_110: ctrl = 4'b0110; // OR
                    9'b000000_111: ctrl = 4'b0111; // AND
                    9'b000000_001: ctrl = 4'b1000; // SLL
                    9'b000000_101: ctrl = 4'b1001; // SRL
                    9'b010000_101: ctrl = 4'b1010; // SRA
                    9'b000000_010: ctrl = 4'b1011; // SLT
                    9'b000000_011: ctrl = 4'b1100; // SLTU
                    default:       ctrl = 4'b0000;
                endcase
            end
            default: ctrl = 4'b0000;
        endcase
    end
endmodule
