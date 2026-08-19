module banco_registradores (
    input         clk,
    input         reset,
    input         reg_write,
    input  [5:0]  rs1,
    input  [5:0]  rs2,
    input  [5:0]  rd,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

     reg [31:0] regs [63:0];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 64; i = i + 1)
                regs[i] <= 32'd0;
        end else if (reg_write && rd != 6'd0) begin
            regs[rd] <= write_data;
        end
    end

    assign read_data1 = (rs1 == 6'd0) ? 32'd0 : regs[rs1];
    assign read_data2 = (rs2 == 6'd0) ? 32'd0 : regs[rs2];

endmodule
