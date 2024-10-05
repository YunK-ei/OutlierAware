module LeftmostOutlierSeg #(
    parameter NUM_LR = 4,
    //only support dimm=8 now
    parameter dimm = 64,
    parameter IndexWidth = $clog2(dimm)
)(
    input logic clk,
    input logic rst_n,
    // input logic ready,
    input logic [dimm-1 : 0] overflow,
    output logic [NUM_LR-1 : 0][IndexWidth-1 : 0] index
    // output logic valid
);

// ###################### pipeline detect use leading zero detector #####################
// // `include "DW_lzd_function.inc"

// logic [dimm-1:0] DWF_lzd_in;
// logic [dimm-1:0] DWF_lzd_feedback;
// logic [dimm-1:0] overflow_reg;

// logic ready_d1, ready_d2, ready_d3;

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         ready_d1 <= 'b0;
//         ready_d2 <= 'b0;
//         ready_d3 <= 'b0;
//         valid <= 'b0;
//     end
//     else begin
//         ready_d1 <= ready;
//         ready_d2 <= ready_d1;
//         ready_d3 <= ready_d2;
//         valid <= ready_d3;
//     end
// end

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         overflow_reg <= 'b0;
//     end
//     else if(ready) begin
//         overflow_reg <= overflow;
//     end
//     else begin
//         overflow_reg <= overflow_reg;
//     end
// end

// assign dec_func = DWF_lzd(DWF_lzd_in);
// assign enc_func = DWF_lzd_enc(DWF_lzd_in);

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         DWF_lzd_in <= 'b0;
//     end
//     else begin
//         if(ready) begin
//             DWF_lzd_in <= overflow;
//         end
//         else begin
//             DWF_lzd_in <= DWF_lzd_feedback;
//         end
//     end
// end

// always_comb begin
//     case(enc_func)
//         4'b1111:
//             DWF_lzd_feedback = overflow_reg & 8'b0000_0000;
//         4'b0000:
//             DWF_lzd_feedback = overflow_reg & 8'b0111_1111;
//         4'b0001:
//             DWF_lzd_feedback = overflow_reg & 8'b0011_1111;
//         4'b0010:
//             DWF_lzd_feedback = overflow_reg & 8'b0001_1111;
//         default:
//             DWF_lzd_feedback = 8'b0000_0000;
//     endcase
// end

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         index <= 'b0;
//     end
//     else if(ready_d1) begin
//         index[0] <= enc_func;
//     end
    
//     else begin
//         index[0] <= index[0];
//     end
// end

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         index <= 'b0;
//     end
//     else if(ready_d2) begin
//         index[1] <= enc_func;
//     end
    
//     else begin
//         index[1] <= index[1];
//     end
// end

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         index <= 'b0;
//     end
//     else if(ready_d3) begin
//         index[2] <= enc_func;
//     end
    
//     else begin
//         index[2] <= index[2];
//     end
// end

// always_ff@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         index <= 'b0;
//     end
//     else if(ready_d3) begin
//         index[3] <= enc_func;
//     end
    
//     else begin
//         index[3] <= index[3];
//     end
// end

// ################## version1 ################################### 
// Only calculating index of Outliers, invalidate index of Inliers
// Add a valid bit in IndexSeq

// logic [dimm-1:0][IndexWidth-1+1:0] IndexSeq;
// logic [dimm-1:0][IndexWidth-1:0] num_zeros;


// // wires used as stg2 input
// logic [dimm-1:0][IndexWidth-1+1:0] IndexSeq_stg1;
// logic [dimm-1:0] overflow_stg1;
// logic [dimm-1:0][IndexWidth-1:0] num_zeros_stg1;
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         assign IndexSeq[i] = i;
//     end
// endgenerate


// // stage 1 stride 1
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==0) begin
//             assign num_zeros[i] = 0;
//         end

//         else begin
//             assign num_zeros[i] = num_zeros[i-1] + ~overflow[i-1];
//         end
//     end
// endgenerate

// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==dimm-1) begin
//             assign IndexSeq_stg1[i] = (num_zeros[i][0] == 1'b1) ? {$bits(IndexSeq){1'b1}} : IndexSeq[i];
//             assign overflow_stg1[i] = (num_zeros[i][0] == 1'b1) ? 1'b0 : overflow[i];
//         end else begin
//             assign IndexSeq_stg1[i] = (num_zeros[i+1][0] == 1'b1) ? IndexSeq[i+1] : IndexSeq[i];
//             assign overflow_stg1[i] = (num_zeros[i+1][0] == 1'b1) ? overflow[i+1] : overflow[i];
//         end
//     end
// endgenerate

// // wires used as stg3 input
// logic [dimm-1:0][IndexWidth-1+1:0] IndexSeq_stg2;
// logic [dimm-1:0] overflow_stg2;
// logic [dimm-1:0][IndexWidth-1:0] num_zeros_stg2;

// // stage 2 stride 2
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==0) begin
//             assign num_zeros_stg1[i] = 0;
//         end

//         else begin
//             assign num_zeros_stg1[i] = num_zeros_stg1[i-1] + ~overflow_stg1[i-1];
//         end
//     end
// endgenerate

// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i>=dimm-2) begin
//             //'b1111 for invalid index(dont' care)
//             assign IndexSeq_stg2[i] = (num_zeros_stg1[i][1] == 1'b1) ? {$bits(IndexSeq){1'b1}} : IndexSeq_stg1[i];
//             assign overflow_stg2[i] = (num_zeros_stg1[i][1] == 1'b1) ? 1'b0 : overflow_stg1[i];
//         end else begin
//             assign IndexSeq_stg2[i] = (num_zeros_stg1[i+2][1] == 1'b1) ? IndexSeq_stg1[i+2] : IndexSeq_stg1[i];
//             assign overflow_stg2[i] = (num_zeros_stg1[i+2][1] == 1'b1) ? overflow_stg1[i+2] : overflow_stg1[i];
//         end
//     end
// endgenerate

// logic [dimm-1:0][IndexWidth-1+1:0] IndexSeq_stg3;
// logic [dimm-1:0] overflow_stg3;
// // stage 3 stride 4
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==0) begin
//             assign num_zeros_stg2[i] = 0;
//         end

//         else begin
//             assign num_zeros_stg2[i] = num_zeros_stg2[i-1] + ~overflow_stg2[i-1];
//         end
//     end
// endgenerate

// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i>=dimm-4) begin
//             //'b1111 for invalid index(dont' care)
//             assign IndexSeq_stg3[i] = (num_zeros_stg2[i][1] == 1'b1) ? {$bits(IndexSeq){1'b1}} : IndexSeq_stg2[i];
//             assign overflow_stg3[i] = (num_zeros_stg2[i][1] == 1'b1) ? 1'b0 : overflow_stg2[i];
//         end else begin
//             assign IndexSeq_stg3[i] = (num_zeros_stg2[i+2][1] == 1'b1) ? IndexSeq_stg2[i+2] : IndexSeq_stg2[i];
//             assign overflow_stg3[i] = (num_zeros_stg2[i+2][1] == 1'b1) ? overflow_stg2[i+2] : overflow_stg2[i];
//         end
//     end
// endgenerate

// generate
//     for(genvar i=0; i<NUM_LR; i++) begin
//         assign index[i] = IndexSeq_stg3[i];
//     end
// endgenerate


// ########################### version2 #################################

// ################## automization ###################
logic [dimm-1:0][IndexWidth-1:0] IndexSeq;

generate
    for(genvar i=0; i<dimm; i++) begin
        assign IndexSeq[i] = i;
    end
endgenerate

