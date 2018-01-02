/* This module allows the detection of collisions such as when a projectile of one party collides with a ship of the other party 
( Your ship firing and projectile and the projectile colliding with an enemy ship). 
This module also handles when a user ship comes into contact with an enemy ship. For these collisions, we send a collision signal to the colormapper which will then display an explosion.*/ 
`include "galaga_lib.sv"
import galaga_lib::*;

module CollisionDetector(
                    input frame_clk, pixel_clk, Reset,
                    //input [9:0] DrawX, DrawY,
                    input ShipOn,
                    input [NP - 1:0] ProjOn,
                    input EShipOn[NE - 1:0], 
                    input [NPE - 1:0] EProjOn [NE - 1:0],
                    output rising_edge,
                    output ShipColl,
                    output [NP - 1:0] ProjColl,
                    output [NE - 1:0] EShipColl,
                    output [NPE - 1:0] EProjColl [NE - 1:0],
                    output ProjOn_cm, EShipOn_cm, EProjOn_cm);

    logic fc_sample;
    initial
    begin
        fc_sample = 1'b0;
    end
    
    assign rising_edge = fc_sample;

//    logic ShipColl_eship, ShipColl_eproj;
//    logic  [NE - 1:0] EShipColl_ship, EShipColl_proj;
    logic ShipColl_sig;
    logic [NP - 1:0] ProjColl_sig;
    logic [NE - 1:0] EShipColl_sig;
    logic [NPE - 1:0] EProjColl_sig [NE - 1:0];


    parameter bit [NP - 1:0] PC0 = {NP{1'b0}};
    parameter bit [NE - 1:0] ESC0 = {NE{1'b0}};
    parameter bit [NPE - 1:0] EPC0 [NE - 1:0] =  '{NE{{NPE{1'b0}}}};

    always_ff @ (posedge pixel_clk)
    begin
        fc_sample <= frame_clk;
        if(Reset | (~fc_sample & frame_clk))
        begin
        // Reset every frame
            ShipColl <= 1'b0;
            //ShipColl_eship <= 1'b0;
            ProjColl <= PC0;
            EShipColl <= ESC0;
            //EShipColl_ship <= ESC0;
            EProjColl <= EPC0;
        end
        else
        begin
            ShipColl <= ShipColl | ShipColl_sig;
            ProjColl <= ProjColl | ProjColl_sig;
            EShipColl <= EShipColl | EShipColl_sig;
            EProjColl <= EProjColl_sig;
        end
        /*
        begin
            ShipColl_eproj <= 1'b0;
            ShipColl_eship <= 1'b0;
            ProjColl <= PC0;
            EShipColl_proj <= ESC0;
            EShipColl_ship <= ESC0;
            EProjColl <= EPC0;
            
            if(ShipOn)
            begin
                EProjColl <= EProjOn;
                EShipColl_ship <= logic_NE_t'(EShipOn);
            end
            if(logic_NE_t'(EShipOn) != ESC0)
            begin
                ShipColl_eship <= ShipOn;
                ProjColl <= ProjOn;
            end
            if(ProjOn != PC0)
            begin
                EShipColl_proj <= logic_NE_t'(EShipOn);
                ProjColl <= ProjOn;
            end
            if(EProjOn != EPC0)
            begin
                ShipColl_eproj <= ShipOn;
            end
        end*/
    end
    always_comb
    begin
        for(int i = 0; i < NE; i++)
        begin
            EProjColl_sig[i][NPE - 1:0] = EProjColl[i][NPE - 1:0] | EProjOn[i][NPE - 1:0] & {NPE{ShipOn}};
        end
    end
    //assign EShipColl = EShipColl_proj | EShipColl_ship;//EShipColl_proj.or with(EShipColl_ship);
    //assign ShipColl = ShipColl_eproj | ShipColl_eship;//ShipColl_eproj.or with(ShipColl_eship);
    
    assign ShipColl_sig = ShipOn & ((EProjOn != EPC0)|(logic_NE_t'(EShipOn) != ESC0));
    logic_NE_t ess;
    assign ess = logic_NE_t'(EShipOn);
    assign EShipColl_sig = ess & {NE{((ProjOn != PC0) | ShipOn)}};
    assign ProjColl_sig = ProjOn & {NP{(logic_NE_t'(EShipOn) != ESC0)}};

    assign ProjOn_cm = |ProjOn;
    assign EShipOn_cm = EShipOn.or;
    assign EProjOn_cm = |(EProjOn.or);
endmodule 