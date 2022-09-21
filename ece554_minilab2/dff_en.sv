/**
* This is the dff module with an enable
*/
module dff_en(
	// Input
	input clk,
	input rst_n,
	input logic signed d,
	input logic en, // enable signal for flip flop
	// Output
	output logic signed q
	); 
	
	assign d_en = en ? d : q;
	
	dff DFF1 (.clk(clk),
						.rst_n(rst_n),
						.d(d_en),
						.q(q)
					 );
endmodule
