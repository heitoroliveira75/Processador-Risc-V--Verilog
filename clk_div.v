module clk_div (
    input  CLOCK_50,
    input  reset,
    output reg clk_out
);
 
    reg [4:0] contador; 
 
    always @(posedge CLOCK_50) begin
        if (reset) begin
            contador <= 5'd0;
            clk_out  <= 1'b0;
        end else if (contador == 5'd24) begin
            contador <= 5'd0;
            clk_out  <= ~clk_out;
        end else begin
            contador <= contador + 5'd1;
        end
    end
 
endmodule
