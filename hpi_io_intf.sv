	 module hpi_io_intf( input [1:0]  from_sw_address,
								output reg[15:0] from_sw_data_in,
								input [15:0] from_sw_data_out,
								input		 	 from_sw_r,from_sw_w,from_sw_cs,
								inout [15:0] OTG_DATA,    
								output reg[1:0]	 OTG_ADDR,    
								output reg		 OTG_RD_N, OTG_WR_N, OTG_CS_N, OTG_RST_N, 
								input 		 OTG_INT, Clk, Reset);
								
logic [15:0] tmp_data;
logic from_sw_int; 

//Fill in the blanks below. 
assign OTG_RST_N = ~Reset;
assign OTG_DATA = tmp_data;//Should be tristated

always_ff @ (posedge Clk or posedge Reset)
begin
	if(Reset)
	begin
		tmp_data 		<= 16'bZ;
		OTG_ADDR 		<= from_sw_address;
		OTG_RD_N 		<= 1'b1;
		OTG_WR_N 		<= 1'b1;
		OTG_CS_N 		<= from_sw_cs;
		from_sw_data_in<=  from_sw_data_out;
		from_sw_int 	<= 1'bX;
	end
	else 
	begin
        case({from_sw_r, from_sw_w})
            2'b10 : 
            begin
                tmp_data 		<= from_sw_data_out; // When we write to memory, set the bus with the data from software
                OTG_ADDR 		<= from_sw_address;
                OTG_RD_N			<= 1'b1;
                OTG_WR_N			<= 1'b0;
                OTG_CS_N			<= from_sw_cs;
                from_sw_data_in<= from_sw_data_in; // maintain old value for software
            end
            2'b01 : 
            begin
                tmp_data 		<= 16'bZ; // When we read from memory, set the tristate the High-Z
                OTG_ADDR 		<= from_sw_address;
                OTG_RD_N			<= 1'b0;
                OTG_WR_N			<= 1'b1;
                OTG_CS_N			<= from_sw_cs;
                from_sw_data_in<= OTG_DATA; // And send the bus into the software
            end
            default :
            begin
                tmp_data 		<= 16'bZ;
                OTG_ADDR 		<= from_sw_address;
                OTG_RD_N			<= 1'b1;
                OTG_WR_N			<= 1'b1;
                OTG_CS_N			<= 1'b1;
                from_sw_data_in<= from_sw_data_out;
            end
        endcase
		from_sw_int <= 1'bX;
	end
end
endmodule 