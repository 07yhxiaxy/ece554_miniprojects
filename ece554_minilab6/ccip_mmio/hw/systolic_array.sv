
module systolic_array
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8
    )
   (
    input                      clk,rst_n,WrEn,en,
    input signed [BITS_AB-1:0] A [DIM-1:0],
    input signed [BITS_AB-1:0] B [DIM-1:0],
    input signed [BITS_C-1:0]  Cin [DIM-1:0],
    input [$clog2(DIM)-1:0]    Crow,
    output signed [BITS_C-1:0] Cout [DIM-1:0]
    );

wire signed [BITS_AB-1:0] carryA [DIM-1:0][DIM:0];
wire signed [BITS_AB-1:0] carryB [DIM:0][DIM-1:0];
wire signed [BITS_C-1:0] carryC [DIM-1:0][DIM-1:0];


genvar k;
generate
	for(k = 0; k < DIM; k+=1) begin
		assign carryA[k][DIM] = A[k];
		assign carryB[DIM][k] = B[k];
		assign Cout[k] = carryC[Crow][k];
	end
endgenerate

genvar i, j;
generate
    for(i = 0; i < DIM; i++) begin
			for(j = 0; j < DIM; j++) begin
				tpumac #(
				.BITS_AB(BITS_AB), 
				.BITS_C(BITS_C)) 
				iDUT(
				.clk(clk), 
				.rst_n(rst_n), 
				.en(en),
				.WrEn((Crow == i) ? WrEn : 1'b0), 
				.Ain(carryA[i][j+1]), 
				.Bin(carryB[i+1][j]), 
				.Cin(Cin[i]),
				.Aout(carryA[i][j]), 
				.Bout(carryB[i][j]), 
				.Cout(carryC[i][j]));
			end
    end
endgenerate

endmodule
