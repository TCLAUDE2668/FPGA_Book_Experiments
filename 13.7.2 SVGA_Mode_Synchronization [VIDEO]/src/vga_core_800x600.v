`timescale 1ns / 1ps

module vga_core_800x600(
	input clk,rst_n, //clock must be 50MHz for 640x480 
	output hsync,vsync,
	output reg video_on,
	output[11:0] pixel_x,pixel_y
    );		
	 
	 //800x600 parameters
	 localparam HD=800, //Horizontal Display
					HR=64, //Right Border
					HRet=120, //Horizontal Retrace
					HL=56, //Left Border
					
					VD=600, //Vertical Display
					VB=23, //Bottom Border
					VRet=6, //Vertical Retrace
					VT=37; //Top Border
					
	reg[11:0] vctr_q=0,vctr_d; //counter for vertical scan
	reg[11:0] hctr_q=0,hctr_d; //counter for vertical scan
	reg hsync_q=0,hsync_d; //horizontal sync is buffered for a glitchless output
	reg vsync_q=0,vsync_d; //vertical sync is buffered for a glitchless output
	
	//vctr and hctr register operation
	always @(posedge clk,negedge rst_n) begin
		if(!rst_n) begin
			vctr_q<=0;
			hctr_q<=0;
			vsync_q<=0;
			hsync_q<=0;
		end
		else begin
			vctr_q<=vctr_d;
			hctr_q<=hctr_d;
			vsync_q<=vsync_d;
			hsync_q<=hsync_d;
		end
	end
	
	//horizontal and vertical counter logic for horizontal sync and vertical sync
	always @* begin
		vctr_d=vctr_q;
		hctr_d=hctr_q;
		video_on=0;
		hsync_d=1; 
		vsync_d=1; 
		
		if(hctr_q==HD+HR+HRet+HL-1) hctr_d=0; //horizontal counter
		else hctr_d=hctr_q+1'b1;
		
		if(vctr_q==VD+VB+VRet+VT-1) vctr_d=0; //vertical counter
		else if(hctr_q==HD+HR+HRet+HL-1) vctr_d=vctr_q+1'b1;
		
		if(hctr_q<HD && vctr_q<VD) video_on=1; //video_on 
		
		if( (hctr_d>=HD+HR) && (hctr_d<=HD+HR+HRet-1) ) hsync_d=0; //d-input is used as condition (not the present "q")to remove the one-clock delay due to buffering the horizontal sync 
		if( (vctr_d>=VD+VB) && (vctr_d<=VD+VB+VRet-1) ) vsync_d=0; //d-input is used as condition (not the present "q")to remove the one-clock delay due to buffering the vertical sync
				
	end
		assign vsync=vsync_q;
		assign hsync=hsync_q;
		assign pixel_x=hctr_q;
		assign pixel_y=vctr_q;

endmodule
