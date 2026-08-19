module mem_dados
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=8)
(
    input                       clk,
    input                       reset,
    input  [(DATA_WIDTH-1):0]   write_data,
    input  [(ADDR_WIDTH-1):0]   addr,
    input                       mem_read,
    input                       mem_write,
    input                       byte_op,
    output reg [(DATA_WIDTH-1):0] read_data
);

    
    reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
	 
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 2**ADDR_WIDTH; i = i + 1)
                ram[i] <= {(DATA_WIDTH){1'b0}};
        end else if (mem_write) begin
            if (byte_op)
                ram[addr][7:0] <= write_data[7:0];
            else
                ram[addr] <= write_data;
        end
    end

    
    always @(*) begin
        if (mem_read) begin
            if (byte_op)
                read_data = {24'd0, ram[addr][7:0]};
            else
                read_data = ram[addr];
        end else begin
            read_data = {(DATA_WIDTH){1'b0}};
        end
    end

endmodule
