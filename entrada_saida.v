
module entrada_saida (
    input         clk,
    input         reset,

    input  [7:0]  addr,
    input  [31:0] write_data,
    input         mem_write,
    input         mem_read,
    output reg [31:0] read_data,

    input      [17:0] switches,
    input      [3:0]  buttons,
    output reg [6:0]  hex0,
    output reg [6:0]  hex1,
    output reg [6:0]  hex2,
    output reg [6:0]  hex3,
    input      [3:0]  n_capturado
);

    localparam ADDR_SW    = 8'hF1;
    localparam ADDR_BTN   = 8'hF2;
    localparam ADDR_HEX0  = 8'hF3;
    localparam ADDR_HEX1  = 8'hF4;
    localparam ADDR_HEX2  = 8'hF5;
    localparam ADDR_HEX3  = 8'hF6;
    localparam ADDR_N_CAP = 8'hF7;

    always @(posedge clk) begin
        if (reset) begin
            hex0 <= 7'h7F;
            hex1 <= 7'h7F;
            hex2 <= 7'h7F;
            hex3 <= 7'h7F;
        end else if (mem_write) begin
            case (addr)
                ADDR_HEX0: hex0 <= write_data[6:0];
                ADDR_HEX1: hex1 <= write_data[6:0];
                ADDR_HEX2: hex2 <= write_data[6:0];
                ADDR_HEX3: hex3 <= write_data[6:0];
                default: ;
            endcase
        end
    end

    always @(*) begin
        read_data = 32'd0;
        if (mem_read) begin
            case (addr)
                ADDR_SW:    read_data = {14'd0, switches};
                ADDR_BTN:   read_data = {28'd0, buttons};
                ADDR_N_CAP: read_data = {28'd0, n_capturado};
                default:    read_data = 32'd0;
            endcase
        end
    end

endmodule