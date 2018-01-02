`include "galaga_lib.sv"
import galaga_lib::*;

module EShipProjectileController(input Reset, frame_clk,
                                input ESchedFire[NM - 1:0],
                                input [9:0] DrawX, DrawY,
                                input [9:0] ESchedCtr,
                                input [9:0] EShipX, EShipY, EShipXStep,
                                input [NPE - 1:0] EProjColl,
                                output [NPE - 1:0] EProjOn,
                                output [9:0] EProjDistX, EProjDistY);

    logic [NPE - 1:0] EProjActvt_sig;
    logic [NPE - 1:0] EProjOn_sig, EProjEn_sig;
    logic [9:0] EProjDistX_sig[NPE - 1:0], EProjDistY_sig[NPE - 1:0];
    logic [9:0] ShipXGunOffset = 5;
    logic [9:0] ShipYGunOffset = 7;
    
    always_comb
    begin
        EProjDistX = 10'd0;
        EProjDistY = 10'd0;
        EProjOn = EProjOn_sig;
        for(int i = 0; i < NPE; i++)
        begin
            if(EProjOn_sig[i] == 1'b1)
            begin
                EProjDistX = EProjDistX_sig[i];
                EProjDistY = EProjDistY_sig[i];
                break;
            end
        end
    end
    
    EShipProjectileFinder _espf(.*,
                        .EProjEn(EProjEn_sig),
                        .EProjActvt(EProjActvt_sig));
    EShipProjectile _esprojectiles [NPE - 1:0] (.Reset,
                                        .frame_clk,
                                        .EProjEn(EProjEn_sig),
                                        .EProjActvt(EProjActvt_sig),
                                        .DrawX,
                                        .DrawY,
                                        .EProjDistX(EProjDistX_sig),
                                        .EProjDistY(EProjDistY_sig),
                                        .EProjColl,
                                        .EProjOn(EProjOn_sig),
                                        .EShipXStep,
                                        .EShipGunX(EShipX + ShipXGunOffset),
                                        .EShipGunY(EShipY + ShipYGunOffset));
endmodule
