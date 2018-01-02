`include "galaga_lib.sv"
import galaga_lib::*;

module ShipProjectileFinder(input Reset, frame_clk, 
                                input [15:0] keycode,
                                input [NP - 1:0] ProjEn,
                                output reg [NP - 1:0] ProjActvt);

    logic [NP - 1:0] i;
    logic allow_fire;
    always_ff @ (posedge frame_clk)
    begin
        if(Reset)
        begin
            ProjActvt <= {NP{1'b0}};
        end
        else
        begin
            if(keycode[7:0] == SPACE_KEY || keycode[15:8] == SPACE_KEY) // Space keycode
            begin
                // This is really hacky, but we need some sort of priority here.
                for(i = 0; i < NP; i++)
                begin
                    if(ProjEn[i] == 1'b0 && allow_fire == 1'b1)
                    begin
                        ProjActvt <= 1'b1 << i;
                        allow_fire <= 1'b0;
                        break;
                    end
                    else
                    begin
                        ProjActvt <= ProjActvt;
                    end
                end
            end
            else
            begin
                allow_fire <= 1'b1;
                ProjActvt <= {NP{1'b0}};
            end
        end
    end
endmodule

                /*
                if(ProjEn[0] == 1'b0)
                    ProjActvt <= 10'd1;
                else if(ProjEn[1] == 1'b0)
                    ProjActvt <= 10'd2;
                else if(ProjEn[2] == 1'b0)
                    ProjActvt <= 10'd4;
                else if(ProjEn[3] == 1'b0)
                    ProjActvt <= 10'd8;
                else if(ProjEn[4] == 1'b0)
                    ProjActvt <= 10'd16;
                else if(ProjEn[5] == 1'b0)
                    ProjActvt <= 10'd32;
                else if(ProjEn[6] == 1'b0)
                    ProjActvt <= 10'd64;
                else if(ProjEn[7] == 1'b0)
                    ProjActvt <= 10'd128;
                else if(ProjEn[8] == 1'b0)
                    ProjActvt <= 10'd256;
                else if(ProjEn[9] == 1'b0)
                    ProjActvt <= 10'd512;
                else
                    ProjActvt <= ProjActvt;*/
//                case(ProjEn)
//                    10'bXXXXXXXXX0:
//                    begin
//                        ProjActvt <= 10'd1;
//                    end
//                    10'bXXXXXXXX0X:
//                    begin
//                        ProjActvt <= 10'd2;
//                    end
//                    10'bXXXXXXX0XX:
//                    begin
//                        ProjActvt <= 10'd4;
//                    end
//                    10'bXXXXXX0XXX:
//                    begin
//                        ProjActvt <= 10'd8;
//                    end
//                    10'bXXXXX0XXXX:
//                    begin
//                        ProjActvt <= 10'd16;
//                    end
//                    10'bXXXX0XXXXX:
//                    begin
//                        ProjActvt <= 10'd32;
//                    end
//                    10'bXXX0XXXXXX:
//                    begin
//                        ProjActvt <= 10'd64;
//                    end
//                    10'bXX0XXXXXXX:
//                    begin
//                        ProjActvt <= 10'd128;
//                    end
//                    10'bX0XXXXXXXX:
//                    begin
//                        ProjActvt <= 10'd256;
//                    end
//                    10'b0XXXXXXXXX:
//                    begin
//                        ProjActvt <= 10'd512;
//                    end
//                    default:
//                        ProjActvt <= ProjActvt;
//                endcase
