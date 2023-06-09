module fc_1#(
    parameter DATA_WIDTH = 16,
    parameter INPUT_NODES = 120,
    parameter OUTPUT_NODES = 1200
)(
    input clk,
    input rstn,
    input [DATA_WIDTH*INPUT_NODES-1:0]input_fc,
    input [DATA_WIDTH*INPUT_NODES-1:0]input_weights,
    input [DATA_WIDTH*OUTPUT_NODES-1:0]input_bias,
    input fc1_en,

    output reg [DATA_WIDTH*OUTPUT_NODES-1:0]output_fc,
    output reg fc1_nobias_done,
    output reg input_bias_en,
    output reg input_weights_en,
    output reg fc1_done,
    output reg count_weights,
    output reg count_bias
);

    reg [DATA_WIDTH-1:0]output_fc_nobias[OUTPUT_NODES-1:0];
    reg [DATA_WIDTH-1:0]output_fc_nobias_reg;
    reg [DATA_WIDTH-1:0]output_fc_0;
    reg [DATA_WIDTH-1:0]output_fc_1node;
    reg [2:0]state;

    parameter idle          = 3'b100;
    parameter load_weights  = 3'b010;
    parameter load_bias     = 3'b001;

    reg input_fc_0       ;
    reg input_weights_0  ;

    reg count_bias_en;
    reg [2:0]circle;
    reg [DATA_WIDTH-1:0] input_bias_reg;
    reg [OUTPUT_NODES*DATA_WIDTH-1:0] output_fc_reg;

    //例化四个layer电路,一个layer在一个时钟周期内计算一个输出点，有1200个输出点，
    //四个layer则每个layer需要工作300个时钟周期，每个layer计算300个点，共1200个
    layer #(
    .INPUT_NODES(INPUT_NODES),
    .OUTPUT_NODES(OUTPUT_NODES)
    )
    u_layer(
    .clk(clk),
    .rstn(rstn),
    .input_fc(input_fc_0),
    .input_weights(input_weights_0),
    .output_fc(output_fc_0)
    );

    floatAdd16 u_add_bias(
    .floatA(input_bias_reg)  , 
    .floatB(output_fc_nobias_reg)  ,
    .sum   (output_fc_1node)  );


    genvar i;

    always@(posedge clk or negedge rstn)
    begin
        if(!rstn)
        begin
            state <= idle;
        end
        else 
        begin
            if(fc1_en)
                begin
                    case(state)
                        idle:
                            begin
                                input_fc_0        <= 0; 
                                input_weights_0   <= 0;      

                                fc1_nobias_done <= 0;
                                fc1_done <= 0;

                                input_bias_en <= 0;
                                input_weights_en <= 1;//考虑下这个放在load_weights里面还是放在这里？？？
                               
                                state <= load_weights;
                                while (i <= OUTPUT_NODES-1) begin
                                    output_fc_nobias[i] <= 0;
                                end

                            end
                        load_weights:
                            begin
                                if(0 <= count_weights && count_weights < 1200) begin
                                    input_bias_en <= 0;
                                    
                                    //非阻塞赋值加载数据需要多一个时钟周期,这里要注意时序？？？
                                    if(circle == 0)begin
                                        input_fc_0        <= input_fc; 
                                        input_weights_0   <= input_weights;      
                                        circle            <= circle + 1;
                                        count_weights       <= count_weights + 1;
                                        //circle只是用来等时钟的，多出两个
                                    end
                                    else if(circle == 3)begin
                                        output_fc_nobias[count_weights] <= output_fc_0;
                                        //上面在一个时钟里面，需要将inpu_weights传给input_weights_0，input_weights_0再传到u_layer_0里面得到output_fc_0
                                        //output_fc_0最终再传给output_fc_nobias[count_weights]，这中间造成的时钟延迟怎么处理？？？？
                                        count_weights <= count_weights + 1;
                                    end
                                    else circle <= circle + 1;
                                end
                                else if(count_weights == 1200)begin
                                    fc1_nobias_done <= 1;
                                    count_weights <= 0;
                                    input_bias_en <= 1;
                                    state <= load_bias;
                                    input_weights_en <= 0;
                                end
                            end
                        load_bias:
                            begin
                                if(0 <= count_bias && count_bias < 1200) begin
                                    if(circle == 0)begin
                                        output_fc_nobias_reg <= output_fc_nobias[count_bias]; 
                                        input_bias_reg  <= input_bias[count_bias*DATA_WIDTH +:DATA_WIDTH]; 
                                        circle <= circle + 1;     
                                        count_bias <= count_bias + 1;
                                    end
                                    else if(circle == 3)begin
                                        output_fc_reg[count_bias*DATA_WIDTH +:DATA_WIDTH] <=  output_fc_1node;
                                        circle <= 0;
                                    end
                                    else circle <= circle + 1;
                                end
                                else if (count_bias == 1200)begin
                                    output_fc <= output_fc_reg;
                                    count_bias <= 0;
                                    state <= idle;
                                    input_bias_en <= 0;
                                    fc1_done <= 1;
                                end
                            end
                    endcase
                end
        end
    end



        
endmodule