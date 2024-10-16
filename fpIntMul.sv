module fpIntMul(
    input  logic [15:0] fp,
    input  logic [2:0]  int3,
    output logic [15:0] out_mul
);
    // * Internal Logics
    logic [2:0] fpSign;
    logic [2:0][5-1:0] fpExp;
    logic [2:0][10-1:0] fpFrac;
    logic [15:0] out_mul_w;

    // * Split
    assign fpSign[0] = fp[15];
    assign fpSign[1] = fp[15];
    assign fpSign[2] = fp[15] ^ int3[2];
    assign fpExp[0]  = int3[0] ? fp[14:10] : 0;
    assign fpExp[1]  = int3[1] ? (fp[14:10] + 1) : 0;
    assign fpExp[2]  = int3[2] ? (fp[14:10] + 2) : 0;
    assign fpFrac[0] = fp[9:0];
    assign fpFrac[1] = fp[9:0];
    assign fpFrac[2] = fp[9:0];

    // * Mult
    DW_fp_sum3 #(
        .sig_width          ( 10    ),
        .exp_width          (  5    ),
        .ieee_compliance    (  0    ),
        .arch_type          (  0    )
    ) u_fp_sum3 (
        .a  ({fpSign[0],fpExp[0],fpFrac[0]}),
        .b  ({fpSign[1],fpExp[1],fpFrac[1]}),
        .c  ({fpSign[2],fpExp[2],fpFrac[2]}),
        .rnd( 3'b000                       ),
        .z  ( out_mul                      )
    );

endmodule


module fpIntMulSum3(
    input  logic [15:0] fp,
    input  logic [2:0]  int3,
    output logic [15:0] out_mul
);
    // * Internal Logics
    logic [2:0] fpSign;
    logic [2:0][5-1:0] fpExp;
    logic [2:0][10-1:0] fpFrac;
    logic [15:0] out_mul_w;

    // * Split
    assign fpSign[0] = fp[15];
    assign fpSign[1] = fp[15];
    assign fpSign[2] = fp[15] ^ int3[2];
    assign fpExp[0]  = int3[0] ? fp[14:10] : 0;
    assign fpExp[1]  = int3[1] ? (fp[14:10] + 1) : 0;
    assign fpExp[2]  = int3[2] ? (fp[14:10] + 2) : 0;
    assign fpFrac[0] = fp[9:0];
    assign fpFrac[1] = fp[9:0];
    assign fpFrac[2] = fp[9:0];

    // * Mult
    DW_fp_sum3 #(
        .sig_width          ( 10    ),
        .exp_width          (  5    ),
        .ieee_compliance    (  0    ),
        .arch_type          (  0    )
    ) u_fp_sum3 (
        .a  ({fpSign[0],fpExp[0],fpFrac[0]}),
        .b  ({fpSign[1],fpExp[1],fpFrac[1]}),
        .c  ({fpSign[2],fpExp[2],fpFrac[2]}),
        .rnd( 3'b000                       ),
        .z  ( out_mul                      )
    );

endmodule