`timescale 100 ns / 10 ps

module processingElement16(clk,rstn,floatA,floatB,result);

parameter DATA_WIDTH = 16;

input clk, rstn;
input [DATA_WIDTH-1:0] floatA, floatB;
output reg [DATA_WIDTH-1:0] result;

wire [DATA_WIDTH-1:0] multResult;
wire [DATA_WIDTH-1:0] addResult;

floatMult16 FM (floatA,floatB,multResult);
floatAdd16 FADD (multResult,result,addResult);

always @ (posedge clk or negedge rstn) begin
	if (rstn == 1'b1) begin
		result <= 0;
	end else begin
		result <= addResult;
	end
end

endmodule
