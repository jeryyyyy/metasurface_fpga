module weightbiasMemory_fc1#(
parameter DATA_WIDTH = 16,
parameter INPUT_NODES = 120,
parameter OUTPUT_NODES = 1200,
parameter weight_file = "E:/FPGA_Learn/FPGA/Day1211/Weight/weightsdense_1_IEEE.txt",
parameter bias_file = "E:/FPGA_Learn/FPGA/Day1211/Weight/weightsdense_1_IEEE.txt"
)(
input clk,
input rstn,
input weights_en,
input [10:0]output_bias_addr, //表明当前计算的是第几个输出点，一共有1200个
input bias_en,
input [10:0]output_weights_addr,

output reg [DATA_WIDTH*INPUT_NODES-1:0] weights,
output reg weights_output_done,
output reg [DATA_WIDTH*OUTPUT_NODES-1:0] bias
);

	reg [INPUT_NODES*DATA_WIDTH-1:0] weightmemory [0:OUTPUT_NODES-1];
	//这里将weightmemory变一下，将inputnodes数量的定点数放在一行里面变成一个数，那每一行的位宽就是datawidth*input_nodes
	reg [DATA_WIDTH-1:0] biasmemory [0:OUTPUT_NODES-1];

	always@(posedge clk or negedge rstn)
		begin
			if(!rstn)
			begin
				weights <= 0;
				bias <= 0;
			end
			else if(weights_en)begin
					if(0 <= output_weights_addr && output_weights_addr < 1200) begin
						weights <= weightmemory[output_weights_addr];
					end
					else weights <= 0;
			end
			else if(bias_en)begin
					if(0 <= output_bias_addr && output_bias_addr < 1200) begin
						bias <= biasmemory[output_bias_addr];
					end
					else bias <= 0;
			end
		end

	initial begin
		$readmemh(weight_file,weightmemory);
		$readmemh(bias_file,biasmemory);
	end

endmodule

