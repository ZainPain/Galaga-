`include "galaga_lib.sv"
import galaga_lib::*;

/*

    The ship controller is used to keep track of the location of the player
    controlled ship and all of its projectiles. It issues the signals used
    by the color mapper to index into the appropriate sprite tables. It also
    keeps track of whether or not the ship and its projectiles should be "on",
    which is used by both the collision detector and the color mapper.

*/

module ShipController(input frame_clk, Reset, ResetShips,
                    input [15:0] keycode,
                    input [9:0] DrawX, DrawY,
                    input ShipColl,
                    input [NP - 1:0] ProjColl,
                    output ShipOn,
                    output ShipEn,
                    output [NP - 1:0] ProjOn,
                    output [9:0] ShipDistX, ShipDistY,
                    output [9:0] ProjDistX, ProjDistY
                    );
                    //output [NP - 1:0] ProjEn,
                    //output [9:0]ProjX_arr[NP - 1:0], ProjY_arr[NP - 1:0]);

logic [9:0] ShipX_sig, ShipY_sig;

    ShipLocation _sl(
            .Reset,
            .ResetShips,
            .frame_clk,
            .DrawX,
            .DrawY,
            .ShipOn,
            .ShipEn,
            .ShipColl,
            .ShipDistX,
            .ShipDistY,
            .ShipX(ShipX_sig),
            .ShipY(ShipY_sig),
            .keycode);

    ShipProjectileController _spc (
            .Reset(Reset | ResetShips),
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

//-------------------------------------------------------------------------
// ShipLocation.sv
//  State Machine and logic governing movement of player owned ship in galaga.
//  Written by Jeremy DeJournett and Zain Paya in November 2016.
//-------------------------------------------------------------------------
//`include "galaga_lib.sv"
//import galaga_lib::*;

module  ShipLocation ( input Reset, ResetShips, frame_clk,
               input [15:0] keycode,
               input [9:0] DrawX, DrawY,
               input ShipColl,
               output ShipOn,
               output ShipEn,
               output [9:0] ShipDistX, ShipDistY, ShipX, ShipY
               );
    
    logic [9:0] Ship_X_Pos, Ship_X_Motion, Ship_Y_Pos, Ship_Y_Motion;
    logic [3:0] NumLives;
