`timescale 1 ns / 10 ps

module weightMemroy_TB();

reg clk;
reg [6:0] address;
wire [32*32-1:0] weights;

localparam PERIOD = 100;

always
	#(PERIOD/2) clk = ~clk;

always@(posedge clk or negedge rstn)begin
	if(!rstn)begin
		fc1_input_weights_en <= 0;
	end
	else if(0 <= count_weights && count_weights < 1200)begin
		fc1_input_weights_en <= 1;
	end
	else if(count_weights == 1200)begin
		fc1_input_weights_en <= 1;
	end
end

always@(posedge clk or negedge rstn)begin
	if(!rstn)begin
		fc1_count_bias <= 0;
	end
	else if(0 <= fc1_count_bias && fc1_count_bias < 1200)begin
		input_bias_en <= 0;
	end
	else if(fc1_count_bias == 1200)begin
		input_bias_en <= 1;
	end
end





initial begin
	#0
	clk = 1'b0;
	rstn = 0;

	address = 0;

	#PERIOD
	address = 1;

	#PERIOD 
	address = 2;

	#PERIOD
	address = 32;

	#PERIOD
	$stop;
end



weightbiasMemory_fc1 u_weightMemory_fc1(
    .clk                        (clk                     ),
    .rstn                       (rstn                    ),
    .weights_en                 (fc1_input_weights_en    ),
    .bias_en                    (fc1_input_bias_en       ),  
    .output_bias_addr           (fc1_count_bias          ),
    .output_weights_addr        (fc1_count_weights       ),

    .weights                    (fc1_input_weights       ),
    .bias                       (fc1_input_bias          )
);


endmodule
