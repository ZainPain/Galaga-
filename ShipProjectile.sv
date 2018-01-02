`include "galaga_lib.sv"
import galaga_lib::*;

// Module that drives state machine for projectiles originating from our ship

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
