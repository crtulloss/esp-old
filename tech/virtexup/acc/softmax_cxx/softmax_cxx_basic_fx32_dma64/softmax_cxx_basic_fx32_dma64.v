
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




//------> ./softmax_cxx_ccs_in_v1.v 
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


module esp_acc_softmax_cxx_ccs_in_v1 (idat, dat);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  input  [width-1:0] dat;

  wire   [width-1:0] idat;

  assign idat = dat;

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
//  Generated date: Wed Jun  3 12:13:17 2020
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
//  Generated date: Wed Jun  3 12:13:47 2020
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_10_7_67_128_128_67_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_10_7_67_128_128_67_1_gen
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_9_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_9_7_32_128_128_32_1_gen
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
  clk, rst, core_wen, fsm_output, CONFIG_LOOP_C_0_tr0, BATCH_LOOP_C_0_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [3:0] fsm_output;
  reg [3:0] fsm_output;
  input CONFIG_LOOP_C_0_tr0;
  input BATCH_LOOP_C_0_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_softmax_cxx_core_core_fsm_1
  parameter
    main_C_0 = 2'd0,
    CONFIG_LOOP_C_0 = 2'd1,
    BATCH_LOOP_C_0 = 2'd2,
    main_C_1 = 2'd3;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_softmax_cxx_core_core_fsm_1
    case (state_var)
      CONFIG_LOOP_C_0 : begin
        fsm_output = 4'b0010;
        if ( CONFIG_LOOP_C_0_tr0 ) begin
          state_var_NS = BATCH_LOOP_C_0;
        end
        else begin
          state_var_NS = CONFIG_LOOP_C_0;
        end
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
      // main_C_0
      default : begin
        fsm_output = 4'b0001;
        state_var_NS = CONFIG_LOOP_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( ~ rst ) begin
      state_var <= main_C_0;
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
  clk, rst, core_wen, core_wten, dma_read_chnl_rsci_wen_comp, dma_write_chnl_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input dma_read_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = dma_read_chnl_rsci_wen_comp & dma_write_chnl_rsci_wen_comp;
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj_conf_done_rsc_triosy_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj_conf_done_rsc_triosy_wait_ctrl
    (
  core_wten, conf_done_rsc_triosy_obj_iswt0, conf_done_rsc_triosy_obj_ld_core_sct
);
  input core_wten;
  input conf_done_rsc_triosy_obj_iswt0;
  output conf_done_rsc_triosy_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign conf_done_rsc_triosy_obj_ld_core_sct = conf_done_rsc_triosy_obj_iswt0 &
      (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl
    (
  core_wten, conf_info_batch_rsc_triosy_obj_iswt0, conf_info_batch_rsc_triosy_obj_ld_core_sct
);
  input core_wten;
  input conf_info_batch_rsc_triosy_obj_iswt0;
  output conf_info_batch_rsc_triosy_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign conf_info_batch_rsc_triosy_obj_ld_core_sct = conf_info_batch_rsc_triosy_obj_iswt0
      & (~ core_wten);
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
  core_wen, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_iswt0, core_wten, dma_read_ctrl_rsci_biwt,
      dma_read_ctrl_rsci_bdwt
);
  input core_wen;
  input dma_read_ctrl_rsci_oswt_unreg;
  input dma_read_ctrl_rsci_iswt0;
  input core_wten;
  output dma_read_ctrl_rsci_biwt;
  output dma_read_ctrl_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bdwt = dma_read_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_read_ctrl_rsci_biwt = (~ core_wten) & dma_read_ctrl_rsci_iswt0;
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj (
  conf_done_rsc_triosy_lz, core_wten, conf_done_rsc_triosy_obj_iswt0
);
  output conf_done_rsc_triosy_lz;
  input core_wten;
  input conf_done_rsc_triosy_obj_iswt0;


  // Interconnect Declarations
  wire conf_done_rsc_triosy_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) conf_done_rsc_triosy_obj (
      .ld(conf_done_rsc_triosy_obj_ld_core_sct),
      .lz(conf_done_rsc_triosy_lz)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj_conf_done_rsc_triosy_wait_ctrl
      softmax_cxx_core_conf_done_rsc_triosy_obj_conf_done_rsc_triosy_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .conf_done_rsc_triosy_obj_iswt0(conf_done_rsc_triosy_obj_iswt0),
      .conf_done_rsc_triosy_obj_ld_core_sct(conf_done_rsc_triosy_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj (
  conf_info_batch_rsc_triosy_lz, core_wten, conf_info_batch_rsc_triosy_obj_iswt0
);
  output conf_info_batch_rsc_triosy_lz;
  input core_wten;
  input conf_info_batch_rsc_triosy_obj_iswt0;


  // Interconnect Declarations
  wire conf_info_batch_rsc_triosy_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) conf_info_batch_rsc_triosy_obj
      (
      .ld(conf_info_batch_rsc_triosy_obj_ld_core_sct),
      .lz(conf_info_batch_rsc_triosy_lz)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl
      softmax_cxx_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .conf_info_batch_rsc_triosy_obj_iswt0(conf_info_batch_rsc_triosy_obj_iswt0),
      .conf_info_batch_rsc_triosy_obj_ld_core_sct(conf_info_batch_rsc_triosy_obj_ld_core_sct)
    );
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
  esp_acc_softmax_cxx_ccs_sync_out_vld_v1 #(.rscid(32'sd15)) acc_done_synci (
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd7),
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
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd6),
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd5),
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
      core_wen, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_bawt, dma_read_ctrl_rsci_iswt0,
      core_wten, dma_read_ctrl_rsci_irdy_mxwt, dma_read_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input core_wen;
  input dma_read_ctrl_rsci_oswt_unreg;
  output dma_read_ctrl_rsci_bawt;
  input dma_read_ctrl_rsci_iswt0;
  input core_wten;
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd4),
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
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .core_wten(core_wten),
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core (
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_batch_rsc_dat, conf_info_batch_rsc_triosy_lz,
      conf_done_rsc_dat, conf_done_rsc_triosy_lz, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat,
      dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_sync_vld, plm_out_data_rsci_d_d,
      plm_out_data_rsci_q_d, plm_out_data_rsci_radr_d, plm_out_data_rsci_wadr_d,
      plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d,
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
  input [31:0] conf_info_batch_rsc_dat;
  output conf_info_batch_rsc_triosy_lz;
  input conf_done_rsc_dat;
  output conf_done_rsc_triosy_lz;
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
  wire [31:0] conf_info_batch_rsci_idat;
  wire conf_done_rsci_idat;
  wire dma_read_ctrl_rsci_bawt;
  wire core_wten;
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
  wire [1:0] STORE_LOOP_mux1h_48_tmp;
  wire BATCH_LOOP_and_12_tmp;
  wire or_tmp_9;
  wire and_tmp;
  wire and_tmp_3;
  wire not_tmp_29;
  wire and_tmp_21;
  wire and_dcpl_35;
  wire and_dcpl_36;
  wire or_dcpl_14;
  wire or_dcpl_32;
  wire or_tmp_135;
  wire mux_tmp_107;
  wire or_tmp_136;
  wire mux_tmp_108;
  wire or_dcpl_37;
  wire or_dcpl_44;
  wire and_tmp_56;
  wire or_tmp_151;
  wire or_tmp_152;
  wire or_tmp_153;
  wire or_tmp_154;
  wire or_tmp_157;
  wire or_tmp_159;
  wire or_tmp_160;
  wire mux_tmp_136;
  wire mux_tmp_140;
  wire mux_tmp_141;
  wire nor_tmp_39;
  wire and_dcpl_42;
  wire and_dcpl_45;
  wire mux_tmp_161;
  wire nand_tmp_27;
  wire nor_tmp_47;
  wire or_tmp_171;
  wire mux_tmp_162;
  wire mux_tmp_164;
  wire or_tmp_194;
  wire or_tmp_195;
  wire mux_tmp_185;
  wire or_tmp_206;
  wire or_tmp_208;
  wire and_tmp_62;
  wire nand_tmp_32;
  wire or_tmp_214;
  wire or_tmp_217;
  wire mux_tmp_197;
  wire nor_tmp_74;
  wire mux_tmp_231;
  wire mux_tmp_232;
  wire mux_tmp_240;
  wire mux_tmp_241;
  wire and_dcpl_58;
  wire or_dcpl_81;
  wire or_tmp_264;
  wire mux_tmp_254;
  wire not_tmp_182;
  wire not_tmp_183;
  wire or_dcpl_101;
  wire and_dcpl_69;
  wire and_dcpl_130;
  wire and_tmp_96;
  wire and_dcpl_136;
  wire mux_tmp_378;
  wire and_dcpl_137;
  wire or_tmp_375;
  wire mux_tmp_432;
  wire mux_tmp_450;
  wire mux_tmp_465;
  wire and_tmp_148;
  wire or_tmp_431;
  wire and_tmp_151;
  wire and_dcpl_160;
  wire and_dcpl_164;
  wire or_tmp_443;
  wire or_tmp_449;
  wire mux_tmp_494;
  wire mux_tmp_495;
  wire and_dcpl_248;
  wire or_tmp_509;
  wire or_tmp_510;
  wire or_tmp_516;
  wire or_tmp_522;
  wire or_tmp_543;
  wire or_tmp_560;
  wire or_tmp_579;
  wire or_tmp_582;
  wire or_tmp_632;
  wire or_tmp_663;
  wire or_tmp_704;
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
  wire STORE_LOOP_and_5_ssc_1;
  wire STORE_LOOP_and_7_ssc_1;
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
  reg exit_CALC_SOFTMAX_LOOP_lpi_2;
  reg [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0;
  wire STORE_LOOP_STORE_LOOP_and_cse_1;
  wire STORE_LOOP_STORE_LOOP_nor_1_cse_1;
  wire STORE_LOOP_equal_tmp_mx0w0;
  wire STORE_LOOP_equal_tmp_1_mx0w0;
  reg STORE_LOOP_nor_tmp_1;
  reg exit_BATCH_LOOP_lpi_2_dfm_1;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [74:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  reg [7:0] STORE_LOOP_i_7_0_sva_1_1;
  reg exit_STORE_CTRL_LOOP_lpi_2_dfm_3;
  reg CALC_SOFTMAX_LOOP_asn_3_itm_1;
  reg STORE_LOOP_asn_17_itm_1;
  reg exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_1_0;
  reg CALC_SOFTMAX_LOOP_asn_itm_9;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_9_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_9;
  reg BATCH_LOOP_stage_0_12;
  reg BATCH_LOOP_stage_v_9;
  reg BATCH_LOOP_stage_0_10;
  reg BATCH_LOOP_stage_0_11;
  reg exitL_exit_STORE_LOOP_sva;
  reg STORE_LOOP_STORE_LOOP_and_9_itm_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_2;
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
  reg STORE_LOOP_asn_17_itm_5;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2;
  reg BATCH_LOOP_stage_v_3;
  reg BATCH_LOOP_stage_0_4;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_3;
  reg BATCH_LOOP_stage_0_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_3;
  reg STORE_LOOP_asn_17_itm_3;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0;
  reg BATCH_LOOP_stage_v_2;
  reg BATCH_LOOP_stage_0_3;
  reg LOAD_LOOP_and_1_svs_st_3;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1;
  reg LOAD_LOOP_and_1_svs_st_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_2;
  reg lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2;
  reg CALC_SOFTMAX_LOOP_asn_itm_4;
  reg STORE_LOOP_and_32_itm_4;
  reg BATCH_LOOP_stage_v;
  reg BATCH_LOOP_stage_0;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
  reg reg_dma_write_chnl_rsci_iswt0_cse;
  wire STORE_LOOP_and_53_cse;
  wire CALC_SOFTMAX_LOOP_and_cse;
  wire CALC_SOFTMAX_LOOP_and_22_cse;
  wire STORE_LOOP_and_59_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_4_cse;
  reg reg_dma_read_chnl_rsci_iswt0_cse;
  wire or_245_cse;
  wire BATCH_LOOP_and_17_cse;
  wire and_970_cse;
  wire STORE_LOOP_and_68_cse;
  wire STORE_LOOP_and_71_cse;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse;
  wire CALC_SOFTMAX_LOOP_and_24_cse;
  wire CALC_SOFTMAX_LOOP_and_25_cse;
  reg reg_conf_done_rsc_triosy_obj_ld_core_psct_cse;
  reg reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse;
  reg reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse;
  reg reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse;
  reg reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  reg reg_dma_write_ctrl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_ctrl_rsci_ivld_core_psct_cse;
  wire STORE_LOOP_and_73_cse;
  wire LOAD_LOOP_i_and_1_cse;
  wire LOAD_LOOP_and_2_cse;
  wire LOAD_LOOP_and_3_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_cse;
  wire or_472_cse;
  wire or_862_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  wire and_971_cse;
  wire or_1_cse;
  wire or_20_cse;
  wire or_12_cse;
  wire and_997_cse;
  wire and_1006_cse;
  wire nor_125_cse;
  wire and_967_cse;
  wire and_1003_cse;
  wire and_1009_cse;
  wire and_1001_cse;
  wire and_998_cse;
  wire or_606_cse;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1;
  reg [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0;
  wire STORE_LOOP_and_9_itm_mx0w0;
  reg [6:0] reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse;
  wire nor_229_cse;
  wire or_270_cse;
  wire mux_146_cse;
  wire mux_31_cse;
  wire mux_484_cse;
  wire mux_298_cse;
  wire mux_357_cse;
  wire mux_355_cse;
  wire mux_293_cse;
  wire nor_176_cse;
  wire mux_147_cse;
  wire mux_223_cse;
  wire mux_288_cse;
  wire and_332_cse;
  wire and_973_cse;
  wire mux_486_cse;
  wire mux_191_cse;
  wire mux_427_cse;
  wire mux_426_cse;
  wire mux_425_cse;
  wire mux_444_cse;
  wire and_271_cse;
  wire mux_568_cse;
  wire and_389_cse;
  wire mux_144_cse;
  wire and_485_cse;
  wire and_390_cse;
  wire and_125_cse;
  reg [31:0] plm_out_data_rsci_d_d_reg;
  wire [31:0] CALC_SOFTMAX_LOOP_mux_1_rmff;
  reg [6:0] plm_out_data_rsci_radr_d_reg;
  wire [6:0] STORE_LOOP_i_mux_rmff;
  reg [6:0] plm_out_data_rsci_wadr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_rmff;
  wire plm_out_data_rsci_we_d_iff;
  wire and_779_rmff;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_789_rmff;
  reg [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
  reg [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_1_rmff;
  reg [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg;
  wire [6:0] CALC_EXP_LOOP_i_mux_rmff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;
  wire and_785_rmff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_783_rmff;
  wire and_777_rmff;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2;
  wire [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4;
  wire or_dcpl_126;
  wire LOAD_LOOP_and_1_svs_mx0w0;
  wire STORE_LOOP_or_tmp_mx0w0;
  wire STORE_LOOP_nor_tmp_mx0w0;
  wire STORE_LOOP_and_8_itm_mx0w0;
  wire or_883_tmp;
  wire STORE_LOOP_and_26_tmp;
  wire or_878_tmp;
  wire STORE_LOOP_and_29_tmp;
  wire STORE_LOOP_and_23_m1c_1;
  wire and_1023_cse;
  wire and_1028_cse;
  wire and_1029_cse;
  wire [93:0] operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [72:0] operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm;
  wire mux_164_itm;
  wire [3:0] z_out;
  wire [4:0] nl_z_out;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2;
  reg [31:0] conf_info_batch_sva;
  reg [3:0] dma_read_data_index_10_7_sva;
  reg [3:0] dma_write_data_index_10_7_sva;
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
  reg STORE_LOOP_and_8_itm_1;
  reg STORE_LOOP_and_8_itm_2;
  reg STORE_LOOP_and_9_itm_1;
  reg STORE_LOOP_and_9_itm_2;
  reg STORE_LOOP_or_25_itm_1;
  reg STORE_LOOP_or_25_itm_2;
  reg STORE_LOOP_and_32_itm_1;
  reg STORE_LOOP_and_32_itm_2;
  reg STORE_LOOP_and_32_itm_3;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_1;
  reg CALC_SOFTMAX_LOOP_asn_itm_2;
  reg exit_BATCH_LOOP_lpi_2_dfm_st_6;
  reg CALC_SOFTMAX_LOOP_asn_itm_5;
  reg CALC_SOFTMAX_LOOP_asn_itm_6;
  reg STORE_LOOP_asn_17_itm_2;
  reg STORE_LOOP_asn_17_itm_4;
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
  wire [3:0] dma_read_data_index_10_7_sva_mx1;
  wire STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1;
  wire exit_STORE_CTRL_LOOP_lpi_2_mx1;
  wire STORE_LOOP_mux1h_18_mx0w1;
  wire [1:0] lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1;
  wire exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx0w1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1;
  wire [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2;
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
  wire STORE_LOOP_mux1h_19_mx0w1;
  wire [6:0] STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
  wire BATCH_LOOP_stage_v_mx0c1;
  wire BATCH_LOOP_stage_v_2_mx0c1;
  wire BATCH_LOOP_stage_v_3_mx0c1;
  wire BATCH_LOOP_stage_v_4_mx0c1;
  wire BATCH_LOOP_b_4_0_sva_3_0_mx0c1;
  wire BATCH_LOOP_stage_0_3_mx0c1;
  wire BATCH_LOOP_stage_0_4_mx0c1;
  wire BATCH_LOOP_stage_0_5_mx0c1;
  wire BATCH_LOOP_stage_0_6_mx0c1;
  wire CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1;
  wire STORE_LOOP_or_25_itm_mx0w0;
  wire STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1;
  wire lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1;
  wire BATCH_LOOP_BATCH_LOOP_or_21_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_6_cse_1;
  wire BATCH_LOOP_BATCH_LOOP_or_4_cse_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [6:0] libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp;
  wire and_835_cse;
  wire and_657_cse;
  wire STORE_LOOP_and_98_cse;
  wire mux_620_itm;
  wire BATCH_LOOP_acc_itm_32_1;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28;
  wire mux_145_cse;
  reg reg_LOAD_LOOP_and_1_svs_1_cse;

  wire[0:0] or_640_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl;
  wire[0:0] or_646_nl;
  wire[0:0] mux_622_nl;
  wire[0:0] and_126_nl;
  wire[0:0] dma_read_data_index_not_1_nl;
  wire[0:0] mux_165_nl;
  wire[0:0] or_885_nl;
  wire[0:0] mux_190_nl;
  wire[0:0] nor_133_nl;
  wire[0:0] mux_189_nl;
  wire[0:0] mux_188_nl;
  wire[0:0] mux_187_nl;
  wire[0:0] mux_186_nl;
  wire[0:0] mux_185_nl;
  wire[0:0] nand_30_nl;
  wire[0:0] nand_29_nl;
  wire[0:0] mux_182_nl;
  wire[0:0] nand_28_nl;
  wire[0:0] mux_181_nl;
  wire[0:0] nor_136_nl;
  wire[0:0] mux_174_nl;
  wire[0:0] nor_137_nl;
  wire[0:0] nor_7_nl;
  wire[3:0] STORE_LOOP_mux_15_nl;
  wire[0:0] or_276_nl;
  wire[0:0] dma_write_data_index_not_1_nl;
  wire[0:0] mux_292_nl;
  wire[0:0] mux_291_nl;
  wire[0:0] mux_290_nl;
  wire[0:0] and_170_nl;
  wire[0:0] mux_297_nl;
  wire[0:0] and_169_nl;
  wire[0:0] mux_296_nl;
  wire[0:0] and_168_nl;
  wire[0:0] mux_295_nl;
  wire[0:0] and_167_nl;
  wire[0:0] mux_294_nl;
  wire[0:0] and_166_nl;
  wire[0:0] mux_299_nl;
  wire[0:0] and_172_nl;
  wire[0:0] or_294_nl;
  wire[0:0] mux_354_nl;
  wire[0:0] mux_353_nl;
  wire[0:0] mux_352_nl;
  wire[0:0] mux_351_nl;
  wire[0:0] or_424_nl;
  wire[0:0] mux_349_nl;
  wire[0:0] mux_345_nl;
  wire[0:0] mux_344_nl;
  wire[0:0] or_409_nl;
  wire[0:0] mux_359_nl;
  wire[0:0] mux_358_nl;
  wire[0:0] mux_356_nl;
  wire[0:0] mux_339_nl;
  wire[0:0] or_408_nl;
  wire[0:0] and_294_nl;
  wire[0:0] mux_424_nl;
  wire[0:0] and_293_nl;
  wire[0:0] mux_423_nl;
  wire[0:0] mux_422_nl;
  wire[0:0] mux_421_nl;
  wire[0:0] mux_420_nl;
  wire[0:0] and_295_nl;
  wire[0:0] and_296_nl;
  wire[0:0] mux_503_nl;
  wire[0:0] and_972_nl;
  wire[0:0] mux_505_nl;
  wire[0:0] nor_172_nl;
  wire[0:0] BATCH_LOOP_mux_46_nl;
  wire[0:0] nor_nl;
  wire[0:0] BATCH_LOOP_mux_45_nl;
  wire[0:0] mux_458_nl;
  wire[0:0] nand_61_nl;
  wire[0:0] nand_62_nl;
  wire[0:0] BATCH_LOOP_mux_44_nl;
  wire[0:0] mux_475_nl;
  wire[0:0] nand_58_nl;
  wire[0:0] nand_59_nl;
  wire[0:0] mux_483_nl;
  wire[0:0] mux_485_nl;
  wire[0:0] nor_177_nl;
  wire[0:0] and_331_nl;
  wire[0:0] BATCH_LOOP_mux_43_nl;
  wire[0:0] mux_489_nl;
  wire[0:0] mux_488_nl;
  wire[0:0] nor_175_nl;
  wire[0:0] mux_487_nl;
  wire[0:0] BATCH_LOOP_mux_42_nl;
  wire[0:0] mux_499_nl;
  wire[0:0] mux_498_nl;
  wire[0:0] or_545_nl;
  wire[0:0] mux_497_nl;
  wire[0:0] mux_496_nl;
  wire[0:0] nand_55_nl;
  wire[0:0] BATCH_LOOP_mux_41_nl;
  wire[0:0] mux_502_nl;
  wire[0:0] nand_53_nl;
  wire[0:0] nand_54_nl;
  wire[0:0] BATCH_LOOP_mux_40_nl;
  wire[0:0] mux_504_nl;
  wire[0:0] nand_50_nl;
  wire[0:0] nand_51_nl;
  wire[0:0] LOAD_CTRL_LOOP_not_1_nl;
  wire[0:0] mux_570_nl;
  wire[0:0] and_391_nl;
  wire[0:0] mux_569_nl;
  wire[0:0] mux_581_nl;
  wire[0:0] and_397_nl;
  wire[0:0] and_491_nl;
  wire[0:0] or_215_nl;
  wire[0:0] STORE_CTRL_LOOP_mux_1_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_1_nl;
  wire[0:0] STORE_LOOP_or_19_nl;
  wire[0:0] STORE_LOOP_mux_27_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_12_nl;
  wire[0:0] STORE_LOOP_and_96_nl;
  wire[6:0] STORE_LOOP_i_mux_1_nl;
  wire[0:0] BATCH_LOOP_if_not_nl;
  wire[0:0] or_337_nl;
  wire[0:0] nor_230_nl;
  wire[0:0] LOAD_LOOP_LOAD_LOOP_and_2_nl;
  wire[0:0] STORE_LOOP_or_20_nl;
  wire[0:0] nor_231_nl;
  wire[0:0] and_1025_nl;
  wire[0:0] STORE_LOOP_mux_39_nl;
  wire[0:0] STORE_LOOP_STORE_LOOP_nor_nl;
  wire[0:0] or_573_nl;
  wire[32:0] BATCH_LOOP_acc_nl;
  wire[33:0] nl_BATCH_LOOP_acc_nl;
  wire[0:0] STORE_LOOP_mux_62_nl;
  wire[0:0] STORE_LOOP_and_47_nl;
  wire[0:0] STORE_LOOP_and_48_nl;
  wire[0:0] STORE_LOOP_or_24_nl;
  wire[1:0] STORE_LOOP_and_nl;
  wire[46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire signed [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire[0:0] and_18_nl;
  wire[0:0] or_223_nl;
  wire[0:0] mux_155_nl;
  wire[0:0] mux_154_nl;
  wire[0:0] mux_153_nl;
  wire[0:0] or_226_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] mux_163_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] mux_161_nl;
  wire[0:0] and_137_nl;
  wire[0:0] mux_176_nl;
  wire[0:0] mux_175_nl;
  wire[0:0] mux_196_nl;
  wire[0:0] or_267_nl;
  wire[0:0] mux_195_nl;
  wire[0:0] or_266_nl;
  wire[0:0] or_264_nl;
  wire[0:0] mux_194_nl;
  wire[0:0] nand_31_nl;
  wire[0:0] mux_200_nl;
  wire[0:0] mux_199_nl;
  wire[0:0] mux_198_nl;
  wire[0:0] mux_197_nl;
  wire[0:0] or_nl;
  wire[0:0] or_250_nl;
  wire[0:0] mux_207_nl;
  wire[0:0] or_287_nl;
  wire[0:0] mux_211_nl;
  wire[0:0] mux_221_nl;
  wire[0:0] mux_204_nl;
  wire[0:0] and_990_nl;
  wire[0:0] nor_55_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] nor_189_nl;
  wire[0:0] and_978_nl;
  wire[0:0] mux_255_nl;
  wire[0:0] mux_254_nl;
  wire[0:0] mux_253_nl;
  wire[0:0] mux_252_nl;
  wire[0:0] mux_251_nl;
  wire[0:0] mux_250_nl;
  wire[0:0] nand_38_nl;
  wire[0:0] or_326_nl;
  wire[0:0] mux_287_nl;
  wire[0:0] and_163_nl;
  wire[0:0] mux_286_nl;
  wire[0:0] mux_285_nl;
  wire[0:0] mux_284_nl;
  wire[0:0] mux_283_nl;
  wire[0:0] mux_282_nl;
  wire[0:0] mux_281_nl;
  wire[0:0] mux_280_nl;
  wire[0:0] mux_279_nl;
  wire[0:0] mux_278_nl;
  wire[0:0] mux_277_nl;
  wire[0:0] mux_276_nl;
  wire[0:0] mux_275_nl;
  wire[0:0] and_1016_nl;
  wire[0:0] nor_185_nl;
  wire[0:0] or_448_nl;
  wire[0:0] mux_447_nl;
  wire[0:0] nand_46_nl;
  wire[0:0] mux_446_nl;
  wire[0:0] nand_45_nl;
  wire[0:0] mux_445_nl;
  wire[0:0] and_309_nl;
  wire[0:0] mux_465_nl;
  wire[0:0] nor_180_nl;
  wire[0:0] or_567_nl;
  wire[0:0] mux_508_nl;
  wire[0:0] mux_605_nl;
  wire[0:0] mux_166_nl;
  wire[0:0] or_864_nl;
  wire[0:0] mux_519_nl;
  wire[0:0] nor_233_nl;
  wire[0:0] mux_518_nl;
  wire[0:0] mux_517_nl;
  wire[0:0] mux_516_nl;
  wire[0:0] mux_515_nl;
  wire[0:0] mux_514_nl;
  wire[0:0] mux_513_nl;
  wire[0:0] nor_234_nl;
  wire[0:0] mux_393_nl;
  wire[0:0] mux_392_nl;
  wire[0:0] nor_196_nl;
  wire[0:0] nor_197_nl;
  wire[0:0] mux_391_nl;
  wire[0:0] and_270_nl;
  wire[0:0] mux_390_nl;
  wire[0:0] mux_546_nl;
  wire[0:0] and_377_nl;
  wire[0:0] mux_557_nl;
  wire[0:0] and_383_nl;
  wire[3:0] BATCH_LOOP_mux_47_nl;
  wire[0:0] and_1037_nl;

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
      = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]))
      & and_dcpl_42 & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg
      = (~(CALC_SOFTMAX_LOOP_asn_3_itm_1 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2))
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b11) & (~ exit_BATCH_LOOP_lpi_2_dfm_1)
      & BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat =
      {56'b01100000000000000000000000010000000000000000000000000000 , dma_write_ctrl_rsci_idat_10_7
      , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_read_chnl_rsci_inst_dma_read_chnl_rsci_oswt_unreg
      = and_dcpl_45 & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg
      = and_dcpl_36 & (fsm_output[2]);
  wire [63:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat =
      {32'b11011110101011011011111011101111 , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_oswt_unreg
      = or_tmp_9 & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b11)
      & (~(exit_BATCH_LOOP_lpi_2_dfm_st_11 | CALC_SOFTMAX_LOOP_asn_itm_11)) & plm_out_data_rsci_bawt
      & BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11 & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_1_inst_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg
      = mux_568_cse & and_dcpl_69 & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0]))
      & ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      & BATCH_LOOP_stage_v_4 & (fsm_output[2]);
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_3_nl;
  wire [93:0] nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_3_nl
      = STORE_LOOP_and_32_itm_4 & (~((~ BATCH_LOOP_stage_v_5) | STORE_LOOP_asn_17_itm_5));
  assign nl_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst_CALC_SOFTMAX_LOOP_mul_cmp_b_core
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_3_nl);
  esp_acc_softmax_cxx_ccs_out_v1 #(.rscid(32'sd1),
  .width(32'sd32)) debug_rsci (
      .idat(32'b00000000000000000000000000000000),
      .dat(debug_rsc_dat)
    );
  esp_acc_softmax_cxx_ccs_in_v1 #(.rscid(32'sd2),
  .width(32'sd32)) conf_info_batch_rsci (
      .dat(conf_info_batch_rsc_dat),
      .idat(conf_info_batch_rsci_idat)
    );
  esp_acc_softmax_cxx_ccs_in_v1 #(.rscid(32'sd3),
  .width(32'sd1)) conf_done_rsci (
      .dat(conf_done_rsc_dat),
      .idat(conf_done_rsci_idat)
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
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci softmax_cxx_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_ctrl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg[0:0]),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_iswt0(reg_dma_read_ctrl_rsci_ivld_core_psct_cse),
      .core_wten(core_wten),
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
      .dma_read_chnl_rsci_iswt0(reg_dma_read_chnl_rsci_iswt0_cse),
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
      .dma_write_chnl_rsci_iswt0(reg_dma_write_chnl_rsci_iswt0_cse),
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
      .plm_out_data_rsci_oswt_unreg_1(or_tmp_509),
      .plm_out_data_rsci_iswt0_1(reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .plm_out_data_rsci_iswt0_pff(and_779_rmff),
      .plm_out_data_rsci_iswt0_1_pff(and_789_rmff)
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
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_oswt_unreg_1(and_777_rmff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1(reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d_mxwt),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_pff(and_785_rmff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_iswt0_1_pff(and_783_rmff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci softmax_cxx_core_acc_done_synci_inst
      (
      .acc_done_sync_vld(acc_done_sync_vld),
      .core_wten(core_wten),
      .acc_done_synci_iswt0(reg_conf_done_rsc_triosy_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj softmax_cxx_core_debug_rsc_triosy_obj_inst
      (
      .debug_rsc_triosy_lz(debug_rsc_triosy_lz),
      .core_wten(core_wten),
      .debug_rsc_triosy_obj_iswt0(reg_conf_done_rsc_triosy_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj softmax_cxx_core_conf_info_batch_rsc_triosy_obj_inst
      (
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
      .core_wten(core_wten),
      .conf_info_batch_rsc_triosy_obj_iswt0(reg_conf_done_rsc_triosy_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj softmax_cxx_core_conf_done_rsc_triosy_obj_inst
      (
      .conf_done_rsc_triosy_lz(conf_done_rsc_triosy_lz),
      .core_wten(core_wten),
      .conf_done_rsc_triosy_obj_iswt0(reg_conf_done_rsc_triosy_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp softmax_cxx_core_CALC_SOFTMAX_LOOP_mul_cmp_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .CALC_SOFTMAX_LOOP_mul_cmp_oswt_unreg(and_779_rmff),
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
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_fsm softmax_cxx_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .CONFIG_LOOP_C_0_tr0(conf_done_rsci_idat),
      .BATCH_LOOP_C_0_tr0(BATCH_LOOP_nor_13_tmp)
    );
  assign CALC_SOFTMAX_LOOP_mux_1_rmff = MUX_v_32_2_2(CALC_SOFTMAX_LOOP_mul_cmp_z_mxwt,
      plm_out_data_rsci_d_d_reg, or_tmp_516);
  assign CALC_SOFTMAX_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10,
      plm_out_data_rsci_wadr_d_reg, or_tmp_516);
  assign or_640_nl = (~ (fsm_output[2])) | (~ mux_31_cse) | (~ BATCH_LOOP_stage_0_11)
      | exit_BATCH_LOOP_lpi_2_dfm_st_10 | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b00) | (~ BATCH_LOOP_stage_v_10);
  assign STORE_LOOP_i_mux_rmff = MUX_v_7_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9,
      plm_out_data_rsci_radr_d_reg, or_640_nl);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_4_cse
      = core_wen & ((fsm_output[0]) | (fsm_output[2]));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp
      = STORE_LOOP_and_32_itm_4 & (~((~ mux_427_cse) | or_dcpl_32 | STORE_LOOP_asn_17_itm_5));
  assign operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff = MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg,
      or_tmp_522);
  assign CALC_EXP_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg,
      or_tmp_522);
  assign or_646_nl = (~ (fsm_output[2])) | (~ mux_144_cse) | or_dcpl_44 | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])) | CALC_SOFTMAX_LOOP_asn_itm_3;
  assign CALC_SOFTMAX_LOOP_i_mux_1_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg,
      or_646_nl);
  assign STORE_LOOP_and_53_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_144_cse)
      | or_dcpl_37));
  assign mux_145_cse = MUX_s_1_2_2(nor_229_cse, or_tmp_9, or_20_cse);
  assign mux_622_nl = MUX_s_1_2_2(nor_229_cse, or_tmp_9, or_20_cse);
  assign mux_146_cse = MUX_s_1_2_2(nor_229_cse, mux_622_nl, BATCH_LOOP_stage_0_12);
  assign and_126_nl = or_472_cse & BATCH_LOOP_stage_0_11 & mux_146_cse;
  assign mux_147_cse = MUX_s_1_2_2(mux_145_cse, and_126_nl, BATCH_LOOP_stage_v_10);
  assign CALC_SOFTMAX_LOOP_and_cse = core_wen & (~((~ (fsm_output[2])) | (~ mux_147_cse)
      | not_tmp_29));
  assign CALC_SOFTMAX_LOOP_and_22_cse = core_wen & (fsm_output[2]) & and_tmp_56 &
      BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign STORE_LOOP_and_59_cse = core_wen & (fsm_output[2]) & and_tmp_3 & BATCH_LOOP_stage_0_12
      & BATCH_LOOP_stage_v_11;
  assign or_245_cse = (STORE_LOOP_mux1h_48_tmp!=2'b00);
  assign and_970_cse = STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7]);
  assign and_971_cse = STORE_LOOP_and_5_ssc_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_133_nl = ~(lfst_exit_STORE_LOOP_lpi_2_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0[1]));
  assign mux_190_nl = MUX_s_1_2_2(nor_133_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign nand_30_nl = ~(or_245_cse & (~(and_970_cse | or_tmp_171)));
  assign mux_185_nl = MUX_s_1_2_2(nand_30_nl, mux_tmp_161, and_971_cse);
  assign mux_186_nl = MUX_s_1_2_2(mux_185_nl, mux_tmp_164, BATCH_LOOP_acc_itm_32_1);
  assign nand_28_nl = ~(STORE_LOOP_equal_tmp_2_1 & (STORE_LOOP_i_7_0_sva_1_1[7])
      & (~ nand_tmp_27));
  assign mux_182_nl = MUX_s_1_2_2(mux_tmp_162, nand_28_nl, or_245_cse);
  assign nand_29_nl = ~(BATCH_LOOP_acc_itm_32_1 & (~(STORE_LOOP_and_5_ssc_1 | mux_182_nl)));
  assign mux_187_nl = MUX_s_1_2_2(mux_186_nl, nand_29_nl, lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]);
  assign nor_136_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1[1]) | mux_tmp_164);
  assign mux_181_nl = MUX_s_1_2_2(nor_136_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_188_nl = MUX_s_1_2_2((~ mux_187_nl), mux_181_nl, STORE_LOOP_STORE_LOOP_and_9_itm_1);
  assign nor_137_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0[1]) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign mux_174_nl = MUX_s_1_2_2(nor_137_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_189_nl = MUX_s_1_2_2(mux_188_nl, mux_174_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_7_nl = ~(STORE_LOOP_asn_17_itm_1 | (~ BATCH_LOOP_and_12_tmp));
  assign mux_191_cse = MUX_s_1_2_2(mux_190_nl, mux_189_nl, nor_7_nl);
  assign BATCH_LOOP_and_17_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_13_tmp;
  assign or_1_cse = (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
  assign STORE_LOOP_and_98_cse = core_wen & ((mux_tmp_240 & BATCH_LOOP_and_13_tmp
      & (fsm_output[2])) | or_tmp_579);
  assign CALC_SOFTMAX_LOOP_and_24_cse = core_wen & (((~ mux_tmp_241) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2])) | or_tmp_582);
  assign and_998_cse = STORE_LOOP_STORE_LOOP_and_9_itm_1 & exitL_exit_STORE_LOOP_sva;
  assign and_657_cse = ((~ mux_tmp_240) | BATCH_LOOP_acc_itm_32_1) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign STORE_LOOP_and_68_cse = core_wen & (and_657_cse | and_835_cse);
  assign CALC_SOFTMAX_LOOP_and_25_cse = core_wen & (~((~ (fsm_output[2])) | mux_tmp_241
      | (~ BATCH_LOOP_and_13_tmp)));
  assign STORE_LOOP_and_71_cse = core_wen & (fsm_output[2]) & (~(mux_tmp_240 & (~
      BATCH_LOOP_acc_itm_32_1))) & BATCH_LOOP_and_13_tmp;
  assign mux_290_nl = MUX_s_1_2_2((~ or_12_cse), BATCH_LOOP_stage_v_11, BATCH_LOOP_stage_v_10);
  assign mux_291_nl = MUX_s_1_2_2(or_tmp_264, mux_290_nl, or_472_cse);
  assign mux_292_nl = MUX_s_1_2_2((~ mux_291_nl), mux_tmp_254, BATCH_LOOP_stage_0_12);
  assign mux_293_cse = MUX_s_1_2_2((~ or_tmp_264), mux_292_nl, BATCH_LOOP_stage_0_11);
  assign and_166_nl = BATCH_LOOP_stage_0_10 & mux_293_cse;
  assign mux_294_nl = MUX_s_1_2_2(mux_tmp_254, and_166_nl, BATCH_LOOP_stage_v_9);
  assign and_167_nl = BATCH_LOOP_stage_0_9 & mux_294_nl;
  assign mux_295_nl = MUX_s_1_2_2(mux_tmp_254, and_167_nl, BATCH_LOOP_stage_v_8);
  assign and_168_nl = BATCH_LOOP_stage_0_8 & mux_295_nl;
  assign mux_296_nl = MUX_s_1_2_2(mux_tmp_254, and_168_nl, BATCH_LOOP_stage_v_7);
  assign and_169_nl = BATCH_LOOP_stage_0_7 & mux_296_nl;
  assign mux_297_nl = MUX_s_1_2_2(mux_tmp_254, and_169_nl, BATCH_LOOP_stage_v_6);
  assign and_170_nl = BATCH_LOOP_stage_0_6 & mux_297_nl;
  assign mux_298_cse = MUX_s_1_2_2(mux_tmp_254, and_170_nl, BATCH_LOOP_stage_v_5);
  assign and_172_nl = BATCH_LOOP_stage_0_5 & or_862_cse & mux_298_cse;
  assign mux_299_nl = MUX_s_1_2_2(mux_tmp_254, and_172_nl, BATCH_LOOP_stage_v_4);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse = core_wen
      & (~((~ (fsm_output[2])) | (~(or_606_cse & or_tmp_9 & mux_299_nl)) | or_dcpl_44
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])
      | (~ LOAD_LOOP_and_1_svs_st_3)));
  assign and_777_rmff = mux_568_cse & and_dcpl_69 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0])
      & BATCH_LOOP_stage_v_4 & (~ CALC_SOFTMAX_LOOP_asn_itm_4) & (fsm_output[2]);
  assign and_779_rmff = mux_31_cse & BATCH_LOOP_stage_0_11 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10) & (~ CALC_SOFTMAX_LOOP_asn_itm_10) &
      (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11)
      & BATCH_LOOP_stage_v_10 & (fsm_output[2]);
  assign and_783_rmff = mux_144_cse & and_dcpl_58 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]) & (~ CALC_SOFTMAX_LOOP_asn_itm_3)
      & (fsm_output[2]);
  assign and_785_rmff = mux_144_cse & and_dcpl_58 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_3)
      & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]) & (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2)
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0])) & (fsm_output[2]);
  assign and_789_rmff = mux_31_cse & BATCH_LOOP_stage_0_11 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10)
      & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b00)
      & BATCH_LOOP_stage_v_10 & (fsm_output[2]);
  assign STORE_LOOP_and_73_cse = core_wen & ((exit_BATCH_LOOP_lpi_2_dfm_1 & BATCH_LOOP_and_12_tmp
      & (fsm_output[2])) | or_tmp_663);
  assign LOAD_LOOP_i_and_1_cse = core_wen & (fsm_output[2]) & BATCH_LOOP_and_12_tmp;
  assign and_835_cse = mux_tmp_240 & (~ BATCH_LOOP_acc_itm_32_1) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign nor_125_cse = ~((STORE_LOOP_mux1h_48_tmp!=2'b00));
  assign and_967_cse = (STORE_LOOP_acc_1_tmp[7]) & (BATCH_LOOP_acc_3_tmp[4]);
  assign or_294_nl = (~ BATCH_LOOP_and_12_tmp) | STORE_LOOP_asn_17_itm_1 | exit_BATCH_LOOP_lpi_2_dfm_1
      | STORE_LOOP_STORE_LOOP_and_9_itm_1;
  assign mux_357_cse = MUX_s_1_2_2(or_tmp_217, or_tmp_206, or_294_nl);
  assign or_424_nl = and_970_cse | nor_125_cse | or_tmp_214;
  assign mux_351_nl = MUX_s_1_2_2(or_424_nl, and_tmp_62, and_971_cse);
  assign mux_352_nl = MUX_s_1_2_2(mux_351_nl, mux_tmp_197, BATCH_LOOP_acc_itm_32_1);
  assign mux_349_nl = MUX_s_1_2_2((~ mux_tmp_197), BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_353_nl = MUX_s_1_2_2((~ mux_352_nl), mux_349_nl, STORE_LOOP_STORE_LOOP_and_9_itm_1);
  assign mux_345_nl = MUX_s_1_2_2((~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2), BATCH_LOOP_acc_itm_32_1,
      exitL_exit_STORE_LOOP_sva);
  assign mux_354_nl = MUX_s_1_2_2(mux_353_nl, mux_345_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_344_nl = MUX_s_1_2_2(or_tmp_217, or_tmp_206, or_tmp_208);
  assign or_409_nl = (STORE_LOOP_mux_28_tmp!=2'b00);
  assign mux_355_cse = MUX_s_1_2_2(mux_354_nl, mux_344_nl, or_409_nl);
  assign LOAD_LOOP_and_2_cse = core_wen & BATCH_LOOP_and_12_tmp;
  assign LOAD_LOOP_and_3_cse = core_wen & mux_tmp_378;
  assign or_472_cse = CALC_SOFTMAX_LOOP_mul_cmp_bawt | CALC_SOFTMAX_LOOP_asn_itm_10
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2
      | exit_BATCH_LOOP_lpi_2_dfm_st_10;
  assign or_862_cse = exit_BATCH_LOOP_lpi_2_dfm_st_4 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0!=2'b10)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt;
  assign mux_420_nl = MUX_s_1_2_2((~ mux_tmp_107), or_tmp_135, BATCH_LOOP_stage_v_10);
  assign mux_421_nl = MUX_s_1_2_2(or_tmp_136, mux_420_nl, or_472_cse);
  assign mux_422_nl = MUX_s_1_2_2((~ mux_421_nl), mux_tmp_108, BATCH_LOOP_stage_0_12);
  assign mux_423_nl = MUX_s_1_2_2((~ or_tmp_136), mux_422_nl, BATCH_LOOP_stage_0_11);
  assign and_293_nl = BATCH_LOOP_stage_0_10 & mux_423_nl;
  assign mux_424_nl = MUX_s_1_2_2(mux_tmp_108, and_293_nl, BATCH_LOOP_stage_v_9);
  assign and_294_nl = BATCH_LOOP_stage_0_9 & mux_424_nl;
  assign mux_425_cse = MUX_s_1_2_2(mux_tmp_108, and_294_nl, BATCH_LOOP_stage_v_8);
  assign and_295_nl = BATCH_LOOP_stage_0_8 & mux_425_cse;
  assign mux_426_cse = MUX_s_1_2_2(mux_tmp_108, and_295_nl, BATCH_LOOP_stage_v_7);
  assign and_296_nl = BATCH_LOOP_stage_0_7 & mux_426_cse;
  assign mux_427_cse = MUX_s_1_2_2(mux_tmp_108, and_296_nl, BATCH_LOOP_stage_v_6);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_cse
      = core_wen & and_tmp_21;
  assign and_1001_cse = BATCH_LOOP_stage_v_9 & BATCH_LOOP_stage_0_10;
  assign mux_483_nl = MUX_s_1_2_2(mux_tmp_107, (~ or_tmp_135), BATCH_LOOP_stage_v_10);
  assign mux_484_cse = MUX_s_1_2_2(mux_483_nl, mux_tmp_107, BATCH_LOOP_stage_0_12);
  assign nor_176_cse = ~((~(BATCH_LOOP_stage_0_10 | (~ BATCH_LOOP_stage_v_9))) |
      BATCH_LOOP_stage_v_10 | (~ mux_tmp_107));
  assign nor_177_nl = ~(or_tmp_375 | (~ mux_tmp_107));
  assign and_331_nl = BATCH_LOOP_stage_0_10 & mux_484_cse;
  assign mux_485_nl = MUX_s_1_2_2(nor_177_nl, and_331_nl, BATCH_LOOP_stage_0_11);
  assign mux_486_cse = MUX_s_1_2_2(mux_tmp_107, mux_485_nl, BATCH_LOOP_stage_v_9);
  assign and_332_cse = BATCH_LOOP_stage_0_9 & mux_486_cse;
  assign and_973_cse = BATCH_LOOP_stage_0_9 & nor_176_cse;
  assign and_389_cse = BATCH_LOOP_stage_0_6 & mux_427_cse;
  assign mux_568_cse = MUX_s_1_2_2(mux_tmp_108, and_389_cse, BATCH_LOOP_stage_v_5);
  assign and_390_cse = BATCH_LOOP_stage_0_5 & mux_568_cse;
  assign and_485_cse = or_862_cse & mux_568_cse;
  assign and_397_nl = or_862_cse & mux_298_cse;
  assign mux_581_nl = MUX_s_1_2_2(mux_tmp_254, and_397_nl, BATCH_LOOP_stage_v_4);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      = core_wen & ((or_606_cse & or_tmp_9 & mux_581_nl) | and_dcpl_248);
  assign or_215_nl = (~ dma_read_ctrl_rsci_irdy_mxwt) | STORE_LOOP_equal_tmp_1 |
      STORE_LOOP_equal_tmp_2_1 | exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_nor_tmp_1
      | STORE_LOOP_equal_tmp_1_1 | STORE_LOOP_asn_17_itm_1 | (~ BATCH_LOOP_and_12_tmp);
  assign dma_read_data_index_10_7_sva_mx1 = MUX_v_4_2_2(z_out, dma_read_data_index_10_7_sva,
      or_215_nl);
  assign STORE_CTRL_LOOP_mux_1_nl = MUX_s_1_2_2(STORE_LOOP_mux1h_19_mx0w1, exit_STORE_CTRL_LOOP_lpi_2,
      exit_BATCH_LOOP_lpi_2_dfm_1);
  assign exit_STORE_CTRL_LOOP_lpi_2_mx1 = MUX_s_1_2_2(STORE_CTRL_LOOP_mux_1_nl, exit_STORE_CTRL_LOOP_lpi_2,
      or_tmp_151);
  assign LOAD_LOOP_LOAD_LOOP_and_1_nl = exit_CALC_SOFTMAX_LOOP_lpi_2 & (~ LOAD_LOOP_and_1_svs_mx0w0);
  assign STORE_LOOP_or_19_nl = STORE_LOOP_or_tmp_mx0w0 | STORE_LOOP_equal_tmp_2_mx0w0
      | STORE_LOOP_nor_tmp_mx0w0;
  assign STORE_LOOP_mux1h_18_mx0w1 = MUX1HOT_s_1_3_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_1_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx0w1, {STORE_LOOP_or_19_nl
      , STORE_LOOP_equal_tmp_mx0w0 , STORE_LOOP_equal_tmp_1_mx0w0});
  assign STORE_LOOP_mux_27_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign lfst_exit_STORE_LOOP_lpi_2_2_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_27_nl, lfst_exit_STORE_LOOP_lpi_2_2,
      or_tmp_151);
  assign STORE_LOOP_STORE_LOOP_nor_12_nl = ~(exit_BATCH_LOOP_lpi_2_dfm_1 | or_tmp_151);
  assign STORE_LOOP_and_96_nl = exit_BATCH_LOOP_lpi_2_dfm_1 & (~ or_tmp_151);
  assign lfst_exit_STORE_LOOP_lpi_2_1_0_mx1 = MUX1HOT_v_2_3_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, lfst_exit_STORE_LOOP_lpi_2_1_0, {STORE_LOOP_STORE_LOOP_nor_12_nl
      , STORE_LOOP_and_96_nl , or_tmp_151});
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
  assign STORE_LOOP_i_mux_1_nl = MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      STORE_LOOP_i_7_0_lpi_2_6_0, or_tmp_151);
  assign nl_STORE_LOOP_acc_1_tmp = conv_u2u_7_8(STORE_LOOP_i_mux_1_nl) + 8'b00000001;
  assign STORE_LOOP_acc_1_tmp = nl_STORE_LOOP_acc_1_tmp[7:0];
  assign BATCH_LOOP_if_not_nl = ~ BATCH_LOOP_acc_itm_32_1;
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1 = MUX_v_2_2_2(2'b00, lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
      BATCH_LOOP_if_not_nl);
  assign exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx0w1 = (CALC_SOFTMAX_LOOP_i_7_0_sva_2[7])
      | exit_CALC_SOFTMAX_LOOP_lpi_2;
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1 = lfst_exit_STORE_LOOP_lpi_2_2_mx1
      & (~ BATCH_LOOP_acc_itm_32_1);
  assign STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 = (BATCH_LOOP_acc_3_tmp[4])
      & (STORE_LOOP_acc_1_tmp[7]) & STORE_LOOP_equal_tmp_2_mx0w0;
  assign or_337_nl = (~ BATCH_LOOP_stage_v_3) | STORE_LOOP_asn_17_itm_3;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      or_337_nl);
  assign SUM_EXP_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0, or_tmp_151);
  assign CALC_EXP_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0, or_tmp_151);
  assign LOAD_LOOP_i_7_0_lpi_2_6_0_mx1 = MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0,
      LOAD_LOOP_i_7_0_lpi_2_6_0, or_tmp_151);
  assign or_878_tmp = exit_BATCH_LOOP_lpi_2_dfm_mx0w0 | STORE_LOOP_nor_tmp_mx0w0
      | STORE_LOOP_equal_tmp_2_mx0w0 | STORE_LOOP_or_tmp_mx0w0 | (exit_CALC_SOFTMAX_LOOP_lpi_2
      & STORE_LOOP_and_23_m1c_1) | (STORE_LOOP_equal_tmp_mx0w0 & (~ LOAD_LOOP_and_1_svs_mx0w0));
  assign STORE_LOOP_and_29_tmp = (~ exit_CALC_SOFTMAX_LOOP_lpi_2) & STORE_LOOP_and_23_m1c_1;
  assign nor_230_nl = ~(STORE_LOOP_and_29_tmp | or_878_tmp);
  assign CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2 = MUX1HOT_v_7_3_2((signext_7_1(~
      LOAD_LOOP_and_1_svs_mx0w0)), (CALC_SOFTMAX_LOOP_i_7_0_sva_2[6:0]), CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
      {nor_230_nl , STORE_LOOP_and_29_tmp , or_878_tmp});
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
  assign and_1028_cse = ~(STORE_LOOP_and_9_itm_mx0w0 | or_dcpl_126);
  assign and_1029_cse = STORE_LOOP_and_9_itm_mx0w0 & (~ or_dcpl_126);
  assign LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~ dma_read_ctrl_rsci_irdy_mxwt)),
      LOAD_LOOP_i_7_0_sva_1_1_6_0, LOAD_LOOP_i_7_0_lpi_2_6_0, {and_1028_cse , and_1029_cse
      , or_dcpl_126});
  assign CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), CALC_EXP_LOOP_i_7_0_sva_1_1_6_0, CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
      {and_1028_cse , and_1029_cse , or_dcpl_126});
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0
      = MUX1HOT_v_74_3_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      {STORE_LOOP_and_8_itm_2 , STORE_LOOP_and_9_itm_2 , STORE_LOOP_or_25_itm_2});
  assign SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_read_ctrl_rsci_irdy_mxwt)), SUM_EXP_LOOP_i_7_0_sva_1_1_6_0, SUM_EXP_LOOP_i_7_0_lpi_2_6_0,
      {and_1028_cse , and_1029_cse , or_dcpl_126});
  assign LOAD_LOOP_LOAD_LOOP_and_2_nl = exit_STORE_CTRL_LOOP_lpi_2 & (~ reg_LOAD_LOOP_and_1_svs_1_cse);
  assign STORE_LOOP_or_20_nl = STORE_LOOP_or_tmp_1 | STORE_LOOP_equal_tmp_2_1 | STORE_LOOP_nor_tmp_1;
  assign STORE_LOOP_mux1h_19_mx0w1 = MUX1HOT_s_1_3_2(exit_STORE_CTRL_LOOP_lpi_2,
      LOAD_LOOP_LOAD_LOOP_and_2_nl, exit_STORE_CTRL_LOOP_lpi_2_dfm_4, {STORE_LOOP_or_20_nl
      , STORE_LOOP_equal_tmp_1 , STORE_LOOP_equal_tmp_1_1});
  assign and_1023_cse = (~ CALC_SOFTMAX_LOOP_and_svs_1) & STORE_LOOP_equal_tmp_1_1;
  assign or_883_tmp = STORE_LOOP_or_tmp_1 | STORE_LOOP_nor_tmp_1 | STORE_LOOP_equal_tmp_1
      | and_1023_cse | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign STORE_LOOP_and_26_tmp = STORE_LOOP_equal_tmp_2_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_231_nl = ~(STORE_LOOP_and_26_tmp | or_883_tmp);
  assign and_1025_nl = STORE_LOOP_and_26_tmp & (~ or_883_tmp);
  assign STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      CALC_SOFTMAX_LOOP_and_svs_1)), (STORE_LOOP_i_7_0_sva_1_1[6:0]), STORE_LOOP_i_7_0_lpi_2_6_0,
      {nor_231_nl , and_1025_nl , or_883_tmp});
  assign STORE_LOOP_STORE_LOOP_nor_nl = ~(lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 |
      (lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1!=2'b00));
  assign STORE_LOOP_mux_39_nl = MUX_s_1_2_2(STORE_LOOP_STORE_LOOP_nor_nl, exitL_exit_STORE_LOOP_sva,
      STORE_LOOP_STORE_LOOP_and_9_itm_1);
  assign or_573_nl = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_asn_17_itm_1 | (~ BATCH_LOOP_and_12_tmp);
  assign exitL_exit_STORE_LOOP_sva_mx1 = MUX_s_1_2_2(STORE_LOOP_mux_39_nl, exitL_exit_STORE_LOOP_sva,
      or_573_nl);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      + conv_u2u_67_74(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[73:0];
  assign STORE_LOOP_and_8_itm_mx0w0 = STORE_LOOP_or_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign STORE_LOOP_and_9_itm_mx0w0 = STORE_LOOP_equal_tmp_1 & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
  assign STORE_LOOP_or_25_itm_mx0w0 = STORE_LOOP_equal_tmp_1_1 | STORE_LOOP_equal_tmp_2_1
      | STORE_LOOP_nor_tmp_1 | exit_BATCH_LOOP_lpi_2_dfm_1;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1,
      94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3);
  assign nl_BATCH_LOOP_acc_3_tmp = conv_u2u_4_5(BATCH_LOOP_b_4_0_sva_3_0) + 5'b00001;
  assign BATCH_LOOP_acc_3_tmp = nl_BATCH_LOOP_acc_3_tmp[4:0];
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0 = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_2_mx1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1, mux_tmp_240);
  assign nl_BATCH_LOOP_acc_nl = ({29'b10000000000000000000000000000 , BATCH_LOOP_b_4_0_sva_3_0})
      + conv_u2u_32_33(~ conf_info_batch_sva) + 33'b000000000000000000000000000000001;
  assign BATCH_LOOP_acc_nl = nl_BATCH_LOOP_acc_nl[32:0];
  assign BATCH_LOOP_acc_itm_32_1 = readslicef_33_1_32(BATCH_LOOP_acc_nl);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0 = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_1_0_mx1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1, mux_tmp_240);
  assign CALC_SOFTMAX_LOOP_and_svs_1 = exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  assign STORE_LOOP_mux_62_nl = MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2, and_970_cse);
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1 = (STORE_LOOP_mux_62_nl & (~(STORE_LOOP_or_tmp_1
      | STORE_LOOP_and_5_ssc_1))) | STORE_LOOP_and_7_ssc_1;
  assign STORE_LOOP_and_47_nl = (~ dma_read_ctrl_rsci_irdy_mxwt) & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_and_48_nl = dma_read_ctrl_rsci_irdy_mxwt & STORE_LOOP_or_tmp_1;
  assign STORE_LOOP_or_24_nl = ((~ reg_LOAD_LOOP_and_1_svs_1_cse) & STORE_LOOP_equal_tmp_1)
      | and_1023_cse | ((~ (STORE_LOOP_i_7_0_sva_1_1[7])) & STORE_LOOP_equal_tmp_2_1)
      | STORE_LOOP_nor_tmp_1;
  assign STORE_LOOP_mux1h_48_tmp = MUX1HOT_v_2_3_2(2'b01, 2'b10, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
      {STORE_LOOP_and_47_nl , STORE_LOOP_and_48_nl , STORE_LOOP_or_24_nl});
  assign STORE_LOOP_and_nl = STORE_LOOP_mux1h_48_tmp & (signext_2_1(~ and_970_cse))
      & (signext_2_1(~ STORE_LOOP_and_7_ssc_1));
  assign lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1 = MUX_v_2_2_2(STORE_LOOP_and_nl,
      2'b11, STORE_LOOP_and_5_ssc_1);
  assign exit_STORE_CTRL_LOOP_lpi_2_dfm_4 = dma_write_ctrl_rsci_irdy_mxwt | exit_STORE_CTRL_LOOP_lpi_2;
  assign STORE_LOOP_and_5_ssc_1 = reg_LOAD_LOOP_and_1_svs_1_cse & STORE_LOOP_equal_tmp_1;
  assign STORE_LOOP_and_7_ssc_1 = CALC_SOFTMAX_LOOP_and_svs_1 & STORE_LOOP_equal_tmp_1_1;
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
  assign STORE_LOOP_and_23_m1c_1 = STORE_LOOP_equal_tmp_1_mx0w0 & (~ exit_BATCH_LOOP_lpi_2_dfm_mx0w0);
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = $signed((dma_read_chnl_rsci_idat_mxwt)) * $signed(16'b0101110001010101);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl[46:0];
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28
      = readslicef_47_19_28(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl);
  assign BATCH_LOOP_nor_13_tmp = ~((~(BATCH_LOOP_stage_v_12 & BATCH_LOOP_BATCH_LOOP_or_cse_1))
      | (BATCH_LOOP_stage_0 & (mux_223_cse | (~ BATCH_LOOP_and_13_tmp))) | BATCH_LOOP_stage_0_1
      | BATCH_LOOP_stage_0_2 | BATCH_LOOP_stage_0_3 | BATCH_LOOP_stage_0_4 | BATCH_LOOP_stage_0_5
      | BATCH_LOOP_stage_0_6 | BATCH_LOOP_stage_0_7 | BATCH_LOOP_stage_0_8 | BATCH_LOOP_stage_0_9
      | BATCH_LOOP_stage_0_10 | BATCH_LOOP_stage_0_11 | BATCH_LOOP_stage_0_12);
  assign BATCH_LOOP_and_13_tmp = BATCH_LOOP_stage_v & (~(BATCH_LOOP_stage_v_1 & (~
      BATCH_LOOP_and_12_tmp))) & BATCH_LOOP_stage_0_1 & BATCH_LOOP_BATCH_LOOP_or_21_cse_1
      & BATCH_LOOP_BATCH_LOOP_or_6_cse_1 & BATCH_LOOP_BATCH_LOOP_or_4_cse_1 & BATCH_LOOP_BATCH_LOOP_or_cse_1;
  assign STORE_LOOP_mux_28_tmp = MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1,
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign BATCH_LOOP_and_12_tmp = BATCH_LOOP_stage_v_1 & (~(BATCH_LOOP_stage_v_2 &
      (not_tmp_183 | or_dcpl_81))) & BATCH_LOOP_stage_0_2 & (dma_read_ctrl_rsci_bawt
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
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]);
  assign or_12_cse = (~ BATCH_LOOP_stage_v_11) | CALC_SOFTMAX_LOOP_asn_itm_11 | exit_BATCH_LOOP_lpi_2_dfm_st_11
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2
      | plm_out_data_rsci_bawt;
  assign and_tmp = or_12_cse & or_tmp_9;
  assign nor_229_cse = ~(BATCH_LOOP_stage_v_11 | (~ or_tmp_9));
  assign or_20_cse = plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_11 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 | exit_BATCH_LOOP_lpi_2_dfm_st_11;
  assign and_tmp_3 = or_20_cse & or_tmp_9;
  assign and_18_nl = BATCH_LOOP_stage_0_12 & and_tmp_3;
  assign mux_31_cse = MUX_s_1_2_2(or_tmp_9, and_18_nl, BATCH_LOOP_stage_v_11);
  assign not_tmp_29 = ~(BATCH_LOOP_stage_0_10 & BATCH_LOOP_stage_v_9);
  assign and_1009_cse = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_0_9;
  assign and_997_cse = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_0_8;
  assign and_tmp_21 = ((~ BATCH_LOOP_stage_v_10) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2 | CALC_SOFTMAX_LOOP_asn_itm_10 |
      exit_BATCH_LOOP_lpi_2_dfm_st_10 | CALC_SOFTMAX_LOOP_mul_cmp_bawt) & and_tmp;
  assign and_1006_cse = BATCH_LOOP_stage_v_6 & BATCH_LOOP_stage_0_7;
  assign and_1003_cse = BATCH_LOOP_stage_v_5 & BATCH_LOOP_stage_0_6;
  assign and_dcpl_35 = (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1])) & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2
      & (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]));
  assign and_dcpl_36 = and_dcpl_35 & (~ exit_BATCH_LOOP_lpi_2_dfm_st_12) & dma_write_chnl_rsci_bawt
      & BATCH_LOOP_stage_v_12;
  assign or_dcpl_14 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b00)
      | exit_BATCH_LOOP_lpi_2_dfm_st_11 | (~ BATCH_LOOP_stage_0_12) | (~ BATCH_LOOP_stage_v_11);
  assign or_dcpl_32 = ~(BATCH_LOOP_stage_0_6 & BATCH_LOOP_stage_v_5);
  assign or_tmp_135 = BATCH_LOOP_stage_v_11 | (~ or_tmp_9);
  assign mux_tmp_107 = MUX_s_1_2_2((~ or_tmp_135), or_tmp_9, or_20_cse);
  assign or_tmp_136 = BATCH_LOOP_stage_v_10 | (~ mux_tmp_107);
  assign mux_tmp_108 = MUX_s_1_2_2((~ or_tmp_136), mux_tmp_107, or_472_cse);
  assign or_dcpl_37 = ~(BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3);
  assign and_125_cse = BATCH_LOOP_stage_0_5 & or_862_cse & mux_568_cse;
  assign mux_144_cse = MUX_s_1_2_2(mux_tmp_108, and_125_cse, BATCH_LOOP_stage_v_4);
  assign or_dcpl_44 = or_dcpl_37 | exit_BATCH_LOOP_lpi_2_dfm_st_3 | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1]));
  assign and_tmp_56 = or_472_cse & mux_31_cse;
  assign or_tmp_151 = (~ BATCH_LOOP_and_12_tmp) | STORE_LOOP_asn_17_itm_1;
  assign or_tmp_152 = (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_2
      | exitL_exit_STORE_LOOP_sva;
  assign or_tmp_153 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) | exitL_exit_STORE_LOOP_sva
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign or_tmp_154 = exitL_exit_STORE_LOOP_sva | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign or_tmp_157 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2) | STORE_LOOP_or_tmp_1;
  assign or_tmp_159 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2) | STORE_LOOP_or_tmp_1;
  assign or_tmp_160 = or_tmp_159 | STORE_LOOP_and_5_ssc_1;
  assign or_223_nl = or_tmp_157 | STORE_LOOP_and_5_ssc_1;
  assign mux_tmp_136 = MUX_s_1_2_2(or_tmp_160, or_223_nl, and_970_cse);
  assign mux_153_nl = MUX_s_1_2_2(STORE_LOOP_and_5_ssc_1, or_tmp_160, or_245_cse);
  assign mux_154_nl = MUX_s_1_2_2(mux_153_nl, STORE_LOOP_and_5_ssc_1, and_970_cse);
  assign or_226_nl = exitL_exit_STORE_LOOP_sva | (~ mux_tmp_136);
  assign mux_155_nl = MUX_s_1_2_2((~ mux_154_nl), or_226_nl, STORE_LOOP_STORE_LOOP_and_9_itm_1);
  assign mux_tmp_140 = MUX_s_1_2_2(mux_155_nl, or_tmp_154, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_tmp_141 = MUX_s_1_2_2(mux_tmp_140, or_tmp_153, STORE_LOOP_equal_tmp_1_1);
  assign nor_tmp_39 = dma_write_ctrl_rsci_irdy_mxwt & STORE_LOOP_equal_tmp_1_1;
  assign mux_159_nl = MUX_s_1_2_2(mux_tmp_140, or_tmp_153, nor_tmp_39);
  assign mux_620_itm = MUX_s_1_2_2(mux_159_nl, mux_tmp_141, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_161_nl = MUX_s_1_2_2(mux_620_itm, mux_tmp_141, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_162_nl = MUX_s_1_2_2(mux_tmp_140, mux_161_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_163_nl = MUX_s_1_2_2(mux_162_nl, mux_tmp_141, or_1_cse);
  assign mux_164_itm = MUX_s_1_2_2(mux_163_nl, or_tmp_154, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign and_dcpl_42 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp;
  assign and_dcpl_45 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b10)
      & and_dcpl_42;
  assign mux_175_nl = MUX_s_1_2_2(nor_tmp_39, STORE_LOOP_equal_tmp_1_1, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_176_nl = MUX_s_1_2_2(mux_175_nl, STORE_LOOP_equal_tmp_1_1, exit_STORE_CTRL_LOOP_lpi_2);
  assign and_137_nl = exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & mux_176_nl;
  assign mux_tmp_161 = MUX_s_1_2_2(and_137_nl, STORE_LOOP_equal_tmp_1_1, or_1_cse);
  assign nand_tmp_27 = ~(or_tmp_157 & (~ mux_tmp_161));
  assign nor_tmp_47 = ~(STORE_LOOP_or_tmp_1 | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2));
  assign or_tmp_171 = nor_tmp_47 | mux_tmp_161;
  assign mux_tmp_162 = MUX_s_1_2_2(or_tmp_171, nand_tmp_27, and_970_cse);
  assign mux_tmp_164 = MUX_s_1_2_2(mux_tmp_162, mux_tmp_161, STORE_LOOP_and_5_ssc_1);
  assign or_tmp_194 = STORE_LOOP_or_tmp_1 | (~ STORE_LOOP_and_5_ssc_1);
  assign or_tmp_195 = STORE_LOOP_or_tmp_1 | (~(reg_LOAD_LOOP_and_1_svs_1_cse | (~
      STORE_LOOP_equal_tmp_1)));
  assign or_266_nl = nor_125_cse | lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2;
  assign mux_195_nl = MUX_s_1_2_2(or_tmp_195, or_tmp_194, or_266_nl);
  assign or_267_nl = STORE_LOOP_equal_tmp_2_1 | mux_195_nl;
  assign mux_194_nl = MUX_s_1_2_2(or_tmp_195, or_tmp_194, lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign or_264_nl = exitL_exit_STORE_LOOP_sva | STORE_LOOP_equal_tmp_2_1 | mux_194_nl;
  assign mux_196_nl = MUX_s_1_2_2(or_267_nl, or_264_nl, STORE_LOOP_STORE_LOOP_and_9_itm_1);
  assign or_270_cse = STORE_LOOP_equal_tmp_1_1 | STORE_LOOP_nor_tmp_1 | exit_BATCH_LOOP_lpi_2_dfm_1
      | mux_196_nl;
  assign mux_198_nl = MUX_s_1_2_2(mux_620_itm, or_270_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_197_nl = MUX_s_1_2_2(mux_tmp_141, or_270_cse, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_199_nl = MUX_s_1_2_2(mux_198_nl, mux_197_nl, or_1_cse);
  assign or_nl = or_tmp_154 | exit_STORE_CTRL_LOOP_lpi_2;
  assign mux_200_nl = MUX_s_1_2_2(mux_199_nl, or_nl, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nand_31_nl = ~((STORE_LOOP_mux_28_tmp==2'b11) & (~ mux_200_nl));
  assign or_250_nl = exit_STORE_CTRL_LOOP_lpi_2 | (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b11)
      | lfst_exit_STORE_LOOP_lpi_2_2 | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_185 = MUX_s_1_2_2(nand_31_nl, or_250_nl, or_tmp_151);
  assign or_tmp_206 = (~ exitL_exit_STORE_LOOP_sva) | BATCH_LOOP_acc_itm_32_1;
  assign or_tmp_208 = exit_BATCH_LOOP_lpi_2_dfm_1 | STORE_LOOP_STORE_LOOP_and_9_itm_1;
  assign and_tmp_62 = STORE_LOOP_equal_tmp_1_1 & exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1
      & exit_STORE_CTRL_LOOP_lpi_2_dfm_4;
  assign nand_tmp_32 = ~(or_tmp_157 & (~ and_tmp_62));
  assign or_tmp_214 = nor_tmp_47 | and_tmp_62;
  assign or_287_nl = (STORE_LOOP_mux1h_48_tmp!=2'b00) | or_tmp_214;
  assign mux_207_nl = MUX_s_1_2_2(or_287_nl, nand_tmp_32, and_970_cse);
  assign or_tmp_217 = BATCH_LOOP_acc_itm_32_1 | STORE_LOOP_and_5_ssc_1 | mux_207_nl;
  assign mux_211_nl = MUX_s_1_2_2(or_tmp_214, nand_tmp_32, and_970_cse);
  assign mux_tmp_197 = MUX_s_1_2_2(mux_211_nl, and_tmp_62, STORE_LOOP_and_5_ssc_1);
  assign and_990_nl = exitL_exit_STORE_LOOP_sva & BATCH_LOOP_acc_itm_32_1;
  assign nor_55_nl = ~((lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b00) | (~ lfst_exit_STORE_LOOP_lpi_2_2));
  assign mux_204_nl = MUX_s_1_2_2(or_tmp_206, and_990_nl, nor_55_nl);
  assign mux_221_nl = MUX_s_1_2_2(mux_355_cse, mux_204_nl, or_tmp_151);
  assign mux_223_cse = MUX_s_1_2_2(mux_357_cse, mux_221_nl, and_967_cse);
  assign nor_tmp_74 = or_tmp_208 & exitL_exit_STORE_LOOP_sva;
  assign nor_189_nl = ~((STORE_LOOP_mux1h_48_tmp!=2'b00) | (~(or_tmp_159 & (~ STORE_LOOP_and_5_ssc_1))));
  assign and_978_nl = or_tmp_157 & (~ STORE_LOOP_and_5_ssc_1);
  assign mux_246_nl = MUX_s_1_2_2(nor_189_nl, and_978_nl, and_970_cse);
  assign mux_tmp_231 = MUX_s_1_2_2(mux_246_nl, exitL_exit_STORE_LOOP_sva, or_tmp_208);
  assign mux_tmp_232 = MUX_s_1_2_2(mux_tmp_231, nor_tmp_74, STORE_LOOP_equal_tmp_1_1);
  assign mux_250_nl = MUX_s_1_2_2(mux_tmp_231, nor_tmp_74, nor_tmp_39);
  assign mux_251_nl = MUX_s_1_2_2(mux_250_nl, mux_tmp_232, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_252_nl = MUX_s_1_2_2(mux_251_nl, mux_tmp_232, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_253_nl = MUX_s_1_2_2(mux_tmp_231, mux_252_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_254_nl = MUX_s_1_2_2(mux_253_nl, mux_tmp_232, or_1_cse);
  assign mux_255_nl = MUX_s_1_2_2(mux_254_nl, exitL_exit_STORE_LOOP_sva, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_tmp_240 = MUX_s_1_2_2(mux_255_nl, exitL_exit_STORE_LOOP_sva, or_tmp_151);
  assign nand_38_nl = ~((STORE_LOOP_mux_28_tmp==2'b11) & (~ mux_164_itm));
  assign or_326_nl = (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_2
      | exitL_exit_STORE_LOOP_sva;
  assign mux_tmp_241 = MUX_s_1_2_2(nand_38_nl, or_326_nl, or_tmp_151);
  assign and_dcpl_58 = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_v_3;
  assign or_dcpl_81 = ~(BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2);
  assign or_tmp_264 = BATCH_LOOP_stage_v_10 | (~ or_12_cse);
  assign mux_tmp_254 = MUX_s_1_2_2((~ or_tmp_264), or_12_cse, or_472_cse);
  assign not_tmp_182 = ~(BATCH_LOOP_stage_v_3 | (~ mux_tmp_254));
  assign mux_287_nl = MUX_s_1_2_2(not_tmp_182, mux_tmp_254, BATCH_LOOP_stage_0_4);
  assign mux_275_nl = MUX_s_1_2_2(mux_tmp_254, mux_293_cse, BATCH_LOOP_stage_v_3);
  assign mux_276_nl = MUX_s_1_2_2(not_tmp_182, mux_275_nl, BATCH_LOOP_stage_0_10);
  assign mux_277_nl = MUX_s_1_2_2(mux_tmp_254, mux_276_nl, BATCH_LOOP_stage_v_9);
  assign mux_278_nl = MUX_s_1_2_2(not_tmp_182, mux_277_nl, BATCH_LOOP_stage_0_9);
  assign mux_279_nl = MUX_s_1_2_2(mux_tmp_254, mux_278_nl, BATCH_LOOP_stage_v_8);
  assign mux_280_nl = MUX_s_1_2_2(not_tmp_182, mux_279_nl, BATCH_LOOP_stage_0_8);
  assign mux_281_nl = MUX_s_1_2_2(mux_tmp_254, mux_280_nl, BATCH_LOOP_stage_v_7);
  assign mux_282_nl = MUX_s_1_2_2(not_tmp_182, mux_281_nl, BATCH_LOOP_stage_0_7);
  assign mux_283_nl = MUX_s_1_2_2(mux_tmp_254, mux_282_nl, BATCH_LOOP_stage_v_6);
  assign mux_284_nl = MUX_s_1_2_2(not_tmp_182, mux_283_nl, BATCH_LOOP_stage_0_6);
  assign mux_285_nl = MUX_s_1_2_2(mux_tmp_254, mux_284_nl, BATCH_LOOP_stage_v_5);
  assign and_1016_nl = BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_0_5;
  assign mux_286_nl = MUX_s_1_2_2(not_tmp_182, mux_285_nl, and_1016_nl);
  assign and_163_nl = or_862_cse & mux_286_nl;
  assign mux_288_cse = MUX_s_1_2_2(mux_287_nl, and_163_nl, BATCH_LOOP_stage_v_4);
  assign not_tmp_183 = ~(or_tmp_9 & mux_288_cse);
  assign or_dcpl_101 = (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[1]);
  assign and_dcpl_69 = BATCH_LOOP_stage_0_5 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[1])
      & (~(lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 | exit_BATCH_LOOP_lpi_2_dfm_st_4));
  assign and_dcpl_130 = BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_v_2;
  assign and_tmp_96 = or_tmp_9 & mux_288_cse;
  assign and_dcpl_136 = and_tmp_96 & and_dcpl_130;
  assign and_271_cse = and_dcpl_130 & mux_tmp_108;
  assign nor_185_nl = ~((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[1]) | (~ and_tmp_21));
  assign or_448_nl = (~ BATCH_LOOP_stage_v_4) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_bawt
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0[0]) | exit_BATCH_LOOP_lpi_2_dfm_st_4
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2;
  assign mux_tmp_378 = MUX_s_1_2_2(nor_185_nl, and_tmp_21, or_448_nl);
  assign and_dcpl_137 = BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_v_4;
  assign or_tmp_375 = (~ BATCH_LOOP_stage_0_10) | BATCH_LOOP_stage_v_10;
  assign mux_444_cse = MUX_s_1_2_2(mux_tmp_107, and_332_cse, BATCH_LOOP_stage_v_8);
  assign nand_45_nl = ~(BATCH_LOOP_stage_0_9 & nor_176_cse);
  assign mux_446_nl = MUX_s_1_2_2(or_tmp_136, nand_45_nl, BATCH_LOOP_stage_v_8);
  assign nand_46_nl = ~(BATCH_LOOP_stage_0_8 & (~ mux_446_nl));
  assign mux_447_nl = MUX_s_1_2_2(or_tmp_136, nand_46_nl, BATCH_LOOP_stage_v_7);
  assign and_309_nl = BATCH_LOOP_stage_0_8 & mux_444_cse;
  assign mux_445_nl = MUX_s_1_2_2(mux_tmp_107, and_309_nl, BATCH_LOOP_stage_v_7);
  assign mux_tmp_432 = MUX_s_1_2_2((~ mux_447_nl), mux_445_nl, or_472_cse);
  assign nor_180_nl = ~(BATCH_LOOP_stage_v_10 | (~ mux_tmp_107));
  assign mux_465_nl = MUX_s_1_2_2(nor_180_nl, and_973_cse, BATCH_LOOP_stage_v_8);
  assign mux_tmp_450 = MUX_s_1_2_2(mux_465_nl, mux_444_cse, or_472_cse);
  assign mux_tmp_465 = MUX_s_1_2_2(nor_176_cse, mux_486_cse, or_472_cse);
  assign and_tmp_148 = BATCH_LOOP_stage_v_7 & BATCH_LOOP_stage_0_8 & mux_tmp_107;
  assign or_tmp_431 = or_tmp_375 | (~ mux_tmp_107);
  assign and_tmp_151 = BATCH_LOOP_stage_v_8 & BATCH_LOOP_stage_0_9 & mux_tmp_107;
  assign and_dcpl_160 = BATCH_LOOP_stage_0_11 & BATCH_LOOP_stage_v_10;
  assign and_dcpl_164 = BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11;
  assign or_tmp_443 = dma_write_chnl_rsci_bawt | exit_BATCH_LOOP_lpi_2_dfm_st_12
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[0]) | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2)
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0[1]);
  assign or_tmp_449 = exitL_exit_STORE_LOOP_sva | (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2);
  assign or_567_nl = and_998_cse | mux_tmp_136;
  assign mux_tmp_494 = MUX_s_1_2_2(or_567_nl, or_tmp_449, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_508_nl = MUX_s_1_2_2(and_998_cse, or_tmp_449, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign mux_tmp_495 = MUX_s_1_2_2(mux_tmp_494, mux_508_nl, STORE_LOOP_equal_tmp_1_1);
  assign or_606_cse = (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign mux_605_nl = MUX_s_1_2_2(mux_tmp_108, and_485_cse, BATCH_LOOP_stage_v_4);
  assign and_dcpl_248 = mux_605_nl & (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1==74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign or_tmp_509 = or_tmp_9 & lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0==2'b00)
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_11) & BATCH_LOOP_stage_0_12 & BATCH_LOOP_stage_v_11
      & (fsm_output[2]);
  assign or_tmp_510 = or_dcpl_14 & and_dcpl_36 & (fsm_output[2]);
  assign or_tmp_516 = ~((fsm_output[2]) & mux_31_cse & BATCH_LOOP_stage_0_11 & CALC_SOFTMAX_LOOP_mul_cmp_bawt
      & (~ exit_BATCH_LOOP_lpi_2_dfm_st_10) & (~ CALC_SOFTMAX_LOOP_asn_itm_10) &
      (~ lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_2) & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_10_1_0==2'b11)
      & BATCH_LOOP_stage_v_10);
  assign or_tmp_522 = (~ (fsm_output[2])) | (~ mux_144_cse) | or_dcpl_37 | exit_BATCH_LOOP_lpi_2_dfm_st_3
      | (~ (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[1])) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_2
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_3_1_0[0]);
  assign or_864_nl = (STORE_LOOP_mux_28_tmp!=2'b10) | mux_tmp_141;
  assign mux_166_nl = MUX_s_1_2_2(or_864_nl, or_tmp_152, STORE_LOOP_asn_17_itm_1);
  assign or_tmp_543 = (mux_166_nl | (~ BATCH_LOOP_and_13_tmp)) & and_dcpl_45 & (fsm_output[2]);
  assign or_tmp_560 = mux_223_cse & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_579 = (~ mux_tmp_240) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_582 = mux_tmp_241 & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign or_tmp_632 = (mux_tmp_241 | exit_CALC_SOFTMAX_LOOP_lpi_2) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign or_tmp_663 = (~ exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  assign or_tmp_704 = (~ mux_223_cse) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1 = (~ STORE_LOOP_asn_17_itm_1) & BATCH_LOOP_and_12_tmp
      & (fsm_output[2]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1
      = mux_144_cse & and_dcpl_58 & (~ STORE_LOOP_asn_17_itm_3) & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1
      = mux_427_cse & and_1003_cse & (~ STORE_LOOP_and_32_itm_4) & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_mx0c1 = (~(mux_223_cse & BATCH_LOOP_stage_0)) & BATCH_LOOP_and_13_tmp
      & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_2_mx0c1 = BATCH_LOOP_and_12_tmp & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_3_mx0c1 = and_dcpl_136 & (fsm_output[2]);
  assign BATCH_LOOP_stage_v_4_mx0c1 = mux_144_cse & and_dcpl_58 & (fsm_output[2]);
  assign mux_513_nl = MUX_s_1_2_2(mux_tmp_494, and_998_cse, nor_tmp_39);
  assign mux_514_nl = MUX_s_1_2_2(mux_513_nl, mux_tmp_495, CALC_SOFTMAX_LOOP_asn_3_itm_1);
  assign mux_515_nl = MUX_s_1_2_2(mux_514_nl, mux_tmp_495, exit_STORE_CTRL_LOOP_lpi_2);
  assign mux_516_nl = MUX_s_1_2_2(mux_tmp_494, mux_515_nl, exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1);
  assign mux_517_nl = MUX_s_1_2_2(mux_516_nl, mux_tmp_495, or_1_cse);
  assign mux_518_nl = MUX_s_1_2_2(mux_517_nl, or_tmp_449, exit_BATCH_LOOP_lpi_2_dfm_1);
  assign nor_233_nl = ~((STORE_LOOP_mux_28_tmp!=2'b00) | mux_518_nl);
  assign nor_234_nl = ~((lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b00) | (~ lfst_exit_STORE_LOOP_lpi_2_2)
      | exitL_exit_STORE_LOOP_sva);
  assign mux_519_nl = MUX_s_1_2_2(nor_233_nl, nor_234_nl, or_tmp_151);
  assign BATCH_LOOP_b_4_0_sva_3_0_mx0c1 = mux_519_nl & (STORE_LOOP_acc_1_tmp[7])
      & (~ (BATCH_LOOP_acc_3_tmp[4])) & BATCH_LOOP_and_13_tmp & (fsm_output[2]);
  assign BATCH_LOOP_stage_0_3_mx0c1 = (and_dcpl_136 | BATCH_LOOP_and_12_tmp) & (fsm_output[2]);
  assign nor_196_nl = ~(BATCH_LOOP_stage_v_4 | (~ and_271_cse));
  assign nor_197_nl = ~((~ BATCH_LOOP_stage_0_4) | BATCH_LOOP_stage_v_4 | (~ mux_tmp_108));
  assign mux_392_nl = MUX_s_1_2_2(nor_196_nl, nor_197_nl, BATCH_LOOP_stage_v_3);
  assign mux_390_nl = MUX_s_1_2_2(mux_tmp_108, and_390_cse, BATCH_LOOP_stage_v_4);
  assign and_270_nl = BATCH_LOOP_stage_0_4 & mux_390_nl;
  assign mux_391_nl = MUX_s_1_2_2(and_271_cse, and_270_nl, BATCH_LOOP_stage_v_3);
  assign mux_393_nl = MUX_s_1_2_2(mux_392_nl, mux_391_nl, or_862_cse);
  assign BATCH_LOOP_stage_0_4_mx0c1 = mux_393_nl & (fsm_output[2]);
  assign and_377_nl = and_dcpl_58 & mux_tmp_108;
  assign mux_546_nl = MUX_s_1_2_2(and_377_nl, and_125_cse, BATCH_LOOP_stage_v_4);
  assign BATCH_LOOP_stage_0_5_mx0c1 = mux_546_nl & (fsm_output[2]);
  assign and_383_nl = or_862_cse & BATCH_LOOP_stage_v_4 & BATCH_LOOP_stage_0_5 &
      mux_tmp_108;
  assign mux_557_nl = MUX_s_1_2_2(and_383_nl, and_389_cse, BATCH_LOOP_stage_v_5);
  assign BATCH_LOOP_stage_0_6_mx0c1 = mux_557_nl & (fsm_output[2]);
  assign CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1 = (exit_BATCH_LOOP_lpi_2_dfm_1
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2)
      & BATCH_LOOP_and_12_tmp;
  assign STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1 = (or_dcpl_101 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
      | exit_BATCH_LOOP_lpi_2_dfm_1) & BATCH_LOOP_and_12_tmp;
  assign plm_out_data_rsci_d_d = CALC_SOFTMAX_LOOP_mux_1_rmff;
  assign plm_out_data_rsci_radr_d = STORE_LOOP_i_mux_rmff;
  assign plm_out_data_rsci_wadr_d = CALC_SOFTMAX_LOOP_i_mux_rmff;
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d
      = operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d
      = CALC_SOFTMAX_LOOP_i_mux_1_rmff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d
      = CALC_EXP_LOOP_i_mux_rmff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign or_dcpl_126 = (STORE_LOOP_and_8_itm_mx0w0 & (~ dma_read_ctrl_rsci_irdy_mxwt))
      | STORE_LOOP_or_25_itm_mx0w0;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_chnl_rsci_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & (or_tmp_509 | or_tmp_510) ) begin
      reg_dma_write_chnl_rsci_iswt0_cse <= ~ or_tmp_510;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | (and_dcpl_35 & (~(exit_BATCH_LOOP_lpi_2_dfm_st_12
        | dma_write_chnl_rsci_bawt)) & BATCH_LOOP_stage_v_12) | or_dcpl_14)) ) begin
      dma_write_chnl_rsci_idat_31_0 <= plm_out_data_rsci_q_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_data_rsci_d_d_reg <= 32'b00000000000000000000000000000000;
      plm_out_data_rsci_wadr_d_reg <= 7'b0000000;
      plm_out_data_rsci_radr_d_reg <= 7'b0000000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg
          <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg
          <= 7'b0000000;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg
          <= 7'b0000000;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse <= 1'b0;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= 1'b0;
      reg_conf_done_rsc_triosy_obj_ld_core_psct_cse <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse
          <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse
          <= 1'b0;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= 1'b0;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
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
      plm_out_data_rsci_d_d_reg <= CALC_SOFTMAX_LOOP_mux_1_rmff;
      plm_out_data_rsci_wadr_d_reg <= CALC_SOFTMAX_LOOP_i_mux_rmff;
      plm_out_data_rsci_radr_d_reg <= STORE_LOOP_i_mux_rmff;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d_reg
          <= operator_67_47_false_AC_TRN_AC_WRAP_mux_rmff;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d_reg
          <= CALC_EXP_LOOP_i_mux_rmff;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_reg
          <= CALC_SOFTMAX_LOOP_i_mux_1_rmff;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_iswt5_cse <= and_777_rmff;
      reg_CALC_SOFTMAX_LOOP_mul_cmp_oswt_cse <= and_779_rmff;
      reg_conf_done_rsc_triosy_obj_ld_core_psct_cse <= BATCH_LOOP_nor_13_tmp & (fsm_output[2]);
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse
          <= and_783_rmff;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse
          <= and_785_rmff;
      reg_plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= and_789_rmff;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= (~ mux_tmp_185) & BATCH_LOOP_and_13_tmp
          & (fsm_output[2]);
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= mux_191_cse & BATCH_LOOP_and_13_tmp
          & (fsm_output[2]);
      BATCH_LOOP_stage_v_5 <= ((BATCH_LOOP_stage_v_5 & (~((~(or_862_cse & BATCH_LOOP_stage_v_4
          & BATCH_LOOP_stage_0_5)) & mux_427_cse & and_1003_cse))) | (and_485_cse
          & and_dcpl_137)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_6 <= ((BATCH_LOOP_stage_v_6 & (~(mux_tmp_432 & and_1006_cse
          & or_dcpl_32))) | (mux_427_cse & and_1003_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_7 <= ((BATCH_LOOP_stage_v_7 & (~(mux_tmp_450 & and_997_cse
          & (~(BATCH_LOOP_stage_0_7 & BATCH_LOOP_stage_v_6))))) | (mux_tmp_432 &
          and_1006_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_8 <= ((BATCH_LOOP_stage_v_8 & (~(mux_tmp_465 & and_1009_cse
          & (~(BATCH_LOOP_stage_0_8 & BATCH_LOOP_stage_v_7))))) | (mux_tmp_450 &
          and_997_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_9 <= ((BATCH_LOOP_stage_v_9 & (~(mux_147_cse & and_1001_cse
          & (~(BATCH_LOOP_stage_0_9 & BATCH_LOOP_stage_v_8))))) | (mux_tmp_465 &
          and_1009_cse)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_10 <= ((BATCH_LOOP_stage_v_10 & (~(and_tmp_56 & and_dcpl_160
          & not_tmp_29))) | (mux_147_cse & and_1001_cse)) & (fsm_output[2]);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9, and_tmp_21);
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9 <= MUX_v_7_2_2(STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_9,
          STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_8, and_tmp);
      BATCH_LOOP_stage_v_11 <= ((BATCH_LOOP_stage_v_11 & (~(mux_503_nl & and_dcpl_164)))
          | (and_tmp_56 & and_dcpl_160)) & (fsm_output[2]);
      BATCH_LOOP_stage_v_12 <= ((BATCH_LOOP_stage_v_12 & (~ mux_505_nl)) | (and_tmp_3
          & and_dcpl_164)) & (fsm_output[2]);
      exitL_exit_STORE_LOOP_sva <= exitL_exit_STORE_LOOP_sva_mx1 | (~ (fsm_output[2]));
      BATCH_LOOP_stage_v_1 <= ((BATCH_LOOP_stage_v_1 & (~ BATCH_LOOP_and_12_tmp))
          | BATCH_LOOP_and_13_tmp) & (fsm_output[2]);
      BATCH_LOOP_stage_0_2 <= BATCH_LOOP_mux_46_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_7 <= BATCH_LOOP_mux_45_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_8 <= BATCH_LOOP_mux_44_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_9 <= BATCH_LOOP_mux_43_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_10 <= BATCH_LOOP_mux_42_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_11 <= BATCH_LOOP_mux_41_nl & (fsm_output[2]);
      BATCH_LOOP_stage_0_12 <= BATCH_LOOP_mux_40_nl & (fsm_output[2]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      dma_read_data_index_10_7_sva <= 4'b0000;
      dma_write_data_index_10_7_sva <= 4'b0000;
      exit_STORE_CTRL_LOOP_lpi_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= 2'b00;
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
      LOAD_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_4_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= MUX1HOT_v_94_3_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4,
          {(~ (fsm_output[2])) , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl});
      dma_read_data_index_10_7_sva <= MUX_v_4_2_2(4'b0000, dma_read_data_index_10_7_sva_mx1,
          dma_read_data_index_not_1_nl);
      dma_write_data_index_10_7_sva <= MUX_v_4_2_2(4'b0000, STORE_LOOP_mux_15_nl,
          dma_write_data_index_not_1_nl);
      exit_STORE_CTRL_LOOP_lpi_2 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_dfm_3,
          exit_STORE_CTRL_LOOP_lpi_2_mx1, fsm_output[2]);
      lfst_exit_STORE_LOOP_lpi_2_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_8_2,
          lfst_exit_STORE_LOOP_lpi_2_2_mx1, fsm_output[2]);
      lfst_exit_STORE_LOOP_lpi_2_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0,
          lfst_exit_STORE_LOOP_lpi_2_1_0_mx1, fsm_output[2]);
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
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0 <= 2'b00;
      exit_BATCH_LOOP_lpi_2_dfm_st_4 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( STORE_LOOP_and_53_cse ) begin
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
    else if ( STORE_LOOP_and_59_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_12_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_12 <= exit_BATCH_LOOP_lpi_2_dfm_st_11;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_chnl_rsci_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & (((~ mux_165_nl) & BATCH_LOOP_and_13_tmp & (fsm_output[2]))
        | or_tmp_543) ) begin
      reg_dma_read_chnl_rsci_iswt0_cse <= ~ or_tmp_543;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( core_wen & ((fsm_output[0]) | STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1) ) begin
      STORE_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0,
          STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0, STORE_LOOP_i_7_0_lpi_2_6_0_mx0c1);
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
      dma_write_ctrl_rsci_idat_10_7 <= 4'b0000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_tmp_185 | (~ BATCH_LOOP_and_13_tmp)))
        ) begin
      dma_write_ctrl_rsci_idat_10_7 <= dma_write_data_index_10_7_sva;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[0]) | or_tmp_560) ) begin
      exit_CALC_SOFTMAX_LOOP_lpi_2 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3,
          STORE_LOOP_mux1h_18_mx0w1, or_tmp_560);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_batch_sva <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (fsm_output[2:1]==2'b00) ) begin
      conf_info_batch_sva <= conf_info_batch_rsci_idat;
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
      STORE_LOOP_STORE_LOOP_and_9_itm_1 <= 1'b0;
      STORE_LOOP_asn_17_itm_1 <= 1'b0;
      SUM_EXP_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0 <= 7'b0000000;
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
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 <= exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_mx0w1;
      lfst_exit_STORE_LOOP_lpi_2_dfm_5_1_2 <= BATCH_LOOP_acc_3_tmp[4];
      STORE_LOOP_STORE_LOOP_and_9_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1;
      STORE_LOOP_asn_17_itm_1 <= STORE_LOOP_STORE_LOOP_STORE_LOOP_and_cse_mx0w1 |
          exit_BATCH_LOOP_lpi_2_dfm_mx0w0;
      SUM_EXP_LOOP_i_7_0_sva_1_1_6_0 <= SUM_EXP_LOOP_i_7_0_sva_2[6:0];
      CALC_EXP_LOOP_i_7_0_sva_1_1_6_0 <= CALC_EXP_LOOP_i_7_0_sva_2[6:0];
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= LOAD_LOOP_i_7_0_sva_2[6:0];
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0 <= CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= 2'b00;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= 1'b0;
    end
    else if ( STORE_LOOP_and_98_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0w1,
          lfst_exit_STORE_LOOP_lpi_2_1_0_mx1, or_tmp_579);
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0w1,
          lfst_exit_STORE_LOOP_lpi_2_2_mx1, or_tmp_579);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_24_cse ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm_1 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2_mx1,
          CALC_SOFTMAX_LOOP_asn_3_itm, or_tmp_582);
      CALC_SOFTMAX_LOOP_asn_itm_1 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2, CALC_SOFTMAX_LOOP_asn_itm,
          or_tmp_582);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= 2'b00;
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= 1'b0;
    end
    else if ( STORE_LOOP_and_68_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2, and_835_cse);
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0, and_835_cse);
      exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_CALC_SOFTMAX_LOOP_lpi_2,
          STORE_LOOP_mux1h_18_mx0w1, and_657_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((fsm_output[0]) | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1)
        ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_2_mx0w0,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_25_cse ) begin
      CALC_SOFTMAX_LOOP_asn_3_itm <= exit_STORE_CTRL_LOOP_lpi_2_mx1;
      CALC_SOFTMAX_LOOP_asn_itm <= exit_CALC_SOFTMAX_LOOP_lpi_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0 <= 2'b00;
    end
    else if ( STORE_LOOP_and_71_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_2_mx0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_0_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0 <= 7'b0000000;
    end
    else if ( core_wen & (~((fsm_output[1]) | ((~(mux_223_cse & BATCH_LOOP_and_13_tmp))
        & (fsm_output[2])))) ) begin
      CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0,
          CALC_SOFTMAX_LOOP_i_7_0_lpi_2_dfm_3_6_0_mx0w2, or_tmp_560);
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
        | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0!=2'b10) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2))
        ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm <= CALC_EXP_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse <= 7'b0000000;
    end
    else if ( core_wen & (((~ mux_tmp_241) & BATCH_LOOP_and_13_tmp & (~ exit_CALC_SOFTMAX_LOOP_lpi_2)
        & (fsm_output[2])) | or_tmp_632) ) begin
      reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm, or_tmp_632);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= 1'b0;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | not_tmp_183 | or_dcpl_81 | exit_BATCH_LOOP_lpi_2_dfm_st_2
        | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0!=2'b10)
        | (~ LOAD_LOOP_and_1_svs_st_2))) ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm <= 7'b0000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | mux_tmp_241 | (~ BATCH_LOOP_and_13_tmp)
        | exit_CALC_SOFTMAX_LOOP_lpi_2)) ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm <= CALC_SOFTMAX_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm <= 7'b0000000;
    end
    else if ( core_wen & (~((~ (fsm_output[2])) | or_dcpl_101 | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0[0])
        | exit_BATCH_LOOP_lpi_2_dfm_1 | (~ BATCH_LOOP_and_12_tmp))) ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm <= STORE_LOOP_i_7_0_lpi_2_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0 <= 2'b00;
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= 1'b0;
    end
    else if ( STORE_LOOP_and_73_cse ) begin
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_2 <= MUX_s_1_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_2,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_2_1, or_tmp_663);
      lfst_exit_STORE_LOOP_lpi_2_dfm_8_1_0 <= MUX_v_2_2_2(lfst_exit_STORE_LOOP_lpi_2_dfm_1_1_1_0,
          lfst_exit_STORE_LOOP_lpi_2_dfm_7_1_0_1, or_tmp_663);
      exit_STORE_CTRL_LOOP_lpi_2_dfm_3 <= MUX_s_1_2_2(exit_STORE_CTRL_LOOP_lpi_2,
          STORE_LOOP_mux1h_19_mx0w1, or_tmp_663);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
      STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= 7'b0000000;
    end
    else if ( LOAD_LOOP_i_and_1_cse ) begin
      LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= LOAD_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= CALC_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= SUM_EXP_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
      STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0 <= STORE_LOOP_i_7_0_lpi_2_dfm_2_6_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & ((mux_427_cse & and_1003_cse & STORE_LOOP_and_32_itm_4 &
        (fsm_output[2])) | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1)
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_359_nl & BATCH_LOOP_stage_0 & (fsm_output[2]))
        | BATCH_LOOP_stage_v_mx0c1) ) begin
      BATCH_LOOP_stage_v <= ~ BATCH_LOOP_stage_v_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (and_tmp_96 & and_dcpl_130 & (~ BATCH_LOOP_and_12_tmp)
        & (fsm_output[2])) | BATCH_LOOP_stage_v_2_mx0c1) ) begin
      BATCH_LOOP_stage_v_2 <= BATCH_LOOP_stage_v_2_mx0c1;
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
      STORE_LOOP_asn_17_itm_2 <= 1'b0;
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
      STORE_LOOP_and_8_itm_1 <= 1'b0;
      STORE_LOOP_and_9_itm_1 <= 1'b0;
      STORE_LOOP_or_25_itm_1 <= 1'b0;
      exit_LOAD_CTRL_LOOP_sva_1 <= 1'b0;
      STORE_LOOP_and_32_itm_1 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_2_cse ) begin
      LOAD_LOOP_and_1_svs_st_2 <= reg_LOAD_LOOP_and_1_svs_1_cse;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0;
      exit_BATCH_LOOP_lpi_2_dfm_st_2 <= exit_BATCH_LOOP_lpi_2_dfm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_2 <= reg_CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1_cse;
      CALC_SOFTMAX_LOOP_asn_itm_2 <= CALC_SOFTMAX_LOOP_asn_itm_1;
      STORE_LOOP_asn_17_itm_2 <= STORE_LOOP_asn_17_itm_1;
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
      STORE_LOOP_and_8_itm_1 <= STORE_LOOP_and_8_itm_mx0w0;
      STORE_LOOP_and_9_itm_1 <= STORE_LOOP_and_9_itm_mx0w0;
      STORE_LOOP_or_25_itm_1 <= STORE_LOOP_or_25_itm_mx0w0;
      exit_LOAD_CTRL_LOOP_sva_1 <= dma_read_ctrl_rsci_irdy_mxwt;
      STORE_LOOP_and_32_itm_1 <= reg_LOAD_LOOP_and_1_svs_1_cse & STORE_LOOP_equal_tmp_1
          & (~ exit_BATCH_LOOP_lpi_2_dfm_1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (mux_144_cse & and_dcpl_58 & or_dcpl_81
        & (fsm_output[2])) | BATCH_LOOP_stage_v_3_mx0c1) ) begin
      BATCH_LOOP_stage_v_3 <= BATCH_LOOP_stage_v_3_mx0c1;
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
      STORE_LOOP_asn_17_itm_3 <= 1'b0;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      STORE_LOOP_and_32_itm_3 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      STORE_LOOP_and_8_itm_2 <= 1'b0;
      STORE_LOOP_and_9_itm_2 <= 1'b0;
      STORE_LOOP_or_25_itm_2 <= 1'b0;
      STORE_LOOP_asn_17_itm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
      STORE_LOOP_and_32_itm_2 <= 1'b0;
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
      STORE_LOOP_asn_17_itm_3 <= STORE_LOOP_asn_17_itm_2;
      exit_BATCH_LOOP_lpi_2_dfm_st_3 <= exit_BATCH_LOOP_lpi_2_dfm_st_2;
      CALC_SOFTMAX_LOOP_asn_itm_4 <= CALC_SOFTMAX_LOOP_asn_itm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      STORE_LOOP_and_32_itm_3 <= STORE_LOOP_and_32_itm_2;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1
          <= MUX_v_74_2_2(74'b00000000000000000000000000000000000000000000000000000000000000000000000000,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1,
          LOAD_CTRL_LOOP_not_1_nl);
      STORE_LOOP_and_8_itm_2 <= STORE_LOOP_and_8_itm_1;
      STORE_LOOP_and_9_itm_2 <= STORE_LOOP_and_9_itm_1;
      STORE_LOOP_or_25_itm_2 <= STORE_LOOP_or_25_itm_1;
      STORE_LOOP_asn_17_itm_4 <= STORE_LOOP_asn_17_itm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= MUX_s_1_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm,
          and_491_nl);
      STORE_LOOP_and_32_itm_2 <= STORE_LOOP_and_32_itm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_3;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_3 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2;
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_2 <= STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | (and_485_cse & and_dcpl_137 & or_dcpl_37
        & (fsm_output[2])) | BATCH_LOOP_stage_v_4_mx0c1) ) begin
      BATCH_LOOP_stage_v_4 <= BATCH_LOOP_stage_v_4_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2 <= 1'b0;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0 <= 2'b00;
      STORE_LOOP_asn_17_itm_5 <= 1'b0;
      STORE_LOOP_and_32_itm_4 <= 1'b0;
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
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_2 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_2;
      lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_5_1_0 <= lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_4_1_0;
      STORE_LOOP_asn_17_itm_5 <= STORE_LOOP_asn_17_itm_4;
      STORE_LOOP_and_32_itm_4 <= STORE_LOOP_and_32_itm_3;
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
    else if ( core_wen & ((fsm_output[1]) | or_tmp_704) ) begin
      BATCH_LOOP_stage_0 <= ~ or_tmp_704;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((fsm_output[1]) | BATCH_LOOP_b_4_0_sva_3_0_mx0c1) ) begin
      BATCH_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, (BATCH_LOOP_acc_3_tmp[3:0]),
          BATCH_LOOP_b_4_0_sva_3_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_1 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_704 | or_tmp_560) ) begin
      BATCH_LOOP_stage_0_1 <= ~((~(BATCH_LOOP_stage_0 | (~ or_tmp_560))) | or_tmp_704);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_3 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | BATCH_LOOP_stage_0_3_mx0c1) ) begin
      BATCH_LOOP_stage_0_3 <= BATCH_LOOP_stage_0_2 & BATCH_LOOP_stage_0_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_4 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | BATCH_LOOP_stage_0_4_mx0c1) ) begin
      BATCH_LOOP_stage_0_4 <= BATCH_LOOP_stage_0_3 & BATCH_LOOP_stage_0_4_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_5 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | BATCH_LOOP_stage_0_5_mx0c1) ) begin
      BATCH_LOOP_stage_0_5 <= BATCH_LOOP_stage_0_4 & BATCH_LOOP_stage_0_5_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      BATCH_LOOP_stage_0_6 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | BATCH_LOOP_stage_0_6_mx0c1) ) begin
      BATCH_LOOP_stage_0_6 <= BATCH_LOOP_stage_0_5 & BATCH_LOOP_stage_0_6_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= 7'b0000000;
    end
    else if ( core_wen & (and_dcpl_45 | CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1)
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
    else if ( core_wen & mux_570_nl ) begin
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
          and_dcpl_248);
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= MUX_v_8_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm, and_dcpl_248);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_8_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm,
          and_dcpl_248);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1
          <= MUX_v_10_2_2((operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[69:60]),
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm,
          and_dcpl_248);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1 <= 7'b0000000;
    end
    else if ( core_wen & ((lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_2 & (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_1_1_0==2'b00)
        & and_dcpl_42) | STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1) ) begin
      STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1 <= MUX_v_7_2_2(STORE_LOOP_i_7_0_lpi_2_6_0,
          STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm, STORE_LOOP_i_slc_STORE_LOOP_i_7_0_6_0_itm_1_mx0c1);
    end
  end
  assign and_972_nl = (~(or_472_cse & BATCH_LOOP_stage_0_11)) & and_tmp_3;
  assign mux_503_nl = MUX_s_1_2_2(and_tmp_3, and_972_nl, BATCH_LOOP_stage_v_10);
  assign nor_172_nl = ~(plm_out_data_rsci_bawt | CALC_SOFTMAX_LOOP_asn_itm_11 | exit_BATCH_LOOP_lpi_2_dfm_st_11
      | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_1_0!=2'b11) | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_11_2
      | (~ or_tmp_443));
  assign mux_505_nl = MUX_s_1_2_2(or_tmp_443, nor_172_nl, and_dcpl_164);
  assign nor_nl = ~(BATCH_LOOP_and_12_tmp | BATCH_LOOP_and_13_tmp);
  assign BATCH_LOOP_mux_46_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_1, BATCH_LOOP_stage_0_2,
      nor_nl);
  assign nand_61_nl = ~(BATCH_LOOP_stage_v_5 & BATCH_LOOP_stage_0_6 & mux_tmp_108);
  assign nand_62_nl = ~(BATCH_LOOP_stage_0_7 & mux_426_cse);
  assign mux_458_nl = MUX_s_1_2_2(nand_61_nl, nand_62_nl, BATCH_LOOP_stage_v_6);
  assign BATCH_LOOP_mux_45_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_6, BATCH_LOOP_stage_0_7,
      mux_458_nl);
  assign nand_58_nl = ~(BATCH_LOOP_stage_v_6 & BATCH_LOOP_stage_0_7 & mux_tmp_108);
  assign nand_59_nl = ~(BATCH_LOOP_stage_0_8 & mux_425_cse);
  assign mux_475_nl = MUX_s_1_2_2(nand_58_nl, nand_59_nl, BATCH_LOOP_stage_v_7);
  assign BATCH_LOOP_mux_44_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_7, BATCH_LOOP_stage_0_8,
      mux_475_nl);
  assign nor_175_nl = ~(BATCH_LOOP_stage_v_10 | (~ and_tmp_148));
  assign mux_488_nl = MUX_s_1_2_2(nor_175_nl, and_973_cse, BATCH_LOOP_stage_v_8);
  assign mux_487_nl = MUX_s_1_2_2(and_tmp_148, and_332_cse, BATCH_LOOP_stage_v_8);
  assign mux_489_nl = MUX_s_1_2_2(mux_488_nl, mux_487_nl, or_472_cse);
  assign BATCH_LOOP_mux_43_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_9, BATCH_LOOP_stage_0_8,
      mux_489_nl);
  assign or_545_nl = BATCH_LOOP_stage_v_10 | (~ and_tmp_151);
  assign mux_498_nl = MUX_s_1_2_2(or_545_nl, or_tmp_431, BATCH_LOOP_stage_v_9);
  assign nand_55_nl = ~(BATCH_LOOP_stage_0_10 & mux_484_cse);
  assign mux_496_nl = MUX_s_1_2_2(or_tmp_431, nand_55_nl, BATCH_LOOP_stage_0_11);
  assign mux_497_nl = MUX_s_1_2_2((~ and_tmp_151), mux_496_nl, BATCH_LOOP_stage_v_9);
  assign mux_499_nl = MUX_s_1_2_2(mux_498_nl, mux_497_nl, or_472_cse);
  assign BATCH_LOOP_mux_42_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_9, BATCH_LOOP_stage_0_10,
      mux_499_nl);
  assign nand_53_nl = ~(BATCH_LOOP_stage_v_9 & BATCH_LOOP_stage_0_10 & mux_145_cse);
  assign nand_54_nl = ~(or_472_cse & BATCH_LOOP_stage_0_11 & mux_146_cse);
  assign mux_502_nl = MUX_s_1_2_2(nand_53_nl, nand_54_nl, BATCH_LOOP_stage_v_10);
  assign BATCH_LOOP_mux_41_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_10, BATCH_LOOP_stage_0_11,
      mux_502_nl);
  assign nand_50_nl = ~(or_472_cse & BATCH_LOOP_stage_v_10 & BATCH_LOOP_stage_0_11
      & or_tmp_9);
  assign nand_51_nl = ~(BATCH_LOOP_stage_0_12 & or_20_cse & or_tmp_9);
  assign mux_504_nl = MUX_s_1_2_2(nand_50_nl, nand_51_nl, BATCH_LOOP_stage_v_11);
  assign BATCH_LOOP_mux_40_nl = MUX_s_1_2_2(BATCH_LOOP_stage_0_11, BATCH_LOOP_stage_0_12,
      mux_504_nl);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_5_nl
      = (~ ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp)
      & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_6_nl
      = ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_tmp
      & (fsm_output[2]);
  assign dma_read_data_index_not_1_nl = ~ (fsm_output[0]);
  assign or_276_nl = (~(exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_1 & exit_STORE_CTRL_LOOP_lpi_2_dfm_4))
      | exit_BATCH_LOOP_lpi_2_dfm_1 | (~ STORE_LOOP_equal_tmp_1_1) | or_tmp_151;
  assign STORE_LOOP_mux_15_nl = MUX_v_4_2_2(z_out, dma_write_data_index_10_7_sva,
      or_276_nl);
  assign dma_write_data_index_not_1_nl = ~ (fsm_output[0]);
  assign or_885_nl = (STORE_LOOP_mux_28_tmp!=2'b10) | mux_164_itm;
  assign mux_165_nl = MUX_s_1_2_2(or_885_nl, or_tmp_152, or_tmp_151);
  assign or_408_nl = (lfst_exit_STORE_LOOP_lpi_2_1_0!=2'b00) | (~ lfst_exit_STORE_LOOP_lpi_2_2);
  assign mux_339_nl = MUX_s_1_2_2(or_408_nl, BATCH_LOOP_acc_itm_32_1, exitL_exit_STORE_LOOP_sva);
  assign mux_356_nl = MUX_s_1_2_2(mux_355_cse, mux_339_nl, or_tmp_151);
  assign mux_358_nl = MUX_s_1_2_2(mux_357_cse, mux_356_nl, and_967_cse);
  assign mux_359_nl = MUX_s_1_2_2((~ BATCH_LOOP_stage_v), mux_358_nl, BATCH_LOOP_and_13_tmp);
  assign LOAD_CTRL_LOOP_not_1_nl = ~ exit_LOAD_CTRL_LOOP_sva_1;
  assign and_491_nl = ((~ LOAD_LOOP_and_1_svs_st_2) | (lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_1_0!=2'b10)
      | lfst_exit_STORE_LOOP_lpi_2_dfm_1_st_2_2 | exit_BATCH_LOOP_lpi_2_dfm_st_2)
      & mux_tmp_378;
  assign mux_569_nl = MUX_s_1_2_2(mux_tmp_108, and_390_cse, BATCH_LOOP_stage_v_3);
  assign and_391_nl = or_862_cse & mux_569_nl;
  assign mux_570_nl = MUX_s_1_2_2(mux_tmp_108, and_391_nl, BATCH_LOOP_stage_v_4);
  assign and_1037_nl = (~ STORE_LOOP_equal_tmp_1_1) & (fsm_output[2]);
  assign BATCH_LOOP_mux_47_nl = MUX_v_4_2_2(dma_write_data_index_10_7_sva, dma_read_data_index_10_7_sva,
      and_1037_nl);
  assign nl_z_out = BATCH_LOOP_mux_47_nl + 4'b0001;
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
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_batch_rsc_dat, conf_info_batch_rsc_triosy_lz,
      conf_done_rsc_dat, conf_done_rsc_triosy_lz, dma_read_ctrl_rsc_dat_size, dma_read_ctrl_rsc_dat_length,
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
  input [31:0] conf_info_batch_rsc_dat;
  output conf_info_batch_rsc_triosy_lz;
  input conf_done_rsc_dat;
  output conf_done_rsc_triosy_lz;
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
  esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_9_7_32_128_128_32_1_gen
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
  esp_acc_softmax_cxx_softmax_cxx_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_10_7_67_128_128_67_1_gen
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
      .conf_info_batch_rsc_dat(conf_info_batch_rsc_dat),
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
      .conf_done_rsc_dat(conf_done_rsc_dat),
      .conf_done_rsc_triosy_lz(conf_done_rsc_triosy_lz),
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
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_batch_rsc_dat, conf_info_batch_rsc_triosy_lz,
      conf_done_rsc_dat, conf_done_rsc_triosy_lz, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat,
      dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_sync_vld
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;
  input [31:0] conf_info_batch_rsc_dat;
  output conf_info_batch_rsc_triosy_lz;
  input conf_done_rsc_dat;
  output conf_done_rsc_triosy_lz;
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
      .conf_info_batch_rsc_dat(conf_info_batch_rsc_dat),
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
      .conf_done_rsc_dat(conf_done_rsc_dat),
      .conf_done_rsc_triosy_lz(conf_done_rsc_triosy_lz),
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



