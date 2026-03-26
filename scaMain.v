
module scaMain #(
    parameter IMAGE_WIDTH = 320,
    parameter IMAGE_HEIGHT = 240,
    parameter LABEL_WIDTH = 8,
    parameter STACK_POINTER_WIDTH = 8,
    parameter ADDR_WIDTH = 17,
    parameter AERA_BIT_LENGTH = 12
)
(
    input wire clk,
    input wire rst_n,
    
    input wire data_in,
    output reg data_req,
    output wire [ADDR_WIDTH-1:0] pixel_address,
    input wire data_valid,

    output reg scan_finish,
    output reg out_new,
    output reg [AERA_BIT_LENGTH-1:0] area_out,
    output reg [9:0]  x_out,
    output reg [8:0]  y_out,
    output reg [9:0] x_min_out,
    output reg [9:0] x_max_out,
    output reg [8:0] y_min_out,
    output reg [8:0] y_max_out
);

function integer log2(input integer n);
  begin
    log2 = 0;
    while (2 ** log2 < n) log2 = log2 + 1;  // 向上取整
  end
endfunction

(* ramstyle = "M9K, no_rw_check" *)reg [LABEL_WIDTH-1:0] label_merger_table [0:(1<<LABEL_WIDTH)-1]; // 标签合并表
reg [LABEL_WIDTH-1:0] label_merger_table_wr_data_1; // 标签合并表写入数据_1
reg [LABEL_WIDTH-1:0] label_merger_table_wr_addr_1; // 标签合并表写入地址_1
reg label_merger_table_wr_en_1; // 标签合并表写入使能_1

reg [LABEL_WIDTH-1:0] label_merger_table_rd_addr_1; // 标签合并表读取地址_1
reg [LABEL_WIDTH-1:0] label_merger_table_rd_data_1; // 标签合并表读取数据_1
// reg [LABEL_WIDTH-1:0] label_merger_table_rd_addr_2; // 标签合并表读取地址_2
// reg [LABEL_WIDTH-1:0] label_merger_table_rd_data_2; // 标签合并表读取数据_2

always @(posedge clk) begin
    if (label_merger_table_wr_en_1)
    begin
        label_merger_table[label_merger_table_wr_addr_1] <= label_merger_table_wr_data_1;
    end
    label_merger_table_rd_data_1 <= label_merger_table[label_merger_table_rd_addr_1];
end

reg [LABEL_WIDTH-1:0] label_used_counter; // 已使用标签计数器

reg [LABEL_WIDTH:0] data_table_inout_label; // 输入数据对应的标签
// reg [LABEL_WIDTH:0] data_table_inout_label_alt; // 输入数据对应的标签

reg data_table_wr_en; // 数据表写入信号
// reg data_table_wr_en_alt; // 数据表写入信号

localparam x_data_length = (log2(IMAGE_WIDTH + 1) + 1);
localparam y_data_length = (log2(IMAGE_HEIGHT + 1) + 1);

reg [AERA_BIT_LENGTH-1:0] area_wr;
reg [x_data_length-1:0]  x_min_wr;
reg [x_data_length-1:0]  x_max_wr;
reg [y_data_length-1:0]  y_min_wr;
reg [y_data_length-1:0]  y_max_wr;

// reg [AERA_BIT_LENGTH-1:0] area_wr_alt;
// reg [x_data_length-1:0]  x_min_wr_alt;
// reg [x_data_length-1:0]  x_max_wr_alt;
// reg [y_data_length-1:0]  y_min_wr_alt;
// reg [y_data_length-1:0]  y_max_wr_alt;

reg [(AERA_BIT_LENGTH+x_data_length+x_data_length+y_data_length+y_data_length) - 1:0] data_table_out; // 数据表输出，存储面积和边界框信息
// reg [(AERA_BIT_LENGTH+x_data_length+x_data_length+y_data_length+y_data_length) - 1:0] data_table_out_alt; // 数据表输出另一个接头，存储面积和边界框信息

wire [AERA_BIT_LENGTH-1:0] area;
wire [x_data_length-1:0]  x_min;
wire [x_data_length-1:0]  x_max;
wire [y_data_length-1:0]  y_min;
wire [y_data_length-1:0]  y_max;

reg [AERA_BIT_LENGTH-1:0] area_nc;
reg [x_data_length-1:0]  x_min_nc;
reg [x_data_length-1:0]  x_max_nc;
reg [y_data_length-1:0]  y_min_nc;
reg [y_data_length-1:0]  y_max_nc;

