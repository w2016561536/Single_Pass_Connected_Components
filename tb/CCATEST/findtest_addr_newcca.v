`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/03 13:57:53
// Design Name: 
// Module Name: findtest
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/29 13:30:07
// Design Name: 
// Module Name: test_c
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


module test_c(

    );
    
    reg clk;
    reg RSTn;
    reg line_pixel_f[76799:0];
    wire line_pixel_in;

    wire [8:0] hexagon_x;
    wire [7:0] hexagon_y;
    wire [8:0] square_x;
    wire [7:0] square_y;
    wire [7:0] circle_y;
    wire [8:0] circle_x;
    wire stop_o;
    
    wire [16:0] pixel_counter;

initial begin
    $readmemb("C:/Users/w2016/Desktop/test.txt",line_pixel_f);
end

assign line_pixel_in = line_pixel_f[pixel_counter];

reg en;
reg data_ack;
wire data_req;

// shape_finder_bram_1cycle shape_finder_ins(
//     .clk(clk),
//     .rst_n(RSTn),
//     .en(en),
//     .data_req(data_req),
//     .data_ack(data_ack),
//     .data_in(line_pixel_in),
//     .analysis_done(stop_o),
//     .hexagon_x(hexagon_x),
//     .circle_x(circle_x),
//     .square_x(square_x),
//     .hexagon_y(hexagon_y),
//     .circle_y(circle_y),
//     .square_y(square_y),
//     .pixel_address(pixel_counter)
// );

scaMain #(
    .IMAGE_WIDTH(320),
    .IMAGE_HEIGHT(240),
    .LABEL_WIDTH(8),
    .STACK_POINTER_WIDTH(8)
) scaMain_inst (
    .clk(clk),
    .rst_n(RSTn),
    // .en(en),
    .data_req(data_req),
    .data_valid(data_ack),
    .pixel_address(pixel_counter),
    .data_in(line_pixel_in)

    // .area_out(area_out),
    // .x_min_out(x_min_out),
    // .x_max_out(x_max_out),
    // .y_min_out(y_min_out),
    // .y_max_out(y_max_out)
);


initial begin                                                  
    clk = 0;
    RSTn=0;
    #100
    RSTn=1;
    #100
    en=1;
end

always begin                                                  
    #10 clk = ~clk;
end       

reg data_req_last;
always @(posedge clk or negedge RSTn) begin
    if (!RSTn) begin
        data_req_last <= 1'b0;
    end else begin
        data_req_last <= data_req;
    end
end
wire data_req_rising_edge = data_req & ~data_req_last;

reg [1:0] work_state;
always @(posedge clk or negedge RSTn) begin
    if (!RSTn) begin
        work_state <= 2'b00;
        data_ack <= 1'b0;
        //pixel_counter <= 32'd2222222222;
    end else begin
        if (data_req_rising_edge )
        begin
            work_state <= 2'b01;
        end
        if (work_state == 2'b01)
        begin
            data_ack <= 1'b1;
            work_state <= 2'b10;
        end
        if (work_state == 2'b10)
        begin
            data_ack <= 1'b0;
            work_state <= 2'b00;
        end

    end
end
    

endmodule
