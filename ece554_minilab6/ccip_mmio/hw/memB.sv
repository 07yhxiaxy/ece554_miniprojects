/** This module would skew the B matrix that would be fed into the 
 *			Systolic array
*/
module memB
  #(
    parameter BITS_AB=8,
    parameter DIM=8
	)
  (
		// Input 
    input clk,
		input rst_n,
		input en, 
    input signed [BITS_AB-1:0] Bin [DIM-1:0],
		// Output
    output signed [BITS_AB-1:0] Bout [DIM-1:0]
  );
		
	// Declare the gen variable
	genvar i;
		
	generate  
		for (i = 0; i < DIM; i = i + 1) begin // for B rows
			fifo #(.DEPTH(8+i),
					.BITS(BITS_AB)
						) FIFO_BLK 
						(
						.clk(clk),
						.rst_n(rst_n),
						.en(en),
						.d(Bin[DIM-1-i]), // NOTE: Assuming [5,2,1,3,...] in verilog array => 5 is index 7 of matrix
						.q(Bout[DIM-1-i])
						);
		end
		
	
	endgenerate 
endmodule
