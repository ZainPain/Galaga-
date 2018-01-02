//-------------------------------------------------------------------------
//      Galaga Final Project
//      Jeremy DeJournett
//      Zain Paya
//      Fall 2016
//
//      This is the top level module of our final project.
//      It connects the Ship and Enemy Controllers to the Enemy Scheduler,
//      Color Mapper, Collision Detector, and Level Controller, as well as
//      the NIOS II CPU and HPIO USB modules.
//-------------------------------------------------------------------------
`include "galaga_lib.sv"
import galaga_lib::*;

module  galaga         ( input         CLOCK_50,
                       input[3:0]    KEY, //bit 0 is set up as Reset
                       input [17:0] SW,
                              output [6:0]  HEX0, HEX1, HEX2, HEX3, //HEX4, HEX5, HEX6, HEX7,
                              output [8:0]  LEDG,
                              output [17:0] LEDR,
                              // VGA Interface 
                       output [7:0]  VGA_R,                    //VGA Red
                                            VGA_G,                    //VGA Green
                                                 VGA_B,                    //VGA Blue
                              output        VGA_CLK,                //VGA Clock
                                            VGA_SYNC_N,            //VGA Sync signal
                                                 VGA_BLANK_N,            //VGA Blank signal
                                                 VGA_VS,                    //VGA virtical sync signal    
                                                 VGA_HS,                    //VGA horizontal sync signal
                              // CY7C67200 Interface
                              inout [15:0]  OTG_DATA,                        //    CY7C67200 Data bus 16 Bits
                              output [1:0]  OTG_ADDR,                        //    CY7C67200 Address 2 Bits
                              output        OTG_CS_N,                        //    CY7C67200 Chip Select
                                                 OTG_RD_N,                        //    CY7C67200 Write
                                                 OTG_WR_N,                        //    CY7C67200 Read
                                                 OTG_RST_N,                        //    CY7C67200 Reset
                              input             OTG_INT,                        //    CY7C67200 Interrupt
                              // SDRAM Interface for Nios II Software
                              output [12:0] DRAM_ADDR,                // SDRAM Address 13 Bits
                              inout [31:0]  DRAM_DQ,                // SDRAM Data 32 Bits
                              output [1:0]  DRAM_BA,                // SDRAM Bank Address 2 Bits
                              output [3:0]  DRAM_DQM,                // SDRAM Data Mast 4 Bits
                              output             DRAM_RAS_N,            // SDRAM Row Address Strobe
                              output             DRAM_CAS_N,            // SDRAM Column Address Strobe
                              output             DRAM_CKE,                // SDRAM Clock Enable
                              output             DRAM_WE_N,                // SDRAM Write Enable
                              output             DRAM_CS_N,                // SDRAM Chip Select
                              output             DRAM_CLK                // SDRAM Clock
                                            );
    
    logic Reset_h, vssig, Clk;
    logic [9:0] drawxsig, drawysig;
     logic [15:0] keycode;
    //logic [9:0] X_ship_projectiles[9:0], Y_ship_projectiles[9:0];
    //logic [9:0] enabled_ship_projectiles;
    logic ShipOn_sig;
    logic ShipColl_sig;
    logic [9:0] inSW;
    assign inSW = SW[9:0];
    // Ship Projectile Signals
    logic [NP - 1:0] ProjOn_sig;
    logic [NP - 1:0] ProjColl_sig;
    //logic [NP - 1:0] ProjColl_sig, ProjEn_sig;
    //logic [9:0] ProjX_arr_sig [NP - 1:0], ProjY_arr_sig [NP - 1:0];

    // Enemy Ship Signals
    logic [NE - 1:0] EShipColl_sig;
    logic EShipOn_sig [NE - 1:0];
    //logic EShipEn_sig [NE - 1:0];
    //logic [9:0] EShipX_sig [NE - 1:0], EShipY_sig [NE - 1:0];
    
    // Enemy Projectile Signals
    //logic [NPE - 1:0] EProjEn_sig [NE - 1:0];
    logic [NPE - 1:0] EProjColl_sig [NE - 1:0];
    logic [NPE - 1:0] EProjOn_sig [NE - 1:0];
    //logic [9:0] EProjX_arr_sig[NE - 1:0][NPE - 1:0];
    //logic [9:0] EProjY_arr_sig[NE - 1:0][NPE - 1:0];

    // Enemy Scheduler Signals
    logic ESchedClk_sig;
    logic [9:0] ESchedCtr_sig, ESchedX_sig [NE - 1:0][NM - 1:0], ESchedY_sig [NE - 1:0][NM - 1:0];
    //logic [9:0] ESchedCtr_sig;
    //logic [9:0] [NE - 1:0] ESchedX_sig, ESchedY_sig;
    logic [9:0] EShipInitialX_sig [NE - 1:0], EShipInitialY_sig [NE - 1:0];
    logic ESchedFire_sig [NE - 1:0][NM - 1:0];
    //logic ESchedFire_sig [NE - 1:0];
    
    assign Clk = CLOCK_50;
    assign {Reset_h}=~ (KEY[0]);  // The push buttons are active low
    
    // Red LEDs for debugging
    assign LEDR[9:0] = ESchedX_sig[NE - 1][ESchedCtr_sig];
    assign LEDR[16:10] = 7'b0;
    assign LEDR[17] = (ESchedX_sig[NE - 1][ESchedCtr_sig] <= 10'd0);
    // Green LEDs for debugging
    //assign LEDG = ;
    logic rising_edge;
    DREG _dr (.Clk, .Reset(Reset_h | KEY[1]), .LD(drawxsig == TestPX && drawysig == TestPY),
    .D_IN({3'b0, rising_edge, ShipColl_sig, ShipOn_sig, ProjOn_cm, EShipOn_cm, EProjOn_cm}),
    .D_OUT(LEDG));
    //assign vssig = CLOCK_50; // Used for running simulations
     assign VGA_VS = vssig;
    
    wire [1:0] hpi_addr;
     wire [15:0] hpi_data_in, hpi_data_out;
     wire hpi_r, hpi_w,hpi_cs;
     
     hpi_io_intf hpi_io_inst(   .from_sw_address(hpi_addr),
                                         .from_sw_data_in(hpi_data_in),
                                         .from_sw_data_out(hpi_data_out),
                                         .from_sw_r(hpi_r),
                                         .from_sw_w(hpi_w),
                                         .from_sw_cs(hpi_cs),
                                          .OTG_DATA(OTG_DATA),    
                                         .OTG_ADDR(OTG_ADDR),    
                                         .OTG_RD_N(OTG_RD_N),    
                                         .OTG_WR_N(OTG_WR_N),    
                                         .OTG_CS_N(OTG_CS_N),    
                                         .OTG_RST_N(OTG_RST_N),   
                                         .OTG_INT(OTG_INT),
                                         .Clk(Clk),
                                         .Reset(Reset_h)
     );
     
     //The connections for nios_system might be named different depending on how you set up Qsys
     lab_8 nios_system(
                                         .clk_clk(Clk),         
                                         .reset_reset_n(KEY[0]),   
                                         .sdram_wire_addr(DRAM_ADDR), 
                                         .sdram_wire_ba(DRAM_BA),   
                                         .sdram_wire_cas_n(DRAM_CAS_N),
                                         .sdram_wire_cke(DRAM_CKE),  
                                         .sdram_wire_cs_n(DRAM_CS_N), 
                                         .sdram_wire_dq(DRAM_DQ),   
                                         .sdram_wire_dqm(DRAM_DQM),  
                                         .sdram_wire_ras_n(DRAM_RAS_N),
                                         .sdram_wire_we_n(DRAM_WE_N), 
                                         .sdram_clk_clk(DRAM_CLK),
                                         .keycode_export(keycode),  
                                         .otg_hpi_address_export(hpi_addr),
                                         .otg_hpi_data_in_port(hpi_data_in),
                                         .otg_hpi_data_out_port(hpi_data_out),
                                         .otg_hpi_cs_export(hpi_cs),
                                         .otg_hpi_r_export(hpi_r),
                                         .otg_hpi_w_export(hpi_w));
    
    //Fill in the connections for the rest of the modules 
    vga_controller vgasync_instance(
            .Clk,
            .Reset(Reset_h),
            .hs(VGA_HS),
            .vs(vssig),
            .pixel_clk(VGA_CLK),
            .blank(VGA_BLANK_N),
            .sync(VGA_SYNC_N),
            .DrawX(drawxsig),
            .DrawY(drawysig));

    ShipController _sc(.frame_clk(vssig), .Reset(Reset_h | ~KEY[1] | NewGame),
                    .ResetShips,
                    .keycode,
                    .DrawX(drawxsig),
                    .DrawY(drawysig),
                    //.ShipX(ShipX_sig),
                    //.ShipY(ShipY_sig),
                    .ShipDistX(ShipDistX_sig),
                    .ShipDistY(ShipDistY_sig),
                    .ShipEn(ShipEn_sig),
                    .ShipOn(ShipOn_sig),
                    .ProjOn(ProjOn_sig),
                    .ProjDistX(ProjDistX_sig),
                    .ProjDistY(ProjDistY_sig),
                    .ShipColl(SW[0] & ShipColl_sig),
                    .ProjColl(ProjColl_sig)
                    );
    EnemyShips _eships (.*,
            .frame_clk(vssig), .Reset(Reset_h | ~KEY[1] | ResetShips),
            .DrawX(drawxsig),
            .DrawY(drawysig),
            // Scheduler signals
            .ESchedCtr(ESchedCtr_sig),
            .ESchedFire(ESchedFire_sig),
            .ESchedX(ESchedX_sig),
            .ESchedY(ESchedY_sig),
            .EShipInitialX(EShipInitialX_sig),
            .EShipInitialY(EShipInitialY_sig),
            // Collision unit signals
            .EShipColl(EShipColl_sig),
            .EProjColl(EProjColl_sig),
            // Color mapper signals
            .EShipOn(EShipOn_sig),
            .EShipEn(EShipEn_sig),
            .EShipDistX(EShipDistX_sig),
            .EShipDistY(EShipDistY_sig),
            .EProjOn(EProjOn_sig),
            .EProjDistX(EProjDistX_sig),
            .EProjDistY(EProjDistY_sig)
    );
    
    EScheduler _es(.*, .Clk(vssig), .Reset(Reset_h | ~KEY[1] | ResetShips),
                .CurrentLevel(CurrentLevel_sig),
                //.ESchedClk(ESchedClk_sig),
                .ESchedCtr(ESchedCtr_sig),
                .ESchedX(ESchedX_sig),
                .ESchedY(ESchedY_sig),
                .EShipInitialX(EShipInitialX_sig),
                .EShipInitialY(EShipInitialY_sig),
                .ESchedFire(ESchedFire_sig)
                );
    logic [9:0] ShipDistX_sig, ShipDistY_sig, ProjDistX_sig, ProjDistY_sig;
    logic [9:0] EShipDistX_sig, EShipDistY_sig, EProjDistX_sig, EProjDistY_sig;
    CollisionDetector _cd(.*,
                    .frame_clk(vssig),
                    .pixel_clk(VGA_CLK),
                    .rising_edge,
                    .Reset(Reset_h | ~KEY[1] | ResetShips),
                    .ShipOn(ShipOn_sig),
                    .ProjOn(ProjOn_sig),
                    .EShipOn(EShipOn_sig),
                    .EProjOn(EProjOn_sig),
                    .ShipColl(ShipColl_sig),
                    .ProjColl(ProjColl_sig),
                    .EShipColl(EShipColl_sig),
                    .EProjColl(EProjColl_sig),
                    .ProjOn_cm, .EShipOn_cm, .EProjOn_cm
                    );
    logic ProjOn_cm, EShipOn_cm, EProjOn_cm;
    color_mapper color_instance(.*,
            //.ShipX(ShipX_sig),
            //.ShipY(ShipY_sig),
            .CurrentLevel(CurrentLevel_sig),
            .SplashScreen(SplashScreen_sig),
            .GameOver(GameOver_sig),
            .DrawX(drawxsig),
            .DrawY(drawysig),
            .ShipOn(ShipOn_sig),
            .ShipDistX(ShipDistX_sig),
            .ShipDistY(ShipDistY_sig),
            //.X_ship_projectiles(ProjX_arr_sig),
            //.Y_ship_projectiles(ProjY_arr_sig),
            .ProjOn(ProjOn_cm),
            .ProjDistX(ProjDistX_sig),
            .ProjDistY(ProjDistY_sig),
            //.enabled_ship_projectiles(ProjEn_sig),
            //.EShipX(EShipX_sig),
            //.EShipY(EShipY_sig),
            //.EShipEn(EShipEn_sig),
            .EShipOn(EShipOn_cm),
            .EShipDistX(EShipDistX_sig),
            .EShipDistY(EShipDistY_sig),
            .EProjOn(EProjOn_cm),
            .EProjDistX(EProjDistX_sig),
            .EProjDistY(EProjDistY_sig),
            //.EProjEn(EProjEn_sig),
            //.EProjX_arr(EProjX_arr_sig),
            //.EProjY_arr(EProjY_arr_sig),
            .Red(VGA_R),
            .Green(VGA_G),
            .Blue(VGA_B));
    logic EShipEn_sig[NE - 1:0];
    logic ShipEn_sig, ResetShips, NewGame;
    logic SplashScreen_sig, GameOver_sig;
    logic [2:0] CurrentLevel_sig;
    
    LevelController _lc (.Clk(vssig),
                        .Reset(Reset_h | ~KEY[1]),
                        .NewGame,
                        .EShipEn(EShipEn_sig),
                        .ShipEn(ShipEn_sig),
                        .keycode,
                        .ResetShips,
                        .SplashScreen(SplashScreen_sig),
                        .GameOver(GameOver_sig),
                        .CurrentLevel(CurrentLevel_sig)
                        );
                                          
     HexDriver hex_inst_0 (keycode[3:0], HEX0);
     HexDriver hex_inst_1 (keycode[7:4], HEX1);
     HexDriver hex_inst_2 (keycode[11:8], HEX2);
     HexDriver hex_inst_3 (keycode[15:12], HEX3);

endmodule
