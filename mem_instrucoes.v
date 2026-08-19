// Quartus Prime Verilog Template Style
// Single Port ROM with combinational read (Single-Cycle)

module mem_instrucoes
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=8)
(
    input [(ADDR_WIDTH-1):0] addr,
    output reg [(DATA_WIDTH-1):0] instrucao
);

    // Declare the ROM variable
    reg [DATA_WIDTH-1:0] rom [2**ADDR_WIDTH-1:0];

    // Initialize the ROM with $readmemb. Put the memory contents
    // in the file instrucoes_init.txt. Without this file,
    // this design will not compile.
    initial
    begin
        $readmemb("instrucoes_init.txt", rom);
    end

    // Read process (Combinational for Single-Cycle Datapath)
    always @ (*)
    begin
        instrucao = rom[addr];
    end

endmodule