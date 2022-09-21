// fifo.sv
// Implements delay buffer (fifo)
// On reset all entries are set to 0
// Shift causes fifo to shift out oldest entry to q, shift in d

module fifo
  #(
  parameter DEPTH=8,
  parameter BITS=64
  )
  (
  input clk,rst_n,en,
  input [BITS-1:0] d,
  output [BITS-1:0] q
  );

  logic [2:0] count;

  // your RTL code here
  logic [BITS-1:0] FIFO [DEPTH-1:0];

  assign q = FIFO[count];

  always_ff @(posedge clk, negedge rst_n) begin
    // Initialize counter and fifo buffer to 0s on reset
    if (~rst_n) begin
      count <= 0;
      for(int i = 0; i < $size(FIFO); i++)
        FIFO[i] <= 64'b0;
    end
    // if the fifo is enabled, enq d into the buffer and increment the counter by 1; This is a circular buffer.
    else begin
      if (en) begin
        FIFO[count] <= d;
        count <= count + 1;
      end
    end

  end

endmodule // fifo