module shiftRegister #(
    parameter IMAGE_WIDTH = 320,
    parameter LABEL_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [LABEL_WIDTH-1:0]  data_in,
    input wire data_valid,
    output wire [LABEL_WIDTH-1:0] data_out_last_row_left,
    output wire [LABEL_WIDTH-1:0] data_out_last_row_mid,
    output wire [LABEL_WIDTH-1:0] data_out_last_row_right,
    output wire [LABEL_WIDTH-1:0] data_out_current_row_left
);

function integer log2(input integer n);
  begin
    log2 = 0;
    while (2 ** log2 < n) log2 = log2 + 1;  // 向上取整
  end
endfunction

// shift register RAM Based
reg [LABEL_WIDTH-1:0] shift_reg [0:IMAGE_WIDTH-3];

reg [LABEL_WIDTH-1:0] current_row_left;
reg [LABEL_WIDTH-1:0] last_row_left;
reg [LABEL_WIDTH-1:0] last_row_mid;
reg [LABEL_WIDTH-1:0] last_row_right;


reg [log2(IMAGE_WIDTH-2)-1:0] write_ptr; // 写指针

always @(posedge clk) begin
    if (!rst_n) begin
        write_ptr <= 0;
    end 
    else 
    begin
        if (data_valid) 
        begin
            // 更新当前行的左边像素
            current_row_left <= data_in;

            // 更新上一行的像素
            last_row_left <= last_row_mid;
            last_row_mid <= last_row_right;
            last_row_right <= shift_reg[write_ptr];

            // 将当前输入数据写入shift register
            shift_reg[write_ptr] <= data_in;
            // 更新写指针
            if (write_ptr == IMAGE_WIDTH - 3) 
            begin
                write_ptr <= 0; // 回绕
            end
            else
            begin
                write_ptr <= write_ptr + 1;
            end
        end
    end
end

assign data_out_last_row_left = last_row_left;
assign data_out_last_row_mid = last_row_mid;
assign data_out_last_row_right = last_row_right;
assign data_out_current_row_left = current_row_left;


endmodule
