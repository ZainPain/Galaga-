`include "galaga_lib.sv"
import galaga_lib::*;

// Module that governs the state machine for an enemy ship projectile.

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
