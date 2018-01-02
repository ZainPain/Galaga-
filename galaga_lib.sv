/*

    This SV file serves as a header file, defining useful constants for use in multiple other
    modules. It also allows us to dynamically change how many enemies there are, how many
    projectiles they get to shoot, and how many projectiles our ship gets to shoot.

*/


// TO USE: Include this file in your project, and paste the following 2 lines
//   (uncommented) into whatever file needs to reference the functions &
//   constants included in this file, just after the usual library references:
//`include "galaga_lib.sv"
//import galaga_lib::*;
`ifndef _GALAGA_LIB
`define _GALAGA_LIB

package galaga_lib;

// Test Pixel Location
    parameter TestPX = 10'd565;
    parameter TestPY = 10'd41;

// Screen Parameters
    parameter X_Min = 10'd0;
    parameter X_Max = 10'd639;
    parameter Y_Min = 10'd0;
    parameter Y_Max = 10'd479;

// Projectile Parameters
    parameter ProjXSize = 10'd3;
    parameter ProjYSize = 10'd8;
    parameter EProjXSize = 10'd3;
    parameter EProjYSize = 10'd8;

// Ship Parameters
    parameter ShipXSize = 10'd17;
    parameter ShipYSize = 10'd19;
    parameter ShipVMaxX = 10'd5;
    parameter ShipVMaxY = 10'd3;
    parameter EShipXSize = 10'd15;
    parameter EShipYSize = 10'd17;

// Keycodes
    parameter SPACE_KEY = 8'd44;
    parameter W_KEY = 8'h1a;
    parameter A_KEY = 8'h04;
    parameter S_KEY = 8'h16;
    parameter D_KEY = 8'h07;
    parameter ENTER_KEY = 8'd40;
    parameter R_KEY = 8'h15;

// Number of <thing>
    parameter NE = 10;  // Number of enemy ships
    parameter NP = 15;  // Number of projectiles our ship uses
    parameter NPE = 15; // Number of projectiles per enemy ship
    parameter NM = 20;  // Number of moves in an enemy "Schedule". Should end up with enemy at same location as start.

    typedef logic [NE - 1:0] logic_NE_t;

endpackage

`endif