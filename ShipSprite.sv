module ShipSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[18:0][16:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hff,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hff,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'hff,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hff,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'hff,8'h00,8'h00,8'h00,8'hde,8'hde,8'hff,8'hff,8'hff,8'hde,8'hde,8'h00,8'h00,8'h00,8'hff,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'hde,8'hff,8'hde,8'hff,8'hde,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hff,8'hde,8'hde,8'hde,8'hff,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'hff,8'hff,8'hde,8'hde,8'hde,8'hff,8'hff,8'h00,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'h00,8'h00,8'hff,8'hff,8'h00,8'hde,8'h00,8'hff,8'hff,8'h00,8'h00,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableG[18:0][16:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h68,8'hde,8'hde,8'h00,8'hde,8'hde,8'h68,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h68,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'h68,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableB[18:0][16:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'h00,8'hde,8'hde,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00,8'h00,8'h00,8'hde,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'hde,8'h00},
'{8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hde,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule
