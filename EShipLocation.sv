`include "galaga_lib.sv"
import galaga_lib::*;

module EShipLocation(input frame_clk, Reset,
                    input [9:0] DrawX, DrawY,
                        input [9:0] ESchedCtr,
                        input [9:0] ESchedX [NM - 1:0], ESchedY [NM - 1:0], EShipInitialX, EShipInitialY,
                        input EShipColl,
                        output reg EShipOn,
                        output [9:0] EShipDistX, EShipDistY, EShipX, EShipY, EShipXStep);

    logic [9:0] Ship_X_Pos, Ship_X_Motion, Ship_Y_Pos, Ship_Y_Motion;
    logic EShipEn;

    always_comb
    begin
        if (DrawX >= EShipX && DrawX <= EShipX + EShipXSize && DrawY >= EShipY && DrawY <= EShipY + EShipYSize)
        begin
            EShipOn = EShipEn;
            EShipDistX = DrawX - EShipX;
            EShipDistY = DrawY - EShipY;
        end
        else
        begin
            EShipOn = 1'b0;
            EShipDistX = 10'd0;
            EShipDistY = 10'd0;
        end
    end

    always_ff @ (posedge frame_clk )
    begin: Move_Enemy_Ship
        EShipEn <= EShipEn;
        if (Reset == 1'b1)  // synchronous Reset
        begin 
            Ship_Y_Motion <= 10'd0; //Ship_Y_Step;
            Ship_X_Motion <= 10'd0; //Ship_X_Step;
            Ship_Y_Pos <= EShipInitialY;
            Ship_X_Pos <= EShipInitialX;
            EShipEn <= 1'b1;
        end
           
        else 
        begin
            if ( (Ship_Y_Pos + ShipYSize) >= Y_Max )
                Ship_Y_Motion <= 10'd0;
            else if ( (Ship_Y_Pos - ShipYSize) <= Y_Min )
                Ship_Y_Motion <= 10'd0;
            else if ( (Ship_X_Pos + ShipXSize) >= X_Max)
                Ship_X_Motion <= 10'd0;
            else if ( (Ship_X_Pos - ShipXSize ) <= X_Min)
                Ship_X_Motion <= 10'd0;
            else
            begin
                Ship_X_Motion <= ESchedX[ESchedCtr];
                Ship_Y_Motion <= ESchedY[ESchedCtr];
            end
            if(EShipColl == 1'b1 || EShipEn == 1'b0)
            begin
                EShipEn <= 1'b0;
                Ship_X_Pos <= Ship_X_Pos;
                Ship_Y_Pos <= Ship_Y_Pos;
            end
            else
            begin
                Ship_Y_Pos <= (Ship_Y_Pos + Ship_Y_Motion);  // Update ball position
                Ship_X_Pos <= (Ship_X_Pos + Ship_X_Motion); 
            end
        end  
    end
    assign EShipX = Ship_X_Pos;
    assign EShipY = Ship_Y_Pos;
    assign EShipXStep = Ship_X_Motion;
endmodule 