// wire [AERA_BIT_LENGTH-1:0] area_alt;
// wire [x_data_length-1:0]  x_min_alt;
// wire [x_data_length-1:0]  x_max_alt;
// wire [y_data_length-1:0]  y_min_alt;
// wire [y_data_length-1:0]  y_max_alt;

(* ramstyle = "M9K, no_rw_check" *)reg [(AERA_BIT_LENGTH+x_data_length+x_data_length+y_data_length+y_data_length) - 1:0] data_table[0:(1<<LABEL_WIDTH)-1]; // 数据表，存储面积和边界框信息

// always @(posedge clk) begin
//     if (data_table_wr_en_alt)
//     begin
//         data_table[data_table_inout_label_alt] <= {area_wr_alt, x_min_wr_alt, x_max_wr_alt, y_min_wr_alt, y_max_wr_alt}; // 将新的面积和边界框信息写入数据表
//     end
//     data_table_out_alt <= data_table[data_table_inout_label_alt]; // 输出当前标签的数据表信息
// end

always @(posedge clk) begin
    if (data_table_wr_en)
    begin
        data_table[data_table_inout_label] <= {area_wr, x_min_wr, x_max_wr, y_min_wr, y_max_wr}; // 将新的面积和边界框信息写入数据表
    end
    data_table_out <= data_table[data_table_inout_label]; // 输出当前标签的数据表信息
end

reg merger_stack_push; // 堆栈推入信号
reg merger_stack_pop; // 堆栈弹出信号
wire [LABEL_WIDTH-1:0] merger_stack_src_data_out; // 堆栈输出数据
reg [LABEL_WIDTH-1:0] merger_stack_src_data_in; // 堆栈输入数据
wire [LABEL_WIDTH-1:0] merger_stack_dst_data_out; // 堆栈输出数据
reg [LABEL_WIDTH-1:0] merger_stack_dst_data_in; // 堆栈输入数据
wire stack_empty; // 堆栈空标志
wire stack_full; // 堆栈满标志

mergerStack #(
    .LABEL_WIDTH(LABEL_WIDTH),
    .STACK_POINTER_WIDTH(STACK_POINTER_WIDTH)
) merger_stack (
    .clk(clk),
    .rst_n(rst_n),
    .data_in_src(merger_stack_src_data_in), // 堆栈输入数据
    .data_out_src(merger_stack_src_data_out), // 堆栈输出数据
    .data_in_dst(merger_stack_dst_data_in), // 堆栈输入数据
    .data_out_dst(merger_stack_dst_data_out), // 堆栈输出数据
    .push(merger_stack_push), // 当数据有效时推入堆栈
    .pop(merger_stack_pop), // 不需要弹出，可以保持为0
    .empty(stack_empty), // 堆栈空标志
    .full(stack_full) // 堆栈满标志
);

reg shift_register_valid; // 移位寄存器加载信号
reg  [LABEL_WIDTH-1:0] shift_register_in; // 移位寄存器输入数据
wire [LABEL_WIDTH-1:0] shift_reg_out_last_row_left;
wire [LABEL_WIDTH-1:0] shift_reg_out_last_row_mid;
wire [LABEL_WIDTH-1:0] shift_reg_out_last_row_right;
wire [LABEL_WIDTH-1:0] shift_reg_out_current_row_last; // 当前行的最后一个数据

shiftRegister #(
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .LABEL_WIDTH(LABEL_WIDTH)
) shift_register (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(shift_register_in),
    .data_valid(shift_register_valid),
    .data_out_last_row_left(shift_reg_out_last_row_left),
    .data_out_last_row_mid(shift_reg_out_last_row_mid),
    .data_out_last_row_right(shift_reg_out_last_row_right),
    .data_out_current_row_left(shift_reg_out_current_row_last)
);


assign {area, x_min, x_max, y_min, y_max} = data_table_out; // 从数据表中获取当前标签的信息
// assign {area_alt, x_min_alt, x_max_alt, y_min_alt, y_max_alt} = data_table_out_alt; // 从数据表中获取当前标签的信息


reg [9:0] image_x;
reg [8:0] image_y;
reg wiping_data;
reg [1:0] ram_delay_counter; // RAM访问延迟计数器

reg [LABEL_WIDTH-1:0] PIC_A; // 标签A
reg [LABEL_WIDTH-1:0] PIC_B; // 标签B
reg [LABEL_WIDTH-1:0] PIC_C; // 标签C
reg [LABEL_WIDTH-1:0] PIC_D; // 标签D

