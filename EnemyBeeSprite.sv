module EnemyBeeSprite(input [9:0] SpriteX, SpriteY,
            output [7:0] SpriteR, SpriteG, SpriteB);

parameter bit [7:0] SpriteTableR[6:0][8:0] = '{'{8'h00,8'h00,8'h00,8'h00,8'hf8,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hf8,8'hf8,8'hf8,8'hf8,8'hf8,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hf8,8'hf8,8'hf8,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hf8,8'hf8,8'hf8,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hf8,8'hf8,8'hf8,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'hf8,8'hf8,8'hf8,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'hf8,8'h00,8'h00,8'h00,8'h00}};

parameter bit [7:0] SpriteTableG[6:0][8:0] = '{'{8'h00,8'h50,8'h00,8'h00,8'he8,8'h00,8'h00,8'h50,8'h00},
'{8'h00,8'h00,8'he8,8'h00,8'he8,8'h00,8'he8,8'h00,8'h00},
'{8'h00,8'h00,8'h50,8'he8,8'he8,8'he8,8'h50,8'h00,8'h00},
'{8'h00,8'h00,8'h50,8'h00,8'h00,8'h00,8'h50,8'h00,8'h00},
'{8'h00,8'h50,8'h50,8'h00,8'h00,8'h00,8'h50,8'h50,8'h00},
'{8'h50,8'h50,8'h50,8'he8,8'he8,8'he8,8'h50,8'h50,8'h50},
'{8'h50,8'h50,8'h00,8'h00,8'h00,8'h00,8'h00,8'h50,8'h50}};

parameter bit [7:0] SpriteTableB[6:0][8:0] = '{'{8'h00,8'hf8,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf8,8'h00},
'{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
'{8'h00,8'h00,8'hf8,8'h00,8'h00,8'h00,8'hf8,8'h00,8'h00},
'{8'h00,8'h00,8'hf8,8'h00,8'h00,8'h00,8'hf8,8'h00,8'h00},
'{8'h00,8'hf8,8'hf8,8'h00,8'h00,8'h00,8'hf8,8'hf8,8'h00},
'{8'hf8,8'hf8,8'hf8,8'h00,8'h00,8'h00,8'hf8,8'hf8,8'hf8},
'{8'hf8,8'hf8,8'h00,8'h00,8'h00,8'h00,8'h00,8'hf8,8'hf8}};

assign SpriteR = SpriteTableR[SpriteY][SpriteX];
assign SpriteG = SpriteTableG[SpriteY][SpriteX];
assign SpriteB = SpriteTableB[SpriteY][SpriteX];

endmodule
