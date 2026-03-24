module mergerStack #(
    parameter LABEL_WIDTH = 8,
    parameter STACK_POINTER_WIDTH = 8
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire [LABEL_WIDTH-1:0]       data_in_src,
    output reg  [LABEL_WIDTH-1:0]       data_out_src,

    input  wire [LABEL_WIDTH-1:0]       data_in_dst,
    output reg  [LABEL_WIDTH-1:0]       data_out_dst,
    input  wire                         push,
    input  wire                         pop,
    output wire                         empty,
    output wire                         full
);

localparam DEPTH = (1 << STACK_POINTER_WIDTH);

(* ramstyle = "M9K, no_rw_check" *)reg [LABEL_WIDTH-1:0] stack_src [0:DEPTH-1];
(* ramstyle = "M9K, no_rw_check" *)reg [LABEL_WIDTH-1:0] stack_dst [0:DEPTH-1];

reg [STACK_POINTER_WIDTH-1:0] top;

// 独立的读地址寄存器
reg [STACK_POINTER_WIDTH-1:0] rd_addr;

// RAM 同步输出寄存器
reg [LABEL_WIDTH-1:0] ram_q_src;
reg [LABEL_WIDTH-1:0] ram_q_dst;

assign empty = (top == 0);
assign full  = (top == DEPTH-1);  // 保持你原来的语义，不改行为

always @(posedge clk) begin
    if (!rst_n) begin
        // 标准同步读模板
        ram_q_src <= {LABEL_WIDTH{1'b0}};
        ram_q_dst <= {LABEL_WIDTH{1'b0}};
    end else begin
        ram_q_src <= stack_src[rd_addr];
        ram_q_dst <= stack_dst[rd_addr];
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        top          <= {STACK_POINTER_WIDTH{1'b0}};
        rd_addr      <= {STACK_POINTER_WIDTH{1'b0}};
        data_out_src <= {LABEL_WIDTH{1'b0}};
        data_out_dst <= {LABEL_WIDTH{1'b0}};
    end else begin
        // ---------------------------------
        // 写 RAM
        // ---------------------------------
        if (push && pop && !empty) begin
            stack_src[top - 1'b1] <= data_in_src;
            stack_dst[top - 1'b1] <= data_in_dst;
        end
        else if (push && !full) begin
            stack_src[top] <= data_in_src;
            stack_dst[top] <= data_in_dst;
            top <= top + 1'b1;
        end
        else if (pop && !empty) begin
            top <= top - 1'b1;
        end

        // ---------------------------------
        // 生成下一拍读地址
        // ---------------------------------
        if (push && !full) begin
            // push 后逻辑上栈顶是新数据，但这里仍保留旁路输出，不靠 RAM 立刻读出
            rd_addr <= top;
        end
        else if (!empty && pop && (top > 1)) begin
            rd_addr <= top - 2'd2;
        end
        else if (!empty) begin
            rd_addr <= top - 1'b1;
        end
        else begin
            rd_addr <= {STACK_POINTER_WIDTH{1'b0}};
        end

        // ---------------------------------
        // 输出保持原语义
        // ---------------------------------
        if (push && !full) begin
            // 保持你原来的“push 时立刻输出输入数据”语义
            data_out_src <= data_in_src;
            data_out_dst <= data_in_dst;
        end
        else if (!empty && pop && (top > 1)) begin
            // 这里拿上一拍同步读出来的数据
            data_out_src <= ram_q_src;
            data_out_dst <= ram_q_dst;
        end
        else if (!empty) begin
            data_out_src <= ram_q_src;
            data_out_dst <= ram_q_dst;
        end
        else begin
            data_out_src <= {LABEL_WIDTH{1'b0}};
            data_out_dst <= {LABEL_WIDTH{1'b0}};
        end
    end
end

endmodule
