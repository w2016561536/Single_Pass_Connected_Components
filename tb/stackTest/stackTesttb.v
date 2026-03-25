module stackTesttb (
    
);

reg clk;
reg rst_n;

reg pop;
reg push;

reg [7:0] data_in_src;
reg [7:0] data_in_dst;

wire [7:0] data_out_src;
wire [7:0] data_out_dst;

mergerStack #(
    .LABEL_WIDTH(8),
    .STACK_POINTER_WIDTH(8)
) merger_stack_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in_src(data_in_src),
    .data_out_src(data_out_src),
    .data_in_dst(data_in_dst),
    .data_out_dst(data_out_dst),
    .push(push),
    .pop(pop)
);

initial begin
    clk = 0;
    rst_n = 0;
    push = 0;
    pop = 0;
    data_in_src = 0;
    data_in_dst = 0;

    #20 rst_n = 1; // 20ns后释放复位信号

    #10 push = 1; data_in_src = 8'hAA; data_in_dst = 8'h55; // 第一次推入数据
    #10 push = 0; // 停止推入
    #10 push = 1; data_in_src = 8'hBB; data_in_dst = 8'h66; // 第二次推入数据
    #10 push = 0; // 停止推入
    #10 push = 1; data_in_src = 8'hCC; data_in_dst = 8'h77; // 第二次推入数据
    #10 push = 0; // 停止推入

    #20 push = 0; // 停止推入

    #10 pop = 1; // 第一次弹出数据
    #10 pop = 0; // 停止弹出
    #10 pop = 1; // 第二次弹出数据
    #10 pop = 0; // 停止弹出
    #10 pop = 1; // 第二次弹出数据
    #10 pop = 0; // 停止弹出

     #10 pop = 1; // 第二次弹出数据
    #10 pop = 0; // 停止弹出

     #10 pop = 1; // 第二次弹出数据
    #10 pop = 0; // 停止弹出

    #10 pop = 0; // 停止弹出
    #10 push = 1; data_in_src = 8'hAA; data_in_dst = 8'h55; // 第一次推入数据
    #10 push = 0; // 停止推入
    #10 push = 1; data_in_src = 8'hBB; data_in_dst = 8'h66; // 第二次推入数据
        pop = 1; // 同时弹出数据
    #10 push = 0; // 停止推入
    pop = 0;
    
end

always
begin
    #5 clk = ~clk; // 10ns周期的时钟信号
end
    
endmodule
