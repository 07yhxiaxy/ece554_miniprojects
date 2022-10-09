module tpuv1
  #(
    parameter BITS_AB=8,
    parameter BITS_C=16,
    parameter DIM=8,
    parameter ADDRW=16,
    parameter DATAW=64
    )
   (
    input clk, rst_n, r_w, // r_w=0 read, =1 write
    input [DATAW-1:0] dataIn,
    output [DATAW-1:0] dataOut,
    input [ADDRW-1:0] addr
   );

   logic signed [BITS_AB-1:0] bytes [DIM-1:0];
   logic signed [BITS_C-1:0] halfwords [3:0];

   // A/B are byte, C is halfword or 16b each
   assign bytes = { dataIn[63:56], dataIn[55:48], dataIn[47:40], dataIn[39:32], dataIn[31:24], dataIn[23:16], dataIn[15:8], dataIn[7:0] };
   assign halfwords = { dataIn[63:48], dataIn[46:32], dataIn[31:16], dataIn[15:0] };

   logic writeA, writeB, writeC, matMul;

   assign writeA = ((addr[11:8] === 4'h1) & r_w) ? 1'b1 : 1'b0; // 0x0100 – 0x013f
   assign writeB = ((addr[11:8] === 4'h2) & r_w) ? 1'b1 : 1'b0; // 0x0200 – 0x023f
   

   logic signed [BITS_AB-1:0] Aout [DIM-1:0];
   logic signed [BITS_AB-1:0] Bout [DIM-1:0];
   logic signed [BITS_C-1:0] Cout [DIM-1:0];

   logic [2:0] Arow;
   logic [7:0] Arow_cast;
   assign Arow_cast = addr[7:0]>>3;
   assign Arow = Arow_cast[2:0];

   logic signed [BITS_C-1:0] Cin [DIM-1:0];
   //logic signed [BITS_C-1:0] Cin1 [(DIM/2) - 1:0];
   //logic signed [BITS_C-1:0] Cin2 [(DIM/2) - 1:0];

   //assign Cin = {Cin1, Cin2};

   logic firstHalf;
   assign dataOut = ~(firstHalf) ? {Cout[3], Cout[2], Cout[1], Cout[0]} : {Cout[7], Cout[6], Cout[5], Cout[4]};

   //logic [7:0] Crow_cast;
   logic [2:0] Crow;
   assign Crow = addr[6:4];

   systolic_array #(BITS_AB, BITS_C, DIM) iDUT1(
    // input
    .clk(clk), .rst_n(rst_n), .WrEn(writeC), .en(matMul),
    .A(Aout), .B(Bout), .Cin(Cin), .Crow(Crow),
    // output
    .Cout(Cout)
    );

   memA #(BITS_AB, DIM) iDUT2(
    // input
    .clk(clk), .rst_n(rst_n), .en(matMul), .WrEn(writeA), .Ain(bytes), .Arow(Arow),
    // output
    .Aout(Aout)
   );
	 
	logic signed [BITS_AB-1:0] zerosArray [DIM-1:0]; // reg zeros
	genvar row;
	generate
		for (row = 0; row < DIM; row++) begin
			// Prepare the values
			assign zerosArray[row] = '0;
			
		end
	endgenerate
	
	logic signed [BITS_AB-1:0]Bin_selected [DIM-1:0]; // selected Bin
	
	assign Bin_selected = writeB ? bytes : zerosArray; // memB has no write enable (en always writes)
	
   memB #(BITS_AB, DIM) iDUT3(
    // input
    .clk(clk), .rst_n(rst_n), .en(writeB | matMul), .Bin(Bin_selected),
    // output
    .Bout(Bout)
   );

  logic [4:0] count;
  logic firstCycle;

  enum logic [1:0] {START=2'b00, MULTIPLY=2'b01, WRITEC=2'b10, READC=2'b11} state;

  always_ff @( posedge clk, negedge rst_n ) begin

    if(~rst_n) begin
      state <= START;
      //Crow <= '0;
      firstCycle <= '0;
      matMul <= '0;
      count <= '0;
      firstHalf <= '1;
    end

    else begin
      case(state)
				START: begin
          // Crow <= addr[6:4];
          writeC <= 1'b0;

          if((addr == 16'h0400) & r_w) begin
            matMul <= 1'b1; // start shift
            count <= 0;
            state <= MULTIPLY;
          end

          else if(addr[11:8] == 4'h3) begin
            if(r_w) begin
              firstCycle <= 1;
              state <= WRITEC;
            end
            else begin
              firstHalf <= 1'b1;
              state <= READC; 
            end
          end

        end
				MULTIPLY: begin
					// counter - waits 22 cycles to finish shifting
					if(count < 22)
						count <= count + 1;

					else begin
						matMul <= 1'b0; // end shift
						state <= START;
					end

				end

				WRITEC: begin
					if(firstCycle) begin
						Cin <= {Cout[7], Cout[6], Cout[5], Cout[4], halfwords[3], halfwords[2], halfwords[1], halfwords[0]};
						//Crow <= addr[7:0]>>4; // TODO: might not work
						firstCycle <= 1'b0;
					end
					else begin
						Cin <= {halfwords[3], halfwords[2], halfwords[1], halfwords[0], Cout[3], Cout[2], Cout[1], Cout[0]}; // first half of array
						writeC <= 1'b1;
						state <= START;
					end
				end

				READC: begin
					if(firstHalf) begin
						firstHalf <= 1'b0;
						state <= START;
					end
				end
      endcase
    end
    
   end

endmodule