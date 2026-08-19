// ============================================================
// Exec Unit — Banco de Registradores + MUX ALUSrc + ULA Cntrl + ULA
// PC e Jump Ctrl foram movidos para o top-level.
// ============================================================
module exec_unit (
    input         clk,
    input         reset,
    input  [5:0]  rs1,
    input  [5:0]  rs2,
    input  [5:0]  rd,
    input  [5:0]  funct6,
    input  [2:0]  funct3,
    input         reg_write,
    input         alu_src,
    input  [1:0]  ula_op,      // CORRIGIDO: era [3:0] ula_ctrl_sig
    input  [31:0] write_data,
    input  [31:0] imm_ext,
    output [31:0] ula_result,
    output [31:0] read_data2,
    output        zero,
    output        negative
);

    wire [31:0] reg_data1, reg_data2, ula_b;
    wire [3:0]  ula_ctrl_sig;

    // Banco de Registradores
    banco_registradores BR (
        .clk        (clk),
        .reset      (reset),   // ADICIONADO: reset agora conectado
        .reg_write  (reg_write),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .write_data (write_data),
        .read_data1 (reg_data1),
        .read_data2 (reg_data2)
    );

    // ULA Cntrl — decodifica ula_op + funct6 + funct3
    ula_ctrl ULACTRL (
        .ula_op (ula_op),
        .funct6 (funct6),
        .funct3 (funct3),
        .ctrl   (ula_ctrl_sig)
    );

    // MUX ALUSrc
    assign ula_b = alu_src ? imm_ext : reg_data2;

    // ULA
    ula ULA_inst (
        .A        (reg_data1),
        .B        (ula_b),
        .ula_ctrl (ula_ctrl_sig),
        .result   (ula_result),
        .zero     (zero),
        .negative (negative)
    );

    assign read_data2 = reg_data2;

endmodule
