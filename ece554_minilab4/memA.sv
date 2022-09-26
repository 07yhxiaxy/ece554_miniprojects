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
    output signed [BITS_AB-1:0] Aout [DIM-1:0]
);
// Instantiate a transpose fifo module that takes input of Ain as data to be stored in memory and outputs the rhombus shape data
transpose_fifo tf(.clk(clk),.rst_n(rst_n),.en(en),.WrEn(WrEn),.Ain(Ain),.Aout(Aout));

endmodule