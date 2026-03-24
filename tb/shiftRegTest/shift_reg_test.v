`timescale 1ns / 1ns
module shift_reg_test (
    
);

reg clk;
reg rst_n;
reg [7:0] data_in;
reg data_valid;
wire [7:0] data_out_last_row_left;
wire [7:0] data_out_last_row_mid;
wire [7:0] data_out_last_row_right;

initial begin
    clk = 0;
    rst_n = 0;

    #20 rst_n = 1; // 20ns后释放复位信号
end


always
begin
    #5 clk = ~clk; // 10ns周期的时钟信号
end

always @(posedge clk) begin
    if (!rst_n) begin
        data_in <= 1;
        data_valid <= 1;
    end else begin
        data_valid <= 1; // 数据有效信号始终为1，表示持续输入数据
        data_in <= data_in + 1; // 每个时钟周期输入递增的数据
    end
end

shiftRegister #(
    .IMAGE_WIDTH(20),
    .LABEL_WIDTH(8)
) shift_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .data_valid(data_valid),
    .data_out_last_row_left(data_out_last_row_left),
    .data_out_last_row_mid(data_out_last_row_mid),
    .data_out_last_row_right(data_out_last_row_right)
);



endmodule