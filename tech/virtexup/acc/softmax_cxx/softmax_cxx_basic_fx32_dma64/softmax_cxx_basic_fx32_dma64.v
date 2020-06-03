
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

//------> ./softmax_cxx_mgc_io_sync_v2.v 
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


module esp_acc_softmax_cxx_mgc_io_sync_v2 (ld, lz);
    parameter valid = 0;

    input  ld;
    output lz;

    wire   lz;

    assign lz = ld;

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

//------> ./softmax_cxx_ccs_out_v1.v 
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

module esp_acc_softmax_cxx_ccs_out_v1 (dat, idat);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output   [width-1:0] dat;
  input    [width-1:0] idat;

  wire     [width-1:0] dat;

  assign dat = idat;

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
//  Generated date: Wed Jun  3 18:08:31 2020
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
//  Generated date: Wed Jun  3 18:09:02 2020
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj_debug_rsc_triosy_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj_debug_rsc_triosy_wait_ctrl
    (
  core_wten, debug_rsc_triosy_obj_iswt0, debug_rsc_triosy_obj_ld_core_sct
);
  input core_wten;
  input debug_rsc_triosy_obj_iswt0;
  output debug_rsc_triosy_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign debug_rsc_triosy_obj_ld_core_sct = debug_rsc_triosy_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci_acc_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci_acc_done_wait_ctrl (
  core_wten, acc_done_synci_iswt0, acc_done_synci_ivld_core_sct
);
  input core_wten;
  input acc_done_synci_iswt0;
  output acc_done_synci_ivld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign acc_done_synci_ivld_core_sct = acc_done_synci_iswt0 & (~ core_wten);
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj (
  debug_rsc_triosy_lz, core_wten, debug_rsc_triosy_obj_iswt0
);
  output debug_rsc_triosy_lz;
  input core_wten;
  input debug_rsc_triosy_obj_iswt0;


  // Interconnect Declarations
  wire debug_rsc_triosy_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) debug_rsc_triosy_obj (
      .ld(debug_rsc_triosy_obj_ld_core_sct),
      .lz(debug_rsc_triosy_lz)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj_debug_rsc_triosy_wait_ctrl
      softmax_cxx_core_debug_rsc_triosy_obj_debug_rsc_triosy_wait_ctrl_inst (
      .core_wten(core_wten),
      .debug_rsc_triosy_obj_iswt0(debug_rsc_triosy_obj_iswt0),
      .debug_rsc_triosy_obj_ld_core_sct(debug_rsc_triosy_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci (
  acc_done_sync_vld, core_wten, acc_done_synci_iswt0
);
  output acc_done_sync_vld;
  input core_wten;
  input acc_done_synci_iswt0;


  // Interconnect Declarations
  wire acc_done_synci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_vld_v1 #(.rscid(32'sd14)) acc_done_synci (
      .vld(acc_done_sync_vld),
      .ivld(acc_done_synci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci_acc_done_wait_ctrl softmax_cxx_core_acc_done_synci_acc_done_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .acc_done_synci_iswt0(acc_done_synci_iswt0),
      .acc_done_synci_ivld_core_sct(acc_done_synci_ivld_core_sct)
    );
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd6),
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
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd5),
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
  assign nl_dma_write_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , (dma_write_ctrl_rsci_idat[10:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd4),
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd3),
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
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd2),
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
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_rsc_dat, conf_info_rsc_vld,
      conf_info_rsc_rdy, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat,
      dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld,
      dma_write_chnl_rsc_rdy, acc_done_sync_vld, plm_out_data_rsci_d_d, plm_out_data_rsci_q_d,
      plm_out_data_rsci_radr_d, plm_out_data_rsci_wadr_d, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      plm_out_data_rsci_we_d_pff, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;
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
  output acc_done_sync_vld;
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
  reg [3:0] dma_write_ctrl_rsci_idat_10_7;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [3:0] fsm_output;
  wire BATCH_LOOP_nor_13_tmp;
  wire [4:0] BATCH_LOOP_acc_3_tmp;
  wire [5:0] nl_BATCH_LOOP_acc_3_tmp;
  wire [7:0] STORE_LOOP_acc_1_tmp;
  wire [8:0] nl_STORE_LOOP_acc_1_tmp;
  wire BATCH_LOOP_and_13_tmp;
  wire [1:0] STORE_LOOP_mux_28_tmp;
  wire [1:0] STORE_LOOP_mux1h_45_tmp;
  wire BATCH_LOOP_and_12_tmp;
  wire or_tmp_6;
  wire and_tmp;
  wire mux_tmp_10;
  wire or_tmp_21;
  wire or_tmp_22;
  wire or_tmp_25;
  wire or_tmp_26;
  wire mux_tmp_27;
  wire mux_tmp_29;
  wire mux_tmp_40;
  wire not_tmp_36;
  wire and_tmp_8;
  wire and_tmp_21;
  wire or_dcpl_9;
  wire and_dcpl_27;
  wire or_tmp_150;
  wire mux_tmp_156;
  wire mux_tmp_160;
  wire nand_tmp_34;
  wire or_tmp_168;
  wire mux_tmp_161;
  wire mux_tmp_163;
  wire and_dcpl_29;
  wire and_dcpl_32;
  wire or_tmp_181;
  wire mux_tmp_175;
  wire or_tmp_182;
  wire mux_tmp_176;
  wire and_dcpl_47;
  wire mux_tmp_198;
  wire and_dcpl_84;
  wire and_dcpl_87;
  wire and_dcpl_90;
  wire or_tmp_201;
  wire or_dcpl_17;
  wire or_dcpl_24;
  wire and_tmp_66;
  wire or_tmp_238;
  wire nor_tmp_90;
  wire mux_tmp_260;
  wire mux_tmp_262;
  wire mux_tmp_269;
  wire mux_tmp_270;
  wire or_dcpl_57;
  wire or_tmp_250;
  wire mux_tmp_271;
  wire not_tmp_196;
  wire not_tmp_197;
  wire or_dcpl_71;
  wire or_dcpl_75;
  wire and_tmp_88;
  wire nand_tmp_44;
  wire or_tmp_282;
  wire and_dcpl_126;
  wire and_tmp_92;
  wire and_dcpl_132;
  wire and_tmp_103;
  wire or_tmp_363;
  wire mux_tmp_449;
  wire mux_tmp_467;
  wire mux_tmp_482;
  wire and_tmp_145;
  wire or_tmp_419;
  wire and_tmp_148;
  wire and_dcpl_155;
  wire and_dcpl_159;
  wire or_tmp_431;
  wire and_dcpl_247;
  wire or_tmp_526;
  wire or_tmp_529;
  wire or_tmp_536;
  wire or_tmp_547;
  wire or_tmp_550;
  wire or_tmp_576;
  wire or_tmp_580;
  wire or_tmp_587;
  wire or_tmp_615;
  wire or_tmp_629;
  wire or_tmp_676;
  wire or_tmp_681;
  wire STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
  wire exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
  wire STORE_LOOP_equal_tmp_2_mx0w0;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0;
  wire exitL_exit_STORE_LOOP_sva_mx1;
  wire lfst_exit_STORE_LOOP_lpi_2_2_mx1;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0_mx1;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2;
  reg STORE_LOOP_or_tmp_1;
  wire STORE_LOOP_and_2_ssc_1;
  wire STORE_LOOP_and_4_ssc_1;
  reg STORE_LOOP_equal_tmp_2_1;
  wire CALC_SOFTMAX_LOOP_and_svs_1;
  reg STORE_LOOP_equal_tmp_1_1;
  reg STORE_LOOP_equal_tmp_1;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1;
  wire exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  reg exit_STORE_CTRL_LOOP_lpi_2;
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
  reg exit_CALC_SOFTMAX_LOOP_lpi_2;
  wire exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0;
  wire STORE_LOOP_or_tmp_mx0w0;
  wire STORE_LOOP_nor_tmp_mx0w0;
  wire STORE_LOOP_equal_tmp_1_mx0w0;
  wire [7:0] LOAD_LOOP_i_7_0_sva_2;
  wire [8:0] nl_LOAD_LOOP_i_7_0_sva_2;
  wire [7:0] CALC_EXP_LOOP_i_7_0_sva_2;
  wire [8:0] nl_CALC_EXP_LOOP_i_7_0_sva_2;
  wire [7:0] SUM_EXP_LOOP_i_7_0_sva_2;
  wire [8:0] nl_SUM_EXP_LOOP_i_7_0_sva_2;
  wire [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire [6:0] LOAD_LOOP_i_7_0_lpi_2_6_0_mx1;
  wire [7:0] CALC_SOFTMAX_LOOP_i_7_0_sva_2;
  wire [8:0] nl_CALC_SOFTMAX_LOOP_i_7_0_sva_2;
  reg [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0;
  wire STORE_LOOP_STORE_LOOP_and_cse_1;
  wire STORE_LOOP_STORE_LOOP_nor_1_cse_1;
  wire STORE_LOOP_equal_tmp_mx0w0;
  reg STORE_LOOP_nor_tmp_1;
  reg exit_BATCH_LOOP_lpi_2_dfm_1;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0;
  reg STORE_LOOP_equal_tmp_2;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [74:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  reg [7:0] STORE_LOOP_i_7_0_sva_1_1;
  reg CALC_SOFTMAX_LOOP_asn_3_itm_1;
  reg exit_STORE_CTRL_LOOP_lpi_2_dfm_3;
  reg STORE_LOOP_asn_19_itm_1;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0;
  reg CALC_SOFTMAX_LOOP_asn_itm_9;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_9;
  reg BATCH_LOOP_stage_0_12;
  reg BATCH_LOOP_stage_v_9;
  reg BATCH_LOOP_stage_0_10;
  reg BATCH_LOOP_stage_0_11;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_2;
  reg exitL_exit_STORE_LOOP_sva;
  reg STORE_LOOP_STORE_LOOP_and_10_itm_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_1_0;
  reg BATCH_LOOP_stage_v_8;
  reg BATCH_LOOP_stage_0_9;
  reg CALC_SOFTMAX_LOOP_asn_itm_8;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_8_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_8;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_1_0;
  reg BATCH_LOOP_stage_v_7;
  reg BATCH_LOOP_stage_0_8;
  reg CALC_SOFTMAX_LOOP_asn_itm_7;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_7_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_7;
  reg BATCH_LOOP_stage_v_6;
  reg BATCH_LOOP_stage_0_7;
  reg BATCH_LOOP_stage_v_5;
  reg BATCH_LOOP_stage_0_6;
  reg CALC_SOFTMAX_LOOP_asn_itm_4;
  reg CALC_SOFTMAX_LOOP_asn_itm_3;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_3;
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
  reg STORE_LOOP_asn_19_itm_5;
  reg STORE_LOOP_asn_19_itm_3;
  reg LOAD_LOOP_and_1_svs_5;
  wire LOAD_LOOP_and_1_svs_mx0w0;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
  wire or_187_cse;
  reg reg_debug_rsc_triosy_obj_ld_core_psct_cse;
  reg reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse;
  reg reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse;
  reg reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_dma_write_chnl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_chnl_rsci_irdy_core_psct_cse;
  reg reg_dma_write_ctrl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_ctrl_rsci_ivld_core_psct_cse;
  reg reg_conf_info_rsci_irdy_core_psct_cse;
  wire STORE_LOOP_and_46_cse;
  wire CALC_SOFTMAX_LOOP_and_cse;
  wire CALC_SOFTMAX_LOOP_and_22_cse;
  wire STORE_LOOP_and_52_cse;
  wire BATCH_LOOP_and_17_cse;
  wire nor_233_cse;
  wire or_23_cse;
  wire STORE_LOOP_and_59_cse;
  wire STORE_LOOP_and_62_cse;
  wire and_919_cse;
  wire nor_263_cse;
  wire or_86_cse;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse;
  wire CALC_SOFTMAX_LOOP_and_23_cse;
  wire CALC_SOFTMAX_LOOP_and_24_cse;
  wire STORE_LOOP_and_64_cse;
  wire LOAD_LOOP_i_and_cse;
  wire LOAD_LOOP_and_2_cse;
  wire LOAD_LOOP_and_3_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_1_cse;
  wire or_434_cse;
  wire or_843_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  wire CALC_SOFTMAX_LOOP_and_30_cse;
  wire and_920_cse;
  wire or_9_cse;
  wire or_78_cse;
  wire and_950_cse;
  wire and_952_cse;
  wire mux_58_cse;
  wire or_74_cse;
  wire and_944_cse;
  wire and_964_cse;
  wire and_961_cse;
  wire or_354_cse;
  wire nor_224_cse;
  wire and_967_cse;
  wire and_959_cse;
  wire or_369_cse;
  wire and_933_cse;
  wire or_602_cse;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0;
  wire STORE_LOOP_asn_80;
  wire STORE_LOOP_i_and_8_rgt;
  reg [6:0] reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse;
  reg reg_STORE_LOOP_and_8_itm_1_cse;
  wire nor_235_cse;
  wire mux_42_cse;
  wire or_175_cse;
  wire STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1;
  wire mux_272_cse;
  wire or_362_cse;
  wire mux_346_cse;
  wire mux_502_cse;
  wire mux_316_cse;
  wire mux_311_cse;
  wire nor_207_cse;
  wire mux_273_cse;
  wire mux_378_cse;
  wire mux_377_cse;
  wire mux_375_cse;
  wire mux_191_cse;
  wire mux_306_cse;
  wire and_304_cse;
  wire and_928_cse;
  wire mux_504_cse;
  wire mux_445_cse;
  wire mux_444_cse;
  wire mux_443_cse;
  wire mux_462_cse;
  wire and_243_cse;
  wire mux_571_cse;
  wire and_343_cse;
  wire or_42_cse;
  wire mux_52_cse;
  reg [31:0] plm_out_data_rsci_d_d_reg;
  wire [31:0] CALC_SOFTMAX_LOOP_mux_1_rmff;
  reg [6:0] plm_out_data_rsci_radr_d_reg;
  wire [6:0] STORE_LOOP_i_mux_rmff;
  reg [6:0] plm_out_data_rsci_wadr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_1_rmff;
  wire plm_out_data_rsci_we_d_iff;
  wire and_483_rmff;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_493_rmff;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
  reg [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_rmff;
  reg [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg;
  wire [6:0] CALC_EXP_LOOP_i_mux_rmff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;
  wire and_489_rmff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_487_rmff;
  wire and_481_rmff;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2;
  wire and_344_cse;
  wire and_353_cse;
  wire and_464_cse;
  wire or_dcpl;
  wire STORE_LOOP_and_7_itm_mx0w0;
  wire or_864_tmp;
  wire or_861_tmp;
  wire STORE_LOOP_and_22_tmp;
  wire STORE_LOOP_and_3_cse;
  wire and_985_cse;
  wire and_986_cse;
  wire [93:0] operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [93:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm;
  wire [72:0] operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm;
  wire [3:0] z_out;
  wire [4:0] nl_z_out;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2;
  reg [3:0] dma_read_data_index_10_7_sva;
  reg [3:0] dma_write_data_index_10_7_sva;
  reg [31:0] batch_sva;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3;
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
  reg STORE_LOOP_or_24_itm_1;
  reg STORE_LOOP_or_24_itm_2;
  reg STORE_LOOP_and_10_itm_2;
  reg LOAD_LOOP_and_1_svs_st_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_1;
  reg CALC_SOFTMAX_LOOP_asn_itm_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_6;
  reg CALC_SOFTMAX_LOOP_asn_itm_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_6;
  reg STORE_LOOP_asn_19_itm_2;
  reg STORE_LOOP_asn_19_itm_4;
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
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1;
  wire [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [8:0] nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
  wire [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
  wire [6:0] LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0;
  wire [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1;
  wire [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2;
  wire exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3_mx0w1;
  wire STORE_LOOP_mux1h_19_mx0w1;
  wire BATCH_LOOP_stage_v_mx0c1;
  wire BATCH_LOOP_stage_v_2_mx0c0;
  wire BATCH_LOOP_stage_v_3_mx0c0;
  wire BATCH_LOOP_stage_v_4_mx0c0;
  wire [3:0] dma_read_data_index_10_7_sva_mx1;
  wire exit_STORE_CTRL_LOOP_lpi_2_mx1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1;
  wire CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1;
  wire STORE_LOOP_or_24_itm_mx0w0;
  wire STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1;
  wire [6:0] STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1;
  wire BATCH_LOOP_BATCH_LOOP_or_21_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_6_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_4_cse_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [6:0] libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp;
  wire nor_272_cse;
  wire and_616_cse;
  wire mux_47_itm;
  wire BATCH_LOOP_acc_itm_32_1;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28;
  wire mux_271_cse;
  reg reg_LOAD_LOOP_and_1_svs_1_cse;

  wire[0:0] mux_190_nl;
  wire[0:0] nor_164_nl;
  wire[0:0] mux_189_nl;
  wire[0:0] mux_188_nl;
  wire[0:0] mux_187_nl;
  wire[0:0] mux_186_nl;
  wire[0:0] mux_185_nl;
  wire[0:0] nand_37_nl;
  wire[0:0] nand_36_nl;
  wire[0:0] mux_182_nl;
  wire[0:0] nand_35_nl;
  wire[0:0] mux_181_nl;
  wire[0:0] nor_167_nl;
  wire[0:0] mux_174_nl;
  wire[0:0] nor_168_nl;
  wire[0:0] nor_27_nl;
  wire[0:0] mux_223_nl;
  wire[0:0] nor_271_nl;
  wire[0:0] or_659_nl;
  wire[0:0] or_662_nl;
  wire[0:0] mux_668_nl;
  wire[0:0] and_176_nl;
  wire[0:0] mux_55_nl;
  wire[0:0] mux_310_nl;
  wire[0:0] mux_309_nl;
  wire[0:0] mux_308_nl;
  wire[0:0] and_195_nl;
  wire[0:0] mux_315_nl;
  wire[0:0] and_194_nl;
  wire[0:0] mux_314_nl;
  wire[0:0] and_193_nl;
  wire[0:0] mux_313_nl;
  wire[0:0] and_192_nl;
  wire[0:0] mux_312_nl;
  wire[0:0] and_191_nl;
  wire[0:0] mux_317_nl;
  wire[0:0] and_197_nl;
  wire[0:0] STORE_LOOP_and_88_nl;
  wire[0:0] mux_358_nl;
  wire[0:0] mux_357_nl;
  wire[0:0] mux_355_nl;
  wire[0:0] mux_338_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl;
  wire[0:0] and_266_nl;
  wire[0:0] mux_442_nl;
  wire[0:0] and_265_nl;
  wire[0:0] mux_441_nl;
  wire[0:0] mux_440_nl;
  wire[0:0] mux_439_nl;
  wire[0:0] mux_438_nl;
  wire[0:0] and_267_nl;
  wire[0:0] and_268_nl;
  wire[0:0] mux_521_nl;
  wire[0:0] and_927_nl;
  wire[0:0] mux_523_nl;
  wire[0:0] nor_203_nl;
  wire[3:0] STORE_LOOP_mux_36_nl;
  wire[0:0] or_552_nl;
  wire[0:0] BATCH_LOOP_b_not_1_nl;
  wire[0:0] mux_560_nl;
  wire[0:0] nor_269_nl;
  wire[0:0] mux_65_nl;
  wire[0:0] mux_64_nl;
  wire[0:0] mux_63_nl;
  wire[0:0] mux_62_nl;
  wire[0:0] mux_61_nl;
  wire[0:0] mux_60_nl;
  wire[0:0] nor_270_nl;
  wire[0:0] BATCH_LOOP_mux_10_nl;
  wire[0:0] nor_264_nl;
  wire[0:0] mux_575_nl;
  wire[0:0] mux_574_nl;
  wire[0:0] nor_152_nl;
  wire[0:0] nor_153_nl;
  wire[0:0] mux_573_nl;
  wire[0:0] and_345_nl;
  wire[0:0] mux_572_nl;
  wire[0:0] mux_587_nl;
  wire[0:0] and_354_nl;
  wire[0:0] mux_598_nl;
  wire[0:0] and_360_nl;
  wire[0:0] BATCH_LOOP_mux_11_nl;
  wire[0:0] mux_476_nl;
  wire[0:0] nand_67_nl;
  wire[0:0] nand_68_nl;
  wire[0:0] BATCH_LOOP_mux_12_nl;
  wire[0:0] mux_493_nl;
  wire[0:0] nand_64_nl;
  wire[0:0] nand_65_nl;
  wire[0:0] mux_501_nl;
  wire[0:0] mux_503_nl;
  wire[0:0] nor_208_nl;
  wire[0:0] and_303_nl;
  wire[0:0] BATCH_LOOP_mux_13_nl;
  wire[0:0] mux_507_nl;
  wire[0:0] mux_506_nl;
  wire[0:0] nor_206_nl;
  wire[0:0] mux_505_nl;
  wire[0:0] BATCH_LOOP_mux_14_nl;
  wire[0:0] mux_517_nl;
  wire[0:0] mux_516_nl;
  wire[0:0] or_507_nl;
  wire[0:0] mux_515_nl;
  wire[0:0] mux_514_nl;
  wire[0:0] nand_61_nl;
  wire[0:0] BATCH_LOOP_mux_15_nl;
  wire[0:0] mux_520_nl;
  wire[0:0] nand_59_nl;
  wire[0:0] nand_60_nl;
  wire[0:0] BATCH_LOOP_mux_16_nl;
  wire[0:0] mux_522_nl;
  wire[0:0] nand_56_nl;
  wire[0:0] nand_57_nl;
  wire[0:0] LOAD_CTRL_LOOP_not_6_nl;
  wire[0:0] mux_611_nl;
  wire[0:0] and_370_nl;
  wire[0:0] mux_610_nl;
  wire[0:0] mux_622_nl;
  wire[0:0] and_376_nl;
  wire[0:0] and_469_nl;
  wire[0:0] BATCH_LOOP_if_not_nl;
  wire[6:0] STORE_LOOP_i_mux_5_nl;
  wire[0:0] STORE_LOOP_i_or_3_nl;
  wire[0:0] nor_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_1_nl;
  wire[0:0] STORE_LOOP_or_19_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_2_nl;
  wire[0:0] STORE_LOOP_or_20_nl;
  wire[0:0] or_528_nl;
  wire[0:0] STORE_CTRL_LOOP_mux_nl;
  wire[0:0] STORE_LOOP_mux_23_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_9_nl;
  wire[0:0] STORE_LOOP_and_86_nl;
  wire[0:0] STORE_LOOP_mux_41_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_nl;
  wire[0:0] or_566_nl;
  wire[0:0] or_594_nl;
  wire[32:0] BATCH_LOOP_acc_nl;
  wire[33:0] nl_BATCH_LOOP_acc_nl;
  wire[0:0] STORE_LOOP_mux_63_nl;
  wire[0:0] STORE_LOOP_and_40_nl;
  wire[0:0] STORE_LOOP_and_41_nl;
  wire[0:0] STORE_LOOP_or_23_nl;
  wire[1:0] STORE_LOOP_and_nl;
  wire[0:0] nor_267_nl;
  wire[0:0] and_982_nl;
  wire[46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire signed [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire[0:0] and_13_nl;
  wire[0:0] mux_43_nl;
  wire[0:0] nor_259_nl;
  wire[0:0] or_31_nl;
  wire[0:0] mux_51_nl;
  wire[0:0] mux_50_nl;
  wire[0:0] mux_49_nl;
  wire[0:0] mux_666_nl;
  wire[0:0] or_43_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] mux_161_nl;
  wire[0:0] or_165_nl;
  wire[0:0] or_163_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] or_162_nl;
  wire[0:0] nand_33_nl;
  wire[0:0] mux_172_nl;
  wire[0:0] mux_171_nl;
  wire[0:0] mux_170_nl;
  wire[0:0] mux_169_nl;
  wire[0:0] mux_48_nl;
  wire[0:0] or_856_nl;
  wire[0:0] or_150_nl;
  wire[0:0] and_81_nl;
  wire[0:0] mux_176_nl;
  wire[0:0] mux_175_nl;
  wire[0:0] or_178_nl;
  wire[0:0] nor_219_nl;
  wire[0:0] mux_276_nl;
  wire[0:0] and_179_nl;
  wire[0:0] mux_285_nl;
  wire[0:0] mux_284_nl;
  wire[0:0] mux_283_nl;
  wire[0:0] mux_282_nl;
  wire[0:0] mux_281_nl;
  wire[0:0] mux_280_nl;
  wire[0:0] nand_43_nl;
  wire[0:0] or_298_nl;
  wire[0:0] mux_305_nl;
  wire[0:0] and_188_nl;
  wire[0:0] mux_304_nl;
  wire[0:0] mux_303_nl;
  wire[0:0] mux_302_nl;
  wire[0:0] mux_301_nl;
  wire[0:0] mux_300_nl;
  wire[0:0] mux_299_nl;
  wire[0:0] mux_298_nl;
  wire[0:0] mux_297_nl;
  wire[0:0] mux_296_nl;
  wire[0:0] mux_295_nl;
  wire[0:0] mux_294_nl;
  wire[0:0] mux_293_nl;
  wire[0:0] and_973_nl;
  wire[0:0] mux_341_nl;
  wire[0:0] or_360_nl;
  wire[0:0] mux_345_nl;
  wire[0:0] or_367_nl;
  wire[0:0] mux_374_nl;
  wire[0:0] mux_373_nl;
  wire[0:0] mux_372_nl;
  wire[0:0] mux_371_nl;
  wire[0:0] or_384_nl;
  wire[0:0] mux_369_nl;
  wire[0:0] mux_365_nl;
  wire[0:0] mux_364_nl;
  wire[0:0] or_371_nl;
  wire[0:0] mux_376_nl;
  wire[0:0] mux_359_nl;
  wire[0:0] and_932_nl;
  wire[0:0] mux_465_nl;
  wire[0:0] nand_49_nl;
  wire[0:0] mux_464_nl;
  wire[0:0] nand_48_nl;
  wire[0:0] mux_463_nl;
  wire[0:0] and_281_nl;
  wire[0:0] mux_483_nl;
  wire[0:0] nor_211_nl;
  wire[0:0] mux_646_nl;
  wire[0:0] mux_231_nl;
  wire[0:0] mux_230_nl;
  wire[0:0] nor_229_nl;
  wire[0:0] mux_229_nl;
  wire[0:0] mux_228_nl;
  wire[0:0] mux_227_nl;
  wire[0:0] mux_667_nl;
  wire[0:0] or_215_nl;
  wire[0:0] mux_226_nl;
  wire[0:0] mux_665_nl;
  wire[0:0] mux_224_nl;
  wire[0:0] nor_230_nl;
  wire[3:0] BATCH_LOOP_mux_23_nl;
  wire[0:0] and_994_nl;

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
      & and_dcpl_87 & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg
      = (~ CALC_SOFTMAX_LOOP_asn_3_itm_1) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat =
      {56'b01100000000000000000000000010000000000000000000000000000 , dma_write_ctrl_rsci_idat_10_7
      , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg
      = and_dcpl_90 & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg
      = and_dcpl_84 & (fsm_output[2]);
  wire [63:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat =
      {32'b11011110101011011011111011101111 , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg
      = or_tmp_6 & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b11)
      & (~(exit_BATCH_LOOP_lpi_2_dfm_st_11 | CALC_SOFTMAX_LOOP_asn_itm_11)) & plm_out_data_rsci_bawt
      & BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11 & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg
      = mux_571_cse & and_dcpl_32 & (~(exit_BATCH_LOOP_lpi_2_dfm_st_4 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0])))
      & ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      & BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4 & (fsm_output[2]);
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl;
  wire [93:0] nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl
      = LOAD_LOOP_and_1_svs_5 & STORE_LOOP_and_10_itm_3 & (~((~ BATCH_LOOP_stage_v_5)
      | STORE_LOOP_asn_19_itm_5));
  assign nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_7_nl);
  esp_acc_softmax_cxx_ccs_out_v1 #(.rscid(32'sd1),
  .width(32'sd32)) debug_rsci (
      .idat(32'b00000000000000000000000000000000),
      .dat(debug_rsc_dat)
    );
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
      .plm_out_data_rsci_oswt_unreg_1(or_tmp_526),
      .plm_out_data_rsci_iswt0_1(reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .plm_out_data_rsci_iswt0_pff(and_483_rmff),
      .plm_out_data_rsci_iswt0_1_pff(and_493_rmff)
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
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1(and_481_rmff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1(reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff(and_489_rmff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff(and_487_rmff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci softmax_cxx_core_acc_done_synci_inst
      (
      .acc_done_sync_vld(acc_done_sync_vld),
      .core_wten(core_wten),
      .acc_done_synci_iswt0(reg_debug_rsc_triosy_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj softmax_cxx_core_debug_rsc_triosy_obj_inst
      (
      .debug_rsc_triosy_lz(debug_rsc_triosy_lz),
      .core_wten(core_wten),
      .debug_rsc_triosy_obj_iswt0(reg_debug_rsc_triosy_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg(and_483_rmff),
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
  assign or_187_cse = (STORE_LOOP_mux1h_45_tmp!=2'b00);
  assign and_919_cse = STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7]);
  assign and_920_cse = STORE_LOOP_and_2_ssc_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_164_nl = ~(lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]));
  assign mux_190_nl = MUX_s_1_2_2(nor_164_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign nand_37_nl = ~(or_187_cse & (~(and_919_cse | or_tmp_168)));
  assign mux_185_nl = MUX_s_1_2_2(nand_37_nl, mux_tmp_160, and_920_cse);
  assign mux_186_nl = MUX_s_1_2_2(mux_185_nl, mux_tmp_163, BATCH_LOOP_acc_itm_32_1);
  assign nand_35_nl = ~(STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7])
      & (~ nand_tmp_34));
  assign mux_182_nl = MUX_s_1_2_2(mux_tmp_161, nand_35_nl, or_187_cse);
  assign nand_36_nl = ~(BATCH_LOOP_acc_itm_32_1 & (~(STORE_LOOP_and_2_ssc_1 | mux_182_nl)));
  assign mux_187_nl = MUX_s_1_2_2(mux_186_nl, nand_36_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]);
  assign nor_167_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]) | mux_tmp_163);
  assign mux_181_nl = MUX_s_1_2_2(nor_167_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_188_nl = MUX_s_1_2_2((~ mux_187_nl), mux_181_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign nor_168_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_174_nl = MUX_s_1_2_2(nor_168_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_189_nl = MUX_s_1_2_2(mux_188_nl, mux_174_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_27_nl = ~(STORE_LOOP_asn_19_itm_1 | (~ BATCH_LOOP_and_12_tmp));
  assign mux_191_cse = MUX_s_1_2_2(mux_190_nl, mux_189_nl, nor_27_nl);
  assign and_481_rmff = mux_571_cse & and_dcpl_32 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_4)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0]) & and_dcpl_29 & (~ CALC_SOFTMAX_LOOP_asn_itm_4)
      & (fsm_output[2]);
  assign and_483_rmff = mux_tmp_10 & BATCH_LOOP_stage_0_11 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10) & (~ CALC_SOFTMAX_LOOP_asn_itm_10) &
      (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11)
      & BATCH_LOOP_stage_v_10 & (fsm_output[2]);
  assign and_487_rmff = mux_tmp_198 & and_dcpl_47 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0==2'b11)
      & (~ CALC_SOFTMAX_LOOP_asn_itm_3) & (fsm_output[2]);
  assign and_489_rmff = mux_tmp_198 & and_dcpl_47 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0==2'b10)
      & (fsm_output[2]);
  assign and_493_rmff = mux_tmp_10 & BATCH_LOOP_stage_0_11 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10)
      & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b00)
      & BATCH_LOOP_stage_v_10 & (fsm_output[2]);
  assign nor_272_cse = ~(lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b10)
      | exitL_exit_STORE_LOOP_sva);
  assign CALC_EXP_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg,
      or_tmp_547);
  assign or_659_nl = (~ (fsm_output[2])) | (~ mux_tmp_198) | or_dcpl_24 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0!=2'b11)
      | CALC_SOFTMAX_LOOP_asn_itm_3;
  assign CALC_SOFTMAX_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg,
      or_659_nl);
  assign operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg,
      or_tmp_547);
  assign CALC_SOFTMAX_LOOP_i_mux_1_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10,
      plm_out_data_rsci_wadr_d_reg, or_tmp_550);
  assign or_662_nl = (~ (fsm_output[2])) | (~ mux_tmp_10) | (~ BATCH_LOOP_stage_0_11)
      | exit_BATCH_LOOP_lpi_2_dfm_st_10 | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b00) | (~ BATCH_LOOP_stage_v_10);
  assign STORE_LOOP_i_mux_rmff = MUX_v_7_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9,
      plm_out_data_rsci_radr_d_reg, or_662_nl);
  assign CALC_SOFTMAX_LOOP_mux_1_rmff = MUX_v_32_2_2(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt,
      plm_out_data_rsci_d_d_reg, or_tmp_550);
  assign STORE_LOOP_and_46_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_tmp_198)
      | or_dcpl_17));
  assign mux_271_cse = MUX_s_1_2_2(nor_235_cse, or_tmp_6, or_9_cse);
  assign mux_668_nl = MUX_s_1_2_2(nor_235_cse, or_tmp_6, or_9_cse);
  assign mux_272_cse = MUX_s_1_2_2(nor_235_cse, mux_668_nl, BATCH_LOOP_stage_0_12);
  assign and_176_nl = or_434_cse & BATCH_LOOP_stage_0_11 & mux_272_cse;
  assign mux_273_cse = MUX_s_1_2_2(mux_271_cse, and_176_nl, BATCH_LOOP_stage_v_10);
  assign CALC_SOFTMAX_LOOP_and_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_273_cse)
      | not_tmp_36));
  assign CALC_SOFTMAX_LOOP_and_22_cse = core_wen & (fsm_output[2]) & and_tmp_66 &
      BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign STORE_LOOP_and_52_cse = core_wen & (fsm_output[2]) & and_tmp & BATCH_LOOP_stage_0_12
      & BATCH_LOOP_stage_v_11;
  assign BATCH_LOOP_and_17_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_13_tmp;
  assign nor_233_cse = ~((~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])));
  assign or_23_cse = (~ BATCH_LOOP_and_12_tmp) | STORE_LOOP_asn_19_itm_1;
  assign CALC_SOFTMAX_LOOP_and_23_cse = core_wen & (((~ mux_tmp_270) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2])) | or_tmp_580);
  assign and_950_cse = dma_write_ctrl_rsci_irdy_mxwt & STORE_LOOP_equal_tmp_1_1;
  assign mux_55_nl = MUX_s_1_2_2(and_952_cse, or_42_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_58_cse = MUX_s_1_2_2(mux_tmp_40, mux_55_nl, STORE_LOOP_equal_tmp_1_1);
  assign or_42_cse = exitL_exit_STORE_LOOP_sva | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign and_616_cse = ((~ mux_tmp_269) | BATCH_LOOP_acc_itm_32_1) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign STORE_LOOP_and_59_cse = core_wen & (and_616_cse | or_tmp_587);
  assign CALC_SOFTMAX_LOOP_and_24_cse = core_wen & (~((~ (fsm_output[2])) | mux_tmp_270
      | (~ BATCH_LOOP_and_13_tmp)));
  assign STORE_LOOP_and_62_cse = core_wen & (fsm_output[2]) & (~(mux_tmp_269 & (~
      BATCH_LOOP_acc_itm_32_1))) & BATCH_LOOP_and_13_tmp;
  assign nor_263_cse = ~(STORE_LOOP_or_tmp_1 | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2));
  assign or_86_cse = (STORE_LOOP_mux_28_tmp!=2'b10);
  assign or_78_cse = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2) | STORE_LOOP_or_tmp_1;
  assign mux_308_nl = MUX_s_1_2_2((~ or_74_cse), BATCH_LOOP_stage_v_11, BATCH_LOOP_stage_v_10);
  assign mux_309_nl = MUX_s_1_2_2(or_tmp_250, mux_308_nl, or_434_cse);
  assign mux_310_nl = MUX_s_1_2_2((~ mux_309_nl), mux_tmp_271, BATCH_LOOP_stage_0_12);
  assign mux_311_cse = MUX_s_1_2_2((~ or_tmp_250), mux_310_nl, BATCH_LOOP_stage_0_11);
  assign and_191_nl = BATCH_LOOP_stage_0_10 & mux_311_cse;
  assign mux_312_nl = MUX_s_1_2_2(mux_tmp_271, and_191_nl, BATCH_LOOP_stage_v_9);
  assign and_192_nl = BATCH_LOOP_stage_0_9 & mux_312_nl;
  assign mux_313_nl = MUX_s_1_2_2(mux_tmp_271, and_192_nl, BATCH_LOOP_stage_v_8);
  assign and_193_nl = BATCH_LOOP_stage_0_8 & mux_313_nl;
  assign mux_314_nl = MUX_s_1_2_2(mux_tmp_271, and_193_nl, BATCH_LOOP_stage_v_7);
  assign and_194_nl = BATCH_LOOP_stage_0_7 & mux_314_nl;
  assign mux_315_nl = MUX_s_1_2_2(mux_tmp_271, and_194_nl, BATCH_LOOP_stage_v_6);
  assign and_195_nl = BATCH_LOOP_stage_0_6 & mux_315_nl;
  assign mux_316_cse = MUX_s_1_2_2(mux_tmp_271, and_195_nl, BATCH_LOOP_stage_v_5);
  assign and_197_nl = BATCH_LOOP_stage_0_5 & or_843_cse & mux_316_cse;
  assign mux_317_nl = MUX_s_1_2_2(mux_tmp_271, and_197_nl, BATCH_LOOP_stage_v_4);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse = core_wen
      & (~((~ (fsm_output[2])) | (~(or_602_cse & or_tmp_6 & mux_317_nl)) | or_dcpl_24
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0!=2'b10) | (~ LOAD_LOOP_and_1_svs_st_3)));
  assign STORE_LOOP_and_64_cse = core_wen & ((exit_BATCH_LOOP_lpi_2_dfm_1 & BATCH_LOOP_and_12_tmp
      & (fsm_output[2])) | or_tmp_629);
  assign LOAD_LOOP_i_and_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_12_tmp;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp
      = LOAD_LOOP_and_1_svs_5 & STORE_LOOP_and_10_itm_3 & (~((~ mux_445_cse) | or_dcpl_75
      | STORE_LOOP_asn_19_itm_5));
  assign LOAD_LOOP_and_2_cse = core_wen & BATCH_LOOP_and_12_tmp;
  assign LOAD_LOOP_and_3_cse = core_wen & and_tmp_103;
  assign or_434_cse = CALC_SOFTMAX_LOOP_mul_cmp_bawt | CALC_SOFTMAX_LOOP_asn_itm_10
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_10;
  assign or_843_cse = exit_BATCH_LOOP_lpi_2_dfm_st_4 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0!=2'b10)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt;
  assign mux_438_nl = MUX_s_1_2_2((~ mux_tmp_175), or_tmp_181, BATCH_LOOP_stage_v_10);
  assign mux_439_nl = MUX_s_1_2_2(or_tmp_182, mux_438_nl, or_434_cse);
  assign mux_440_nl = MUX_s_1_2_2((~ mux_439_nl), mux_tmp_176, BATCH_LOOP_stage_0_12);
  assign mux_441_nl = MUX_s_1_2_2((~ or_tmp_182), mux_440_nl, BATCH_LOOP_stage_0_11);
  assign and_265_nl = BATCH_LOOP_stage_0_10 & mux_441_nl;
  assign mux_442_nl = MUX_s_1_2_2(mux_tmp_176, and_265_nl, BATCH_LOOP_stage_v_9);
  assign and_266_nl = BATCH_LOOP_stage_0_9 & mux_442_nl;
  assign mux_443_cse = MUX_s_1_2_2(mux_tmp_176, and_266_nl, BATCH_LOOP_stage_v_8);
  assign and_267_nl = BATCH_LOOP_stage_0_8 & mux_443_cse;
  assign mux_444_cse = MUX_s_1_2_2(mux_tmp_176, and_267_nl, BATCH_LOOP_stage_v_7);
  assign and_268_nl = BATCH_LOOP_stage_0_7 & mux_444_cse;
  assign mux_445_cse = MUX_s_1_2_2(mux_tmp_176, and_268_nl, BATCH_LOOP_stage_v_6);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_1_cse
      = core_wen & and_tmp_21;
  assign and_959_cse = BATCH_LOOP_stage_v_9 & BATCH_LOOP_stage_0_10;
  assign CALC_SOFTMAX_LOOP_and_30_cse = core_wen & ((fsm_output[1]) | or_tmp_681);
  assign STORE_LOOP_i_and_8_rgt = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1;
  assign and_343_cse = BATCH_LOOP_stage_0_6 & mux_445_cse;
  assign mux_571_cse = MUX_s_1_2_2(mux_tmp_176, and_343_cse, BATCH_LOOP_stage_v_5);
  assign and_344_cse = BATCH_LOOP_stage_0_5 & mux_571_cse;
  assign and_353_cse = BATCH_LOOP_stage_0_5 & or_843_cse & mux_571_cse;
  assign mux_501_nl = MUX_s_1_2_2(mux_tmp_175, (~ or_tmp_181), BATCH_LOOP_stage_v_10);
  assign mux_502_cse = MUX_s_1_2_2(mux_501_nl, mux_tmp_175, BATCH_LOOP_stage_0_12);
  assign nor_207_cse = ~((~(BATCH_LOOP_stage_0_10 | (~ BATCH_LOOP_stage_v_9))) |
      BATCH_LOOP_stage_v_10 | (~ mux_tmp_175));
  assign nor_208_nl = ~(or_tmp_363 | (~ mux_tmp_175));
  assign and_303_nl = BATCH_LOOP_stage_0_10 & mux_502_cse;
  assign mux_503_nl = MUX_s_1_2_2(nor_208_nl, and_303_nl, BATCH_LOOP_stage_0_11);
  assign mux_504_cse = MUX_s_1_2_2(mux_tmp_175, mux_503_nl, BATCH_LOOP_stage_v_9);
  assign and_304_cse = BATCH_LOOP_stage_0_9 & mux_504_cse;
  assign and_928_cse = BATCH_LOOP_stage_0_9 & nor_207_cse;
  assign and_464_cse = or_843_cse & mux_571_cse;
  assign and_376_nl = or_843_cse & mux_316_cse;
  assign mux_622_nl = MUX_s_1_2_2(mux_tmp_271, and_376_nl, BATCH_LOOP_stage_v_4);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      = core_wen & ((or_602_cse & or_tmp_6 & mux_622_nl) | and_dcpl_247);
  assign exit_BATCH_LOOP_lpi_2_dfm_mx0w0 = (~ BATCH_LOOP_acc_itm_32_1) & exitL_exit_STORE_LOOP_sva_mx1;
  assign STORE_LOOP_equal_tmp_1_mx0w0 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0==2'b11)
      & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0);
  assign STORE_LOOP_equal_tmp_mx0w0 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[1])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[0])));
  assign STORE_LOOP_equal_tmp_2_mx0w0 = lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 &
      (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0==2'b00);
  assign STORE_LOOP_nor_tmp_mx0w0 = ~(STORE_LOOP_STORE_LOOP_and_cse_1 | STORE_LOOP_STORE_LOOP_nor_1_cse_1
      | STORE_LOOP_equal_tmp_mx0w0 | STORE_LOOP_equal_tmp_1_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0);
  assign STORE_LOOP_or_tmp_mx0w0 = STORE_LOOP_STORE_LOOP_and_cse_1 | STORE_LOOP_STORE_LOOP_nor_1_cse_1;
  assign LOAD_LOOP_and_1_svs_mx0w0 = (LOAD_LOOP_i_7_0_sva_2[7]) & (CALC_EXP_LOOP_i_7_0_sva_2[7])
      & (SUM_EXP_LOOP_i_7_0_sva_2[7]);
  assign BATCH_LOOP_if_not_nl = ~ BATCH_LOOP_acc_itm_32_1;
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1 = MUX_v_2_2_2(2'b00, lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
      BATCH_LOOP_if_not_nl);
  assign STORE_LOOP_i_or_3_nl = exit_BATCH_LOOP_lpi_2_dfm_1 | or_23_cse;
  assign STORE_LOOP_i_mux_5_nl = MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1,
      STORE_LOOP_i_7_0_lpi_2_6_0, STORE_LOOP_i_or_3_nl);
  assign nl_STORE_LOOP_acc_1_tmp = conv_u2u_7_8(STORE_LOOP_i_mux_5_nl) + 8'b00000001;
  assign STORE_LOOP_acc_1_tmp = nl_STORE_LOOP_acc_1_tmp[7:0];
  assign exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0 = (CALC_SOFTMAX_LOOP_i_7_0_sva_2[7])
      | exit_CALC_SOFTMAX_LOOP_lpi_2;
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1 = lfst_exit_STORE_LOOP_lpi_2_2_mx1
      & (~ BATCH_LOOP_acc_itm_32_1);
  assign STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 = (BATCH_LOOP_acc_3_tmp[4])
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
  assign and_985_cse = ~(STORE_LOOP_asn_80 | or_dcpl);
  assign and_986_cse = STORE_LOOP_asn_80 & (~ or_dcpl);
  assign LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~ dma_read_ctrl_rsci_irdy_mxwt)),
      LOAD_LOOP_i_7_0_sva_1_1_6_0, LOAD_LOOP_i_7_0_lpi_2_6_0, {and_985_cse , and_986_cse
      , or_dcpl});
  assign CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), CALC_EXP_LOOP_i_7_0_sva_1_1_6_0, CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
      {and_985_cse , and_986_cse , or_dcpl});
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0
      = MUX1HOT_v_74_3_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      {STORE_LOOP_and_7_itm_2 , reg_STORE_LOOP_and_8_itm_1_cse , STORE_LOOP_or_24_itm_2});
  assign SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), SUM_EXP_LOOP_i_7_0_sva_1_1_6_0, SUM_EXP_LOOP_i_7_0_lpi_2_6_0,
      {and_985_cse , and_986_cse , or_dcpl});
  assign or_861_tmp = STORE_LOOP_nor_tmp_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0 | (exit_CALC_SOFTMAX_LOOP_lpi_2
      & STORE_LOOP_equal_tmp_1_mx0w0) | (STORE_LOOP_equal_tmp_mx0w0 & (~ LOAD_LOOP_and_1_svs_mx0w0))
      | STORE_LOOP_or_tmp_mx0w0;
  assign STORE_LOOP_and_22_tmp = (~ exit_CALC_SOFTMAX_LOOP_lpi_2) & STORE_LOOP_equal_tmp_1_mx0w0;
  assign nor_nl = ~(STORE_LOOP_and_22_tmp | or_861_tmp);
  assign CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2 = MUX1HOT_v_7_3_2((signext_7_1(~
      LOAD_LOOP_and_1_svs_mx0w0)), (CALC_SOFTMAX_LOOP_i_7_0_sva_2[6:0]), CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
      {nor_nl , STORE_LOOP_and_22_tmp , or_861_tmp});
  assign LOAD_LOOP_LOAD_LOOP_and_1_nl = exit_CALC_SOFTMAX_LOOP_lpi_2 & (~ LOAD_LOOP_and_1_svs_mx0w0);
  assign STORE_LOOP_or_19_nl = STORE_LOOP_or_tmp_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0
      | STORE_LOOP_nor_tmp_mx0w0;
  assign exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3_mx0w1 = MUX1HOT_s_1_3_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_1_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0, {STORE_LOOP_or_19_nl
      , STORE_LOOP_equal_tmp_mx0w0 , STORE_LOOP_equal_tmp_1_mx0w0});
  assign LOAD_LOOP_LOAD_LOOP_and_2_nl = exit_STORE_CTRL_LOOP_lpi_2 & (~ reg_LOAD_LOOP_and_1_svs_1_cse);
  assign STORE_LOOP_or_20_nl = STORE_LOOP_or_tmp_1 | STORE_LOOP_equal_tmp_2_1 | STORE_LOOP_nor_tmp_1;
  assign STORE_LOOP_mux1h_19_mx0w1 = MUX1HOT_s_1_3_2(exit_STORE_CTRL_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_2_nl, exit_STORE_CTRL_LOOP_lpi_2_dfm_4, {STORE_LOOP_or_20_nl
      , STORE_LOOP_equal_tmp_1 , STORE_LOOP_equal_tmp_1_1});
  assign or_528_nl = (~ dma_read_ctrl_rsci_irdy_mxwt) | STORE_LOOP_nor_tmp_1 | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_equal_tmp_1 | exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_equal_tmp_1_1
      | STORE_LOOP_asn_19_itm_1 | (~ BATCH_LOOP_and_12_tmp);
  assign dma_read_data_index_10_7_sva_mx1 = MUX_v_4_2_2(z_out, dma_read_data_index_10_7_sva,
      or_528_nl);
  assign STORE_CTRL_LOOP_mux_nl = MUX_s_1_2_2(STORE_LOOP_mux1h_19_mx0w1, exit_STORE_CTRL_LOOP_lpi_2,
      exit_BATCH_LOOP_lpi_2_dfm_1);
  assign exit_STORE_CTRL_LOOP_lpi_2_mx1 = MUX_s_1_2_2(STORE_CTRL_LOOP_mux_nl, exit_STORE_CTRL_LOOP_lpi_2,
      or_23_cse);
  assign STORE_LOOP_mux_23_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign lfst_exit_STORE_LOOP_lpi_2_2_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_23_nl, lfst_exit_STORE_LOOP_lpi_2_2,
      or_23_cse);
  assign STORE_LOOP_STORE_LOOP_nor_9_nl = ~(exit_BATCH_LOOP_lpi_2_dfm_1 | or_23_cse);
  assign STORE_LOOP_and_86_nl = exit_BATCH_LOOP_lpi_2_dfm_1 & (~ or_23_cse);
  assign lfst_exit_STORE_LOOP_lpi_2_1_0_mx1 = MUX1HOT_v_2_3_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, lfst_exit_STORE_LOOP_lpi_2_1_0, {STORE_LOOP_STORE_LOOP_nor_9_nl
      , STORE_LOOP_and_86_nl , or_23_cse});
  assign STORE_LOOP_STORE_LOOP_nor_nl = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 |
      (lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1!=2'b00));
  assign STORE_LOOP_mux_41_nl = MUX_s_1_2_2(STORE_LOOP_STORE_LOOP_nor_nl, exitL_exit_STORE_LOOP_sva,
      STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign or_566_nl = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_asn_19_itm_1 | (~ BATCH_LOOP_and_12_tmp);
  assign exitL_exit_STORE_LOOP_sva_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_41_nl, exitL_exit_STORE_LOOP_sva,
      or_566_nl);
  assign or_594_nl = (~ BATCH_LOOP_stage_v_3) | STORE_LOOP_asn_19_itm_3;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      or_594_nl);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      + conv_u2u_67_74(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[73:0];
  assign SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0, or_23_cse);
  assign CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0, or_23_cse);
  assign LOAD_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      LOAD_LOOP_i_7_0_lpi_2_6_0, or_23_cse);
  assign STORE_LOOP_and_7_itm_mx0w0 = STORE_LOOP_or_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign STORE_LOOP_or_24_itm_mx0w0 = STORE_LOOP_equal_tmp_1_1 | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_nor_tmp_1 | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1,
      94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3);
  assign nl_BATCH_LOOP_acc_3_tmp = conv_u2u_4_5(BATCH_LOOP_b_4_0_sva_3_0) + 5'b00001;
  assign BATCH_LOOP_acc_3_tmp = nl_BATCH_LOOP_acc_3_tmp[4:0];
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_2_mx1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1, mux_tmp_269);
  assign nl_BATCH_LOOP_acc_nl = ({29'b10000000000000000000000000000 , BATCH_LOOP_b_4_0_sva_3_0})
      + conv_u2u_32_33(~ batch_sva) + 33'b000000000000000000000000000000001;
  assign BATCH_LOOP_acc_nl = nl_BATCH_LOOP_acc_nl[32:0];
  assign BATCH_LOOP_acc_itm_32_1 = readslicef_33_1_32(BATCH_LOOP_acc_nl);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0 = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1, mux_tmp_269);
  assign CALC_SOFTMAX_LOOP_and_svs_1 = exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  assign STORE_LOOP_mux_63_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2, and_919_cse);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 = (STORE_LOOP_mux_63_nl & (~(STORE_LOOP_or_tmp_1
      | STORE_LOOP_and_2_ssc_1))) | STORE_LOOP_and_4_ssc_1;
  assign STORE_LOOP_and_3_cse = (~ CALC_SOFTMAX_LOOP_and_svs_1) & STORE_LOOP_equal_tmp_1_1;
  assign STORE_LOOP_and_40_nl = (~ dma_read_ctrl_rsci_irdy_mxwt) & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_and_41_nl = dma_read_ctrl_rsci_irdy_mxwt & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_or_23_nl = ((~ reg_LOAD_LOOP_and_1_svs_1_cse) & STORE_LOOP_equal_tmp_1)
      | STORE_LOOP_and_3_cse | ((~ (STORE_LOOP_i_7_0_sva_1_1[7])) & STORE_LOOP_equal_tmp_2_1)
      | STORE_LOOP_nor_tmp_1;
  assign STORE_LOOP_mux1h_45_tmp = MUX1HOT_v_2_3_2(2'b01, 2'b10, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
      {STORE_LOOP_and_40_nl , STORE_LOOP_and_41_nl , STORE_LOOP_or_23_nl});
  assign STORE_LOOP_and_nl = STORE_LOOP_mux1h_45_tmp & (signext_2_1(~ and_919_cse))
      & (signext_2_1(~ STORE_LOOP_and_4_ssc_1));
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1 = MUX_v_2_2_2(STORE_LOOP_and_nl,
      2'b11, STORE_LOOP_and_2_ssc_1);
  assign exit_STORE_CTRL_LOOP_lpi_2_dfm_4 = dma_write_ctrl_rsci_irdy_mxwt | exit_STORE_CTRL_LOOP_lpi_2;
  assign or_864_tmp = STORE_LOOP_and_3_cse | STORE_LOOP_or_tmp_1 | STORE_LOOP_equal_tmp_1
      | STORE_LOOP_nor_tmp_1;
  assign nor_267_nl = ~(STORE_LOOP_equal_tmp_2_1 | or_864_tmp);
  assign and_982_nl = STORE_LOOP_equal_tmp_2_1 & (~ or_864_tmp);
  assign STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1 = MUX1HOT_v_7_3_2((signext_7_1(~ CALC_SOFTMAX_LOOP_and_svs_1)),
      (STORE_LOOP_i_7_0_sva_1_1[6:0]), STORE_LOOP_i_7_0_lpi_2_6_0, {nor_267_nl ,
      and_982_nl , or_864_tmp});
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
  assign nl_LOAD_LOOP_i_7_0_sva_2 = conv_u2u_7_8(LOAD_LOOP_i_7_0_lpi_2_6_0_mx1) +
      8'b00000001;
  assign LOAD_LOOP_i_7_0_sva_2 = nl_LOAD_LOOP_i_7_0_sva_2[7:0];
  assign nl_CALC_EXP_LOOP_i_7_0_sva_2 = conv_u2u_7_8(CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1)
      + 8'b00000001;
  assign CALC_EXP_LOOP_i_7_0_sva_2 = nl_CALC_EXP_LOOP_i_7_0_sva_2[7:0];
  assign nl_SUM_EXP_LOOP_i_7_0_sva_2 = conv_u2u_7_8(SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1)
      + 8'b00000001;
  assign SUM_EXP_LOOP_i_7_0_sva_2 = nl_SUM_EXP_LOOP_i_7_0_sva_2[7:0];
  assign nl_CALC_SOFTMAX_LOOP_i_7_0_sva_2 = conv_u2u_7_8(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0)
      + 8'b00000001;
  assign CALC_SOFTMAX_LOOP_i_7_0_sva_2 = nl_CALC_SOFTMAX_LOOP_i_7_0_sva_2[7:0];
  assign STORE_LOOP_STORE_LOOP_and_cse_1 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[0])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0[1])));
  assign STORE_LOOP_STORE_LOOP_nor_1_cse_1 = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0!=2'b00));
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = $signed((dma_read_chnl_rsci_idat_mxwt)) * $signed(16'b0101110001010101);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl[46:0];
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28
      = readslicef_47_19_28(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl);
  assign STORE_LOOP_asn_80 = STORE_LOOP_equal_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign BATCH_LOOP_nor_13_tmp = ~((~(BATCH_LOOP_stage_v_12 & BATCH_LOOP_BATCH_LOOP_or_cse_1))
      | (BATCH_LOOP_stage_0 & (mux_378_cse | (~ BATCH_LOOP_and_13_tmp))) | BATCH_LOOP_stage_0_1
      | BATCH_LOOP_stage_0_2 | BATCH_LOOP_stage_0_3 | BATCH_LOOP_stage_0_4 | BATCH_LOOP_stage_0_5
      | BATCH_LOOP_stage_0_6 | BATCH_LOOP_stage_0_7 | BATCH_LOOP_stage_0_8 | BATCH_LOOP_stage_0_9
      | BATCH_LOOP_stage_0_10 | BATCH_LOOP_stage_0_11 | BATCH_LOOP_stage_0_12);
  assign BATCH_LOOP_and_13_tmp = BATCH_LOOP_stage_v & (~(BATCH_LOOP_stage_v_1 & (~
      BATCH_LOOP_and_12_tmp))) & BATCH_LOOP_stage_0_1 & BATCH_LOOP_BATCH_LOOP_or_21_cse_1
      & BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign STORE_LOOP_mux_28_tmp = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign BATCH_LOOP_and_12_tmp = BATCH_LOOP_stage_v_1 & (~(BATCH_LOOP_stage_v_2 &
      (not_tmp_197 | or_dcpl_57))) & BATCH_LOOP_stage_0_2 & (dma_read_ctrl_rsci_bawt
      | (~(((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]) & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])))) | (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b00))))) | exit_BATCH_LOOP_lpi_2_dfm_1)
      & (dma_read_chnl_rsci_bawt | (~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])))
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1)))) & (dma_write_ctrl_rsci_bawt | (~((~ CALC_SOFTMAX_LOOP_asn_3_itm_1)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b11) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_1)))) & BATCH_LOOP_BATCH_LOOP_or_21_cse_1 &
      BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign or_tmp_6 = (~ BATCH_LOOP_stage_v_12) | dma_write_chnl_rsci_bawt | exit_BATCH_LOOP_lpi_2_dfm_st_12
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]);
  assign or_9_cse = CALC_SOFTMAX_LOOP_asn_itm_11 | exit_BATCH_LOOP_lpi_2_dfm_st_11
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2
      | plm_out_data_rsci_bawt;
  assign and_tmp = or_9_cse & or_tmp_6;
  assign and_13_nl = BATCH_LOOP_stage_0_12 & and_tmp;
  assign mux_tmp_10 = MUX_s_1_2_2(or_tmp_6, and_13_nl, BATCH_LOOP_stage_v_11);
  assign or_tmp_21 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) | exitL_exit_STORE_LOOP_sva
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign or_tmp_22 = exitL_exit_STORE_LOOP_sva | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign or_tmp_25 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2) | STORE_LOOP_or_tmp_1;
  assign mux_42_cse = MUX_s_1_2_2(or_tmp_25, or_78_cse, and_919_cse);
  assign or_tmp_26 = STORE_LOOP_and_2_ssc_1 | mux_42_cse;
  assign nor_259_nl = ~(STORE_LOOP_and_2_ssc_1 | (or_187_cse & (~((STORE_LOOP_i_7_0_sva_1_1[7])
      & STORE_LOOP_equal_tmp_2_1)) & or_tmp_25));
  assign or_31_nl = exitL_exit_STORE_LOOP_sva | (~ or_tmp_26);
  assign mux_43_nl = MUX_s_1_2_2(nor_259_nl, or_31_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_tmp_27 = MUX_s_1_2_2(mux_43_nl, or_tmp_22, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_tmp_29 = MUX_s_1_2_2(mux_tmp_27, or_tmp_21, STORE_LOOP_equal_tmp_1_1);
  assign mux_47_itm = MUX_s_1_2_2(mux_tmp_27, or_tmp_21, and_950_cse);
  assign mux_666_nl = MUX_s_1_2_2(mux_47_itm, mux_tmp_29, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_49_nl = MUX_s_1_2_2(mux_666_nl, mux_tmp_29, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_50_nl = MUX_s_1_2_2(mux_tmp_27, mux_49_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_51_nl = MUX_s_1_2_2(mux_tmp_29, mux_50_nl, nor_233_cse);
  assign mux_52_cse = MUX_s_1_2_2(mux_51_nl, or_tmp_22, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign and_952_cse = STORE_LOOP_STORE_LOOP_and_10_itm_1 & exitL_exit_STORE_LOOP_sva;
  assign or_43_nl = and_952_cse | or_tmp_26;
  assign mux_tmp_40 = MUX_s_1_2_2(or_43_nl, or_42_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign not_tmp_36 = ~(BATCH_LOOP_stage_0_10 & BATCH_LOOP_stage_v_9);
  assign or_74_cse = (~ BATCH_LOOP_stage_v_11) | CALC_SOFTMAX_LOOP_asn_itm_11 | exit_BATCH_LOOP_lpi_2_dfm_st_11
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2
      | plm_out_data_rsci_bawt;
  assign and_tmp_8 = or_74_cse & or_tmp_6;
  assign and_967_cse = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_0_9;
  assign and_944_cse = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_0_8;
  assign nor_235_cse = ~(BATCH_LOOP_stage_v_11 | (~ or_tmp_6));
  assign and_tmp_21 = ((~ BATCH_LOOP_stage_v_10) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 | CALC_SOFTMAX_LOOP_asn_itm_10 |
      exit_BATCH_LOOP_lpi_2_dfm_st_10 | CALC_SOFTMAX_LOOP_mul_cmp_bawt) & and_tmp_8;
  assign and_964_cse = BATCH_LOOP_stage_v_6 & BATCH_LOOP_stage_0_7;
  assign and_961_cse = BATCH_LOOP_stage_v_5 & BATCH_LOOP_stage_0_6;
  assign or_dcpl_9 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b00)
      | exit_BATCH_LOOP_lpi_2_dfm_st_11 | (~ BATCH_LOOP_stage_0_12) | (~ BATCH_LOOP_stage_v_11);
  assign and_dcpl_27 = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0])) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]));
  assign or_tmp_150 = (~ reg_LOAD_LOOP_and_1_svs_1_cse) | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_or_tmp_1 | STORE_LOOP_nor_tmp_1;
  assign nor_224_cse = ~((STORE_LOOP_mux1h_45_tmp!=2'b00));
  assign or_165_nl = nor_224_cse | STORE_LOOP_equal_tmp_2_1 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | STORE_LOOP_or_tmp_1 | STORE_LOOP_nor_tmp_1;
  assign mux_161_nl = MUX_s_1_2_2(or_165_nl, or_tmp_150, STORE_LOOP_equal_tmp_1);
  assign or_162_nl = STORE_LOOP_equal_tmp_2_1 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | STORE_LOOP_or_tmp_1 | STORE_LOOP_nor_tmp_1;
  assign mux_160_nl = MUX_s_1_2_2(or_162_nl, or_tmp_150, STORE_LOOP_equal_tmp_1);
  assign or_163_nl = exitL_exit_STORE_LOOP_sva | mux_160_nl;
  assign mux_162_nl = MUX_s_1_2_2(mux_161_nl, or_163_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign or_175_cse = STORE_LOOP_equal_tmp_1_1 | exit_BATCH_LOOP_lpi_2_dfm_1 | mux_162_nl;
  assign mux_170_nl = MUX_s_1_2_2(mux_tmp_29, or_175_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_48_nl = MUX_s_1_2_2(mux_47_itm, mux_tmp_29, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_169_nl = MUX_s_1_2_2(mux_48_nl, or_175_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_171_nl = MUX_s_1_2_2(mux_170_nl, mux_169_nl, nor_233_cse);
  assign or_856_nl = or_tmp_22 | exit_STORE_CTRL_LOOP_lpi_2;
  assign mux_172_nl = MUX_s_1_2_2(mux_171_nl, or_856_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nand_33_nl = ~((STORE_LOOP_mux_28_tmp==2'b11) & (~ mux_172_nl));
  assign or_150_nl = exit_STORE_CTRL_LOOP_lpi_2 | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[0]))
      | lfst_exit_STORE_LOOP_lpi_2_2 | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[1])) |
      exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_156 = MUX_s_1_2_2(nand_33_nl, or_150_nl, or_23_cse);
  assign mux_175_nl = MUX_s_1_2_2(and_950_cse, STORE_LOOP_equal_tmp_1_1, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_176_nl = MUX_s_1_2_2(mux_175_nl, STORE_LOOP_equal_tmp_1_1, exit_STORE_CTRL_LOOP_lpi_2);
  assign and_81_nl = exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & mux_176_nl;
  assign or_178_nl = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  assign mux_tmp_160 = MUX_s_1_2_2(and_81_nl, STORE_LOOP_equal_tmp_1_1, or_178_nl);
  assign nand_tmp_34 = ~(or_78_cse & (~ mux_tmp_160));
  assign or_tmp_168 = nor_263_cse | mux_tmp_160;
  assign mux_tmp_161 = MUX_s_1_2_2(or_tmp_168, nand_tmp_34, and_919_cse);
  assign mux_tmp_163 = MUX_s_1_2_2(mux_tmp_161, mux_tmp_160, STORE_LOOP_and_2_ssc_1);
  assign and_dcpl_29 = BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4;
  assign and_dcpl_32 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[1]);
  assign or_tmp_181 = BATCH_LOOP_stage_v_11 | (~ or_tmp_6);
  assign mux_tmp_175 = MUX_s_1_2_2((~ or_tmp_181), or_tmp_6, or_9_cse);
  assign or_tmp_182 = BATCH_LOOP_stage_v_10 | (~ mux_tmp_175);
  assign mux_tmp_176 = MUX_s_1_2_2((~ or_tmp_182), mux_tmp_175, or_434_cse);
  assign and_dcpl_47 = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3;
  assign mux_tmp_198 = MUX_s_1_2_2(mux_tmp_176, and_353_cse, BATCH_LOOP_stage_v_4);
  assign and_dcpl_84 = and_dcpl_27 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_12) & dma_write_chnl_rsci_bawt
      & BATCH_LOOP_stage_v_12;
  assign and_dcpl_87 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp;
  assign and_dcpl_90 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])) & and_dcpl_87;
  assign or_tmp_201 = ~(STORE_LOOP_equal_tmp_1 & reg_LOAD_LOOP_and_1_svs_1_cse &
      (STORE_LOOP_mux_28_tmp==2'b10));
  assign or_dcpl_17 = ~(BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3);
  assign or_dcpl_24 = or_dcpl_17 | exit_BATCH_LOOP_lpi_2_dfm_st_3 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
  assign and_tmp_66 = or_434_cse & mux_tmp_10;
  assign or_tmp_238 = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_STORE_LOOP_and_10_itm_1;
  assign nor_tmp_90 = or_tmp_238 & exitL_exit_STORE_LOOP_sva;
  assign and_179_nl = STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7]) &
      or_78_cse;
  assign mux_276_nl = MUX_s_1_2_2(mux_42_cse, and_179_nl, or_187_cse);
  assign nor_219_nl = ~(STORE_LOOP_and_2_ssc_1 | (~ mux_276_nl));
  assign mux_tmp_260 = MUX_s_1_2_2(nor_219_nl, exitL_exit_STORE_LOOP_sva, or_tmp_238);
  assign mux_tmp_262 = MUX_s_1_2_2(mux_tmp_260, nor_tmp_90, STORE_LOOP_equal_tmp_1_1);
  assign mux_280_nl = MUX_s_1_2_2(mux_tmp_260, nor_tmp_90, and_950_cse);
  assign mux_281_nl = MUX_s_1_2_2(mux_280_nl, mux_tmp_262, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_282_nl = MUX_s_1_2_2(mux_281_nl, mux_tmp_262, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_283_nl = MUX_s_1_2_2(mux_tmp_260, mux_282_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_284_nl = MUX_s_1_2_2(mux_tmp_262, mux_283_nl, nor_233_cse);
  assign mux_285_nl = MUX_s_1_2_2(mux_284_nl, exitL_exit_STORE_LOOP_sva, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_tmp_269 = MUX_s_1_2_2(mux_285_nl, exitL_exit_STORE_LOOP_sva, or_23_cse);
  assign nand_43_nl = ~((STORE_LOOP_mux_28_tmp==2'b11) & (~ mux_52_cse));
  assign or_298_nl = (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[0])) | lfst_exit_STORE_LOOP_lpi_2_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_1_0[1])) | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_270 = MUX_s_1_2_2(nand_43_nl, or_298_nl, or_23_cse);
  assign or_dcpl_57 = ~(BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2);
  assign or_tmp_250 = BATCH_LOOP_stage_v_10 | (~ or_74_cse);
  assign mux_tmp_271 = MUX_s_1_2_2((~ or_tmp_250), or_74_cse, or_434_cse);
  assign not_tmp_196 = ~(BATCH_LOOP_stage_v_3 | (~ mux_tmp_271));
  assign mux_305_nl = MUX_s_1_2_2(not_tmp_196, mux_tmp_271, BATCH_LOOP_stage_0_4);
  assign mux_293_nl = MUX_s_1_2_2(mux_tmp_271, mux_311_cse, BATCH_LOOP_stage_v_3);
  assign mux_294_nl = MUX_s_1_2_2(not_tmp_196, mux_293_nl, BATCH_LOOP_stage_0_10);
  assign mux_295_nl = MUX_s_1_2_2(mux_tmp_271, mux_294_nl, BATCH_LOOP_stage_v_9);
  assign mux_296_nl = MUX_s_1_2_2(not_tmp_196, mux_295_nl, BATCH_LOOP_stage_0_9);
  assign mux_297_nl = MUX_s_1_2_2(mux_tmp_271, mux_296_nl, BATCH_LOOP_stage_v_8);
  assign mux_298_nl = MUX_s_1_2_2(not_tmp_196, mux_297_nl, BATCH_LOOP_stage_0_8);
  assign mux_299_nl = MUX_s_1_2_2(mux_tmp_271, mux_298_nl, BATCH_LOOP_stage_v_7);
  assign mux_300_nl = MUX_s_1_2_2(not_tmp_196, mux_299_nl, BATCH_LOOP_stage_0_7);
  assign mux_301_nl = MUX_s_1_2_2(mux_tmp_271, mux_300_nl, BATCH_LOOP_stage_v_6);
  assign mux_302_nl = MUX_s_1_2_2(not_tmp_196, mux_301_nl, BATCH_LOOP_stage_0_6);
  assign mux_303_nl = MUX_s_1_2_2(mux_tmp_271, mux_302_nl, BATCH_LOOP_stage_v_5);
  assign and_973_nl = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_0_5;
  assign mux_304_nl = MUX_s_1_2_2(not_tmp_196, mux_303_nl, and_973_nl);
  assign and_188_nl = or_843_cse & mux_304_nl;
  assign mux_306_cse = MUX_s_1_2_2(mux_305_nl, and_188_nl, BATCH_LOOP_stage_v_4);
  assign not_tmp_197 = ~(or_tmp_6 & mux_306_cse);
  assign or_dcpl_71 = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2);
  assign or_dcpl_75 = ~(BATCH_LOOP_stage_0_6 & BATCH_LOOP_stage_v_5);
  assign or_354_cse = (~ exitL_exit_STORE_LOOP_sva) | BATCH_LOOP_acc_itm_32_1;
  assign and_tmp_88 = STORE_LOOP_equal_tmp_1_1 & exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1
      & exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  assign nand_tmp_44 = ~(or_78_cse & (~ and_tmp_88));
  assign or_tmp_282 = nor_263_cse | and_tmp_88;
  assign or_360_nl = (STORE_LOOP_mux1h_45_tmp!=2'b00) | or_tmp_282;
  assign mux_341_nl = MUX_s_1_2_2(or_360_nl, nand_tmp_44, and_919_cse);
  assign or_362_cse = BATCH_LOOP_acc_itm_32_1 | STORE_LOOP_and_2_ssc_1 | mux_341_nl;
  assign mux_345_nl = MUX_s_1_2_2(or_tmp_282, nand_tmp_44, and_919_cse);
  assign mux_346_cse = MUX_s_1_2_2(mux_345_nl, and_tmp_88, STORE_LOOP_and_2_ssc_1);
  assign or_369_cse = (lfst_exit_STORE_LOOP_lpi_2_1_0[0]) | (~ lfst_exit_STORE_LOOP_lpi_2_2)
      | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]);
  assign and_933_cse = (STORE_LOOP_acc_1_tmp[7]) & (BATCH_LOOP_acc_3_tmp[4]);
  assign or_367_nl = (~ BATCH_LOOP_and_12_tmp) | STORE_LOOP_asn_19_itm_1 | exit_BATCH_LOOP_lpi_2_dfm_1
      | STORE_LOOP_STORE_LOOP_and_10_itm_1;
  assign mux_377_cse = MUX_s_1_2_2(or_362_cse, or_354_cse, or_367_nl);
  assign or_384_nl = and_919_cse | nor_224_cse | or_tmp_282;
  assign mux_371_nl = MUX_s_1_2_2(or_384_nl, and_tmp_88, and_920_cse);
  assign mux_372_nl = MUX_s_1_2_2(mux_371_nl, mux_346_cse, BATCH_LOOP_acc_itm_32_1);
  assign mux_369_nl = MUX_s_1_2_2((~ mux_346_cse), BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_373_nl = MUX_s_1_2_2((~ mux_372_nl), mux_369_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign mux_365_nl = MUX_s_1_2_2((~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2), BATCH_LOOP_acc_itm_32_1,
      exitL_exit_STORE_LOOP_sva);
  assign mux_374_nl = MUX_s_1_2_2(mux_373_nl, mux_365_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_364_nl = MUX_s_1_2_2(or_362_cse, or_354_cse, or_tmp_238);
  assign or_371_nl = (STORE_LOOP_mux_28_tmp!=2'b00);
  assign mux_375_cse = MUX_s_1_2_2(mux_374_nl, mux_364_nl, or_371_nl);
  assign and_932_nl = exitL_exit_STORE_LOOP_sva & BATCH_LOOP_acc_itm_32_1;
  assign mux_359_nl = MUX_s_1_2_2(and_932_nl, or_354_cse, or_369_cse);
  assign mux_376_nl = MUX_s_1_2_2(mux_375_cse, mux_359_nl, or_23_cse);
  assign mux_378_cse = MUX_s_1_2_2(mux_377_cse, mux_376_nl, and_933_cse);
  assign and_dcpl_126 = BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2;
  assign and_tmp_92 = or_tmp_6 & mux_306_cse;
  assign and_dcpl_132 = and_tmp_92 & and_dcpl_126;
  assign and_243_cse = and_dcpl_126 & mux_tmp_176;
  assign and_tmp_103 = ((~ BATCH_LOOP_stage_v_4) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0]) | exit_BATCH_LOOP_lpi_2_dfm_st_4
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2)
      & and_tmp_21;
  assign or_tmp_363 = (~ BATCH_LOOP_stage_0_10) | BATCH_LOOP_stage_v_10;
  assign mux_462_cse = MUX_s_1_2_2(mux_tmp_175, and_304_cse, BATCH_LOOP_stage_v_8);
  assign nand_48_nl = ~(BATCH_LOOP_stage_0_9 & nor_207_cse);
  assign mux_464_nl = MUX_s_1_2_2(or_tmp_182, nand_48_nl, BATCH_LOOP_stage_v_8);
  assign nand_49_nl = ~(BATCH_LOOP_stage_0_8 & (~ mux_464_nl));
  assign mux_465_nl = MUX_s_1_2_2(or_tmp_182, nand_49_nl, BATCH_LOOP_stage_v_7);
  assign and_281_nl = BATCH_LOOP_stage_0_8 & mux_462_cse;
  assign mux_463_nl = MUX_s_1_2_2(mux_tmp_175, and_281_nl, BATCH_LOOP_stage_v_7);
  assign mux_tmp_449 = MUX_s_1_2_2((~ mux_465_nl), mux_463_nl, or_434_cse);
  assign nor_211_nl = ~(BATCH_LOOP_stage_v_10 | (~ mux_tmp_175));
  assign mux_483_nl = MUX_s_1_2_2(nor_211_nl, and_928_cse, BATCH_LOOP_stage_v_8);
  assign mux_tmp_467 = MUX_s_1_2_2(mux_483_nl, mux_462_cse, or_434_cse);
  assign mux_tmp_482 = MUX_s_1_2_2(nor_207_cse, mux_504_cse, or_434_cse);
  assign and_tmp_145 = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_0_8 & mux_tmp_175;
  assign or_tmp_419 = or_tmp_363 | (~ mux_tmp_175);
  assign and_tmp_148 = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_0_9 & mux_tmp_175;
  assign and_dcpl_155 = BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign and_dcpl_159 = BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11;
  assign or_tmp_431 = dma_write_chnl_rsci_bawt | exit_BATCH_LOOP_lpi_2_dfm_st_12
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]);
  assign or_602_cse = (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign mux_646_nl = MUX_s_1_2_2(mux_tmp_176, and_464_cse, BATCH_LOOP_stage_v_4);
  assign and_dcpl_247 = mux_646_nl & (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1==74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign or_tmp_526 = or_tmp_6 & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b00)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_11) & BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11
      & (fsm_output[2]);
  assign or_tmp_529 = or_dcpl_9 & and_dcpl_84 & (fsm_output[2]);
  assign mux_667_nl = MUX_s_1_2_2(or_86_cse, or_tmp_201, nor_263_cse);
  assign mux_227_nl = MUX_s_1_2_2(mux_667_nl, or_tmp_201, and_919_cse);
  assign mux_228_nl = MUX_s_1_2_2(or_tmp_201, mux_227_nl, or_187_cse);
  assign mux_665_nl = MUX_s_1_2_2(or_86_cse, or_tmp_201, nor_263_cse);
  assign mux_224_nl = MUX_s_1_2_2(or_tmp_201, or_86_cse, or_78_cse);
  assign mux_226_nl = MUX_s_1_2_2(mux_665_nl, mux_224_nl, and_919_cse);
  assign or_215_nl = exitL_exit_STORE_LOOP_sva | mux_226_nl;
  assign mux_229_nl = MUX_s_1_2_2(mux_228_nl, or_215_nl, STORE_LOOP_STORE_LOOP_and_10_itm_1);
  assign nor_229_nl = ~(STORE_LOOP_equal_tmp_1_1 | mux_229_nl);
  assign nor_230_nl = ~(exitL_exit_STORE_LOOP_sva | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0!=2'b10));
  assign mux_230_nl = MUX_s_1_2_2(nor_229_nl, nor_230_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_231_nl = MUX_s_1_2_2(mux_230_nl, nor_272_cse, STORE_LOOP_asn_19_itm_1);
  assign or_tmp_536 = (~(mux_231_nl & BATCH_LOOP_and_13_tmp)) & and_dcpl_90 & (fsm_output[2]);
  assign or_tmp_547 = (~ (fsm_output[2])) | (~ mux_tmp_198) | or_dcpl_17 | exit_BATCH_LOOP_lpi_2_dfm_st_3
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0!=2'b10);
  assign or_tmp_550 = ~((fsm_output[2]) & mux_tmp_10 & BATCH_LOOP_stage_0_11 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10) & (~ CALC_SOFTMAX_LOOP_asn_itm_10) &
      (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11)
      & BATCH_LOOP_stage_v_10);
  assign or_tmp_576 = (~ mux_tmp_269) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_580 = mux_tmp_270 & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_587 = mux_tmp_269 & (~ BATCH_LOOP_acc_itm_32_1) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign or_tmp_615 = (mux_tmp_270 | exit_CALC_SOFTMAX_LOOP_lpi_2) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign or_tmp_629 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  assign or_tmp_676 = (~ mux_378_cse) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_681 = mux_378_cse & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1
      = mux_445_cse & and_961_cse & (~ STORE_LOOP_and_10_itm_3) & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_mx0c1 = (~(mux_378_cse & BATCH_LOOP_stage_0)) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_2_mx0c0 = (fsm_output[1]) | (and_tmp_92 & and_dcpl_126
      & (~ BATCH_LOOP_and_12_tmp) & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_3_mx0c0 = (fsm_output[1]) | (mux_tmp_198 & and_dcpl_47
      & or_dcpl_57 & (fsm_output[2]));
  assign BATCH_LOOP_stage_v_4_mx0c0 = (fsm_output[1]) | (and_464_cse & and_dcpl_29
      & or_dcpl_17 & (fsm_output[2]));
  assign STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1 = (~ STORE_LOOP_asn_19_itm_1) & BATCH_LOOP_and_12_tmp
      & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1
      = mux_tmp_198 & and_dcpl_47 & (~ STORE_LOOP_asn_19_itm_3) & (fsm_output[2]);
  assign CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1 = (exit_BATCH_LOOP_lpi_2_dfm_1
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & BATCH_LOOP_and_12_tmp;
  assign STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1 = (or_dcpl_71 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
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
      | STORE_LOOP_or_24_itm_mx0w0;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | (and_dcpl_27 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_12)
        & (~ dma_write_chnl_rsci_bawt) & BATCH_LOOP_stage_v_12) | or_dcpl_9)) ) begin
      dma_write_chnl_rsci_idat_31_0 <= plm_out_data_rsci_q_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_idat_10_7 <= 4'b0000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_tmp_156 | (~ BATCH_LOOP_and_13_tmp)))
        ) begin
      dma_write_ctrl_rsci_idat_10_7 <= dma_write_data_index_10_7_sva;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_idat_10_7 <= 4'b0000;
    end
    else if ( core_wen & (fsm_output[2]) & mux_191_cse & BATCH_LOOP_and_13_tmp )
        begin
      dma_read_ctrl_rsci_idat_10_7 <= dma_read_data_index_10_7_sva_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse <= 1'b0;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= 1'b0;
      reg_debug_rsc_triosy_obj_ld_core_psct_cse <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse
          <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse
          <= 1'b0;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= 1'b0;
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
      BATCH_LOOP_stage_v_5 <= 1'b0;
      BATCH_LOOP_stage_v_6 <= 1'b0;
      BATCH_LOOP_stage_v_7 <= 1'b0;
      BATCH_LOOP_stage_v_8 <= 1'b0;
      BATCH_LOOP_stage_v_9 <= 1'b0;
      BATCH_LOOP_stage_v_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9 <= 7'b0000000;
      BATCH_LOOP_stage_v_11 <= 1'b0;
      BATCH_LOOP_stage_v_12 <= 1'b0;
      dma_read_data_index_10_7_sva <= 4'b0000;
      dma_write_data_index_10_7_sva <= 4'b0000;
      exit_STORE_CTRL_LOOP_lpi_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= 2'b00;
      exitL_exit_STORE_LOOP_sva <= 1'b0;
      BATCH_LOOP_stage_v_1 <= 1'b0;
      BATCH_LOOP_stage_0_2 <= 1'b0;
      BATCH_LOOP_stage_0_7 <= 1'b0;
      BATCH_LOOP_stage_0_8 <= 1'b0;
      BATCH_LOOP_stage_0_9 <= 1'b0;
      BATCH_LOOP_stage_0_10 <= 1'b0;
      BATCH_LOOP_stage_0_11 <= 1'b0;
      BATCH_LOOP_stage_0_12 <= 1'b0;
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      LOAD_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( core_wen ) begin
      reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse <= and_481_rmff;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= and_483_rmff;
      reg_debug_rsc_triosy_obj_ld_core_psct_cse <= BATCH_LOOP_nor_13_tmp & (fsm_output[2]);
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse
          <= and_487_rmff;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse
          <= and_489_rmff;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= and_493_rmff;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= (~ mux_tmp_156) & BATCH_LOOP_and_13_tmp
          & (fsm_output[2]);
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= mux_191_cse & BATCH_LOOP_and_13_tmp
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
      BATCH_LOOP_stage_v_5 <= ((BATCH_LOOP_stage_v_5 & (~((~(or_843_cse & BATCH_LOOP_stage_v_4
          & BATCH_LOOP_stage_0_5)) & mux_445_cse & and_961_cse))) | (and_464_cse
          & and_dcpl_29)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_6 <= ((BATCH_LOOP_stage_v_6 & (~(mux_tmp_449 & and_964_cse
          & or_dcpl_75))) | (mux_445_cse & and_961_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_7 <= ((BATCH_LOOP_stage_v_7 & (~(mux_tmp_467 & and_944_cse
          & (~(BATCH_LOOP_stage_0_7 & BATCH_LOOP_stage_v_6))))) | (mux_tmp_449 &
          and_964_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_8 <= ((BATCH_LOOP_stage_v_8 & (~(mux_tmp_482 & and_967_cse
          & (~(BATCH_LOOP_stage_0_8 & BATCH_LOOP_stage_v_7))))) | (mux_tmp_467 &
          and_944_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_9 <= ((BATCH_LOOP_stage_v_9 & (~(mux_273_cse & and_959_cse
          & (~(BATCH_LOOP_stage_0_9 & BATCH_LOOP_stage_v_8))))) | (mux_tmp_482 &
          and_967_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_10 <= ((BATCH_LOOP_stage_v_10 & (~(and_tmp_66 & and_dcpl_155
          & not_tmp_36))) | (mux_273_cse & and_959_cse)) & (fsm_output[2]);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9, and_tmp_21);
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9 <= MUX_v_7_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9,
          STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_8, and_tmp_8);
      BATCH_LOOP_stage_v_11 <= ((BATCH_LOOP_stage_v_11 & (~(mux_521_nl & and_dcpl_159)))
          | (and_tmp_66 & and_dcpl_155)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_12 <= ((BATCH_LOOP_stage_v_12 & (~ mux_523_nl)) | (and_tmp
          & and_dcpl_159)) & (fsm_output[2]);
      dma_read_data_index_10_7_sva <= MUX_v_4_2_2(4'b0000, dma_read_data_index_10_7_sva_mx1,
          (fsm_output[2]));
      dma_write_data_index_10_7_sva <= MUX_v_4_2_2(4'b0000, STORE_LOOP_mux_36_nl,
          (fsm_output[2]));
      exit_STORE_CTRL_LOOP_lpi_2 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_dfm_3,
          exit_STORE_CTRL_LOOP_lpi_2_mx1, fsm_output[2]);
      lfst_exit_STORE_LOOP_lpi_2_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_8_2,
          lfst_exit_STORE_LOOP_lpi_2_2_mx1, fsm_output[2]);
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0,
          lfst_exit_STORE_LOOP_lpi_2_1_0_mx1, fsm_output[2]);
      exitL_exit_STORE_LOOP_sva <= exitL_exit_STORE_LOOP_sva_mx1 | (~ (fsm_output[2]));
      BATCH_LOOP_stage_v_1 <= ((BATCH_LOOP_stage_v_1 & (~ BATCH_LOOP_and_12_tmp))
          | BATCH_LOOP_and_13_tmp) & (fsm_output[2]);
      BATCH_LOOP_stage_0_2 <= BATCH_LOOP_mux_10_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_7 <= BATCH_LOOP_mux_11_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_8 <= BATCH_LOOP_mux_12_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_9 <= BATCH_LOOP_mux_13_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_10 <= BATCH_LOOP_mux_14_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_11 <= BATCH_LOOP_mux_15_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_12 <= BATCH_LOOP_mux_16_nl & (fsm_output[2]);
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1, fsm_output[2]);
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1, fsm_output[2]);
      LOAD_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0, LOAD_LOOP_i_7_0_lpi_2_6_0_mx1,
          fsm_output[2]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (or_tmp_526 | or_tmp_529) ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= ~ or_tmp_529;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((mux_223_nl & BATCH_LOOP_and_13_tmp & (fsm_output[2]))
        | or_tmp_536) ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= ~ or_tmp_536;
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
    else if ( STORE_LOOP_and_46_cse ) begin
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
    else if ( STORE_LOOP_and_52_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_12 <= exit_BATCH_LOOP_lpi_2_dfm_st_11;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_BATCH_LOOP_lpi_2_dfm_1 <= 1'b0;
      STORE_LOOP_equal_tmp_1_1 <= 1'b0;
      STORE_LOOP_equal_tmp_1 <= 1'b0;
      STORE_LOOP_equal_tmp_2_1 <= 1'b0;
      STORE_LOOP_nor_tmp_1 <= 1'b0;
      STORE_LOOP_or_tmp_1 <= 1'b0;
      reg_LOAD_LOOP_and_1_svs_1_cse <= 1'b0;
      STORE_LOOP_i_7_0_sva_1_1 <= 8'b00000000;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= 1'b0;
      STORE_LOOP_STORE_LOOP_and_10_itm_1 <= 1'b0;
      STORE_LOOP_asn_19_itm_1 <= 1'b0;
      SUM_EXP_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
    end
    else if ( BATCH_LOOP_and_17_cse ) begin
      exit_BATCH_LOOP_lpi_2_dfm_1 <= exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
      STORE_LOOP_equal_tmp_1_1 <= STORE_LOOP_equal_tmp_1_mx0w0;
      STORE_LOOP_equal_tmp_1 <= STORE_LOOP_equal_tmp_mx0w0;
      STORE_LOOP_equal_tmp_2_1 <= STORE_LOOP_equal_tmp_2_mx0w0;
      STORE_LOOP_nor_tmp_1 <= STORE_LOOP_nor_tmp_mx0w0;
      STORE_LOOP_or_tmp_1 <= STORE_LOOP_or_tmp_mx0w0;
      reg_LOAD_LOOP_and_1_svs_1_cse <= LOAD_LOOP_and_1_svs_mx0w0;
      STORE_LOOP_i_7_0_sva_1_1 <= STORE_LOOP_acc_1_tmp;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 <= exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx1w0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= BATCH_LOOP_acc_3_tmp[4];
      STORE_LOOP_STORE_LOOP_and_10_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
      STORE_LOOP_asn_19_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 |
          exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
      SUM_EXP_LOOP_i_7_0_sva_1_1_6_0 <= SUM_EXP_LOOP_i_7_0_sva_2[6:0];
      CALC_EXP_LOOP_i_7_0_sva_1_1_6_0 <= CALC_EXP_LOOP_i_7_0_sva_2[6:0];
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= LOAD_LOOP_i_7_0_sva_2[6:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= 2'b00;
    end
    else if ( core_wen & (~((fsm_output[1]) | (fsm_output[3]) | ((~ BATCH_LOOP_and_13_tmp)
        & (fsm_output[2])))) ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1,
          lfst_exit_STORE_LOOP_lpi_2_1_0_mx1, or_tmp_576);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_23_cse ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm_1 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_mx1,
          CALC_SOFTMAX_LOOP_asn_3_itm, or_tmp_580);
      CALC_SOFTMAX_LOOP_asn_itm_1 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2, CALC_SOFTMAX_LOOP_asn_itm,
          or_tmp_580);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= 1'b0;
    end
    else if ( core_wen & ((mux_tmp_269 & BATCH_LOOP_and_13_tmp & (fsm_output[2]))
        | or_tmp_576) ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1,
          lfst_exit_STORE_LOOP_lpi_2_2_mx1, or_tmp_576);
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
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2, or_tmp_587);
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0, or_tmp_587);
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
          CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2, and_616_cse);
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
          exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3_mx0w1, and_616_cse);
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
    else if ( core_wen & (~((~ (fsm_output[2])) | (~ BATCH_LOOP_and_12_tmp) | exit_BATCH_LOOP_lpi_2_dfm_1
        | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
        | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])))) ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm <= CALC_EXP_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse <= 7'b0000000;
    end
    else if ( core_wen & (((~ mux_tmp_270) & BATCH_LOOP_and_13_tmp & (~ exit_CALC_SOFTMAX_LOOP_lpi_2)
        & (fsm_output[2])) | or_tmp_615) ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm, or_tmp_615);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= 1'b0;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | not_tmp_197 | or_dcpl_57 | exit_BATCH_LOOP_lpi_2_dfm_st_2
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
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_tmp_270 | (~ BATCH_LOOP_and_13_tmp)
        | exit_CALC_SOFTMAX_LOOP_lpi_2)) ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm <= CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm <= 7'b0000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | or_dcpl_71 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
        | exit_BATCH_LOOP_lpi_2_dfm_1 | (~ BATCH_LOOP_and_12_tmp))) ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm <= STORE_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0 <= 2'b00;
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= 1'b0;
      STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
    end
    else if ( STORE_LOOP_and_64_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1, or_tmp_629);
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1, or_tmp_629);
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2,
          STORE_LOOP_mux1h_19_mx0w1, or_tmp_629);
      STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_6_0,
          STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1, or_tmp_629);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
    end
    else if ( LOAD_LOOP_i_and_cse ) begin
      LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_445_cse & and_961_cse & STORE_LOOP_and_10_itm_3 &
        (fsm_output[2])) | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1)
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_1_itm,
          STORE_LOOP_and_88_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_358_nl & BATCH_LOOP_stage_0 & (fsm_output[2]))
        | BATCH_LOOP_stage_v_mx0c1) ) begin
      BATCH_LOOP_stage_v <= ~ BATCH_LOOP_stage_v_mx0c1;
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
      STORE_LOOP_asn_19_itm_2 <= 1'b0;
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
      STORE_LOOP_or_24_itm_1 <= 1'b0;
      exit_LOAD_CTRL_LOOP_sva_1 <= 1'b0;
      STORE_LOOP_equal_tmp_2 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_2_cse ) begin
      LOAD_LOOP_and_1_svs_st_2 <= reg_LOAD_LOOP_and_1_svs_1_cse;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_2 <= exit_BATCH_LOOP_lpi_2_dfm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2 <= reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse;
      CALC_SOFTMAX_LOOP_asn_itm_2 <= CALC_SOFTMAX_LOOP_asn_itm_1;
      STORE_LOOP_asn_19_itm_2 <= STORE_LOOP_asn_19_itm_1;
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
      STORE_LOOP_or_24_itm_1 <= STORE_LOOP_or_24_itm_mx0w0;
      exit_LOAD_CTRL_LOOP_sva_1 <= dma_read_ctrl_rsci_irdy_mxwt;
      STORE_LOOP_equal_tmp_2 <= STORE_LOOP_equal_tmp_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_3_mx0c0 | (and_dcpl_132 & (fsm_output[2])))
        ) begin
      BATCH_LOOP_stage_v_3 <= ~ BATCH_LOOP_stage_v_3_mx0c0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~ not_tmp_197) ) begin
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
      STORE_LOOP_asn_19_itm_3 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      LOAD_LOOP_and_1_svs_4 <= 1'b0;
      STORE_LOOP_and_10_itm_2 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      STORE_LOOP_and_7_itm_2 <= 1'b0;
      reg_STORE_LOOP_and_8_itm_1_cse <= 1'b0;
      STORE_LOOP_or_24_itm_2 <= 1'b0;
      STORE_LOOP_asn_19_itm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3 <= 7'b0000000;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2 <= 7'b0000000;
    end
    else if ( LOAD_LOOP_and_3_cse ) begin
      LOAD_LOOP_and_1_svs_st_3 <= LOAD_LOOP_and_1_svs_st_2;
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1 <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2;
      CALC_SOFTMAX_LOOP_asn_itm_3 <= CALC_SOFTMAX_LOOP_asn_itm_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0;
      STORE_LOOP_asn_19_itm_3 <= STORE_LOOP_asn_19_itm_2;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= exit_BATCH_LOOP_lpi_2_dfm_st_2;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= CALC_SOFTMAX_LOOP_asn_itm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      LOAD_LOOP_and_1_svs_4 <= LOAD_LOOP_and_1_svs_st_3;
      STORE_LOOP_and_10_itm_2 <= reg_STORE_LOOP_and_8_itm_1_cse;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1
          <= MUX_v_74_2_2(74'b00000000000000000000000000000000000000000000000000000000000000000000000000,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1,
          LOAD_CTRL_LOOP_not_6_nl);
      STORE_LOOP_and_7_itm_2 <= STORE_LOOP_and_7_itm_1;
      reg_STORE_LOOP_and_8_itm_1_cse <= STORE_LOOP_equal_tmp_2 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_2);
      STORE_LOOP_or_24_itm_2 <= STORE_LOOP_or_24_itm_1;
      STORE_LOOP_asn_19_itm_4 <= STORE_LOOP_asn_19_itm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= MUX_s_1_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm,
          and_469_nl);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & (BATCH_LOOP_stage_v_4_mx0c0 | (mux_tmp_198 & and_dcpl_47
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_v_4 <= ~ BATCH_LOOP_stage_v_4_mx0c0;
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
      STORE_LOOP_asn_19_itm_5 <= 1'b0;
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
      STORE_LOOP_asn_19_itm_5 <= STORE_LOOP_asn_19_itm_4;
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
    else if ( core_wen & ((fsm_output[1]) | or_tmp_676) ) begin
      BATCH_LOOP_stage_0 <= ~ or_tmp_676;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( CALC_SOFTMAX_LOOP_and_30_cse ) begin
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3,
          exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3_mx0w1, or_tmp_681);
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0,
          CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2, or_tmp_681);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_560_nl & (STORE_LOOP_acc_1_tmp[7])
        & (~ (BATCH_LOOP_acc_3_tmp[4])) & BATCH_LOOP_and_13_tmp & (fsm_output[2])))
        ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, (BATCH_LOOP_acc_3_tmp[3:0]),
          BATCH_LOOP_b_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( core_wen & ((fsm_output[1]) | STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1) & ((~
        STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1) | STORE_LOOP_i_and_8_rgt) ) begin
      STORE_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          STORE_LOOP_i_7_0_lpi_2_dfm_1_6_0_1, STORE_LOOP_i_and_8_rgt);
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
    else if ( core_wen & ((fsm_output[1]) | or_tmp_676 | or_tmp_681) ) begin
      BATCH_LOOP_stage_0_1 <= (BATCH_LOOP_stage_0 & (~ or_tmp_676)) | (fsm_output[1]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_3 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | ((and_dcpl_132 | BATCH_LOOP_and_12_tmp)
        & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_3 <= BATCH_LOOP_stage_0_2 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_4 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_575_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_4 <= BATCH_LOOP_stage_0_3 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_5 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_587_nl & (fsm_output[2]))) ) begin
      BATCH_LOOP_stage_0_5 <= BATCH_LOOP_stage_0_4 & (~ (fsm_output[1]));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_6 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_598_nl & (fsm_output[2]))) ) begin
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
    else if ( core_wen & (and_dcpl_90 | CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1)
        ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
          CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm, CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & mux_611_nl ) begin
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
          and_dcpl_247);
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= MUX_v_8_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm, and_dcpl_247);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_8_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm,
          and_dcpl_247);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1
          <= MUX_v_10_2_2((operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[69:60]),
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm,
          and_dcpl_247);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1 <= 7'b0000000;
    end
    else if ( core_wen & (((~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1])) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2
        & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])) & and_dcpl_87) | STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1)
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
  assign and_927_nl = (~(or_434_cse & BATCH_LOOP_stage_0_11)) & and_tmp;
  assign mux_521_nl = MUX_s_1_2_2(and_tmp, and_927_nl, BATCH_LOOP_stage_v_10);
  assign nor_203_nl = ~(plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_11 | exit_BATCH_LOOP_lpi_2_dfm_st_11
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2
      | (~ or_tmp_431));
  assign mux_523_nl = MUX_s_1_2_2(or_tmp_431, nor_203_nl, and_dcpl_159);
  assign or_552_nl = (~(exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & exit_STORE_CTRL_LOOP_lpi_2_dfm_4))
      | exit_BATCH_LOOP_lpi_2_dfm_1 | (~ STORE_LOOP_equal_tmp_1_1) | or_23_cse;
  assign STORE_LOOP_mux_36_nl = MUX_v_4_2_2(z_out, dma_write_data_index_10_7_sva,
      or_552_nl);
  assign nor_264_nl = ~(BATCH_LOOP_and_12_tmp | BATCH_LOOP_and_13_tmp);
  assign BATCH_LOOP_mux_10_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_1, BATCH_LOOP_stage_0_2,
      nor_264_nl);
  assign nand_67_nl = ~(BATCH_LOOP_stage_v_5 & BATCH_LOOP_stage_0_6 & mux_tmp_176);
  assign nand_68_nl = ~(BATCH_LOOP_stage_0_7 & mux_444_cse);
  assign mux_476_nl = MUX_s_1_2_2(nand_67_nl, nand_68_nl, BATCH_LOOP_stage_v_6);
  assign BATCH_LOOP_mux_11_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_6, BATCH_LOOP_stage_0_7,
      mux_476_nl);
  assign nand_64_nl = ~(BATCH_LOOP_stage_v_6 & BATCH_LOOP_stage_0_7 & mux_tmp_176);
  assign nand_65_nl = ~(BATCH_LOOP_stage_0_8 & mux_443_cse);
  assign mux_493_nl = MUX_s_1_2_2(nand_64_nl, nand_65_nl, BATCH_LOOP_stage_v_7);
  assign BATCH_LOOP_mux_12_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_7, BATCH_LOOP_stage_0_8,
      mux_493_nl);
  assign nor_206_nl = ~(BATCH_LOOP_stage_v_10 | (~ and_tmp_145));
  assign mux_506_nl = MUX_s_1_2_2(nor_206_nl, and_928_cse, BATCH_LOOP_stage_v_8);
  assign mux_505_nl = MUX_s_1_2_2(and_tmp_145, and_304_cse, BATCH_LOOP_stage_v_8);
  assign mux_507_nl = MUX_s_1_2_2(mux_506_nl, mux_505_nl, or_434_cse);
  assign BATCH_LOOP_mux_13_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_9, BATCH_LOOP_stage_0_8,
      mux_507_nl);
  assign or_507_nl = BATCH_LOOP_stage_v_10 | (~ and_tmp_148);
  assign mux_516_nl = MUX_s_1_2_2(or_507_nl, or_tmp_419, BATCH_LOOP_stage_v_9);
  assign nand_61_nl = ~(BATCH_LOOP_stage_0_10 & mux_502_cse);
  assign mux_514_nl = MUX_s_1_2_2(or_tmp_419, nand_61_nl, BATCH_LOOP_stage_0_11);
  assign mux_515_nl = MUX_s_1_2_2((~ and_tmp_148), mux_514_nl, BATCH_LOOP_stage_v_9);
  assign mux_517_nl = MUX_s_1_2_2(mux_516_nl, mux_515_nl, or_434_cse);
  assign BATCH_LOOP_mux_14_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_9, BATCH_LOOP_stage_0_10,
      mux_517_nl);
  assign nand_59_nl = ~(BATCH_LOOP_stage_v_9 & BATCH_LOOP_stage_0_10 & mux_271_cse);
  assign nand_60_nl = ~(or_434_cse & BATCH_LOOP_stage_0_11 & mux_272_cse);
  assign mux_520_nl = MUX_s_1_2_2(nand_59_nl, nand_60_nl, BATCH_LOOP_stage_v_10);
  assign BATCH_LOOP_mux_15_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_10, BATCH_LOOP_stage_0_11,
      mux_520_nl);
  assign nand_56_nl = ~(or_434_cse & BATCH_LOOP_stage_v_10 & BATCH_LOOP_stage_0_11
      & or_tmp_6);
  assign nand_57_nl = ~(BATCH_LOOP_stage_0_12 & or_9_cse & or_tmp_6);
  assign mux_522_nl = MUX_s_1_2_2(nand_56_nl, nand_57_nl, BATCH_LOOP_stage_v_11);
  assign BATCH_LOOP_mux_16_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_11, BATCH_LOOP_stage_0_12,
      mux_522_nl);
  assign nor_271_nl = ~((STORE_LOOP_mux_28_tmp!=2'b10) | mux_52_cse);
  assign mux_223_nl = MUX_s_1_2_2(nor_271_nl, nor_272_cse, or_23_cse);
  assign STORE_LOOP_and_88_nl = LOAD_LOOP_and_1_svs_5 & (~ ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1);
  assign mux_338_nl = MUX_s_1_2_2(or_369_cse, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_355_nl = MUX_s_1_2_2(mux_375_cse, mux_338_nl, or_23_cse);
  assign mux_357_nl = MUX_s_1_2_2(mux_377_cse, mux_355_nl, and_933_cse);
  assign mux_358_nl = MUX_s_1_2_2((~ BATCH_LOOP_stage_v), mux_357_nl, BATCH_LOOP_and_13_tmp);
  assign LOAD_CTRL_LOOP_not_6_nl = ~ exit_LOAD_CTRL_LOOP_sva_1;
  assign and_469_nl = ((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_2) & and_tmp_103;
  assign BATCH_LOOP_b_not_1_nl = ~ (fsm_output[1]);
  assign mux_60_nl = MUX_s_1_2_2(mux_tmp_40, and_952_cse, and_950_cse);
  assign mux_61_nl = MUX_s_1_2_2(mux_60_nl, mux_58_cse, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_62_nl = MUX_s_1_2_2(mux_61_nl, mux_58_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_63_nl = MUX_s_1_2_2(mux_tmp_40, mux_62_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_64_nl = MUX_s_1_2_2(mux_58_cse, mux_63_nl, nor_233_cse);
  assign mux_65_nl = MUX_s_1_2_2(mux_64_nl, or_42_cse, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_269_nl = ~((STORE_LOOP_mux_28_tmp!=2'b00) | mux_65_nl);
  assign nor_270_nl = ~((lfst_exit_STORE_LOOP_lpi_2_1_0[0]) | (~ lfst_exit_STORE_LOOP_lpi_2_2)
      | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]) | exitL_exit_STORE_LOOP_sva);
  assign mux_560_nl = MUX_s_1_2_2(nor_269_nl, nor_270_nl, or_23_cse);
  assign nor_152_nl = ~(BATCH_LOOP_stage_v_4 | (~ and_243_cse));
  assign nor_153_nl = ~((~ BATCH_LOOP_stage_0_4) | BATCH_LOOP_stage_v_4 | (~ mux_tmp_176));
  assign mux_574_nl = MUX_s_1_2_2(nor_152_nl, nor_153_nl, BATCH_LOOP_stage_v_3);
  assign mux_572_nl = MUX_s_1_2_2(mux_tmp_176, and_344_cse, BATCH_LOOP_stage_v_4);
  assign and_345_nl = BATCH_LOOP_stage_0_4 & mux_572_nl;
  assign mux_573_nl = MUX_s_1_2_2(and_243_cse, and_345_nl, BATCH_LOOP_stage_v_3);
  assign mux_575_nl = MUX_s_1_2_2(mux_574_nl, mux_573_nl, or_843_cse);
  assign and_354_nl = and_dcpl_47 & mux_tmp_176;
  assign mux_587_nl = MUX_s_1_2_2(and_354_nl, and_353_cse, BATCH_LOOP_stage_v_4);
  assign and_360_nl = or_843_cse & BATCH_LOOP_stage_v_4 & BATCH_LOOP_stage_0_5 &
      mux_tmp_176;
  assign mux_598_nl = MUX_s_1_2_2(and_360_nl, and_343_cse, BATCH_LOOP_stage_v_5);
  assign mux_610_nl = MUX_s_1_2_2(mux_tmp_176, and_344_cse, BATCH_LOOP_stage_v_3);
  assign and_370_nl = or_843_cse & mux_610_nl;
  assign mux_611_nl = MUX_s_1_2_2(mux_tmp_176, and_370_nl, BATCH_LOOP_stage_v_4);
  assign and_994_nl = (~ STORE_LOOP_equal_tmp_1_1) & (fsm_output[2]);
  assign BATCH_LOOP_mux_23_nl = MUX_v_4_2_2(dma_write_data_index_10_7_sva, dma_read_data_index_10_7_sva,
      and_994_nl);
  assign nl_z_out = BATCH_LOOP_mux_23_nl + 4'b0001;
  assign z_out = nl_z_out[3:0];

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
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_rsc_dat_batch, conf_info_rsc_vld,
      conf_info_rsc_rdy, dma_read_ctrl_rsc_dat_size, dma_read_ctrl_rsc_dat_length,
      dma_read_ctrl_rsc_dat_index, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      dma_write_ctrl_rsc_dat_size, dma_write_ctrl_rsc_dat_length, dma_write_ctrl_rsc_dat_index,
      dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld,
      dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      acc_done_sync_vld
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;
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
  output acc_done_sync_vld;


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
      .debug_rsc_dat(debug_rsc_dat),
      .debug_rsc_triosy_lz(debug_rsc_triosy_lz),
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
      .acc_done_sync_vld(acc_done_sync_vld),
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
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_rsc_dat, conf_info_rsc_vld,
      conf_info_rsc_rdy, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat,
      dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld,
      dma_write_chnl_rsc_rdy, acc_done_sync_vld
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;
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
  output acc_done_sync_vld;


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
      .debug_rsc_dat(debug_rsc_dat),
      .debug_rsc_triosy_lz(debug_rsc_triosy_lz),
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
      .acc_done_sync_vld(acc_done_sync_vld)
    );
  assign dma_read_ctrl_rsc_dat = {dma_read_ctrl_rsc_dat_size , dma_read_ctrl_rsc_dat_length
      , dma_read_ctrl_rsc_dat_index};
  assign dma_write_ctrl_rsc_dat = {dma_write_ctrl_rsc_dat_size , dma_write_ctrl_rsc_dat_length
      , dma_write_ctrl_rsc_dat_index};
endmodule



