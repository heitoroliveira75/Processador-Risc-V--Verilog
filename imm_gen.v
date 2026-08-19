
module imm_gen (
    input  [31:0] instrucao,
    input  [1:0]  imm_sel,
    input         force_zero,
    output reg [31:0] imm_out
);

    wire [11:0] imm_I, imm_S, imm_B;
    wire [21:0] imm_J;
    assign imm_I = {instrucao[31:26], instrucao[25:20]};
    assign imm_S = {instrucao[31:26], instrucao[10:5]};
    assign imm_B = {instrucao[31:26], instrucao[10:5]};
    assign imm_J = {instrucao[31:26], instrucao[25:20],
                    instrucao[19:14], instrucao[13:11], 1'b0};

    reg [31:0] imm_raw;

    always @(*) begin
        case (imm_sel)
            2'b00: imm_raw = {{20{imm_I[11]}}, imm_I};
            2'b01: imm_raw = {{20{imm_S[11]}}, imm_S};
            2'b10: imm_raw = {{20{imm_B[11]}}, imm_B};
            2'b11: imm_raw = {{11{imm_J[20]}}, imm_J};
            default: imm_raw = 32'd0;
        endcase
        // force_zero: modo indireto — endereço = rs1 + 0 = rs1
        imm_out = force_zero ? 32'd0 : imm_raw;
    end

endmodule
