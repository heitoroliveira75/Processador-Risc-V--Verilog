// ============================================================
// ULA — 13 operações + flags zero e negative
// ============================================================
module ula (
    input  [31:0] A, B,
    input  [3:0]  ula_ctrl,
    output reg [31:0] result,
    output zero,
    output negative
);
    always @(*) begin
        case (ula_ctrl)
            4'b0000: result = A + B;
            4'b0001: result = A - B;
            4'b0010: result = A * B;
            4'b0011: result = (B != 0) ? A / B : 32'd0;
            4'b0100: result = (B != 0) ? A % B : A;
            4'b0101: result = A ^ B;
            4'b0110: result = A | B;
            4'b0111: result = A & B;
            4'b1000: result = A << B[4:0];
            4'b1001: result = A >> B[4:0];
            4'b1010: result = $signed(A) >>> B[4:0];
            4'b1011: result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            4'b1100: result = (A < B) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end
    assign zero     = (result == 32'd0);
    assign negative = result[31];
endmodule
