`default_nettype none
//-----------------------------------------------------------------
//--                                                             --
//-- Company:  University of Bonn                                --
//-- Engineer: John Bieling                                      --
//--                                                             --
//-----------------------------------------------------------------
//--                                                             --
//-- Copyright (C) 2015 John Bieling                             --
//--                                                             --
//-- This source file may be used and distributed without        --
//-- restriction provided that this copyright statement is not   --
//-- removed from the file and that any derivative work contains --
//-- the original copyright notice and the associated disclaimer.--
//--                                                             --
//--     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     --
//-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   --
//-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   --
//-- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      --
//-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         --
//-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    --
//-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   --
//-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        --
//-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  --
//-- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  --
//-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  --
//-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         --
//-- POSSIBILITY OF SUCH DAMAGE.                                 --
//--                                                             --
//-----------------------------------------------------------------



//-- The module can be configured with these parameters (defaults given in braces):
//--
//-- shift_bitsize(9) : BRAM needs a 9bit-address, but the desired shift could be
//--                    much less and thus the logic to generate that address
//--                    does not need to handle all 9bits
//--                      
//-- width(1)         : BRAM is 32Bit wide. The width parameter defines how many of them
//--                    should be used parallel to allow shifts of larger patterns

module BRAMSHIFT_512 (d, q, shift, CLK);

	parameter shift_bitsize = 9;
	parameter width = 1;

	parameter input_pipe_steps = 0;
	parameter output_pipe_steps = 0;
	
	output wire [(width*32)-1:0] q;
	input wire [(width*32)-1:0] d;  
	input wire CLK;
	input wire [shift_bitsize-1:0] shift;

	reg [shift_bitsize-1:0] a_read;
	reg [shift_bitsize-1:0] a_write;
	reg [shift_bitsize-1:0] true_shift;

	wire [(width*32)-1:0] sigin;  
	datapipe #(.data_width(width*32),.pipe_steps(input_pipe_steps)) input_pipe ( 
	   .data(d), 
	   .piped_data(sigin),
	   .CLK(CLK));

	wire [(width*32)-1:0] sigout;
	datapipe #(.data_width(width*32),.pipe_steps(output_pipe_steps)) output_pipe ( 
	   .data(sigout), 				
	   .piped_data(q),
	   .CLK(CLK));

	always@(posedge CLK) 
	begin
		true_shift <= shift + 2; //compensate internal delays, shift is usually tigged
		a_read <= a_read + 1;
		a_write <= a_read + true_shift;
	end

	genvar k;
	generate
	 for (k=0; k < width; k=k+1) begin : BRAMS

		RAMB16_S36_S36 #(
			.INIT_A(36'h000000000),  // Value of output RAM registers on Port A at startup
			.INIT_B(36'h000000000),  // Value of output RAM registers on Port B at startup
			.SRVAL_A(36'h000000000), // Port A output value upon SSR assertion
			.SRVAL_B(36'h000000000), // Port B output value upon SSR assertion
			.WRITE_MODE_A("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
			.WRITE_MODE_B("WRITE_FIRST"), // WRITE_FIRST, READ_FIRST or NO_CHANGE
			.SIM_COLLISION_CHECK("ALL"),  // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 

			// The following INIT_xx declarations specify the initial contents of the RAM
			// Address 0 to 127
			.INIT_00(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_01(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_02(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_03(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_04(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_05(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_06(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_07(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_08(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_09(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_0A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_0B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_0C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_0D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_0E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_0F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			// Address 128 to 255
			.INIT_10(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_11(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_12(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_13(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_14(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_15(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_16(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_17(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_18(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_19(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_1A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_1B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_1C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_1D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_1E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_1F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			// Address 256 to 383
			.INIT_20(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_21(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_22(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_23(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_24(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_25(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_26(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_27(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_28(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_29(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_2A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_2B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_2C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_2D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_2E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_2F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			// Address 384 to 511
			.INIT_30(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_31(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_32(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_33(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_34(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_35(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_36(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_37(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_38(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_39(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_3A(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_3B(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_3C(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_3D(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_3E(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),
			.INIT_3F(256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000),

			// The next set of INITP_xx are for the parity bits
			// Address 0 to 127
			.INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
			.INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
			// Address 128 to 255
			.INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
			.INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
			// Address 256 to 383
			.INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
			.INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
			// Address 384 to 511
			.INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
			.INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000)
		) RAMB32_SHIFT (
			.DOA(sigout[((k+1)*32)-1:(k*32)]),      // Port A 32-bit Data Output
			.DOB(),      // Port B 32-bit Data Output
			.ADDRA({'b0,a_read}),  // Port A 9-bit Address Input
			.ADDRB({'b0,a_write}),  // Port B 9-bit Address Input
			.CLKA(CLK),    // Port A Clock
			.CLKB(CLK),    // Port B Clock
			.DIA('b0),      // Port A 32-bit Data Input
			.DIB(sigin[((k+1)*32)-1:(k*32)]),      // Port B 32-bit Data Input

			.DOPA(),    // Port A 4-bit Parity Output
			.DOPB(),    // Port B 4-bit Parity Output
			.DIPA('b0),    // Port A 4-bit parity Input
			.DIPB('b0),    // Port-B 4-bit parity Input

			.ENA(1'b1),      // Port A RAM Enable Input
			.ENB(1'b1),      // Port B RAM Enable Input
			.SSRA(1'b0),    // Port A Synchronous Set/Reset Input
			.SSRB(1'b0),    // Port B Synchronous Set/Reset Input

			.WEA(1'b0),      // Port A Write Enable Input
			.WEB(1'b1)       // Port B Write Enable Input
		);
	 end
	endgenerate
				
endmodule