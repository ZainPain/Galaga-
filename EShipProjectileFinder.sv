`include "galaga_lib.sv"
import galaga_lib::*;

module EShipProjectileFinder(input Reset, frame_clk, 
                                input [9:0] ESchedCtr, 
                                input ESchedFire[NM - 1:0],
                                input [NPE - 1:0] EProjEn,
                                output reg [NPE - 1:0] EProjActvt);

    logic [NPE - 1:0] i;
    always_ff @ (posedge frame_clk)
    begin
        if(Reset)
        begin
            EProjActvt <= {NPE{1'b0}};
        end
        else
        begin
            if(ESchedFire[ESchedCtr] == 1'b1) // Schedule calls for shot fired.
            begin
                // This is really hacky, but we need some sort of priority here.
                for(i = 0; i < NPE; i++)
                begin
                    if(EProjEn[i] == 1'b0)
                    begin
                        EProjActvt <= 1'b1 << i;
                        break;
                    end
                    else
                    begin
                        EProjActvt <= EProjActvt;
                    end
                end
            end
            else
            begin
                EProjActvt <= {NPE{1'b0}};
            end
        end
    end
endmodule
