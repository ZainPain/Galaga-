//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                    h                                   --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

/*

    This module instantiates the various sprite tables we use and uses them to
    map the RGB signals used to drive the VGA display.

*/

`include "galaga_lib.sv"
import galaga_lib::*;

module  color_mapper ( input        [9:0] DrawX, DrawY,
                        //input [9:0] X_ship_projectiles[NP - 1:0], Y_ship_projectiles [NP - 1:0],
                        input [3:0] CurrentLevel,
                        input ShipOn,
                        input SplashScreen,
                        input GameOver,
                        input [9:0] ShipDistX, ShipDistY,
                        input ProjOn,
                        input [9:0] ProjDistX, ProjDistY,
                        //input [NP - 1:0] enabled_ship_projectiles,
                        //input EShipEn [NE - 1:0],
                        input EShipOn,
                        input [9:0] EShipDistX, EShipDistY,
                        //input [9:0] EShipX [NE - 1:0], EShipY [NE - 1:0],
                        //input [NPE - 1:0] EProjEn [NE - 1:0],
                        input EProjOn,
                        input [9:0] EProjDistX, EProjDistY,
                        //input [9:0] EProjX_arr [NE - 1:0][NPE - 1:0],
                        //input [9:0] EProjY_arr [NE - 1:0][NPE - 1:0],
                       output logic [7:0]  Red, Green, Blue );

    //logic ship_on, sproj_on, eship_on, eproj_on;
    logic [7:0] ShipR, ShipG, ShipB;
    logic [7:0] SProjR, SProjG, SProjB;
    logic [7:0] EShipR, EShipG, EShipB;
    logic [7:0] EShipR2, EShipG2, EShipB2;
    logic [7:0] EShipR3, EShipG3, EShipB3;
    logic [7:0] EProjR, EProjG, EProjB;
    logic [7:0] SplashR = 8'haf, SplashG = 8'h00, SplashB = 8'ha0;

    int ShipH, DistX, DistY, ProjectileYSize;
    // assigning ship dimensions
    assign ShipH = ShipYSize;
    // assigning projectile dimensions
    assign ProjectileYSize = ProjYSize;
    
    parameter [9:0] SplashXStart = 10'd207;
    parameter [9:0] SplashXSize = 10'd227;
    parameter [9:0] SplashYStart = 10'd184;
    parameter [9:0] SplashYSize = 10'd117;
       
    always_comb
    begin:RGB_Display
        /*if (DrawX == TestPX && DrawY == TestPY)
        begin
            DistX = 10'd0;
            DistY = 10'd0;
            Red = 8'd94;
            Green = 8'd255;
            Blue = 8'd51;
        end else*/
        if(SplashScreen == 1'b1)
        begin
            //if(DrawX >= SplashXStart && DrawX <= SplashXStart + SplashXSize && DrawY >= SplashYStart && DrawY <= SplashYStart + SplashYSize)
            //begin
                DistX = DrawX - SplashXStart;
                DistY = DrawY - SplashYStart;
                Red = SplashR;
                Green = SplashG;
                Blue = SplashB;
            /*end
            else
            begin
                DistX = 0;
                DistY = 0;
                Red = 8'd150;
                Green = 8'd150;
                Blue = 8'd150;
            end*/
        end
        else
        if(GameOver == 1'b1)
        begin
            DistX = 0;
            DistY = 0;
            Red = 8'haf;
            Green = 8'h00;
            Blue = 8'h00;
        end
        else
        begin
            if ((ShipOn == 1'b1)) 
            begin 
                DistX = ShipDistX;
                DistY = ShipDistY;
                Red = ShipR;
                Green = ShipG;
                Blue = ShipB;
            end       
            else if(ProjOn == 1'b1)
            begin
                DistX = ProjDistX;
                DistY = ProjDistY;
                Red = SProjR;
                Green = SProjG;
                Blue = SProjB;
            end 
            else if(EShipOn == 1'b1)
            begin
                DistX = EShipDistX;
                DistY = EShipDistY;
                case(CurrentLevel)
                    3'd1    :
                    begin
                        Red = EShipR2;
                        Green = EShipG2;
                        Blue = EShipB2;
                    end
                    3'd2    :
                    begin
                        Red = EShipR3;
                        Green = EShipG3;
                        Blue = EShipB3;
                    end
                    default :
                    begin
                        Red = EShipR;
                        Green = EShipG;
                        Blue = EShipB;
                    end
                endcase
            end
            else if(EProjOn == 1'b1)
            begin
                DistX = EProjDistX;
                DistY = EProjDistY;
                Red = EProjR;
                Green = EProjG;
                Blue = EProjB;
            end
            else
            begin 
                DistX = 0;
                DistY = 0;
                Red = 8'h00;//8'h0f; 
                Green = 8'h00;
                Blue = 8'h00;//8'h3f - DrawX[9:3];
            end      
        end
    end 
    EnemyBeeSprite ebs(.SpriteX(DistX), .SpriteY(EShipYSize - DistY), .SpriteR(EShipR), .SpriteG(EShipG), .SpriteB(EShipB));
    ShipSprite sm(.SpriteX(DistX), .SpriteY(ShipH-DistY), .SpriteR(ShipR), .SpriteG(ShipG), .SpriteB(ShipB));
    ShipProjectileSprite sps(.SpriteX(DistX), .SpriteY(ProjectileYSize - DistY), .SpriteR(SProjR), .SpriteG(SProjG), .SpriteB(SProjB));
    EnemyShipProjectileSprite esps(.SpriteX(DistX), .SpriteY(DistY), .SpriteR(EProjR), .SpriteG(EProjG), .SpriteB(EProjB));
    BlueEnemySprite bes(.SpriteX(DistX), .SpriteY(EShipYSize - DistY), .SpriteR(EShipR2), .SpriteG(EShipG2), .SpriteB(EShipB2));
    RealBeeSprite rbs(.SpriteX(DistX), .SpriteY(EShipYSize - DistY), .SpriteR(EShipR3), .SpriteG(EShipG3), .SpriteB(EShipB3));
    //GalagaLogo ss(.SpriteX(SplashXSize - DistX), .SpriteY(SplashYSize - DistY), .SpriteR(SplashR), .SpriteG(SplashG), .SpriteB(SplashB));
endmodule
