`include "galaga_lib.sv"
import galaga_lib::*;

module EnemyShips(input frame_clk, Reset,
                input [9:0] DrawX, DrawY,
                input [9:0] ESchedCtr, ESchedX [NE - 1:0][NM - 1:0], ESchedY [NE - 1:0][NM - 1:0],
                input [9:0] EShipInitialX [NE - 1:0], EShipInitialY [NE - 1:0],
                input ESchedFire [NE - 1:0][NM - 1:0],
                input [NE - 1:0] EShipColl,
                input [NPE - 1:0] EProjColl [NE - 1:0],
                output EShipOn [NE - 1:0],
                output [9:0] EShipDistX, EShipDistY,
                //output [9:0] EShipX [NE - 1:0], EShipY [NE - 1:0],
                output [NPE - 1:0] EProjOn [NE - 1:0],
                output [9:0] EProjDistX, EProjDistY
                //output [9:0] EProjX_arr[NE - 1:0][NPE - 1:0],
                //output [9:0] EProjY_arr[NE - 1:0][NPE - 1:0]
                );
    logic EShipOn_sig [NE - 1:0];
    logic [NPE - 1:0] EProjOn_sig [NE - 1:0];
    logic [9:0] EShipDistX_sig [NE - 1:0], EShipDistY_sig [NE - 1:0];
    logic [9:0] EProjDistX_sig [NE - 1:0], EProjDistY_sig [NE - 1:0];
    /*module EShipController(input frame_clk, Reset,
                    input [9:0] ESchedCtr,
                    input ESchedFire[NM - 1:0],
                    input [9:0] ESchedX [NM - 1:0], ESchedY [NM - 1:0], EShipInitialX, EShipInitialY,
                    input EShipColl,
                    input [NPE - 1:0] EProjColl,
                    output EShipEn,
                    output [9:0] EShipX, EShipY,
                    output [NPE - 1:0] EProjEn,
                    output [9:0]EProjX_arr[NPE - 1:0], EProjY_arr[NPE - 1:0]);*/
    always_comb
    begin
    EProjDistX = 10'd0;
    EProjDistY = 10'd0;
    EShipDistX = 10'd0;
    EShipDistY = 10'd0;
    EShipOn = EShipOn_sig;
    EProjOn = EProjOn_sig;
        for(int i = 0; i < NE; i++)
        begin
            if(EProjOn_sig[i][NPE - 1:0] != {NPE{1'b0}})
            begin
                EProjDistX = EProjDistX_sig[i][9:0];//{ << 10 {EProjDistX_sig[i]}};
                EProjDistY = EProjDistY_sig[i][9:0];//{ << 10 {EProjDistY_sig[i]}};
                break;
            end
        end
        for(int i = 0; i < NE; i++)
        begin
            if(EShipOn_sig[i] != 1'b0)
            begin
                EShipDistX = EShipDistX_sig[i][9:0];
                EShipDistY = EShipDistY_sig[i][9:0];
                break;
            end
        end
    end
    EShipController _eships [NE - 1:0] (
            .frame_clk, .Reset,
            .DrawX, .DrawY,
            .ESchedCtr,
            .ESchedFire,
            .ESchedX,
            .ESchedY,
            .EShipInitialX,
            .EShipInitialY,
            .EShipColl,
            .EProjColl,
            .EShipOn(EShipOn_sig),
            .EShipDistX(EShipDistX_sig),
            .EShipDistY(EShipDistY_sig),
            .EProjOn(EProjOn_sig),
            .EProjDistX(EProjDistX_sig),
            .EProjDistY(EProjDistY_sig)
    );
    
endmodule 