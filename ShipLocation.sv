//-------------------------------------------------------------------------
// ShipLocation.sv
//  State Machine and logic governing movement of player owned ship in galaga.
// TODO:
//  1. Add collision detection
//-------------------------------------------------------------------------
//`include "galaga_lib.sv"
//import galaga_lib::*;

module  ShipLocation ( input Reset, frame_clk,
               input [15:0] keycode,
               input [9:0] DrawX, DrawY,
               input ShipColl,
               output ShipOn,
               output [9:0] ShipDistX, ShipDistY, ShipX, ShipY
               );
    
    logic [9:0] Ship_X_Pos, Ship_X_Motion, Ship_Y_Pos, Ship_Y_Motion;
//    logic [9:0] ShipX, ShipY;
     
    parameter [9:0] Ship_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ship_Y_Center=240;  // Center position on the Y axis
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
        end  
    end
    
    always_comb
    begin
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
