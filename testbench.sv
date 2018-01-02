module testbench();
    timeunit 10ns;
    timeprecision 1ns;
    // Inputs:
    logic CLOCK_50 = 0;
    logic[3:0]    KEY; //bit 0 is set up as Reset
    logic             OTG_INT;                        //    CY7C67200 Interrupt
    logic [17:0] SW;
    // Outputs:
    logic [6:0]  HEX0, HEX1, HEX2, HEX3; //HEX4, HEX5, HEX6, HEX7,
    logic [8:0]  LEDG;
    logic [17:0] LEDR;
          // VGA Interface 
    logic [7:0]  VGA_R,                    //VGA Red
                        VGA_G,                    //VGA Green
                             VGA_B;                    //VGA Blue
    logic        VGA_CLK,                //VGA Clock
                        VGA_SYNC_N,            //VGA Sync signal
                             VGA_BLANK_N,            //VGA Blank signal
                             VGA_VS,                    //VGA virtical sync signal    
                             VGA_HS;                    //VGA horizontal sync signal
          // CY7C67200 Interface
    wire [15:0]  OTG_DATA;                        //    CY7C67200 Data bus 16 Bits
          logic [1:0]  OTG_ADDR;                        //    CY7C67200 Address 2 Bits
          logic        OTG_CS_N,                        //    CY7C67200 Chip Select
                             OTG_RD_N,                        //    CY7C67200 Write
                             OTG_WR_N,                        //    CY7C67200 Read
                             OTG_RST_N;                        //    CY7C67200 Reset
          
          // SDRAM Interface for Nios II Software
          logic [12:0] DRAM_ADDR;                // SDRAM Address 13 Bits
          wire [31:0]  DRAM_DQ;                // SDRAM Data 32 Bits
          logic [1:0]  DRAM_BA;                // SDRAM Bank Address 2 Bits
          logic [3:0]  DRAM_DQM;                // SDRAM Data Mast 4 Bits
          logic             DRAM_RAS_N;            // SDRAM Row Address Strobe
          logic             DRAM_CAS_N;            // SDRAM Column Address Strobe
          logic             DRAM_CKE;                // SDRAM Clock Enable
          logic             DRAM_WE_N;                // SDRAM Write Enable
          logic             DRAM_CS_N;                // SDRAM Chip Select
          logic             DRAM_CLK;                // SDRAM Clock

galaga g(.*);
    
    always begin: CLOCK_GENERATION
        #1 CLOCK_50 = ~CLOCK_50;
    end
    
    
    initial begin: TEST_VECTORS
    KEY[0] = 0;
    KEY[1] = 1;
    
    #2 KEY[0] = 1;
    end
endmodule 