generate
    for(genvar j=0; j<$clog2(dimm); j++) begin:stride
        localparam NUM_SHIFT = 2**j;
        logic [dimm-1:0][IndexWidth-1:0] num_zeros_stg;
        logic [dimm-1:0] overflow_stg;
        logic [dimm-1:0][IndexWidth-1:0] IndexSeq_stg;
        // pt1. prefix sum module
        if(j==0) begin
            for(genvar i=0; i<dimm; i++) begin
                if(i==0) begin
                    assign num_zeros_stg[i] = 0;
                end

                else begin
                    assign num_zeros_stg[i] = num_zeros_stg[i-1] + ~overflow[i-1];
                end
            end
        end else begin
            for(genvar i=0; i<dimm; i++) begin
                if(i==0) begin
                    assign num_zeros_stg[i] = 0;
                end

                else begin
                    assign num_zeros_stg[i] = num_zeros_stg[i-1] + ~stride[j-1].overflow_stg[i-1];       
                end
            end    
        end
        // pt2. mux tree module
        for(genvar i=0; i<dimm-NUM_SHIFT; i++) begin:scan_stride
            logic [IndexWidth-1:0] IndexSeqMux0;
            logic [IndexWidth-1:0] IndexSeqMux1;                
            logic overflowMux0;
            logic overflowMux1;
            if(j==0) begin
                if(i==0) begin
                    assign IndexSeqMux0 = (num_zeros[1][j] == 1'b1) ? IndexSeq[NUM_SHIFT] : IndexSeq[0];
                    assign IndexSeqMux1 = (num_zeros[1][j] == 1'b1) ? IndexSeq[0] : IndexSeq[NUM_SHIFT];
                    assign overflowMux0 = (num_zeros[1][j] == 1'b1) ? overflow[NUM_SHIFT] : overflow[0];
                    assign overflowMux1 = (num_zeros[1][j] == 1'b1) ? overflow[0] : overflow[NUM_SHIFT];
                end else begin
                    assign IndexSeqMux0 = (num_zeros[i+1][j] == 1'b1) ? IndexSeq[i+NUM_SHIFT] : scan_stride[i-1].IndexSeqMux1;
                    assign IndexSeqMux1 = (num_zeros[i+1][j] == 1'b1) ? scan_stride[i-1].IndexSeqMux1 : IndexSeq[i+NUM_SHIFT];
                    assign overflowMux0 = (num_zeros[i+1][j] == 1'b1) ? overflow[i+NUM_SHIFT] : scan_stride[i-1].overflowMux1;
                    assign overflowMux1 = (num_zeros[i+1][j] == 1'b1) ? scan_stride[i-1].overflowMux1 : overflow[i+NUM_SHIFT];
                end
            end else begin
                if(i==0) begin
                    assign IndexSeqMux0 = (num_zeros[1][j] == 1'b1) ? stride[j-1].IndexSeq_stg[NUM_SHIFT] : stride[j-1].IndexSeq_stg[0];
                    assign IndexSeqMux1 = (num_zeros[1][j] == 1'b1) ? stride[j-1].IndexSeq_stg[0] : stride[j-1].IndexSeq[NUM_SHIFT];
                    assign overflowMux0 = (num_zeros[1][j] == 1'b1) ? stride[j-1].overflow_stg[NUM_SHIFT] : stride[j-1].overflow_stg[0];
                    assign overflowMux1 = (num_zeros[1][j] == 1'b1) ? stride[j-1].overflow_stg[0] : stride[j-1].overflow_stg[NUM_SHIFT];
                end else begin
                    assign IndexSeqMux0 = (num_zeros[i+1][j] == 1'b1) ? stride[j-1].IndexSeq_stg[i+NUM_SHIFT] : scan_stride[i-1].IndexSeqMux1;
                    assign IndexSeqMux1 = (num_zeros[i+1][j] == 1'b1) ? scan_stride[i-1].IndexSeqMux1 : stride[j-1].IndexSeq_stg[i+NUM_SHIFT];
                    assign overflowMux0 = (num_zeros[i+1][j] == 1'b1) ? stride[j-1].overflow_stg[i+NUM_SHIFT] : scan_stride[i-1].overflowMux1;
                    assign overflowMux1 = (num_zeros[i+1][j] == 1'b1) ? scan_stride[i-1].overflowMux1 : stride[j-1].overflow_stg[i+NUM_SHIFT];
                end
            end
        end

        // pt3. connect mux tree to output in a stride loop
        for(genvar i=0; i<dimm; i++) begin
            if(j==$clog2(dimm)-1) begin
                if(i == dimm-1) begin
                    assign index[i] = scan_stride[i-1].IndexSeqMux1;
                end else begin
                    assign index[i] = scan_stride[i].IndexSeqMux0;
                end                
            end else begin
                if(i == dimm-1) begin
                    assign IndexSeq_stg[i] = scan_stride[i-1].IndexSeqMux1;
                    assign overflow_stg[i] = scan_stride[i-1].overflowMux1;
                end else begin
                    assign IndexSeq_stg[i] = scan_stride[i].IndexSeqMux0;
                    assign overflow_stg[i] = scan_stride[i].overflowMux0;
                end
            end
        end
    end    
endgenerate        

// // ########### normal ################
// // stage 1 stride 1

// logic [dimm-1:0][IndexWidth-1:0] num_zeros;

// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==0) begin
//             assign num_zeros[i] = 0;
//         end

//         else begin
//             assign num_zeros[i] = num_zero[i-1] + ~overflow[i-1];
//         end
//     end
// endgenerate

// generate
//     for(genvar i=0; i<dimm-1; i++) begin:scan_stride1
//         logic [IndexWidth-1:0] IndexSeqMux0;
//         logic [IndexWidth-1:0] IndexSeqMux1;
//         logic overflowMux0;
//         logic overflowMux1;

//         if(i==0) begin
//             assign IndexSeqMux0 = (num_zeros[1][0] == 1'b1) ? IndexSeq[1] : IndexSeq[0];
//             assign IndexSeqMux1 = (num_zeros[1][0] == 1'b1) ? IndexSeq[0] : IndexSeq[1];
//             assign overflowMux0 = (num_zeros[1][0] == 1'b1) ? overflow[1] : overflow[0];
//             assign overflowMux1 = (num_zeros[1][0] == 1'b1) ? overflow[0] : overflow[1];
//         end else begin
//             assign IndexSeqMux0 = (num_zeros[i+1][0] == 1'b1) ? IndexSeq[i+1] : scan_stride1[i-1].IndexSeqMux1;
//             assign IndexSeqMux1 = (num_zeros[i+1][0] == 1'b1) ? scan_stride1[i-1].IndexSeqMux1 : IndexSeq[i+1];
//             assign overflowMux0 = (num_zeros[i+1][0] == 1'b1) ? overflow[i+1] : scan_stride1[i-1].overflowMux1;
//             assign overflowMux1 = (num_zeros[i+1][0] == 1'b1) ? scan_stride1[i-1].overflowMux1 : overflow[i+1];
//         end
//     end
// endgenerate


// // wires used as stg2 input
// logic [dimm-1:0][IndexWidth-1:0] IndexSeq_stg1;
// logic [dimm-1:0] overflow_stg1;
// logic [dimm-1:0][IndexWidth-1:0] num_zeros_stg1;
// // connect wires
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i == dimm-1) begin
//             assign IndexSeq_stg1[i] = scan_stride1[i-1].IndexSeqMux1;
//             assign overflow_stg1[i] = scan_stride1[i-1].overflowMux1;
//         end else begin
//             assign IndexSeq_stg1[i] = scan_stride1[i].IndexSeqMux0;
//             assign overflow_stg1[i] = scan_stride1[i].overflowMux0;
//         end
//     end
// endgenerate


// // stage 2 stride 2
// // prefix sum module
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==0) begin
//             assign num_zeros_stg1[i] = 0;
//         end

//         else begin
//             assign num_zeros_stg1[i] = num_zero_stg1[i-1] + ~overflow_stg1[i-1];
//         end
//     end
// endgenerate

// // wires used as stg3 input
// logic [dimm-1:0][IndexWidth-1:0] IndexSeq_stg2;
// logic [dimm-1:0] overflow_stg2;
// logic [dimm-1:0][IndexWidth-1:0] num_zeros_stg2;

// generate
//     for(genvar i=0; i<dimm-2; i++) begin:scan_stride2
//         logic [IndexWidth-1:0] IndexSeqMux0;
//         logic [IndexWidth-1:0] IndexSeqMux1;
//         logic overflowMux0;
//         logic overflowMux1;

//         if(i==0) begin
//             assign IndexSeqMux0 = (num_zeros_stg1[2][1] == 1'b1) ? IndexSeq_stg1[2] : IndexSeq_stg1[0];
//             assign IndexSeqMux1 = (num_zeros_stg1[2][1] == 1'b1) ? IndexSeq_stg1[0] : IndexSeq_stg1[2];
//             assign overflowMux0 = (num_zeros_stg1[2][1] == 1'b1) ? overflow_stg1[2] : overflow_stg1[0];
//             assign overflowMux1 = (num_zeros_stg1[2][1] == 1'b1) ? overflow_stg1[0] : overflow_stg1[2];
//         end else begin
//             assign IndexSeqMux0 = (num_zeros_stg1[i+2][1] == 1'b1) ? IndexSeq_stg1[i+2] : scan_stride2[i-1].IndexSeqMux1;
//             assign IndexSeqMux1 = (num_zeros_stg1[i+2][1] == 1'b1) ? scan_stride2[i-1].IndexSeqMux1 : IndexSeq[i+2];
//             assign overflowMux0 = (num_zeros_stg1[i+2][1] == 1'b1) ? overflow[i+2] : scan_stride2[i-1].overflowMux1;
//             assign overflowMux1 = (num_zeros_stg1[i+2][1] == 1'b1) ? scan_stride2[i-1].overflowMux1 : overflow[i+2];
//         end
//     end
// endgenerate

// // connect wires
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i == dimm-1) begin
//             assign IndexSeq_stg2[i] = scan_stride2[i-1].IndexSeqMux1;
//             assign overflow_stg2[i] = scan_stride2[i-1].overflowMux1;
//         end else begin
//             assign IndexSeq_stg2[i] = scan_stride2[i].IndexSeqMux0;
//             assign overflow_stg2[i] = scan_stride2[i].overflowMux0;
//         end
//     end
// endgenerate

// // stage 3 stride 4
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i==0) begin
//             assign num_zeros_stg2[i] = 0;
//         end

//         else begin
//             assign num_zeros_stg2[i] = num_zero_stg2[i-1] + ~overflow_stg2[i-1];
//         end
//     end
// endgenerate

// generate
//     for(genvar i=0; i<dimm-4; i++) begin:scan_stride4
//         logic [IndexWidth-1:0] IndexSeqMux0;
//         logic [IndexWidth-1:0] IndexSeqMux1;

//         if(i==0) begin
//             assign IndexSeqMux0 = (num_zeros_stg2[2][1] == 1'b1) ? IndexSeq_stg2[4] : IndexSeq_stg2[0];
//             assign IndexSeqMux1 = (num_zeros_stg2[2][1] == 1'b1) ? IndexSeq_stg2[0] : IndexSeq_stg2[4];
//         end else begin
//             assign IndexSeqMux0 = (num_zeros_stg2[i+1][1] == 1'b1) ? IndexSeq_stg1[i+4] : scan_stride4[i-1].IndexSeqMux1;
//             assign IndexSeqMux1 = (num_zeros_stg2[i+1][1] == 1'b1) ? scan_stride4[i-1].IndexSeqMux1 : IndexSeq[i+4];
//         end
//     end
// endgenerate

// // connect wires
// generate
//     for(genvar i=0; i<dimm; i++) begin
//         if(i == dimm-1) begin
//             assign index[i] = scan_stride4[i-1].IndexSeqMux1;
//         end else begin
//             assign index[i] = scan_stride4[i].IndexSeqMux0;
//         end
//     end
// endgenerate
endmodule