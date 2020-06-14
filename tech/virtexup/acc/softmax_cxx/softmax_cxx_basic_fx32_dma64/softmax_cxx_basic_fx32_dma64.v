
//------> ./softmax_cxx_ccs_in_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_ccs_in_wait_v1 (idat, rdy, ivld, dat, irdy, vld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  output             rdy;
  output             ivld;
  input  [width-1:0] dat;
  input              irdy;
  input              vld;

  wire   [width-1:0] idat;
  wire               rdy;
  wire               ivld;

  assign idat = dat;
  assign rdy = irdy;
  assign ivld = vld;

endmodule


//------> ./softmax_cxx_ccs_out_wait_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_ccs_out_wait_v1 (dat, irdy, vld, idat, rdy, ivld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] dat;
  output             irdy;
  output             vld;
  input  [width-1:0] idat;
  input              rdy;
  input              ivld;

  wire   [width-1:0] dat;
  wire               irdy;
  wire               vld;

  assign dat = idat;
  assign irdy = rdy;
  assign vld = ivld;

endmodule



//------> ./softmax_cxx_ccs_sync_out_vld_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2015 Mentor Graphics Corp.
//       All Rights Reserved
//
// This document may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------

module esp_acc_softmax_cxx_ccs_sync_out_vld_v1 (vld, ivld);
  parameter integer rscid = 1;

  input  ivld;
  output vld;

  wire   vld;

  assign vld = ivld;
endmodule

//------> ./softmax_cxx_mgc_mul_pipe_beh.v 
//
// File:      $Mgc_home/pkgs/hls_pkgs/mgc_comps_src/mgc_mul_pipe_beh.v
//
// BASELINE:  Catapult-C version 2006b.63
// MODIFIED:  2007-04-03, tnagler
//
// Note: this file uses Verilog2001 features;
//       please enable Verilog2001 in the flow!