assign pixel_address = image_y * IMAGE_WIDTH + image_x; // 计算当前像素地址

parameter STATE_REQUEST_NEW_PIXEL_AND_FETCT_D = 0;

parameter STATE_PROCESSING_PIXEL = 1;
parameter STATE_WRITE_DATA_DIRECTLY = 2;

parameter STATE_WRITE_DATA_WITH_MERGE = 3;

parameter STATE_NEXT_PIXEL = 4;

parameter STATE_LABEL_READ_SHIFT_REGISTER_A = 5; // 读取移位寄存器的状态
parameter STATE_LABEL_READ_SHIFT_REGISTER_B = 6; // 读取移位寄存器的状态
parameter STATE_LABEL_READ_FETCH_A_START_C = 7; // 读取标签合并表的状态
parameter STATE_LABEL_READ_FETCH_B_START_D = 8; // 读取标签合并表的状态
parameter STATE_LABEL_READ_FETCH_C_START_D = 9; // 读取标签合并表的状态
parameter STATE_WAITING_FOR_DATA_C = 10; // 等待数据表数据返回状态
parameter STATE_CLEAR_MERGED_DATA = 11; // 清除被合并标签的数据状态

parameter STATE_REACH_LINE_END = 12;
parameter STATE_REACH_LINE_END_WAIT_FOR_RAM = 13;
parameter STATE_IMAGE_FINISH = 14;

