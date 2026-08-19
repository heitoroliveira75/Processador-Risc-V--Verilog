
module jump_ctrl (
    input  zero,         
    input  negative,     
    input  branch,       
    input  branch_not,   
    input  branch_neg,   
    input  branch_ge,    
    input  jump,         
    output pc_sel        
);

    wire branch_taken;

    assign branch_taken = branch & (
        (~branch_not & ~branch_neg & ~branch_ge &  zero    ) | 
        ( branch_not                             & ~zero    ) | 
        ( branch_neg                             &  negative) |
        ( branch_ge                              & ~negative)   
    );


    assign pc_sel = jump | branch_taken;

endmodule
