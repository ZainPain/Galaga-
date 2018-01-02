`include "galaga_lib.sv"
import galaga_lib::*;

/*  This Module is the top level for the Enemy ships. will pass signals to the enemy ship controller*/
module EnemyShips(input frame_clk, Reset,
                input [9:0] DrawX, DrawY,
                input [9:0] ESchedCtr, ESchedX [NE - 1:0][NM - 1:0], ESchedY [NE - 1:0][NM - 1:0],
                //input [9:0] ESchedCtr, 
                //input [9:0][NE - 1:0] ESchedX, ESchedY,
                input [9:0] EShipInitialX [NE - 1:0], EShipInitialY [NE - 1:0],
                input ESchedFire [NE - 1:0][NM - 1:0],
                input [NE - 1:0] EShipColl,
                input [NPE - 1:0] EProjColl [NE - 1:0],
                input [9:0] inSW,
                output EShipEn [NE - 1:0],
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
    EShipController _eships [NE - 1:0] (.*,
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
            .EShipEn,
            .EShipOn(EShipOn_sig),
            .EShipDistX(EShipDistX_sig),
            .EShipDistY(EShipDistY_sig),
            .EProjOn(EProjOn_sig),
            .EProjDistX(EProjDistX_sig),
            .EProjDistY(EProjDistY_sig)
    );
    
endmodule 


/* Controller for the Enemy Ship. Will pass signals to the enemy ship projectile controller and enemy ship location. This module keeps track of both the position of the ship and the projectiles that are fired/ can be fired.*/

module EShipController(input frame_clk, Reset,
                    input [9:0] ESchedCtr,
                    input [9:0] DrawX, DrawY,
                    //input ESchedFire,
                    input ESchedFire[NM - 1:0],
                    input [9:0] ESchedX [NM - 1:0], ESchedY [NM - 1:0], EShipInitialX, EShipInitialY,
                    //input [9:0] ESchedX, ESchedY, EShipInitialX, EShipInitialY,
                    input EShipColl,
                    input [9:0] inSW,
                    input [NPE - 1:0] EProjColl,
                    output [9:0] EShipDistX, EShipDistY, EProjDistX, EProjDistY,
                    output EShipOn,
                    output EShipEn,
                    output [NPE - 1:0] EProjOn);

logic [9:0] ShipX_sig, ShipY_sig, EShipXStep_sig;
//logic EShipEn; 
/*
module EShipProjectileController(input Reset, frame_clk,
                                input ESchedFire[NM - 1:0],
                                input [9:0] ESchedCtr,
                                input [9:0] EShipX, EShipY, EShipXStep,
                                input [NPE - 1:0] EProjColl,
                                output [NPE - 1:0] EProjEn,
                                output [9:0]EProjX_arr[NPE - 1:0], EProjY_arr[NPE - 1:0]);*/

    EShipLocation _sl(.*,
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
            .EShipDistY,
            .EShipEn
            );

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
            .EProjDistY,
            .EShipEn
            );

endmodule


// Module that governs the state machine for an enemy ship projectile.
// Written by Jeremy DeJournett in November 2016.

module EShipProjectile (input Reset, frame_clk, EProjActvt, EProjColl,
                        input [9:0] EShipGunX, EShipGunY, EShipXStep,
                        input [9:0] DrawX, DrawY,
                        output reg [9:0] EProjDistX, EProjDistY,
                        output reg EProjOn,
                        output reg EProjEn);
    logic [9:0] EProjInitialY;
    logic [9:0] EProjXStep;
    logic [9:0] EProjX, EProjY;
    enum logic [1:0] {Init, Move, Halt} state, next_state;

    parameter [9:0] EProjYStep = 10'b1; // Projs move in +y direction

    assign EProjInitialY = EShipGunY + EProjYSize;
    
    always_comb
    begin
        if(DrawX >= EProjX && DrawX <= EProjX + EProjXSize && DrawY >= EProjY && DrawY <= EProjY + EProjYSize)
        begin
            EProjOn = EProjEn;
            EProjDistX = DrawX - EProjX;
            EProjDistY = DrawY - EProjY;
        end
        else
        begin
            EProjOn = 1'b0;
            EProjDistX = 10'd0;
            EProjDistY = 10'd0;
        end
    end
    
    always_ff @ (posedge frame_clk)
    begin
        if(Reset == 1'b1)
        begin
            state <= Halt;
            EProjX <= EShipGunX;
            EProjY <= EProjInitialY; // starting y is greater than ship y
        end
        else
        begin
            state <= next_state;
            case(state)
                Move:
                begin
                    EProjXStep <= EProjXStep;
                    EProjX <= EProjX + EProjXStep;
                    EProjY <= EProjY + EProjYStep;
                end
                default: 
                begin
                    EProjXStep <= EShipXStep; // Whatever x direction the enemy was moving in, that's the x direction the projectile moves in
                    EProjX <= EShipGunX;
                    EProjY <= EProjInitialY; // starting location moves with ship
                end
            endcase
        end
    end
    always_comb
    begin
        next_state = state;
        EProjEn = 1'b0;
        case (state)
            Halt:
            begin
                if(EProjActvt == 1'b1)
                begin
                    next_state = Init;
                end
                EProjEn = 1'b0;
            end
            Init:
            begin
                next_state = Move;
                EProjEn = 1'b1;
            end
            Move:
            begin
                if(EProjX + EProjXSize >= X_Max)
                begin
                    EProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(EProjX <= X_Min)
                begin
                    // Just <= because EProjX,Y is top left corner
                    EProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(EProjY + EProjYSize >= Y_Max)
                begin
                    EProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(EProjY <= Y_Min)
                begin
                    EProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(EProjColl == 1'b1)
                begin
                    EProjEn = 1'b0;
                    next_state = Halt;
                end
                else
                begin
                    EProjEn = 1'b1;
                    next_state = Move;
                end
            end
            default: ;
        endcase
    end
endmodule


/* Using a scheduler, this module will update the position of an enemy sprite */


module EShipLocation(input frame_clk, Reset,
                    input [9:0] DrawX, DrawY,
                        input [9:0] ESchedCtr,
                        input [9:0] ESchedX [NM - 1:0], ESchedY [NM - 1:0], EShipInitialX, EShipInitialY,
                        //input [9:0] ESchedX, ESchedY, EShipInitialX, EShipInitialY,
                        input EShipColl,
                        input [9:0] inSW,
                        output reg EShipOn,
                        output [9:0] EShipDistX, EShipDistY, EShipX, EShipY, EShipXStep,
                        output EShipEn);

    logic [9:0] Ship_X_Pos, Ship_X_Motion, Ship_Y_Pos, Ship_Y_Motion;
    //logic EShipEn;
    logic [1:0] ExplosionCtr;
    logic [9:0] DistXOffset;

    always_comb
    begin
        if (DrawX >= EShipX && DrawX <= EShipX + EShipXSize && DrawY >= EShipY && DrawY <= EShipY + EShipYSize)
        begin
            EShipOn = EShipEn || (ExplosionCtr != 2'b0);
            EShipDistX = DrawX - EShipX + inSW + DistXOffset;
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
        ExplosionCtr <= ExplosionCtr;
        if (Reset == 1'b1)  // synchronous Reset
        begin 
            Ship_Y_Motion <= 10'd0; //Ship_Y_Step;
            Ship_X_Motion <= 10'd0; //Ship_X_Step;
            Ship_Y_Pos <= EShipInitialY;
            Ship_X_Pos <= EShipInitialX;
            ExplosionCtr <= 2'b0;
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
            if((EShipColl == 1'b1 && (EShipEn == 1'b1))|| (ExplosionCtr != 2'b0))
            begin
                EShipEn <= 1'b0;
                ExplosionCtr <= ExplosionCtr + 2'b1;
            end
            else
            begin
                Ship_Y_Pos <= ShipY_sig;  // Update ball position
                Ship_X_Pos <= ShipX_sig; 
            end
        end  
    end
    logic [9:0] ShipY_sig, ShipX_sig;
    always_comb
    begin
        ShipX_sig = Ship_X_Pos;
        ShipY_sig = Ship_Y_Pos;
        DistXOffset = 10'b0001000101;
        case(ExplosionCtr)
            2'b00   :
            begin
                if((EShipColl == 1'b0) && (EShipEn == 1'b1))
                begin
                    ShipX_sig = Ship_X_Pos + Ship_X_Motion;
                    ShipY_sig = Ship_Y_Pos + Ship_Y_Motion;
                end
            end
            2'b01   :
            begin
                DistXOffset = 10'b0000110010;
            end
            2'b10   :
            begin
                DistXOffset = 10'b0000011001;
            end
            2'b11   :
            begin
                DistXOffset = 10'b0000000001;
            end
            default : ;
        endcase
    end
    assign EShipX = Ship_X_Pos;
    assign EShipY = Ship_Y_Pos;
    assign EShipXStep = Ship_X_Motion;
endmodule 

/* EshipProjectileFinder will keep track of the number of projectiles fired by a ship as it can only fire  a limited amount due to hardware usage. If one projectile exits the screen or collides with the ship, that one projectile's hardware will once again be available to be used by the enemy ship. */ 

module EShipProjectileFinder(input Reset, frame_clk, 
                                input [9:0] ESchedCtr, 
                                //input ESchedFire,
                                input ESchedFire[NM - 1:0],
                                input [NPE - 1:0] EProjEn,
                                output reg [NPE - 1:0] EProjActvt,
                                input EShipEn);

    logic [NPE - 1:0] i;
    always_ff @ (posedge frame_clk)
    begin
        if(Reset)
        begin
            EProjActvt <= {NPE{1'b0}};
        end
        else
        begin
            if(ESchedFire[ESchedCtr] == 1'b1 && EShipEn == 1'b1) // Schedule calls for shot fired.
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


/* This is the enemy ship projectile controller, sends signals to EshipProjectile and EshipProjectileFinder. */

module EShipProjectileController(input Reset, frame_clk,
                                input ESchedFire[NM - 1:0],
                                //input ESchedFire,
                                input [9:0] DrawX, DrawY,
                                input [9:0] ESchedCtr,
                                input [9:0] EShipX, EShipY, EShipXStep,
                                input [NPE - 1:0] EProjColl,
                                output [NPE - 1:0] EProjOn,
                                output [9:0] EProjDistX, EProjDistY,
                                input EShipEn);

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
                        .EProjActvt(EProjActvt_sig),
                        .EShipEn);
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


/* SPrite table for the one type of enemy*/

module EnemyBeeSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'hde,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'hff,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'hff,8'hff,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableG[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h00,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h97,8'h97,8'h47,8'h47,8'h97,8'h47,8'h47,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h97,8'h47,8'h47,8'h97,8'h47,8'h47,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h97,8'h97,8'hff,8'hff,8'h97,8'hff,8'hff,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h97,8'hff,8'hff,8'hff,8'hff,8'hff,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00},
'{8'h97,8'h97,8'h97,8'h97,8'h97,8'hff,8'hff,8'hff,8'hff,8'hff,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00},
'{8'h00,8'h97,8'h97,8'h97,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'hff,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h47,8'h00,8'h47,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h47,8'h00,8'h47,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h00,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableB[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h00,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h97,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h97,8'h00,8'h00,8'h97,8'h00,8'h00,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h97,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h00,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule


/* Sprite table for another type of enemy*/
module BlueEnemySprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h00,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'hde,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'hff,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h97,8'h97,8'h97,8'h97,8'h97,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'hff,8'hff,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableG[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h68,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h68,8'h00,8'h00,8'h68,8'h00,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h68,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00},
'{8'h68,8'h68,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00},
'{8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'hff,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h00,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableB[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule

/* Sprite table for the third type of enemy*/

module RealBeeSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'hde,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'hff,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'hff,8'hff,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableG[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h68,8'h00,8'hff,8'h00,8'hff,8'h00,8'hff,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h00,8'h00,8'hff,8'h00,8'h00,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'hff,8'hff,8'hff,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hde,8'hff,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h68,8'h68,8'h00,8'hff,8'hff,8'hff,8'h00,8'h68,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'hff,8'hff,8'h00,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h68,8'h68,8'h68,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableB[16:0][83:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule

/* Sprite table for the projectiles*/

module EnemyShipProjectileSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[7:0][2:0] = '{'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hff,8'h00},
'{8'h00,8'hff,8'h00},
'{8'h00,8'hff,8'h00},
'{8'h00,8'hff,8'h00}};

parameter bit [7:0] SpriteTableG[7:0][2:0] = '{'{8'h00,8'h68,8'h00},
'{8'h00,8'h68,8'h00},
'{8'h68,8'h68,8'h68},
'{8'h68,8'hde,8'h68},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableB[7:0][2:0] = '{'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'hde,8'hde,8'hde},
'{8'hde,8'hde,8'hde},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule


