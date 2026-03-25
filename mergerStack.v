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

(* ramstyle = "M9K, no_rw_check" *)reg [2*(LABEL_WIDTH)-1:0] stack_src_dst [0:DEPTH-1];

reg [STACK_POINTER_WIDTH-1:0] top;

assign empty = (top == 0);
assign full  = (top == DEPTH-1);  // 保持你原来的语义，不改行为

always @(posedge clk) begin
    if (!rst_n) begin
        top          <= {STACK_POINTER_WIDTH{1'b0}};
    end else begin
        // ---------------------------------
        // 写 RAM
        // ---------------------------------
        // if (push && pop && !empty) begin
        //     stack_src[top - 1'b1] <= data_in_src;
        //     stack_dst[top - 1'b1] <= data_in_dst;
        // end
        // else 
        if (push && !full) begin
            // stack_src[top] <= data_in_src;
            // stack_dst[top] <= data_in_dst;
            stack_src_dst[top] <= {data_in_src, data_in_dst};
            top <= top + 1'b1;
        end
        else if (pop && !empty) begin
            top <= top - 1'b1;
        end

        // data_out_src <= stack_src[top - 1];
        // data_out_dst <= stack_dst[top - 1];
        {data_out_src, data_out_dst} <= stack_src_dst[top - 1];
        
    end
end


endmodule
