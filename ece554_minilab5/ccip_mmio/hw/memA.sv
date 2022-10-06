/*
* memA module, which is a memory that stores the data as input to tpumac.
* Takes input of 8 bit * 8 elements (which is a row)
* outputs a 8 bit * 8 elements (which is a column)
*/
module memA
#(
    parameter BITS_AB=8,
    parameter DIM=8
)
(
    input clk,rst_n,en,WrEn,
    input signed [BITS_AB-1:0] Ain [DIM-1:0],
    input [$clog2(DIM)-1:0] Arow,
    output signed [BITS_AB-1:0] Aout [DIM-1:0] // In matrix first row [5, 4, 2, 1, ...], 5 is matrix 00 which is Ain[7] in verilog
);

// for the remaining rows apart from the 1st
wire signed [BITS_AB-1:0] Ain_intermediate [DIM-1:0][DIM-1:0];
wire [DIM-1:0] isSelectedRow;
wire [DIM-1:0] WrEnVector;

// reg zeros
wire signed [BITS_AB-1:0] zerosArray [DIM-1:0];

genvar row;
generate
	for (row = 0; row < DIM; row++) begin
		// Prepare the values
		assign zerosArray[row] = '0;
		assign isSelectedRow[row] = 1'(Arow === row); 
		assign Ain_intermediate[row] = isSelectedRow[row]  ? Ain : zerosArray; 
		assign WrEnVector[row] = isSelectedRow[row] ? WrEn : 0;
		
		transpose_fifo #(	
										.DEPTH(DIM + DIM - 1 - row),
										.DIM(DIM),
										.BITS(BITS_AB)) 
										tf(
										.clk(clk),
										.rst_n(rst_n),
										.en(en),
										.WrEn(isSelectedRow[row] & WrEnVector[row]), // only write to selected row
										.Ain(Ain_intermediate[row]),
										.Aout(Aout[row]));				
	end
endgenerate

endmodule