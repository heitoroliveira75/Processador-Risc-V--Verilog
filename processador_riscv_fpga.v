module processador_riscv_fpga #(
    parameter IMEM_ADDR_WIDTH = 8,
    parameter DMEM_ADDR_WIDTH = 8
)(
    input  clk,
    input  reset,

    output halt,
    output ecall_flag,
    output [31:0] obs_pc,
    output        obs_pc_sel,
    output        obs_reg_write,
    output        obs_mem_write,
    output        obs_mem_read,
    output [31:0] obs_ula_result,
    output        obs_zero,
    output        obs_negative,
    output [31:0] obs_wb_data,
    output [31:0] obs_mem_rdata,

    input  [17:0] switches,
    input  [3:0]  buttons,
    output [6:0]  hex0,
    output [6:0]  hex1,
    output [6:0]  hex2,
    output [6:0]  hex3,
    input  [3:0]  n_capturado
);

    wire [31:0] pc_out, pc_plus1, pc_branch, pc_next;

    wire [31:0] instrucao;
    wire [4:0]  opcode = instrucao[4:0];
    wire [5:0]  rd_f   = instrucao[10:5];
    wire [2:0]  funct3 = instrucao[13:11];
    wire [5:0]  rs1_f  = instrucao[19:14];
    wire [5:0]  rs2_f  = instrucao[25:20];
    wire [5:0]  funct6 = instrucao[31:26];

    wire        reg_write, mem_read, mem_write;
    wire [1:0]  mem_to_reg;
    wire        alu_src;
    wire [1:0]  imm_sel, ula_op;
    wire        branch, jump, byte_op, force_zero;
    wire        pc_src_jump;

    wire branch_not = branch & (funct3 == 3'b001);
    wire branch_neg = branch & (funct3 == 3'b100);
    wire branch_ge  = branch & (funct3 == 3'b101);

    wire [31:0] imm_ext;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] ula_b;
    wire [3:0]  ula_ctrl_sig;
    wire [31:0] ula_result;
    wire        zero, negative;
    wire [31:0] ram_rdata, io_rdata, mem_read_data;
    wire [31:0] byte_ext_data, wb_data;
    wire        pc_sel;

    wire is_io  = (ula_result[DMEM_ADDR_WIDTH-1:0] >= 8'hF0);
    wire is_ram = ~is_io;

    pc PC_REG (
        .clk    (clk),
        .reset  (reset),
        .pc_next(pc_next),
        .pc_out (pc_out)
    );

    assign pc_plus1  = pc_out + 32'd1;
    assign pc_branch = pc_out + imm_ext;
    assign pc_next   = halt   ? pc_out    :
                       pc_sel ? pc_branch :
                                pc_plus1;

    mem_instrucoes #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(IMEM_ADDR_WIDTH)
    ) IMEM (
        .addr     (pc_out[IMEM_ADDR_WIDTH-1:0]),
        .instrucao(instrucao)
    );

    controle UC (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct6     (funct6),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .alu_src    (alu_src),
        .imm_sel    (imm_sel),
        .ula_op     (ula_op),
        .branch     (branch),
        .jump       (jump),
        .byte_op    (byte_op),
        .pc_src_jump(pc_src_jump),
        .force_zero (force_zero),
        .halt       (halt),
        .ecall_flag (ecall_flag)
    );

    imm_gen IMMGEN (
        .instrucao  (instrucao),
        .imm_sel    (imm_sel),
        .force_zero (force_zero),
        .imm_out    (imm_ext)
    );

    banco_registradores BR (
        .clk        (clk),
        .reset      (reset),
        .reg_write  (reg_write),
        .rs1        (rs1_f),
        .rs2        (rs2_f),
        .rd         (rd_f),
        .write_data (wb_data),
        .read_data1 (reg_data1),
        .read_data2 (reg_data2)
    );

    ula_ctrl ULACTRL (
        .ula_op (ula_op),
        .funct6 (funct6),
        .funct3 (funct3),
        .ctrl   (ula_ctrl_sig)
    );

    assign ula_b = alu_src ? imm_ext : reg_data2;

    ula ULA (
        .A        (reg_data1),
        .B        (ula_b),
        .ula_ctrl (ula_ctrl_sig),
        .result   (ula_result),
        .zero     (zero),
        .negative (negative)
    );

    jump_ctrl JMPCTRL (
        .zero       (zero),
        .negative   (negative),
        .branch     (branch),
        .branch_not (branch_not),
        .branch_neg (branch_neg),
        .branch_ge  (branch_ge),
        .jump       (jump),
        .pc_sel     (pc_sel)
    );

    mem_dados #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(DMEM_ADDR_WIDTH)
    ) DMEM (
        .clk        (clk),
        .reset      (reset),
        .addr       (ula_result[DMEM_ADDR_WIDTH-1:0]),
        .write_data (reg_data2),
        .mem_read   (mem_read  & is_ram),
        .mem_write  (mem_write & is_ram),
        .byte_op    (byte_op),
        .read_data  (ram_rdata)
    );

    entrada_saida ES (
        .clk         (clk),
        .reset       (reset),
        .addr        (ula_result[DMEM_ADDR_WIDTH-1:0]),
        .write_data  (reg_data2),
        .mem_read    (mem_read  & is_io),
        .mem_write   (mem_write & is_io),
        .read_data   (io_rdata),
        .switches    (switches),
        .buttons     (buttons),
        .hex0        (hex0),
        .hex1        (hex1),
        .hex2        (hex2),
        .hex3        (hex3),
        .n_capturado (n_capturado)
    );

    assign mem_read_data = is_io ? io_rdata : ram_rdata;

    byte_extensor BEXT (
        .data_in  (mem_read_data),
        .byte_op  (byte_op),
        .data_out (byte_ext_data)
    );

    assign wb_data = (mem_to_reg == 2'b10) ? pc_plus1      :
                     (mem_to_reg == 2'b01) ? byte_ext_data :
                                             ula_result;

    assign obs_pc         = pc_out;
    assign obs_pc_sel     = pc_sel;
    assign obs_reg_write  = reg_write;
    assign obs_mem_write  = mem_write;
    assign obs_mem_read   = mem_read;
    assign obs_ula_result = ula_result;
    assign obs_zero       = zero;
    assign obs_negative   = negative;
    assign obs_wb_data    = wb_data;
    assign obs_mem_rdata  = mem_read_data;

endmodule