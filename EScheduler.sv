`include "galaga_lib.sv"
import galaga_lib::*;

/*

    The Enemy Scheduler is used to coordinate the movement of the enemy ships.
    It works but sending out an array of scheduled moves, as well as a counter with
    which the enemy ships can index into the schedule. This allows each ship to have a
    flexible set of movement paths and firing schedules without having cimplicated custom
    state machines for each enemy.
    
    The schedules themselves are simply hardcoded parameter arrays.

*/

module EScheduler(input Clk, Reset,
                input [2:0] CurrentLevel,
                //output reg ESchedClk,
                output reg [9:0] ESchedCtr,
                //output reg [9:0][NE - 1:0] ESchedX, ESchedY,
                output reg [9:0] ESchedX [NE - 1:0][NM - 1:0], ESchedY [NE - 1:0][NM - 1:0],
                output reg [9:0] EShipInitialX [NE - 1:0], EShipInitialY [NE - 1:0],
                output reg ESchedFire [NE - 1:0][NM - 1:0]
                //output reg ESchedFire [NE - 1:0]
                );
    logic clkby2;
    initial clkby2 = 0;
    always_ff @ (posedge Clk)
    begin
        clkby2 <= ~clkby2;
    end
    //assign ESchedClk = clkby2;
    //logic [9:0][NE - 1:0] ESchedX_arr[NM - 1:0], ESchedY_arr[NM - 1:0];
    //logic ESchedFire_arr[NE - 1:0][NM - 1:0];
//    always_comb
//    begin
//        ESchedX = ESchedX_arr[ESchedCtr];
//        ESchedY = ESchedY_arr[ESchedCtr];
//        ESchedFire = ESchedFire_arr[ESchedCtr][NE - 1:0];
//    end
    parameter PlusOne = 10'b1;
    parameter MinusOne = (~(PlusOne) + 10'b1);
    parameter PlusThree = 10'd2;
    parameter MinusThree = (~(PlusThree) + 10'b1);
    parameter reg [9:0] NoMove [NM - 1:0] = '{10'd0, 10'd0, 10'd0, 10'd0, 10'd0,
                                        10'd0, 10'd0, 10'd0, 10'd0, 10'd0,
                                        10'd0, 10'd0, 10'd0, 10'd0, 10'd0,
                                        10'd0, 10'd0, 10'd0, 10'd0, 10'd0}; 
    parameter reg [9:0] CircleX [NM - 1:0] = '{   19:PlusOne, 18:PlusOne, 17:PlusOne, 16:PlusOne, 15:PlusOne,
                                            14:MinusOne, 13:MinusOne, 12:MinusOne, 11:MinusOne, 10:MinusOne,
                                            9:MinusOne, 8:MinusOne, 7:MinusOne, 6:MinusOne, 5:MinusOne,
                                            4:PlusOne, 3:PlusOne, 2:PlusOne, 1:PlusOne, 0:PlusOne};
    parameter reg [9:0] CircleY [NM - 1:0] = '{   PlusOne, PlusOne, PlusOne, PlusOne, PlusOne,
                                            PlusOne, PlusOne, PlusOne, PlusOne, PlusOne,
                                            MinusOne, MinusOne, MinusOne, MinusOne, MinusOne,
                                            MinusOne, MinusOne, MinusOne, MinusOne, MinusOne};
    parameter reg [9:0] BackAndForth [NM - 1:0] = '{  PlusThree, MinusThree, PlusThree, MinusThree, PlusThree,
                                                MinusThree, PlusThree, MinusThree, PlusThree, MinusThree,
                                                PlusThree, MinusThree, PlusThree, MinusThree, PlusThree,
                                                MinusThree, PlusThree, MinusThree, PlusThree, MinusThree};
    parameter reg FireOnFrame13 [NM - 1:0] = '{1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                                    1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                                    1'b0, 1'b0, 1'b1, 1'b1, 1'b1,
                                    1'b0, 1'b0, 1'b0, 1'b0, 1'b0 };
    always_ff @ (posedge clkby2)
    begin
        if(Reset == 1'b1)
        begin
            ESchedCtr <= 10'b0;
        end
        else
        begin
            if(ESchedCtr >= NM - 1)
                ESchedCtr <= 10'b0;
            else
                ESchedCtr <= ESchedCtr + 10'b1;
        end
        ESchedFire <= '{ FireOnFrame13, FireOnFrame13,
                FireOnFrame13, FireOnFrame13,
                FireOnFrame13, FireOnFrame13,
                FireOnFrame13, FireOnFrame13,
                FireOnFrame13, FireOnFrame13 };
    end
    always_comb
    begin
        EShipInitialX = '{10'd020, 10'd080, 10'd140, 10'd200, 10'd260, 10'd320, 10'd380, 10'd440, 10'd500, 10'd560};
        EShipInitialY = '{10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040, 10'd040};
        ESchedX = '{CircleX, BackAndForth, CircleY, NoMove, BackAndForth,
                    NoMove, NoMove, NoMove, BackAndForth, NoMove};
        ESchedY = '{CircleY, NoMove, CircleX, NoMove, NoMove,
                    NoMove, CircleX, CircleY, NoMove, NoMove};
        case(CurrentLevel)
            3'b1    :
            begin
                ESchedX = '{BackAndForth, CircleX, CircleY, NoMove, CircleX,
                            CircleY, CircleX, NoMove, BackAndForth, CircleY};
                ESchedY = '{BackAndForth, CircleX, CircleX, BackAndForth, CircleY,
                            CircleX, NoMove, CircleY, CircleY, CircleY};
            end
            3'd2    :
            begin
                ESchedX = '{BackAndForth, BackAndForth, BackAndForth, BackAndForth, BackAndForth,
                            BackAndForth, BackAndForth, BackAndForth, BackAndForth, BackAndForth};
                ESchedY = '{NoMove, NoMove, NoMove, NoMove, NoMove,
                            NoMove, NoMove, NoMove, NoMove, NoMove};
            end
            default : ;
        endcase

        
    end
endmodule 