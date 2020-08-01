`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/28 09:48:11
// Design Name: 
// Module Name: md5_iterative
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`define SALT_A 32'h67452301
`define SALT_B 32'hefcdab89
`define SALT_C 32'h98badcfe
`define SALT_D 32'h10325476

module md5_run(output  [127:0] digest_o=0, output reg valid=0, output reg [127:0] value=0, input clk, rst, input [127:0] message, input new_message);
	reg [1:0] round;
	reg [3:0] phase;
	wire [511:0] padded_message;
	reg [127:0] current_state;
	reg [127:0] digest;
	reg [127:0] digest_o;
	wire [127:0] next_state;
	reg idle;

	always @ (posedge clk) begin
		if( rst ) begin
			round <= 2'd0;
			phase <= 4'd0;
			valid <= 1'b0;
			current_state <= {`SALT_A, `SALT_B, `SALT_C, `SALT_D};
			digest <= 128'd0;
			value <= 128'd0;
			idle <= 1'b1;
		end
		else begin
			if( idle ) begin
				round <= 2'd0;
				phase <= 4'd0;
				current_state <= {`SALT_A, `SALT_B, `SALT_C, `SALT_D};
				idle <= ~new_message;
				if( new_message ) begin
					value <= message;
					valid <= 1'b0;
					digest <= 128'd0;
				end
			end
			else begin
				phase <= phase + 4'd1;
				if( phase == 4'd15 ) begin
					round <= round + 2'd1;
					if( round == 2'd3 ) begin
						valid <= 1'b1;
						digest <= {next_state[127:96]+`SALT_A, next_state[95:64]+`SALT_B,  next_state[63:32]+`SALT_C, next_state[31:0]+`SALT_D};
						idle <= 1'b1;
					end
				end
				current_state <= next_state;
			end
		end
	end

	md5 md50(.round(round), .phase(phase), .message(padded_message), .current_state(current_state), .next_state(next_state));
    always@(posedge clk)
    begin
    if(valid==1)
	 digest_o = {digest[103:96], digest[111:104], digest[119:112], digest[127:120],digest[71:64], digest[79:72], digest[87:80], digest[95:88],digest[39:32], digest[47:40], digest[55:48], digest[63:56],digest[7:0], digest[15:8], digest[23:16], digest[31:24]};
	end

	
	assign padded_message = {
		
		message[71:64], message[79:72], message[87:80], message[95:88],
		message[39:32], message[47:40], message[55:48], message[63:56],
		message[7:0], message[15:8], message[23:16], message[31:24],
		24'd0, 8'h80, {320{1'b0}}, 24'd0, 8'd96, 32'd0}; // Constant 128-bit message
	

	
endmodule