reg [4:0] state;
always @(posedge clk) begin
    if (!rst_n)
    begin
        state <= STATE_REQUEST_NEW_PIXEL_AND_FETCT_D; // 复位后进入请求新像素状态
        image_x <= 0; // 重置图像坐标
        image_y <= 0; // 重置图像坐标
        data_req <= 0; // 请求输入数据
        wiping_data <= 1; // 启用数据擦除
        label_used_counter <= 0; // 重置已使用标签计数器
        data_table_wr_en <= 0; // 禁止数据表写入
        // data_table_wr_en_alt <= 0; // 禁止数据表写入
        area_wr <= 0; // 重置面积写入值
        x_min_wr <= IMAGE_WIDTH + 1; // 重置边界框写入值
        x_max_wr <= 0; // 重置边界框写入值
        y_min_wr <= IMAGE_HEIGHT + 1; // 重置边界框写入值
        y_max_wr <= 0; // 重置边界框写入值
        shift_register_valid <= 0; // 禁止移位寄存器加载
        shift_register_in <= 0; // 重置移位寄存器输入
        merger_stack_push <= 0; // 禁止堆栈推入
        merger_stack_pop <= 0; // 禁止堆栈弹出
        merger_stack_dst_data_in <= 0; // 重置堆栈输入数据
        ram_delay_counter <= 1;
        data_table_inout_label <= 0; // 重置数据表输入标签
        data_table_inout_label <= 0; // 重置数据表输出标签
        label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
        label_merger_table_wr_addr_1 <= 0; // 标签合并表写入地址
        label_merger_table_wr_data_1 <= 0; // 标签合并表写入数据
        scan_finish <= 0; // 扫描未完成
        out_new <=0;
    end
    else if (wiping_data)
    begin
        // 擦除data_table和label_merger_table
        if (data_table_inout_label < (1<<LABEL_WIDTH))
        begin
            // data_table[data_table_inout_label] <= 0; // 这个数据实际上由area_wr, x_min_wr, x_max_wr, y_min_wr, y_max_wr控制，所以不需要单独擦除
            data_table_wr_en <= 1; // 启用数据表写入
            // data_table_wr_en_alt <= 0; // 禁止数据表写入_alt
            label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
            label_merger_table_wr_addr_1 <= data_table_inout_label; // 标签合并表写入地址
            label_merger_table_wr_data_1 <= 0; // 标签合并表写入数据
            data_table_inout_label <= data_table_inout_label + 1; // 继续擦除下一个标签的数据
            area_wr <= 0; // 重置面积写入值
            x_min_wr <= IMAGE_WIDTH + 1; // 重置边界框写入值
            x_max_wr <= 0; // 重置边界框写入值
            y_min_wr <= IMAGE_HEIGHT + 1; // 重置边界框写入值
            y_max_wr <= 0; // 重置边界框写入值
        end
        else
        begin
            data_table_wr_en <= 0; // 禁止数据表写入
            // data_table_wr_en_alt <= 0; // 禁止数据表写入_alt
            wiping_data <= 0; // 禁止数据擦除
        end
    end
    else
    begin
        case (state)
            STATE_REQUEST_NEW_PIXEL_AND_FETCT_D: begin
                // 获取D的标签
                PIC_D <= label_merger_table_rd_data_1; // 当前像素的D标签
                merger_stack_pop <= 0; // 禁止堆栈弹出
                // 请求新像素
                data_req <= 1; // 请求输入数据
                state <= STATE_PROCESSING_PIXEL; // 进入处理像素状态
            end
            STATE_PROCESSING_PIXEL: begin
                // 处理当前像素
                // 等待像素有效
                if (data_valid)
                begin
                    data_req <= 0; // 停止请求输入数据
                    // 如果输入的为背景，送入标签0，下一个，y = 0或 x = 0 或 x = IMAGE_WIDTH - 1 的像素也送入标签0
                    if (data_in == 0 || image_x == 0 || image_y == 0 || image_x == IMAGE_WIDTH - 1)
                    begin
                        shift_register_valid <= 1; // 启用移位寄存器加载
                        shift_register_in <= 0; // 输入背景标签0
                        state <= STATE_NEXT_PIXEL; // 进入下一个像素状态
                    end
                    else // 如果输入的为前景，进行标签处理
                    begin
                        // 如果B != 0，则直接认为是B
                        if (shift_reg_out_last_row_mid != 0)
                        begin
                            // if (PIC_B != PIC_C && PIC_C !=0)
                            // begin
                            //     $display("error b!=c!!");
                            //     $stop;
                            // end
                            shift_register_valid <= 1; // 启用移位寄存器加载
                            shift_register_in <= PIC_B; // 输入标签(查一次表)
                            // 更新数据表中的面积和边界框信息
                            data_table_inout_label <= PIC_B; // 设置数据表输入标签
                            ram_delay_counter <= 1; // 重置RAM访问延迟计数器
                            state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                        end
                        else
                        begin
                            // 处理B=0的情况
                            // C=0 ，不可能是merge操作
                            if (shift_reg_out_last_row_right == 0)
                            begin
                                // 如果A!=0，认为是A
                                if (shift_reg_out_last_row_left != 0)
                                begin
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= PIC_A; // 设置标签合并表读取地址_1为A标签 
                                    data_table_inout_label <= PIC_A;
                                    ram_delay_counter <= 1;
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                                end
                                else if (shift_reg_out_current_row_last != 0) // 如果D!=0，认为是D
                                begin
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= PIC_D; // 输入标签(查一次表)
                                    data_table_inout_label <= PIC_D;
                                    ram_delay_counter <= 1;
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                                end
                                else // A=B=C=D=0，认为是新标签
                                begin
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= label_used_counter + 1; // 输入新标签(不可以是0)
                                    label_used_counter <= label_used_counter + 1; // 已使用标签计数器加1
                                    data_table_inout_label <= label_used_counter + 1; // 准备读取数据表
                                    ram_delay_counter <= 1; // 等待ram就绪延迟
                                    //label_merger_table[label_used_counter + 1] <= label_used_counter + 1; // 标签合并表中该标签指向自己
                                    label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
                                    label_merger_table_wr_addr_1 <= label_used_counter + 1; // 标签合并表写入地址
                                    label_merger_table_wr_data_1 <= label_used_counter + 1; // 标签合并表写入数据
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                                end
                            end
                            else
                            begin
                                // C 不为0，可能是merge操作，也可能不是
                                // 如果 A=D=0，认为是C
                                if (shift_reg_out_last_row_left == 0 && shift_reg_out_current_row_last == 0)
                                begin
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= PIC_C; // 输入标签(查一次表)
                                    data_table_inout_label <= PIC_C; // 读取对应的data table
                                    ram_delay_counter <= 1; // 重置ram延迟
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态

                                end
                                else
                                if (PIC_C == PIC_A && PIC_D == 0)
                                begin
                                    // C=A D=0，认为是C
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= PIC_C; // 输入标签(查一次表)
                                    data_table_inout_label <= PIC_C; // 读取对应的data table
                                    ram_delay_counter <= 1; // 重置ram延迟
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                                end
                                else if (PIC_C == PIC_D && PIC_A == 0)
                                begin
                                    // C=D A=0，认为是C
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= PIC_C; // 输入标签(查一次表)
                                    data_table_inout_label <= PIC_C; // 读取对应的data table
                                    ram_delay_counter <= 1; // 重置ram延迟
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                                end
                                else if (PIC_C == PIC_A
                                        && PIC_C == PIC_D)
                                begin
                                    // 三个标签相同，说明是同一个区域，不需要合并，直接
                                    shift_register_valid <= 1; // 启用移位寄存器加载
                                    shift_register_in <= PIC_C; // 输入标签(查一次表)
                                    data_table_inout_label <= PIC_C; // 读取对应的data table
                                    ram_delay_counter <= 1; // 重置ram延迟
                                    state <= STATE_WRITE_DATA_DIRECTLY; // 进入写入数据状态
                                end
                                else // 是merge操作, AD不全为0，C不为0
                                begin
                                    // 区分是和谁比
                                    // C != A 且 A != 0 ，找出小的，然后其它归并进去
                                    if (PIC_C != PIC_A && PIC_A != 0)
                                    begin
                                        // 要同时读取A和C对应的LABEL的数据表，规定较小的标签为dst，较大的标签为src(ALT)
                                        if (PIC_C < PIC_A)
                                        begin
                                            data_table_inout_label <= PIC_A; // 读取dst标签的数据表
                                            // data_table_inout_label_alt <= PIC_A; // 读取src标签的数据表
                                            merger_stack_src_data_in <= PIC_A; // src标签入堆栈
                                            merger_stack_dst_data_in <= PIC_C; // dst标签入堆栈
                                            merger_stack_push <= 1; // 推入堆栈
                                            // 写入合并表
                                            // label_merger_table[shift_reg_out_last_row_left] <= PIC_C; // 写入大的小的无所谓，都会去执行解链操作
                                            label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
                                            label_merger_table_wr_addr_1 <= shift_reg_out_last_row_left; // 标签合并表写入地址
                                            label_merger_table_wr_data_1 <= PIC_C; // 标签合并表写入数据
                                            shift_register_valid <= 1; // 启用移位寄存器加载
                                            shift_register_in <= PIC_C; // 输入
                                            state <= STATE_WAITING_FOR_DATA_C; // 进入写入数据并合并状态
                                            ram_delay_counter <= 1; // 重置ram延迟
                                        end
                                        else if (PIC_A < PIC_C)
                                        begin
                                            data_table_inout_label <= PIC_A; // 读取dst标签的数据表
                                            // data_table_inout_label_alt <= PIC_C; // 读取src标签的数据表
                                            // is_c_smaller <= 0;
                                            merger_stack_src_data_in <= PIC_C; // src标签入堆栈
                                            merger_stack_dst_data_in <= PIC_A; // dst标签入堆栈
                                            merger_stack_push <= 1; // 推入堆栈
                                            // 写入合并表
                                            // label_merger_table[shift_reg_out_last_row_right] <= PIC_A; // 写入大的小的无所谓，都会去执行解链操作
                                            label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
                                            label_merger_table_wr_addr_1 <= shift_reg_out_last_row_right; // 标签合并表写入地址
                                            label_merger_table_wr_data_1 <= PIC_A; // 标签合并表写入数据
                                            shift_register_valid <= 1; // 启用移位寄存器加载
                                            shift_register_in <= PIC_A; // 输入
                                            state <= STATE_WAITING_FOR_DATA_C; // 进入写入数据并合并状态
                                            ram_delay_counter <= 1; // 重置ram延迟
                                        end
                                    end
                                    // C != D 且 D != 0 ,找小的
                                    else if (PIC_C != PIC_D && PIC_D != 0)
                                    begin
                                        // 要同时读取D和C对应的LABEL的数据表，规定较小的标签
                                        if (PIC_C < PIC_D)
                                        begin
                                            data_table_inout_label <= PIC_D; // 读取dst标签的数据表
                                            // data_table_inout_label_alt <= PIC_D; // 读取src标签的数据表
                                            merger_stack_src_data_in <= PIC_D; // src标签入堆栈
                                            merger_stack_dst_data_in <= PIC_C; // dst标签入堆栈
                                            merger_stack_push <= 1; // 推入堆栈
                                            // 写入合并表
                                            // label_merger_table[shift_reg_out_current_row_last] <= PIC_C; // 写入大的小的无所谓，都会去执行解链操作
                                            label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
                                            label_merger_table_wr_addr_1 <= shift_reg_out_current_row_last; // 标签合并表写入地址
                                            label_merger_table_wr_data_1 <= PIC_C; // 标签合并表写入数据
                                            shift_register_valid <= 1; // 启用移位寄存器加载
                                            shift_register_in <= PIC_C; // 输入
                                            state <= STATE_WAITING_FOR_DATA_C; // 进入写入数据并合并状态
                                            ram_delay_counter <= 1; // 重置ram延迟
                                        end
                                        else if (PIC_C > PIC_D)
                                        begin
                                            data_table_inout_label <= PIC_D; // 读取dst标签的数据表
                                            // data_table_inout_label_alt <= PIC_C; // 读取src标签的数据表
                                            merger_stack_src_data_in <= PIC_C; // src标签入堆栈
                                            merger_stack_dst_data_in <= PIC_D; // dst标签入堆栈
                                            merger_stack_push <= 1; // 推入堆栈
                                            // 写入合并表
                                            // label_merger_table[shift_reg_out_last_row_right] <= PIC_D; // 写入大的小的无所谓，都会去执行解链操作
                                            label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
                                            label_merger_table_wr_addr_1 <= shift_reg_out_last_row_right; // 标签合并表写入地址
                                            label_merger_table_wr_data_1 <= PIC_D; // 标签合并表写入数据
                                            shift_register_valid <= 1; // 启用移位寄存器加载
                                            shift_register_in <= PIC_D; // 输入
                                            state <= STATE_WAITING_FOR_DATA_C; // 进入写入数据并合并状态
                                            ram_delay_counter <= 1; // 重置ram延迟
                                        end
                                        else
                                        // 理论上此处不可达
                                        begin
                                            // 对仿真器报错
                                            $display("Error: Unexpected case at pixel (%d, %d)", image_x, image_y);
                                            $stop;
                                        end
                                    end
                                    else
                                    // 理论上此处不可达
                                    begin
                                        // 对仿真器报错
                                        $display("Error: Unexpected case at pixel (%d, %d)", image_x, image_y);
                                        $stop;
                                    end
                                end
                            end
                        end
                    end
                end
            end

            STATE_WRITE_DATA_DIRECTLY: 
            begin
                // 关闭shift register加载
                shift_register_valid <= 0; // 禁止移位寄存器加载
                merger_stack_push <= 0; // 禁止堆栈推入
                label_merger_table_wr_en_1 <= 0; // 禁止标签合并表写入
                // 直接写入数据表
                if (ram_delay_counter == 0)
                begin
                    // 更新数据表中的面积和边界框信息
                    area_wr <= area + 1; // 面积加1
                    data_table_inout_label <= data_table_inout_label; // 设置数据表输入标签
                    x_min_wr <= (x_min < image_x) ? x_min : image_x; // 更新x_min
                    x_max_wr <= (x_max > image_x) ? x_max : image_x; // 更新x_max
                    y_min_wr <= (y_min < image_y) ? y_min : image_y; // 更新y_min
                    y_max_wr <= (y_max > image_y) ? y_max : image_y; // 更新y_max
                    data_table_wr_en <= 1; // 启用数据表写入
                    // data_table_wr_en_alt <= 0; // 禁用数据表写入_alt
                    state <= STATE_NEXT_PIXEL; // 进入下一个像素状态
                end
                else
                begin
                    ram_delay_counter <= ram_delay_counter - 1; // RAM访问延迟计数器减1
                end
            end

            STATE_WAITING_FOR_DATA_C:begin
                shift_register_valid <= 0; // 禁止移位寄存器加载
                merger_stack_push <= 0; // 禁止堆栈推入
                label_merger_table_wr_en_1 <= 0; // 禁止标签合并表写入
                if (ram_delay_counter == 0)
                begin
                    // 保存另一个数据到_nc
                    area_nc <= area;
                    x_min_nc <= x_min;
                    x_max_nc <= x_max;
                    y_min_nc <= y_min;
                    y_max_nc <= y_max;
                    // 开始读取C
                    data_table_inout_label <= PIC_C; // 设置数据表输入标签为C
                    ram_delay_counter <= 1; // 重置RAM访问延迟计数器
                    state <= STATE_WRITE_DATA_WITH_MERGE; // 进入写入数据并合并状态
                end
                else
                begin
                    ram_delay_counter <= ram_delay_counter - 1; // RAM访问延迟计数器减1
                end
            end

            STATE_WRITE_DATA_WITH_MERGE:
            begin
                // 关闭shift register加载
                shift_register_valid <= 0; // 禁止移位寄存器加载
                merger_stack_push <= 0; // 禁止堆栈推入
                label_merger_table_wr_en_1 <= 0; // 禁止标签合并表写入
                // 等待内存读出数据表中dst和src标签的数据
                if (ram_delay_counter == 0)
                begin
                    // 执行合并操作
                    data_table_inout_label <= merger_stack_dst_data_out; // 设置数据表输入标签为dst标签
                    data_table_wr_en <= 1; // 启用数据表写入
                    area_wr <= area_nc + area + 1; // 面积相加，加上当前像素
                    x_min_wr <= (x_min_nc < x_min) ? x_min_nc : x_min; // x_min取小
                    x_max_wr <= (x_max_nc > x_max) ? x_max_nc : x_max; // x_max取大
                    y_min_wr <= (y_min_nc < y_min) ? y_min_nc : y_min; // y_min取小
                    if (y_max == y_max_nc) // y_max相等，说明两个区域在同一行，合并后y_max + 1
                    begin
                        y_max_wr <= y_max + 1;
                    end
                    else
                    begin
                        y_max_wr <= (y_max > y_max_nc) ? y_max : y_max_nc;
                    end
                    
                    state <= STATE_CLEAR_MERGED_DATA; // 进入清除旧数据状态
                end
                else
                begin
                    ram_delay_counter <= ram_delay_counter - 1; // RAM访问延迟计数器减1
                end
            end
            
            STATE_CLEAR_MERGED_DATA:
            begin
                data_table_inout_label <= merger_stack_src_data_out; // 设置数据表输入标签为src标签
                data_table_wr_en <= 1; // 启用数据表写入
                area_wr <= 0; // 面积重置为0
                x_min_wr <= IMAGE_WIDTH + 1; // x_min重置
                x_max_wr <= 0; // x_max重置
                y_min_wr <= IMAGE_HEIGHT + 1; // y_min重置
                y_max_wr <= 0; // y_max重置
                state <= STATE_NEXT_PIXEL; // 进入下一个像素状态
            end

            STATE_NEXT_PIXEL: begin
                // 移动到下一个像素
                shift_register_valid <= 0; // 禁止移位寄存器加载
                merger_stack_push <= 0; // 禁止堆栈推入
                data_table_wr_en <= 0; // 禁用数据表写入
                label_merger_table_wr_en_1 <= 0;
                // data_table_wr_en_alt <= 0; // 禁用数据表写入_alt

                if (image_x == IMAGE_WIDTH - 1) // 如果当前像素在行末
                begin
                    image_x <= 0; // 回到行首
                    if (image_y == IMAGE_HEIGHT - 1) // 如果当前像素在图像末尾
                    begin
                        state <= STATE_IMAGE_FINISH; // 进入图像处理完成状态
                        data_table_inout_label <= 0; // 准备输出数据表，从标签0开始
                    end
                    else
                    begin
                        image_y <= image_y + 1; // 移动到下一行
                        ram_delay_counter <= 1;
                        label_merger_table_rd_addr_1 <= merger_stack_dst_data_out; 
                        state <= STATE_REACH_LINE_END; // 进入行末尾状态
                    end
                end
                else
                begin
                    image_x <= image_x + 1; // 移动到下一个像素
                    state <= STATE_LABEL_READ_SHIFT_REGISTER_A; // 进入请求新像素状态
                end
            end
            STATE_REACH_LINE_END: begin
                if (ram_delay_counter > 0)
                begin
                    ram_delay_counter <= ram_delay_counter - 1; // RAM访问延迟计数器减1
                    merger_stack_pop <= 0; // 弹出堆栈
                    label_merger_table_wr_en_1 <= 0; // 启用标签合并表写入
                end
                else
                begin
                    if (!stack_empty) // 如果堆栈不空，继续执行解链条操作
                    begin
                        // 到达行末尾，准备执行解链条操作
                        ram_delay_counter <= 2;
                        // 从堆栈顶取出一个合并操作
                        merger_stack_pop <= 1; // 弹出堆栈
                        // 读取dst和src标签
                        // label_merger_table[merger_stack_src_data_out] <= label_merger_table[merger_stack_dst_data_out]; // 更新合并表，src标签指向dst标签
                        label_merger_table_wr_en_1 <= 1; // 启用标签合并表写入
                        label_merger_table_wr_addr_1 <= merger_stack_src_data_out; // 标签合并表写入地址为src标签
                        label_merger_table_wr_data_1 <= label_merger_table_rd_data_1; // 标签合并表写入数据为dst标签的合并结果
                        state <= STATE_REACH_LINE_END_WAIT_FOR_RAM; // 继续合并
                    end
                    else
                    begin
                        state <= STATE_LABEL_READ_SHIFT_REGISTER_A; // 进入请求新像素状态，图片尾部处理在STATE_NEXT_PIXEL
                    end
                end
            end

            STATE_REACH_LINE_END_WAIT_FOR_RAM: begin
                if (ram_delay_counter > 0)
                begin
                    ram_delay_counter <= ram_delay_counter - 1; // RAM访问延迟计数器减1
                    merger_stack_pop <= 0; // 弹出堆栈
                    label_merger_table_wr_en_1 <= 0; // 启用标签合并表写入
                end
                else
                begin
                    state <= STATE_REACH_LINE_END; // 继续合并
                    label_merger_table_rd_addr_1 <= merger_stack_dst_data_out; // 设置标签合并表读取地址为dst标签，准备执行解链条操作
                    ram_delay_counter <= 1;
                end
            end

            STATE_LABEL_READ_SHIFT_REGISTER_A: begin
                // 这里可以添加一些逻辑来处理读取到的B和C标签，例如将它们存储在寄存器中以供后续使用
                label_merger_table_wr_en_1 <= 0 ;
                merger_stack_pop <= 0; // 弹出堆栈
                label_merger_table_rd_addr_1 <= shift_reg_out_last_row_left; // 设置标签合并表读取地址_1为A标签
                state <= STATE_LABEL_READ_SHIFT_REGISTER_B; // 进入读取A和D标签的状态
            end
            STATE_LABEL_READ_SHIFT_REGISTER_B: begin
                label_merger_table_rd_addr_1 <= shift_reg_out_last_row_mid; // 设置标签合并表读取地址_1为B标签
                state <= STATE_LABEL_READ_FETCH_A_START_C; // 回到等待移位寄存器状态，准备下一次读取
            end
            STATE_LABEL_READ_FETCH_A_START_C: begin
                // 这里可以添加一些逻辑来处理读取到的B和C标签，例如将它们存储在寄存器中以供后续使用
                PIC_A <= label_merger_table_rd_data_1; // A标签
                label_merger_table_rd_addr_1 <= shift_reg_out_last_row_right; // 设置标签合并表读取地址_1为C标签
                state <= STATE_LABEL_READ_FETCH_B_START_D; // 进入读取A和D标签的状态
            end
            STATE_LABEL_READ_FETCH_B_START_D: begin
                // 这里可以添加一些逻辑来处理读取到的A和D标签，例如将它们存储在寄存器中以供后续使用
                PIC_B <= label_merger_table_rd_data_1; // B标签
                label_merger_table_rd_addr_1 <= shift_reg_out_current_row_last; // 设置标签合并表读取地址_1为D标签
                state <= STATE_LABEL_READ_FETCH_C_START_D; // 回到等待移位寄存器状态，准备下一次读取
            end

            STATE_LABEL_READ_FETCH_C_START_D: begin
                PIC_C <= label_merger_table_rd_data_1; // C标签
                state <= STATE_REQUEST_NEW_PIXEL_AND_FETCT_D; // 进入请求新像素状态
            end

            STATE_IMAGE_FINISH: begin
                // 图像处理完成
                // 在端口打印一遍结果，仿真器可以捕获这些输出
                scan_finish <= 1; // 扫描完成
                if (data_table_inout_label < (1<<LABEL_WIDTH )-1)
                begin
                    if (area > 0)
                    begin
                        out_new <= 1;
                        area_out <= area; // 输出面积
                        x_out <= x_min + (x_max - x_min) /2 ; // 输出x_min
                        y_out <= y_min + (y_max - y_min) /2 ; // 输出y_min
                        x_min_out <= x_min; // 输出x_min
                        x_max_out <= x_max; // 输出x_max
                        y_min_out <= y_min; // 输出y_min
                        y_max_out <= y_max; // 输出y_max

                    end
                    else
                    begin
                        out_new <= 0;
                    end
                    data_table_inout_label <= data_table_inout_label + 1; // 输出下一个标签的数据
                end
            end
        endcase
    end
end

always @(posedge clk)
begin
    if (image_x == 126 && image_y == 202 && shift_register_valid)
    begin
        $display("Debug: At pixel (126, 202), shift register input = %d", shift_register_in);
        $stop;
    end
end

always @(posedge clk)
begin
    if (label_used_counter >= (1<<LABEL_WIDTH) - 2)
    begin
        // 对仿真器报错
        $display("Error: Label overflow, used labels = %d", label_used_counter);
        $stop;
    end
end
    
endmodule
