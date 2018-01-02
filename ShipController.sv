`include "galaga_lib.sv"
import galaga_lib::*;

module ShipController(input frame_clk, Reset,
                    input [15:0] keycode,
                    input [9:0] DrawX, DrawY,
                    input ShipColl,
                    input [NP - 1:0] ProjColl,
                    output ShipOn,
                    output [NP - 1:0] ProjOn,
                    output [9:0] ShipDistX, ShipDistY,
                    output [9:0] ProjDistX, ProjDistY
                    );
                    //output [NP - 1:0] ProjEn,
                    //output [9:0]ProjX_arr[NP - 1:0], ProjY_arr[NP - 1:0]);

logic [9:0] ShipX_sig, ShipY_sig;

    ShipLocation _sl(
            .Reset,
            .frame_clk,
            .DrawX,
            .DrawY,
            .ShipOn,
            .ShipColl,
            .ShipDistX,
            .ShipDistY,
            .ShipX(ShipX_sig),
            .ShipY(ShipY_sig),
            .keycode);

    ShipProjectileController _spc (
            .Reset,
            .frame_clk,
            .keycode,
            .DrawX,
            .DrawY,
            .ShipX(ShipX_sig),
            .ShipY(ShipY_sig),
            .ProjColl,
            .ProjOn,
            .ProjDistX,
            .ProjDistY
            //.ProjEn,
            //.ProjX_arr,
            //.ProjY_arr
            );
    //assign ShipX = ShipX_sig;
    //assign ShipY = ShipY_sig;

endmodule
