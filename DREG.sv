module DREG(input Clk, Reset, LD, input [8:0] D_IN, output [8:0] D_OUT);
    always_ff @ (posedge Clk)
    begin
        if(Reset)
            D_OUT <= 9'd0;
        else if(LD)
            D_OUT <= D_IN;
        else
            D_OUT <= D_OUT;
    end
endmodule 