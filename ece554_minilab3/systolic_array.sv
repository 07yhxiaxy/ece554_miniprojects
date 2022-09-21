module systolic_array
#(
   parameter BITS_AB=8,
   parameter BITS_C=16,
   parameter DIM=8
)
(
   input clk,rst_n,WrEn,en,
   input signed [BITS_AB-1:0] A [DIM-1:0],
   input signed [BITS_AB-1:0] B [DIM-1:0],
   input signed [BITS_C-1:0]  Cin [DIM-1:0],
   input [$clog2(DIM)-1:0]    Crow,
   output signed [BITS_C-1:0] Cout [DIM-1:0]
);

logic signed [BITS_AB-1:0] Aout [DIM:0][DIM:0];
logic signed [BITS_AB-1:0] Bout [DIM:0][DIM:0];
logic signed [BITS_C-1:0] Co [DIM-1:0][DIM-1:0];
genvar row, col;
generate
   for (row = 0; row < DIM; ++row) begin
      assign Aout[row][0] = A[row];
   end
   for (col = 0; col < DIM; ++col) begin
      assign Bout[0][col] = B[col];
   end
   for (row=0; row < DIM; ++row) begin
      for (col=0; col < DIM; ++col) begin
         tpumac ti(.Ain(Aout[row][col]), .Bin(Bout[row][col]), .Cin(Cin[Crow]), .Aout(Aout[row][col+1]), .Bout(Bout[row+1][col]), .Cout(Co[row][col]), .clk(clk), .en(en), .rst_n(rst_n), .WrEn(WrEn && Crow==row));
      end
   end
endgenerate

// Assign Cout based on Crow selection
assign Cout = Co[Crow];


endmodule