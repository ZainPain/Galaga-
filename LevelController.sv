`include "galaga_lib.sv"
import galaga_lib::*;

// Written by Zain Paya December 2016
/*

    This state machine is used to keep track of overall game state and issue
    control signals to the color mapper, enemy scheduler, and ship controllers
    when a new level is reached or when the main ship dies.

*/
 
module LevelController (input Clk,
                    input Reset,
                    input EShipEn [NE - 1:0],
                    input ShipEn,
                    input [15:0] keycode,
                    output ResetShips,
                    output SplashScreen,
                    output GameOver,
                    output NewGame,
                    output [2:0] CurrentLevel
                  );
 
    parameter bit ESE0 [NE - 1:0] = '{NE{1'b0}};
 
    enum logic [3:0] { Halted, Pause1, Pause2, Pause3, Level1, Level2, Level3, End} State, Next_State;

    logic [2:0] LevelCounter;

    always_ff @ (posedge Clk or posedge Reset)
    begin : Assign_Next_State
        if(Reset)
          begin
            State <= Halted;
                LevelCounter <= 3'b0;
            end
        else
        begin
            State <= Next_State;
        end
    end
   
    /*
        LevelSig ---
       
        000 -> Halted
        001 -> Level1
        010 -> Level2
        011 -> Level3
        100 -> Pause
        101 -> End
    */
    always_comb
    begin
        Next_State = State;
        ResetShips = ((keycode[7:0] == R_KEY)||(keycode[15:8] == R_KEY));
        SplashScreen = 1'b0;
        GameOver = 1'b0;
        CurrentLevel = 3'b0;
        NewGame = ((keycode[7:0] == R_KEY)||(keycode[15:8] == R_KEY));
       
        case(State)
         
            Halted :
            begin
                if(keycode [7:0] == ENTER_KEY ||  keycode [15:8] == ENTER_KEY)
                begin
                    Next_State = Level1;
                end
                ResetShips = 1'b1;
                SplashScreen = 1'b1;
                NewGame = 1'b1;
            end
           
            Level1 :
            begin
                CurrentLevel = 3'd0;
                if((EShipEn == ESE0) && (ShipEn == 1'b1))
                begin
                    Next_State = Pause1;
                end
                else if ( ShipEn == 1'b0)
                begin
                    Next_State = Halted;
                end
            end
 
            Level2 :
            begin
                CurrentLevel = 3'd1;
                if(EShipEn == ESE0 && ShipEn == 1'b1)
                    Next_State = Pause2;
                else if ( ShipEn == 1'b0)
                    Next_State = Halted;
            end
           
            Level3 :
            begin
                CurrentLevel = 3'd2;
                if(EShipEn == ESE0 && ShipEn == 1'b1)
                    Next_State = Pause3;
                else if (ShipEn == 1'b0)
                    Next_State = Halted;
            end
           
            Pause1 :
            begin
                ResetShips = 1'b1;
                //if(keycode [7:0] == ENTER_KEY ||  keycode [15:8] == ENTER_KEY)
                //    begin
                        Next_State = Level2;
                //    end
            end
            
            Pause2 :
            begin
                ResetShips = 1'b1;
                //if(keycode [7:0] == ENTER_KEY ||  keycode [15:8] == ENTER_KEY)
                //    begin
                        Next_State = Level3;
                //    end
            end
            Pause3 :
            begin
                ResetShips = 1'b1;
                //if(keycode [7:0] == ENTER_KEY ||  keycode [15:8] == ENTER_KEY)
                //    begin
                        Next_State = End;
                //    end
            end
            End :
            begin
                ResetShips = 1'b1;
                GameOver = 1'b1;
                if((keycode[7:0] == R_KEY)||(keycode[15:8] == R_KEY))
                    Next_State = Halted;
            end
            default : ;
        endcase
   end
   
endmodule 