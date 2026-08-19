module controle (
    input  [4:0] opcode,
    input  [2:0] funct3,
    input  [5:0] funct6,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg [1:0]  mem_to_reg,   
    output reg        alu_src,
    output reg [1:0]  imm_sel,
    output reg [1:0]  ula_op,
    output reg        branch,
    output reg        jump,
    output reg        byte_op,
    output reg        pc_src_jump,
    output reg        halt,
    output reg        ecall_flag,
    output reg        force_zero
);

    // mem_to_reg — MUX writeback 3 vias:
    //   2'b00 → ula_result    (Tipo R, Tipo I)
    //   2'b01 → byte_ext_data (Load)
    //   2'b10 → pc_plus1      (JAL — endereço de retorno)

    always @(*) begin
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 2'b00;    // CORRIGIDO: 2 bits
        alu_src     = 1'b0;
        imm_sel     = 2'b00;
        ula_op      = 2'b00;
        branch      = 1'b0;
        jump        = 1'b0;
        byte_op     = 1'b0;
        pc_src_jump = 1'b0;
        halt        = 1'b0;
        ecall_flag  = 1'b0;
        force_zero  = 1'b0;

        case (opcode)

            5'b00000: begin                         // Tipo R
                reg_write  = 1'b1;
                alu_src    = 1'b0;
                ula_op     = 2'b10;
                mem_to_reg = 2'b00;  // writeback da ULA
            end

            5'b00001: begin                         // Tipo I (ADDI, SUBI...)
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                imm_sel    = 2'b00;
                mem_to_reg = 2'b00;  // writeback da ULA
                ula_op     = (funct3 == 3'b000 && funct6 == 6'b010000)
                             ? 2'b11   // SUBI: força SUB
                             : 2'b00;  // ADDI: força ADD
            end

            5'b00010: begin                         // Load
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_src    = 1'b1;
                imm_sel    = 2'b00;
                ula_op     = 2'b00;
                mem_to_reg = 2'b01;  // writeback da memória
                byte_op    = ~funct3[1];
                force_zero = funct3[0];
            end

            5'b00011: begin                         // ECALL / EBREAK
                halt       = 1'b1;
                ecall_flag = (funct3 == 3'b000) ? 1'b1 : 1'b0;
            end

            5'b00100: begin                         // Store
                mem_write  = 1'b1;
                alu_src    = 1'b1;
                imm_sel    = 2'b01;
                ula_op     = 2'b00;
                byte_op    = ~funct3[1];
                force_zero = funct3[0];
               
            end

            5'b11000: begin                         // Branch
                alu_src = 1'b0;
                imm_sel = 2'b10;
                ula_op  = 2'b01;
                branch  = 1'b1;

            end

            5'b11011: begin                         // JAL
                reg_write   = 1'b1;
                jump        = 1'b1;
                imm_sel     = 2'b11;
                pc_src_jump = 1'b1;
                mem_to_reg  = 2'b10;  
            end

            default: begin /* NOP */ end
        endcase
    end

endmodule
