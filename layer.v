
module layer#(
parameter DATA_WIDTH = 16,
parameter INPUT_NODES = 120,
parameter OUTPUT_NODES = 1200
)(
input clk, reset,
input [DATA_WIDTH*INPUT_NODES-1:0] input_fc, 
//  每个周期输入input_nodes个数据，需要output个周期才能输入完成
input [DATA_WIDTH*INPUT_NODES-1:0] input_weights,
output [DATA_WIDTH-1:0] output_fc
);

genvar i;
//如果按照这种循环，那么就需要每个输入周期输入不同的数值
//还有个问题，这没有时钟周期？？没有always语句块？？？？
generate
	for (i = 0; i < INPUT_NODES; i = i + 1) begin  
		 //这里我觉得应该是 i<input_nodes，在这个循环里面做PE乘加运算，每做完一轮循环就得到一个输出点
		 //在这个循环外面再套一个j<output_nodes的大循环，做完外面的大循环就得到了数量为output_nodes的输出点
		processingElement PE 
		(
			.clk(clk),
			.reset(reset),
			.floatA(input_fc[DATA_WIDTH*i+:DATA_WIDTH]),
			.floatB(input_weights[DATA_WIDTH*i+:DATA_WIDTH]),
			.result(output_fc)
		);
	end
endgenerate


endmodule
