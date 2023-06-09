


module integrationFC#(
parameter DATA_WIDTH = 16,
parameter FC1_INPUT_NODES = 120,
parameter FC1_OUTPUT_NODES = 1200
	)
    (
input clk, 
input rstn,
input start,

output [DATA_WIDTH*FC1_OUTPUT_NODES-1:0]fc1_output
);
///这里应该参考一下其他代码   用状态机来进行状态变化

reg fc1_bias_en;
reg [6:0]output_node_count;

reg fc1_input_weights_en;  
reg fc1_input_bias_en   ;  
reg [10:0]fc1_count_bias      ;  
reg [10:0]fc1_count_weights   ; 
reg [DATA_WIDTH*FC1_INPUT_NODES-1:0]fc1_input_weights   ;
reg [DATA_WIDTH*FC1_OUTPUT_NODES-1:0]fc1_input_bias      ;

reg fc1_en;
reg fc2_en;
reg finish;

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

fc_1 u_fc_1(
    .clk              (clk                  ),
    .rstn             (rstn                 ),
    .input_fc         (fc1_input_fc         ),
    .input_weights    (fc1_input_weights    ),
    .input_bias       (fc1_input_bias       ),
    .fc1_en           (fc1_en               ),

    .output_fc        (fc1_output           ),
    .input_bias_en    (fc1_input_bias_en    ),
    .input_weights_en (fc1_input_weights_en ),
    .fc1_done		  (fc1_done	            ),  
    .count_weights	  (fc1_count_weights    ),  
    .count_bias       (fc1_count_bias       )          
);

//下面用状态机来控制整体的流程
// 总的状态转化为：加载权重数据并且计算fc层-->加载bias并且计算fc+bias （以上这几步在结束时都要给出done信号）
    reg [7:0] state;
    parameter idle         = 8'b10000000;
    parameter fc1          = 8'b01000000;
    parameter fc2          = 8'b00100000;
              

always@(posedge clk or negedge rstn)begin
    if(!rstn) begin
        state <= idle;
    end
    else begin
        case(state)
            idle:
                begin
                    if(start)
                        finish <= 0;
                        fc1_en <= 1;
                        state <= fc1;
                end
            fc1:    
                begin
                    state <= fc2;
                    fc2_en <=1;
                    fc1_en <=0;
                end
        endcase
    end
end


endmodule  