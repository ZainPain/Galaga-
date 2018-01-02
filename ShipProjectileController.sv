`include "galaga_lib.sv"
import galaga_lib::*;
module ShipProjectileController(input Reset, frame_clk,
                                input [15:0] keycode,
                                input [9:0] ShipX, ShipY,
                                input [9:0] DrawX, DrawY,
                                input [NP - 1:0] ProjColl,
                                //output [NP - 1:0] ProjEn,
                                output [NP - 1:0] ProjOn,
                                output [9:0] ProjDistX, ProjDistY
                                //output [9:0]ProjX_arr[NP - 1:0], ProjY_arr[NP - 1:0]
                                );

    logic [9:0] ProjDistX_sig [NP - 1:0], ProjDistY_sig [NP - 1:0];
    logic [NP - 1:0] ProjOn_sig;
    logic [NP - 1:0] ProjActvt_sig, ProjEn_sig;
    logic [9:0] ShipXGunOffset = 7;
    logic [9:0] ShipYGunOffset = 0;
    ShipProjectileFinder _spf(.*,
                        .ProjEn(ProjEn_sig),
                        .ProjActvt(ProjActvt_sig));
    ShipProjectile _sprojectiles [NP - 1:0] (.Reset,
                                        .frame_clk,
                                        .ProjEn(ProjEn_sig),
                                        .ProjDistX(ProjDistX_sig),
                                        .ProjDistY(ProjDistY_sig),
                                        .DrawX,
                                        .DrawY,
                                        .ProjOn(ProjOn_sig),
                                        .ProjActvt(ProjActvt_sig),
                                        .ProjColl,
                                        .ShipGunX(ShipX + ShipXGunOffset),
                                        .ShipGunY(ShipY + ShipYGunOffset)
                                        //.ProjX(ProjX_arr),
                                        //.ProjY(ProjY_arr)
                                        );
    always_comb
    begin
        ProjOn = ProjOn_sig;
        ProjDistX = 10'd0;
        ProjDistY = 10'd0;
        for(int i = 0; i < NP; i++)
        begin
            if(ProjOn_sig[i])
            begin
                ProjDistX = ProjDistX_sig[i];
                ProjDistY = ProjDistY_sig[i];
                break;
            end
        end
    end
endmodule
