module OutlierSeg #(
    parameter dimm = 64,
    parameter NUM_LR = 4,
    parameter IndexWidth = $clog2(dimm)
) (
    input logic clk,
    input logic rst_n,
    input logic [dimm-1:0] overflow,
    //need indexing here
    input logic [15:0] arrayA [dimm],
    input logic [15:0] arrayW [dimm],
    output logic [NUM_LR-1:0][15:0] OutlierSegOut,
    output logic [dimm-1 : 0][IndexWidth-1:0] index
);

localparam sig_width = 10;
localparam exp_width = 5;
localparam ieee_compliance = 1;

logic [NUM_LR-1:0][7:0] status;
// logic [NUM_LR-1 : 0][IndexWidth-1 : 0] index;
// only support dimm=8
LeftmostOutlierSeg #(
    .NUM_LR(NUM_LR)
    )U0_LeftmostOutlierSeg(
        .clk(clk),
        .rst_n(rst_n),
        .overflow(overflow),
        .index(index)
);

generate
    for(genvar i=0; i < NUM_LR; i++) begin
        DW_fp_mult #(sig_width, exp_width, ieee_compliance)
            U0( .a(arrayA[index[i]]),
                .b(arrayW[index[i]]),
                .rnd(3'b000),
                .z(OutlierSegOut[i]),
                .status(status[i])
                );
    end
endgenerate
endmodule