module esp_acc_softmax_cxx_mgc_mul_pipe (a, b, clk, en, a_rst, s_rst, z);

    // Parameters:
    parameter integer width_a = 32'd4;  // input a bit width
    parameter         signd_a =  1'b1;  // input a type (1=signed, 0=unsigned)
    parameter integer width_b = 32'd4;  // input b bit width
    parameter         signd_b =  1'b1;  // input b type (1=signed, 0=unsigned)
    parameter integer width_z = 32'd8;  // result bit width (= width_a + width_b)
    parameter      clock_edge =  1'b0;  // clock polarity (1=posedge, 0=negedge)
    parameter   enable_active =  1'b0;  // enable polarity (1=posedge, 0=negedge)
    parameter    a_rst_active =  1'b1;  // unused
    parameter    s_rst_active =  1'b1;  // unused
    parameter integer  stages = 32'd2;  // number of output registers + 1 (careful!)
    parameter integer n_inreg = 32'd0;  // number of input registers

    localparam integer width_ab = width_a + width_b;  // multiplier result width
    localparam integer n_inreg_min = (n_inreg > 1) ? (n_inreg-1) : 0; // for Synopsys DC

    // I/O ports:
    input  [width_a-1:0] a;      // input A
    input  [width_b-1:0] b;      // input B
    input                clk;    // clock
    input                en;     // enable
    input                a_rst;  // async reset (unused)
    input                s_rst;  // sync reset (unused)
    output [width_z-1:0] z;      // output


    // Input registers:

    wire [width_a-1:0] a_f;
    wire [width_b-1:0] b_f;

    integer i;

    generate
    if (clock_edge == 1'b0)
    begin: NEG_EDGE1
        case (n_inreg)
        32'd0: begin: B1
            assign a_f = a,
                   b_f = b;
        end
        default: begin: B2
            reg [width_a-1:0] a_reg [n_inreg_min:0];
            reg [width_b-1:0] b_reg [n_inreg_min:0];
            always @(negedge clk)
            if (en == enable_active)
            begin: B21
                a_reg[0] <= a;
                b_reg[0] <= b;
                for (i = 0; i < n_inreg_min; i = i + 1)
                begin: B3
                    a_reg[i+1] <= a_reg[i];
                    b_reg[i+1] <= b_reg[i];
                end
            end
            assign a_f = a_reg[n_inreg_min],
                   b_f = b_reg[n_inreg_min];
        end
        endcase
    end
    else
    begin: POS_EDGE1
        case (n_inreg)
        32'd0: begin: B1
            assign a_f = a,
                   b_f = b;
        end
        default: begin: B2
            reg [width_a-1:0] a_reg [n_inreg_min:0];
            reg [width_b-1:0] b_reg [n_inreg_min:0];
            always @(posedge clk)
            if (en == enable_active)
            begin: B21
                a_reg[0] <= a;
                b_reg[0] <= b;
                for (i = 0; i < n_inreg_min; i = i + 1)
                begin: B3
                    a_reg[i+1] <= a_reg[i];
                    b_reg[i+1] <= b_reg[i];
                end
            end
            assign a_f = a_reg[n_inreg_min],
                   b_f = b_reg[n_inreg_min];
        end
        endcase
    end
    endgenerate


    // Output:
    wire [width_z-1:0]  xz;

    function signed [width_z-1:0] conv_signed;
      input signed [width_ab-1:0] res;
      conv_signed = res[width_z-1:0];
    endfunction

    generate
      wire signed [width_ab-1:0] res;
      if ( (signd_a == 1'b1) && (signd_b == 1'b1) )
      begin: SIGNED_AB
              assign res = $signed(a_f) * $signed(b_f);
              assign xz = conv_signed(res);
      end
      else if ( (signd_a == 1'b1) && (signd_b == 1'b0) )
      begin: SIGNED_A
              assign res = $signed(a_f) * $signed({1'b0, b_f});
              assign xz = conv_signed(res);
      end
      else if ( (signd_a == 1'b0) && (signd_b == 1'b1) )
      begin: SIGNED_B
              assign res = $signed({1'b0,a_f}) * $signed(b_f);
              assign xz = conv_signed(res);
      end
      else
      begin: UNSIGNED_AB
              assign res = a_f * b_f;
	      assign xz = res[width_z-1:0];
      end
    endgenerate


    // Output registers:

    reg  [width_z-1:0] reg_array[stages-2:0];
    wire [width_z-1:0] z;

    generate
    if (clock_edge == 1'b0)
    begin: NEG_EDGE2
        always @(negedge clk)
        if (en == enable_active)
            for (i = stages-2; i >= 0; i = i-1)
                if (i == 0)
                    reg_array[i] <= xz;
                else
                    reg_array[i] <= reg_array[i-1];
    end
    else
    begin: POS_EDGE2
        always @(posedge clk)
        if (en == enable_active)
            for (i = stages-2; i >= 0; i = i-1)
                if (i == 0)
                    reg_array[i] <= xz;
                else
                    reg_array[i] <= reg_array[i-1];
    end
    endgenerate

    assign z = reg_array[stages-2];
endmodule

//------> ./softmax_cxx_mgc_shift_br_beh_v5.v 
module esp_acc_softmax_cxx_mgc_shift_br_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate
     if (signd_a)
     begin: SGNED
       assign z = fshr_s(a,s,a[width_a-1]);
     end
     else
     begin: UNSGNED
       assign z = fshr_s(a,s,1'b0);
     end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift right - unsigned shift argument
   function [width_z-1:0] fshr_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = signd_a ? width_a : width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg signed [len-1:0] result;
      reg signed [len-1:0] result_t;
      begin
        result_t = $signed( {(len){sbit}} );
        result_t[width_a-1:0] = arg1;
        result = result_t >>> arg2;
        fshr_u =  result[olen-1:0];
      end
   endfunction // fshr_u

   //Shift right - signed shift argument
   function [width_z-1:0] fshr_s;
     input [width_a-1:0] arg1;
     input [width_s-1:0] arg2;
     input sbit;
     begin
       if ( arg2[width_s-1] == 1'b0 )
       begin
         fshr_s = fshr_u(arg1, arg2, sbit);
       end
       else
       begin
         fshr_s = fshl_u_1({arg1, 1'b0},~arg2, sbit);
       end
     end
   endfunction

endmodule

//------> ./softmax_cxx_mgc_shift_bl_beh_v5.v 
module esp_acc_softmax_cxx_mgc_shift_bl_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate if ( signd_a )
   begin: SGNED
     assign z = fshl_s(a,s,a[width_a-1]);
   end
   else
   begin: UNSGNED
     assign z = fshl_s(a,s,1'b0);
   end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u

   //Shift right - unsigned shift argument
   function [width_z-1:0] fshr_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = signd_a ? width_a : width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg signed [len-1:0] result;
      reg signed [len-1:0] result_t;
      begin
        result_t = $signed( {(len){sbit}} );
        result_t[width_a-1:0] = arg1;
        result = result_t >>> arg2;
        fshr_u =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift left - signed shift argument
   function [width_z-1:0] fshl_s;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      reg [width_a:0] sbit_arg1;
      begin
        // Ignoring the possibility that arg2[width_s-1] could be X
        // because of customer complaints regarding X'es in simulation results
        if ( arg2[width_s-1] == 1'b0 )
        begin
          sbit_arg1[width_a:0] = {(width_a+1){1'b0}};
          fshl_s = fshl_u(arg1, arg2, sbit);
        end
        else
        begin
          sbit_arg1[width_a] = sbit;
          sbit_arg1[width_a-1:0] = arg1;
          fshl_s = fshr_u(sbit_arg1[width_a:1], ~arg2, sbit);
        end
      end
   endfunction

endmodule

//------> ./softmax_cxx_mgc_shift_l_beh_v5.v 
module esp_acc_softmax_cxx_mgc_shift_l_v5(a,s,z);
   parameter    width_a = 4;
   parameter    signd_a = 1;
   parameter    width_s = 2;
   parameter    width_z = 8;

   input [width_a-1:0] a;
   input [width_s-1:0] s;
   output [width_z -1:0] z;

   generate
   if (signd_a)
   begin: SGNED
      assign z = fshl_u(a,s,a[width_a-1]);
   end
   else
   begin: UNSGNED
      assign z = fshl_u(a,s,1'b0);
   end
   endgenerate

   //Shift-left - unsigned shift argument one bit more
   function [width_z-1:0] fshl_u_1;
      input [width_a  :0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      parameter olen = width_z;
      parameter ilen = width_a+1;
      parameter len = (ilen >= olen) ? ilen : olen;
      reg [len-1:0] result;
      reg [len-1:0] result_t;
      begin
        result_t = {(len){sbit}};
        result_t[ilen-1:0] = arg1;
        result = result_t <<< arg2;
        fshl_u_1 =  result[olen-1:0];
      end
   endfunction // fshl_u

   //Shift-left - unsigned shift argument
   function [width_z-1:0] fshl_u;
      input [width_a-1:0] arg1;
      input [width_s-1:0] arg2;
      input sbit;
      fshl_u = fshl_u_1({sbit,arg1} ,arg2, sbit);
   endfunction // fshl_u

endmodule

//------> ./softmax_cxx_leading_sign_74_0.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5a/871028 Production Release
//  HLS Date:       Tue Apr 14 07:55:32 PDT 2020
//
//  Generated by:   giuseppe@fastml02
//  Generated date: Fri Jun  5 18:34:28 2020
// ----------------------------------------------------------------------

//
// ------------------------------------------------------------------
//  Design Unit:    leading_sign_74_0
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_leading_sign_74_0 (
  mantissa, rtn
);
  input [73:0] mantissa;
  output [6:0] rtn;


  // Interconnect Declarations
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_18_3_sdt_3;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_42_4_sdt_4;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_62_3_sdt_3;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_90_5_sdt_5;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_110_3_sdt_3;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_134_4_sdt_4;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_154_3_sdt_3;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_186_6_sdt_6;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_2;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_206_3_sdt_3;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_14_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_34_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_58_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_78_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_106_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_126_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_150_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_170_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_202_2_sdt_1;
  wire c_h_1_2;
  wire c_h_1_5;
  wire c_h_1_6;
  wire c_h_1_9;
  wire c_h_1_12;
  wire c_h_1_13;
  wire c_h_1_14;
  wire c_h_1_17;
  wire c_h_1_20;
  wire c_h_1_21;
  wire c_h_1_24;
  wire c_h_1_27;
  wire c_h_1_28;
  wire c_h_1_29;
  wire c_h_1_30;
  wire c_h_1_33;
  wire c_h_1_34;
  wire c_h_1_35;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_291_ssc;

  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_1_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_292_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_2_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_or_2_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_nor_nl;

  // Interconnect Declarations for Component Instantiations
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_2
      = ~((mantissa[71:70]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_1
      = ~((mantissa[73:72]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_14_2_sdt_1
      = ~((mantissa[69:68]!=2'b00));
  assign c_h_1_2 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_2;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_18_3_sdt_3
      = (mantissa[67:66]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_14_2_sdt_1;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_2
      = ~((mantissa[63:62]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_1
      = ~((mantissa[65:64]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_34_2_sdt_1
      = ~((mantissa[61:60]!=2'b00));
  assign c_h_1_5 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_2;
  assign c_h_1_6 = c_h_1_2 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_18_3_sdt_3;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_42_4_sdt_4
      = (mantissa[59:58]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_34_2_sdt_1
      & c_h_1_5;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_2
      = ~((mantissa[55:54]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_1
      = ~((mantissa[57:56]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_58_2_sdt_1
      = ~((mantissa[53:52]!=2'b00));
  assign c_h_1_9 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_2;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_62_3_sdt_3
      = (mantissa[51:50]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_58_2_sdt_1;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_2
      = ~((mantissa[47:46]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_1
      = ~((mantissa[49:48]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_78_2_sdt_1
      = ~((mantissa[45:44]!=2'b00));
  assign c_h_1_12 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_2;
  assign c_h_1_13 = c_h_1_9 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_62_3_sdt_3;
  assign c_h_1_14 = c_h_1_6 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_42_4_sdt_4;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_90_5_sdt_5
      = (mantissa[43:42]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_78_2_sdt_1
      & c_h_1_12 & c_h_1_13;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_2
      = ~((mantissa[39:38]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_1
      = ~((mantissa[41:40]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_106_2_sdt_1
      = ~((mantissa[37:36]!=2'b00));
  assign c_h_1_17 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_2;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_110_3_sdt_3
      = (mantissa[35:34]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_106_2_sdt_1;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_2
      = ~((mantissa[31:30]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_1
      = ~((mantissa[33:32]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_126_2_sdt_1
      = ~((mantissa[29:28]!=2'b00));
  assign c_h_1_20 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_2;
  assign c_h_1_21 = c_h_1_17 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_110_3_sdt_3;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_134_4_sdt_4
      = (mantissa[27:26]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_126_2_sdt_1
      & c_h_1_20;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_2
      = ~((mantissa[23:22]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_1
      = ~((mantissa[25:24]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_150_2_sdt_1
      = ~((mantissa[21:20]!=2'b00));
  assign c_h_1_24 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_2;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_154_3_sdt_3
      = (mantissa[19:18]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_150_2_sdt_1;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_2
      = ~((mantissa[15:14]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_1
      = ~((mantissa[17:16]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_170_2_sdt_1
      = ~((mantissa[13:12]!=2'b00));
  assign c_h_1_27 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_2;
  assign c_h_1_28 = c_h_1_24 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_154_3_sdt_3;
  assign c_h_1_29 = c_h_1_21 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_134_4_sdt_4;
  assign c_h_1_30 = c_h_1_14 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_90_5_sdt_5;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_186_6_sdt_6
      = (mantissa[11:10]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_170_2_sdt_1
      & c_h_1_27 & c_h_1_28 & c_h_1_29;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_2
      = ~((mantissa[7:6]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_1
      = ~((mantissa[9:8]!=2'b00));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_202_2_sdt_1
      = ~((mantissa[5:4]!=2'b00));
  assign c_h_1_33 = ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_1
      & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_2;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_206_3_sdt_3
      = (mantissa[3:2]==2'b00) & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_202_2_sdt_1;
  assign c_h_1_34 = c_h_1_33 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_206_3_sdt_3;
  assign c_h_1_35 = c_h_1_30 & ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_186_6_sdt_6;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_291_ssc
      = (mantissa[1:0]==2'b00) & c_h_1_34 & c_h_1_35;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_nl
      = c_h_1_30 & (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_186_6_sdt_6);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_1_nl
      = c_h_1_14 & (c_h_1_29 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_90_5_sdt_5))
      & (~ c_h_1_35);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_292_nl
      = c_h_1_6 & (c_h_1_13 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_42_4_sdt_4))
      & (~((~(c_h_1_21 & (c_h_1_28 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_134_4_sdt_4))))
      & c_h_1_30)) & (c_h_1_34 | (~ c_h_1_35));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_2_nl
      = c_h_1_2 & (c_h_1_5 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_18_3_sdt_3))
      & (~((~(c_h_1_9 & (c_h_1_12 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_62_3_sdt_3))))
      & c_h_1_14)) & (~((~(c_h_1_17 & (c_h_1_20 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_110_3_sdt_3))
      & (~((~(c_h_1_24 & (c_h_1_27 | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_154_3_sdt_3))))
      & c_h_1_29)))) & c_h_1_30)) & (~((~(c_h_1_33 & (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_206_3_sdt_3)))
      & c_h_1_35));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_or_2_nl
      = (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_14_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_6_2_sdt_2))
      & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_34_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_26_2_sdt_2))))
      & c_h_1_6)) & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_58_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_50_2_sdt_2))
      & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_78_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_70_2_sdt_2))))
      & c_h_1_13)))) & c_h_1_14)) & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_106_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_98_2_sdt_2))
      & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_126_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_118_2_sdt_2))))
      & c_h_1_21)) & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_150_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_142_2_sdt_2))
      & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_170_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_162_2_sdt_2))))
      & c_h_1_28)))) & c_h_1_29)))) & c_h_1_30)) & (~((~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_1
      & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_202_2_sdt_1
      | (~ ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_wrs_c_194_2_sdt_2))
      & (~ c_h_1_34))) & c_h_1_35))) | ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_291_ssc;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_nor_nl
      = ~((mantissa[73]) | (~((mantissa[72:71]!=2'b01))) | (((mantissa[69]) | (~((mantissa[68:67]!=2'b01))))
      & c_h_1_2) | ((~((~((mantissa[65]) | (~((mantissa[64:63]!=2'b01))))) & (~(((mantissa[61])
      | (~((mantissa[60:59]!=2'b01)))) & c_h_1_5)))) & c_h_1_6) | ((~((~((mantissa[57])
      | (~((mantissa[56:55]!=2'b01))))) & (~(((mantissa[53]) | (~((mantissa[52:51]!=2'b01))))
      & c_h_1_9)) & (~((~((~((mantissa[49]) | (~((mantissa[48:47]!=2'b01))))) & (~(((mantissa[45])
      | (~((mantissa[44:43]!=2'b01)))) & c_h_1_12)))) & c_h_1_13)))) & c_h_1_14)
      | ((~((~((mantissa[41]) | (~((mantissa[40:39]!=2'b01))))) & (~(((mantissa[37])
      | (~((mantissa[36:35]!=2'b01)))) & c_h_1_17)) & (~((~((~((mantissa[33]) | (~((mantissa[32:31]!=2'b01)))))
      & (~(((mantissa[29]) | (~((mantissa[28:27]!=2'b01)))) & c_h_1_20)))) & c_h_1_21))
      & (~((~((~((mantissa[25]) | (~((mantissa[24:23]!=2'b01))))) & (~(((mantissa[21])
      | (~((mantissa[20:19]!=2'b01)))) & c_h_1_24)) & (~((~((~((mantissa[17]) | (~((mantissa[16:15]!=2'b01)))))
      & (~(((mantissa[13]) | (~((mantissa[12:11]!=2'b01)))) & c_h_1_27)))) & c_h_1_28))))
      & c_h_1_29)))) & c_h_1_30) | ((~((~((mantissa[9]) | (~((mantissa[8:7]!=2'b01)))))
      & (~(((mantissa[5]) | (~((mantissa[4:3]!=2'b01)))) & c_h_1_33)) & (~((mantissa[1])
      & c_h_1_34)))) & c_h_1_35) | ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_291_ssc);
  assign rtn = {c_h_1_35 , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_nl
      , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_1_nl
      , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_292_nl
      , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_and_2_nl
      , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_or_2_nl
      , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_leading_sign_74_0_rtn_nor_nl};
endmodule




//------> /opt/cad/catapult/pkgs/ccs_xilinx/hdl/BLOCK_1R1W_RBW.v 
// Memory Type:            BLOCK
// Operating Mode:         Simple Dual Port (2-Port)
// Clock Mode:             Single Clock
// 
// RTL Code RW Resolution: RBW
// Catapult RW Resolution: RBW
// 
// HDL Work Library:       Xilinx_RAMS_lib
// Component Name:         BLOCK_1R1W_RBW
// Latency = 1:            RAM with no registers on inputs or outputs
//         = 2:            adds embedded register on RAM output
//         = 3:            adds fabric registers to non-clock input RAM pins
//         = 4:            adds fabric register to output (driven by embedded register from latency=2)

module BLOCK_1R1W_RBW #(
  parameter addr_width = 8 ,
  parameter data_width = 7 ,
  parameter depth = 256 ,
  parameter latency = 1 
  
)( clk,clken,d,q,radr,wadr,we);

  input  clk;
  input  clken;
  input [data_width-1:0] d;
  output [data_width-1:0] q;
  input [addr_width-1:0] radr;
  input [addr_width-1:0] wadr;
  input  we;
  
  (* ram_style = "block" *)
  reg [data_width-1:0] mem [depth-1:0];// synthesis syn_ramstyle="block"
  
  reg [data_width-1:0] ramq;
  
  // Port Map
  // readA :: CLOCK clk ENABLE clken DATA_OUT q ADDRESS radr
  // writeA :: CLOCK clk ENABLE clken DATA_IN d ADDRESS wadr WRITE_ENABLE we

  generate
    // Register all non-clock inputs (latency < 3)
    if (latency > 2 ) begin
      reg [addr_width-1:0] radr_reg;
      reg [data_width-1:0] d_reg;
      reg [addr_width-1:0] wadr_reg;
      reg we_reg;
      
      always @(posedge clk) begin
        if (clken) begin
          radr_reg <= radr;
        end
      end
      always @(posedge clk) begin
        if (clken) begin
          d_reg <= d;
          wadr_reg <= wadr;
          we_reg <= we;
        end
      end
      
    // Access memory with registered inputs
      always @(posedge clk) begin
        if (clken) begin
            ramq <= mem[radr_reg];
            if (we_reg) begin
              mem[wadr_reg] <= d_reg;
            end
        end
      end
      
    end // END register inputs

    else begin
    // latency = 1||2: Access memory with non-registered inputs
      always @(posedge clk) begin
        if (clken) begin
            ramq <= mem[radr];
            if (we) begin
              mem[wadr] <= d;
            end
        end
      end
      
    end
  endgenerate //END input port generate 

  generate
    // latency=1: sequential RAM outputs drive module outputs
    if (latency == 1) begin
      assign q = ramq;
      
    end

    else if (latency == 2 || latency == 3) begin
    // latency=2: sequential (RAM output => tmp register => module output)
      reg [data_width-1:0] tmpq;
      
      always @(posedge clk) begin
        if (clken) begin
          tmpq <= ramq;
        end
      end
      
      assign q = tmpq;
      
    end
    else if (latency == 4) begin
    // latency=4: (RAM => tmp1 register => tmp2 fabric register => module output)
      reg [data_width-1:0] tmp1q;
      
      reg [data_width-1:0] tmp2q;
      
      always @(posedge clk) begin
        if (clken) begin
          tmp1q <= ramq;
        end
      end
      
      always @(posedge clk) begin
        if (clken) begin
          tmp2q <= tmp1q;
        end
      end
      
      assign q = tmp2q;
      
    end
    else begin
      //Add error check if latency > 4 or add N-pipeline regs
    end
  endgenerate //END output port generate

endmodule

//------> ./softmax_cxx.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5a/871028 Production Release
//  HLS Date:       Tue Apr 14 07:55:32 PDT 2020
// 
//  Generated by:   giuseppe@fastml02
//  Generated date: Fri Jun  5 18:34:58 2020
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_9_7_67_128_128_67_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_9_7_67_128_128_67_1_gen
    (
  clken, q, radr, we, d, wadr, clken_d, d_d, q_d, radr_d, wadr_d, we_d, writeA_w_ram_ir_internal_WMASK_B_d,
      readA_r_ram_ir_internal_RMASK_B_d
);
  output clken;
  input [66:0] q;
  output [6:0] radr;
  output we;
  output [66:0] d;
  output [6:0] wadr;
  input clken_d;
  input [66:0] d_d;
  output [66:0] q_d;
  input [6:0] radr_d;
  input [6:0] wadr_d;
  input we_d;
  input writeA_w_ram_ir_internal_WMASK_B_d;
  input readA_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign clken = (clken_d);
  assign q_d = q;
  assign radr = (radr_d);
  assign we = (writeA_w_ram_ir_internal_WMASK_B_d);
  assign d = (d_d);
  assign wadr = (wadr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_8_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_8_7_32_128_128_32_1_gen
    (
  clken, q, radr, we, d, wadr, clken_d, d_d, q_d, radr_d, wadr_d, we_d, writeA_w_ram_ir_internal_WMASK_B_d,
      readA_r_ram_ir_internal_RMASK_B_d
);
  output clken;
  input [31:0] q;
  output [6:0] radr;
  output we;
  output [31:0] d;
  output [6:0] wadr;
  input clken_d;
  input [31:0] d_d;
  output [31:0] q_d;
  input [6:0] radr_d;
  input [6:0] wadr_d;
  input we_d;
  input writeA_w_ram_ir_internal_WMASK_B_d;
  input readA_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign clken = (clken_d);
  assign q_d = q;
  assign radr = (radr_d);
  assign we = (writeA_w_ram_ir_internal_WMASK_B_d);
  assign d = (d_d);
  assign wadr = (wadr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_fsm (
  clk, rst, core_wen, fsm_output, BATCH_LOOP_C_0_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [3:0] fsm_output;
  reg [3:0] fsm_output;
  input BATCH_LOOP_C_0_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_softmax_cxx_core_core_fsm_1
  parameter
    core_rlp_C_0 = 2'd0,
    main_C_0 = 2'd1,
    BATCH_LOOP_C_0 = 2'd2,
    main_C_1 = 2'd3;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_softmax_cxx_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 4'b0010;
        state_var_NS = BATCH_LOOP_C_0;
      end
      BATCH_LOOP_C_0 : begin
        fsm_output = 4'b0100;
        if ( BATCH_LOOP_C_0_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = BATCH_LOOP_C_0;
        end
      end
      main_C_1 : begin
        fsm_output = 4'b1000;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 4'b0001;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, dma_read_chnl_rsci_wen_comp,
      dma_write_chnl_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input conf_info_rsci_wen_comp;
  input dma_read_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & dma_read_chnl_rsci_wen_comp & dma_write_chnl_rsci_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_dp
    (
  clk, rst, CALC_SOFTMAX_LOOP_mul_cmp_bawt, CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt, CALC_SOFTMAX_LOOP_mul_cmp_biwt,
      CALC_SOFTMAX_LOOP_mul_cmp_bdwt, CALC_SOFTMAX_LOOP_mul_cmp_z
);
  input clk;
  input rst;
  output CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  output [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt;
  input CALC_SOFTMAX_LOOP_mul_cmp_biwt;
  input CALC_SOFTMAX_LOOP_mul_cmp_bdwt;
  input [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;


  // Interconnect Declarations
  reg [2:0] CALC_SOFTMAX_LOOP_mul_cmp_bcwt;
  wire [3:0] nl_CALC_SOFTMAX_LOOP_mul_cmp_bcwt;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_94_63;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_94_63;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_94_63;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_94_63;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_94_63;
  reg [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_94_63;

  wire[2:0] CALC_SOFTMAX_LOOP_acc_1_nl;
  wire[3:0] nl_CALC_SOFTMAX_LOOP_acc_1_nl;
  wire[1:0] CALC_SOFTMAX_LOOP_acc_2_nl;
  wire[2:0] nl_CALC_SOFTMAX_LOOP_acc_2_nl;

  // Interconnect Declarations for Component Instantiations 
  assign CALC_SOFTMAX_LOOP_mul_cmp_bawt = CALC_SOFTMAX_LOOP_mul_cmp_biwt | (CALC_SOFTMAX_LOOP_mul_cmp_bcwt!=3'b000);
  assign CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt = MUX_v_32_7_2((CALC_SOFTMAX_LOOP_mul_cmp_z[94:63]),
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_94_63, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_94_63,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_94_63, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_94_63,
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_94_63, CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_94_63,
      CALC_SOFTMAX_LOOP_mul_cmp_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_bcwt <= 3'b000;
    end
    else begin
      CALC_SOFTMAX_LOOP_mul_cmp_bcwt <= nl_CALC_SOFTMAX_LOOP_mul_cmp_bcwt[2:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_94_63 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_94_63 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_94_63 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_94_63 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_94_63 <= 32'b00000000000000000000000000000000;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_94_63 <= 32'b00000000000000000000000000000000;
    end
    else if ( CALC_SOFTMAX_LOOP_mul_cmp_biwt ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_94_63 <= CALC_SOFTMAX_LOOP_mul_cmp_z[94:63];
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_94_63 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_94_63;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_94_63 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_1_94_63;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_94_63 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_2_94_63;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_94_63 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_3_94_63;
      CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_5_94_63 <= CALC_SOFTMAX_LOOP_mul_cmp_z_bfwt_4_94_63;
    end
  end
  assign nl_CALC_SOFTMAX_LOOP_acc_1_nl = CALC_SOFTMAX_LOOP_mul_cmp_bcwt + 3'b111;
  assign CALC_SOFTMAX_LOOP_acc_1_nl = nl_CALC_SOFTMAX_LOOP_acc_1_nl[2:0];
  assign nl_CALC_SOFTMAX_LOOP_acc_2_nl = conv_u2u_1_2(CALC_SOFTMAX_LOOP_mul_cmp_biwt)
      + conv_u2u_1_2(~ CALC_SOFTMAX_LOOP_mul_cmp_bdwt);
  assign CALC_SOFTMAX_LOOP_acc_2_nl = nl_CALC_SOFTMAX_LOOP_acc_2_nl[1:0];
  assign nl_CALC_SOFTMAX_LOOP_mul_cmp_bcwt  = CALC_SOFTMAX_LOOP_acc_1_nl + conv_u2u_2_3(CALC_SOFTMAX_LOOP_acc_2_nl);

  function automatic [31:0] MUX_v_32_7_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [31:0] input_2;
    input [31:0] input_3;
    input [31:0] input_4;
    input [31:0] input_5;
    input [31:0] input_6;
    input [2:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      3'b000 : begin
        result = input_0;
      end
      3'b001 : begin
        result = input_1;
      end
      3'b010 : begin
        result = input_2;
      end
      3'b011 : begin
        result = input_3;
      end
      3'b100 : begin
        result = input_4;
      end
      3'b101 : begin
        result = input_5;
      end
      default : begin
        result = input_6;
      end
    endcase
    MUX_v_32_7_2 = result;
  end
  endfunction


  function automatic [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction


  function automatic [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_ctrl
    (
  clk, rst, core_wen, core_wten, CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg, CALC_SOFTMAX_LOOP_mul_cmp_iswt5,
      CALC_SOFTMAX_LOOP_mul_cmp_biwt, CALC_SOFTMAX_LOOP_mul_cmp_bdwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg;
  input CALC_SOFTMAX_LOOP_mul_cmp_iswt5;
  output CALC_SOFTMAX_LOOP_mul_cmp_biwt;
  output CALC_SOFTMAX_LOOP_mul_cmp_bdwt;


  // Interconnect Declarations
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1;
  reg CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0;
  reg [2:0] CALC_SOFTMAX_LOOP_mul_cmp_icwt;
  wire [3:0] nl_CALC_SOFTMAX_LOOP_mul_cmp_icwt;

  wire[2:0] CALC_SOFTMAX_LOOP_acc_2_nl;
  wire[3:0] nl_CALC_SOFTMAX_LOOP_acc_2_nl;
  wire[1:0] CALC_SOFTMAX_LOOP_acc_3_nl;
  wire[2:0] nl_CALC_SOFTMAX_LOOP_acc_3_nl;

  // Interconnect Declarations for Component Instantiations 
  assign CALC_SOFTMAX_LOOP_mul_cmp_bdwt = CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg &
      core_wen;
  assign CALC_SOFTMAX_LOOP_mul_cmp_biwt = CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0
      | (CALC_SOFTMAX_LOOP_mul_cmp_icwt!=3'b000);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0 <= 1'b0;
      CALC_SOFTMAX_LOOP_mul_cmp_icwt <= 3'b000;
    end
    else begin
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4 <= (~ core_wten)
          & CALC_SOFTMAX_LOOP_mul_cmp_iswt5;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt4;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt3;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt2;
      CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0 <= CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt1;
      CALC_SOFTMAX_LOOP_mul_cmp_icwt <= nl_CALC_SOFTMAX_LOOP_mul_cmp_icwt[2:0];
    end
  end
  assign nl_CALC_SOFTMAX_LOOP_acc_2_nl = CALC_SOFTMAX_LOOP_mul_cmp_icwt + 3'b111;
  assign CALC_SOFTMAX_LOOP_acc_2_nl = nl_CALC_SOFTMAX_LOOP_acc_2_nl[2:0];
  assign nl_CALC_SOFTMAX_LOOP_acc_3_nl = conv_u2u_1_2(CALC_SOFTMAX_LOOP_mul_cmp_ALC_SOFTMAX_LOOP_mul_cmp_pdswt0)
      + conv_u2u_1_2(~ CALC_SOFTMAX_LOOP_mul_cmp_biwt);
  assign CALC_SOFTMAX_LOOP_acc_3_nl = nl_CALC_SOFTMAX_LOOP_acc_3_nl[1:0];
  assign nl_CALC_SOFTMAX_LOOP_mul_cmp_icwt  = CALC_SOFTMAX_LOOP_acc_2_nl + conv_u2u_2_3(CALC_SOFTMAX_LOOP_acc_3_nl);

  function automatic [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction


  function automatic [2:0] conv_u2u_2_3 ;
    input [1:0]  vector ;
  begin
    conv_u2u_2_3 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_dp
    (
  clk, rst, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2
);
  input clk;
  input rst;
  input [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt;
  output [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2;


  // Interconnect Declarations
  reg ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt;
  reg ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt_1;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt
      | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt
      = MUX_v_67_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_bfwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt_1);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt
          <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt_1
          <= 1'b0;
    end
    else begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt
          <= ~((~(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt
          | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt))
          | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt);
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt_1
          <= ~((~(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bcwt_1
          | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1))
          | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_bfwt
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_bfwt
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
    end
  end

  function automatic [66:0] MUX_v_67_2_2;
    input [66:0] input_0;
    input [66:0] input_1;
    input [0:0] sel;
    reg [66:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_67_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_ctrl
    (
  core_wen, core_wten, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff
);
  input core_wen;
  input core_wten;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_pff;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff;



  // Interconnect Declarations for Component Instantiations 
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg
      & core_wen;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt
      = (~ core_wten) & ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1
      & core_wen;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1
      = (~ core_wten) & ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_pff
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff
      & core_wen;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
    (
  clk, rst, plm_out_data_rsci_q_d, plm_out_data_rsci_bawt, plm_out_data_rsci_q_d_mxwt,
      plm_out_data_rsci_biwt, plm_out_data_rsci_bdwt, plm_out_data_rsci_biwt_1, plm_out_data_rsci_bdwt_2
);
  input clk;
  input rst;
  input [31:0] plm_out_data_rsci_q_d;
  output plm_out_data_rsci_bawt;
  output [31:0] plm_out_data_rsci_q_d_mxwt;
  input plm_out_data_rsci_biwt;
  input plm_out_data_rsci_bdwt;
  input plm_out_data_rsci_biwt_1;
  input plm_out_data_rsci_bdwt_2;


  // Interconnect Declarations
  reg plm_out_data_rsci_bcwt;
  reg plm_out_data_rsci_bcwt_1;
  reg [31:0] plm_out_data_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_data_rsci_bawt = plm_out_data_rsci_biwt | plm_out_data_rsci_bcwt;
  assign plm_out_data_rsci_q_d_mxwt = MUX_v_32_2_2(plm_out_data_rsci_q_d, plm_out_data_rsci_q_d_bfwt,
      plm_out_data_rsci_bcwt_1);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_data_rsci_bcwt <= 1'b0;
      plm_out_data_rsci_bcwt_1 <= 1'b0;
    end
    else begin
      plm_out_data_rsci_bcwt <= ~((~(plm_out_data_rsci_bcwt | plm_out_data_rsci_biwt))
          | plm_out_data_rsci_bdwt);
      plm_out_data_rsci_bcwt_1 <= ~((~(plm_out_data_rsci_bcwt_1 | plm_out_data_rsci_biwt_1))
          | plm_out_data_rsci_bdwt_2);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_data_rsci_q_d_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( plm_out_data_rsci_biwt_1 ) begin
      plm_out_data_rsci_q_d_bfwt <= plm_out_data_rsci_q_d;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
    (
  core_wen, core_wten, plm_out_data_rsci_oswt_unreg, plm_out_data_rsci_iswt0, plm_out_data_rsci_oswt_unreg_1,
      plm_out_data_rsci_iswt0_1, plm_out_data_rsci_biwt, plm_out_data_rsci_bdwt,
      plm_out_data_rsci_biwt_1, plm_out_data_rsci_bdwt_2, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      plm_out_data_rsci_we_d_core_sct_pff, plm_out_data_rsci_iswt0_pff, plm_out_data_rsci_iswt0_1_pff
);
  input core_wen;
  input core_wten;
  input plm_out_data_rsci_oswt_unreg;
  input plm_out_data_rsci_iswt0;
  input plm_out_data_rsci_oswt_unreg_1;
  input plm_out_data_rsci_iswt0_1;
  output plm_out_data_rsci_biwt;
  output plm_out_data_rsci_bdwt;
  output plm_out_data_rsci_biwt_1;
  output plm_out_data_rsci_bdwt_2;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  output plm_out_data_rsci_we_d_core_sct_pff;
  input plm_out_data_rsci_iswt0_pff;
  input plm_out_data_rsci_iswt0_1_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_data_rsci_bdwt = plm_out_data_rsci_oswt_unreg & core_wen;
  assign plm_out_data_rsci_biwt = (~ core_wten) & plm_out_data_rsci_iswt0;
  assign plm_out_data_rsci_bdwt_2 = plm_out_data_rsci_oswt_unreg_1 & core_wen;
  assign plm_out_data_rsci_biwt_1 = (~ core_wten) & plm_out_data_rsci_iswt0_1;
  assign plm_out_data_rsci_we_d_core_sct_pff = plm_out_data_rsci_iswt0_pff & core_wen;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_out_data_rsci_iswt0_1_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_acc_done_rsci_acc_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_acc_done_rsci_acc_done_wait_ctrl (
  core_wten, acc_done_rsci_iswt0, acc_done_rsci_ivld_core_sct
);
  input core_wten;
  input acc_done_rsci_iswt0;
  output acc_done_rsci_ivld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign acc_done_rsci_ivld_core_sct = acc_done_rsci_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
    (
  clk, rst, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_bawt, dma_write_chnl_rsci_wen_comp,
      dma_write_chnl_rsci_biwt, dma_write_chnl_rsci_bdwt, dma_write_chnl_rsci_bcwt
);
  input clk;
  input rst;
  input dma_write_chnl_rsci_oswt_unreg;
  output dma_write_chnl_rsci_bawt;
  output dma_write_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_biwt;
  input dma_write_chnl_rsci_bdwt;
  output dma_write_chnl_rsci_bcwt;
  reg dma_write_chnl_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_chnl_rsci_bawt = dma_write_chnl_rsci_biwt | dma_write_chnl_rsci_bcwt;
  assign dma_write_chnl_rsci_wen_comp = (~ dma_write_chnl_rsci_oswt_unreg) | dma_write_chnl_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_chnl_rsci_bcwt <= ~((~(dma_write_chnl_rsci_bcwt | dma_write_chnl_rsci_biwt))
          | dma_write_chnl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
    (
  core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_iswt0, dma_write_chnl_rsci_irdy,
      dma_write_chnl_rsci_biwt, dma_write_chnl_rsci_bdwt, dma_write_chnl_rsci_bcwt,
      dma_write_chnl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_write_chnl_rsci_oswt_unreg;
  input dma_write_chnl_rsci_iswt0;
  input dma_write_chnl_rsci_irdy;
  output dma_write_chnl_rsci_biwt;
  output dma_write_chnl_rsci_bdwt;
  input dma_write_chnl_rsci_bcwt;
  output dma_write_chnl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_write_chnl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_chnl_rsci_bdwt = dma_write_chnl_rsci_oswt_unreg & core_wen;
  assign dma_write_chnl_rsci_biwt = dma_write_chnl_rsci_ogwt & dma_write_chnl_rsci_irdy;
  assign dma_write_chnl_rsci_ogwt = dma_write_chnl_rsci_iswt0 & (~ dma_write_chnl_rsci_bcwt);
  assign dma_write_chnl_rsci_ivld_core_sct = dma_write_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
    (
  clk, rst, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_bawt, dma_read_chnl_rsci_wen_comp,
      dma_read_chnl_rsci_idat_mxwt, dma_read_chnl_rsci_biwt, dma_read_chnl_rsci_bdwt,
      dma_read_chnl_rsci_bcwt, dma_read_chnl_rsci_idat
);
  input clk;
  input rst;
  input dma_read_chnl_rsci_oswt_unreg;
  output dma_read_chnl_rsci_bawt;
  output dma_read_chnl_rsci_wen_comp;
  output [31:0] dma_read_chnl_rsci_idat_mxwt;
  input dma_read_chnl_rsci_biwt;
  input dma_read_chnl_rsci_bdwt;
  output dma_read_chnl_rsci_bcwt;
  reg dma_read_chnl_rsci_bcwt;
  input [63:0] dma_read_chnl_rsci_idat;


  // Interconnect Declarations
  reg [31:0] dma_read_chnl_rsci_idat_bfwt_31_0;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_rsci_bawt = dma_read_chnl_rsci_biwt | dma_read_chnl_rsci_bcwt;
  assign dma_read_chnl_rsci_wen_comp = (~ dma_read_chnl_rsci_oswt_unreg) | dma_read_chnl_rsci_bawt;
  assign dma_read_chnl_rsci_idat_mxwt = MUX_v_32_2_2((dma_read_chnl_rsci_idat[31:0]),
      dma_read_chnl_rsci_idat_bfwt_31_0, dma_read_chnl_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_chnl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_chnl_rsci_bcwt <= ~((~(dma_read_chnl_rsci_bcwt | dma_read_chnl_rsci_biwt))
          | dma_read_chnl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_chnl_rsci_idat_bfwt_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( dma_read_chnl_rsci_biwt ) begin
      dma_read_chnl_rsci_idat_bfwt_31_0 <= dma_read_chnl_rsci_idat[31:0];
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
    (
  core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_iswt0, dma_read_chnl_rsci_biwt,
      dma_read_chnl_rsci_bdwt, dma_read_chnl_rsci_bcwt, dma_read_chnl_rsci_irdy_core_sct,
      dma_read_chnl_rsci_ivld
);
  input core_wen;
  input dma_read_chnl_rsci_oswt_unreg;
  input dma_read_chnl_rsci_iswt0;
  output dma_read_chnl_rsci_biwt;
  output dma_read_chnl_rsci_bdwt;
  input dma_read_chnl_rsci_bcwt;
  output dma_read_chnl_rsci_irdy_core_sct;
  input dma_read_chnl_rsci_ivld;


  // Interconnect Declarations
  wire dma_read_chnl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_rsci_bdwt = dma_read_chnl_rsci_oswt_unreg & core_wen;
  assign dma_read_chnl_rsci_biwt = dma_read_chnl_rsci_ogwt & dma_read_chnl_rsci_ivld;
  assign dma_read_chnl_rsci_ogwt = dma_read_chnl_rsci_iswt0 & (~ dma_read_chnl_rsci_bcwt);
  assign dma_read_chnl_rsci_irdy_core_sct = dma_read_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
    (
  clk, rst, dma_write_ctrl_rsci_bawt, dma_write_ctrl_rsci_irdy_mxwt, dma_write_ctrl_rsci_irdy,
      dma_write_ctrl_rsci_biwt, dma_write_ctrl_rsci_bdwt
);
  input clk;
  input rst;
  output dma_write_ctrl_rsci_bawt;
  output dma_write_ctrl_rsci_irdy_mxwt;
  input dma_write_ctrl_rsci_irdy;
  input dma_write_ctrl_rsci_biwt;
  input dma_write_ctrl_rsci_bdwt;


  // Interconnect Declarations
  reg dma_write_ctrl_rsci_bcwt;
  reg dma_write_ctrl_rsci_irdy_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bawt = dma_write_ctrl_rsci_biwt | dma_write_ctrl_rsci_bcwt;
  assign dma_write_ctrl_rsci_irdy_mxwt = MUX_s_1_2_2(dma_write_ctrl_rsci_irdy, dma_write_ctrl_rsci_irdy_bfwt,
      dma_write_ctrl_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_ctrl_rsci_bcwt <= ~((~(dma_write_ctrl_rsci_bcwt | dma_write_ctrl_rsci_biwt))
          | dma_write_ctrl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_irdy_bfwt <= 1'b0;
    end
    else if ( dma_write_ctrl_rsci_biwt ) begin
      dma_write_ctrl_rsci_irdy_bfwt <= dma_write_ctrl_rsci_irdy;
    end
  end

  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
    (
  core_wen, core_wten, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_iswt0,
      dma_write_ctrl_rsci_biwt, dma_write_ctrl_rsci_bdwt
);
  input core_wen;
  input core_wten;
  input dma_write_ctrl_rsci_oswt_unreg;
  input dma_write_ctrl_rsci_iswt0;
  output dma_write_ctrl_rsci_biwt;
  output dma_write_ctrl_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bdwt = dma_write_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_write_ctrl_rsci_biwt = (~ core_wten) & dma_write_ctrl_rsci_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
    (
  clk, rst, dma_read_ctrl_rsci_bawt, dma_read_ctrl_rsci_irdy_mxwt, dma_read_ctrl_rsci_irdy,
      dma_read_ctrl_rsci_biwt, dma_read_ctrl_rsci_bdwt
);
  input clk;
  input rst;
  output dma_read_ctrl_rsci_bawt;
  output dma_read_ctrl_rsci_irdy_mxwt;
  input dma_read_ctrl_rsci_irdy;
  input dma_read_ctrl_rsci_biwt;
  input dma_read_ctrl_rsci_bdwt;


  // Interconnect Declarations
  reg dma_read_ctrl_rsci_bcwt;
  reg dma_read_ctrl_rsci_irdy_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bawt = dma_read_ctrl_rsci_biwt | dma_read_ctrl_rsci_bcwt;
  assign dma_read_ctrl_rsci_irdy_mxwt = MUX_s_1_2_2(dma_read_ctrl_rsci_irdy, dma_read_ctrl_rsci_irdy_bfwt,
      dma_read_ctrl_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_ctrl_rsci_bcwt <= ~((~(dma_read_ctrl_rsci_bcwt | dma_read_ctrl_rsci_biwt))
          | dma_read_ctrl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_irdy_bfwt <= 1'b0;
    end
    else if ( dma_read_ctrl_rsci_biwt ) begin
      dma_read_ctrl_rsci_irdy_bfwt <= dma_read_ctrl_rsci_irdy;
    end
  end

  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
    (
  core_wen, core_wten, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_iswt0, dma_read_ctrl_rsci_biwt,
      dma_read_ctrl_rsci_bdwt
);
  input core_wen;
  input core_wten;
  input dma_read_ctrl_rsci_oswt_unreg;
  input dma_read_ctrl_rsci_iswt0;
  output dma_read_ctrl_rsci_biwt;
  output dma_read_ctrl_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bdwt = dma_read_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_read_ctrl_rsci_biwt = (~ core_wten) & dma_read_ctrl_rsci_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt, conf_info_rsci_wen_comp, conf_info_rsci_idat_mxwt,
      conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt, conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;
  input conf_info_rsci_biwt;
  input conf_info_rsci_bdwt;
  output conf_info_rsci_bcwt;
  reg conf_info_rsci_bcwt;
  input [31:0] conf_info_rsci_idat;


  // Interconnect Declarations
  reg [31:0] conf_info_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt) | conf_info_rsci_biwt
      | conf_info_rsci_bcwt;
  assign conf_info_rsci_idat_mxwt = MUX_v_32_2_2(conf_info_rsci_idat, conf_info_rsci_idat_bfwt,
      conf_info_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_bcwt <= 1'b0;
    end
    else begin
      conf_info_rsci_bcwt <= ~((~(conf_info_rsci_bcwt | conf_info_rsci_biwt)) | conf_info_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_idat_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( conf_info_rsci_biwt ) begin
      conf_info_rsci_idat_bfwt <= conf_info_rsci_idat;
    end
  end

  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci_conf_info_wait_ctrl (
  core_wen, conf_info_rsci_oswt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct, conf_info_rsci_ivld
);
  input core_wen;
  input conf_info_rsci_oswt;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;
  input conf_info_rsci_ivld;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld;
  assign conf_info_rsci_ogwt = conf_info_rsci_oswt & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp (
  clk, rst, core_wen, core_wten, CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg, CALC_SOFTMAX_LOOP_mul_cmp_bawt,
      CALC_SOFTMAX_LOOP_mul_cmp_iswt5, CALC_SOFTMAX_LOOP_mul_cmp_a_core, CALC_SOFTMAX_LOOP_mul_cmp_b_core,
      CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg;
  output CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  input CALC_SOFTMAX_LOOP_mul_cmp_iswt5;
  input [66:0] CALC_SOFTMAX_LOOP_mul_cmp_a_core;
  input [93:0] CALC_SOFTMAX_LOOP_mul_cmp_b_core;
  output [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt;


  // Interconnect Declarations
  wire CALC_SOFTMAX_LOOP_mul_cmp_biwt;
  wire CALC_SOFTMAX_LOOP_mul_cmp_bdwt;
  wire [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  wire [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_mul_pipe #(.width_a(32'sd67),
  .signd_a(32'sd0),
  .width_b(32'sd94),
  .signd_b(32'sd0),
  .width_z(32'sd95),
  .clock_edge(32'sd1),
  .enable_active(32'sd1),
  .a_rst_active(32'sd0),
  .s_rst_active(32'sd0),
  .stages(32'sd6),
  .n_inreg(32'sd1)) CALC_SOFTMAX_LOOP_mul_cmp (
      .a(CALC_SOFTMAX_LOOP_mul_cmp_a_core),
      .b(CALC_SOFTMAX_LOOP_mul_cmp_b_core),
      .clk(clk),
      .en(1'b1),
      .a_rst(1'b1),
      .s_rst(rst),
      .z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_ctrl
      softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_ctrl_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg(CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg),
      .CALC_SOFTMAX_LOOP_mul_cmp_iswt5(CALC_SOFTMAX_LOOP_mul_cmp_iswt5),
      .CALC_SOFTMAX_LOOP_mul_cmp_biwt(CALC_SOFTMAX_LOOP_mul_cmp_biwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_bdwt(CALC_SOFTMAX_LOOP_mul_cmp_bdwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_dp
      softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_mgc_mul_pipe_67_0_94_0_95_1_1_0_0_6_1_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .CALC_SOFTMAX_LOOP_mul_cmp_bawt(CALC_SOFTMAX_LOOP_mul_cmp_bawt),
      .CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt_pconst),
      .CALC_SOFTMAX_LOOP_mul_cmp_biwt(CALC_SOFTMAX_LOOP_mul_cmp_biwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_bdwt(CALC_SOFTMAX_LOOP_mul_cmp_bdwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
  assign CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt = CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1
    (
  clk, rst, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      core_wen, core_wten, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff
);
  input clk;
  input rst;
  input [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1;
  output [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff;
  input ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff;


  // Interconnect Declarations
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_ctrl
      softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_dp
      softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_biwt_1),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bdwt_2)
    );
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_core_sct_iff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1 (
  clk, rst, plm_out_data_rsci_q_d, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      core_wen, core_wten, plm_out_data_rsci_oswt_unreg, plm_out_data_rsci_bawt,
      plm_out_data_rsci_iswt0, plm_out_data_rsci_oswt_unreg_1, plm_out_data_rsci_iswt0_1,
      plm_out_data_rsci_q_d_mxwt, plm_out_data_rsci_we_d_pff, plm_out_data_rsci_iswt0_pff,
      plm_out_data_rsci_iswt0_1_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_data_rsci_q_d;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_out_data_rsci_oswt_unreg;
  output plm_out_data_rsci_bawt;
  input plm_out_data_rsci_iswt0;
  input plm_out_data_rsci_oswt_unreg_1;
  input plm_out_data_rsci_iswt0_1;
  output [31:0] plm_out_data_rsci_q_d_mxwt;
  output plm_out_data_rsci_we_d_pff;
  input plm_out_data_rsci_iswt0_pff;
  input plm_out_data_rsci_iswt0_1_pff;


  // Interconnect Declarations
  wire plm_out_data_rsci_biwt;
  wire plm_out_data_rsci_bdwt;
  wire plm_out_data_rsci_biwt_1;
  wire plm_out_data_rsci_bdwt_2;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  wire plm_out_data_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
      softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_data_rsci_oswt_unreg(plm_out_data_rsci_oswt_unreg),
      .plm_out_data_rsci_iswt0(plm_out_data_rsci_iswt0),
      .plm_out_data_rsci_oswt_unreg_1(plm_out_data_rsci_oswt_unreg_1),
      .plm_out_data_rsci_iswt0_1(plm_out_data_rsci_iswt0_1),
      .plm_out_data_rsci_biwt(plm_out_data_rsci_biwt),
      .plm_out_data_rsci_bdwt(plm_out_data_rsci_bdwt),
      .plm_out_data_rsci_biwt_1(plm_out_data_rsci_biwt_1),
      .plm_out_data_rsci_bdwt_2(plm_out_data_rsci_bdwt_2),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .plm_out_data_rsci_we_d_core_sct_pff(plm_out_data_rsci_we_d_core_sct_iff),
      .plm_out_data_rsci_iswt0_pff(plm_out_data_rsci_iswt0_pff),
      .plm_out_data_rsci_iswt0_1_pff(plm_out_data_rsci_iswt0_1_pff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
      softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_bawt(plm_out_data_rsci_bawt),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_biwt(plm_out_data_rsci_biwt),
      .plm_out_data_rsci_bdwt(plm_out_data_rsci_bdwt),
      .plm_out_data_rsci_biwt_1(plm_out_data_rsci_biwt_1),
      .plm_out_data_rsci_bdwt_2(plm_out_data_rsci_bdwt_2)
    );
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_core_sct_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_acc_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_acc_done_rsci (
  acc_done_rsc_vld, core_wten, acc_done_rsci_iswt0
);
  output acc_done_rsc_vld;
  input core_wten;
  input acc_done_rsci_iswt0;


  // Interconnect Declarations
  wire acc_done_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_vld_v1 #(.rscid(32'sd6)) acc_done_rsci (
      .vld(acc_done_rsc_vld),
      .ivld(acc_done_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_acc_done_rsci_acc_done_wait_ctrl softmax_cxx_core_acc_done_rsci_acc_done_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .acc_done_rsci_iswt0(acc_done_rsci_iswt0),
      .acc_done_rsci_ivld_core_sct(acc_done_rsci_ivld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci (
  clk, rst, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_bawt, dma_write_chnl_rsci_iswt0,
      dma_write_chnl_rsci_wen_comp, dma_write_chnl_rsci_idat
);
  input clk;
  input rst;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  input core_wen;
  input dma_write_chnl_rsci_oswt_unreg;
  output dma_write_chnl_rsci_bawt;
  input dma_write_chnl_rsci_iswt0;
  output dma_write_chnl_rsci_wen_comp;
  input [63:0] dma_write_chnl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_chnl_rsci_irdy;
  wire dma_write_chnl_rsci_biwt;
  wire dma_write_chnl_rsci_bdwt;
  wire dma_write_chnl_rsci_bcwt;
  wire dma_write_chnl_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_dma_write_chnl_rsci_idat;
  assign nl_dma_write_chnl_rsci_idat = {32'b11011110101011011011111011101111 , (dma_write_chnl_rsci_idat[31:0])};
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd5),
  .width(32'sd64)) dma_write_chnl_rsci (
      .irdy(dma_write_chnl_rsci_irdy),
      .ivld(dma_write_chnl_rsci_ivld_core_sct),
      .idat(nl_dma_write_chnl_rsci_idat[63:0]),
      .rdy(dma_write_chnl_rsc_rdy),
      .vld(dma_write_chnl_rsc_vld),
      .dat(dma_write_chnl_rsc_dat)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
      softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_irdy(dma_write_chnl_rsci_irdy),
      .dma_write_chnl_rsci_biwt(dma_write_chnl_rsci_biwt),
      .dma_write_chnl_rsci_bdwt(dma_write_chnl_rsci_bdwt),
      .dma_write_chnl_rsci_bcwt(dma_write_chnl_rsci_bcwt),
      .dma_write_chnl_rsci_ivld_core_sct(dma_write_chnl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
      softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_biwt(dma_write_chnl_rsci_biwt),
      .dma_write_chnl_rsci_bdwt(dma_write_chnl_rsci_bdwt),
      .dma_write_chnl_rsci_bcwt(dma_write_chnl_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci (
  clk, rst, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_bawt, dma_read_chnl_rsci_iswt0,
      dma_read_chnl_rsci_wen_comp, dma_read_chnl_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  input core_wen;
  input dma_read_chnl_rsci_oswt_unreg;
  output dma_read_chnl_rsci_bawt;
  input dma_read_chnl_rsci_iswt0;
  output dma_read_chnl_rsci_wen_comp;
  output [31:0] dma_read_chnl_rsci_idat_mxwt;


  // Interconnect Declarations
  wire dma_read_chnl_rsci_biwt;
  wire dma_read_chnl_rsci_bdwt;
  wire dma_read_chnl_rsci_bcwt;
  wire dma_read_chnl_rsci_irdy_core_sct;
  wire dma_read_chnl_rsci_ivld;
  wire [63:0] dma_read_chnl_rsci_idat;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd4),
  .width(32'sd64)) dma_read_chnl_rsci (
      .rdy(dma_read_chnl_rsc_rdy),
      .vld(dma_read_chnl_rsc_vld),
      .dat(dma_read_chnl_rsc_dat),
      .irdy(dma_read_chnl_rsci_irdy_core_sct),
      .ivld(dma_read_chnl_rsci_ivld),
      .idat(dma_read_chnl_rsci_idat)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
      softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_irdy_core_sct(dma_read_chnl_rsci_irdy_core_sct),
      .dma_read_chnl_rsci_ivld(dma_read_chnl_rsci_ivld)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt_pconst),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_idat(dma_read_chnl_rsci_idat)
    );
  assign dma_read_chnl_rsci_idat_mxwt = dma_read_chnl_rsci_idat_mxwt_pconst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci (
  clk, rst, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      core_wen, core_wten, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_bawt,
      dma_write_ctrl_rsci_iswt0, dma_write_ctrl_rsci_irdy_mxwt, dma_write_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input core_wen;
  input core_wten;
  input dma_write_ctrl_rsci_oswt_unreg;
  output dma_write_ctrl_rsci_bawt;
  input dma_write_ctrl_rsci_iswt0;
  output dma_write_ctrl_rsci_irdy_mxwt;
  input [66:0] dma_write_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_ctrl_rsci_irdy;
  wire dma_write_ctrl_rsci_biwt;
  wire dma_write_ctrl_rsci_bdwt;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_write_ctrl_rsci_idat;
  assign nl_dma_write_ctrl_rsci_idat = {35'b01100000000000000000000000010000000 ,
      (dma_write_ctrl_rsci_idat[31:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd3),
  .width(32'sd67)) dma_write_ctrl_rsci (
      .irdy(dma_write_ctrl_rsci_irdy),
      .ivld(dma_write_ctrl_rsci_biwt),
      .idat(nl_dma_write_ctrl_rsci_idat[66:0]),
      .rdy(dma_write_ctrl_rsc_rdy),
      .vld(dma_write_ctrl_rsc_vld),
      .dat(dma_write_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
      softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(dma_write_ctrl_rsci_oswt_unreg),
      .dma_write_ctrl_rsci_iswt0(dma_write_ctrl_rsci_iswt0),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
      softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_irdy_mxwt(dma_write_ctrl_rsci_irdy_mxwt),
      .dma_write_ctrl_rsci_irdy(dma_write_ctrl_rsci_irdy),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci (
  clk, rst, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      core_wen, core_wten, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_bawt,
      dma_read_ctrl_rsci_iswt0, dma_read_ctrl_rsci_irdy_mxwt, dma_read_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input core_wen;
  input core_wten;
  input dma_read_ctrl_rsci_oswt_unreg;
  output dma_read_ctrl_rsci_bawt;
  input dma_read_ctrl_rsci_iswt0;
  output dma_read_ctrl_rsci_irdy_mxwt;
  input [66:0] dma_read_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_read_ctrl_rsci_irdy;
  wire dma_read_ctrl_rsci_biwt;
  wire dma_read_ctrl_rsci_bdwt;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_read_ctrl_rsci_idat;
  assign nl_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , (dma_read_ctrl_rsci_idat[10:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd2),
  .width(32'sd67)) dma_read_ctrl_rsci (
      .irdy(dma_read_ctrl_rsci_irdy),
      .ivld(dma_read_ctrl_rsci_biwt),
      .idat(nl_dma_read_ctrl_rsci_idat[66:0]),
      .rdy(dma_read_ctrl_rsc_rdy),
      .vld(dma_read_ctrl_rsc_vld),
      .dat(dma_read_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
      softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_irdy_mxwt(dma_read_ctrl_rsci_irdy_mxwt),
      .dma_read_ctrl_rsci_irdy(dma_read_ctrl_rsci_irdy),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt,
      conf_info_rsci_wen_comp, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt;
  output conf_info_rsci_wen_comp;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire conf_info_rsci_ivld;
  wire [31:0] conf_info_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd1),
  .width(32'sd32)) conf_info_rsci (
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci_conf_info_wait_ctrl softmax_cxx_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt(conf_info_rsci_oswt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci_conf_info_wait_dp softmax_cxx_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt(conf_info_rsci_oswt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, dma_read_ctrl_rsc_dat,
      dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld,
      dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_rsc_vld,
      plm_out_data_rsci_d_d, plm_out_data_rsci_q_d, plm_out_data_rsci_radr_d, plm_out_data_rsci_wadr_d,
      plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      plm_out_data_rsci_we_d_pff, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_rsc_vld;
  output [31:0] plm_out_data_rsci_d_d;
  input [31:0] plm_out_data_rsci_q_d;
  output [6:0] plm_out_data_rsci_radr_d;
  output [6:0] plm_out_data_rsci_wadr_d;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  input [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  output [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d;
  output [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output plm_out_data_rsci_we_d_pff;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire dma_read_ctrl_rsci_bawt;
  wire dma_read_ctrl_rsci_irdy_mxwt;
  wire dma_write_ctrl_rsci_bawt;
  wire dma_write_ctrl_rsci_irdy_mxwt;
  wire dma_read_chnl_rsci_bawt;
  wire dma_read_chnl_rsci_wen_comp;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt;
  wire dma_write_chnl_rsci_bawt;
  wire dma_write_chnl_rsci_wen_comp;
  wire plm_out_data_rsci_bawt;
  wire [31:0] plm_out_data_rsci_q_d_mxwt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt;
  wire CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  wire [31:0] CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt;
  reg [3:0] dma_read_ctrl_rsci_idat_10_7;
  reg [24:0] dma_write_ctrl_rsci_idat_31_7;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [3:0] fsm_output;
  wire BATCH_LOOP_nor_13_tmp;
  wire [7:0] SUM_EXP_LOOP_acc_2_tmp;
  wire [8:0] nl_SUM_EXP_LOOP_acc_2_tmp;
  wire [7:0] CALC_EXP_LOOP_acc_1_tmp;
  wire [8:0] nl_CALC_EXP_LOOP_acc_1_tmp;
  wire [7:0] LOAD_LOOP_acc_1_tmp;
  wire [8:0] nl_LOAD_LOOP_acc_1_tmp;
  wire [4:0] BATCH_LOOP_acc_2_tmp;
  wire [5:0] nl_BATCH_LOOP_acc_2_tmp;
  wire [7:0] STORE_LOOP_acc_1_tmp;
  wire [8:0] nl_STORE_LOOP_acc_1_tmp;
  wire BATCH_LOOP_and_13_tmp;
  wire [1:0] STORE_LOOP_mux_27_tmp;
  wire [1:0] STORE_LOOP_mux1h_44_tmp;
  wire CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_or_1_tmp;
  wire BATCH_LOOP_and_12_tmp;
  wire or_tmp_9;
  wire not_tmp_28;
  wire or_tmp_39;
  wire mux_tmp_40;
  wire not_tmp_36;
  wire and_tmp_10;
  wire and_tmp_22;
  wire or_dcpl_8;
  wire and_dcpl_22;
  wire and_dcpl_23;
  wire mux_tmp_131;
  wire mux_tmp_133;
  wire mux_tmp_134;
  wire and_tmp_34;
  wire mux_tmp_136;
  wire or_tmp_149;
  wire nand_tmp_15;
  wire or_tmp_152;
  wire mux_tmp_155;
  wire mux_tmp_159;
  wire nand_tmp_20;
  wire nand_tmp_21;
  wire mux_tmp_160;
  wire mux_tmp_162;
  wire and_dcpl_24;
  wire and_dcpl_27;
  wire or_tmp_175;
  wire mux_tmp_174;
  wire or_tmp_176;
  wire mux_tmp_175;
  wire mux_tmp_185;
  wire and_dcpl_42;
  wire mux_tmp_197;
  wire and_dcpl_79;
  wire or_tmp_197;
  wire mux_tmp_203;
  wire nand_tmp_25;
  wire and_dcpl_82;
  wire and_dcpl_84;
  wire nand_tmp_26;
  wire or_tmp_213;
  wire and_tmp_51;
  wire or_tmp_220;
  wire or_dcpl_16;
  wire or_dcpl_23;
  wire or_tmp_249;
  wire or_tmp_254;
  wire or_tmp_256;
  wire not_tmp_164;
  wire mux_tmp_295;
  wire nand_tmp_36;
  wire or_dcpl_58;
  wire or_tmp_312;
  wire mux_tmp_326;
  wire not_tmp_182;
  wire not_tmp_183;
  wire or_dcpl_72;
  wire and_dcpl_107;
  wire or_dcpl_76;
  wire mux_tmp_397;
  wire nand_tmp_39;
  wire nand_tmp_40;
  wire mux_tmp_400;
  wire or_tmp_362;
  wire or_tmp_367;
  wire and_dcpl_124;
  wire and_tmp_89;
  wire and_dcpl_130;
  wire and_tmp_98;
  wire and_tmp_99;
  wire and_dcpl_137;
  wire or_tmp_436;
  wire mux_tmp_522;
  wire mux_tmp_540;
  wire mux_tmp_555;
  wire and_tmp_141;
  wire or_tmp_492;
  wire and_tmp_144;
  wire and_dcpl_153;
  wire and_tmp_147;
  wire and_dcpl_157;
  wire or_tmp_507;
  wire or_tmp_531;
  wire mux_tmp_606;
  wire and_dcpl_244;
  wire or_tmp_608;
  wire or_tmp_612;
  wire or_tmp_630;
  wire or_tmp_633;
  wire or_tmp_670;
  wire or_tmp_671;
  wire or_tmp_675;
  wire or_tmp_682;
  wire or_tmp_707;
  wire or_tmp_732;
  wire or_tmp_736;
  wire or_tmp_774;
  wire or_tmp_784;
  wire STORE_LOOP_or_19_cse;
  wire STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
  wire exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
  wire STORE_LOOP_equal_tmp_2_mx0w0;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0;
  wire exitL_exit_STORE_LOOP_sva_mx1;
  wire lfst_exit_STORE_LOOP_lpi_2_2_mx1;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0_mx1;
  reg STORE_LOOP_equal_tmp_1;
  reg STORE_LOOP_equal_tmp_1_1;
  reg STORE_LOOP_equal_tmp_2_1;
  reg STORE_LOOP_nor_tmp_1;
  reg exit_BATCH_LOOP_lpi_2_dfm_1;
  reg STORE_LOOP_or_tmp_1;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2;
  wire STORE_LOOP_and_2_ssc_1;
  wire STORE_LOOP_and_4_ssc_1;
  wire CALC_SOFTMAX_LOOP_and_svs_1;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_4;
  reg BATCH_LOOP_stage_v_4;
  reg CALC_SOFTMAX_LOOP_asn_itm_10;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_10;
  reg BATCH_LOOP_stage_v_10;
  reg CALC_SOFTMAX_LOOP_asn_itm_11;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_11;
  reg BATCH_LOOP_stage_v_11;
  reg BATCH_LOOP_stage_v_12;
  wire BATCH_LOOP_BATCH_LOOP_or_cse_1;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_12;
  wire [7:0] CALC_SOFTMAX_LOOP_i_7_0_sva_2;
  wire [8:0] nl_CALC_SOFTMAX_LOOP_i_7_0_sva_2;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2;
  reg [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0;
  wire STORE_LOOP_STORE_LOOP_and_cse_1;
  wire STORE_LOOP_STORE_LOOP_nor_1_cse_1;
  wire STORE_LOOP_equal_tmp_mx0w0;
  wire STORE_LOOP_equal_tmp_1_mx0w0;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0;
  reg STORE_LOOP_equal_tmp_2;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [74:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  reg [7:0] STORE_LOOP_i_7_0_sva_1_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  reg CALC_SOFTMAX_LOOP_asn_3_itm_1;
  reg exit_STORE_CTRL_LOOP_lpi_2_dfm_3;
  reg STORE_LOOP_asn_20_itm_1;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3;
  reg CALC_SOFTMAX_LOOP_asn_itm_9;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_9;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2;
  reg BATCH_LOOP_stage_0_11;
  reg BATCH_LOOP_stage_0_12;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0;
  reg BATCH_LOOP_stage_v_9;
  reg BATCH_LOOP_stage_0_10;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_2;
  reg exitL_exit_STORE_LOOP_sva;
  reg exit_STORE_CTRL_LOOP_lpi_2;
  reg STORE_LOOP_STORE_LOOP_and_10_itm_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0;
  reg BATCH_LOOP_stage_v_8;
  reg BATCH_LOOP_stage_0_9;
  reg CALC_SOFTMAX_LOOP_asn_itm_8;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_8;
  reg BATCH_LOOP_stage_v_7;
  reg BATCH_LOOP_stage_0_8;
  reg CALC_SOFTMAX_LOOP_asn_itm_4;
  reg BATCH_LOOP_stage_0_7;
  reg BATCH_LOOP_stage_v_6;
  reg BATCH_LOOP_stage_0_6;
  reg CALC_SOFTMAX_LOOP_asn_itm_3;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_3;
  reg BATCH_LOOP_stage_v_5;
  reg BATCH_LOOP_stage_0_5;
  reg BATCH_LOOP_stage_v_3;
  reg BATCH_LOOP_stage_0_4;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2;
  reg BATCH_LOOP_stage_v_2;
  reg BATCH_LOOP_stage_0_3;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_2;
  reg LOAD_LOOP_and_1_svs_st_3;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1;
  reg STORE_LOOP_and_10_itm_3;
  reg BATCH_LOOP_stage_v;
  reg BATCH_LOOP_stage_0;
  reg STORE_LOOP_asn_20_itm_5;
  reg STORE_LOOP_asn_20_itm_3;
  reg LOAD_LOOP_and_1_svs_5;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
  wire or_180_cse;
  reg reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse;
  reg reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse;
  reg reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_acc_done_rsci_ivld_core_psct_cse;
  reg reg_dma_write_chnl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_chnl_rsci_irdy_core_psct_cse;
  reg reg_dma_write_ctrl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_ctrl_rsci_ivld_core_psct_cse;
  reg reg_conf_info_rsci_irdy_core_psct_cse;
  wire STORE_LOOP_and_44_cse;
  wire CALC_SOFTMAX_LOOP_and_cse;
  wire CALC_SOFTMAX_LOOP_and_22_cse;
  wire STORE_LOOP_and_50_cse;
  wire LOAD_LOOP_i_and_cse;
  wire BATCH_LOOP_and_17_cse;
  wire and_938_cse;
  wire or_949_cse;
  wire nor_14_cse;
  wire STORE_LOOP_and_59_cse;
  wire STORE_LOOP_and_62_cse;
  wire or_38_cse;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse;
  wire CALC_SOFTMAX_LOOP_and_23_cse;
  wire CALC_SOFTMAX_LOOP_and_24_cse;
  wire CALC_EXP_LOOP_i_and_1_cse;
  wire STORE_CTRL_LOOP_and_1_cse;
  wire LOAD_LOOP_and_4_cse;
  wire LOAD_LOOP_and_5_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_1_cse;
  wire or_630_cse;
  wire or_929_cse;
  wire or_647_cse;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_and_2_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  wire CALC_SOFTMAX_LOOP_and_30_cse;
  wire and_939_cse;
  wire or_40_cse;
  wire or_39_cse;
  wire or_73_cse;
  wire or_104_cse;
  wire or_103_cse;
  wire or_121_cse;
  wire and_990_cse;
  wire nor_12_cse;
  wire or_23_cse;
  wire or_113_cse;
  wire or_100_cse;
  wire or_114_cse;
  wire or_431_cse;
  wire nor_259_cse;
  wire and_1009_cse;
  wire and_1004_cse;
  wire mux_439_cse;
  wire or_620_cse;
  wire or_688_cse;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0;
  wire STORE_LOOP_asn_76;
  reg [6:0] reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse;
  reg reg_STORE_LOOP_and_8_itm_1_cse;
  wire and_999_cse;
  wire nor_266_cse;
  wire mux_296_cse;
  wire mux_450_cse;
  wire mux_294_cse;
  wire mux_575_cse;
  wire mux_371_cse;
  wire mux_300_cse;
  wire mux_366_cse;
  wire nor_242_cse;
  wire mux_295_cse;
  wire nand_33_cse;
  wire mux_361_cse;
  wire and_298_cse;
  wire and_946_cse;
  wire mux_577_cse;
  wire mux_190_cse;
  wire mux_655_cse;
  wire and_337_cse;
  wire mux_653_cse;
  wire mux_652_cse;
  wire mux_327_cse;
  wire mux_230_cse;
  wire mux_535_cse;
  wire mux_451_cse;
  wire and_238_cse;
  wire mux_654_cse;
  wire and_338_cse;
  wire and_347_cse;
  reg [31:0] plm_out_data_rsci_d_d_reg;
  wire [31:0] CALC_SOFTMAX_LOOP_mux_1_rmff;
  reg [6:0] plm_out_data_rsci_radr_d_reg;
  wire [6:0] STORE_LOOP_i_mux_rmff;
  reg [6:0] plm_out_data_rsci_wadr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_1_rmff;
  wire plm_out_data_rsci_we_d_iff;
  wire and_477_rmff;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_485_rmff;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
  reg [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_rmff;
  reg [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg;
  wire [6:0] CALC_EXP_LOOP_i_mux_rmff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;
  wire and_481_rmff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_479_rmff;
  wire and_475_rmff;
  wire and_247_cse;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2;
  wire mux_694_cse;
  wire or_dcpl;
  wire STORE_LOOP_and_7_itm_mx0w0;
  wire LOAD_LOOP_and_1_svs_mx0w0;
  wire STORE_LOOP_or_tmp_mx0w0;
  wire STORE_LOOP_nor_tmp_mx0w0;
  wire or_960_tmp;
  wire STORE_LOOP_and_21_tmp;
  wire or_956_tmp;
  wire STORE_LOOP_and_3_cse;
  wire and_1027_cse;
  wire and_1028_cse;
  wire [93:0] operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [93:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm;
  wire [72:0] operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2;
  reg [24:0] BATCH_LOOP_acc_3_psp_lpi_2;
  reg [31:0] batch_sva;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3;
  reg [24:0] BATCH_LOOP_acc_3_psp_lpi_2_dfm_2;
  reg BATCH_LOOP_stage_v_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm;
  reg [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm;
  reg CALC_SOFTMAX_LOOP_asn_itm;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm;
  reg CALC_SOFTMAX_LOOP_asn_3_itm;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm;
  reg exit_LOAD_CTRL_LOOP_sva_1;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1;
  reg LOAD_LOOP_and_1_svs_4;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1;
  reg [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
  reg [4:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg [9:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1;
  reg [6:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1;
  reg [6:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_4;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_5;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_6;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_7;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_8;
  reg [6:0] STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9;
  reg STORE_LOOP_and_7_itm_1;
  reg STORE_LOOP_and_7_itm_2;
  reg STORE_LOOP_or_23_itm_1;
  reg STORE_LOOP_or_23_itm_2;
  reg STORE_LOOP_and_10_itm_2;
  reg LOAD_LOOP_and_1_svs_st_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_1;
  reg CALC_SOFTMAX_LOOP_asn_itm_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_6;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_7;
  reg CALC_SOFTMAX_LOOP_asn_itm_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_6;
  reg CALC_SOFTMAX_LOOP_asn_itm_7;
  reg STORE_LOOP_asn_20_itm_2;
  reg STORE_LOOP_asn_20_itm_4;
  reg BATCH_LOOP_stage_0_1;
  reg BATCH_LOOP_stage_0_2;
  reg [6:0] LOAD_LOOP_i_7_0_lpi_2_6_0;
  reg [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_6_0;
  reg [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_6_0;
  reg [6:0] STORE_LOOP_i_7_0_lpi_2_6_0;
  reg [3:0] BATCH_LOOP_b_4_0_sva_3_0;
  reg [6:0] LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0;
  reg [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0;
  reg [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0;
  reg [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0;
  reg [6:0] STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0;
  reg [6:0] SUM_EXP_LOOP_i_7_0_sva_1_1_6_0;
  reg [6:0] CALC_EXP_LOOP_i_7_0_sva_1_1_6_0;
  reg [6:0] LOAD_LOOP_i_7_0_sva_1_1_6_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_8_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0;
  wire [6:0] LOAD_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w2;
  wire exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1;
  wire [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [8:0] nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
  wire [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
  wire [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0;
  wire [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1;
  wire STORE_LOOP_mux1h_17_mx0w1;
  wire BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1;
  wire STORE_LOOP_mux1h_18_mx0w1;
  wire [6:0] LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire BATCH_LOOP_stage_v_2_mx0c0;
  wire BATCH_LOOP_stage_v_3_mx0c0;
  wire BATCH_LOOP_stage_v_4_mx0c0;
  wire BATCH_LOOP_stage_v_5_mx0c0;
  wire [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire exit_STORE_CTRL_LOOP_lpi_2_mx1;
  wire [6:0] STORE_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1;
  wire CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1;
  wire STORE_LOOP_or_23_itm_mx0w0;
  wire STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1;
  wire [6:0] STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1;
  wire BATCH_LOOP_BATCH_LOOP_or_21_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_6_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_4_cse_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [24:0] BATCH_LOOP_acc_3_psp_sva_1;
  wire [25:0] nl_BATCH_LOOP_acc_3_psp_sva_1;
  wire [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_2_6_0_1;
  wire [6:0] libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp;
  wire and_634_cse;
  wire BATCH_LOOP_acc_itm_32_1;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28;
  wire mux_293_cse;
  reg reg_LOAD_LOOP_and_1_svs_1_cse;

  wire[0:0] mux_189_nl;
  wire[0:0] nor_197_nl;
  wire[0:0] mux_188_nl;
  wire[0:0] mux_187_nl;
  wire[0:0] mux_186_nl;
  wire[0:0] mux_185_nl;
  wire[0:0] mux_184_nl;
  wire[0:0] nand_24_nl;
  wire[0:0] nand_23_nl;
  wire[0:0] mux_181_nl;
  wire[0:0] nand_22_nl;
  wire[0:0] mux_180_nl;
  wire[0:0] nor_200_nl;
  wire[0:0] mux_173_nl;
  wire[0:0] nor_201_nl;
  wire[0:0] mux_241_nl;
  wire[0:0] mux_240_nl;
  wire[0:0] mux_239_nl;
  wire[0:0] mux_238_nl;
  wire[0:0] mux_237_nl;
  wire[0:0] mux_755_nl;
  wire[0:0] or_219_nl;
  wire[0:0] mux_236_nl;
  wire[0:0] mux_235_nl;
  wire[0:0] mux_234_nl;
  wire[0:0] mux_233_nl;
  wire[0:0] mux_232_nl;
  wire[0:0] mux_751_nl;
  wire[0:0] mux_262_nl;
  wire[0:0] mux_261_nl;
  wire[0:0] mux_260_nl;
  wire[0:0] mux_259_nl;
  wire[0:0] mux_258_nl;
  wire[0:0] mux_257_nl;
  wire[0:0] mux_256_nl;
  wire[0:0] mux_254_nl;
  wire[0:0] mux_253_nl;
  wire[0:0] mux_760_nl;
  wire[0:0] mux_252_nl;
  wire[0:0] mux_250_nl;
  wire[0:0] mux_249_nl;
  wire[0:0] mux_248_nl;
  wire[0:0] mux_247_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] mux_754_nl;
  wire[0:0] or_227_nl;
  wire[0:0] mux_243_nl;
  wire[0:0] nor_72_nl;
  wire[0:0] and_145_nl;
  wire[0:0] or_738_nl;
  wire[0:0] or_741_nl;
  wire[0:0] mux_759_nl;
  wire[0:0] and_164_nl;
  wire[0:0] and_166_nl;
  wire[0:0] mux_365_nl;
  wire[0:0] mux_364_nl;
  wire[0:0] mux_363_nl;
  wire[0:0] and_185_nl;
  wire[0:0] mux_370_nl;
  wire[0:0] and_184_nl;
  wire[0:0] mux_369_nl;
  wire[0:0] and_183_nl;
  wire[0:0] mux_368_nl;
  wire[0:0] and_182_nl;
  wire[0:0] mux_367_nl;
  wire[0:0] and_181_nl;
  wire[0:0] mux_372_nl;
  wire[0:0] and_187_nl;
  wire[0:0] STORE_LOOP_and_91_nl;
  wire[0:0] mux_432_nl;
  wire[0:0] mux_431_nl;
  wire[0:0] mux_429_nl;
  wire[0:0] mux_428_nl;
  wire[0:0] mux_427_nl;
  wire[0:0] mux_426_nl;
  wire[0:0] mux_425_nl;
  wire[0:0] mux_424_nl;
  wire[0:0] mux_423_nl;
  wire[0:0] or_447_nl;
  wire[0:0] mux_419_nl;
  wire[0:0] mux_418_nl;
  wire[0:0] mux_409_nl;
  wire[0:0] and_935_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl;
  wire[0:0] mux_595_nl;
  wire[0:0] and_945_nl;
  wire[0:0] mux_597_nl;
  wire[0:0] nor_238_nl;
  wire[0:0] BATCH_LOOP_b_not_1_nl;
  wire[0:0] mux_631_nl;
  wire[0:0] nor_184_nl;
  wire[0:0] mux_630_nl;
  wire[0:0] nor_185_nl;
  wire[0:0] mux_641_nl;
  wire[0:0] mux_640_nl;
  wire[0:0] mux_639_nl;
  wire[0:0] mux_756_nl;
  wire[0:0] mux_638_nl;
  wire[0:0] mux_752_nl;
  wire[0:0] nor_186_nl;
  wire[0:0] BATCH_LOOP_mux_23_nl;
  wire[0:0] nor_289_nl;
  wire[0:0] and_334_nl;
  wire[0:0] mux_651_nl;
  wire[0:0] and_333_nl;
  wire[0:0] mux_650_nl;
  wire[0:0] mux_649_nl;
  wire[0:0] mux_648_nl;
  wire[0:0] mux_647_nl;
  wire[0:0] and_335_nl;
  wire[0:0] and_336_nl;
  wire[0:0] mux_659_nl;
  wire[0:0] mux_658_nl;
  wire[0:0] nor_182_nl;
  wire[0:0] nor_183_nl;
  wire[0:0] mux_657_nl;
  wire[0:0] and_339_nl;
  wire[0:0] mux_656_nl;
  wire[0:0] mux_671_nl;
  wire[0:0] and_348_nl;
  wire[0:0] mux_682_nl;
  wire[0:0] and_354_nl;
  wire[0:0] BATCH_LOOP_mux_25_nl;
  wire[0:0] mux_549_nl;
  wire[0:0] nand_65_nl;
  wire[0:0] nand_66_nl;
  wire[0:0] BATCH_LOOP_mux_27_nl;
  wire[0:0] mux_566_nl;
  wire[0:0] nand_62_nl;
  wire[0:0] nand_63_nl;
  wire[0:0] mux_574_nl;
  wire[0:0] mux_576_nl;
  wire[0:0] nor_243_nl;
  wire[0:0] and_297_nl;
  wire[0:0] BATCH_LOOP_mux_29_nl;
  wire[0:0] mux_580_nl;
  wire[0:0] mux_579_nl;
  wire[0:0] nor_241_nl;
  wire[0:0] mux_578_nl;
  wire[0:0] BATCH_LOOP_mux_31_nl;
  wire[0:0] mux_590_nl;
  wire[0:0] mux_589_nl;
  wire[0:0] or_584_nl;
  wire[0:0] mux_588_nl;
  wire[0:0] mux_587_nl;
  wire[0:0] nand_59_nl;
  wire[0:0] BATCH_LOOP_mux_33_nl;
  wire[0:0] mux_594_nl;
  wire[0:0] nand_57_nl;
  wire[0:0] nand_58_nl;
  wire[0:0] BATCH_LOOP_mux_35_nl;
  wire[0:0] mux_596_nl;
  wire[0:0] nand_54_nl;
  wire[0:0] nand_55_nl;
  wire[0:0] LOAD_CTRL_LOOP_not_5_nl;
  wire[0:0] mux_707_nl;
  wire[0:0] and_370_nl;
  wire[0:0] mux_706_nl;
  wire[0:0] mux_718_nl;
  wire[0:0] and_376_nl;
  wire[0:0] and_463_nl;
  wire[0:0] STORE_LOOP_mux_26_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_8_nl;
  wire[0:0] STORE_LOOP_and_90_nl;
  wire[0:0] BATCH_LOOP_if_not_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_1_nl;
  wire[0:0] STORE_LOOP_or_18_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_2_nl;
  wire[0:0] STORE_CTRL_LOOP_mux_nl;
  wire[0:0] STORE_LOOP_i_or_2_nl;
  wire[0:0] STORE_LOOP_mux_37_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_nl;
  wire[0:0] or_645_nl;
  wire[0:0] or_673_nl;
  wire[32:0] BATCH_LOOP_acc_nl;
  wire[33:0] nl_BATCH_LOOP_acc_nl;
  wire[0:0] STORE_LOOP_mux_59_nl;
  wire[0:0] STORE_LOOP_and_38_nl;
  wire[0:0] STORE_LOOP_and_39_nl;
  wire[0:0] STORE_LOOP_or_22_nl;
  wire[1:0] STORE_LOOP_and_nl;
  wire[0:0] nor_292_nl;
  wire[0:0] and_1026_nl;
  wire[0:0] nor_293_nl;
  wire[46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire signed [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire[0:0] mux_56_nl;
  wire[0:0] mux_55_nl;
  wire[0:0] mux_54_nl;
  wire[0:0] mux_149_nl;
  wire[0:0] or_157_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] mux_158_nl;
  wire[0:0] or_161_nl;
  wire[0:0] nand_19_nl;
  wire[0:0] mux_171_nl;
  wire[0:0] mux_170_nl;
  wire[0:0] mux_168_nl;
  wire[0:0] or_942_nl;
  wire[0:0] mux_167_nl;
  wire[0:0] mux_166_nl;
  wire[0:0] nand_17_nl;
  wire[0:0] or_164_nl;
  wire[0:0] mux_164_nl;
  wire[0:0] mux_163_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] mux_161_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] or_163_nl;
  wire[0:0] mux_157_nl;
  wire[0:0] mux_156_nl;
  wire[0:0] mux_155_nl;
  wire[0:0] mux_154_nl;
  wire[0:0] or_160_nl;
  wire[0:0] or_150_nl;
  wire[0:0] or_149_nl;
  wire[0:0] and_69_nl;
  wire[0:0] mux_175_nl;
  wire[0:0] mux_174_nl;
  wire[0:0] and_984_nl;
  wire[0:0] nor_256_nl;
  wire[0:0] mux_219_nl;
  wire[0:0] mux_218_nl;
  wire[0:0] mux_217_nl;
  wire[0:0] mux_229_nl;
  wire[0:0] mux_228_nl;
  wire[0:0] mux_226_nl;
  wire[0:0] mux_225_nl;
  wire[0:0] mux_757_nl;
  wire[0:0] or_211_nl;
  wire[0:0] mux_223_nl;
  wire[0:0] mux_749_nl;
  wire[0:0] mux_221_nl;
  wire[0:0] mux_244_nl;
  wire[0:0] and_978_nl;
  wire[0:0] mux_299_nl;
  wire[0:0] mux_298_nl;
  wire[0:0] and_1014_nl;
  wire[0:0] or_313_nl;
  wire[0:0] mux_297_nl;
  wire[0:0] mux_303_nl;
  wire[0:0] mux_301_nl;
  wire[0:0] or_316_nl;
  wire[0:0] nand_32_nl;
  wire[0:0] mux_311_nl;
  wire[0:0] mux_309_nl;
  wire[0:0] nor_254_nl;
  wire[0:0] and_965_nl;
  wire[0:0] or_50_nl;
  wire[0:0] mux_326_nl;
  wire[0:0] mux_325_nl;
  wire[0:0] mux_323_nl;
  wire[0:0] mux_322_nl;
  wire[0:0] mux_758_nl;
  wire[0:0] or_340_nl;
  wire[0:0] mux_320_nl;
  wire[0:0] mux_753_nl;
  wire[0:0] mux_318_nl;
  wire[0:0] or_36_nl;
  wire[0:0] mux_360_nl;
  wire[0:0] and_178_nl;
  wire[0:0] mux_359_nl;
  wire[0:0] mux_358_nl;
  wire[0:0] mux_357_nl;
  wire[0:0] mux_356_nl;
  wire[0:0] mux_355_nl;
  wire[0:0] mux_354_nl;
  wire[0:0] mux_353_nl;
  wire[0:0] mux_352_nl;
  wire[0:0] mux_351_nl;
  wire[0:0] mux_350_nl;
  wire[0:0] mux_349_nl;
  wire[0:0] mux_348_nl;
  wire[0:0] and_1015_nl;
  wire[0:0] and_217_nl;
  wire[0:0] mux_413_nl;
  wire[0:0] and_216_nl;
  wire[0:0] mux_412_nl;
  wire[0:0] mux_410_nl;
  wire[0:0] mux_415_nl;
  wire[0:0] mux_420_nl;
  wire[0:0] or_441_nl;
  wire[0:0] and_948_nl;
  wire[0:0] nor_142_nl;
  wire[0:0] mux_449_nl;
  wire[0:0] mux_448_nl;
  wire[0:0] mux_447_nl;
  wire[0:0] mux_446_nl;
  wire[0:0] mux_445_nl;
  wire[0:0] or_463_nl;
  wire[0:0] mux_443_nl;
  wire[0:0] mux_438_nl;
  wire[0:0] or_459_nl;
  wire[0:0] mux_436_nl;
  wire[0:0] or_457_nl;
  wire[0:0] or_449_nl;
  wire[0:0] mux_538_nl;
  wire[0:0] nand_46_nl;
  wire[0:0] mux_537_nl;
  wire[0:0] nand_45_nl;
  wire[0:0] mux_536_nl;
  wire[0:0] and_275_nl;
  wire[0:0] mux_556_nl;
  wire[0:0] nor_246_nl;
  wire[0:0] mux_622_nl;
  wire[0:0] mux_621_nl;
  wire[0:0] mux_620_nl;

  // Interconnect Declarations for Component Instantiations 
  wire[10:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire[11:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire [73:0] nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a;
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = conv_s2u_9_11(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])
      + ({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1});
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl[10:0];
  assign nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a = {ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl
      , (ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0])
      , 53'b00000000000000000000000000000000000000000000000000000};
  wire[10:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire[11:0] nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire [20:0] nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a;
  assign nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = conv_u2u_9_11(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])
      + ({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
      , 1'b1 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1});
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = nl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl[10:0];
  assign nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a = {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_nl
      , (ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0])};
  wire [72:0] nl_operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg_a;
  assign nl_operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg_a = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1[72:0];
  wire [0:0] nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg
      = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & and_dcpl_82 & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg
      = (~(or_103_cse | CALC_SOFTMAX_LOOP_asn_3_itm_1)) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat =
      {35'b01100000000000000000000000010000000 , dma_write_ctrl_rsci_idat_31_7 ,
      7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg
      = and_dcpl_84 & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg
      = and_dcpl_79 & (fsm_output[2]);
  wire [63:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat =
      {32'b11011110101011011011111011101111 , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg
      = or_tmp_9 & plm_out_data_rsci_bawt & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b11)
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 | exit_BATCH_LOOP_lpi_2_dfm_st_11))
      & (~ CALC_SOFTMAX_LOOP_asn_itm_11) & BATCH_LOOP_stage_v_11 & BATCH_LOOP_stage_0_12
      & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg
      = mux_655_cse & and_dcpl_27 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0==2'b10)
      & ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      & BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4 & (fsm_output[2]);
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl;
  wire [93:0] nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl
      = LOAD_LOOP_and_1_svs_5 & STORE_LOOP_and_10_itm_3 & (~((~ BATCH_LOOP_stage_v_5)
      | STORE_LOOP_asn_20_itm_5));
  assign nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl);
  esp_acc_softmax_cxx_mgc_shift_br_v5 #(.width_a(32'sd74),
  .signd_a(32'sd0),
  .width_s(32'sd8),
  .width_z(32'sd94)) operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg (
      .a(nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a[73:0]),
      .s(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1),
      .z(operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm)
    );
  esp_acc_softmax_cxx_mgc_shift_bl_v5 #(.width_a(32'sd21),
  .signd_a(32'sd0),
  .width_s(32'sd7),
  .width_z(32'sd67)) operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a[20:0]),
      .s(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1),
      .z(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0)
    );
  esp_acc_softmax_cxx_mgc_shift_l_v5 #(.width_a(32'sd73),
  .signd_a(32'sd0),
  .width_s(32'sd7),
  .width_z(32'sd73)) operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(nl_operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg_a[72:0]),
      .s(libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1),
      .z(operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm)
    );
  esp_acc_softmax_cxx_leading_sign_74_0  leading_sign_74_0_rg (
      .mantissa(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1),
      .rtn(libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_info_rsci softmax_cxx_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt(reg_conf_info_rsci_irdy_core_psct_cse),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci softmax_cxx_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg[0:0]),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_iswt0(reg_dma_read_ctrl_rsci_ivld_core_psct_cse),
      .dma_read_ctrl_rsci_irdy_mxwt(dma_read_ctrl_rsci_irdy_mxwt),
      .dma_read_ctrl_rsci_idat(nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci softmax_cxx_core_dma_write_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg[0:0]),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_iswt0(reg_dma_write_ctrl_rsci_ivld_core_psct_cse),
      .dma_write_ctrl_rsci_irdy_mxwt(dma_write_ctrl_rsci_irdy_mxwt),
      .dma_write_ctrl_rsci_idat(nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci softmax_cxx_core_dma_read_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg[0:0]),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_iswt0(reg_dma_read_chnl_rsci_irdy_core_psct_cse),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci softmax_cxx_core_dma_write_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg[0:0]),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_iswt0(reg_dma_write_chnl_rsci_ivld_core_psct_cse),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_idat(nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat[63:0])
    );
  esp_acc_softmax_cxx_softmax_cxx_core_acc_done_rsci softmax_cxx_core_acc_done_rsci_inst
      (
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .core_wten(core_wten),
      .acc_done_rsci_iswt0(reg_acc_done_rsci_ivld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1 softmax_cxx_core_plm_out_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_data_rsci_oswt_unreg(nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg[0:0]),
      .plm_out_data_rsci_bawt(plm_out_data_rsci_bawt),
      .plm_out_data_rsci_iswt0(reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse),
      .plm_out_data_rsci_oswt_unreg_1(or_tmp_608),
      .plm_out_data_rsci_iswt0_1(reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .plm_out_data_rsci_iswt0_pff(and_477_rmff),
      .plm_out_data_rsci_iswt0_1_pff(and_485_rmff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1
      softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg(nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg[0:0]),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0(reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1(and_475_rmff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1(reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff(and_481_rmff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff(and_479_rmff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg(and_477_rmff),
      .CALC_SOFTMAX_LOOP_mul_cmp_bawt(CALC_SOFTMAX_LOOP_mul_cmp_bawt),
      .CALC_SOFTMAX_LOOP_mul_cmp_iswt5(reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse),
      .CALC_SOFTMAX_LOOP_mul_cmp_a_core(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt),
      .CALC_SOFTMAX_LOOP_mul_cmp_b_core(nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core[93:0]),
      .CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_staller softmax_cxx_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_fsm softmax_cxx_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .BATCH_LOOP_C_0_tr0(BATCH_LOOP_nor_13_tmp)
    );
  assign or_180_cse = (STORE_LOOP_mux1h_44_tmp!=2'b00);
  assign and_938_cse = STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7]);
  assign and_939_cse = STORE_LOOP_and_2_ssc_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_197_nl = ~(lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]));
  assign mux_189_nl = MUX_s_1_2_2(nor_197_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign nand_24_nl = ~(or_180_cse & (~(and_938_cse | nand_tmp_21)));
  assign mux_184_nl = MUX_s_1_2_2(nand_24_nl, mux_tmp_159, and_939_cse);
  assign mux_185_nl = MUX_s_1_2_2(mux_184_nl, mux_tmp_162, BATCH_LOOP_acc_itm_32_1);
  assign nand_22_nl = ~(STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7])
      & (~ nand_tmp_20));
  assign mux_181_nl = MUX_s_1_2_2(mux_tmp_160, nand_22_nl, or_180_cse);
  assign nand_23_nl = ~(BATCH_LOOP_acc_itm_32_1 & (~(STORE_LOOP_and_2_ssc_1 | mux_181_nl)));
  assign mux_186_nl = MUX_s_1_2_2(mux_185_nl, nand_23_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]);
  assign nor_200_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]) | mux_tmp_162);
  assign mux_180_nl = MUX_s_1_2_2(nor_200_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_187_nl = MUX_s_1_2_2((~ mux_186_nl), mux_180_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign nor_201_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_173_nl = MUX_s_1_2_2(nor_201_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_188_nl = MUX_s_1_2_2(mux_187_nl, mux_173_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_190_cse = MUX_s_1_2_2(mux_189_nl, mux_188_nl, nor_14_cse);
  assign and_475_rmff = mux_655_cse & and_dcpl_27 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0==2'b11)
      & and_dcpl_24 & (~ CALC_SOFTMAX_LOOP_asn_itm_4) & (fsm_output[2]);
  assign and_477_rmff = mux_tmp_185 & BATCH_LOOP_stage_0_11 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10) & (~ CALC_SOFTMAX_LOOP_asn_itm_10) &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2)
      & BATCH_LOOP_stage_v_10 & (fsm_output[2]);
  assign and_479_rmff = mux_tmp_197 & and_dcpl_42 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]) & (~ CALC_SOFTMAX_LOOP_asn_itm_3)
      & (fsm_output[2]);
  assign and_481_rmff = mux_tmp_197 & and_dcpl_42 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2)
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])) & (fsm_output[2]);
  assign and_485_rmff = mux_tmp_185 & BATCH_LOOP_stage_0_11 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b00) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2
      & BATCH_LOOP_stage_v_10 & (fsm_output[2]);
  assign CALC_EXP_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg,
      or_tmp_630);
  assign or_738_nl = (~ (fsm_output[2])) | (~ mux_tmp_197) | or_dcpl_23 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])) | CALC_SOFTMAX_LOOP_asn_itm_3;
  assign CALC_SOFTMAX_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg,
      or_738_nl);
  assign operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg,
      or_tmp_630);
  assign CALC_SOFTMAX_LOOP_i_mux_1_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10,
      plm_out_data_rsci_wadr_d_reg, or_tmp_633);
  assign or_741_nl = (~ (fsm_output[2])) | (~ mux_tmp_185) | (~ BATCH_LOOP_stage_0_11)
      | exit_BATCH_LOOP_lpi_2_dfm_st_10 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b00)
      | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2) | (~ BATCH_LOOP_stage_v_10);
  assign STORE_LOOP_i_mux_rmff = MUX_v_7_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9,
      plm_out_data_rsci_radr_d_reg, or_741_nl);
  assign CALC_SOFTMAX_LOOP_mux_1_rmff = MUX_v_32_2_2(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt,
      plm_out_data_rsci_d_d_reg, or_tmp_633);
  assign STORE_LOOP_and_44_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_tmp_197)
      | or_dcpl_16));
  assign mux_293_cse = MUX_s_1_2_2(nor_266_cse, or_tmp_9, or_73_cse);
  assign mux_759_nl = MUX_s_1_2_2(nor_266_cse, or_tmp_9, or_73_cse);
  assign mux_294_cse = MUX_s_1_2_2(nor_266_cse, mux_759_nl, BATCH_LOOP_stage_0_12);
  assign and_164_nl = or_929_cse & BATCH_LOOP_stage_0_11 & mux_294_cse;
  assign mux_295_cse = MUX_s_1_2_2(mux_293_cse, and_164_nl, BATCH_LOOP_stage_v_10);
  assign CALC_SOFTMAX_LOOP_and_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_295_cse)
      | not_tmp_36));
  assign and_166_nl = BATCH_LOOP_stage_0_12 & or_73_cse & or_tmp_9;
  assign mux_296_cse = MUX_s_1_2_2(or_tmp_9, and_166_nl, BATCH_LOOP_stage_v_11);
  assign CALC_SOFTMAX_LOOP_and_22_cse = core_wen & (fsm_output[2]) & or_929_cse &
      mux_296_cse & BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign STORE_LOOP_and_50_cse = core_wen & (fsm_output[2]) & and_tmp_10 & BATCH_LOOP_stage_v_11
      & BATCH_LOOP_stage_0_12;
  assign LOAD_LOOP_i_and_cse = core_wen & ((fsm_output[3:2]!=2'b00));
  assign BATCH_LOOP_and_17_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_13_tmp;
  assign or_949_cse = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2) | STORE_LOOP_or_tmp_1;
  assign nor_14_cse = ~(STORE_LOOP_asn_20_itm_1 | (~ BATCH_LOOP_and_12_tmp));
  assign or_38_cse = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2) | STORE_LOOP_or_tmp_1;
  assign CALC_SOFTMAX_LOOP_and_23_cse = core_wen & (((~ mux_327_cse) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2])) | or_tmp_675);
  assign and_634_cse = (not_tmp_164 | BATCH_LOOP_acc_itm_32_1) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign STORE_LOOP_and_59_cse = core_wen & (and_634_cse | or_tmp_682);
  assign CALC_SOFTMAX_LOOP_and_24_cse = core_wen & (~((~ (fsm_output[2])) | mux_327_cse
      | (~ BATCH_LOOP_and_13_tmp)));
  assign STORE_LOOP_and_62_cse = core_wen & (fsm_output[2]) & (~(mux_tmp_295 & (~
      BATCH_LOOP_acc_itm_32_1))) & BATCH_LOOP_and_13_tmp;
  assign or_113_cse = lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b10)
      | exitL_exit_STORE_LOOP_sva;
  assign or_100_cse = exitL_exit_STORE_LOOP_sva | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | (STORE_LOOP_mux_27_tmp!=2'b10);
  assign or_114_cse = exit_BATCH_LOOP_lpi_2_dfm_1 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b10)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  assign mux_363_nl = MUX_s_1_2_2((~ or_121_cse), BATCH_LOOP_stage_v_11, BATCH_LOOP_stage_v_10);
  assign mux_364_nl = MUX_s_1_2_2(or_tmp_312, mux_363_nl, or_929_cse);
  assign mux_365_nl = MUX_s_1_2_2((~ mux_364_nl), mux_tmp_326, BATCH_LOOP_stage_0_12);
  assign mux_366_cse = MUX_s_1_2_2((~ or_tmp_312), mux_365_nl, BATCH_LOOP_stage_0_11);
  assign and_181_nl = BATCH_LOOP_stage_0_10 & mux_366_cse;
  assign mux_367_nl = MUX_s_1_2_2(mux_tmp_326, and_181_nl, BATCH_LOOP_stage_v_9);
  assign and_182_nl = BATCH_LOOP_stage_0_9 & mux_367_nl;
  assign mux_368_nl = MUX_s_1_2_2(mux_tmp_326, and_182_nl, BATCH_LOOP_stage_v_8);
  assign and_183_nl = BATCH_LOOP_stage_0_8 & mux_368_nl;
  assign mux_369_nl = MUX_s_1_2_2(mux_tmp_326, and_183_nl, BATCH_LOOP_stage_v_7);
  assign and_184_nl = BATCH_LOOP_stage_0_7 & mux_369_nl;
  assign mux_370_nl = MUX_s_1_2_2(mux_tmp_326, and_184_nl, BATCH_LOOP_stage_v_6);
  assign and_185_nl = BATCH_LOOP_stage_0_6 & mux_370_nl;
  assign mux_371_cse = MUX_s_1_2_2(mux_tmp_326, and_185_nl, BATCH_LOOP_stage_v_5);
  assign and_187_nl = BATCH_LOOP_stage_0_5 & or_647_cse & mux_371_cse;
  assign mux_372_nl = MUX_s_1_2_2(mux_tmp_326, and_187_nl, BATCH_LOOP_stage_v_4);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse = core_wen
      & (~((~ (fsm_output[2])) | (~(or_688_cse & or_tmp_9 & mux_372_nl)) | or_dcpl_23
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])
      | (~ LOAD_LOOP_and_1_svs_st_3)));
  assign CALC_EXP_LOOP_i_and_1_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_12_tmp;
  assign STORE_CTRL_LOOP_and_1_cse = core_wen & ((exit_BATCH_LOOP_lpi_2_dfm_1 & BATCH_LOOP_and_12_tmp
      & (fsm_output[2])) | or_tmp_736);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp
      = LOAD_LOOP_and_1_svs_5 & STORE_LOOP_and_10_itm_3 & (~((~ mux_654_cse) | or_dcpl_76
      | STORE_LOOP_asn_20_itm_5));
  assign LOAD_LOOP_and_4_cse = core_wen & BATCH_LOOP_and_12_tmp;
  assign LOAD_LOOP_and_5_cse = core_wen & and_tmp_99;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_1_cse
      = core_wen & and_tmp_98;
  assign and_1004_cse = BATCH_LOOP_stage_v_9 & BATCH_LOOP_stage_0_10;
  assign or_929_cse = lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b11)
      | CALC_SOFTMAX_LOOP_asn_itm_10 | exit_BATCH_LOOP_lpi_2_dfm_st_10 | CALC_SOFTMAX_LOOP_mul_cmp_bawt;
  assign or_630_cse = (STORE_LOOP_mux_27_tmp!=2'b00);
  assign CALC_SOFTMAX_LOOP_and_30_cse = core_wen & ((fsm_output[1]) | or_tmp_784);
  assign or_647_cse = exit_BATCH_LOOP_lpi_2_dfm_st_4 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0!=2'b10)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt;
  assign mux_647_nl = MUX_s_1_2_2((~ mux_tmp_174), or_tmp_175, BATCH_LOOP_stage_v_10);
  assign mux_648_nl = MUX_s_1_2_2(or_tmp_176, mux_647_nl, or_929_cse);
  assign mux_649_nl = MUX_s_1_2_2((~ mux_648_nl), mux_tmp_175, BATCH_LOOP_stage_0_12);
  assign mux_650_nl = MUX_s_1_2_2((~ or_tmp_176), mux_649_nl, BATCH_LOOP_stage_0_11);
  assign and_333_nl = BATCH_LOOP_stage_0_10 & mux_650_nl;
  assign mux_651_nl = MUX_s_1_2_2(mux_tmp_175, and_333_nl, BATCH_LOOP_stage_v_9);
  assign and_334_nl = BATCH_LOOP_stage_0_9 & mux_651_nl;
  assign mux_652_cse = MUX_s_1_2_2(mux_tmp_175, and_334_nl, BATCH_LOOP_stage_v_8);
  assign and_335_nl = BATCH_LOOP_stage_0_8 & mux_652_cse;
  assign mux_653_cse = MUX_s_1_2_2(mux_tmp_175, and_335_nl, BATCH_LOOP_stage_v_7);
  assign and_336_nl = BATCH_LOOP_stage_0_7 & mux_653_cse;
  assign mux_654_cse = MUX_s_1_2_2(mux_tmp_175, and_336_nl, BATCH_LOOP_stage_v_6);
  assign and_337_cse = BATCH_LOOP_stage_0_6 & mux_654_cse;
  assign mux_655_cse = MUX_s_1_2_2(mux_tmp_175, and_337_cse, BATCH_LOOP_stage_v_5);
  assign and_338_cse = BATCH_LOOP_stage_0_5 & mux_655_cse;
  assign and_347_cse = BATCH_LOOP_stage_0_5 & or_647_cse & mux_655_cse;
  assign mux_574_nl = MUX_s_1_2_2(mux_tmp_174, (~ or_tmp_175), BATCH_LOOP_stage_v_10);
  assign mux_575_cse = MUX_s_1_2_2(mux_574_nl, mux_tmp_174, BATCH_LOOP_stage_0_12);
  assign nor_242_cse = ~((~((~ BATCH_LOOP_stage_v_9) | BATCH_LOOP_stage_0_10)) |
      BATCH_LOOP_stage_v_10 | (~ mux_tmp_174));
  assign nor_243_nl = ~(or_tmp_436 | (~ mux_tmp_174));
  assign and_297_nl = BATCH_LOOP_stage_0_10 & mux_575_cse;
  assign mux_576_nl = MUX_s_1_2_2(nor_243_nl, and_297_nl, BATCH_LOOP_stage_0_11);
  assign mux_577_cse = MUX_s_1_2_2(mux_tmp_174, mux_576_nl, BATCH_LOOP_stage_v_9);
  assign and_298_cse = BATCH_LOOP_stage_0_9 & mux_577_cse;
  assign and_946_cse = BATCH_LOOP_stage_0_9 & nor_242_cse;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_and_2_cse = core_wen
      & mux_694_cse;
  assign and_376_nl = or_647_cse & mux_371_cse;
  assign mux_718_nl = MUX_s_1_2_2(mux_tmp_326, and_376_nl, BATCH_LOOP_stage_v_4);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      = core_wen & ((or_688_cse & or_tmp_9 & mux_718_nl) | and_dcpl_244);
  assign LOAD_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      LOAD_LOOP_i_7_0_lpi_2_6_0, or_23_cse);
  assign STORE_LOOP_mux_26_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign lfst_exit_STORE_LOOP_lpi_2_2_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_26_nl, lfst_exit_STORE_LOOP_lpi_2_2,
      or_23_cse);
  assign STORE_LOOP_STORE_LOOP_nor_8_nl = ~(exit_BATCH_LOOP_lpi_2_dfm_1 | or_23_cse);
  assign STORE_LOOP_and_90_nl = exit_BATCH_LOOP_lpi_2_dfm_1 & (~ or_23_cse);
  assign lfst_exit_STORE_LOOP_lpi_2_1_0_mx1 = MUX1HOT_v_2_3_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, lfst_exit_STORE_LOOP_lpi_2_1_0, {STORE_LOOP_STORE_LOOP_nor_8_nl
      , STORE_LOOP_and_90_nl , or_23_cse});
  assign exit_BATCH_LOOP_lpi_2_dfm_mx0w0 = (~ BATCH_LOOP_acc_itm_32_1) & exitL_exit_STORE_LOOP_sva_mx1;
  assign STORE_LOOP_or_tmp_mx0w0 = STORE_LOOP_STORE_LOOP_and_cse_1 | STORE_LOOP_STORE_LOOP_nor_1_cse_1;
  assign STORE_LOOP_equal_tmp_2_mx0w0 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0==2'b00);
  assign STORE_LOOP_nor_tmp_mx0w0 = ~(STORE_LOOP_STORE_LOOP_and_cse_1 | STORE_LOOP_STORE_LOOP_nor_1_cse_1
      | STORE_LOOP_equal_tmp_mx0w0 | STORE_LOOP_equal_tmp_1_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0);
  assign LOAD_LOOP_and_1_svs_mx0w0 = (LOAD_LOOP_acc_1_tmp[7]) & (CALC_EXP_LOOP_acc_1_tmp[7])
      & (SUM_EXP_LOOP_acc_2_tmp[7]);
  assign STORE_LOOP_equal_tmp_mx0w0 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[1])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[0])));
  assign STORE_LOOP_equal_tmp_1_mx0w0 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0==2'b11)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0);
  assign BATCH_LOOP_if_not_nl = ~ BATCH_LOOP_acc_itm_32_1;
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w2 = MUX_v_2_2_2(2'b00, lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
      BATCH_LOOP_if_not_nl);
  assign nl_STORE_LOOP_acc_1_tmp = conv_u2u_7_8(STORE_LOOP_i_7_0_lpi_2_6_0_mx1) +
      8'b00000001;
  assign STORE_LOOP_acc_1_tmp = nl_STORE_LOOP_acc_1_tmp[7:0];
  assign exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0 = (CALC_SOFTMAX_LOOP_i_7_0_sva_2[7])
      | exit_CALC_SOFTMAX_LOOP_lpi_2;
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1 = lfst_exit_STORE_LOOP_lpi_2_2_mx1
      & (~ BATCH_LOOP_acc_itm_32_1);
  assign STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 = (BATCH_LOOP_acc_2_tmp[4])
      & (STORE_LOOP_acc_1_tmp[7]) & STORE_LOOP_equal_tmp_2_mx0w0;
  assign nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0
      = ({1'b1 , (~ libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1)})
      + 8'b00110111;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0
      = nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0[7:0];
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0
      = MUX_v_10_8_2(10'b1111111101, 10'b1100011001, 10'b1001100100, 10'b0111010000,
      10'b0101010100, 10'b0011101011, 10'b0010010001, 10'b0001000100, operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0
      = MUX_v_8_8_2(8'b00011100, 8'b01001011, 8'b01101100, 8'b10000100, 8'b10010111,
      8'b10100110, 8'b10110011, 8'b10111100, operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0
      = ~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000));
  assign and_1027_cse = ~(STORE_LOOP_asn_76 | or_dcpl);
  assign and_1028_cse = STORE_LOOP_asn_76 & (~ or_dcpl);
  assign CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), CALC_EXP_LOOP_i_7_0_sva_1_1_6_0, CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
      {and_1027_cse , and_1028_cse , or_dcpl});
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0
      = MUX1HOT_v_74_3_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      {STORE_LOOP_and_7_itm_2 , reg_STORE_LOOP_and_8_itm_1_cse , STORE_LOOP_or_23_itm_2});
  assign SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), SUM_EXP_LOOP_i_7_0_sva_1_1_6_0, SUM_EXP_LOOP_i_7_0_lpi_2_6_0,
      {and_1027_cse , and_1028_cse , or_dcpl});
  assign LOAD_LOOP_LOAD_LOOP_and_1_nl = exit_CALC_SOFTMAX_LOOP_lpi_2 & (~ LOAD_LOOP_and_1_svs_mx0w0);
  assign STORE_LOOP_or_18_nl = STORE_LOOP_or_tmp_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0
      | STORE_LOOP_nor_tmp_mx0w0;
  assign STORE_LOOP_mux1h_17_mx0w1 = MUX1HOT_s_1_3_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_1_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0, {STORE_LOOP_or_18_nl
      , STORE_LOOP_equal_tmp_mx0w0 , STORE_LOOP_equal_tmp_1_mx0w0});
  assign STORE_LOOP_or_19_cse = STORE_LOOP_or_tmp_1 | STORE_LOOP_equal_tmp_2_1 |
      STORE_LOOP_nor_tmp_1;
  assign LOAD_LOOP_LOAD_LOOP_and_2_nl = exit_STORE_CTRL_LOOP_lpi_2 & (~ reg_LOAD_LOOP_and_1_svs_1_cse);
  assign STORE_LOOP_mux1h_18_mx0w1 = MUX1HOT_s_1_3_2(exit_STORE_CTRL_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_2_nl, CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_or_1_tmp,
      {STORE_LOOP_or_19_cse , STORE_LOOP_equal_tmp_1 , STORE_LOOP_equal_tmp_1_1});
  assign LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~ dma_read_ctrl_rsci_irdy_mxwt)),
      LOAD_LOOP_i_7_0_sva_1_1_6_0, LOAD_LOOP_i_7_0_lpi_2_6_0, {and_1027_cse , and_1028_cse
      , or_dcpl});
  assign SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0, or_23_cse);
  assign CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0, or_23_cse);
  assign STORE_CTRL_LOOP_mux_nl = MUX_s_1_2_2(STORE_LOOP_mux1h_18_mx0w1, exit_STORE_CTRL_LOOP_lpi_2,
      exit_BATCH_LOOP_lpi_2_dfm_1);
  assign exit_STORE_CTRL_LOOP_lpi_2_mx1 = MUX_s_1_2_2(STORE_CTRL_LOOP_mux_nl, exit_STORE_CTRL_LOOP_lpi_2,
      or_23_cse);
  assign STORE_LOOP_i_or_2_nl = exit_BATCH_LOOP_lpi_2_dfm_1 | or_23_cse;
  assign STORE_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1,
      STORE_LOOP_i_7_0_lpi_2_6_0, STORE_LOOP_i_or_2_nl);
  assign STORE_LOOP_STORE_LOOP_nor_nl = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 |
      (lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1!=2'b00));
  assign STORE_LOOP_mux_37_nl = MUX_s_1_2_2(STORE_LOOP_STORE_LOOP_nor_nl, exitL_exit_STORE_LOOP_sva,
      STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign or_645_nl = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_asn_20_itm_1 | (~ BATCH_LOOP_and_12_tmp);
  assign exitL_exit_STORE_LOOP_sva_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_37_nl, exitL_exit_STORE_LOOP_sva,
      or_645_nl);
  assign or_673_nl = (~ BATCH_LOOP_stage_v_3) | STORE_LOOP_asn_20_itm_3;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      or_673_nl);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      + conv_u2u_67_74(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[73:0];
  assign STORE_LOOP_and_7_itm_mx0w0 = STORE_LOOP_or_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign STORE_LOOP_or_23_itm_mx0w0 = STORE_LOOP_equal_tmp_1_1 | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_nor_tmp_1 | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1,
      94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3);
  assign nl_BATCH_LOOP_acc_2_tmp = conv_u2u_4_5(BATCH_LOOP_b_4_0_sva_3_0) + 5'b00001;
  assign BATCH_LOOP_acc_2_tmp = nl_BATCH_LOOP_acc_2_tmp[4:0];
  assign nl_LOAD_LOOP_acc_1_tmp = conv_u2u_7_8(LOAD_LOOP_i_7_0_lpi_2_6_0_mx1) + 8'b00000001;
  assign LOAD_LOOP_acc_1_tmp = nl_LOAD_LOOP_acc_1_tmp[7:0];
  assign nl_CALC_EXP_LOOP_acc_1_tmp = conv_u2u_7_8(CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1)
      + 8'b00000001;
  assign CALC_EXP_LOOP_acc_1_tmp = nl_CALC_EXP_LOOP_acc_1_tmp[7:0];
  assign nl_SUM_EXP_LOOP_acc_2_tmp = conv_u2u_7_8(SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1)
      + 8'b00000001;
  assign SUM_EXP_LOOP_acc_2_tmp = nl_SUM_EXP_LOOP_acc_2_tmp[7:0];
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1,
      lfst_exit_STORE_LOOP_lpi_2_2_mx1, not_tmp_164);
  assign nl_BATCH_LOOP_acc_nl = ({29'b10000000000000000000000000000 , BATCH_LOOP_b_4_0_sva_3_0})
      + conv_u2u_32_33(~ batch_sva) + 33'b000000000000000000000000000000001;
  assign BATCH_LOOP_acc_nl = nl_BATCH_LOOP_acc_nl[32:0];
  assign BATCH_LOOP_acc_itm_32_1 = readslicef_33_1_32(BATCH_LOOP_acc_nl);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0 = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w2,
      lfst_exit_STORE_LOOP_lpi_2_1_0_mx1, not_tmp_164);
  assign STORE_LOOP_mux_59_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2, and_938_cse);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 = (STORE_LOOP_mux_59_nl & (~(STORE_LOOP_or_tmp_1
      | STORE_LOOP_and_2_ssc_1))) | STORE_LOOP_and_4_ssc_1;
  assign STORE_LOOP_and_3_cse = (~ CALC_SOFTMAX_LOOP_and_svs_1) & STORE_LOOP_equal_tmp_1_1;
  assign STORE_LOOP_and_38_nl = (~ dma_read_ctrl_rsci_irdy_mxwt) & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_and_39_nl = dma_read_ctrl_rsci_irdy_mxwt & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_or_22_nl = ((~ reg_LOAD_LOOP_and_1_svs_1_cse) & STORE_LOOP_equal_tmp_1)
      | STORE_LOOP_and_3_cse | ((~ (STORE_LOOP_i_7_0_sva_1_1[7])) & STORE_LOOP_equal_tmp_2_1)
      | STORE_LOOP_nor_tmp_1;
  assign STORE_LOOP_mux1h_44_tmp = MUX1HOT_v_2_3_2(2'b01, 2'b10, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
      {STORE_LOOP_and_38_nl , STORE_LOOP_and_39_nl , STORE_LOOP_or_22_nl});
  assign STORE_LOOP_and_nl = STORE_LOOP_mux1h_44_tmp & (signext_2_1(~ and_938_cse))
      & (signext_2_1(~ STORE_LOOP_and_4_ssc_1));
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1 = MUX_v_2_2_2(STORE_LOOP_and_nl,
      2'b11, STORE_LOOP_and_2_ssc_1);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_or_1_tmp = dma_write_ctrl_rsci_irdy_mxwt
      | exit_STORE_CTRL_LOOP_lpi_2;
  assign or_956_tmp = STORE_LOOP_nor_tmp_1 | STORE_LOOP_equal_tmp_1 | STORE_LOOP_or_tmp_1
      | STORE_LOOP_and_3_cse;
  assign nor_292_nl = ~(STORE_LOOP_equal_tmp_2_1 | or_956_tmp);
  assign and_1026_nl = STORE_LOOP_equal_tmp_2_1 & (~ or_956_tmp);
  assign STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1 = MUX1HOT_v_7_3_2((signext_7_1(~ CALC_SOFTMAX_LOOP_and_svs_1)),
      (STORE_LOOP_i_7_0_sva_1_1[6:0]), STORE_LOOP_i_7_0_lpi_2_6_0, {nor_292_nl ,
      and_1026_nl , or_956_tmp});
  assign CALC_SOFTMAX_LOOP_and_svs_1 = exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_or_1_tmp;
  assign STORE_LOOP_and_2_ssc_1 = reg_LOAD_LOOP_and_1_svs_1_cse & STORE_LOOP_equal_tmp_1;
  assign STORE_LOOP_and_4_ssc_1 = CALC_SOFTMAX_LOOP_and_svs_1 & STORE_LOOP_equal_tmp_1_1;
  assign BATCH_LOOP_BATCH_LOOP_or_21_cse_1 = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      | (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[1]) & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0]))) & (~ exit_BATCH_LOOP_lpi_2_dfm_st_4)
      & BATCH_LOOP_stage_v_4));
  assign BATCH_LOOP_BATCH_LOOP_or_6_cse_1 = CALC_SOFTMAX_LOOP_mul_cmp_bawt | (~((~
      CALC_SOFTMAX_LOOP_asn_itm_10) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2) & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10)
      & BATCH_LOOP_stage_v_10));
  assign BATCH_LOOP_BATCH_LOOP_or_4_cse_1 = plm_out_data_rsci_bawt | (~((~ CALC_SOFTMAX_LOOP_asn_itm_11)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_11) & BATCH_LOOP_stage_v_11));
  assign BATCH_LOOP_BATCH_LOOP_or_cse_1 = dma_write_chnl_rsci_bawt | (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0==2'b00) & (~ exit_BATCH_LOOP_lpi_2_dfm_st_12)
      & BATCH_LOOP_stage_v_12));
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = conv_u2u_19_19(({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
      , 1'b0 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1})
      * ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1);
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = $signed(({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1}))
      * $signed(conv_u2s_10_11(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:0];
  assign nl_BATCH_LOOP_acc_3_psp_sva_1 = (batch_sva[24:0]) + conv_u2u_4_25(BATCH_LOOP_b_4_0_sva_3_0);
  assign BATCH_LOOP_acc_3_psp_sva_1 = nl_BATCH_LOOP_acc_3_psp_sva_1[24:0];
  assign nl_CALC_SOFTMAX_LOOP_i_7_0_sva_2 = conv_u2u_7_8(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0)
      + 8'b00000001;
  assign CALC_SOFTMAX_LOOP_i_7_0_sva_2 = nl_CALC_SOFTMAX_LOOP_i_7_0_sva_2[7:0];
  assign STORE_LOOP_STORE_LOOP_and_cse_1 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[0])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[1])));
  assign STORE_LOOP_STORE_LOOP_nor_1_cse_1 = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0!=2'b00));
  assign or_960_tmp = STORE_LOOP_nor_tmp_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0 | (exit_CALC_SOFTMAX_LOOP_lpi_2
      & STORE_LOOP_equal_tmp_1_mx0w0) | (STORE_LOOP_equal_tmp_mx0w0 & (~ LOAD_LOOP_and_1_svs_mx0w0))
      | STORE_LOOP_or_tmp_mx0w0;
  assign STORE_LOOP_and_21_tmp = (~ exit_CALC_SOFTMAX_LOOP_lpi_2) & STORE_LOOP_equal_tmp_1_mx0w0;
  assign nor_293_nl = ~(STORE_LOOP_and_21_tmp | or_960_tmp);
  assign CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_2_6_0_1 = MUX1HOT_v_7_3_2((signext_7_1(~
      LOAD_LOOP_and_1_svs_mx0w0)), (CALC_SOFTMAX_LOOP_i_7_0_sva_2[6:0]), CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
      {nor_293_nl , STORE_LOOP_and_21_tmp , or_960_tmp});
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = $signed((dma_read_chnl_rsci_idat_mxwt)) * $signed(16'b0101110001010101);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl[46:0];
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28
      = readslicef_47_19_28(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl);
  assign STORE_LOOP_asn_76 = STORE_LOOP_equal_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign BATCH_LOOP_nor_13_tmp = ~((~(BATCH_LOOP_stage_v_12 & BATCH_LOOP_BATCH_LOOP_or_cse_1))
      | (BATCH_LOOP_stage_0 & (mux_451_cse | (~ BATCH_LOOP_and_13_tmp))) | BATCH_LOOP_stage_0_1
      | BATCH_LOOP_stage_0_2 | BATCH_LOOP_stage_0_3 | BATCH_LOOP_stage_0_4 | BATCH_LOOP_stage_0_5
      | BATCH_LOOP_stage_0_6 | BATCH_LOOP_stage_0_7 | BATCH_LOOP_stage_0_8 | BATCH_LOOP_stage_0_9
      | BATCH_LOOP_stage_0_10 | BATCH_LOOP_stage_0_11 | BATCH_LOOP_stage_0_12);
  assign BATCH_LOOP_and_13_tmp = BATCH_LOOP_stage_v & (~(BATCH_LOOP_stage_v_1 & (~
      BATCH_LOOP_and_12_tmp))) & BATCH_LOOP_stage_0_1 & BATCH_LOOP_BATCH_LOOP_or_21_cse_1
      & BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign STORE_LOOP_mux_27_tmp = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign BATCH_LOOP_and_12_tmp = BATCH_LOOP_stage_v_1 & (~(BATCH_LOOP_stage_v_2 &
      (not_tmp_183 | or_dcpl_58))) & BATCH_LOOP_stage_0_2 & (dma_read_ctrl_rsci_bawt
      | (~(((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]) & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])))) | (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b00))))) | exit_BATCH_LOOP_lpi_2_dfm_1)
      & (dma_read_chnl_rsci_bawt | (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])))
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1)))) & (dma_write_ctrl_rsci_bawt | (~((~ CALC_SOFTMAX_LOOP_asn_3_itm_1)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1)))) & BATCH_LOOP_BATCH_LOOP_or_21_cse_1 &
      BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign or_tmp_9 = (~ BATCH_LOOP_stage_v_12) | dma_write_chnl_rsci_bawt | exit_BATCH_LOOP_lpi_2_dfm_st_12
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]);
  assign nor_12_cse = ~(STORE_LOOP_or_tmp_1 | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2));
  assign or_23_cse = (~ BATCH_LOOP_and_12_tmp) | STORE_LOOP_asn_20_itm_1;
  assign not_tmp_28 = ~((STORE_LOOP_mux_27_tmp==2'b11));
  assign or_40_cse = STORE_LOOP_equal_tmp_1_1 | not_tmp_28;
  assign or_39_cse = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  assign and_999_cse = or_39_cse & STORE_LOOP_equal_tmp_1_1;
  assign or_tmp_39 = and_999_cse | not_tmp_28;
  assign mux_54_nl = MUX_s_1_2_2(or_tmp_39, or_40_cse, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_55_nl = MUX_s_1_2_2(mux_54_nl, or_40_cse, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_56_nl = MUX_s_1_2_2(mux_55_nl, or_40_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_tmp_40 = MUX_s_1_2_2(or_tmp_39, mux_56_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign not_tmp_36 = ~(BATCH_LOOP_stage_0_10 & BATCH_LOOP_stage_v_9);
  assign or_73_cse = plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_11 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 | exit_BATCH_LOOP_lpi_2_dfm_st_11;
  assign and_1009_cse = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_0_9;
  assign or_104_cse = STORE_LOOP_equal_tmp_1_1 | (STORE_LOOP_mux_27_tmp!=2'b10);
  assign or_103_cse = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  assign and_tmp_10 = or_73_cse & or_tmp_9;
  assign or_121_cse = (~ BATCH_LOOP_stage_v_11) | plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_11
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_11;
  assign and_tmp_22 = or_121_cse & or_tmp_9;
  assign and_990_cse = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_0_8;
  assign nor_266_cse = ~(BATCH_LOOP_stage_v_11 | (~ or_tmp_9));
  assign or_dcpl_8 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b00) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2)
      | exit_BATCH_LOOP_lpi_2_dfm_st_11 | (~ BATCH_LOOP_stage_v_11) | (~ BATCH_LOOP_stage_0_12);
  assign and_dcpl_22 = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0])) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]));
  assign and_dcpl_23 = and_dcpl_22 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_12) & (~ dma_write_chnl_rsci_bawt)
      & BATCH_LOOP_stage_v_12;
  assign mux_tmp_131 = MUX_s_1_2_2(or_103_cse, (~ or_103_cse), dma_write_ctrl_rsci_irdy_mxwt);
  assign or_157_nl = exit_STORE_CTRL_LOOP_lpi_2 | mux_tmp_131;
  assign mux_149_nl = MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2, or_157_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]);
  assign mux_tmp_133 = MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2, mux_149_nl, STORE_LOOP_equal_tmp_1_1);
  assign mux_tmp_134 = MUX_s_1_2_2(mux_tmp_131, (~ or_103_cse), exit_STORE_CTRL_LOOP_lpi_2);
  assign and_tmp_34 = STORE_LOOP_equal_tmp_1_1 & mux_tmp_134;
  assign mux_tmp_136 = MUX_s_1_2_2(and_tmp_34, mux_tmp_133, STORE_LOOP_or_19_cse);
  assign or_tmp_149 = and_938_cse | mux_tmp_133;
  assign nand_tmp_15 = ~(STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7])
      & (~ mux_tmp_133));
  assign mux_158_nl = MUX_s_1_2_2(and_tmp_34, mux_tmp_133, STORE_LOOP_nor_tmp_1);
  assign or_161_nl = (STORE_LOOP_i_7_0_sva_1_1[7]) | mux_tmp_133;
  assign mux_159_nl = MUX_s_1_2_2(mux_158_nl, or_161_nl, STORE_LOOP_equal_tmp_2_1);
  assign or_tmp_152 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 | mux_159_nl;
  assign nor_259_cse = ~((STORE_LOOP_mux1h_44_tmp!=2'b00));
  assign mux_167_nl = MUX_s_1_2_2(or_tmp_152, or_tmp_149, STORE_LOOP_or_tmp_1);
  assign or_942_nl = nor_259_cse | mux_167_nl;
  assign nand_17_nl = ~(or_180_cse & (~(nor_12_cse | or_tmp_149)));
  assign mux_166_nl = MUX_s_1_2_2(nand_17_nl, mux_tmp_136, reg_LOAD_LOOP_and_1_svs_1_cse);
  assign mux_168_nl = MUX_s_1_2_2(or_942_nl, mux_166_nl, STORE_LOOP_equal_tmp_1);
  assign or_163_nl = STORE_LOOP_equal_tmp_2_1 | STORE_LOOP_nor_tmp_1;
  assign mux_160_nl = MUX_s_1_2_2(and_tmp_34, mux_tmp_133, or_163_nl);
  assign mux_161_nl = MUX_s_1_2_2(mux_160_nl, nand_tmp_15, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_162_nl = MUX_s_1_2_2(mux_161_nl, or_tmp_152, lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2);
  assign mux_163_nl = MUX_s_1_2_2(mux_162_nl, mux_tmp_133, STORE_LOOP_or_tmp_1);
  assign mux_154_nl = MUX_s_1_2_2(mux_tmp_133, nand_tmp_15, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign or_160_nl = lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 | or_tmp_149;
  assign mux_155_nl = MUX_s_1_2_2(mux_154_nl, or_160_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2);
  assign mux_156_nl = MUX_s_1_2_2(mux_155_nl, mux_tmp_133, STORE_LOOP_or_tmp_1);
  assign mux_157_nl = MUX_s_1_2_2(mux_156_nl, mux_tmp_136, reg_LOAD_LOOP_and_1_svs_1_cse);
  assign mux_164_nl = MUX_s_1_2_2(mux_163_nl, mux_157_nl, STORE_LOOP_equal_tmp_1);
  assign or_164_nl = exitL_exit_STORE_LOOP_sva | mux_164_nl;
  assign mux_170_nl = MUX_s_1_2_2(mux_168_nl, or_164_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign or_150_nl = exitL_exit_STORE_LOOP_sva | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | exit_STORE_CTRL_LOOP_lpi_2;
  assign mux_171_nl = MUX_s_1_2_2(mux_170_nl, or_150_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nand_19_nl = ~((STORE_LOOP_mux_27_tmp==2'b11) & (~ mux_171_nl));
  assign or_149_nl = (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[0])) | lfst_exit_STORE_LOOP_lpi_2_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[1])) | exitL_exit_STORE_LOOP_sva | exit_STORE_CTRL_LOOP_lpi_2;
  assign mux_tmp_155 = MUX_s_1_2_2(nand_19_nl, or_149_nl, or_23_cse);
  assign and_984_nl = dma_write_ctrl_rsci_irdy_mxwt & STORE_LOOP_equal_tmp_1_1;
  assign mux_174_nl = MUX_s_1_2_2(and_984_nl, STORE_LOOP_equal_tmp_1_1, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_175_nl = MUX_s_1_2_2(mux_174_nl, STORE_LOOP_equal_tmp_1_1, exit_STORE_CTRL_LOOP_lpi_2);
  assign and_69_nl = exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & mux_175_nl;
  assign mux_tmp_159 = MUX_s_1_2_2(and_69_nl, STORE_LOOP_equal_tmp_1_1, or_39_cse);
  assign nand_tmp_20 = ~(or_38_cse & (~ mux_tmp_159));
  assign nand_tmp_21 = ~(or_949_cse & (~ mux_tmp_159));
  assign mux_tmp_160 = MUX_s_1_2_2(nand_tmp_21, nand_tmp_20, and_938_cse);
  assign mux_tmp_162 = MUX_s_1_2_2(mux_tmp_160, mux_tmp_159, STORE_LOOP_and_2_ssc_1);
  assign and_dcpl_24 = BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4;
  assign and_dcpl_27 = ~(exit_BATCH_LOOP_lpi_2_dfm_st_4 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2);
  assign or_tmp_175 = BATCH_LOOP_stage_v_11 | (~ or_tmp_9);
  assign mux_tmp_174 = MUX_s_1_2_2((~ or_tmp_175), or_tmp_9, or_73_cse);
  assign or_tmp_176 = BATCH_LOOP_stage_v_10 | (~ mux_tmp_174);
  assign mux_tmp_175 = MUX_s_1_2_2((~ or_tmp_176), mux_tmp_174, or_929_cse);
  assign nor_256_nl = ~(BATCH_LOOP_stage_v_11 | and_dcpl_23);
  assign mux_tmp_185 = MUX_s_1_2_2(nor_256_nl, and_tmp_22, BATCH_LOOP_stage_0_12);
  assign and_dcpl_42 = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3;
  assign mux_tmp_197 = MUX_s_1_2_2(mux_tmp_175, and_347_cse, BATCH_LOOP_stage_v_4);
  assign and_dcpl_79 = and_dcpl_22 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_12) & dma_write_chnl_rsci_bawt
      & BATCH_LOOP_stage_v_12;
  assign or_tmp_197 = and_999_cse | (STORE_LOOP_mux_27_tmp!=2'b10);
  assign mux_217_nl = MUX_s_1_2_2(or_tmp_197, or_104_cse, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_218_nl = MUX_s_1_2_2(mux_217_nl, or_104_cse, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_219_nl = MUX_s_1_2_2(mux_218_nl, or_104_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_tmp_203 = MUX_s_1_2_2(or_tmp_197, mux_219_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign nand_tmp_25 = ~(STORE_LOOP_and_2_ssc_1 & (~ mux_tmp_203));
  assign mux_757_nl = MUX_s_1_2_2(nand_tmp_25, mux_tmp_203, or_949_cse);
  assign mux_225_nl = MUX_s_1_2_2(mux_757_nl, nand_tmp_25, and_938_cse);
  assign mux_226_nl = MUX_s_1_2_2(nand_tmp_25, mux_225_nl, or_180_cse);
  assign mux_749_nl = MUX_s_1_2_2(nand_tmp_25, mux_tmp_203, or_949_cse);
  assign mux_221_nl = MUX_s_1_2_2(nand_tmp_25, mux_tmp_203, or_38_cse);
  assign mux_223_nl = MUX_s_1_2_2(mux_749_nl, mux_221_nl, and_938_cse);
  assign or_211_nl = exitL_exit_STORE_LOOP_sva | mux_223_nl;
  assign mux_228_nl = MUX_s_1_2_2(mux_226_nl, or_211_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_229_nl = MUX_s_1_2_2(mux_228_nl, or_100_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_230_cse = MUX_s_1_2_2(or_113_cse, mux_229_nl, nor_14_cse);
  assign and_dcpl_82 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp;
  assign and_dcpl_84 = (~ or_103_cse) & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]))
      & and_dcpl_82;
  assign nand_tmp_26 = ~(STORE_LOOP_and_2_ssc_1 & (~ or_104_cse));
  assign or_tmp_213 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]));
  assign and_978_nl = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]) & exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1;
  assign mux_244_nl = MUX_s_1_2_2(or_103_cse, mux_tmp_134, and_978_nl);
  assign and_tmp_51 = STORE_LOOP_equal_tmp_1_1 & mux_244_nl;
  assign or_tmp_220 = (~ BATCH_LOOP_and_12_tmp) | exit_BATCH_LOOP_lpi_2_dfm_1 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]));
  assign or_dcpl_16 = ~(BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3);
  assign or_dcpl_23 = or_dcpl_16 | exit_BATCH_LOOP_lpi_2_dfm_st_3 | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]));
  assign or_tmp_249 = STORE_LOOP_asn_20_itm_1 | exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_STORE_LOOP_and_10_itm_1;
  assign or_tmp_254 = ((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & STORE_LOOP_equal_tmp_1_1) | STORE_LOOP_and_2_ssc_1;
  assign or_tmp_256 = and_999_cse | STORE_LOOP_and_2_ssc_1;
  assign and_1014_nl = dma_write_ctrl_rsci_irdy_mxwt & exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1;
  assign mux_298_nl = MUX_s_1_2_2(or_tmp_256, or_tmp_254, and_1014_nl);
  assign or_313_nl = ((exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) & STORE_LOOP_equal_tmp_1_1) | STORE_LOOP_and_2_ssc_1;
  assign mux_299_nl = MUX_s_1_2_2(mux_298_nl, or_313_nl, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_297_nl = MUX_s_1_2_2(or_tmp_256, or_tmp_254, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_300_cse = MUX_s_1_2_2(mux_299_nl, mux_297_nl, exit_STORE_CTRL_LOOP_lpi_2);
  assign nand_33_cse = ~(or_949_cse & (~ mux_300_cse));
  assign or_316_nl = (STORE_LOOP_mux1h_44_tmp!=2'b00) | nand_33_cse;
  assign nand_32_nl = ~(or_38_cse & (~ mux_300_cse));
  assign mux_301_nl = MUX_s_1_2_2(or_316_nl, nand_32_nl, and_938_cse);
  assign mux_303_nl = MUX_s_1_2_2((~ exitL_exit_STORE_LOOP_sva), mux_301_nl, BATCH_LOOP_and_12_tmp);
  assign not_tmp_164 = MUX_s_1_2_2(mux_303_nl, (~ exitL_exit_STORE_LOOP_sva), or_tmp_249);
  assign nor_254_nl = ~((STORE_LOOP_mux1h_44_tmp!=2'b00) | nand_33_cse);
  assign and_965_nl = or_38_cse & (~ mux_300_cse);
  assign mux_309_nl = MUX_s_1_2_2(nor_254_nl, and_965_nl, and_938_cse);
  assign mux_311_nl = MUX_s_1_2_2(exitL_exit_STORE_LOOP_sva, mux_309_nl, BATCH_LOOP_and_12_tmp);
  assign mux_tmp_295 = MUX_s_1_2_2(mux_311_nl, exitL_exit_STORE_LOOP_sva, or_tmp_249);
  assign nand_tmp_36 = ~(STORE_LOOP_and_2_ssc_1 & (~ mux_tmp_40));
  assign or_50_nl = lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b11)
      | exitL_exit_STORE_LOOP_sva;
  assign mux_758_nl = MUX_s_1_2_2(nand_tmp_36, mux_tmp_40, or_949_cse);
  assign mux_322_nl = MUX_s_1_2_2(mux_758_nl, nand_tmp_36, and_938_cse);
  assign mux_323_nl = MUX_s_1_2_2(nand_tmp_36, mux_322_nl, or_180_cse);
  assign mux_753_nl = MUX_s_1_2_2(nand_tmp_36, mux_tmp_40, or_949_cse);
  assign mux_318_nl = MUX_s_1_2_2(nand_tmp_36, mux_tmp_40, or_38_cse);
  assign mux_320_nl = MUX_s_1_2_2(mux_753_nl, mux_318_nl, and_938_cse);
  assign or_340_nl = exitL_exit_STORE_LOOP_sva | mux_320_nl;
  assign mux_325_nl = MUX_s_1_2_2(mux_323_nl, or_340_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign or_36_nl = exitL_exit_STORE_LOOP_sva | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | not_tmp_28;
  assign mux_326_nl = MUX_s_1_2_2(mux_325_nl, or_36_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_327_cse = MUX_s_1_2_2(or_50_nl, mux_326_nl, nor_14_cse);
  assign or_dcpl_58 = ~(BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2);
  assign or_tmp_312 = BATCH_LOOP_stage_v_10 | (~ or_121_cse);
  assign mux_tmp_326 = MUX_s_1_2_2((~ or_tmp_312), or_121_cse, or_929_cse);
  assign not_tmp_182 = ~(BATCH_LOOP_stage_v_3 | (~ mux_tmp_326));
  assign mux_360_nl = MUX_s_1_2_2(not_tmp_182, mux_tmp_326, BATCH_LOOP_stage_0_4);
  assign mux_348_nl = MUX_s_1_2_2(mux_tmp_326, mux_366_cse, BATCH_LOOP_stage_v_3);
  assign mux_349_nl = MUX_s_1_2_2(not_tmp_182, mux_348_nl, BATCH_LOOP_stage_0_10);
  assign mux_350_nl = MUX_s_1_2_2(mux_tmp_326, mux_349_nl, BATCH_LOOP_stage_v_9);
  assign mux_351_nl = MUX_s_1_2_2(not_tmp_182, mux_350_nl, BATCH_LOOP_stage_0_9);
  assign mux_352_nl = MUX_s_1_2_2(mux_tmp_326, mux_351_nl, BATCH_LOOP_stage_v_8);
  assign mux_353_nl = MUX_s_1_2_2(not_tmp_182, mux_352_nl, BATCH_LOOP_stage_0_8);
  assign mux_354_nl = MUX_s_1_2_2(mux_tmp_326, mux_353_nl, BATCH_LOOP_stage_v_7);
  assign mux_355_nl = MUX_s_1_2_2(not_tmp_182, mux_354_nl, BATCH_LOOP_stage_0_7);
  assign mux_356_nl = MUX_s_1_2_2(mux_tmp_326, mux_355_nl, BATCH_LOOP_stage_v_6);
  assign mux_357_nl = MUX_s_1_2_2(not_tmp_182, mux_356_nl, BATCH_LOOP_stage_0_6);
  assign mux_358_nl = MUX_s_1_2_2(mux_tmp_326, mux_357_nl, BATCH_LOOP_stage_v_5);
  assign and_1015_nl = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_0_5;
  assign mux_359_nl = MUX_s_1_2_2(not_tmp_182, mux_358_nl, and_1015_nl);
  assign and_178_nl = or_647_cse & mux_359_nl;
  assign mux_361_cse = MUX_s_1_2_2(mux_360_nl, and_178_nl, BATCH_LOOP_stage_v_4);
  assign not_tmp_183 = ~(or_tmp_9 & mux_361_cse);
  assign or_dcpl_72 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2);
  assign and_dcpl_107 = BATCH_LOOP_stage_0_6 & BATCH_LOOP_stage_v_5;
  assign or_dcpl_76 = ~(BATCH_LOOP_stage_0_6 & BATCH_LOOP_stage_v_5);
  assign or_431_cse = (~ exitL_exit_STORE_LOOP_sva) | BATCH_LOOP_acc_itm_32_1;
  assign mux_413_nl = MUX_s_1_2_2(or_39_cse, (~ or_39_cse), CALC_SOFTMAX_LOOP_and_svs_1);
  assign and_217_nl = STORE_LOOP_equal_tmp_1_1 & mux_413_nl;
  assign mux_410_nl = MUX_s_1_2_2(or_39_cse, (~ or_39_cse), exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_412_nl = MUX_s_1_2_2(or_39_cse, mux_410_nl, exit_STORE_CTRL_LOOP_lpi_2);
  assign and_216_nl = STORE_LOOP_equal_tmp_1_1 & mux_412_nl;
  assign mux_tmp_397 = MUX_s_1_2_2(and_217_nl, and_216_nl, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign nand_tmp_39 = ~(or_38_cse & (~ mux_tmp_397));
  assign nand_tmp_40 = ~(or_949_cse & (~ mux_tmp_397));
  assign mux_415_nl = MUX_s_1_2_2(nand_tmp_40, nand_tmp_39, and_938_cse);
  assign mux_tmp_400 = MUX_s_1_2_2(mux_415_nl, mux_tmp_397, STORE_LOOP_and_2_ssc_1);
  assign or_441_nl = (STORE_LOOP_mux1h_44_tmp!=2'b00) | nand_tmp_40;
  assign mux_420_nl = MUX_s_1_2_2(or_441_nl, nand_tmp_39, and_938_cse);
  assign or_tmp_362 = BATCH_LOOP_acc_itm_32_1 | STORE_LOOP_and_2_ssc_1 | mux_420_nl;
  assign or_tmp_367 = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_STORE_LOOP_and_10_itm_1;
  assign mux_439_cse = MUX_s_1_2_2((~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2), BATCH_LOOP_acc_itm_32_1,
      exitL_exit_STORE_LOOP_sva);
  assign and_948_nl = exitL_exit_STORE_LOOP_sva & BATCH_LOOP_acc_itm_32_1;
  assign nor_142_nl = ~((~ lfst_exit_STORE_LOOP_lpi_2_2) | (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b00)
      | (~ (BATCH_LOOP_acc_2_tmp[4])) | (~ (STORE_LOOP_acc_1_tmp[7])));
  assign mux_450_cse = MUX_s_1_2_2(or_431_cse, and_948_nl, nor_142_nl);
  assign or_463_nl = and_938_cse | nor_259_cse | nand_tmp_21;
  assign mux_445_nl = MUX_s_1_2_2(or_463_nl, mux_tmp_159, and_939_cse);
  assign mux_446_nl = MUX_s_1_2_2(mux_445_nl, mux_tmp_162, BATCH_LOOP_acc_itm_32_1);
  assign mux_443_nl = MUX_s_1_2_2((~ mux_tmp_162), BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_447_nl = MUX_s_1_2_2((~ mux_446_nl), mux_443_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_448_nl = MUX_s_1_2_2(mux_447_nl, mux_439_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign or_457_nl = (STORE_LOOP_mux1h_44_tmp!=2'b00) | nand_tmp_21;
  assign mux_436_nl = MUX_s_1_2_2(or_457_nl, nand_tmp_20, and_938_cse);
  assign or_459_nl = BATCH_LOOP_acc_itm_32_1 | STORE_LOOP_and_2_ssc_1 | mux_436_nl;
  assign mux_438_nl = MUX_s_1_2_2(or_459_nl, or_431_cse, or_tmp_367);
  assign or_449_nl = (~ (BATCH_LOOP_acc_2_tmp[4])) | (~ (STORE_LOOP_acc_1_tmp[7]))
      | (STORE_LOOP_mux_27_tmp!=2'b00);
  assign mux_449_nl = MUX_s_1_2_2(mux_448_nl, mux_438_nl, or_449_nl);
  assign mux_451_cse = MUX_s_1_2_2(mux_450_cse, mux_449_nl, nor_14_cse);
  assign and_dcpl_124 = BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2;
  assign and_tmp_89 = or_tmp_9 & mux_361_cse;
  assign and_dcpl_130 = and_tmp_89 & and_dcpl_124;
  assign and_238_cse = and_dcpl_124 & mux_tmp_175;
  assign and_tmp_98 = ((~ BATCH_LOOP_stage_v_10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b11) | CALC_SOFTMAX_LOOP_asn_itm_10
      | exit_BATCH_LOOP_lpi_2_dfm_st_10 | CALC_SOFTMAX_LOOP_mul_cmp_bawt) & and_tmp_22;
  assign and_tmp_99 = ((~ BATCH_LOOP_stage_v_4) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_4) & and_tmp_98;
  assign and_247_cse = or_647_cse & mux_655_cse;
  assign and_dcpl_137 = BATCH_LOOP_stage_0_7 & BATCH_LOOP_stage_v_6;
  assign or_tmp_436 = (~ BATCH_LOOP_stage_0_10) | BATCH_LOOP_stage_v_10;
  assign mux_535_cse = MUX_s_1_2_2(mux_tmp_174, and_298_cse, BATCH_LOOP_stage_v_8);
  assign nand_45_nl = ~(BATCH_LOOP_stage_0_9 & nor_242_cse);
  assign mux_537_nl = MUX_s_1_2_2(or_tmp_176, nand_45_nl, BATCH_LOOP_stage_v_8);
  assign nand_46_nl = ~(BATCH_LOOP_stage_0_8 & (~ mux_537_nl));
  assign mux_538_nl = MUX_s_1_2_2(or_tmp_176, nand_46_nl, BATCH_LOOP_stage_v_7);
  assign and_275_nl = BATCH_LOOP_stage_0_8 & mux_535_cse;
  assign mux_536_nl = MUX_s_1_2_2(mux_tmp_174, and_275_nl, BATCH_LOOP_stage_v_7);
  assign mux_tmp_522 = MUX_s_1_2_2((~ mux_538_nl), mux_536_nl, or_929_cse);
  assign nor_246_nl = ~(BATCH_LOOP_stage_v_10 | (~ mux_tmp_174));
  assign mux_556_nl = MUX_s_1_2_2(nor_246_nl, and_946_cse, BATCH_LOOP_stage_v_8);
  assign mux_tmp_540 = MUX_s_1_2_2(mux_556_nl, mux_535_cse, or_929_cse);
  assign mux_tmp_555 = MUX_s_1_2_2(nor_242_cse, mux_577_cse, or_929_cse);
  assign and_tmp_141 = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_0_8 & mux_tmp_174;
  assign or_tmp_492 = or_tmp_436 | (~ mux_tmp_174);
  assign and_tmp_144 = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_0_9 & mux_tmp_174;
  assign and_dcpl_153 = BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign and_tmp_147 = or_929_cse & mux_296_cse;
  assign and_dcpl_157 = BATCH_LOOP_stage_v_11 & BATCH_LOOP_stage_0_12;
  assign or_tmp_507 = dma_write_chnl_rsci_bawt | exit_BATCH_LOOP_lpi_2_dfm_st_12
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]);
  assign or_620_cse = (~ STORE_LOOP_equal_tmp_1_1) | (STORE_LOOP_mux_27_tmp!=2'b00);
  assign or_tmp_531 = (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2))
      | (~ STORE_LOOP_equal_tmp_1_1) | (STORE_LOOP_mux_27_tmp!=2'b00);
  assign mux_620_nl = MUX_s_1_2_2(or_tmp_531, or_620_cse, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_621_nl = MUX_s_1_2_2(mux_620_nl, or_620_cse, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_622_nl = MUX_s_1_2_2(mux_621_nl, or_620_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_tmp_606 = MUX_s_1_2_2(or_tmp_531, mux_622_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_694_cse = MUX_s_1_2_2(mux_tmp_175, and_247_cse, BATCH_LOOP_stage_v_4);
  assign or_688_cse = (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign and_dcpl_244 = mux_694_cse & (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1==74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign or_tmp_608 = or_tmp_9 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b00)
      & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_11)
      & BATCH_LOOP_stage_v_11 & BATCH_LOOP_stage_0_12 & (fsm_output[2]);
  assign or_tmp_612 = or_dcpl_8 & and_dcpl_79 & (fsm_output[2]);
  assign or_tmp_630 = (~ (fsm_output[2])) | (~ mux_tmp_197) | or_dcpl_16 | exit_BATCH_LOOP_lpi_2_dfm_st_3
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]);
  assign or_tmp_633 = ~((fsm_output[2]) & mux_tmp_185 & BATCH_LOOP_stage_0_11 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10) & (~ CALC_SOFTMAX_LOOP_asn_itm_10) &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2)
      & BATCH_LOOP_stage_v_10);
  assign or_tmp_670 = not_tmp_164 & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_671 = mux_tmp_295 & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_675 = mux_327_cse & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_682 = mux_tmp_295 & (~ BATCH_LOOP_acc_itm_32_1) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign or_tmp_707 = (mux_327_cse | exit_CALC_SOFTMAX_LOOP_lpi_2) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign or_tmp_732 = (~ mux_230_cse) & (SUM_EXP_LOOP_acc_2_tmp[7]) & (CALC_EXP_LOOP_acc_1_tmp[7])
      & (LOAD_LOOP_acc_1_tmp[7]) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_736 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  assign or_tmp_774 = (~ mux_451_cse) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_784 = mux_451_cse & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1
      = mux_654_cse & and_dcpl_107 & (~ STORE_LOOP_and_10_itm_3) & (fsm_output[2]);
  assign BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1 = (mux_230_cse | (~((SUM_EXP_LOOP_acc_2_tmp[7])
      & (CALC_EXP_LOOP_acc_1_tmp[7]))) | (~ (LOAD_LOOP_acc_1_tmp[7]))) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_2_mx0c0 = (fsm_output[1]) | (and_tmp_89 & and_dcpl_124
      & (~ BATCH_LOOP_and_12_tmp) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_3_mx0c0 = (fsm_output[1]) | (mux_tmp_197 & and_dcpl_42
      & or_dcpl_58 & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_4_mx0c0 = (fsm_output[1]) | (and_247_cse & and_dcpl_24
      & or_dcpl_16 & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_5_mx0c0 = (fsm_output[1]) | ((~(or_647_cse & BATCH_LOOP_stage_v_4
      & BATCH_LOOP_stage_0_5)) & mux_654_cse & and_dcpl_107 & (fsm_output[2]));
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1
      = mux_tmp_197 & and_dcpl_42 & (~ STORE_LOOP_asn_20_itm_3) & (fsm_output[2]);
  assign CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1 = or_114_cse &
      BATCH_LOOP_and_12_tmp;
  assign STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1 = (or_dcpl_72 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
      | exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp;
  assign plm_out_data_rsci_d_d = CALC_SOFTMAX_LOOP_mux_1_rmff;
  assign plm_out_data_rsci_radr_d = STORE_LOOP_i_mux_rmff;
  assign plm_out_data_rsci_wadr_d = CALC_SOFTMAX_LOOP_i_mux_1_rmff;
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d
      = operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d
      = CALC_SOFTMAX_LOOP_i_mux_rmff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d
      = CALC_EXP_LOOP_i_mux_rmff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign or_dcpl = (STORE_LOOP_and_7_itm_mx0w0 & (~ dma_read_ctrl_rsci_irdy_mxwt))
      | STORE_LOOP_or_23_itm_mx0w0;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | and_dcpl_23 | or_dcpl_8)) ) begin
      dma_write_chnl_rsci_idat_31_0 <= plm_out_data_rsci_q_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_idat_31_7 <= 25'b0000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_tmp_155 | (~ BATCH_LOOP_and_13_tmp)))
        ) begin
      dma_write_ctrl_rsci_idat_31_7 <= BATCH_LOOP_acc_3_psp_lpi_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_idat_10_7 <= 4'b0000;
    end
    else if ( core_wen & (fsm_output[2]) & mux_190_cse & BATCH_LOOP_and_13_tmp )
        begin
      dma_read_ctrl_rsci_idat_10_7 <= BATCH_LOOP_b_4_0_sva_3_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse <= 1'b0;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse
          <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse
          <= 1'b0;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= 1'b0;
      reg_acc_done_rsci_ivld_core_psct_cse <= 1'b0;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      reg_conf_info_rsci_irdy_core_psct_cse <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg
          <= 7'b0000000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg
          <= 7'b0000000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      plm_out_data_rsci_wadr_d_reg <= 7'b0000000;
      plm_out_data_rsci_radr_d_reg <= 7'b0000000;
      plm_out_data_rsci_d_d_reg <= 32'b00000000000000000000000000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      BATCH_LOOP_stage_v_6 <= 1'b0;
      BATCH_LOOP_stage_v_7 <= 1'b0;
      BATCH_LOOP_stage_v_8 <= 1'b0;
      BATCH_LOOP_stage_v_9 <= 1'b0;
      BATCH_LOOP_stage_v_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9 <= 7'b0000000;
      BATCH_LOOP_stage_v_11 <= 1'b0;
      BATCH_LOOP_stage_v_12 <= 1'b0;
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      exit_STORE_CTRL_LOOP_lpi_2 <= 1'b0;
      STORE_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      exitL_exit_STORE_LOOP_sva <= 1'b0;
      BATCH_LOOP_stage_v_1 <= 1'b0;
      BATCH_LOOP_stage_0_2 <= 1'b0;
      BATCH_LOOP_stage_0_7 <= 1'b0;
      BATCH_LOOP_stage_0_8 <= 1'b0;
      BATCH_LOOP_stage_0_9 <= 1'b0;
      BATCH_LOOP_stage_0_10 <= 1'b0;
      BATCH_LOOP_stage_0_11 <= 1'b0;
      BATCH_LOOP_stage_0_12 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse <= and_475_rmff;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= and_477_rmff;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse
          <= and_479_rmff;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse
          <= and_481_rmff;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= and_485_rmff;
      reg_acc_done_rsci_ivld_core_psct_cse <= BATCH_LOOP_nor_13_tmp & (fsm_output[2]);
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= (~ mux_tmp_155) & BATCH_LOOP_and_13_tmp
          & (fsm_output[2]);
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= mux_190_cse & BATCH_LOOP_and_13_tmp
          & (fsm_output[2]);
      reg_conf_info_rsci_irdy_core_psct_cse <= ~((fsm_output[2:1]!=2'b00));
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg
          <= CALC_EXP_LOOP_i_mux_rmff;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg
          <= CALC_SOFTMAX_LOOP_i_mux_rmff;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg
          <= operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
      plm_out_data_rsci_wadr_d_reg <= CALC_SOFTMAX_LOOP_i_mux_1_rmff;
      plm_out_data_rsci_radr_d_reg <= STORE_LOOP_i_mux_rmff;
      plm_out_data_rsci_d_d_reg <= CALC_SOFTMAX_LOOP_mux_1_rmff;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= MUX1HOT_v_94_3_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm,
          {(~ (fsm_output[2])) , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl});
      BATCH_LOOP_stage_v_6 <= ((BATCH_LOOP_stage_v_6 & (~(mux_tmp_522 & and_dcpl_137
          & or_dcpl_76))) | (mux_654_cse & and_dcpl_107)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_7 <= ((BATCH_LOOP_stage_v_7 & (~(mux_tmp_540 & and_990_cse
          & (~(BATCH_LOOP_stage_0_7 & BATCH_LOOP_stage_v_6))))) | (mux_tmp_522 &
          and_dcpl_137)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_8 <= ((BATCH_LOOP_stage_v_8 & (~(mux_tmp_555 & and_1009_cse
          & (~(BATCH_LOOP_stage_0_8 & BATCH_LOOP_stage_v_7))))) | (mux_tmp_540 &
          and_990_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_9 <= ((BATCH_LOOP_stage_v_9 & (~(mux_295_cse & and_1004_cse
          & (~(BATCH_LOOP_stage_0_9 & BATCH_LOOP_stage_v_8))))) | (mux_tmp_555 &
          and_1009_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_10 <= ((BATCH_LOOP_stage_v_10 & (~(and_tmp_147 & and_dcpl_153
          & not_tmp_36))) | (mux_295_cse & and_1004_cse)) & (fsm_output[2]);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9, and_tmp_98);
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9 <= MUX_v_7_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9,
          STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_8, and_tmp_22);
      BATCH_LOOP_stage_v_11 <= ((BATCH_LOOP_stage_v_11 & (~(mux_595_nl & and_dcpl_157)))
          | (and_tmp_147 & and_dcpl_153)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_12 <= ((BATCH_LOOP_stage_v_12 & (~ mux_597_nl)) | (and_tmp_10
          & and_dcpl_157)) & (fsm_output[2]);
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1, fsm_output[2]);
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1, fsm_output[2]);
      exit_STORE_CTRL_LOOP_lpi_2 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_dfm_3,
          exit_STORE_CTRL_LOOP_lpi_2_mx1, fsm_output[2]);
      STORE_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          STORE_LOOP_i_7_0_lpi_2_6_0_mx1, fsm_output[2]);
      exitL_exit_STORE_LOOP_sva <= exitL_exit_STORE_LOOP_sva_mx1 | (~ (fsm_output[2]));
      BATCH_LOOP_stage_v_1 <= ((BATCH_LOOP_stage_v_1 & (~ BATCH_LOOP_and_12_tmp))
          | BATCH_LOOP_and_13_tmp) & (fsm_output[2]);
      BATCH_LOOP_stage_0_2 <= BATCH_LOOP_mux_23_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_7 <= BATCH_LOOP_mux_25_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_8 <= BATCH_LOOP_mux_27_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_9 <= BATCH_LOOP_mux_29_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_10 <= BATCH_LOOP_mux_31_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_11 <= BATCH_LOOP_mux_33_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_12 <= BATCH_LOOP_mux_35_nl & (fsm_output[2]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (or_tmp_608 | or_tmp_612) ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= ~ or_tmp_612;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_262_nl)) ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= ~((mux_241_nl | (~ BATCH_LOOP_and_13_tmp))
          & and_dcpl_84 & (fsm_output[2]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_4 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( STORE_LOOP_and_44_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_4 <= exit_BATCH_LOOP_lpi_2_dfm_st_3;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_itm_10 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_10 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_cse ) begin
      CALC_SOFTMAX_LOOP_asn_itm_10 <= CALC_SOFTMAX_LOOP_asn_itm_9;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_10 <= exit_BATCH_LOOP_lpi_2_dfm_st_9;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_itm_11 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_11 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_22_cse ) begin
      CALC_SOFTMAX_LOOP_asn_itm_11 <= CALC_SOFTMAX_LOOP_asn_itm_10;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_11 <= exit_BATCH_LOOP_lpi_2_dfm_st_10;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_12 <= 1'b0;
    end
    else if ( STORE_LOOP_and_50_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_12 <= exit_BATCH_LOOP_lpi_2_dfm_st_11;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      lfst_exit_STORE_LOOP_lpi_2_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= 2'b00;
    end
    else if ( LOAD_LOOP_i_and_cse ) begin
      LOAD_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_2_6_0_mx1, LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          fsm_output[3]);
      lfst_exit_STORE_LOOP_lpi_2_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_2_mx1,
          lfst_exit_STORE_LOOP_lpi_2_dfm_8_2, fsm_output[3]);
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
          lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0, fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_BATCH_LOOP_lpi_2_dfm_1 <= 1'b0;
      STORE_LOOP_or_tmp_1 <= 1'b0;
      STORE_LOOP_equal_tmp_2_1 <= 1'b0;
      STORE_LOOP_nor_tmp_1 <= 1'b0;
      reg_LOAD_LOOP_and_1_svs_1_cse <= 1'b0;
      STORE_LOOP_equal_tmp_1 <= 1'b0;
      STORE_LOOP_equal_tmp_1_1 <= 1'b0;
      SUM_EXP_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      STORE_LOOP_i_7_0_sva_1_1 <= 8'b00000000;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= 1'b0;
      STORE_LOOP_STORE_LOOP_and_10_itm_1 <= 1'b0;
      STORE_LOOP_asn_20_itm_1 <= 1'b0;
    end
    else if ( BATCH_LOOP_and_17_cse ) begin
      exit_BATCH_LOOP_lpi_2_dfm_1 <= exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
      STORE_LOOP_or_tmp_1 <= STORE_LOOP_or_tmp_mx0w0;
      STORE_LOOP_equal_tmp_2_1 <= STORE_LOOP_equal_tmp_2_mx0w0;
      STORE_LOOP_nor_tmp_1 <= STORE_LOOP_nor_tmp_mx0w0;
      reg_LOAD_LOOP_and_1_svs_1_cse <= LOAD_LOOP_and_1_svs_mx0w0;
      STORE_LOOP_equal_tmp_1 <= STORE_LOOP_equal_tmp_mx0w0;
      STORE_LOOP_equal_tmp_1_1 <= STORE_LOOP_equal_tmp_1_mx0w0;
      SUM_EXP_LOOP_i_7_0_sva_1_1_6_0 <= SUM_EXP_LOOP_acc_2_tmp[6:0];
      CALC_EXP_LOOP_i_7_0_sva_1_1_6_0 <= CALC_EXP_LOOP_acc_1_tmp[6:0];
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= LOAD_LOOP_acc_1_tmp[6:0];
      STORE_LOOP_i_7_0_sva_1_1 <= STORE_LOOP_acc_1_tmp;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 <= exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= BATCH_LOOP_acc_2_tmp[4];
      STORE_LOOP_STORE_LOOP_and_10_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
      STORE_LOOP_asn_20_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 |
          exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= 2'b00;
    end
    else if ( core_wen & (~((fsm_output[1]) | (fsm_output[3]) | ((~ BATCH_LOOP_and_13_tmp)
        & (fsm_output[2])))) ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w2, or_tmp_671);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_23_cse ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm_1 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_mx1,
          CALC_SOFTMAX_LOOP_asn_3_itm, or_tmp_675);
      CALC_SOFTMAX_LOOP_asn_itm_1 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2, CALC_SOFTMAX_LOOP_asn_itm,
          or_tmp_675);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= 1'b0;
    end
    else if ( core_wen & (or_tmp_671 | or_tmp_670) ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1,
          lfst_exit_STORE_LOOP_lpi_2_2_mx1, or_tmp_670);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0 <= 7'b0000000;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= 1'b0;
    end
    else if ( STORE_LOOP_and_59_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2, or_tmp_682);
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0, or_tmp_682);
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
          CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_2_6_0_1, and_634_cse);
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
          STORE_LOOP_mux1h_17_mx0w1, and_634_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_24_cse ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm <= exit_STORE_CTRL_LOOP_lpi_2_mx1;
      CALC_SOFTMAX_LOOP_asn_itm <= exit_CALC_SOFTMAX_LOOP_lpi_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0 <= 2'b00;
    end
    else if ( STORE_LOOP_and_62_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm <= 8'b00000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm
          <= 8'b00000000;
    end
    else if ( ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse
        ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm
          <= operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[69:60];
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm
          <= ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm <= 7'b0000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | or_tmp_220)) ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm <= CALC_EXP_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse <= 7'b0000000;
    end
    else if ( core_wen & (((~ mux_327_cse) & BATCH_LOOP_and_13_tmp & (~ exit_CALC_SOFTMAX_LOOP_lpi_2)
        & (fsm_output[2])) | or_tmp_707) ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm, or_tmp_707);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= 1'b0;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | not_tmp_183 | or_dcpl_58 | exit_BATCH_LOOP_lpi_2_dfm_st_2
        | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0!=2'b10)))
        ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm <= 7'b0000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_327_cse | (~ BATCH_LOOP_and_13_tmp)
        | exit_CALC_SOFTMAX_LOOP_lpi_2)) ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm <= CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm <= 7'b0000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | or_dcpl_72 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
        | exit_BATCH_LOOP_lpi_2_dfm_1 | (~ BATCH_LOOP_and_12_tmp))) ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm <= STORE_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
    end
    else if ( CALC_EXP_LOOP_i_and_1_cse ) begin
      CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_654_cse & and_dcpl_107 & STORE_LOOP_and_10_itm_3 &
        (fsm_output[2])) | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1)
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm,
          STORE_LOOP_and_91_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_acc_3_psp_lpi_2_dfm_2 <= 25'b0000000000000000000000000;
    end
    else if ( core_wen & (or_tmp_732 | BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1) )
        begin
      BATCH_LOOP_acc_3_psp_lpi_2_dfm_2 <= MUX_v_25_2_2(BATCH_LOOP_acc_3_psp_sva_1,
          BATCH_LOOP_acc_3_psp_lpi_2, BATCH_LOOP_acc_3_psp_lpi_2_dfm_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= 1'b0;
      STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0 <= 2'b00;
    end
    else if ( STORE_CTRL_LOOP_and_1_cse ) begin
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2,
          STORE_LOOP_mux1h_18_mx0w1, or_tmp_736);
      STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_6_0,
          STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1, or_tmp_736);
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1, or_tmp_736);
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1, or_tmp_736);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v <= 1'b0;
    end
    else if ( core_wen & (~((fsm_output[0]) | (fsm_output[3]) | ((~((~(BATCH_LOOP_stage_v
        | (~ BATCH_LOOP_stage_0))) | BATCH_LOOP_and_13_tmp)) & (fsm_output[2]))))
        ) begin
      BATCH_LOOP_stage_v <= (~((~(mux_451_cse & BATCH_LOOP_stage_0)) & BATCH_LOOP_and_13_tmp
          & (fsm_output[2]))) | (mux_432_nl & BATCH_LOOP_stage_0 & (fsm_output[2]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_2_mx0c0 | (BATCH_LOOP_and_12_tmp & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_v_2 <= ~ BATCH_LOOP_stage_v_2_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_and_1_svs_st_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_asn_itm_2 <= 1'b0;
      STORE_LOOP_asn_20_itm_2 <= 1'b0;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= 3'b000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= 7'b0000000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1
          <= 7'b0000000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= 5'b00000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= 3'b000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1
          <= 10'b0000000000;
      STORE_LOOP_and_7_itm_1 <= 1'b0;
      STORE_LOOP_or_23_itm_1 <= 1'b0;
      exit_LOAD_CTRL_LOOP_sva_1 <= 1'b0;
      STORE_LOOP_equal_tmp_2 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_4_cse ) begin
      LOAD_LOOP_and_1_svs_st_2 <= reg_LOAD_LOOP_and_1_svs_1_cse;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_2 <= exit_BATCH_LOOP_lpi_2_dfm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2 <= reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse;
      CALC_SOFTMAX_LOOP_asn_itm_2 <= CALC_SOFTMAX_LOOP_asn_itm_1;
      STORE_LOOP_asn_20_itm_2 <= STORE_LOOP_asn_20_itm_1;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= MUX_v_3_4_2(3'b011, 3'b100, 3'b101, 3'b110, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]);
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= MUX_v_7_4_2(7'b1111110, 7'b1000000, 7'b0100110, 7'b0110111, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]);
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[18:12];
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_5_4_2(5'b01100, 5'b01110, 5'b10001, 5'b10100, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]);
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= MUX_v_3_4_2(3'b010, 3'b110, 3'b001, 3'b101, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]);
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[9:0];
      STORE_LOOP_and_7_itm_1 <= STORE_LOOP_and_7_itm_mx0w0;
      STORE_LOOP_or_23_itm_1 <= STORE_LOOP_or_23_itm_mx0w0;
      exit_LOAD_CTRL_LOOP_sva_1 <= dma_read_ctrl_rsci_irdy_mxwt;
      STORE_LOOP_equal_tmp_2 <= STORE_LOOP_equal_tmp_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_3_mx0c0 | (and_dcpl_130 & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_v_3 <= ~ BATCH_LOOP_stage_v_3_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~ not_tmp_183) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_and_1_svs_st_3 <= 1'b0;
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_asn_itm_3 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0 <= 2'b00;
      STORE_LOOP_asn_20_itm_3 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      STORE_LOOP_and_7_itm_2 <= 1'b0;
      reg_STORE_LOOP_and_8_itm_1_cse <= 1'b0;
      STORE_LOOP_or_23_itm_2 <= 1'b0;
      STORE_LOOP_asn_20_itm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2 <= 7'b0000000;
    end
    else if ( LOAD_LOOP_and_5_cse ) begin
      LOAD_LOOP_and_1_svs_st_3 <= LOAD_LOOP_and_1_svs_st_2;
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1 <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2;
      CALC_SOFTMAX_LOOP_asn_itm_3 <= CALC_SOFTMAX_LOOP_asn_itm_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0;
      STORE_LOOP_asn_20_itm_3 <= STORE_LOOP_asn_20_itm_2;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= exit_BATCH_LOOP_lpi_2_dfm_st_2;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= CALC_SOFTMAX_LOOP_asn_itm_3;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1
          <= MUX_v_74_2_2(74'b00000000000000000000000000000000000000000000000000000000000000000000000000,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1,
          LOAD_CTRL_LOOP_not_5_nl);
      STORE_LOOP_and_7_itm_2 <= STORE_LOOP_and_7_itm_1;
      reg_STORE_LOOP_and_8_itm_1_cse <= STORE_LOOP_equal_tmp_2 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_2);
      STORE_LOOP_or_23_itm_2 <= STORE_LOOP_or_23_itm_1;
      STORE_LOOP_asn_20_itm_4 <= STORE_LOOP_asn_20_itm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= MUX_s_1_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm,
          and_463_nl);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_4_mx0c0 | (mux_tmp_197 & and_dcpl_42
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_4 <= ~ BATCH_LOOP_stage_v_4_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_5 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_5_mx0c0 | (and_247_cse & and_dcpl_24
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_5 <= ~ BATCH_LOOP_stage_v_5_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= 1'b0;
      LOAD_LOOP_and_1_svs_5 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0 <= 2'b00;
      STORE_LOOP_asn_20_itm_5 <= 1'b0;
      STORE_LOOP_and_10_itm_3 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_8 <= 7'b0000000;
      exit_BATCH_LOOP_lpi_2_dfm_st_9 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_7 <= 7'b0000000;
      exit_BATCH_LOOP_lpi_2_dfm_st_8 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_6 <= 7'b0000000;
      exit_BATCH_LOOP_lpi_2_dfm_st_7 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_5 <= 7'b0000000;
      exit_BATCH_LOOP_lpi_2_dfm_st_6 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0 <= 2'b00;
      CALC_SOFTMAX_LOOP_asn_itm_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_4 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_asn_itm_5 <= 1'b0;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_1_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
      LOAD_LOOP_and_1_svs_5 <= LOAD_LOOP_and_1_svs_4;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0;
      STORE_LOOP_asn_20_itm_5 <= STORE_LOOP_asn_20_itm_4;
      STORE_LOOP_and_10_itm_3 <= STORE_LOOP_and_10_itm_2;
      exit_BATCH_LOOP_lpi_2_dfm_st_5 <= exit_BATCH_LOOP_lpi_2_dfm_st_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_8 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_7;
      exit_BATCH_LOOP_lpi_2_dfm_st_9 <= exit_BATCH_LOOP_lpi_2_dfm_st_8;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_9 <= CALC_SOFTMAX_LOOP_asn_itm_8;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_7 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_6;
      exit_BATCH_LOOP_lpi_2_dfm_st_8 <= exit_BATCH_LOOP_lpi_2_dfm_st_7;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_8 <= CALC_SOFTMAX_LOOP_asn_itm_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_6 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_5;
      exit_BATCH_LOOP_lpi_2_dfm_st_7 <= exit_BATCH_LOOP_lpi_2_dfm_st_6;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_7 <= CALC_SOFTMAX_LOOP_asn_itm_6;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_5 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_4;
      exit_BATCH_LOOP_lpi_2_dfm_st_6 <= exit_BATCH_LOOP_lpi_2_dfm_st_5;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_6_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0;
      CALC_SOFTMAX_LOOP_asn_itm_6 <= CALC_SOFTMAX_LOOP_asn_itm_5;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_4 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3;
      CALC_SOFTMAX_LOOP_asn_itm_5 <= CALC_SOFTMAX_LOOP_asn_itm_4;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_774) ) begin
      BATCH_LOOP_stage_0 <= ~ or_tmp_774;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_631_nl & (STORE_LOOP_acc_1_tmp[7])
        & (~ (BATCH_LOOP_acc_2_tmp[4])) & BATCH_LOOP_and_13_tmp & (fsm_output[2])))
        ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, (BATCH_LOOP_acc_2_tmp[3:0]),
          BATCH_LOOP_b_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_acc_3_psp_lpi_2 <= 25'b0000000000000000000000000;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_732) ) begin
      BATCH_LOOP_acc_3_psp_lpi_2 <= MUX_v_25_2_2(BATCH_LOOP_acc_3_psp_lpi_2_dfm_2,
          BATCH_LOOP_acc_3_psp_sva_1, or_tmp_732);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( CALC_SOFTMAX_LOOP_and_30_cse ) begin
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3,
          STORE_LOOP_mux1h_17_mx0w1, or_tmp_784);
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0,
          CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_2_6_0_1, or_tmp_784);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~ (fsm_output[2])) ) begin
      batch_sva <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_1 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_774 | or_tmp_784) ) begin
      BATCH_LOOP_stage_0_1 <= (BATCH_LOOP_stage_0 & (~ or_tmp_774)) | (fsm_output[1]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_3 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | ((and_dcpl_130 | BATCH_LOOP_and_12_tmp)
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_3 <= BATCH_LOOP_stage_0_2 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_4 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_659_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_4 <= BATCH_LOOP_stage_0_3 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_5 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_671_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_5 <= BATCH_LOOP_stage_0_4 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_6 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_682_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_6 <= BATCH_LOOP_stage_0_5 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((fsm_output[1]) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= 7'b0000000;
    end
    else if ( core_wen & (and_dcpl_84 | CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1)
        ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
          CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm, CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      LOAD_LOOP_and_1_svs_4 <= 1'b0;
      STORE_LOOP_and_10_itm_2 <= 1'b0;
    end
    else if ( ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_and_2_cse )
        begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      LOAD_LOOP_and_1_svs_4 <= LOAD_LOOP_and_1_svs_st_3;
      STORE_LOOP_and_10_itm_2 <= reg_STORE_LOOP_and_8_itm_1_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & mux_707_nl ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= 10'b0000000000;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= 8'b00000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= 8'b00000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1
          <= 10'b0000000000;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= MUX_v_10_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm,
          and_dcpl_244);
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= MUX_v_8_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm, and_dcpl_244);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_8_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm,
          and_dcpl_244);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1
          <= MUX_v_10_2_2((operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[69:60]),
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm,
          and_dcpl_244);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1 <= 7'b0000000;
    end
    else if ( core_wen & (((~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
        & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])) & and_dcpl_82) | STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1)
        ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_6_0,
          STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm, STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1);
    end
  end
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl
      = (~ ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp)
      & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl
      = ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp
      & (fsm_output[2]);
  assign and_945_nl = (~(or_929_cse & BATCH_LOOP_stage_0_11)) & and_tmp_10;
  assign mux_595_nl = MUX_s_1_2_2(and_tmp_10, and_945_nl, BATCH_LOOP_stage_v_10);
  assign nor_238_nl = ~(CALC_SOFTMAX_LOOP_asn_itm_11 | exit_BATCH_LOOP_lpi_2_dfm_st_11
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11)
      | plm_out_data_rsci_bawt | (~ or_tmp_507));
  assign mux_597_nl = MUX_s_1_2_2(or_tmp_507, nor_238_nl, and_dcpl_157);
  assign nor_289_nl = ~(BATCH_LOOP_and_12_tmp | BATCH_LOOP_and_13_tmp);
  assign BATCH_LOOP_mux_23_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_1, BATCH_LOOP_stage_0_2,
      nor_289_nl);
  assign nand_65_nl = ~(BATCH_LOOP_stage_v_5 & BATCH_LOOP_stage_0_6 & mux_tmp_175);
  assign nand_66_nl = ~(BATCH_LOOP_stage_0_7 & mux_653_cse);
  assign mux_549_nl = MUX_s_1_2_2(nand_65_nl, nand_66_nl, BATCH_LOOP_stage_v_6);
  assign BATCH_LOOP_mux_25_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_6, BATCH_LOOP_stage_0_7,
      mux_549_nl);
  assign nand_62_nl = ~(BATCH_LOOP_stage_v_6 & BATCH_LOOP_stage_0_7 & mux_tmp_175);
  assign nand_63_nl = ~(BATCH_LOOP_stage_0_8 & mux_652_cse);
  assign mux_566_nl = MUX_s_1_2_2(nand_62_nl, nand_63_nl, BATCH_LOOP_stage_v_7);
  assign BATCH_LOOP_mux_27_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_7, BATCH_LOOP_stage_0_8,
      mux_566_nl);
  assign nor_241_nl = ~(BATCH_LOOP_stage_v_10 | (~ and_tmp_141));
  assign mux_579_nl = MUX_s_1_2_2(nor_241_nl, and_946_cse, BATCH_LOOP_stage_v_8);
  assign mux_578_nl = MUX_s_1_2_2(and_tmp_141, and_298_cse, BATCH_LOOP_stage_v_8);
  assign mux_580_nl = MUX_s_1_2_2(mux_579_nl, mux_578_nl, or_929_cse);
  assign BATCH_LOOP_mux_29_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_9, BATCH_LOOP_stage_0_8,
      mux_580_nl);
  assign or_584_nl = BATCH_LOOP_stage_v_10 | (~ and_tmp_144);
  assign mux_589_nl = MUX_s_1_2_2(or_584_nl, or_tmp_492, BATCH_LOOP_stage_v_9);
  assign nand_59_nl = ~(BATCH_LOOP_stage_0_10 & mux_575_cse);
  assign mux_587_nl = MUX_s_1_2_2(or_tmp_492, nand_59_nl, BATCH_LOOP_stage_0_11);
  assign mux_588_nl = MUX_s_1_2_2((~ and_tmp_144), mux_587_nl, BATCH_LOOP_stage_v_9);
  assign mux_590_nl = MUX_s_1_2_2(mux_589_nl, mux_588_nl, or_929_cse);
  assign BATCH_LOOP_mux_31_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_9, BATCH_LOOP_stage_0_10,
      mux_590_nl);
  assign nand_57_nl = ~(BATCH_LOOP_stage_v_9 & BATCH_LOOP_stage_0_10 & mux_293_cse);
  assign nand_58_nl = ~(or_929_cse & BATCH_LOOP_stage_0_11 & mux_294_cse);
  assign mux_594_nl = MUX_s_1_2_2(nand_57_nl, nand_58_nl, BATCH_LOOP_stage_v_10);
  assign BATCH_LOOP_mux_33_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_10, BATCH_LOOP_stage_0_11,
      mux_594_nl);
  assign nand_54_nl = ~(or_929_cse & BATCH_LOOP_stage_v_10 & BATCH_LOOP_stage_0_11
      & or_tmp_9);
  assign nand_55_nl = ~(BATCH_LOOP_stage_0_12 & or_73_cse & or_tmp_9);
  assign mux_596_nl = MUX_s_1_2_2(nand_54_nl, nand_55_nl, BATCH_LOOP_stage_v_11);
  assign BATCH_LOOP_mux_35_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_11, BATCH_LOOP_stage_0_12,
      mux_596_nl);
  assign mux_755_nl = MUX_s_1_2_2(or_104_cse, nand_tmp_26, and_938_cse);
  assign mux_237_nl = MUX_s_1_2_2(mux_755_nl, nand_tmp_26, nor_12_cse);
  assign mux_238_nl = MUX_s_1_2_2(nand_tmp_26, mux_237_nl, or_180_cse);
  assign mux_233_nl = MUX_s_1_2_2(nand_tmp_26, or_104_cse, and_938_cse);
  assign mux_234_nl = MUX_s_1_2_2(or_104_cse, mux_233_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_751_nl = MUX_s_1_2_2(or_104_cse, nand_tmp_26, and_938_cse);
  assign mux_232_nl = MUX_s_1_2_2(mux_751_nl, nand_tmp_26, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_235_nl = MUX_s_1_2_2(mux_234_nl, mux_232_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2);
  assign mux_236_nl = MUX_s_1_2_2(mux_235_nl, or_104_cse, STORE_LOOP_or_tmp_1);
  assign or_219_nl = exitL_exit_STORE_LOOP_sva | mux_236_nl;
  assign mux_239_nl = MUX_s_1_2_2(mux_238_nl, or_219_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_240_nl = MUX_s_1_2_2(mux_239_nl, or_100_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_241_nl = MUX_s_1_2_2(mux_240_nl, or_113_cse, STORE_LOOP_asn_20_itm_1);
  assign mux_760_nl = MUX_s_1_2_2(and_tmp_51, or_tmp_213, and_938_cse);
  assign mux_253_nl = MUX_s_1_2_2(mux_760_nl, or_tmp_213, nor_12_cse);
  assign mux_254_nl = MUX_s_1_2_2(or_tmp_213, mux_253_nl, or_180_cse);
  assign mux_256_nl = MUX_s_1_2_2(mux_254_nl, and_tmp_51, and_939_cse);
  assign mux_247_nl = MUX_s_1_2_2(or_tmp_213, and_tmp_51, and_938_cse);
  assign mux_248_nl = MUX_s_1_2_2(and_tmp_51, mux_247_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_754_nl = MUX_s_1_2_2(and_tmp_51, or_tmp_213, and_938_cse);
  assign mux_246_nl = MUX_s_1_2_2(mux_754_nl, or_tmp_213, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_249_nl = MUX_s_1_2_2(mux_248_nl, mux_246_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2);
  assign or_227_nl = STORE_LOOP_and_2_ssc_1 | STORE_LOOP_or_tmp_1;
  assign mux_250_nl = MUX_s_1_2_2(mux_249_nl, and_tmp_51, or_227_nl);
  assign mux_252_nl = MUX_s_1_2_2(mux_250_nl, or_114_cse, exitL_exit_STORE_LOOP_sva);
  assign mux_257_nl = MUX_s_1_2_2(mux_256_nl, mux_252_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_243_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2, or_114_cse,
      exitL_exit_STORE_LOOP_sva);
  assign mux_258_nl = MUX_s_1_2_2(mux_257_nl, mux_243_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_72_nl = ~((STORE_LOOP_mux_27_tmp!=2'b10));
  assign mux_259_nl = MUX_s_1_2_2(or_114_cse, mux_258_nl, nor_72_nl);
  assign and_145_nl = or_113_cse & or_114_cse;
  assign mux_260_nl = MUX_s_1_2_2(mux_259_nl, and_145_nl, STORE_LOOP_asn_20_itm_1);
  assign mux_261_nl = MUX_s_1_2_2(or_113_cse, mux_260_nl, BATCH_LOOP_and_12_tmp);
  assign mux_262_nl = MUX_s_1_2_2(or_tmp_220, mux_261_nl, BATCH_LOOP_and_13_tmp);
  assign STORE_LOOP_and_91_nl = LOAD_LOOP_and_1_svs_5 & (~ ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1);
  assign mux_428_nl = MUX_s_1_2_2(or_tmp_362, or_431_cse, or_tmp_367);
  assign or_447_nl = and_938_cse | nor_259_cse | nand_tmp_40;
  assign mux_423_nl = MUX_s_1_2_2(or_447_nl, mux_tmp_397, and_939_cse);
  assign mux_424_nl = MUX_s_1_2_2(mux_423_nl, mux_tmp_400, BATCH_LOOP_acc_itm_32_1);
  assign mux_425_nl = MUX_s_1_2_2((~ mux_424_nl), or_tmp_362, or_630_cse);
  assign mux_418_nl = MUX_s_1_2_2((~ mux_tmp_400), BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_419_nl = MUX_s_1_2_2(mux_418_nl, or_431_cse, or_630_cse);
  assign mux_426_nl = MUX_s_1_2_2(mux_425_nl, mux_419_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_409_nl = MUX_s_1_2_2(mux_439_cse, or_431_cse, or_630_cse);
  assign mux_427_nl = MUX_s_1_2_2(mux_426_nl, mux_409_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign and_935_nl = (BATCH_LOOP_acc_2_tmp[4]) & (STORE_LOOP_acc_1_tmp[7]);
  assign mux_429_nl = MUX_s_1_2_2(mux_428_nl, mux_427_nl, and_935_nl);
  assign mux_431_nl = MUX_s_1_2_2(mux_450_cse, mux_429_nl, nor_14_cse);
  assign mux_432_nl = MUX_s_1_2_2((~ BATCH_LOOP_stage_v), mux_431_nl, BATCH_LOOP_and_13_tmp);
  assign LOAD_CTRL_LOOP_not_5_nl = ~ exit_LOAD_CTRL_LOOP_sva_1;
  assign and_463_nl = ((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_2) & and_tmp_99;
  assign BATCH_LOOP_b_not_1_nl = ~ (fsm_output[1]);
  assign nor_184_nl = ~((~ lfst_exit_STORE_LOOP_lpi_2_2) | (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b00)
      | exitL_exit_STORE_LOOP_sva);
  assign mux_756_nl = MUX_s_1_2_2(or_630_cse, mux_tmp_606, STORE_LOOP_and_2_ssc_1);
  assign mux_639_nl = MUX_s_1_2_2(mux_tmp_606, mux_756_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_752_nl = MUX_s_1_2_2(or_630_cse, mux_tmp_606, STORE_LOOP_and_2_ssc_1);
  assign mux_638_nl = MUX_s_1_2_2(mux_tmp_606, mux_752_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2);
  assign mux_640_nl = MUX_s_1_2_2(mux_639_nl, mux_638_nl, and_938_cse);
  assign mux_641_nl = MUX_s_1_2_2(mux_640_nl, mux_tmp_606, STORE_LOOP_or_tmp_1);
  assign nor_185_nl = ~((STORE_LOOP_STORE_LOOP_and_10_itm_1 & exitL_exit_STORE_LOOP_sva)
      | mux_641_nl);
  assign nor_186_nl = ~(exitL_exit_STORE_LOOP_sva | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0!=2'b00));
  assign mux_630_nl = MUX_s_1_2_2(nor_185_nl, nor_186_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_631_nl = MUX_s_1_2_2(nor_184_nl, mux_630_nl, nor_14_cse);
  assign nor_182_nl = ~(BATCH_LOOP_stage_v_4 | (~ and_238_cse));
  assign nor_183_nl = ~((~ BATCH_LOOP_stage_0_4) | BATCH_LOOP_stage_v_4 | (~ mux_tmp_175));
  assign mux_658_nl = MUX_s_1_2_2(nor_182_nl, nor_183_nl, BATCH_LOOP_stage_v_3);
  assign mux_656_nl = MUX_s_1_2_2(mux_tmp_175, and_338_cse, BATCH_LOOP_stage_v_4);
  assign and_339_nl = BATCH_LOOP_stage_0_4 & mux_656_nl;
  assign mux_657_nl = MUX_s_1_2_2(and_238_cse, and_339_nl, BATCH_LOOP_stage_v_3);
  assign mux_659_nl = MUX_s_1_2_2(mux_658_nl, mux_657_nl, or_647_cse);
  assign and_348_nl = and_dcpl_42 & mux_tmp_175;
  assign mux_671_nl = MUX_s_1_2_2(and_348_nl, and_347_cse, BATCH_LOOP_stage_v_4);
  assign and_354_nl = or_647_cse & BATCH_LOOP_stage_v_4 & BATCH_LOOP_stage_0_5 &
      mux_tmp_175;
  assign mux_682_nl = MUX_s_1_2_2(and_354_nl, and_337_cse, BATCH_LOOP_stage_v_5);
  assign mux_706_nl = MUX_s_1_2_2(mux_tmp_175, and_338_cse, BATCH_LOOP_stage_v_3);
  assign and_370_nl = or_647_cse & mux_706_nl;
  assign mux_707_nl = MUX_s_1_2_2(mux_tmp_175, and_370_nl, BATCH_LOOP_stage_v_4);

  function automatic [0:0] MUX1HOT_s_1_3_2;
    input [0:0] input_2;
    input [0:0] input_1;
    input [0:0] input_0;
    input [2:0] sel;
    reg [0:0] result;
  begin
    result = input_0 & {1{sel[0]}};
    result = result | ( input_1 & {1{sel[1]}});
    result = result | ( input_2 & {1{sel[2]}});
    MUX1HOT_s_1_3_2 = result;
  end
  endfunction


  function automatic [1:0] MUX1HOT_v_2_3_2;
    input [1:0] input_2;
    input [1:0] input_1;
    input [1:0] input_0;
    input [2:0] sel;
    reg [1:0] result;
  begin
    result = input_0 & {2{sel[0]}};
    result = result | ( input_1 & {2{sel[1]}});
    result = result | ( input_2 & {2{sel[2]}});
    MUX1HOT_v_2_3_2 = result;
  end
  endfunction


  function automatic [73:0] MUX1HOT_v_74_3_2;
    input [73:0] input_2;
    input [73:0] input_1;
    input [73:0] input_0;
    input [2:0] sel;
    reg [73:0] result;
  begin
    result = input_0 & {74{sel[0]}};
    result = result | ( input_1 & {74{sel[1]}});
    result = result | ( input_2 & {74{sel[2]}});
    MUX1HOT_v_74_3_2 = result;
  end
  endfunction


  function automatic [6:0] MUX1HOT_v_7_3_2;
    input [6:0] input_2;
    input [6:0] input_1;
    input [6:0] input_0;
    input [2:0] sel;
    reg [6:0] result;
  begin
    result = input_0 & {7{sel[0]}};
    result = result | ( input_1 & {7{sel[1]}});
    result = result | ( input_2 & {7{sel[2]}});
    MUX1HOT_v_7_3_2 = result;
  end
  endfunction


  function automatic [93:0] MUX1HOT_v_94_3_2;
    input [93:0] input_2;
    input [93:0] input_1;
    input [93:0] input_0;
    input [2:0] sel;
    reg [93:0] result;
  begin
    result = input_0 & {94{sel[0]}};
    result = result | ( input_1 & {94{sel[1]}});
    result = result | ( input_2 & {94{sel[2]}});
    MUX1HOT_v_94_3_2 = result;
  end
  endfunction


  function automatic [0:0] MUX_s_1_2_2;
    input [0:0] input_0;
    input [0:0] input_1;
    input [0:0] sel;
    reg [0:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_s_1_2_2 = result;
  end
  endfunction


  function automatic [9:0] MUX_v_10_2_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input [0:0] sel;
    reg [9:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_10_2_2 = result;
  end
  endfunction


  function automatic [9:0] MUX_v_10_8_2;
    input [9:0] input_0;
    input [9:0] input_1;
    input [9:0] input_2;
    input [9:0] input_3;
    input [9:0] input_4;
    input [9:0] input_5;
    input [9:0] input_6;
    input [9:0] input_7;
    input [2:0] sel;
    reg [9:0] result;
  begin
    case (sel)
      3'b000 : begin
        result = input_0;
      end
      3'b001 : begin
        result = input_1;
      end
      3'b010 : begin
        result = input_2;
      end
      3'b011 : begin
        result = input_3;
      end
      3'b100 : begin
        result = input_4;
      end
      3'b101 : begin
        result = input_5;
      end
      3'b110 : begin
        result = input_6;
      end
      default : begin
        result = input_7;
      end
    endcase
    MUX_v_10_8_2 = result;
  end
  endfunction


  function automatic [24:0] MUX_v_25_2_2;
    input [24:0] input_0;
    input [24:0] input_1;
    input [0:0] sel;
    reg [24:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_25_2_2 = result;
  end
  endfunction


  function automatic [1:0] MUX_v_2_2_2;
    input [1:0] input_0;
    input [1:0] input_1;
    input [0:0] sel;
    reg [1:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_2_2_2 = result;
  end
  endfunction


  function automatic [31:0] MUX_v_32_2_2;
    input [31:0] input_0;
    input [31:0] input_1;
    input [0:0] sel;
    reg [31:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_32_2_2 = result;
  end
  endfunction


  function automatic [2:0] MUX_v_3_4_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input [2:0] input_2;
    input [2:0] input_3;
    input [1:0] sel;
    reg [2:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      2'b10 : begin
        result = input_2;
      end
      default : begin
        result = input_3;
      end
    endcase
    MUX_v_3_4_2 = result;
  end
  endfunction


  function automatic [3:0] MUX_v_4_2_2;
    input [3:0] input_0;
    input [3:0] input_1;
    input [0:0] sel;
    reg [3:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_4_2_2 = result;
  end
  endfunction


  function automatic [4:0] MUX_v_5_4_2;
    input [4:0] input_0;
    input [4:0] input_1;
    input [4:0] input_2;
    input [4:0] input_3;
    input [1:0] sel;
    reg [4:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      2'b10 : begin
        result = input_2;
      end
      default : begin
        result = input_3;
      end
    endcase
    MUX_v_5_4_2 = result;
  end
  endfunction


  function automatic [66:0] MUX_v_67_2_2;
    input [66:0] input_0;
    input [66:0] input_1;
    input [0:0] sel;
    reg [66:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_67_2_2 = result;
  end
  endfunction


  function automatic [73:0] MUX_v_74_2_2;
    input [73:0] input_0;
    input [73:0] input_1;
    input [0:0] sel;
    reg [73:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_74_2_2 = result;
  end
  endfunction


  function automatic [6:0] MUX_v_7_2_2;
    input [6:0] input_0;
    input [6:0] input_1;
    input [0:0] sel;
    reg [6:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_7_2_2 = result;
  end
  endfunction


  function automatic [6:0] MUX_v_7_4_2;
    input [6:0] input_0;
    input [6:0] input_1;
    input [6:0] input_2;
    input [6:0] input_3;
    input [1:0] sel;
    reg [6:0] result;
  begin
    case (sel)
      2'b00 : begin
        result = input_0;
      end
      2'b01 : begin
        result = input_1;
      end
      2'b10 : begin
        result = input_2;
      end
      default : begin
        result = input_3;
      end
    endcase
    MUX_v_7_4_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_2_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input [0:0] sel;
    reg [7:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_8_2_2 = result;
  end
  endfunction


  function automatic [7:0] MUX_v_8_8_2;
    input [7:0] input_0;
    input [7:0] input_1;
    input [7:0] input_2;
    input [7:0] input_3;
    input [7:0] input_4;
    input [7:0] input_5;
    input [7:0] input_6;
    input [7:0] input_7;
    input [2:0] sel;
    reg [7:0] result;
  begin
    case (sel)
      3'b000 : begin
        result = input_0;
      end
      3'b001 : begin
        result = input_1;
      end
      3'b010 : begin
        result = input_2;
      end
      3'b011 : begin
        result = input_3;
      end
      3'b100 : begin
        result = input_4;
      end
      3'b101 : begin
        result = input_5;
      end
      3'b110 : begin
        result = input_6;
      end
      default : begin
        result = input_7;
      end
    endcase
    MUX_v_8_8_2 = result;
  end
  endfunction


  function automatic [93:0] MUX_v_94_2_2;
    input [93:0] input_0;
    input [93:0] input_1;
    input [0:0] sel;
    reg [93:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_94_2_2 = result;
  end
  endfunction


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [18:0] readslicef_47_19_28;
    input [46:0] vector;
    reg [46:0] tmp;
  begin
    tmp = vector >> 28;
    readslicef_47_19_28 = tmp[18:0];
  end
  endfunction


  function automatic [1:0] signext_2_1;
    input [0:0] vector;
  begin
    signext_2_1= {{1{vector[0]}}, vector};
  end
  endfunction


  function automatic [6:0] signext_7_1;
    input [0:0] vector;
  begin
    signext_7_1= {{6{vector[0]}}, vector};
  end
  endfunction


  function automatic [10:0] conv_s2u_9_11 ;
    input [8:0]  vector ;
  begin
    conv_s2u_9_11 = {{2{vector[8]}}, vector};
  end
  endfunction


  function automatic [10:0] conv_u2s_10_11 ;
    input [9:0]  vector ;
  begin
    conv_u2s_10_11 =  {1'b0, vector};
  end
  endfunction


  function automatic [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction


  function automatic [24:0] conv_u2u_4_25 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_25 = {{21{1'b0}}, vector};
  end
  endfunction


  function automatic [7:0] conv_u2u_7_8 ;
    input [6:0]  vector ;
  begin
    conv_u2u_7_8 = {1'b0, vector};
  end
  endfunction


  function automatic [10:0] conv_u2u_9_11 ;
    input [8:0]  vector ;
  begin
    conv_u2u_9_11 = {{2{1'b0}}, vector};
  end
  endfunction


  function automatic [18:0] conv_u2u_19_19 ;
    input [18:0]  vector ;
  begin
    conv_u2u_19_19 = vector;
  end
  endfunction


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction


  function automatic [73:0] conv_u2u_67_74 ;
    input [66:0]  vector ;
  begin
    conv_u2u_67_74 = {{7{1'b0}}, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_struct
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_struct (
  clk, rst, conf_info_rsc_dat_batch, conf_info_rsc_vld, conf_info_rsc_rdy, dma_read_ctrl_rsc_dat_size,
      dma_read_ctrl_rsc_dat_length, dma_read_ctrl_rsc_dat_index, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat_size, dma_write_ctrl_rsc_dat_length,
      dma_write_ctrl_rsc_dat_index, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat,
      dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat_batch;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [2:0] dma_read_ctrl_rsc_dat_size;
  output [31:0] dma_read_ctrl_rsc_dat_length;
  output [31:0] dma_read_ctrl_rsc_dat_index;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  output [2:0] dma_write_ctrl_rsc_dat_size;
  output [31:0] dma_write_ctrl_rsc_dat_length;
  output [31:0] dma_write_ctrl_rsc_dat_index;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_rsc_vld;


  // Interconnect Declarations
  wire [31:0] plm_out_data_rsci_d_d;
  wire [31:0] plm_out_data_rsci_q_d;
  wire [6:0] plm_out_data_rsci_radr_d;
  wire [6:0] plm_out_data_rsci_wadr_d;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire plm_out_data_rsc_clken;
  wire [31:0] plm_out_data_rsc_q;
  wire [6:0] plm_out_data_rsc_radr;
  wire plm_out_data_rsc_we;
  wire [31:0] plm_out_data_rsc_d;
  wire [6:0] plm_out_data_rsc_wadr;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_clken;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_q;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_radr;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_we;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wadr;
  wire [66:0] dma_read_ctrl_rsc_dat;
  wire [66:0] dma_write_ctrl_rsc_dat;
  wire plm_out_data_rsci_we_d_iff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;


  // Interconnect Declarations for Component Instantiations 
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd32),
  .depth(32'sd128),
  .latency(32'sd1)) plm_out_data_rsc_comp (
      .clk(clk),
      .clken(plm_out_data_rsc_clken),
      .d(plm_out_data_rsc_d),
      .q(plm_out_data_rsc_q),
      .radr(plm_out_data_rsc_radr),
      .wadr(plm_out_data_rsc_wadr),
      .we(plm_out_data_rsc_we)
    );
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd67),
  .depth(32'sd128),
  .latency(32'sd1)) ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_comp
      (
      .clk(clk),
      .clken(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_clken),
      .d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_d),
      .q(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_q),
      .radr(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_radr),
      .wadr(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wadr),
      .we(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_we)
    );
  esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_8_7_32_128_128_32_1_gen
      plm_out_data_rsci (
      .clken(plm_out_data_rsc_clken),
      .q(plm_out_data_rsc_q),
      .radr(plm_out_data_rsc_radr),
      .we(plm_out_data_rsc_we),
      .d(plm_out_data_rsc_d),
      .wadr(plm_out_data_rsc_wadr),
      .clken_d(1'b1),
      .d_d(plm_out_data_rsci_d_d),
      .q_d(plm_out_data_rsci_q_d),
      .radr_d(plm_out_data_rsci_radr_d),
      .wadr_d(plm_out_data_rsci_wadr_d),
      .we_d(plm_out_data_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(plm_out_data_rsci_we_d_iff),
      .readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_9_7_67_128_128_67_1_gen
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci
      (
      .clken(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_clken),
      .q(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_q),
      .radr(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_radr),
      .we(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_we),
      .d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_d),
      .wadr(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wadr),
      .clken_d(1'b1),
      .d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .radr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d),
      .wadr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d),
      .we_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_softmax_cxx_core softmax_cxx_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_batch),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .plm_out_data_rsci_d_d(plm_out_data_rsci_d_d),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_radr_d(plm_out_data_rsci_radr_d),
      .plm_out_data_rsci_wadr_d(plm_out_data_rsci_wadr_d),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff)
    );
  assign dma_read_ctrl_rsc_dat_index = dma_read_ctrl_rsc_dat[31:0];
  assign dma_read_ctrl_rsc_dat_length = dma_read_ctrl_rsc_dat[63:32];
  assign dma_read_ctrl_rsc_dat_size = dma_read_ctrl_rsc_dat[66:64];
  assign dma_write_ctrl_rsc_dat_index = dma_write_ctrl_rsc_dat[31:0];
  assign dma_write_ctrl_rsc_dat_length = dma_write_ctrl_rsc_dat[63:32];
  assign dma_write_ctrl_rsc_dat_size = dma_write_ctrl_rsc_dat[66:64];
endmodule

// ------------------------------------------------------------------
//  Design Unit:    softmax_cxx_basic_fx32_dma64
// ------------------------------------------------------------------


module softmax_cxx_basic_fx32_dma64 (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, dma_read_ctrl_rsc_dat,
      dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld,
      dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_rsc_vld;


  // Interconnect Declarations
  wire [2:0] dma_read_ctrl_rsc_dat_size;
  wire [31:0] dma_read_ctrl_rsc_dat_length;
  wire [31:0] dma_read_ctrl_rsc_dat_index;
  wire [2:0] dma_write_ctrl_rsc_dat_size;
  wire [31:0] dma_write_ctrl_rsc_dat_length;
  wire [31:0] dma_write_ctrl_rsc_dat_index;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_struct softmax_cxx_struct_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat_batch(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .dma_read_ctrl_rsc_dat_size(dma_read_ctrl_rsc_dat_size),
      .dma_read_ctrl_rsc_dat_length(dma_read_ctrl_rsc_dat_length),
      .dma_read_ctrl_rsc_dat_index(dma_read_ctrl_rsc_dat_index),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_write_ctrl_rsc_dat_size(dma_write_ctrl_rsc_dat_size),
      .dma_write_ctrl_rsc_dat_length(dma_write_ctrl_rsc_dat_length),
      .dma_write_ctrl_rsc_dat_index(dma_write_ctrl_rsc_dat_index),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .acc_done_rsc_vld(acc_done_rsc_vld)
    );
  assign dma_read_ctrl_rsc_dat = {dma_read_ctrl_rsc_dat_size , dma_read_ctrl_rsc_dat_length
      , dma_read_ctrl_rsc_dat_index};
  assign dma_write_ctrl_rsc_dat = {dma_write_ctrl_rsc_dat_size , dma_write_ctrl_rsc_dat_length
      , dma_write_ctrl_rsc_dat_index};
endmodule



