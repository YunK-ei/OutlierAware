module top(clk, rst_n, arrayA, arrayW, psum);
localparam dimm = 64;
// dot product length 64
localparam NUM_LR = 4;
localparam IndexWidth = $clog2(dimm);
input logic [dimm-1:0][15:0] arrayA;
input logic [dimm-1:0][15:0] arrayW;
input logic clk;
input logic rst_n;
output logic [15+$clog2(dimm):0] psum;


logic [dimm-1:0] overflow;
logic [dimm-NUM_LR-1:0] [15:0] InlierSegOut;
logic [NUM_LR-1:0] [15:0] OutlierSegOut;
logic [dimm-1:0] [15:0] x;
logic [dimm-1:0][IndexWidth-1:0] index;

generate
    for(genvar i=0; i<dimm-1; i++) begin
        if(i<NUM_LR) begin
            always_ff@(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    x[i] <= 'b0;
                end else begin
                    x[i] <= OutlierSegOut[i];
                end
            end
        end else begin
            always_ff@(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    x[i] <= 'b0;
                end else begin
                    x[i] <= InlierSegOut[i-NUM_LR];
                end
            end
        end
    end
endgenerate

InlierSeg #(
    .dimm(dimm),
    .NUM_LR(NUM_LR)
)U0_InlierSeg(
    .clk(clk),
    .rst_n(rst_n),
    .arrayA(arrayA),
    .arrayW(arrayW),
    .index(index),
    .InlierSegOut(InlierSegOut),
    .overflow(overflow)
);
OutlierSeg #(
    .dimm(dimm),
    .NUM_LR(NUM_LR)
    )U0_OutlierSeg(
        .clk(clk),
        .rst_n(rst_n),
        .overflow(overflow),
        .arrayA(arrayA),
        .arrayW(arrayW),
        .OutlierSegOut(OutlierSegOut),
        .index(index)
    );
fp_adder_tree #(
    .PIPELINE(6'b000001),
    .DATA_WIDTH(16),
    .LENGTH(64)) U0_adder_tree(
        .clk(clk),
        .rst_n(rst_n),
        .x(x),
        .y(psum)
    );
endmodule