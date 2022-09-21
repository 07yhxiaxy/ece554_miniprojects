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

logic signed [15:0] Aout [7:0];
logic signed [15:0] Bout [7:0];
logic signed [15:0] Co [7:0];

// tpumac t1 (.Ain(A), .Bin(B), .Cin(Cin[0]), .Aout(Aout[0]), .Bout(Bout[0]), .Cout(Co[0]), .clk(clk), .en(en), .rst_n(rst_n), .WrEn(WrEn==0));
genvar i, j;
generate
  for (i=0; i < 8; ++i) begin
   for (j=0; j < 8; ++j) begin
      tpumac ti(.Ain(Aout[i]), .Bin(Bout[j]), .Cin(Cin[Crow]), .Aout(Aout[i]), .Bout(Bout[j]), .Cout(Co[i]), .clk(clk), .en(en), .rst_n(rst_n), .WrEn(WrEn==i));
   end // for(i
  end
endgenerate

// Assign Cout based on Crow selection
assign Cout = Co;


endmodule