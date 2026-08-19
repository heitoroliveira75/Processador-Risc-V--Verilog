
module byte_extensor (
    input  [31:0] data_in,
    input         byte_op,  
    output [31:0] data_out
);

    assign data_out = byte_op
                      ? {{24{data_in[7]}}, data_in[7:0]}  
                      : data_in;                           
endmodule