//    logic [9:0] ShipX, ShipY;
    initial begin
        NumLives = 4'd9;
    end
    parameter [9:0] Ship_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ship_Y_Center=400;  // Center position on the Y axis
    parameter [9:0] Ship_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ship_Y_Step=1;      // Step size on the Y axis

    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ship
        if (Reset)  // Asynchronous Reset
        begin 
            Ship_Y_Motion <= 10'd0; //Ship_Y_Step;
            Ship_X_Motion <= 10'd0; //Ship_X_Step;
            Ship_Y_Pos <= Ship_Y_Center;
            Ship_X_Pos <= Ship_X_Center;
            NumLives <= 4'd9;
        end
        else
        if(ResetShips)
        begin
            Ship_Y_Motion <= 10'd0;
            Ship_X_Motion <= 10'd0;
            Ship_X_Pos <= Ship_X_Center;
            Ship_Y_Pos <= Ship_Y_Center;
            NumLives <= NumLives;
        end
        else
        begin 
            if ( (Ship_Y_Pos + ShipYSize) >= Y_Max )
                  Ship_Y_Motion <= (~(Ship_Y_Step) + 1'b1);//10'd0;
            else if ( Ship_Y_Pos <= Y_Min )
                  Ship_Y_Motion <= Ship_Y_Step;
            else if ( (Ship_X_Pos + ShipXSize) >= X_Max)
                Ship_X_Motion <= (~(Ship_X_Step) + 1'b1);//10'd0;
            else if ( Ship_X_Pos <= X_Min)
                Ship_X_Motion <= Ship_X_Step;
            else
                case(keycode[7:0])
                    W_KEY   ://16'h1a  :   
                        begin
                            Ship_Y_Motion <= (~(Ship_Y_Step) + 1'b1); // Key W moves up
                            Ship_X_Motion <= 10'd0;
                        end
                    S_KEY   ://16'h16  :   
                        begin
                            Ship_Y_Motion <= Ship_Y_Step; // Key S moves down
                            Ship_X_Motion <= 10'd0;
                        end
                    D_KEY   ://16'h07  :   
                        begin
                            Ship_X_Motion <= Ship_X_Step; // Key D moves right
                            Ship_Y_Motion <= 10'd0;
                        end
                    A_KEY   ://16'h04  :   
                        begin
                            Ship_X_Motion <= (~(Ship_X_Step) + 1'b1);// Key A moves left
                            Ship_Y_Motion <= 10'd0;
                        end
                    SPACE_KEY:
                        begin
                            case(keycode[15:8])
                                W_KEY   ://16'h1a  :   
                                    begin
                                        Ship_Y_Motion <= (~(Ship_Y_Step) + 1'b1); // Key W moves up
                                        Ship_X_Motion <= 10'd0;
                                    end
                                S_KEY   ://16'h16  :   
                                    begin
                                        Ship_Y_Motion <= Ship_Y_Step; // Key S moves down
                                        Ship_X_Motion <= 10'd0;
                                    end
                                D_KEY   ://16'h07  :   
                                    begin
                                        Ship_X_Motion <= Ship_X_Step; // Key D moves right
                                        Ship_Y_Motion <= 10'd0;
                                    end
                                A_KEY   ://16'h04  :   
                                    begin
                                        Ship_X_Motion <= (~(Ship_X_Step) + 1'b1); // Key A moves left
                                        Ship_Y_Motion <= 10'd0;
                                    end
                                default :   
                                    begin
                                        Ship_X_Motion <= 1'b0;//Ship_X_Motion;
                                        Ship_Y_Motion <= 1'b0; //Ship_Y_Motion;
                                    end
                            endcase
                        end
                    default :   
                        begin
                            Ship_X_Motion <= 10'd0;//Ship_X_Motion;
                            Ship_Y_Motion <= 10'd0;//Ship_Y_Motion;
                        end
                endcase
                Ship_Y_Pos <= (Ship_Y_Pos + Ship_Y_Motion);  // Update ball position
                Ship_X_Pos <= (Ship_X_Pos + Ship_X_Motion); 
                if(ShipColl == 1'b1)
                    NumLives <= NumLives - 4'b1;
                else
                    NumLives <= NumLives;
        end  
    end
    
    always_comb
    begin
        ShipEn = NumLives > 4'd0;
        if(DrawX >= ShipX && DrawX <= ShipX + ShipXSize  && DrawY >= ShipY && DrawY <= ShipY + ShipYSize)
        begin
            ShipOn = ~ShipColl;
            ShipDistX = DrawX - ShipX;
            ShipDistY = DrawY - ShipY;
        end
        else
        begin
            ShipOn = 1'b0;
            ShipDistX = 10'd0;
            ShipDistY = 10'd0;
        end
    end
    
    assign ShipX = Ship_X_Pos;

    assign ShipY = Ship_Y_Pos;

endmodule

/*

    This module loops through the hardware dedicated to tracking the ship's
    projectile modules and find one that's not being used when the user wants
    to fire a projectile. If it finds one, it send it the appropriate activation
    signal. If not, no projectiles get fired (eg all available hardware is in use).

*/

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

    This module is the upper level module for the ship's projectiles.
    It keeps track of all NP projectiles, including their location 
    on screen, and their draw signals for the color mapper and collision detector.
    

*/

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
    // We generate NP different DistX signals, but if the
    // projectile isn't on, we shouldn't use it. We just use the
    // first one we find, which is okay because projectiles can
    // almost never overlap one another.
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

module ShipProjectile (input Reset, frame_clk, ProjActvt, ProjColl,
                        input [9:0] ShipGunX, ShipGunY,
                        input [9:0] DrawX, DrawY,
                        output reg [9:0] ProjDistX, ProjDistY,
                        output reg ProjEn,
                        output ProjOn);
                        //output [9:0] ProjDistX, ProjDistY);
    logic [9:0] ProjInitialY;
    logic [9:0] ProjX, ProjY;
    
    assign ProjInitialY = ShipGunY - ProjYSize; // starting y is less than ship y, as gun is further up screen
    enum logic [1:0] {Init, Move, Halt} state, next_state;

    parameter [9:0] ProjXStep = 0;
    parameter [9:0] ProjYStep = ~(10'd3) + 1'b1; // Projs move in -y direction
    
    always_comb
    begin
        if(DrawX >= ProjX && DrawX <= ProjX + ProjXSize && DrawY >= ProjY && DrawY <= ProjY + ProjYSize)
        begin
            ProjOn = ProjEn;
            ProjDistX = DrawX - ProjX;
            ProjDistY = DrawY - ProjY;
        end
        else
        begin
            ProjOn = 1'b0;
            ProjDistX = 10'd0;
            ProjDistY = 10'd0;
        end
    end
    
    always_ff @ (posedge frame_clk)
    begin
        if(Reset == 1'b1)
        begin
            state <= Halt;
            ProjX <= ShipGunX;
            ProjY <= ProjInitialY; 
        end
        else
        begin
            state <= next_state;
            case(state)
                Move:
                begin
                    ProjX <= ProjX + ProjXStep;
                    ProjY <= ProjY + ProjYStep;
                end
                default: 
                begin
                    ProjX <= ShipGunX;
                    ProjY <= ProjInitialY;
                end
            endcase
        end
    end
    always_comb
    begin
        next_state = state;
        ProjEn = 1'b0;
        case (state)
            Halt:
            begin
                if(ProjActvt == 1'b1)
                begin
                    next_state = Init;
                end
                ProjEn = 1'b0;
            end
            Init:
            begin
                next_state = Move;
                ProjEn = 1'b1;
            end
            Move:
            begin
                if(ProjX + ProjXSize >= X_Max)
                begin
                    ProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(ProjX <= X_Min)
                begin
                    // Just <= because ProjX,Y is top left corner
                    ProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(ProjY + ProjYSize >= Y_Max)
                begin
                    ProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(ProjY <= Y_Min)
                begin
                    ProjEn = 1'b0;
                    next_state = Halt;
                end
                else if(ProjColl == 1'b1)
                begin
                    ProjEn = 1'b0;
                    next_state = Halt;
                end
                else
                begin
                    ProjEn = 1'b1;
                    next_state = Move;
                end
            end
            default: ;
        endcase
    end
endmodule

/* ship projectile sprites are stored here as constant arrays in hardware, ROM */
module ShipProjectileSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[7:0][2:0] = '{'{8'h00,8'hff,8'h00},
'{8'h00,8'hff,8'h00},
'{8'hff,8'hff,8'hff},
'{8'hff,8'h00,8'hff},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00}};

parameter bit [7:0] SpriteTableG[7:0][2:0] = '{'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'hff,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00}};

parameter bit [7:0] SpriteTableB[7:0][2:0] = '{'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule


/* Ship Sprites are stored here as constant arrays in hardware.*/
module ShipSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[18:0][16:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hff,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'hff,8'h00,8'h00,8'h00,8'hde,8'hde,8'hff,8'hff,8'hff,8'hde,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'hde,8'hff,8'hde,8'hff,8'hde,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hff,8'hde,8'hde,8'hde,8'hff,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'hff,8'hff,8'hde,8'hde,8'hde,8'hff,8'hff,8'h00,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableG[18:0][16:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h68,8'hde,8'hde,8'h00,8'hde,8'hde,8'h68,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h68,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'h68,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableB[18:0][16:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule
