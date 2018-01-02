`include "galaga_lib.sv"
import galaga_lib::*;

module EShipController(input frame_clk, Reset,
                    input [9:0] ESchedCtr,
                    input [9:0] DrawX, DrawY,
                    input ESchedFire[NM - 1:0],
                    input [9:0] ESchedX [NM - 1:0], ESchedY [NM - 1:0], EShipInitialX, EShipInitialY,
                    input EShipColl,
                    input [NPE - 1:0] EProjColl,
                    output [9:0] EShipDistX, EShipDistY, EProjDistX, EProjDistY,
                    output EShipOn,
                    output [NPE - 1:0] EProjOn);

logic [9:0] ShipX_sig, ShipY_sig, EShipXStep_sig;
/*
module EShipProjectileController(input Reset, frame_clk,
                                input ESchedFire[NM - 1:0],
                                input [9:0] ESchedCtr,
                                input [9:0] EShipX, EShipY, EShipXStep,
                                input [NPE - 1:0] EProjColl,
                                output [NPE - 1:0] EProjEn,
                                output [9:0]EProjX_arr[NPE - 1:0], EProjY_arr[NPE - 1:0]);*/

/*module EShipLocation(input frame_clk, Reset,
                        input [9:0] ESchedCtr,
                        input [9:0] ESchedX [NM - 1:0], ESchedY [NM - 1:0], EShipInitialX, EShipInitialY,
                        input EShipColl,
                        output reg EShipOn,
                        output [9:0] EShipDistX, EShipDistY, EShipXStep);*/

    EShipLocation _sl(
            .Reset,
            .frame_clk,
            .DrawX,
            .DrawY,
            .ESchedCtr,
            .ESchedX,
            .ESchedY,
            .EShipInitialX,
            .EShipInitialY,
            .EShipColl,
            .EShipOn,
            .EShipXStep(EShipXStep_sig),
            .EShipX(ShipX_sig),
            .EShipY(ShipY_sig),
            .EShipDistX,
            .EShipDistY
            );
/*
module EShipProjectileController(input Reset, frame_clk,
                                input ESchedFire[NM - 1:0],
                                input [9:0] ESchedCtr,
                                input [9:0] EShipX, EShipY, EShipXStep,
                                input [NPE - 1:0] EProjColl,
                                output [NPE - 1:0] EProjEn,
                                output [9:0]EProjX_arr[NPE - 1:0], EProjY_arr[NPE - 1:0]);*/
    EShipProjectileController _espc (
            .Reset,
            .frame_clk,
            .DrawX,
            .DrawY,
            .ESchedFire,
            .ESchedCtr,
            .EShipX(ShipX_sig),
            .EShipY(ShipY_sig),
            .EShipXStep(EShipXStep_sig),
            .EProjColl,
            .EProjOn,
            .EProjDistX,
            .EProjDistY
            );

endmodule
