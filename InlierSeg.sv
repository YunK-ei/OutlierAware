module InlierSeg #(
    // NUM_PE = 64
    parameter dimm = 64,
    //NUM_LR for the num of overflow in dimm fp2ints
    parameter NUM_LR = 4,
    parameter IndexWidth = $clog2(dimm)
) (
    input logic clk,
    input logic rst_n,
    input logic [dimm-1:0][15:0] arrayA,
    input logic [dimm-1:0][15:0] arrayW,
    input logic [dimm-1:0][IndexWidth-1:0] index,
    output logic [dimm-NUM_LR-1:0][15:0] InlierSegOut,
    output logic [dimm-1:0]overflow
);
localparam sig_width = 10;
localparam exp_width = 5;
localparam isize = 3;
localparam ieee_compliance = 0;

wire [dimm-1:0][7:0] status;
wire [dimm-1:0][2:0] arrayAint;

generate
    for(genvar i=0; i<dimm; i++) begin
        assign overflow[i] = status[i][0];
    end
endgenerate

generate
    for(genvar i=0; i < dimm; i++) begin:U0_DW_fp_i2flt
        DW_fp_flt2i #(sig_width, exp_width, isize, ieee_compliance)
            U0(
                .a(arrayA[i]),
                .rnd(3'b000),
                .z(arrayAint[i]),
                .status(status[i])
            );
    end
endgenerate


generate
    for(genvar i=0; i < dimm-NUM_LR; i++) begin
        fpIntMul U0_fpIntMul(
            .clk(clk),
            .rst_n(rst_n),
            .fp(arrayW[index[i+NUM_LR]]),
            .int3(arrayAint[index[i+NUM_LR]]),
            .out_mul(InlierSegOut[i])
        );
    end
endgenerate

endmodule