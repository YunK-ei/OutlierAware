module fpIntMul(
    input logic [15:0] fp,
    input logic [2:0] int3,
    output logic [15:0] out_mul
);

localparam sig_width = 10;
localparam exp_width = 5;
localparam ieee_compliance = 0;

logic [4:0] out_mul_exp2;
logic [4:0] out_mul_exp1;
logic [4:0] out_mul_exp0;

logic [15:0] out_mul_partial2;
logic [15:0] out_mul_partial1;
logic [15:0] out_mul_partial0;

assign out_mul_exp2 = fp [14:10] + 2'b10;
assign out_mul_exp1 = fp [14:10] + 2'b01;
assign out_mul_exp0 = fp [14:10] + 2'b00;

assign out_mul_partial2 = {fp[15], out_mul_exp2, fp[9:0]} & {16{int3[2]}};
assign out_mul_partial1 = {fp[15], out_mul_exp1, fp[9:0]} & {16{int3[1]}};
assign out_mul_partial0 = {fp[15], out_mul_exp0, fp[9:0]} & {16{int3[0]}};

logic [1:0] [7:0] status;
logic [15:0] wire0;

DW_fp_add #(sig_width, exp_width, ieee_compliance)
    U0(
        .a(out_mul_partial2),
        .b(out_mul_partial1),
        .rnd(3'b000),
        .z(wire0),
        .status(status[0])
    );

DW_fp_add #(sig_width, exp_width, ieee_compliance)
    U1(
        .a(wire0),
        .b(out_mul_partial0),
        .rnd(3'b000),
        .z(out_mul),
        .status(status[1])
    );

endmodule