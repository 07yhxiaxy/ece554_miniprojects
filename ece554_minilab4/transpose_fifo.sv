module transpose_fifo  #(
	parameter DEPTH=8,
	parameter BITS=8
)
(
	input clk,rst_n, en, WrEn,
	input [$clog2(DEPTH)-1:0] Arow,
	input [BITS-1:0] Ain [DEPTH-1:0], 
	output [BITS-1:0] Aout [DEPTH-1:0]
);

// Make 8 FIFO modules each has 8 bits * 8 elements to store matrix data which will later be pumped to delayFIFO
logic [BITS-1:0] fifo [DEPTH:0] [DEPTH:0];
// fifo_out are value holders(wires) that direct the output from FIFO to delayFIFO, and d_fifo_out is the value coming out of delay fifo
logic [BITS-1:0] fifo_out [DEPTH-1:0];
logic [BITS-1:0] d_fifo_out [DEPTH-1:0];

// DelayFIFO that holds zeroes to form a rhombus shape for FIFO
// logic [BITS-1:0] delay_fifo [DEPTH-1:0] [DEPTH-1:0];
genvar row;
generate
	for (row=0; row<DEPTH; row++) begin
		fifo delay_fifo(.clk(clk), .rst_n(rst_n), .en(en), .d(fifo_out[row]), .q(d_fifo_out[row]));
		defparam delay_fifo.DEPTH=row+1;  // Don't know if DEPTH=0 works so added 1
		defparam delay_fifo.BITS=BITS;
	end
endgenerate

always @(posedge clk, negedge rst_n) begin
	// Reset the fifo modules on negative reset
	if(!rst_n) begin
		for(integer i = 0; i < DEPTH; i++) begin
			for (integer j = 0; j < DEPTH; j++) begin
				fifo[i][j] <= '0;
			end
		end
	end
	// Parallel write 8 bits data into fifo with corresponding rows at signal WrEn
	else if(WrEn) begin
		for (integer row = 0; row < DEPTH; row++) begin
			if (row == Arow) begin
				fifo[row] <= Ain;
			end
		end
	end
	// If enabled, pipeline the data to delayFIFO which appends zeroes to form rhombus shape.
	else if(en) begin
		for(integer i = 0; i < DEPTH; i++) begin
			// Feeds output from FIFO to delayFIFO
			fifo_out[i] <= fifo[i][DEPTH-1];
			// Ripple the data from the previous element to the next element, basically does what FIFO buffer do.
			for(integer j = 0; j < DEPTH; j++) begin
				fifo[j] <= fifo[j+1];
			end
		end
	end
end

assign Aout = d_fifo_out;

endmodule