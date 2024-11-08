//the adder_tree only support LENGTH = 2**N, input port same bit width(any)
module fp_adder_tree #(
    parameter PIPELINE = 6'b000001,
    parameter DATA_WIDTH = 32,
    parameter LENGTH = 64
) (
    input  logic clk,
    input  logic rst_n,
    //1. [dimm0-1 : 0][dimm1-1 : 0] x ##x for packed array
    //2. [bit_width-1 : 0] x [dimm]  ##x for reg files with mux ahead to support indexing
    input  logic [LENGTH-1 : 0][DATA_WIDTH-1:0] x,
    output logic [DATA_WIDTH + $clog2(LENGTH)-1:0] y
);
// localparam OUT_WIDTH = DATA_WIDTH + $clog2(LENGTH);

// local parameters
localparam NUM_LAYERS = $clog2(LENGTH);
localparam [NUM_LAYERS-1:0] ADD_REG = PIPELINE;
localparam sig_width = 10;
localparam exp_width = 5;
localparam ieee_compliance = 0;
// adder tree
generate
    for (genvar i = 0; i < NUM_LAYERS; i = i+1) begin: tree
        localparam NODE_N = LENGTH / (2**(i+1));
        localparam NODE_W = DATA_WIDTH;
        logic [NODE_N-1:0][NODE_W-1:0] node;
        logic [NODE_N-1:0][NODE_W-1:0] node_d;
        // adder
        if (i == 0) begin
            for (genvar j = 0; j < NODE_N; j = j+1) begin
                // DW_fp_add #(
                //     sig_width, exp_width, ieee_compliance
                // ) U0(
                //     .a(x[2*j]),
                //     .b(x[2*j+1]),
                //     .rnd(3'b000),
                //     .z(node[j]),
                //     .status()
                // );
                assign node[j] = signed'(x[2*j]) + signed'(x[2*j+1]);
            end
        end else begin
            for (genvar j = 0; j < NODE_N; j = j+1) begin
                // DW_fp_add #(
                //     sig_width, exp_width, ieee_compliance
                // ) U1(
                //     .a(tree[i-1].node_d[2*j]),
                //     .b(tree[i-1].node_d[2*j+1]),
                //     .rnd(3'b000),
                //     .z(node[j]),
                //     .status()
                // );
                assign node[j] = signed'(tree[i-1].node_d[2*j]) + signed'(tree[i-1].node_d[2*j+1]);
            end
        end
        // pipe
        if (ADD_REG[i]) begin
            for(genvar j = 0; j < NODE_N; j = j+1) begin
            always_ff @( posedge clk or negedge rst_n ) begin
                if (!rst_n) begin
                    node_d[j] <= '0;
                end else begin
                    node_d[j] <= node[j];
                end
            end
            end
        end
        else begin
            assign node_d = node;
        end
    end
endgenerate

// drive I/O
assign y = tree[NUM_LAYERS - 1].node_d;

endmodule