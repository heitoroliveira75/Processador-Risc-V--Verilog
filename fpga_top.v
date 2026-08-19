module fpga_top (
    input        CLOCK_50,
    input  [3:0] KEY,
    input  [3:0] SW,

    output [2:0] LEDG,

    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3
);

    wire        clk_lento;
    wire        reset;
    wire        clock_liberado;
    wire [3:0]  n_capturado;
    wire        halt;
    wire        ecall_flag;
    wire [31:0] obs_pc;
    wire        obs_pc_sel;
    wire        obs_reg_write;
    wire        obs_mem_write;
    wire        obs_mem_read;
    wire [31:0] obs_ula_result;
    wire        obs_zero;
    wire        obs_negative;
    wire [31:0] obs_wb_data;
    wire [31:0] obs_mem_rdata;
    wire [6:0]  hex0_nc, hex1_nc, hex2_nc, hex3_nc;

    assign reset = ~KEY[0];

    wire proc_reset = reset | ~clock_liberado;

    reg [31:0] resultado_travado;
    reg        resultado_valido;

    always @(posedge clk_lento or posedge reset) begin
        if (reset) begin
            resultado_travado <= 32'd0;
            resultado_valido  <= 1'b0;
        end else if (~clock_liberado) begin
            resultado_travado <= 32'd0;
            resultado_valido  <= 1'b0;
        end else if (!halt) begin
            if (obs_reg_write)
                resultado_travado <= obs_wb_data;
        end else begin
            resultado_valido <= 1'b1;
        end
    end

    wire [31:0] valor_display = resultado_valido ? resultado_travado : 32'd0;

    clk_div DIV (
        .CLOCK_50 (CLOCK_50),
        .reset    (reset),
        .clk_out  (clk_lento)
    );

    ctrl_execucao CTRL (
        .CLOCK_50      (CLOCK_50),
        .reset         (reset),
        .botao         (KEY[1]),
        .switches_n    (SW[3:0]),
        .n_capturado   (n_capturado),
        .clock_liberado(clock_liberado)
    );

    processador_riscv_fpga #(
        .IMEM_ADDR_WIDTH(8),
        .DMEM_ADDR_WIDTH(8)
    ) CPU (
        .clk           (clk_lento),
        .reset         (proc_reset),
        .halt          (halt),
        .ecall_flag    (ecall_flag),
        .obs_pc        (obs_pc),
        .obs_pc_sel    (obs_pc_sel),
        .obs_reg_write (obs_reg_write),
        .obs_mem_write (obs_mem_write),
        .obs_mem_read  (obs_mem_read),
        .obs_ula_result(obs_ula_result),
        .obs_zero      (obs_zero),
        .obs_negative  (obs_negative),
        .obs_wb_data   (obs_wb_data),
        .obs_mem_rdata (obs_mem_rdata),
        .switches      ({14'd0, SW[3:0]}),
        .buttons       ({1'b1, KEY[3:1]}),
        .hex0          (hex0_nc),
        .hex1          (hex1_nc),
        .hex2          (hex2_nc),
        .hex3          (hex3_nc),
        .n_capturado   (n_capturado)
    );

    bcd_seg7 BCD (
        .valor (valor_display),
        .hex0  (HEX0),
        .hex1  (HEX1),
        .hex2  (HEX2),
        .hex3  (HEX3)
    );

    assign LEDG[0] = clock_liberado;
    assign LEDG[1] = resultado_valido;
    assign LEDG[2] = ~proc_reset;

endmodule