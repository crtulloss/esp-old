
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


//------> ./softmax_cxx_mgc_in_sync_v2.v 
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


module esp_acc_softmax_cxx_mgc_in_sync_v2 (vd, vz);
    parameter valid = 1;

    output vd;
    input  vz;

    wire   vd;

    assign vd = vz;

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

//------> ./softmax_cxx_leading_sign_74_0.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5a/871028 Production Release
//  HLS Date:       Tue Apr 14 07:55:32 PDT 2020
//
//  Generated by:   giuseppe@fastml02
//  Generated date: Tue May 19 23:26:27 2020
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

//------> ./softmax_cxx_ccs_in_vld_v1.v 
//------------------------------------------------------------------------------
// Catapult Synthesis - Sample I/O Port Library
//
// Copyright (c) 2003-2017 Mentor Graphics Corp.
//       All Rights Reserved
//
// This doocument may be used and distributed without restriction provided that
// this copyright statement is not removed from the file and that any derivative
// work contains this copyright notice.
//
// The design information contained in this file is intended to be an example
// of the functionality which the end user may study in preparation for creating
// their own custom interfaces. This design does not necessarily present a
// complete implementation of the named protocol or standard.
//
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_ccs_in_vld_v1 (idat, ivld, dat, vld);

  parameter integer rscid = 1;
  parameter integer width = 8;

  output [width-1:0] idat;
  output             ivld;
  input  [width-1:0] dat;
  input              vld;

  wire   [width-1:0] idat;
  wire               ivld;

  assign idat = dat;
  assign ivld = vld;

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




//------> ./softmax_cxx.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5a/871028 Production Release
//  HLS Date:       Tue Apr 14 07:55:32 PDT 2020
// 
//  Generated by:   giuseppe@fastml02
//  Generated date: Sun May 24 15:09:36 2020
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_plm_out_cns_bctl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_plm_out_cns_bctl (
  clk, rst, plm_out_rsc_wadr_ncompute_inst, plm_out_rsc_d_ncompute_inst, plm_out_rsc_we_ncompute_inst,
      plm_out_rsc_req_vz_ncompute_inst, plm_out_rsc_we_ncompute_inst_buz, plm_conf_rsc_rdy_nstore_inst,
      plm_out_rsc_radr_nstore_inst, plm_out_rsc_q_nstore_inst, plm_out_rsc_req_vz_nstore_inst,
      dma_write_ctrl_rsc_vld_nstore_inst, dma_write_chnl_rsc_vld_nstore_inst, acc_done_sync_vld_nstore_inst,
      plm_conf_rsc_rdy_nstore_inst_bud, plm_out_rsc_we_ncompute_inst_buz_bud, plm_out_rsc_rls_lz_ncompute_inst_bud,
      plm_out_rsc_rls_lz_nstore_inst_bud, dma_write_ctrl_rsc_vld_nstore_inst_bud,
      dma_write_chnl_rsc_vld_nstore_inst_bud, acc_done_sync_vld_nstore_inst_bud,
      plm_out_cns_S0, plm_out_cns_R0, plm_out_cns_S1, plm_out_cns_R1, plm_out_cns_d_shi0,
      plm_out_cns_d_shi1, plm_out_cns_q_sho0, plm_out_cns_q_sho1, plm_out_cns_radr_shi0,
      plm_out_cns_radr_shi1, plm_out_cns_wadr_shi0, plm_out_cns_wadr_shi1, plm_out_cns_we_shi0,
      plm_out_cns_we_shi1, plm_out_rsc_we_ncompute_inst_buz_pff, plm_out_rsc_we_ncompute_inst_buz_bud_pff,
      plm_out_cns_S0_pff
);
  input clk;
  input rst;
  input [6:0] plm_out_rsc_wadr_ncompute_inst;
  input [31:0] plm_out_rsc_d_ncompute_inst;
  input plm_out_rsc_we_ncompute_inst;
  output plm_out_rsc_req_vz_ncompute_inst;
  input plm_out_rsc_we_ncompute_inst_buz;
  output plm_conf_rsc_rdy_nstore_inst;
  input [6:0] plm_out_rsc_radr_nstore_inst;
  output [31:0] plm_out_rsc_q_nstore_inst;
  output plm_out_rsc_req_vz_nstore_inst;
  output dma_write_ctrl_rsc_vld_nstore_inst;
  output dma_write_chnl_rsc_vld_nstore_inst;
  output acc_done_sync_vld_nstore_inst;
  input plm_conf_rsc_rdy_nstore_inst_bud;
  output plm_out_rsc_we_ncompute_inst_buz_bud;
  input plm_out_rsc_rls_lz_ncompute_inst_bud;
  input plm_out_rsc_rls_lz_nstore_inst_bud;
  input dma_write_ctrl_rsc_vld_nstore_inst_bud;
  input dma_write_chnl_rsc_vld_nstore_inst_bud;
  input acc_done_sync_vld_nstore_inst_bud;
  output plm_out_cns_S0;
  input plm_out_cns_R0;
  output plm_out_cns_S1;
  input plm_out_cns_R1;
  output [31:0] plm_out_cns_d_shi0;
  output [31:0] plm_out_cns_d_shi1;
  input [31:0] plm_out_cns_q_sho0;
  input [31:0] plm_out_cns_q_sho1;
  output [6:0] plm_out_cns_radr_shi0;
  output [6:0] plm_out_cns_radr_shi1;
  output [6:0] plm_out_cns_wadr_shi0;
  output [6:0] plm_out_cns_wadr_shi1;
  output plm_out_cns_we_shi0;
  output plm_out_cns_we_shi1;
  input plm_out_rsc_we_ncompute_inst_buz_pff;
  output plm_out_rsc_we_ncompute_inst_buz_bud_pff;
  output plm_out_cns_S0_pff;


  // Interconnect Declarations
  reg plm_out_rsc_we_ncompute_inst_buy;
  wire plm_out_cns_PC0;
  reg plm_out_cns_ppidx;
  reg [1:0] plm_out_cns_ppown;
  wire plm_out_cns_PC1;
  reg plm_out_cns_ppidx_1;
  reg [1:0] plm_out_cns_ppown_1;
  wire [1:0] plm_out_acc_rmff;
  wire [3:0] nl_plm_out_acc_rmff;
  wire plm_out_xor_rmff;
  wire [1:0] plm_out_acc_1_rmff;
  wire [3:0] nl_plm_out_acc_1_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsc_rdy_nstore_inst = plm_conf_rsc_rdy_nstore_inst_bud;
  assign dma_write_ctrl_rsc_vld_nstore_inst = dma_write_ctrl_rsc_vld_nstore_inst_bud;
  assign dma_write_chnl_rsc_vld_nstore_inst = dma_write_chnl_rsc_vld_nstore_inst_bud;
  assign acc_done_sync_vld_nstore_inst = acc_done_sync_vld_nstore_inst_bud;
  assign plm_out_rsc_req_vz_ncompute_inst = plm_out_cns_R0;
  assign plm_out_rsc_req_vz_nstore_inst = plm_out_cns_R1;
  assign plm_out_xor_rmff = plm_out_cns_ppidx ^ plm_out_cns_PC0;
  assign nl_plm_out_acc_rmff = plm_out_cns_ppown + conv_u2u_1_2(plm_out_cns_PC0)
      + conv_s2u_1_2(plm_out_cns_PC1);
  assign plm_out_acc_rmff = nl_plm_out_acc_rmff[1:0];
  assign plm_out_cns_PC0 = plm_out_cns_S0 & plm_out_rsc_rls_lz_ncompute_inst_bud;
  assign nl_plm_out_acc_1_rmff = plm_out_cns_ppown_1 + conv_u2u_1_2(plm_out_cns_PC1)
      + conv_s2u_1_2(plm_out_cns_PC0);
  assign plm_out_acc_1_rmff = nl_plm_out_acc_1_rmff[1:0];
  assign plm_out_cns_PC1 = ((plm_out_cns_ppown_1!=2'b00)) & plm_out_rsc_rls_lz_nstore_inst_bud;
  assign plm_out_rsc_q_nstore_inst = MUX_v_32_2_2(plm_out_cns_q_sho0, plm_out_cns_q_sho1,
      plm_out_cns_ppidx_1);
  assign plm_out_cns_d_shi0 = plm_out_rsc_d_ncompute_inst;
  assign plm_out_cns_radr_shi0 = plm_out_rsc_radr_nstore_inst;
  assign plm_out_cns_wadr_shi0 = plm_out_rsc_wadr_ncompute_inst;
  assign plm_out_cns_we_shi0 = plm_out_rsc_we_ncompute_inst_buz_pff & plm_out_cns_S0_pff
      & (~ plm_out_xor_rmff);
  assign plm_out_rsc_we_ncompute_inst_buz_bud = plm_out_rsc_we_ncompute_inst_buy;
  assign plm_out_rsc_we_ncompute_inst_buz_bud_pff = plm_out_rsc_we_ncompute_inst;
  assign plm_out_cns_S0 = ~((plm_out_cns_ppown==2'b10));
  assign plm_out_cns_S0_pff = ~((plm_out_acc_rmff==2'b10));
  assign plm_out_cns_d_shi1 = plm_out_rsc_d_ncompute_inst;
  assign plm_out_cns_radr_shi1 = plm_out_rsc_radr_nstore_inst;
  assign plm_out_cns_wadr_shi1 = plm_out_rsc_wadr_ncompute_inst;
  assign plm_out_cns_we_shi1 = plm_out_rsc_we_ncompute_inst_buz_pff & plm_out_cns_S0_pff
      & plm_out_xor_rmff;
  assign plm_out_cns_S1 = (plm_out_acc_1_rmff!=2'b00);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_out_rsc_we_ncompute_inst_buy <= 1'b0;
      plm_out_cns_ppidx <= 1'b0;
      plm_out_cns_ppown <= 2'b00;
      plm_out_cns_ppidx_1 <= 1'b0;
      plm_out_cns_ppown_1 <= 2'b00;
    end
    else begin
      plm_out_rsc_we_ncompute_inst_buy <= plm_out_rsc_we_ncompute_inst;
      plm_out_cns_ppidx <= plm_out_xor_rmff;
      plm_out_cns_ppown <= plm_out_acc_rmff;
      plm_out_cns_ppidx_1 <= plm_out_cns_ppidx_1 ^ plm_out_cns_PC1;
      plm_out_cns_ppown_1 <= plm_out_acc_1_rmff;
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


  function automatic [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function automatic [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_plm_in_cns_bctl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_plm_in_cns_bctl (
  clk, rst, plm_conf_rsc_rdy_nload_inst, plm_in_rsc_wadr_nload_inst, plm_in_rsc_d_nload_inst,
      plm_in_rsc_we_nload_inst, plm_in_rsc_req_vz_nload_inst, dma_read_ctrl_rsc_vld_nload_inst,
      dma_read_chnl_rsc_rdy_nload_inst, plm_conf_rsc_rdy_ncompute_inst, plm_in_rsc_radr_ncompute_inst,
      plm_in_rsc_q_ncompute_inst, plm_in_rsc_req_vz_ncompute_inst, plm_out_rsc_we_ncompute_inst_buz,
      plm_conf_rsc_rdy_nload_inst_bud, plm_conf_rsc_rdy_ncompute_inst_bud, plm_in_rsc_rls_lz_nload_inst_bud,
      plm_in_rsc_rls_lz_ncompute_inst_bud, dma_read_ctrl_rsc_vld_nload_inst_bud,
      dma_read_chnl_rsc_rdy_nload_inst_bud, plm_out_rsc_we_ncompute_inst_buz_bud,
      plm_out_rsc_rls_lz_ncompute_inst_bud, plm_in_cns_S0, plm_in_cns_R0, plm_in_cns_S1,
      plm_in_cns_R1, plm_in_cns_d_shi0, plm_in_cns_d_shi1, plm_in_cns_q_sho0, plm_in_cns_q_sho1,
      plm_in_cns_radr_shi0, plm_in_cns_radr_shi1, plm_in_cns_wadr_shi0, plm_in_cns_wadr_shi1,
      plm_in_cns_we_shi0, plm_in_cns_we_shi1, plm_in_cns_S0_pff, plm_out_rsc_we_ncompute_inst_buz_pff,
      plm_out_rsc_we_ncompute_inst_buz_bud_pff
);
  input clk;
  input rst;
  output plm_conf_rsc_rdy_nload_inst;
  input [6:0] plm_in_rsc_wadr_nload_inst;
  input [31:0] plm_in_rsc_d_nload_inst;
  input plm_in_rsc_we_nload_inst;
  output plm_in_rsc_req_vz_nload_inst;
  output dma_read_ctrl_rsc_vld_nload_inst;
  output dma_read_chnl_rsc_rdy_nload_inst;
  output plm_conf_rsc_rdy_ncompute_inst;
  input [6:0] plm_in_rsc_radr_ncompute_inst;
  output [31:0] plm_in_rsc_q_ncompute_inst;
  output plm_in_rsc_req_vz_ncompute_inst;
  output plm_out_rsc_we_ncompute_inst_buz;
  input plm_conf_rsc_rdy_nload_inst_bud;
  input plm_conf_rsc_rdy_ncompute_inst_bud;
  input plm_in_rsc_rls_lz_nload_inst_bud;
  input plm_in_rsc_rls_lz_ncompute_inst_bud;
  input dma_read_ctrl_rsc_vld_nload_inst_bud;
  input dma_read_chnl_rsc_rdy_nload_inst_bud;
  input plm_out_rsc_we_ncompute_inst_buz_bud;
  input plm_out_rsc_rls_lz_ncompute_inst_bud;
  output plm_in_cns_S0;
  input plm_in_cns_R0;
  output plm_in_cns_S1;
  input plm_in_cns_R1;
  output [31:0] plm_in_cns_d_shi0;
  output [31:0] plm_in_cns_d_shi1;
  input [31:0] plm_in_cns_q_sho0;
  input [31:0] plm_in_cns_q_sho1;
  output [6:0] plm_in_cns_radr_shi0;
  output [6:0] plm_in_cns_radr_shi1;
  output [6:0] plm_in_cns_wadr_shi0;
  output [6:0] plm_in_cns_wadr_shi1;
  output plm_in_cns_we_shi0;
  output plm_in_cns_we_shi1;
  output plm_in_cns_S0_pff;
  output plm_out_rsc_we_ncompute_inst_buz_pff;
  input plm_out_rsc_we_ncompute_inst_buz_bud_pff;


  // Interconnect Declarations
  wire plm_in_cns_PC0;
  reg plm_in_cns_ppidx;
  reg [1:0] plm_in_cns_ppown;
  wire plm_in_cns_PC1;
  reg plm_in_cns_ppidx_1;
  reg [1:0] plm_in_cns_ppown_1;
  wire [1:0] plm_in_acc_rmff;
  wire [3:0] nl_plm_in_acc_rmff;
  wire plm_in_xor_rmff;
  wire [1:0] plm_in_acc_1_rmff;
  wire [3:0] nl_plm_in_acc_1_rmff;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsc_rdy_nload_inst = plm_conf_rsc_rdy_nload_inst_bud;
  assign plm_conf_rsc_rdy_ncompute_inst = plm_conf_rsc_rdy_ncompute_inst_bud;
  assign dma_read_ctrl_rsc_vld_nload_inst = dma_read_ctrl_rsc_vld_nload_inst_bud;
  assign dma_read_chnl_rsc_rdy_nload_inst = dma_read_chnl_rsc_rdy_nload_inst_bud;
  assign plm_in_rsc_req_vz_nload_inst = plm_in_cns_R0;
  assign plm_in_rsc_req_vz_ncompute_inst = plm_in_cns_R1;
  assign plm_in_xor_rmff = plm_in_cns_ppidx ^ plm_in_cns_PC0;
  assign nl_plm_in_acc_rmff = plm_in_cns_ppown + conv_u2u_1_2(plm_in_cns_PC0) + conv_s2u_1_2(plm_in_cns_PC1);
  assign plm_in_acc_rmff = nl_plm_in_acc_rmff[1:0];
  assign plm_in_cns_PC0 = plm_in_cns_S0 & plm_in_rsc_rls_lz_nload_inst_bud;
  assign nl_plm_in_acc_1_rmff = plm_in_cns_ppown_1 + conv_u2u_1_2(plm_in_cns_PC1)
      + conv_s2u_1_2(plm_in_cns_PC0);
  assign plm_in_acc_1_rmff = nl_plm_in_acc_1_rmff[1:0];
  assign plm_in_cns_PC1 = ((plm_in_cns_ppown_1!=2'b00)) & plm_in_rsc_rls_lz_ncompute_inst_bud;
  assign plm_in_rsc_q_ncompute_inst = MUX_v_32_2_2(plm_in_cns_q_sho0, plm_in_cns_q_sho1,
      plm_in_cns_ppidx_1);
  assign plm_in_cns_d_shi0 = plm_in_rsc_d_nload_inst;
  assign plm_in_cns_radr_shi0 = plm_in_rsc_radr_ncompute_inst;
  assign plm_in_cns_wadr_shi0 = plm_in_rsc_wadr_nload_inst;
  assign plm_in_cns_we_shi0 = plm_in_rsc_we_nload_inst & plm_in_cns_S0_pff & (~ plm_in_xor_rmff);
  assign plm_in_cns_S0 = ~((plm_in_cns_ppown==2'b10));
  assign plm_in_cns_S0_pff = ~((plm_in_acc_rmff==2'b10));
  assign plm_in_cns_d_shi1 = plm_in_rsc_d_nload_inst;
  assign plm_in_cns_radr_shi1 = plm_in_rsc_radr_ncompute_inst;
  assign plm_in_cns_wadr_shi1 = plm_in_rsc_wadr_nload_inst;
  assign plm_in_cns_we_shi1 = plm_in_rsc_we_nload_inst & plm_in_cns_S0_pff & plm_in_xor_rmff;
  assign plm_out_rsc_we_ncompute_inst_buz = plm_out_rsc_we_ncompute_inst_buz_bud;
  assign plm_out_rsc_we_ncompute_inst_buz_pff = plm_out_rsc_we_ncompute_inst_buz_bud_pff;
  assign plm_in_cns_S1 = (plm_in_acc_1_rmff!=2'b00);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_in_cns_ppidx <= 1'b0;
      plm_in_cns_ppown <= 2'b00;
      plm_in_cns_ppidx_1 <= 1'b0;
      plm_in_cns_ppown_1 <= 2'b00;
    end
    else begin
      plm_in_cns_ppidx <= plm_in_xor_rmff;
      plm_in_cns_ppown <= plm_in_acc_rmff;
      plm_in_cns_ppidx_1 <= plm_in_cns_ppidx_1 ^ plm_in_cns_PC1;
      plm_in_cns_ppown_1 <= plm_in_acc_1_rmff;
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


  function automatic [1:0] conv_s2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_s2u_1_2 = {vector[0], vector};
  end
  endfunction


  function automatic [1:0] conv_u2u_1_2 ;
    input [0:0]  vector ;
  begin
    conv_u2u_1_2 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_unreg_hier
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_unreg_hier (
  in_0, out_0
);
  input in_0;
  output out_0;



  // Interconnect Declarations for Component Instantiations 
  assign out_0 = in_0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core (
  clk, rst, debug_rsc_triosy_obj_ld
);
  input clk;
  input rst;
  output debug_rsc_triosy_obj_ld;
  reg debug_rsc_triosy_obj_ld;



  // Interconnect Declarations for Component Instantiations 
  always @(posedge clk) begin
    if ( rst ) begin
      debug_rsc_triosy_obj_ld <= 1'b0;
    end
    else begin
      debug_rsc_triosy_obj_ld <= 1'b1;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [2:0] fsm_output;
  reg [2:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_config_core_core_fsm_1
  parameter
    core_rlp_C_0 = 2'd0,
    main_C_0 = 2'd1,
    main_C_1 = 2'd2;

  reg [1:0] state_var;
  reg [1:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_config_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 3'b010;
        state_var_NS = main_C_1;
      end
      main_C_1 : begin
        fsm_output = 3'b100;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 3'b001;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_staller (
  clk, rst, core_wen, core_wten, conf_info_batch_rsci_wen_comp, plm_conf_load_rsci_wen_comp,
      plm_conf_compute_rsci_wen_comp, plm_conf_store_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  reg core_wten;
  input conf_info_batch_rsci_wen_comp;
  input plm_conf_load_rsci_wen_comp;
  input plm_conf_compute_rsci_wen_comp;
  input plm_conf_store_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_batch_rsci_wen_comp & plm_conf_load_rsci_wen_comp &
      plm_conf_compute_rsci_wen_comp & plm_conf_store_rsci_wen_comp;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
    (
  clk, rst, plm_conf_store_rsci_oswt, plm_conf_store_rsci_wen_comp, plm_conf_store_rsci_biwt,
      plm_conf_store_rsci_bdwt, plm_conf_store_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_store_rsci_oswt;
  output plm_conf_store_rsci_wen_comp;
  input plm_conf_store_rsci_biwt;
  input plm_conf_store_rsci_bdwt;
  output plm_conf_store_rsci_bcwt;
  reg plm_conf_store_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_store_rsci_wen_comp = (~ plm_conf_store_rsci_oswt) | plm_conf_store_rsci_biwt
      | plm_conf_store_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_conf_store_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_store_rsci_bcwt <= ~((~(plm_conf_store_rsci_bcwt | plm_conf_store_rsci_biwt))
          | plm_conf_store_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl
    (
  core_wen, plm_conf_store_rsci_oswt, plm_conf_store_rsci_irdy, plm_conf_store_rsci_biwt,
      plm_conf_store_rsci_bdwt, plm_conf_store_rsci_bcwt, plm_conf_store_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_store_rsci_oswt;
  input plm_conf_store_rsci_irdy;
  output plm_conf_store_rsci_biwt;
  output plm_conf_store_rsci_bdwt;
  input plm_conf_store_rsci_bcwt;
  output plm_conf_store_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_store_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_store_rsci_bdwt = plm_conf_store_rsci_oswt & core_wen;
  assign plm_conf_store_rsci_biwt = plm_conf_store_rsci_ogwt & plm_conf_store_rsci_irdy;
  assign plm_conf_store_rsci_ogwt = plm_conf_store_rsci_oswt & (~ plm_conf_store_rsci_bcwt);
  assign plm_conf_store_rsci_ivld_core_sct = plm_conf_store_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
    (
  clk, rst, plm_conf_compute_rsci_oswt, plm_conf_compute_rsci_wen_comp, plm_conf_compute_rsci_biwt,
      plm_conf_compute_rsci_bdwt, plm_conf_compute_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_compute_rsci_oswt;
  output plm_conf_compute_rsci_wen_comp;
  input plm_conf_compute_rsci_biwt;
  input plm_conf_compute_rsci_bdwt;
  output plm_conf_compute_rsci_bcwt;
  reg plm_conf_compute_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_compute_rsci_wen_comp = (~ plm_conf_compute_rsci_oswt) | plm_conf_compute_rsci_biwt
      | plm_conf_compute_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_conf_compute_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_compute_rsci_bcwt <= ~((~(plm_conf_compute_rsci_bcwt | plm_conf_compute_rsci_biwt))
          | plm_conf_compute_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
    (
  core_wen, plm_conf_compute_rsci_oswt, plm_conf_compute_rsci_irdy, plm_conf_compute_rsci_biwt,
      plm_conf_compute_rsci_bdwt, plm_conf_compute_rsci_bcwt, plm_conf_compute_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_compute_rsci_oswt;
  input plm_conf_compute_rsci_irdy;
  output plm_conf_compute_rsci_biwt;
  output plm_conf_compute_rsci_bdwt;
  input plm_conf_compute_rsci_bcwt;
  output plm_conf_compute_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_compute_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_compute_rsci_bdwt = plm_conf_compute_rsci_oswt & core_wen;
  assign plm_conf_compute_rsci_biwt = plm_conf_compute_rsci_ogwt & plm_conf_compute_rsci_irdy;
  assign plm_conf_compute_rsci_ogwt = plm_conf_compute_rsci_oswt & (~ plm_conf_compute_rsci_bcwt);
  assign plm_conf_compute_rsci_ivld_core_sct = plm_conf_compute_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp (
  clk, rst, plm_conf_load_rsci_oswt, plm_conf_load_rsci_wen_comp, plm_conf_load_rsci_biwt,
      plm_conf_load_rsci_bdwt, plm_conf_load_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_load_rsci_oswt;
  output plm_conf_load_rsci_wen_comp;
  input plm_conf_load_rsci_biwt;
  input plm_conf_load_rsci_bdwt;
  output plm_conf_load_rsci_bcwt;
  reg plm_conf_load_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_wen_comp = (~ plm_conf_load_rsci_oswt) | plm_conf_load_rsci_biwt
      | plm_conf_load_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_conf_load_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_load_rsci_bcwt <= ~((~(plm_conf_load_rsci_bcwt | plm_conf_load_rsci_biwt))
          | plm_conf_load_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl
    (
  core_wen, plm_conf_load_rsci_oswt, plm_conf_load_rsci_irdy, plm_conf_load_rsci_biwt,
      plm_conf_load_rsci_bdwt, plm_conf_load_rsci_bcwt, plm_conf_load_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_load_rsci_oswt;
  input plm_conf_load_rsci_irdy;
  output plm_conf_load_rsci_biwt;
  output plm_conf_load_rsci_bdwt;
  input plm_conf_load_rsci_bcwt;
  output plm_conf_load_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_load_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_bdwt = plm_conf_load_rsci_oswt & core_wen;
  assign plm_conf_load_rsci_biwt = plm_conf_load_rsci_ogwt & plm_conf_load_rsci_irdy;
  assign plm_conf_load_rsci_ogwt = plm_conf_load_rsci_oswt & (~ plm_conf_load_rsci_bcwt);
  assign plm_conf_load_rsci_ivld_core_sct = plm_conf_load_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_conf_info_batch_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_conf_info_batch_rsci (
  conf_info_batch_rsc_dat, conf_info_batch_rsc_vld, conf_info_batch_rsci_oswt, conf_info_batch_rsci_wen_comp,
      conf_info_batch_rsci_idat_mxwt
);
  input [31:0] conf_info_batch_rsc_dat;
  input conf_info_batch_rsc_vld;
  input conf_info_batch_rsci_oswt;
  output conf_info_batch_rsci_wen_comp;
  output [31:0] conf_info_batch_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_batch_rsci_ivld;
  wire [31:0] conf_info_batch_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_in_vld_v1 #(.rscid(32'sd1),
  .width(32'sd32)) conf_info_batch_rsci (
      .vld(conf_info_batch_rsc_vld),
      .dat(conf_info_batch_rsc_dat),
      .ivld(conf_info_batch_rsci_ivld),
      .idat(conf_info_batch_rsci_idat)
    );
  assign conf_info_batch_rsci_idat_mxwt = conf_info_batch_rsci_idat;
  assign conf_info_batch_rsci_wen_comp = (~ conf_info_batch_rsci_oswt) | conf_info_batch_rsci_ivld;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_6_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_6_7_32_128_128_32_1_gen
    (
  we, d, wadr, d_d, wadr_d, we_d, writeA_w_ram_ir_internal_WMASK_B_d
);
  output we;
  output [31:0] d;
  output [6:0] wadr;
  input [31:0] d_d;
  input [6:0] wadr_d;
  input we_d;
  input writeA_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = (writeA_w_ram_ir_internal_WMASK_B_d);
  assign d = (d_d);
  assign wadr = (wadr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_core_fsm (
  clk, rst, core_wen, fsm_output, main_C_0_tr0, LOAD_INNER_LOOP_C_0_tr0, LOAD_OUTER_LOOP_C_1_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [4:0] fsm_output;
  reg [4:0] fsm_output;
  input main_C_0_tr0;
  input LOAD_INNER_LOOP_C_0_tr0;
  input LOAD_OUTER_LOOP_C_1_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_load_core_core_fsm_1
  parameter
    core_rlp_C_0 = 3'd0,
    main_C_0 = 3'd1,
    LOAD_OUTER_LOOP_C_0 = 3'd2,
    LOAD_INNER_LOOP_C_0 = 3'd3,
    LOAD_OUTER_LOOP_C_1 = 3'd4;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_load_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 5'b00010;
        if ( main_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = LOAD_OUTER_LOOP_C_0;
        end
      end
      LOAD_OUTER_LOOP_C_0 : begin
        fsm_output = 5'b00100;
        state_var_NS = LOAD_INNER_LOOP_C_0;
      end
      LOAD_INNER_LOOP_C_0 : begin
        fsm_output = 5'b01000;
        if ( LOAD_INNER_LOOP_C_0_tr0 ) begin
          state_var_NS = LOAD_OUTER_LOOP_C_1;
        end
        else begin
          state_var_NS = LOAD_INNER_LOOP_C_0;
        end
      end
      LOAD_OUTER_LOOP_C_1 : begin
        fsm_output = 5'b10000;
        if ( LOAD_OUTER_LOOP_C_1_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = LOAD_OUTER_LOOP_C_0;
        end
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 5'b00001;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_staller (
  clk, rst, core_wen, core_wten, plm_conf_rsci_wen_comp, dma_read_ctrl_rsci_wen_comp,
      dma_read_chnl_rsci_wen_comp, plm_in_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input plm_conf_rsci_wen_comp;
  input dma_read_ctrl_rsci_wen_comp;
  input dma_read_chnl_rsci_wen_comp;
  input plm_in_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = plm_conf_rsci_wen_comp & dma_read_ctrl_rsci_wen_comp & dma_read_chnl_rsci_wen_comp
      & plm_in_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp (
  clk, rst, plm_in_rsc_req_obj_oswt, plm_in_rsc_req_obj_wen_comp, plm_in_rsc_req_obj_biwt,
      plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_in_rsc_req_obj_oswt;
  output plm_in_rsc_req_obj_wen_comp;
  input plm_in_rsc_req_obj_biwt;
  input plm_in_rsc_req_obj_bdwt;
  output plm_in_rsc_req_obj_bcwt;
  reg plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_wen_comp = (~ plm_in_rsc_req_obj_oswt) | plm_in_rsc_req_obj_biwt
      | plm_in_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_in_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsc_req_obj_bcwt <= ~((~(plm_in_rsc_req_obj_bcwt | plm_in_rsc_req_obj_biwt))
          | plm_in_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl
    (
  core_wen, plm_in_rsc_req_obj_oswt, plm_in_rsc_req_obj_vd, plm_in_rsc_req_obj_biwt,
      plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_in_rsc_req_obj_oswt;
  input plm_in_rsc_req_obj_vd;
  output plm_in_rsc_req_obj_biwt;
  output plm_in_rsc_req_obj_bdwt;
  input plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_bdwt = plm_in_rsc_req_obj_oswt & core_wen;
  assign plm_in_rsc_req_obj_biwt = plm_in_rsc_req_obj_oswt & (~ plm_in_rsc_req_obj_bcwt)
      & plm_in_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
    (
  core_wten, plm_in_rsc_rls_obj_iswt0, plm_in_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input plm_in_rsc_rls_obj_iswt0;
  output plm_in_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_rls_obj_ld_core_sct = plm_in_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp (
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
    if ( rst ) begin
      dma_read_chnl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_chnl_rsci_bcwt <= ~((~(dma_read_chnl_rsci_bcwt | dma_read_chnl_rsci_biwt))
          | dma_read_chnl_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( dma_read_chnl_rsci_biwt ) begin
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl (
  core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_iswt0, dma_read_chnl_rsci_irdy_core_psct,
      dma_read_chnl_rsci_biwt, dma_read_chnl_rsci_bdwt, dma_read_chnl_rsci_bcwt,
      dma_read_chnl_rsci_irdy_core_sct, dma_read_chnl_rsci_ivld
);
  input core_wen;
  input dma_read_chnl_rsci_oswt_unreg;
  input dma_read_chnl_rsci_iswt0;
  input dma_read_chnl_rsci_irdy_core_psct;
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
  assign dma_read_chnl_rsci_irdy_core_sct = dma_read_chnl_rsci_irdy_core_psct & dma_read_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp (
  clk, rst, dma_read_ctrl_rsci_oswt, dma_read_ctrl_rsci_wen_comp, dma_read_ctrl_rsci_biwt,
      dma_read_ctrl_rsci_bdwt, dma_read_ctrl_rsci_bcwt
);
  input clk;
  input rst;
  input dma_read_ctrl_rsci_oswt;
  output dma_read_ctrl_rsci_wen_comp;
  input dma_read_ctrl_rsci_biwt;
  input dma_read_ctrl_rsci_bdwt;
  output dma_read_ctrl_rsci_bcwt;
  reg dma_read_ctrl_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_wen_comp = (~ dma_read_ctrl_rsci_oswt) | dma_read_ctrl_rsci_biwt
      | dma_read_ctrl_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dma_read_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_ctrl_rsci_bcwt <= ~((~(dma_read_ctrl_rsci_bcwt | dma_read_ctrl_rsci_biwt))
          | dma_read_ctrl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl (
  core_wen, dma_read_ctrl_rsci_oswt, dma_read_ctrl_rsci_irdy, dma_read_ctrl_rsci_biwt,
      dma_read_ctrl_rsci_bdwt, dma_read_ctrl_rsci_bcwt, dma_read_ctrl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_read_ctrl_rsci_oswt;
  input dma_read_ctrl_rsci_irdy;
  output dma_read_ctrl_rsci_biwt;
  output dma_read_ctrl_rsci_bdwt;
  input dma_read_ctrl_rsci_bcwt;
  output dma_read_ctrl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_read_ctrl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bdwt = dma_read_ctrl_rsci_oswt & core_wen;
  assign dma_read_ctrl_rsci_biwt = dma_read_ctrl_rsci_ogwt & dma_read_ctrl_rsci_irdy;
  assign dma_read_ctrl_rsci_ogwt = dma_read_ctrl_rsci_oswt & (~ dma_read_ctrl_rsci_bcwt);
  assign dma_read_ctrl_rsci_ivld_core_sct = dma_read_ctrl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsci_1_plm_in_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsci_1_plm_in_rsc_wait_dp (
  clk, rst, plm_in_rsci_bawt, plm_in_rsci_biwt, plm_in_rsci_bdwt
);
  input clk;
  input rst;
  output plm_in_rsci_bawt;
  input plm_in_rsci_biwt;
  input plm_in_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bawt = plm_in_rsci_biwt | plm_in_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_in_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsci_bcwt <= ~((~(plm_in_rsci_bcwt | plm_in_rsci_biwt)) | plm_in_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl (
  core_wen, core_wten, plm_in_rsci_oswt_unreg, plm_in_rsci_iswt0, plm_in_rsci_biwt,
      plm_in_rsci_bdwt, plm_in_rsci_we_d_core_sct_pff, plm_in_rsci_iswt0_pff
);
  input core_wen;
  input core_wten;
  input plm_in_rsci_oswt_unreg;
  input plm_in_rsci_iswt0;
  output plm_in_rsci_biwt;
  output plm_in_rsci_bdwt;
  output plm_in_rsci_we_d_core_sct_pff;
  input plm_in_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bdwt = plm_in_rsci_oswt_unreg & core_wen;
  assign plm_in_rsci_biwt = (~ core_wten) & plm_in_rsci_iswt0;
  assign plm_in_rsci_we_d_core_sct_pff = plm_in_rsci_iswt0_pff & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_conf_rsci_plm_conf_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_conf_rsci_plm_conf_wait_dp (
  clk, rst, plm_conf_rsci_oswt, plm_conf_rsci_wen_comp, plm_conf_rsci_idat_mxwt,
      plm_conf_rsci_biwt, plm_conf_rsci_bdwt, plm_conf_rsci_bcwt, plm_conf_rsci_idat
);
  input clk;
  input rst;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_wen_comp;
  output [31:0] plm_conf_rsci_idat_mxwt;
  input plm_conf_rsci_biwt;
  input plm_conf_rsci_bdwt;
  output plm_conf_rsci_bcwt;
  reg plm_conf_rsci_bcwt;
  input [31:0] plm_conf_rsci_idat;


  // Interconnect Declarations
  reg [31:0] plm_conf_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsci_wen_comp = (~ plm_conf_rsci_oswt) | plm_conf_rsci_biwt | plm_conf_rsci_bcwt;
  assign plm_conf_rsci_idat_mxwt = MUX_v_32_2_2(plm_conf_rsci_idat, plm_conf_rsci_idat_bfwt,
      plm_conf_rsci_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_conf_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_rsci_bcwt <= ~((~(plm_conf_rsci_bcwt | plm_conf_rsci_biwt)) | plm_conf_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_conf_rsci_biwt ) begin
      plm_conf_rsci_idat_bfwt <= plm_conf_rsci_idat;
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_conf_rsci_plm_conf_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_conf_rsci_plm_conf_wait_ctrl (
  core_wen, plm_conf_rsci_oswt, plm_conf_rsci_biwt, plm_conf_rsci_bdwt, plm_conf_rsci_bcwt,
      plm_conf_rsci_irdy_core_sct, plm_conf_rsci_ivld
);
  input core_wen;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_biwt;
  output plm_conf_rsci_bdwt;
  input plm_conf_rsci_bcwt;
  output plm_conf_rsci_irdy_core_sct;
  input plm_conf_rsci_ivld;


  // Interconnect Declarations
  wire plm_conf_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsci_bdwt = plm_conf_rsci_oswt & core_wen;
  assign plm_conf_rsci_biwt = plm_conf_rsci_ogwt & plm_conf_rsci_ivld;
  assign plm_conf_rsci_ogwt = plm_conf_rsci_oswt & (~ plm_conf_rsci_bcwt);
  assign plm_conf_rsci_irdy_core_sct = plm_conf_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_15_7_67_128_128_67_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_15_7_67_128_128_67_1_gen
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
//  Design Unit:    esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_12_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_12_7_32_128_128_32_1_gen
    (
  we, d, wadr, d_d, wadr_d, we_d, writeA_w_ram_ir_internal_WMASK_B_d
);
  output we;
  output [31:0] d;
  output [6:0] wadr;
  input [31:0] d_d;
  input [6:0] wadr_d;
  input we_d;
  input writeA_w_ram_ir_internal_WMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign we = (writeA_w_ram_ir_internal_WMASK_B_d);
  assign d = (d_d);
  assign wadr = (wadr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_11_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_11_7_32_128_128_32_1_gen
    (
  q, radr, q_d, radr_d, readA_r_ram_ir_internal_RMASK_B_d
);
  input [31:0] q;
  output [6:0] radr;
  output [31:0] q_d;
  input [6:0] radr_d;
  input readA_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign q_d = q;
  assign radr = (radr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_core_fsm (
  clk, rst, core_wen, fsm_output, main_C_0_tr0, CALC_EXP_LOOP_C_0_tr0, CALC_SOFTMAX_LOOP_C_0_tr0,
      COMPUTE_LOOP_C_2_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [6:0] fsm_output;
  reg [6:0] fsm_output;
  input main_C_0_tr0;
  input CALC_EXP_LOOP_C_0_tr0;
  input CALC_SOFTMAX_LOOP_C_0_tr0;
  input COMPUTE_LOOP_C_2_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_compute_core_core_fsm_1
  parameter
    core_rlp_C_0 = 3'd0,
    main_C_0 = 3'd1,
    COMPUTE_LOOP_C_0 = 3'd2,
    CALC_EXP_LOOP_C_0 = 3'd3,
    COMPUTE_LOOP_C_1 = 3'd4,
    CALC_SOFTMAX_LOOP_C_0 = 3'd5,
    COMPUTE_LOOP_C_2 = 3'd6;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_compute_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 7'b0000010;
        if ( main_C_0_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = COMPUTE_LOOP_C_0;
        end
      end
      COMPUTE_LOOP_C_0 : begin
        fsm_output = 7'b0000100;
        state_var_NS = CALC_EXP_LOOP_C_0;
      end
      CALC_EXP_LOOP_C_0 : begin
        fsm_output = 7'b0001000;
        if ( CALC_EXP_LOOP_C_0_tr0 ) begin
          state_var_NS = COMPUTE_LOOP_C_1;
        end
        else begin
          state_var_NS = CALC_EXP_LOOP_C_0;
        end
      end
      COMPUTE_LOOP_C_1 : begin
        fsm_output = 7'b0010000;
        state_var_NS = CALC_SOFTMAX_LOOP_C_0;
      end
      CALC_SOFTMAX_LOOP_C_0 : begin
        fsm_output = 7'b0100000;
        if ( CALC_SOFTMAX_LOOP_C_0_tr0 ) begin
          state_var_NS = COMPUTE_LOOP_C_2;
        end
        else begin
          state_var_NS = CALC_SOFTMAX_LOOP_C_0;
        end
      end
      COMPUTE_LOOP_C_2 : begin
        fsm_output = 7'b1000000;
        if ( COMPUTE_LOOP_C_2_tr0 ) begin
          state_var_NS = main_C_0;
        end
        else begin
          state_var_NS = COMPUTE_LOOP_C_0;
        end
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 7'b0000001;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_staller (
  clk, rst, core_wen, core_wten, plm_conf_rsci_wen_comp, plm_in_rsc_req_obj_wen_comp,
      plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input plm_conf_rsci_wen_comp;
  input plm_in_rsc_req_obj_wen_comp;
  input plm_out_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = plm_conf_rsci_wen_comp & plm_in_rsc_req_obj_wen_comp & plm_out_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
    (
  clk, rst, plm_out_rsc_req_obj_oswt, plm_out_rsc_req_obj_wen_comp, plm_out_rsc_req_obj_biwt,
      plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_out_rsc_req_obj_oswt;
  output plm_out_rsc_req_obj_wen_comp;
  input plm_out_rsc_req_obj_biwt;
  input plm_out_rsc_req_obj_bdwt;
  output plm_out_rsc_req_obj_bcwt;
  reg plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_wen_comp = (~ plm_out_rsc_req_obj_oswt) | plm_out_rsc_req_obj_biwt
      | plm_out_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_out_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsc_req_obj_bcwt <= ~((~(plm_out_rsc_req_obj_bcwt | plm_out_rsc_req_obj_biwt))
          | plm_out_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl
    (
  core_wen, plm_out_rsc_req_obj_oswt, plm_out_rsc_req_obj_vd, plm_out_rsc_req_obj_biwt,
      plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_out_rsc_req_obj_oswt;
  input plm_out_rsc_req_obj_vd;
  output plm_out_rsc_req_obj_biwt;
  output plm_out_rsc_req_obj_bdwt;
  input plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_bdwt = plm_out_rsc_req_obj_oswt & core_wen;
  assign plm_out_rsc_req_obj_biwt = plm_out_rsc_req_obj_oswt & (~ plm_out_rsc_req_obj_bcwt)
      & plm_out_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp
    (
  clk, rst, plm_in_rsc_req_obj_oswt, plm_in_rsc_req_obj_wen_comp, plm_in_rsc_req_obj_biwt,
      plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_in_rsc_req_obj_oswt;
  output plm_in_rsc_req_obj_wen_comp;
  input plm_in_rsc_req_obj_biwt;
  input plm_in_rsc_req_obj_bdwt;
  output plm_in_rsc_req_obj_bcwt;
  reg plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_wen_comp = (~ plm_in_rsc_req_obj_oswt) | plm_in_rsc_req_obj_biwt
      | plm_in_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_in_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsc_req_obj_bcwt <= ~((~(plm_in_rsc_req_obj_bcwt | plm_in_rsc_req_obj_biwt))
          | plm_in_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl
    (
  core_wen, plm_in_rsc_req_obj_oswt, plm_in_rsc_req_obj_vd, plm_in_rsc_req_obj_biwt,
      plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_in_rsc_req_obj_oswt;
  input plm_in_rsc_req_obj_vd;
  output plm_in_rsc_req_obj_biwt;
  output plm_in_rsc_req_obj_bdwt;
  input plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_bdwt = plm_in_rsc_req_obj_oswt & core_wen;
  assign plm_in_rsc_req_obj_biwt = plm_in_rsc_req_obj_oswt & (~ plm_in_rsc_req_obj_bcwt)
      & plm_in_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
    (
  core_wten, plm_in_rsc_rls_obj_iswt0, plm_in_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input plm_in_rsc_rls_obj_iswt0;
  output plm_in_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_rls_obj_ld_core_sct = plm_in_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
    (
  core_wten, plm_out_rsc_rls_obj_iswt0, plm_out_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input plm_out_rsc_rls_obj_iswt0;
  output plm_out_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_rls_obj_ld_core_sct = plm_out_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl (
  plm_out_rsci_we_d_core_sct_pff, plm_out_rsci_iswt0_pff, core_wten_pff
);
  output plm_out_rsci_we_d_core_sct_pff;
  input plm_out_rsci_iswt0_pff;
  input core_wten_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_we_d_core_sct_pff = plm_out_rsci_iswt0_pff & (~ core_wten_pff);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp (
  clk, rst, plm_in_rsci_q_d, plm_in_rsci_q_d_mxwt, plm_in_rsci_biwt, plm_in_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_in_rsci_q_d;
  output [31:0] plm_in_rsci_q_d_mxwt;
  input plm_in_rsci_biwt;
  input plm_in_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_rsci_bcwt;
  reg [31:0] plm_in_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_q_d_mxwt = MUX_v_32_2_2(plm_in_rsci_q_d, plm_in_rsci_q_d_bfwt,
      plm_in_rsci_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_in_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsci_bcwt <= ~((~(plm_in_rsci_bcwt | plm_in_rsci_biwt)) | plm_in_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_in_rsci_biwt ) begin
      plm_in_rsci_q_d_bfwt <= plm_in_rsci_q_d;
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
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl (
  core_wen, core_wten, plm_in_rsci_oswt, plm_in_rsci_biwt, plm_in_rsci_bdwt, plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      plm_in_rsci_oswt_pff
);
  input core_wen;
  input core_wten;
  input plm_in_rsci_oswt;
  output plm_in_rsci_biwt;
  output plm_in_rsci_bdwt;
  output plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  input plm_in_rsci_oswt_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bdwt = plm_in_rsci_oswt & core_wen;
  assign plm_in_rsci_biwt = (~ core_wten) & plm_in_rsci_oswt;
  assign plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_in_rsci_oswt_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_conf_rsci_plm_conf_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_conf_rsci_plm_conf_wait_dp (
  clk, rst, plm_conf_rsci_oswt, plm_conf_rsci_wen_comp, plm_conf_rsci_idat_mxwt,
      plm_conf_rsci_biwt, plm_conf_rsci_bdwt, plm_conf_rsci_bcwt, plm_conf_rsci_idat
);
  input clk;
  input rst;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_wen_comp;
  output [31:0] plm_conf_rsci_idat_mxwt;
  input plm_conf_rsci_biwt;
  input plm_conf_rsci_bdwt;
  output plm_conf_rsci_bcwt;
  reg plm_conf_rsci_bcwt;
  input [31:0] plm_conf_rsci_idat;


  // Interconnect Declarations
  reg [31:0] plm_conf_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsci_wen_comp = (~ plm_conf_rsci_oswt) | plm_conf_rsci_biwt | plm_conf_rsci_bcwt;
  assign plm_conf_rsci_idat_mxwt = MUX_v_32_2_2(plm_conf_rsci_idat, plm_conf_rsci_idat_bfwt,
      plm_conf_rsci_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_conf_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_rsci_bcwt <= ~((~(plm_conf_rsci_bcwt | plm_conf_rsci_biwt)) | plm_conf_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_conf_rsci_biwt ) begin
      plm_conf_rsci_idat_bfwt <= plm_conf_rsci_idat;
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
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_conf_rsci_plm_conf_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_conf_rsci_plm_conf_wait_ctrl (
  core_wen, plm_conf_rsci_oswt, plm_conf_rsci_biwt, plm_conf_rsci_bdwt, plm_conf_rsci_bcwt,
      plm_conf_rsci_irdy_core_sct, plm_conf_rsci_ivld
);
  input core_wen;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_biwt;
  output plm_conf_rsci_bdwt;
  input plm_conf_rsci_bcwt;
  output plm_conf_rsci_irdy_core_sct;
  input plm_conf_rsci_ivld;


  // Interconnect Declarations
  wire plm_conf_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsci_bdwt = plm_conf_rsci_oswt & core_wen;
  assign plm_conf_rsci_biwt = plm_conf_rsci_ogwt & plm_conf_rsci_ivld;
  assign plm_conf_rsci_ogwt = plm_conf_rsci_oswt & (~ plm_conf_rsci_bcwt);
  assign plm_conf_rsci_irdy_core_sct = plm_conf_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_21_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_21_7_32_128_128_32_1_gen
    (
  q, radr, q_d, radr_d, readA_r_ram_ir_internal_RMASK_B_d
);
  input [31:0] q;
  output [6:0] radr;
  output [31:0] q_d;
  input [6:0] radr_d;
  input readA_r_ram_ir_internal_RMASK_B_d;



  // Interconnect Declarations for Component Instantiations 
  assign q_d = q;
  assign radr = (radr_d);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_core_fsm (
  clk, rst, core_wen, fsm_output, main_C_0_tr0, STORE_INNER_LOOP_C_0_tr0, STORE_OUTER_LOOP_C_1_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [5:0] fsm_output;
  reg [5:0] fsm_output;
  input main_C_0_tr0;
  input STORE_INNER_LOOP_C_0_tr0;
  input STORE_OUTER_LOOP_C_1_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_store_core_core_fsm_1
  parameter
    core_rlp_C_0 = 3'd0,
    main_C_0 = 3'd1,
    STORE_OUTER_LOOP_C_0 = 3'd2,
    STORE_INNER_LOOP_C_0 = 3'd3,
    STORE_OUTER_LOOP_C_1 = 3'd4,
    main_C_1 = 3'd5;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_store_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 6'b000010;
        if ( main_C_0_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = STORE_OUTER_LOOP_C_0;
        end
      end
      STORE_OUTER_LOOP_C_0 : begin
        fsm_output = 6'b000100;
        state_var_NS = STORE_INNER_LOOP_C_0;
      end
      STORE_INNER_LOOP_C_0 : begin
        fsm_output = 6'b001000;
        if ( STORE_INNER_LOOP_C_0_tr0 ) begin
          state_var_NS = STORE_OUTER_LOOP_C_1;
        end
        else begin
          state_var_NS = STORE_INNER_LOOP_C_0;
        end
      end
      STORE_OUTER_LOOP_C_1 : begin
        fsm_output = 6'b010000;
        if ( STORE_OUTER_LOOP_C_1_tr0 ) begin
          state_var_NS = main_C_1;
        end
        else begin
          state_var_NS = STORE_OUTER_LOOP_C_0;
        end
      end
      main_C_1 : begin
        fsm_output = 6'b100000;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 6'b000001;
        state_var_NS = main_C_0;
      end
    endcase
  end

  always @(posedge clk) begin
    if ( rst ) begin
      state_var <= core_rlp_C_0;
    end
    else if ( core_wen ) begin
      state_var <= state_var_NS;
    end
  end

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_staller (
  clk, rst, core_wen, core_wten, plm_conf_rsci_wen_comp, dma_write_ctrl_rsci_wen_comp,
      dma_write_chnl_rsci_wen_comp, plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input plm_conf_rsci_wen_comp;
  input dma_write_ctrl_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;
  input plm_out_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = plm_conf_rsci_wen_comp & dma_write_ctrl_rsci_wen_comp & dma_write_chnl_rsci_wen_comp
      & plm_out_rsc_req_obj_wen_comp;
  assign core_wten = core_wten_reg;
  always @(posedge clk) begin
    if ( rst ) begin
      core_wten_reg <= 1'b0;
    end
    else begin
      core_wten_reg <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
    (
  clk, rst, plm_out_rsc_req_obj_oswt, plm_out_rsc_req_obj_wen_comp, plm_out_rsc_req_obj_biwt,
      plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_out_rsc_req_obj_oswt;
  output plm_out_rsc_req_obj_wen_comp;
  input plm_out_rsc_req_obj_biwt;
  input plm_out_rsc_req_obj_bdwt;
  output plm_out_rsc_req_obj_bcwt;
  reg plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_wen_comp = (~ plm_out_rsc_req_obj_oswt) | plm_out_rsc_req_obj_biwt
      | plm_out_rsc_req_obj_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      plm_out_rsc_req_obj_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsc_req_obj_bcwt <= ~((~(plm_out_rsc_req_obj_bcwt | plm_out_rsc_req_obj_biwt))
          | plm_out_rsc_req_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl
    (
  core_wen, plm_out_rsc_req_obj_oswt, plm_out_rsc_req_obj_vd, plm_out_rsc_req_obj_biwt,
      plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_out_rsc_req_obj_oswt;
  input plm_out_rsc_req_obj_vd;
  output plm_out_rsc_req_obj_biwt;
  output plm_out_rsc_req_obj_bdwt;
  input plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_bdwt = plm_out_rsc_req_obj_oswt & core_wen;
  assign plm_out_rsc_req_obj_biwt = plm_out_rsc_req_obj_oswt & (~ plm_out_rsc_req_obj_bcwt)
      & plm_out_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
    (
  core_wten, plm_out_rsc_rls_obj_iswt0, plm_out_rsc_rls_obj_ld_core_sct
);
  input core_wten;
  input plm_out_rsc_rls_obj_iswt0;
  output plm_out_rsc_rls_obj_ld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_rls_obj_ld_core_sct = plm_out_rsc_rls_obj_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_acc_done_synci_acc_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_acc_done_synci_acc_done_wait_ctrl (
  core_wten, acc_done_synci_iswt0, acc_done_synci_ivld_core_sct
);
  input core_wten;
  input acc_done_synci_iswt0;
  output acc_done_synci_ivld_core_sct;



  // Interconnect Declarations for Component Instantiations 
  assign acc_done_synci_ivld_core_sct = acc_done_synci_iswt0 & (~ core_wten);
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp
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
    if ( rst ) begin
      dma_write_chnl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_chnl_rsci_bcwt <= ~((~(dma_write_chnl_rsci_bcwt | dma_write_chnl_rsci_biwt))
          | dma_write_chnl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
    (
  core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_iswt0, dma_write_chnl_rsci_ivld_core_psct,
      dma_write_chnl_rsci_irdy, dma_write_chnl_rsci_biwt, dma_write_chnl_rsci_bdwt,
      dma_write_chnl_rsci_bcwt, dma_write_chnl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_write_chnl_rsci_oswt_unreg;
  input dma_write_chnl_rsci_iswt0;
  input dma_write_chnl_rsci_ivld_core_psct;
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
  assign dma_write_chnl_rsci_ivld_core_sct = dma_write_chnl_rsci_ivld_core_psct &
      dma_write_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
    (
  clk, rst, dma_write_ctrl_rsci_oswt, dma_write_ctrl_rsci_wen_comp, dma_write_ctrl_rsci_biwt,
      dma_write_ctrl_rsci_bdwt, dma_write_ctrl_rsci_bcwt
);
  input clk;
  input rst;
  input dma_write_ctrl_rsci_oswt;
  output dma_write_ctrl_rsci_wen_comp;
  input dma_write_ctrl_rsci_biwt;
  input dma_write_ctrl_rsci_bdwt;
  output dma_write_ctrl_rsci_bcwt;
  reg dma_write_ctrl_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_wen_comp = (~ dma_write_ctrl_rsci_oswt) | dma_write_ctrl_rsci_biwt
      | dma_write_ctrl_rsci_bcwt;
  always @(posedge clk) begin
    if ( rst ) begin
      dma_write_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_ctrl_rsci_bcwt <= ~((~(dma_write_ctrl_rsci_bcwt | dma_write_ctrl_rsci_biwt))
          | dma_write_ctrl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
    (
  core_wen, dma_write_ctrl_rsci_oswt, dma_write_ctrl_rsci_irdy, dma_write_ctrl_rsci_biwt,
      dma_write_ctrl_rsci_bdwt, dma_write_ctrl_rsci_bcwt, dma_write_ctrl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_write_ctrl_rsci_oswt;
  input dma_write_ctrl_rsci_irdy;
  output dma_write_ctrl_rsci_biwt;
  output dma_write_ctrl_rsci_bdwt;
  input dma_write_ctrl_rsci_bcwt;
  output dma_write_ctrl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_write_ctrl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bdwt = dma_write_ctrl_rsci_oswt & core_wen;
  assign dma_write_ctrl_rsci_biwt = dma_write_ctrl_rsci_ogwt & dma_write_ctrl_rsci_irdy;
  assign dma_write_ctrl_rsci_ogwt = dma_write_ctrl_rsci_oswt & (~ dma_write_ctrl_rsci_bcwt);
  assign dma_write_ctrl_rsci_ivld_core_sct = dma_write_ctrl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsci_1_plm_out_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsci_1_plm_out_rsc_wait_dp (
  clk, rst, plm_out_rsci_q_d, plm_out_rsci_bawt, plm_out_rsci_q_d_mxwt, plm_out_rsci_biwt,
      plm_out_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_out_rsci_q_d;
  output plm_out_rsci_bawt;
  output [31:0] plm_out_rsci_q_d_mxwt;
  input plm_out_rsci_biwt;
  input plm_out_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_rsci_bcwt;
  reg [31:0] plm_out_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bawt = plm_out_rsci_biwt | plm_out_rsci_bcwt;
  assign plm_out_rsci_q_d_mxwt = MUX_v_32_2_2(plm_out_rsci_q_d, plm_out_rsci_q_d_bfwt,
      plm_out_rsci_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_out_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsci_bcwt <= ~((~(plm_out_rsci_bcwt | plm_out_rsci_biwt)) | plm_out_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_out_rsci_biwt ) begin
      plm_out_rsci_q_d_bfwt <= plm_out_rsci_q_d;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl (
  core_wen, core_wten, plm_out_rsci_oswt_unreg, plm_out_rsci_iswt0, plm_out_rsci_biwt,
      plm_out_rsci_bdwt, plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      plm_out_rsci_iswt0_pff
);
  input core_wen;
  input core_wten;
  input plm_out_rsci_oswt_unreg;
  input plm_out_rsci_iswt0;
  output plm_out_rsci_biwt;
  output plm_out_rsci_bdwt;
  output plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  input plm_out_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bdwt = plm_out_rsci_oswt_unreg & core_wen;
  assign plm_out_rsci_biwt = (~ core_wten) & plm_out_rsci_iswt0;
  assign plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_out_rsci_iswt0_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_conf_rsci_plm_conf_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_conf_rsci_plm_conf_wait_dp (
  clk, rst, plm_conf_rsci_oswt, plm_conf_rsci_wen_comp, plm_conf_rsci_idat_mxwt,
      plm_conf_rsci_biwt, plm_conf_rsci_bdwt, plm_conf_rsci_bcwt, plm_conf_rsci_idat
);
  input clk;
  input rst;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_wen_comp;
  output [31:0] plm_conf_rsci_idat_mxwt;
  input plm_conf_rsci_biwt;
  input plm_conf_rsci_bdwt;
  output plm_conf_rsci_bcwt;
  reg plm_conf_rsci_bcwt;
  input [31:0] plm_conf_rsci_idat;


  // Interconnect Declarations
  reg [31:0] plm_conf_rsci_idat_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsci_wen_comp = (~ plm_conf_rsci_oswt) | plm_conf_rsci_biwt | plm_conf_rsci_bcwt;
  assign plm_conf_rsci_idat_mxwt = MUX_v_32_2_2(plm_conf_rsci_idat, plm_conf_rsci_idat_bfwt,
      plm_conf_rsci_bcwt);
  always @(posedge clk) begin
    if ( rst ) begin
      plm_conf_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_conf_rsci_bcwt <= ~((~(plm_conf_rsci_bcwt | plm_conf_rsci_biwt)) | plm_conf_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( plm_conf_rsci_biwt ) begin
      plm_conf_rsci_idat_bfwt <= plm_conf_rsci_idat;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_conf_rsci_plm_conf_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_conf_rsci_plm_conf_wait_ctrl (
  core_wen, plm_conf_rsci_oswt, plm_conf_rsci_biwt, plm_conf_rsci_bdwt, plm_conf_rsci_bcwt,
      plm_conf_rsci_irdy_core_sct, plm_conf_rsci_ivld
);
  input core_wen;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_biwt;
  output plm_conf_rsci_bdwt;
  input plm_conf_rsci_bcwt;
  output plm_conf_rsci_irdy_core_sct;
  input plm_conf_rsci_ivld;


  // Interconnect Declarations
  wire plm_conf_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_rsci_bdwt = plm_conf_rsci_oswt & core_wen;
  assign plm_conf_rsci_biwt = plm_conf_rsci_ogwt & plm_conf_rsci_ivld;
  assign plm_conf_rsci_ogwt = plm_conf_rsci_oswt & (~ plm_conf_rsci_bcwt);
  assign plm_conf_rsci_irdy_core_sct = plm_conf_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core (
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;


  // Interconnect Declarations
  wire debug_rsc_triosy_obj_ld;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_v1 #(.rscid(32'sd36),
  .width(32'sd32)) debug_rsci (
      .idat(32'b00000000000000000000000000000000),
      .dat(debug_rsc_dat)
    );
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) debug_rsc_triosy_obj (
      .ld(debug_rsc_triosy_obj_ld),
      .lz(debug_rsc_triosy_lz)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core softmax_cxx_core_core_inst (
      .clk(clk),
      .rst(rst),
      .debug_rsc_triosy_obj_ld(debug_rsc_triosy_obj_ld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_conf_info_batch_rsc_triosy_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_conf_info_batch_rsc_triosy_obj (
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
  esp_acc_softmax_cxx_config_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl
      config_core_conf_info_batch_rsc_triosy_obj_conf_info_batch_rsc_triosy_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .conf_info_batch_rsc_triosy_obj_iswt0(conf_info_batch_rsc_triosy_obj_iswt0),
      .conf_info_batch_rsc_triosy_obj_ld_core_sct(conf_info_batch_rsc_triosy_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_store_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_store_rsci (
  clk, rst, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      core_wen, plm_conf_store_rsci_oswt, plm_conf_store_rsci_wen_comp, plm_conf_store_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input core_wen;
  input plm_conf_store_rsci_oswt;
  output plm_conf_store_rsci_wen_comp;
  input [31:0] plm_conf_store_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_store_rsci_irdy;
  wire plm_conf_store_rsci_biwt;
  wire plm_conf_store_rsci_bdwt;
  wire plm_conf_store_rsci_bcwt;
  wire plm_conf_store_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd4),
  .width(32'sd32)) plm_conf_store_rsci (
      .irdy(plm_conf_store_rsci_irdy),
      .ivld(plm_conf_store_rsci_ivld_core_sct),
      .idat(plm_conf_store_rsci_idat),
      .rdy(plm_conf_store_rsc_rdy),
      .vld(plm_conf_store_rsc_vld),
      .dat(plm_conf_store_rsc_dat)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_store_rsci_oswt(plm_conf_store_rsci_oswt),
      .plm_conf_store_rsci_irdy(plm_conf_store_rsci_irdy),
      .plm_conf_store_rsci_biwt(plm_conf_store_rsci_biwt),
      .plm_conf_store_rsci_bdwt(plm_conf_store_rsci_bdwt),
      .plm_conf_store_rsci_bcwt(plm_conf_store_rsci_bcwt),
      .plm_conf_store_rsci_ivld_core_sct(plm_conf_store_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp config_core_plm_conf_store_rsci_plm_conf_store_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_store_rsci_oswt(plm_conf_store_rsci_oswt),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .plm_conf_store_rsci_biwt(plm_conf_store_rsci_biwt),
      .plm_conf_store_rsci_bdwt(plm_conf_store_rsci_bdwt),
      .plm_conf_store_rsci_bcwt(plm_conf_store_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci (
  clk, rst, plm_conf_compute_rsc_dat, plm_conf_compute_rsc_vld, plm_conf_compute_rsc_rdy,
      core_wen, plm_conf_compute_rsci_oswt, plm_conf_compute_rsci_wen_comp, plm_conf_compute_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  input core_wen;
  input plm_conf_compute_rsci_oswt;
  output plm_conf_compute_rsci_wen_comp;
  input [31:0] plm_conf_compute_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_compute_rsci_irdy;
  wire plm_conf_compute_rsci_biwt;
  wire plm_conf_compute_rsci_bdwt;
  wire plm_conf_compute_rsci_bcwt;
  wire plm_conf_compute_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd3),
  .width(32'sd32)) plm_conf_compute_rsci (
      .irdy(plm_conf_compute_rsci_irdy),
      .ivld(plm_conf_compute_rsci_ivld_core_sct),
      .idat(plm_conf_compute_rsci_idat),
      .rdy(plm_conf_compute_rsc_rdy),
      .vld(plm_conf_compute_rsc_vld),
      .dat(plm_conf_compute_rsc_dat)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
      config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl_inst (
      .core_wen(core_wen),
      .plm_conf_compute_rsci_oswt(plm_conf_compute_rsci_oswt),
      .plm_conf_compute_rsci_irdy(plm_conf_compute_rsci_irdy),
      .plm_conf_compute_rsci_biwt(plm_conf_compute_rsci_biwt),
      .plm_conf_compute_rsci_bdwt(plm_conf_compute_rsci_bdwt),
      .plm_conf_compute_rsci_bcwt(plm_conf_compute_rsci_bcwt),
      .plm_conf_compute_rsci_ivld_core_sct(plm_conf_compute_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
      config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_compute_rsci_oswt(plm_conf_compute_rsci_oswt),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_compute_rsci_biwt(plm_conf_compute_rsci_biwt),
      .plm_conf_compute_rsci_bdwt(plm_conf_compute_rsci_bdwt),
      .plm_conf_compute_rsci_bcwt(plm_conf_compute_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_load_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_load_rsci (
  clk, rst, plm_conf_load_rsc_dat, plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy,
      core_wen, plm_conf_load_rsci_oswt, plm_conf_load_rsci_wen_comp, plm_conf_load_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  input core_wen;
  input plm_conf_load_rsci_oswt;
  output plm_conf_load_rsci_wen_comp;
  input [31:0] plm_conf_load_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_load_rsci_irdy;
  wire plm_conf_load_rsci_biwt;
  wire plm_conf_load_rsci_bdwt;
  wire plm_conf_load_rsci_bcwt;
  wire plm_conf_load_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd2),
  .width(32'sd32)) plm_conf_load_rsci (
      .irdy(plm_conf_load_rsci_irdy),
      .ivld(plm_conf_load_rsci_ivld_core_sct),
      .idat(plm_conf_load_rsci_idat),
      .rdy(plm_conf_load_rsc_rdy),
      .vld(plm_conf_load_rsc_vld),
      .dat(plm_conf_load_rsc_dat)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_load_rsci_oswt(plm_conf_load_rsci_oswt),
      .plm_conf_load_rsci_irdy(plm_conf_load_rsci_irdy),
      .plm_conf_load_rsci_biwt(plm_conf_load_rsci_biwt),
      .plm_conf_load_rsci_bdwt(plm_conf_load_rsci_bdwt),
      .plm_conf_load_rsci_bcwt(plm_conf_load_rsci_bcwt),
      .plm_conf_load_rsci_ivld_core_sct(plm_conf_load_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp config_core_plm_conf_load_rsci_plm_conf_load_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsci_oswt(plm_conf_load_rsci_oswt),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_load_rsci_biwt(plm_conf_load_rsci_biwt),
      .plm_conf_load_rsci_bdwt(plm_conf_load_rsci_bdwt),
      .plm_conf_load_rsci_bcwt(plm_conf_load_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj (
  clk, rst, plm_in_rsc_req_vz, core_wen, plm_in_rsc_req_obj_oswt, plm_in_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_in_rsc_req_vz;
  input core_wen;
  input plm_in_rsc_req_obj_oswt;
  output plm_in_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire plm_in_rsc_req_obj_vd;
  wire plm_in_rsc_req_obj_biwt;
  wire plm_in_rsc_req_obj_bdwt;
  wire plm_in_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_in_sync_v2 #(.valid(32'sd1)) plm_in_rsc_req_obj (
      .vd(plm_in_rsc_req_obj_vd),
      .vz(plm_in_rsc_req_vz)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_in_rsc_req_obj_oswt(plm_in_rsc_req_obj_oswt),
      .plm_in_rsc_req_obj_vd(plm_in_rsc_req_obj_vd),
      .plm_in_rsc_req_obj_biwt(plm_in_rsc_req_obj_biwt),
      .plm_in_rsc_req_obj_bdwt(plm_in_rsc_req_obj_bdwt),
      .plm_in_rsc_req_obj_bcwt(plm_in_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_obj_oswt(plm_in_rsc_req_obj_oswt),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp),
      .plm_in_rsc_req_obj_biwt(plm_in_rsc_req_obj_biwt),
      .plm_in_rsc_req_obj_bdwt(plm_in_rsc_req_obj_bdwt),
      .plm_in_rsc_req_obj_bcwt(plm_in_rsc_req_obj_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj (
  plm_in_rsc_rls_lz, core_wten, plm_in_rsc_rls_obj_iswt0
);
  output plm_in_rsc_rls_lz;
  input core_wten;
  input plm_in_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_in_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_in_rsc_rls_obj (
      .ld(plm_in_rsc_rls_obj_ld_core_sct),
      .lz(plm_in_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_iswt0(plm_in_rsc_rls_obj_iswt0),
      .plm_in_rsc_rls_obj_ld_core_sct(plm_in_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci (
  clk, rst, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy,
      core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_bawt, dma_read_chnl_rsci_iswt0,
      dma_read_chnl_rsci_wen_comp, dma_read_chnl_rsci_irdy_core_psct, dma_read_chnl_rsci_idat_mxwt
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
  input dma_read_chnl_rsci_irdy_core_psct;
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
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd8),
  .width(32'sd64)) dma_read_chnl_rsci (
      .rdy(dma_read_chnl_rsc_rdy),
      .vld(dma_read_chnl_rsc_vld),
      .dat(dma_read_chnl_rsc_dat),
      .irdy(dma_read_chnl_rsci_irdy_core_sct),
      .ivld(dma_read_chnl_rsci_ivld),
      .idat(dma_read_chnl_rsci_idat)
    );
  esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_irdy_core_psct(dma_read_chnl_rsci_irdy_core_psct),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_irdy_core_sct(dma_read_chnl_rsci_irdy_core_sct),
      .dma_read_chnl_rsci_ivld(dma_read_chnl_rsci_ivld)
    );
  esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp load_core_dma_read_chnl_rsci_dma_read_chnl_wait_dp_inst
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci (
  clk, rst, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      core_wen, dma_read_ctrl_rsci_oswt, dma_read_ctrl_rsci_wen_comp, dma_read_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input core_wen;
  input dma_read_ctrl_rsci_oswt;
  output dma_read_ctrl_rsci_wen_comp;
  input [66:0] dma_read_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_read_ctrl_rsci_irdy;
  wire dma_read_ctrl_rsci_biwt;
  wire dma_read_ctrl_rsci_bdwt;
  wire dma_read_ctrl_rsci_bcwt;
  wire dma_read_ctrl_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_read_ctrl_rsci_idat;
  assign nl_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , (dma_read_ctrl_rsci_idat[10:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd7),
  .width(32'sd67)) dma_read_ctrl_rsci (
      .irdy(dma_read_ctrl_rsci_irdy),
      .ivld(dma_read_ctrl_rsci_ivld_core_sct),
      .idat(nl_dma_read_ctrl_rsci_idat[66:0]),
      .rdy(dma_read_ctrl_rsc_rdy),
      .vld(dma_read_ctrl_rsc_vld),
      .dat(dma_read_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .dma_read_ctrl_rsci_oswt(dma_read_ctrl_rsci_oswt),
      .dma_read_ctrl_rsci_irdy(dma_read_ctrl_rsci_irdy),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt),
      .dma_read_ctrl_rsci_bcwt(dma_read_ctrl_rsci_bcwt),
      .dma_read_ctrl_rsci_ivld_core_sct(dma_read_ctrl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsci_oswt(dma_read_ctrl_rsci_oswt),
      .dma_read_ctrl_rsci_wen_comp(dma_read_ctrl_rsci_wen_comp),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt),
      .dma_read_ctrl_rsci_bcwt(dma_read_ctrl_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsci_1 (
  clk, rst, core_wen, core_wten, plm_in_rsci_oswt_unreg, plm_in_rsci_bawt, plm_in_rsci_iswt0,
      plm_in_rsci_we_d_pff, plm_in_rsci_iswt0_pff
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input plm_in_rsci_oswt_unreg;
  output plm_in_rsci_bawt;
  input plm_in_rsci_iswt0;
  output plm_in_rsci_we_d_pff;
  input plm_in_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_rsci_biwt;
  wire plm_in_rsci_bdwt;
  wire plm_in_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_load_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl load_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt_unreg(plm_in_rsci_oswt_unreg),
      .plm_in_rsci_iswt0(plm_in_rsci_iswt0),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_we_d_core_sct_pff(plm_in_rsci_we_d_core_sct_iff),
      .plm_in_rsci_iswt0_pff(plm_in_rsci_iswt0_pff)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsci_1_plm_in_rsc_wait_dp load_core_plm_in_rsci_1_plm_in_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt)
    );
  assign plm_in_rsci_we_d_pff = plm_in_rsci_we_d_core_sct_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_conf_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_conf_rsci (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, core_wen, plm_conf_rsci_oswt,
      plm_conf_rsci_wen_comp, plm_conf_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  input core_wen;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_wen_comp;
  output [31:0] plm_conf_rsci_idat_mxwt;


  // Interconnect Declarations
  wire plm_conf_rsci_biwt;
  wire plm_conf_rsci_bdwt;
  wire plm_conf_rsci_bcwt;
  wire plm_conf_rsci_irdy_core_sct;
  wire plm_conf_rsci_ivld;
  wire [31:0] plm_conf_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd5),
  .width(32'sd32)) plm_conf_rsci (
      .rdy(plm_conf_rsc_rdy),
      .vld(plm_conf_rsc_vld),
      .dat(plm_conf_rsc_dat),
      .irdy(plm_conf_rsci_irdy_core_sct),
      .ivld(plm_conf_rsci_ivld),
      .idat(plm_conf_rsci_idat)
    );
  esp_acc_softmax_cxx_load_core_plm_conf_rsci_plm_conf_wait_ctrl load_core_plm_conf_rsci_plm_conf_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_rsci_oswt(plm_conf_rsci_oswt),
      .plm_conf_rsci_biwt(plm_conf_rsci_biwt),
      .plm_conf_rsci_bdwt(plm_conf_rsci_bdwt),
      .plm_conf_rsci_bcwt(plm_conf_rsci_bcwt),
      .plm_conf_rsci_irdy_core_sct(plm_conf_rsci_irdy_core_sct),
      .plm_conf_rsci_ivld(plm_conf_rsci_ivld)
    );
  esp_acc_softmax_cxx_load_core_plm_conf_rsci_plm_conf_wait_dp load_core_plm_conf_rsci_plm_conf_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsci_oswt(plm_conf_rsci_oswt),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_conf_rsci_idat_mxwt(plm_conf_rsci_idat_mxwt),
      .plm_conf_rsci_biwt(plm_conf_rsci_biwt),
      .plm_conf_rsci_bdwt(plm_conf_rsci_bdwt),
      .plm_conf_rsci_bcwt(plm_conf_rsci_bcwt),
      .plm_conf_rsci_idat(plm_conf_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj (
  clk, rst, plm_out_rsc_req_vz, core_wen, plm_out_rsc_req_obj_oswt, plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_out_rsc_req_vz;
  input core_wen;
  input plm_out_rsc_req_obj_oswt;
  output plm_out_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire plm_out_rsc_req_obj_vd;
  wire plm_out_rsc_req_obj_biwt;
  wire plm_out_rsc_req_obj_bdwt;
  wire plm_out_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_in_sync_v2 #(.valid(32'sd1)) plm_out_rsc_req_obj (
      .vd(plm_out_rsc_req_obj_vd),
      .vz(plm_out_rsc_req_vz)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl
      compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl_inst (
      .core_wen(core_wen),
      .plm_out_rsc_req_obj_oswt(plm_out_rsc_req_obj_oswt),
      .plm_out_rsc_req_obj_vd(plm_out_rsc_req_obj_vd),
      .plm_out_rsc_req_obj_biwt(plm_out_rsc_req_obj_biwt),
      .plm_out_rsc_req_obj_bdwt(plm_out_rsc_req_obj_bdwt),
      .plm_out_rsc_req_obj_bcwt(plm_out_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_obj_oswt(plm_out_rsc_req_obj_oswt),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp),
      .plm_out_rsc_req_obj_biwt(plm_out_rsc_req_obj_biwt),
      .plm_out_rsc_req_obj_bdwt(plm_out_rsc_req_obj_bdwt),
      .plm_out_rsc_req_obj_bcwt(plm_out_rsc_req_obj_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj (
  clk, rst, plm_in_rsc_req_vz, core_wen, plm_in_rsc_req_obj_oswt, plm_in_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_in_rsc_req_vz;
  input core_wen;
  input plm_in_rsc_req_obj_oswt;
  output plm_in_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire plm_in_rsc_req_obj_vd;
  wire plm_in_rsc_req_obj_biwt;
  wire plm_in_rsc_req_obj_bdwt;
  wire plm_in_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_in_sync_v2 #(.valid(32'sd1)) plm_in_rsc_req_obj (
      .vd(plm_in_rsc_req_obj_vd),
      .vz(plm_in_rsc_req_vz)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_in_rsc_req_obj_oswt(plm_in_rsc_req_obj_oswt),
      .plm_in_rsc_req_obj_vd(plm_in_rsc_req_obj_vd),
      .plm_in_rsc_req_obj_biwt(plm_in_rsc_req_obj_biwt),
      .plm_in_rsc_req_obj_bdwt(plm_in_rsc_req_obj_bdwt),
      .plm_in_rsc_req_obj_bcwt(plm_in_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_obj_oswt(plm_in_rsc_req_obj_oswt),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp),
      .plm_in_rsc_req_obj_biwt(plm_in_rsc_req_obj_biwt),
      .plm_in_rsc_req_obj_bdwt(plm_in_rsc_req_obj_bdwt),
      .plm_in_rsc_req_obj_bcwt(plm_in_rsc_req_obj_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj (
  plm_in_rsc_rls_lz, core_wten, plm_in_rsc_rls_obj_iswt0
);
  output plm_in_rsc_rls_lz;
  input core_wten;
  input plm_in_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_in_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_in_rsc_rls_obj (
      .ld(plm_in_rsc_rls_obj_ld_core_sct),
      .lz(plm_in_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_iswt0(plm_in_rsc_rls_obj_iswt0),
      .plm_in_rsc_rls_obj_ld_core_sct(plm_in_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj (
  plm_out_rsc_rls_lz, core_wten, plm_out_rsc_rls_obj_iswt0
);
  output plm_out_rsc_rls_lz;
  input core_wten;
  input plm_out_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_out_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_out_rsc_rls_obj (
      .ld(plm_out_rsc_rls_obj_ld_core_sct),
      .lz(plm_out_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
      compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl_inst (
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_iswt0(plm_out_rsc_rls_obj_iswt0),
      .plm_out_rsc_rls_obj_ld_core_sct(plm_out_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsci_1 (
  plm_out_rsci_we_d_pff, plm_out_rsci_iswt0_pff, core_wten_pff
);
  output plm_out_rsci_we_d_pff;
  input plm_out_rsci_iswt0_pff;
  input core_wten_pff;


  // Interconnect Declarations
  wire plm_out_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl_inst
      (
      .plm_out_rsci_we_d_core_sct_pff(plm_out_rsci_we_d_core_sct_iff),
      .plm_out_rsci_iswt0_pff(plm_out_rsci_iswt0_pff),
      .core_wten_pff(core_wten_pff)
    );
  assign plm_out_rsci_we_d_pff = plm_out_rsci_we_d_core_sct_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsci_1 (
  clk, rst, plm_in_rsci_q_d, plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d, core_wen,
      core_wten, plm_in_rsci_oswt, plm_in_rsci_q_d_mxwt, plm_in_rsci_oswt_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_rsci_q_d;
  output plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_in_rsci_oswt;
  output [31:0] plm_in_rsci_q_d_mxwt;
  input plm_in_rsci_oswt_pff;


  // Interconnect Declarations
  wire plm_in_rsci_biwt;
  wire plm_in_rsci_bdwt;
  wire plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl compute_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt(plm_in_rsci_oswt),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .plm_in_rsci_oswt_pff(plm_in_rsci_oswt_pff)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_q_d(plm_in_rsci_q_d),
      .plm_in_rsci_q_d_mxwt(plm_in_rsci_q_d_mxwt),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt)
    );
  assign plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_conf_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_conf_rsci (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, core_wen, plm_conf_rsci_oswt,
      plm_conf_rsci_wen_comp, plm_conf_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  input core_wen;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_wen_comp;
  output [31:0] plm_conf_rsci_idat_mxwt;


  // Interconnect Declarations
  wire plm_conf_rsci_biwt;
  wire plm_conf_rsci_bdwt;
  wire plm_conf_rsci_bcwt;
  wire plm_conf_rsci_irdy_core_sct;
  wire plm_conf_rsci_ivld;
  wire [31:0] plm_conf_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd10),
  .width(32'sd32)) plm_conf_rsci (
      .rdy(plm_conf_rsc_rdy),
      .vld(plm_conf_rsc_vld),
      .dat(plm_conf_rsc_dat),
      .irdy(plm_conf_rsci_irdy_core_sct),
      .ivld(plm_conf_rsci_ivld),
      .idat(plm_conf_rsci_idat)
    );
  esp_acc_softmax_cxx_compute_core_plm_conf_rsci_plm_conf_wait_ctrl compute_core_plm_conf_rsci_plm_conf_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_rsci_oswt(plm_conf_rsci_oswt),
      .plm_conf_rsci_biwt(plm_conf_rsci_biwt),
      .plm_conf_rsci_bdwt(plm_conf_rsci_bdwt),
      .plm_conf_rsci_bcwt(plm_conf_rsci_bcwt),
      .plm_conf_rsci_irdy_core_sct(plm_conf_rsci_irdy_core_sct),
      .plm_conf_rsci_ivld(plm_conf_rsci_ivld)
    );
  esp_acc_softmax_cxx_compute_core_plm_conf_rsci_plm_conf_wait_dp compute_core_plm_conf_rsci_plm_conf_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsci_oswt(plm_conf_rsci_oswt),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_conf_rsci_idat_mxwt(plm_conf_rsci_idat_mxwt),
      .plm_conf_rsci_biwt(plm_conf_rsci_biwt),
      .plm_conf_rsci_bdwt(plm_conf_rsci_bdwt),
      .plm_conf_rsci_bcwt(plm_conf_rsci_bcwt),
      .plm_conf_rsci_idat(plm_conf_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj (
  clk, rst, plm_out_rsc_req_vz, core_wen, plm_out_rsc_req_obj_oswt, plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_out_rsc_req_vz;
  input core_wen;
  input plm_out_rsc_req_obj_oswt;
  output plm_out_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  wire plm_out_rsc_req_obj_vd;
  wire plm_out_rsc_req_obj_biwt;
  wire plm_out_rsc_req_obj_bdwt;
  wire plm_out_rsc_req_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_in_sync_v2 #(.valid(32'sd1)) plm_out_rsc_req_obj (
      .vd(plm_out_rsc_req_obj_vd),
      .vz(plm_out_rsc_req_vz)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_out_rsc_req_obj_oswt(plm_out_rsc_req_obj_oswt),
      .plm_out_rsc_req_obj_vd(plm_out_rsc_req_obj_vd),
      .plm_out_rsc_req_obj_biwt(plm_out_rsc_req_obj_biwt),
      .plm_out_rsc_req_obj_bdwt(plm_out_rsc_req_obj_bdwt),
      .plm_out_rsc_req_obj_bcwt(plm_out_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_obj_oswt(plm_out_rsc_req_obj_oswt),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp),
      .plm_out_rsc_req_obj_biwt(plm_out_rsc_req_obj_biwt),
      .plm_out_rsc_req_obj_bdwt(plm_out_rsc_req_obj_bdwt),
      .plm_out_rsc_req_obj_bcwt(plm_out_rsc_req_obj_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj (
  plm_out_rsc_rls_lz, core_wten, plm_out_rsc_rls_obj_iswt0
);
  output plm_out_rsc_rls_lz;
  input core_wten;
  input plm_out_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_out_rsc_rls_obj_ld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_out_rsc_rls_obj (
      .ld(plm_out_rsc_rls_obj_ld_core_sct),
      .lz(plm_out_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_iswt0(plm_out_rsc_rls_obj_iswt0),
      .plm_out_rsc_rls_obj_ld_core_sct(plm_out_rsc_rls_obj_ld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_acc_done_synci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_acc_done_synci (
  acc_done_sync_vld, core_wten, acc_done_synci_iswt0
);
  output acc_done_sync_vld;
  input core_wten;
  input acc_done_synci_iswt0;


  // Interconnect Declarations
  wire acc_done_synci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_vld_v1 #(.rscid(32'sd37)) acc_done_synci (
      .vld(acc_done_sync_vld),
      .ivld(acc_done_synci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_store_core_acc_done_synci_acc_done_wait_ctrl store_core_acc_done_synci_acc_done_wait_ctrl_inst
      (
      .core_wten(core_wten),
      .acc_done_synci_iswt0(acc_done_synci_iswt0),
      .acc_done_synci_ivld_core_sct(acc_done_synci_ivld_core_sct)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci (
  clk, rst, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_bawt, dma_write_chnl_rsci_iswt0,
      dma_write_chnl_rsci_wen_comp, dma_write_chnl_rsci_ivld_core_psct, dma_write_chnl_rsci_idat
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
  input dma_write_chnl_rsci_ivld_core_psct;
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd23),
  .width(32'sd64)) dma_write_chnl_rsci (
      .irdy(dma_write_chnl_rsci_irdy),
      .ivld(dma_write_chnl_rsci_ivld_core_sct),
      .idat(nl_dma_write_chnl_rsci_idat[63:0]),
      .rdy(dma_write_chnl_rsc_rdy),
      .vld(dma_write_chnl_rsc_vld),
      .dat(dma_write_chnl_rsc_dat)
    );
  esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_ivld_core_psct(dma_write_chnl_rsci_ivld_core_psct),
      .dma_write_chnl_rsci_irdy(dma_write_chnl_rsci_irdy),
      .dma_write_chnl_rsci_biwt(dma_write_chnl_rsci_biwt),
      .dma_write_chnl_rsci_bdwt(dma_write_chnl_rsci_bdwt),
      .dma_write_chnl_rsci_bcwt(dma_write_chnl_rsci_bcwt),
      .dma_write_chnl_rsci_ivld_core_sct(dma_write_chnl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp store_core_dma_write_chnl_rsci_dma_write_chnl_wait_dp_inst
      (
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci (
  clk, rst, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      core_wen, dma_write_ctrl_rsci_oswt, dma_write_ctrl_rsci_wen_comp, dma_write_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input core_wen;
  input dma_write_ctrl_rsci_oswt;
  output dma_write_ctrl_rsci_wen_comp;
  input [66:0] dma_write_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_ctrl_rsci_irdy;
  wire dma_write_ctrl_rsci_biwt;
  wire dma_write_ctrl_rsci_bdwt;
  wire dma_write_ctrl_rsci_bcwt;
  wire dma_write_ctrl_rsci_ivld_core_sct;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_write_ctrl_rsci_idat;
  assign nl_dma_write_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , (dma_write_ctrl_rsci_idat[10:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd22),
  .width(32'sd67)) dma_write_ctrl_rsci (
      .irdy(dma_write_ctrl_rsci_irdy),
      .ivld(dma_write_ctrl_rsci_ivld_core_sct),
      .idat(nl_dma_write_ctrl_rsci_idat[66:0]),
      .rdy(dma_write_ctrl_rsc_rdy),
      .vld(dma_write_ctrl_rsc_vld),
      .dat(dma_write_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .dma_write_ctrl_rsci_oswt(dma_write_ctrl_rsci_oswt),
      .dma_write_ctrl_rsci_irdy(dma_write_ctrl_rsci_irdy),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt),
      .dma_write_ctrl_rsci_bcwt(dma_write_ctrl_rsci_bcwt),
      .dma_write_ctrl_rsci_ivld_core_sct(dma_write_ctrl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsci_oswt(dma_write_ctrl_rsci_oswt),
      .dma_write_ctrl_rsci_wen_comp(dma_write_ctrl_rsci_wen_comp),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt),
      .dma_write_ctrl_rsci_bcwt(dma_write_ctrl_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsci_1 (
  clk, rst, plm_out_rsci_q_d, plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d, core_wen,
      core_wten, plm_out_rsci_oswt_unreg, plm_out_rsci_bawt, plm_out_rsci_iswt0,
      plm_out_rsci_q_d_mxwt, plm_out_rsci_iswt0_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_rsci_q_d;
  output plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_out_rsci_oswt_unreg;
  output plm_out_rsci_bawt;
  input plm_out_rsci_iswt0;
  output [31:0] plm_out_rsci_q_d_mxwt;
  input plm_out_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_out_rsci_biwt;
  wire plm_out_rsci_bdwt;
  wire plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_store_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl store_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsci_oswt_unreg(plm_out_rsci_oswt_unreg),
      .plm_out_rsci_iswt0(plm_out_rsci_iswt0),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt),
      .plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .plm_out_rsci_iswt0_pff(plm_out_rsci_iswt0_pff)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsci_1_plm_out_rsc_wait_dp store_core_plm_out_rsci_1_plm_out_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsci_q_d(plm_out_rsci_q_d),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_q_d_mxwt(plm_out_rsci_q_d_mxwt),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt)
    );
  assign plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_conf_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_conf_rsci (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, core_wen, plm_conf_rsci_oswt,
      plm_conf_rsci_wen_comp, plm_conf_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  input core_wen;
  input plm_conf_rsci_oswt;
  output plm_conf_rsci_wen_comp;
  output [31:0] plm_conf_rsci_idat_mxwt;


  // Interconnect Declarations
  wire plm_conf_rsci_biwt;
  wire plm_conf_rsci_bdwt;
  wire plm_conf_rsci_bcwt;
  wire plm_conf_rsci_irdy_core_sct;
  wire plm_conf_rsci_ivld;
  wire [31:0] plm_conf_rsci_idat;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd20),
  .width(32'sd32)) plm_conf_rsci (
      .rdy(plm_conf_rsc_rdy),
      .vld(plm_conf_rsc_vld),
      .dat(plm_conf_rsc_dat),
      .irdy(plm_conf_rsci_irdy_core_sct),
      .ivld(plm_conf_rsci_ivld),
      .idat(plm_conf_rsci_idat)
    );
  esp_acc_softmax_cxx_store_core_plm_conf_rsci_plm_conf_wait_ctrl store_core_plm_conf_rsci_plm_conf_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_rsci_oswt(plm_conf_rsci_oswt),
      .plm_conf_rsci_biwt(plm_conf_rsci_biwt),
      .plm_conf_rsci_bdwt(plm_conf_rsci_bdwt),
      .plm_conf_rsci_bcwt(plm_conf_rsci_bcwt),
      .plm_conf_rsci_irdy_core_sct(plm_conf_rsci_irdy_core_sct),
      .plm_conf_rsci_ivld(plm_conf_rsci_ivld)
    );
  esp_acc_softmax_cxx_store_core_plm_conf_rsci_plm_conf_wait_dp store_core_plm_conf_rsci_plm_conf_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsci_oswt(plm_conf_rsci_oswt),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_conf_rsci_idat_mxwt(plm_conf_rsci_idat_mxwt),
      .plm_conf_rsci_biwt(plm_conf_rsci_biwt),
      .plm_conf_rsci_bdwt(plm_conf_rsci_bdwt),
      .plm_conf_rsci_bcwt(plm_conf_rsci_bcwt),
      .plm_conf_rsci_idat(plm_conf_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core (
  clk, rst, conf_info_batch_rsc_dat, conf_info_batch_rsc_vld, conf_info_batch_rsc_triosy_lz,
      plm_conf_load_rsc_dat, plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy, plm_conf_compute_rsc_dat,
      plm_conf_compute_rsc_vld, plm_conf_compute_rsc_rdy, plm_conf_store_rsc_dat,
      plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] conf_info_batch_rsc_dat;
  input conf_info_batch_rsc_vld;
  output conf_info_batch_rsc_triosy_lz;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;


  // Interconnect Declarations
  wire core_wen;
  wire core_wten;
  wire conf_info_batch_rsci_wen_comp;
  wire [31:0] conf_info_batch_rsci_idat_mxwt;
  wire plm_conf_load_rsci_wen_comp;
  wire plm_conf_compute_rsci_wen_comp;
  wire plm_conf_store_rsci_wen_comp;
  wire [2:0] fsm_output;
  reg reg_plm_conf_load_rsci_oswt_cse;
  reg reg_conf_info_batch_rsci_oswt_cse;
  reg [31:0] reg_plm_conf_load_rsci_idat_cse;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_config_core_conf_info_batch_rsci config_core_conf_info_batch_rsci_inst
      (
      .conf_info_batch_rsc_dat(conf_info_batch_rsc_dat),
      .conf_info_batch_rsc_vld(conf_info_batch_rsc_vld),
      .conf_info_batch_rsci_oswt(reg_conf_info_batch_rsci_oswt_cse),
      .conf_info_batch_rsci_wen_comp(conf_info_batch_rsci_wen_comp),
      .conf_info_batch_rsci_idat_mxwt(conf_info_batch_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_load_rsci config_core_plm_conf_load_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_load_rsci_oswt(reg_plm_conf_load_rsci_oswt_cse),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_load_rsci_idat(reg_plm_conf_load_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci config_core_plm_conf_compute_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_compute_rsci_oswt(reg_plm_conf_load_rsci_oswt_cse),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_compute_rsci_idat(reg_plm_conf_load_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_store_rsci config_core_plm_conf_store_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_store_rsci_oswt(reg_plm_conf_load_rsci_oswt_cse),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .plm_conf_store_rsci_idat(reg_plm_conf_load_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_config_core_conf_info_batch_rsc_triosy_obj config_core_conf_info_batch_rsc_triosy_obj_inst
      (
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
      .core_wten(core_wten),
      .conf_info_batch_rsc_triosy_obj_iswt0(reg_conf_info_batch_rsci_oswt_cse)
    );
  esp_acc_softmax_cxx_config_core_staller config_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_batch_rsci_wen_comp(conf_info_batch_rsci_wen_comp),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_config_core_core_fsm config_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  always @(posedge clk) begin
    if ( rst ) begin
      reg_conf_info_batch_rsci_oswt_cse <= 1'b0;
      reg_plm_conf_load_rsci_oswt_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_conf_info_batch_rsci_oswt_cse <= ~ (fsm_output[1]);
      reg_plm_conf_load_rsci_oswt_cse <= fsm_output[1];
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (fsm_output[1]) ) begin
      reg_plm_conf_load_rsci_idat_cse <= conf_info_batch_rsci_idat_mxwt;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, plm_in_rsc_req_vz,
      plm_in_rsc_rls_lz, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, plm_in_rsci_d_d,
      plm_in_rsci_wadr_d, plm_in_rsci_we_d_pff
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  output [31:0] plm_in_rsci_d_d;
  output [6:0] plm_in_rsci_wadr_d;
  output plm_in_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire core_wten;
  wire plm_conf_rsci_wen_comp;
  wire [31:0] plm_conf_rsci_idat_mxwt;
  wire plm_in_rsci_bawt;
  wire dma_read_ctrl_rsci_wen_comp;
  wire dma_read_chnl_rsci_bawt;
  reg dma_read_chnl_rsci_iswt0;
  wire dma_read_chnl_rsci_wen_comp;
  reg dma_read_chnl_rsci_irdy_core_psct;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt;
  wire plm_in_rsc_req_obj_wen_comp;
  reg [3:0] dma_read_ctrl_rsci_idat_10_7;
  wire [4:0] fsm_output;
  wire or_tmp;
  wire and_dcpl_3;
  wire and_dcpl_4;
  wire and_dcpl_6;
  wire and_dcpl_8;
  wire and_dcpl_12;
  wire and_tmp_2;
  wire or_dcpl_9;
  wire or_dcpl_10;
  wire or_dcpl_11;
  wire or_tmp_4;
  wire or_tmp_17;
  wire and_42_cse;
  wire and_43_cse;
  wire [4:0] LOAD_OUTER_LOOP_b_4_0_sva_2;
  wire [5:0] nl_LOAD_OUTER_LOOP_b_4_0_sva_2;
  reg LOAD_INNER_LOOP_stage_0_1;
  reg LOAD_INNER_LOOP_stage_0;
  reg LOAD_INNER_LOOP_stage_v_1;
  reg LOAD_INNER_LOOP_stage_v;
  reg reg_plm_conf_rsci_oswt_cse;
  reg reg_plm_in_rsci_iswt0_cse;
  reg reg_dma_read_ctrl_rsci_oswt_cse;
  reg reg_plm_in_rsc_rls_obj_iswt0_cse;
  wire LOAD_INNER_LOOP_data_ac_and_cse;
  reg [31:0] plm_in_rsci_d_d_reg;
  wire [31:0] LOAD_INNER_LOOP_data_ac_mux_rmff;
  reg [6:0] plm_in_rsci_wadr_d_reg;
  wire [6:0] LOAD_INNER_LOOP_i_mux_rmff;
  wire plm_in_rsci_we_d_iff;
  wire and_47_rmff;
  wire or_25_itm;
  wire [32:0] z_out;
  reg [31:0] batch_sva;
  reg [3:0] offset_10_7_sva_1;
  reg [3:0] LOAD_OUTER_LOOP_b_4_0_sva_3_0;
  reg [6:0] LOAD_INNER_LOOP_i_7_0_sva_6_0;

  wire[0:0] LOAD_OUTER_LOOP_not_1_nl;
  wire[3:0] LOAD_OUTER_LOOP_b_mux_nl;
  wire[0:0] not_nl;
  wire[6:0] LOAD_INNER_LOOP_i_mux_2_nl;
  wire[0:0] or_15_nl;
  wire[0:0] LOAD_INNER_LOOP_mux_nl;
  wire[33:0] acc_nl;
  wire[34:0] nl_acc_nl;
  wire[0:0] operator_32_false_operator_32_false_or_1_nl;
  wire[24:0] operator_32_false_operator_32_false_operator_32_false_nor_1_nl;
  wire[0:0] operator_32_false_or_3_nl;
  wire[2:0] operator_32_false_operator_32_false_and_2_nl;
  wire[2:0] operator_32_false_mux_1_nl;
  wire[0:0] operator_32_false_nor_5_nl;
  wire[3:0] operator_32_false_mux1h_2_nl;
  wire[0:0] operator_32_false_or_4_nl;
  wire[31:0] operator_32_false_operator_32_false_mux_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_load_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg;
  assign nl_load_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg = and_dcpl_3 & (fsm_output[3]);
  wire [66:0] nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_load_core_core_fsm_inst_main_C_0_tr0;
  assign nl_load_core_core_fsm_inst_main_C_0_tr0 = ~ (z_out[32]);
  wire [0:0] nl_load_core_core_fsm_inst_LOAD_OUTER_LOOP_C_1_tr0;
  assign nl_load_core_core_fsm_inst_LOAD_OUTER_LOOP_C_1_tr0 = (~ (z_out[32])) | (LOAD_OUTER_LOOP_b_4_0_sva_2[4]);
  esp_acc_softmax_cxx_load_core_plm_conf_rsci load_core_plm_conf_rsci_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_rsc_dat),
      .plm_conf_rsc_vld(plm_conf_rsc_vld),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_rsci_oswt(reg_plm_conf_rsci_oswt_cse),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_conf_rsci_idat_mxwt(plm_conf_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsci_1 load_core_plm_in_rsci_1_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt_unreg(nl_load_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg[0:0]),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_iswt0(reg_plm_in_rsci_iswt0_cse),
      .plm_in_rsci_we_d_pff(plm_in_rsci_we_d_iff),
      .plm_in_rsci_iswt0_pff(and_47_rmff)
    );
  esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci load_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_ctrl_rsci_oswt(reg_dma_read_ctrl_rsci_oswt_cse),
      .dma_read_ctrl_rsci_wen_comp(dma_read_ctrl_rsci_wen_comp),
      .dma_read_ctrl_rsci_idat(nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci load_core_dma_read_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(and_47_rmff),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_irdy_core_psct(dma_read_chnl_rsci_irdy_core_psct),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj load_core_plm_in_rsc_rls_obj_inst
      (
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_iswt0(reg_plm_in_rsc_rls_obj_iswt0_cse)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj load_core_plm_in_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .core_wen(core_wen),
      .plm_in_rsc_req_obj_oswt(reg_dma_read_ctrl_rsci_oswt_cse),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_load_core_staller load_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .dma_read_ctrl_rsci_wen_comp(dma_read_ctrl_rsci_wen_comp),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_load_core_core_fsm load_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .main_C_0_tr0(nl_load_core_core_fsm_inst_main_C_0_tr0[0:0]),
      .LOAD_INNER_LOOP_C_0_tr0(and_dcpl_4),
      .LOAD_OUTER_LOOP_C_1_tr0(nl_load_core_core_fsm_inst_LOAD_OUTER_LOOP_C_1_tr0[0:0])
    );
  assign LOAD_INNER_LOOP_data_ac_and_cse = core_wen & ((and_dcpl_8 & (fsm_output[3]))
      | (fsm_output[2]) | or_tmp_4);
  assign and_47_rmff = and_tmp_2 & (fsm_output[3]);
  assign or_25_itm = and_42_cse | and_43_cse;
  assign LOAD_INNER_LOOP_i_mux_rmff = MUX_v_7_2_2(LOAD_INNER_LOOP_i_7_0_sva_6_0,
      plm_in_rsci_wadr_d_reg, or_tmp_17);
  assign LOAD_INNER_LOOP_data_ac_mux_rmff = MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt,
      plm_in_rsci_d_d_reg, or_tmp_17);
  assign nl_LOAD_OUTER_LOOP_b_4_0_sva_2 = conv_u2u_4_5(LOAD_OUTER_LOOP_b_4_0_sva_3_0)
      + 5'b00001;
  assign LOAD_OUTER_LOOP_b_4_0_sva_2 = nl_LOAD_OUTER_LOOP_b_4_0_sva_2[4:0];
  assign or_tmp = plm_in_rsci_bawt | (~ LOAD_INNER_LOOP_stage_v_1);
  assign and_dcpl_3 = LOAD_INNER_LOOP_stage_v_1 & plm_in_rsci_bawt;
  assign and_dcpl_4 = and_dcpl_3 & (~ LOAD_INNER_LOOP_stage_0_1) & (~ LOAD_INNER_LOOP_stage_0);
  assign and_dcpl_6 = or_tmp & dma_read_chnl_rsci_bawt;
  assign and_dcpl_8 = (~((~(and_dcpl_6 & LOAD_INNER_LOOP_stage_0_1 & (~ (z_out[7]))))
      & LOAD_INNER_LOOP_stage_v)) & LOAD_INNER_LOOP_stage_0;
  assign and_dcpl_12 = or_tmp & dma_read_chnl_rsci_bawt & LOAD_INNER_LOOP_stage_v
      & ((z_out[7]) | (~ LOAD_INNER_LOOP_stage_0)) & LOAD_INNER_LOOP_stage_0_1;
  assign and_tmp_2 = LOAD_INNER_LOOP_stage_0_1 & LOAD_INNER_LOOP_stage_v & dma_read_chnl_rsci_bawt
      & or_tmp;
  assign or_dcpl_9 = ~(LOAD_INNER_LOOP_stage_v & LOAD_INNER_LOOP_stage_0_1);
  assign or_dcpl_10 = (~ and_dcpl_6) | or_dcpl_9;
  assign or_dcpl_11 = ~(dma_read_chnl_rsci_bawt & LOAD_INNER_LOOP_stage_v);
  assign or_tmp_4 = and_dcpl_12 & (fsm_output[3]);
  assign and_42_cse = (z_out[32]) & (fsm_output[1]);
  assign and_43_cse = (z_out[32]) & (~ (LOAD_OUTER_LOOP_b_4_0_sva_2[4])) & (fsm_output[4]);
  assign or_tmp_17 = or_dcpl_10 | (~ (fsm_output[3]));
  assign plm_in_rsci_d_d = LOAD_INNER_LOOP_data_ac_mux_rmff;
  assign plm_in_rsci_wadr_d = LOAD_INNER_LOOP_i_mux_rmff;
  assign plm_in_rsci_we_d_pff = plm_in_rsci_we_d_iff;
  always @(posedge clk) begin
    if ( LOAD_INNER_LOOP_data_ac_and_cse ) begin
      dma_read_chnl_rsci_irdy_core_psct <= ~ or_tmp_4;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      dma_read_chnl_rsci_iswt0 <= 1'b0;
    end
    else if ( LOAD_INNER_LOOP_data_ac_and_cse ) begin
      dma_read_chnl_rsci_iswt0 <= ~ or_tmp_4;
    end
  end
  always @(posedge clk) begin
    if ( core_wen ) begin
      plm_in_rsci_wadr_d_reg <= LOAD_INNER_LOOP_i_mux_rmff;
      plm_in_rsci_d_d_reg <= LOAD_INNER_LOOP_data_ac_mux_rmff;
      LOAD_OUTER_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, LOAD_OUTER_LOOP_b_mux_nl,
          not_nl);
      LOAD_INNER_LOOP_i_7_0_sva_6_0 <= MUX_v_7_2_2(7'b0000000, LOAD_INNER_LOOP_i_mux_2_nl,
          (fsm_output[3]));
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_plm_conf_rsci_oswt_cse <= 1'b0;
      reg_plm_in_rsci_iswt0_cse <= 1'b0;
      reg_dma_read_ctrl_rsci_oswt_cse <= 1'b0;
      reg_plm_in_rsc_rls_obj_iswt0_cse <= 1'b0;
      LOAD_INNER_LOOP_stage_v <= 1'b0;
      LOAD_INNER_LOOP_stage_0 <= 1'b0;
      LOAD_INNER_LOOP_stage_v_1 <= 1'b0;
      LOAD_INNER_LOOP_stage_0_1 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_plm_conf_rsci_oswt_cse <= ~((fsm_output[3:2]!=2'b00) | and_42_cse | and_43_cse);
      reg_plm_in_rsci_iswt0_cse <= and_47_rmff;
      reg_dma_read_ctrl_rsci_oswt_cse <= or_25_itm;
      reg_plm_in_rsc_rls_obj_iswt0_cse <= and_dcpl_4 & (fsm_output[3]);
      LOAD_INNER_LOOP_stage_v <= (LOAD_INNER_LOOP_stage_v & (~ and_dcpl_12)) | and_dcpl_8
          | (~ (fsm_output[3]));
      LOAD_INNER_LOOP_stage_0 <= ~((~(LOAD_INNER_LOOP_stage_0 & ((~ and_dcpl_6) |
          or_dcpl_9 | (~ (z_out[7]))))) & (fsm_output[3]));
      LOAD_INNER_LOOP_stage_v_1 <= ((LOAD_INNER_LOOP_stage_v_1 & (~((or_dcpl_11 |
          (~ LOAD_INNER_LOOP_stage_0_1)) & and_dcpl_3))) | and_tmp_2) & (fsm_output[3]);
      LOAD_INNER_LOOP_stage_0_1 <= ~((~(LOAD_INNER_LOOP_mux_nl & (~(and_dcpl_6 &
          LOAD_INNER_LOOP_stage_v & LOAD_INNER_LOOP_stage_0_1 & (z_out[7]))))) &
          (fsm_output[3]));
    end
  end
  always @(posedge clk) begin
    if ( core_wen & or_25_itm ) begin
      dma_read_ctrl_rsci_idat_10_7 <= MUX_v_4_2_2(4'b0000, offset_10_7_sva_1, LOAD_OUTER_LOOP_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( core_wen & ((fsm_output[1:0]!=2'b00)) ) begin
      batch_sva <= plm_conf_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (~ (fsm_output[3])) ) begin
      offset_10_7_sva_1 <= z_out[3:0];
    end
  end
  assign LOAD_OUTER_LOOP_b_mux_nl = MUX_v_4_2_2(LOAD_OUTER_LOOP_b_4_0_sva_3_0, (LOAD_OUTER_LOOP_b_4_0_sva_2[3:0]),
      fsm_output[4]);
  assign not_nl = ~ (fsm_output[1]);
  assign or_15_nl = (LOAD_INNER_LOOP_stage_v_1 & (~ plm_in_rsci_bawt)) | or_dcpl_11;
  assign LOAD_INNER_LOOP_i_mux_2_nl = MUX_v_7_2_2((z_out[6:0]), LOAD_INNER_LOOP_i_7_0_sva_6_0,
      or_15_nl);
  assign LOAD_INNER_LOOP_mux_nl = MUX_s_1_2_2(LOAD_INNER_LOOP_stage_0, LOAD_INNER_LOOP_stage_0_1,
      or_dcpl_10);
  assign LOAD_OUTER_LOOP_not_1_nl = ~ and_42_cse;
  assign operator_32_false_operator_32_false_or_1_nl = (~((fsm_output[3:2]!=2'b00)))
      | (fsm_output[1]) | (fsm_output[4]);
  assign operator_32_false_or_3_nl = (fsm_output[4:2]!=3'b000);
  assign operator_32_false_operator_32_false_operator_32_false_nor_1_nl = ~(MUX_v_25_2_2((plm_conf_rsci_idat_mxwt[31:7]),
      25'b1111111111111111111111111, operator_32_false_or_3_nl));
  assign operator_32_false_mux_1_nl = MUX_v_3_2_2((~ (plm_conf_rsci_idat_mxwt[6:4])),
      (LOAD_INNER_LOOP_i_7_0_sva_6_0[6:4]), fsm_output[3]);
  assign operator_32_false_nor_5_nl = ~((fsm_output[2]) | (fsm_output[4]));
  assign operator_32_false_operator_32_false_and_2_nl = MUX_v_3_2_2(3'b000, operator_32_false_mux_1_nl,
      operator_32_false_nor_5_nl);
  assign operator_32_false_mux1h_2_nl = MUX1HOT_v_4_4_2(dma_read_ctrl_rsci_idat_10_7,
      (~ (plm_conf_rsci_idat_mxwt[3:0])), (LOAD_OUTER_LOOP_b_4_0_sva_2[3:0]), (LOAD_INNER_LOOP_i_7_0_sva_6_0[3:0]),
      {(fsm_output[2]) , (fsm_output[1]) , (fsm_output[4]) , (fsm_output[3])});
  assign operator_32_false_or_4_nl = (~((fsm_output[3:1]!=3'b000))) | (fsm_output[4]);
  assign operator_32_false_operator_32_false_mux_1_nl = MUX_v_32_2_2(32'b00000000000000000000000000000001,
      (~ batch_sva), fsm_output[4]);
  assign nl_acc_nl = ({operator_32_false_operator_32_false_or_1_nl , operator_32_false_operator_32_false_operator_32_false_nor_1_nl
      , operator_32_false_operator_32_false_and_2_nl , operator_32_false_mux1h_2_nl
      , operator_32_false_or_4_nl}) + conv_u2u_33_34({operator_32_false_operator_32_false_mux_1_nl
      , 1'b1});
  assign acc_nl = nl_acc_nl[33:0];
  assign z_out = readslicef_34_33_1(acc_nl);

  function automatic [3:0] MUX1HOT_v_4_4_2;
    input [3:0] input_3;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [3:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    result = result | ( input_3 & {4{sel[3]}});
    MUX1HOT_v_4_4_2 = result;
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


  function automatic [2:0] MUX_v_3_2_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input [0:0] sel;
    reg [2:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_3_2_2 = result;
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


  function automatic [32:0] readslicef_34_33_1;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 1;
    readslicef_34_33_1 = tmp[32:0];
  end
  endfunction


  function automatic [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction


  function automatic [33:0] conv_u2u_33_34 ;
    input [32:0]  vector ;
  begin
    conv_u2u_33_34 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, plm_in_rsc_req_vz,
      plm_in_rsc_rls_lz, plm_out_rsc_req_vz, plm_out_rsc_rls_lz, plm_in_rsci_q_d,
      plm_in_rsci_radr_d, plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d, plm_out_rsci_d_d,
      plm_out_rsci_wadr_d, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      CALC_SOFTMAX_LOOP_mul_cmp_b, CALC_SOFTMAX_LOOP_mul_cmp_z, plm_out_rsci_we_d_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;
  input [31:0] plm_in_rsci_q_d;
  output [6:0] plm_in_rsci_radr_d;
  output plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output [31:0] plm_out_rsci_d_d;
  output [6:0] plm_out_rsci_wadr_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d;
  output [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  output [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d;
  output [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output [93:0] CALC_SOFTMAX_LOOP_mul_cmp_b;
  input [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  output plm_out_rsci_we_d_pff;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire core_wten;
  wire plm_conf_rsci_wen_comp;
  wire [31:0] plm_conf_rsci_idat_mxwt;
  wire [31:0] plm_in_rsci_q_d_mxwt;
  reg [6:0] plm_in_rsci_radr_d_core;
  wire plm_in_rsc_req_obj_wen_comp;
  wire plm_out_rsc_req_obj_wen_comp;
  wire [6:0] fsm_output;
  wire CALC_EXP_LOOP_and_tmp;
  wire and_dcpl_5;
  wire and_dcpl_6;
  wire and_dcpl_10;
  wire and_dcpl_11;
  wire or_tmp_10;
  wire or_tmp_33;
  wire and_25_cse;
  wire and_26_cse;
  wire [4:0] COMPUTE_LOOP_b_4_0_sva_2;
  wire [5:0] nl_COMPUTE_LOOP_b_4_0_sva_2;
  wire [7:0] SUM_EXP_LOOP_i_7_0_sva_2;
  wire [8:0] nl_SUM_EXP_LOOP_i_7_0_sva_2;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva;
  reg CALC_SOFTMAX_LOOP_stage_0_4;
  reg CALC_SOFTMAX_LOOP_stage_0_3;
  reg CALC_EXP_LOOP_asn_1_itm_1;
  reg CALC_SOFTMAX_LOOP_stage_0_5;
  reg CALC_EXP_LOOP_stage_0_3;
  reg CALC_EXP_LOOP_stage_0;
  reg CALC_EXP_LOOP_asn_1_itm_2;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [74:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  reg reg_plm_conf_rsci_oswt_cse;
  reg reg_plm_out_rsc_rls_obj_iswt0_cse;
  reg reg_plm_in_rsc_rls_obj_iswt0_cse;
  reg reg_plm_in_rsc_req_obj_oswt_cse;
  wire plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_28_rmff;
  wire plm_out_rsci_we_d_iff;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
  reg [6:0] CALC_SOFTMAX_LOOP_i_7_0_sva_6_0;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
  wire [93:0] operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [10:0] z_out;
  wire [11:0] nl_z_out;
  wire [32:0] z_out_1;
  wire [72:0] z_out_2;
  reg [31:0] batch_sva;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm;
  reg [10:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_itm_1;
  reg [9:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3;
  reg [3:0] COMPUTE_LOOP_b_4_0_sva_3_0;
  reg [6:0] CALC_EXP_LOOP_i_7_0_sva_6_0;
  reg [6:0] SUM_EXP_LOOP_i_7_0_sva_6_0;
  wire CALC_EXP_LOOP_stage_0_mx0c0;
  wire CALC_EXP_LOOP_stage_0_mx0c1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [6:0] libraries_leading_sign_74_0_2abd7b3cff8691d03642c4ad577461acbee6_1;
  reg reg_plm_in_rsci_oswt_cse_1;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_11_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_14_cse;

  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_mux_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_nand_nl;
  wire[73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_mux_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_or_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_not_nl;
  wire[0:0] CALC_EXP_LOOP_mux_nl;
  wire[6:0] CALC_SOFTMAX_LOOP_i_mux_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_i_not_nl;
  wire[93:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_nl;
  wire[46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire signed [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire[4:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_5_nl;
  wire[2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_nl;
  wire[7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_10_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_16_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_9_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_17_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_12_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_10_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nand_1_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_18_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_13_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_11_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_19_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_12_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_20_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_13_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_21_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_16_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_14_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_22_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_15_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_23_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_16_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_24_nl;
  wire[0:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_19_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_17_nl;
  wire[9:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_25_nl;
  wire[33:0] acc_1_nl;
  wire[34:0] nl_acc_1_nl;
  wire[0:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_or_1_nl;
  wire[24:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_1_nl;
  wire[0:0] COMPUTE_LOOP_if_or_3_nl;
  wire[6:0] COMPUTE_LOOP_if_mux1h_2_nl;
  wire[0:0] COMPUTE_LOOP_if_or_4_nl;
  wire[31:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_mux_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [73:0] nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a;
  assign nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a = {z_out , (ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0])
      , 53'b00000000000000000000000000000000000000000000000000000};
  wire [7:0] nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_s;
  assign nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_s = ({1'b1 , (~ libraries_leading_sign_74_0_2abd7b3cff8691d03642c4ad577461acbee6_1)})
      + 8'b00110111;
  wire [72:0] nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a;
  assign nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a = MUX_v_73_2_2(({52'b0000000000000000000000000000000000000000000000000000
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1}),
      (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva[72:0]),
      fsm_output[4]);
  wire [7:0] nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_s;
  assign nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_s = MUX_v_8_2_2(({{1{CALC_SOFTMAX_LOOP_i_7_0_sva_6_0[6]}},
      CALC_SOFTMAX_LOOP_i_7_0_sva_6_0}), ({1'b0 , libraries_leading_sign_74_0_2abd7b3cff8691d03642c4ad577461acbee6_1}),
      fsm_output[4]);
  wire [0:0] nl_compute_core_plm_out_rsci_1_inst_plm_out_rsci_iswt0_pff;
  assign nl_compute_core_plm_out_rsci_1_inst_plm_out_rsci_iswt0_pff = CALC_SOFTMAX_LOOP_stage_0_5
      & (fsm_output[5]);
  wire [0:0] nl_compute_core_plm_out_rsci_1_inst_core_wten_pff;
  assign nl_compute_core_plm_out_rsci_1_inst_core_wten_pff = ~ core_wen;
  wire [0:0] nl_compute_core_core_fsm_inst_main_C_0_tr0;
  assign nl_compute_core_core_fsm_inst_main_C_0_tr0 = ~ (z_out_1[32]);
  wire [0:0] nl_compute_core_core_fsm_inst_COMPUTE_LOOP_C_2_tr0;
  assign nl_compute_core_core_fsm_inst_COMPUTE_LOOP_C_2_tr0 = (~ (z_out_1[32])) |
      (COMPUTE_LOOP_b_4_0_sva_2[4]);
  esp_acc_softmax_cxx_mgc_shift_br_v5 #(.width_a(32'sd74),
  .signd_a(32'sd0),
  .width_s(32'sd8),
  .width_z(32'sd94)) operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg (
      .a(nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a[73:0]),
      .s(nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_s[7:0]),
      .z(operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm)
    );
  esp_acc_softmax_cxx_leading_sign_74_0  leading_sign_74_0_rg (
      .mantissa(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva),
      .rtn(libraries_leading_sign_74_0_2abd7b3cff8691d03642c4ad577461acbee6_1)
    );
  esp_acc_softmax_cxx_mgc_shift_bl_v5 #(.width_a(32'sd73),
  .signd_a(32'sd0),
  .width_s(32'sd8),
  .width_z(32'sd73)) operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a[72:0]),
      .s(nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_s[7:0]),
      .z(z_out_2)
    );
  esp_acc_softmax_cxx_compute_core_plm_conf_rsci compute_core_plm_conf_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_rsc_dat),
      .plm_conf_rsc_vld(plm_conf_rsc_vld),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_rsci_oswt(reg_plm_conf_rsci_oswt_cse),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_conf_rsci_idat_mxwt(plm_conf_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsci_1 compute_core_plm_in_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_q_d(plm_in_rsci_q_d),
      .plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt(reg_plm_in_rsci_oswt_cse_1),
      .plm_in_rsci_q_d_mxwt(plm_in_rsci_q_d_mxwt),
      .plm_in_rsci_oswt_pff(and_28_rmff)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsci_1 compute_core_plm_out_rsci_1_inst
      (
      .plm_out_rsci_we_d_pff(plm_out_rsci_we_d_iff),
      .plm_out_rsci_iswt0_pff(nl_compute_core_plm_out_rsci_1_inst_plm_out_rsci_iswt0_pff[0:0]),
      .core_wten_pff(nl_compute_core_plm_out_rsci_1_inst_core_wten_pff[0:0])
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj compute_core_plm_out_rsc_rls_obj_inst
      (
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_iswt0(reg_plm_out_rsc_rls_obj_iswt0_cse)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj compute_core_plm_in_rsc_rls_obj_inst
      (
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_iswt0(reg_plm_in_rsc_rls_obj_iswt0_cse)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj compute_core_plm_in_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .core_wen(core_wen),
      .plm_in_rsc_req_obj_oswt(reg_plm_in_rsc_req_obj_oswt_cse),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj compute_core_plm_out_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .core_wen(core_wen),
      .plm_out_rsc_req_obj_oswt(reg_plm_in_rsc_req_obj_oswt_cse),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_staller compute_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_core_fsm compute_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .main_C_0_tr0(nl_compute_core_core_fsm_inst_main_C_0_tr0[0:0]),
      .CALC_EXP_LOOP_C_0_tr0(and_dcpl_6),
      .CALC_SOFTMAX_LOOP_C_0_tr0(and_dcpl_10),
      .COMPUTE_LOOP_C_2_tr0(nl_compute_core_core_fsm_inst_COMPUTE_LOOP_C_2_tr0[0:0])
    );
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d
      = core_wen;
  assign and_28_rmff = CALC_EXP_LOOP_stage_0 & (fsm_output[3]);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva
      + conv_u2u_67_74(z_out_2[66:0]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[73:0];
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0
      = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0,
      CALC_EXP_LOOP_stage_0_3);
  assign CALC_EXP_LOOP_and_tmp = (z_out_1[7]) & (SUM_EXP_LOOP_i_7_0_sva_2[7]);
  assign nl_SUM_EXP_LOOP_i_7_0_sva_2 = conv_u2u_7_8(SUM_EXP_LOOP_i_7_0_sva_6_0) +
      8'b00000001;
  assign SUM_EXP_LOOP_i_7_0_sva_2 = nl_SUM_EXP_LOOP_i_7_0_sva_2[7:0];
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = $signed((plm_in_rsci_q_d_mxwt)) * $signed(16'b0101110001010101);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl[46:0];
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28
      = readslicef_47_19_28(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_5_nl
      = MUX_v_5_4_2(5'b01100, 5'b01110, 5'b10001, 5'b10100, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_nl
      = MUX_v_3_4_2(3'b010, 3'b110, 3'b001, 3'b101, ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = conv_u2u_19_19(({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_5_nl
      , 1'b0 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_nl})
      * (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[9:0]));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_nl
      = MUX_v_8_8_2(8'b00011100, 8'b01001011, 8'b01101100, 8'b10000100, 8'b10010111,
      8'b10100110, 8'b10110011, 8'b10111100, z_out_2[72:70]);
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = $signed(({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_nl}))
      * $signed(conv_u2s_10_11(z_out_2[69:60]));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:0];
  assign nl_COMPUTE_LOOP_b_4_0_sva_2 = conv_u2u_4_5(COMPUTE_LOOP_b_4_0_sva_3_0) +
      5'b00001;
  assign COMPUTE_LOOP_b_4_0_sva_2 = nl_COMPUTE_LOOP_b_4_0_sva_2[4:0];
  assign and_dcpl_5 = ~(CALC_EXP_LOOP_stage_0 | reg_plm_in_rsci_oswt_cse_1);
  assign and_dcpl_6 = and_dcpl_5 & (~ CALC_EXP_LOOP_stage_0_3);
  assign and_dcpl_10 = (~(CALC_EXP_LOOP_stage_0 | CALC_SOFTMAX_LOOP_stage_0_5 | CALC_SOFTMAX_LOOP_stage_0_4))
      & (~(CALC_SOFTMAX_LOOP_stage_0_3 | CALC_EXP_LOOP_asn_1_itm_1));
  assign and_dcpl_11 = ~((fsm_output[1:0]!=2'b00));
  assign and_25_cse = (z_out_1[32]) & (fsm_output[1]);
  assign and_26_cse = (z_out_1[32]) & (~ (COMPUTE_LOOP_b_4_0_sva_2[4])) & (fsm_output[6]);
  assign or_tmp_10 = and_dcpl_6 & (fsm_output[3]);
  assign or_tmp_33 = ~((fsm_output[5]) | (fsm_output[3]));
  assign CALC_EXP_LOOP_stage_0_mx0c0 = (fsm_output[2]) | (fsm_output[4]);
  assign CALC_EXP_LOOP_stage_0_mx0c1 = CALC_EXP_LOOP_stage_0 & CALC_EXP_LOOP_and_tmp
      & (fsm_output[3]);
  assign CALC_SOFTMAX_LOOP_mul_cmp_b = ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm;
  assign plm_in_rsci_radr_d = CALC_EXP_LOOP_i_7_0_sva_6_0;
  assign plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_rsci_d_d = CALC_SOFTMAX_LOOP_mul_cmp_z[94:63];
  assign plm_out_rsci_wadr_d = CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
  assign plm_out_rsci_we_d_pff = plm_out_rsci_we_d_iff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d
      = z_out_2[66:0];
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d
      = CALC_SOFTMAX_LOOP_i_7_0_sva_6_0;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d
      = CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
      = CALC_EXP_LOOP_stage_0_3 & (fsm_output[3]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d
      = CALC_EXP_LOOP_stage_0 & (fsm_output[5]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]==2'b01);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]==2'b11);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse
      = ~((ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]!=2'b00));
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]==2'b10);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      = (z_out_2[72:70]==3'b010);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      = (z_out_2[72:70]==3'b101);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse
      = (z_out_2[72:70]==3'b110);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse
      = (z_out_2[72:70]==3'b111);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      = ~((z_out_2[72:70]!=3'b000));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      = (z_out_2[72:70]==3'b001);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      = (z_out_2[72:70]==3'b011);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      = (z_out_2[72:70]==3'b100);
  always @(posedge clk) begin
    if ( core_wen ) begin
      plm_in_rsci_radr_d_core <= CALC_EXP_LOOP_i_7_0_sva_6_0;
      SUM_EXP_LOOP_i_7_0_sva_6_0 <= MUX_v_7_2_2(7'b0000000, (SUM_EXP_LOOP_i_7_0_sva_2[6:0]),
          (fsm_output[3]));
      CALC_EXP_LOOP_i_7_0_sva_6_0 <= MUX_v_7_2_2(7'b0000000, (z_out_1[6:0]), (fsm_output[3]));
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= plm_in_rsci_radr_d_core;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_itm_1
          <= MUX_v_11_2_2(z_out, ({4'b0000 , CALC_SOFTMAX_LOOP_i_7_0_sva_6_0}), fsm_output[5]);
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1
          <= MUX_v_10_2_2((ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[9:0]),
          ({3'b000 , (ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_acc_itm_1[6:0])}),
          fsm_output[5]);
      CALC_SOFTMAX_LOOP_i_7_0_sva_6_0 <= MUX_v_7_2_2(7'b0000000, CALC_SOFTMAX_LOOP_i_mux_nl,
          CALC_SOFTMAX_LOOP_i_not_nl);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm
          <= MUX_v_94_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_nl,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm,
          fsm_output[5]);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3 <= ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_slc_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_9_0_itm_1[6:0];
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_plm_conf_rsci_oswt_cse <= 1'b0;
      reg_plm_in_rsci_oswt_cse_1 <= 1'b0;
      reg_plm_out_rsc_rls_obj_iswt0_cse <= 1'b0;
      reg_plm_in_rsc_rls_obj_iswt0_cse <= 1'b0;
      reg_plm_in_rsc_req_obj_oswt_cse <= 1'b0;
      CALC_EXP_LOOP_asn_1_itm_2 <= 1'b0;
      CALC_EXP_LOOP_stage_0_3 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      CALC_EXP_LOOP_asn_1_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_stage_0_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_stage_0_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_stage_0_5 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_plm_conf_rsci_oswt_cse <= ~((and_dcpl_11 & (~ (fsm_output[6]))) | and_25_cse
          | and_26_cse);
      reg_plm_in_rsci_oswt_cse_1 <= and_28_rmff;
      reg_plm_out_rsc_rls_obj_iswt0_cse <= and_dcpl_10 & (fsm_output[5]);
      reg_plm_in_rsc_rls_obj_iswt0_cse <= or_tmp_10;
      reg_plm_in_rsc_req_obj_oswt_cse <= and_25_cse | and_26_cse;
      CALC_EXP_LOOP_asn_1_itm_2 <= CALC_EXP_LOOP_asn_1_itm_1;
      CALC_EXP_LOOP_stage_0_3 <= reg_plm_in_rsci_oswt_cse_1 & (fsm_output[3]);
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva
          <= MUX_v_74_2_2(74'b00000000000000000000000000000000000000000000000000000000000000000000000000,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_mux_nl,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_not_nl);
      CALC_EXP_LOOP_asn_1_itm_1 <= CALC_EXP_LOOP_mux_nl & (~ or_tmp_33);
      CALC_SOFTMAX_LOOP_stage_0_3 <= CALC_EXP_LOOP_asn_1_itm_1 & (fsm_output[5]);
      CALC_SOFTMAX_LOOP_stage_0_4 <= CALC_SOFTMAX_LOOP_stage_0_3 & (fsm_output[5]);
      CALC_SOFTMAX_LOOP_stage_0_5 <= CALC_SOFTMAX_LOOP_stage_0_4 & (fsm_output[5]);
    end
  end
  always @(posedge clk) begin
    if ( core_wen & ((fsm_output[6]) | (fsm_output[1])) ) begin
      COMPUTE_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, (COMPUTE_LOOP_b_4_0_sva_2[3:0]),
          (fsm_output[6]));
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (~ and_dcpl_11) ) begin
      batch_sva <= plm_conf_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      CALC_EXP_LOOP_stage_0 <= 1'b0;
    end
    else if ( core_wen & (CALC_EXP_LOOP_stage_0_mx0c0 | CALC_EXP_LOOP_stage_0_mx0c1
        | or_tmp_10 | (fsm_output[5])) ) begin
      CALC_EXP_LOOP_stage_0 <= (~(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_mux_nl
          | CALC_EXP_LOOP_stage_0_mx0c1)) | CALC_EXP_LOOP_stage_0_mx0c0;
    end
  end
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_or_nl
      = (~(CALC_EXP_LOOP_stage_0_3 | (~(and_dcpl_5 & (fsm_output[3]))))) | ((reg_plm_in_rsci_oswt_cse_1
      | CALC_EXP_LOOP_stage_0) & ((~ CALC_EXP_LOOP_stage_0_3) | CALC_EXP_LOOP_asn_1_itm_2)
      & (fsm_output[3])) | (~((fsm_output[3:2]!=2'b00)));
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_mux_nl
      = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_or_nl);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_not_nl
      = ~ (fsm_output[2]);
  assign CALC_EXP_LOOP_mux_nl = MUX_s_1_2_2(CALC_EXP_LOOP_and_tmp, CALC_EXP_LOOP_stage_0,
      fsm_output[5]);
  assign CALC_SOFTMAX_LOOP_i_mux_nl = MUX_v_7_2_2((ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[18:12]),
      (z_out_1[6:0]), fsm_output[5]);
  assign CALC_SOFTMAX_LOOP_i_not_nl = ~ or_tmp_33;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_or_nl
      = MUX_v_94_2_2(operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm, 94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      CALC_EXP_LOOP_stage_0);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_nl = (ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_nand_nl = ~(CALC_EXP_LOOP_stage_0
      & (~ (z_out_1[7])));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_mux_nl = MUX_s_1_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_nl,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_nand_nl, fsm_output[5]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_11_cse
      = (~(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse))
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_14_cse
      = (~((ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]==2'b01)))
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_10_nl
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28[11:10]!=2'b00)
      | (fsm_output[4]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_9_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_16_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_11_cse,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_9_nl,
      fsm_output[4]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_12_nl
      = (~(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse))
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_10_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_17_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_12_nl,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_10_nl,
      fsm_output[4]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nand_1_nl
      = ~((ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse)
      & ((z_out_2[72:70]!=3'b000)) & (~((z_out_2[72:70]==3'b011))) & (~((z_out_2[72:70]==3'b101)))
      & (~((z_out_2[72:70]==3'b110))) & (fsm_output[4]));
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_13_nl
      = (~(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse))
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_11_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_18_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_13_nl,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_11_nl,
      fsm_output[4]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_12_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_19_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_14_cse,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_12_nl,
      fsm_output[4]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_13_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_20_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_11_cse,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_13_nl,
      fsm_output[4]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_16_nl
      = (~(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse))
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_14_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_21_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_16_nl,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_14_nl,
      fsm_output[4]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_15_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_22_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_14_cse,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_15_nl,
      fsm_output[4]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_16_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_23_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_14_cse,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_16_nl,
      fsm_output[4]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_19_nl
      = (~(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_nor_1_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_1_cse))
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_2_cse;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_17_nl
      = (~(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_6_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_1_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_4_cse))
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nor_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_5_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_2_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_3_cse;
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_24_nl
      = MUX_s_1_2_2(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_19_nl,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_or_17_nl,
      fsm_output[4]);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_25_nl
      = MUX_v_10_2_2(({1'b0 , (ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])}),
      (signext_10_9(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])),
      fsm_output[4]);
  assign nl_z_out = ({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_or_10_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_16_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_17_nl
      , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_nand_1_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_18_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_19_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_20_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_21_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_22_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_23_nl
      , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_24_nl})
      + conv_s2u_10_11(ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_25_nl);
  assign z_out = nl_z_out[10:0];
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_or_1_nl = or_tmp_33 | (fsm_output[1]) |
      (fsm_output[6]);
  assign COMPUTE_LOOP_if_or_3_nl = (fsm_output[6]) | (fsm_output[3]) | (fsm_output[5]);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_1_nl = ~(MUX_v_25_2_2((plm_conf_rsci_idat_mxwt[31:7]),
      25'b1111111111111111111111111, COMPUTE_LOOP_if_or_3_nl));
  assign COMPUTE_LOOP_if_mux1h_2_nl = MUX1HOT_v_7_4_2((~ (plm_conf_rsci_idat_mxwt[6:0])),
      ({3'b000 , (COMPUTE_LOOP_b_4_0_sva_2[3:0])}), CALC_EXP_LOOP_i_7_0_sva_6_0,
      CALC_SOFTMAX_LOOP_i_7_0_sva_6_0, {(fsm_output[1]) , (fsm_output[6]) , (fsm_output[3])
      , (fsm_output[5])});
  assign COMPUTE_LOOP_if_or_4_nl = (~((fsm_output[1]) | (fsm_output[3]) | (fsm_output[5])))
      | (fsm_output[6]);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_mux_1_nl = MUX_v_32_2_2(32'b00000000000000000000000000000001,
      (~ batch_sva), fsm_output[6]);
  assign nl_acc_1_nl = ({COMPUTE_LOOP_if_COMPUTE_LOOP_if_or_1_nl , COMPUTE_LOOP_if_COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_1_nl
      , COMPUTE_LOOP_if_mux1h_2_nl , COMPUTE_LOOP_if_or_4_nl}) + conv_u2u_33_34({COMPUTE_LOOP_if_COMPUTE_LOOP_if_mux_1_nl
      , 1'b1});
  assign acc_1_nl = nl_acc_1_nl[33:0];
  assign z_out_1 = readslicef_34_33_1(acc_1_nl);

  function automatic [6:0] MUX1HOT_v_7_4_2;
    input [6:0] input_3;
    input [6:0] input_2;
    input [6:0] input_1;
    input [6:0] input_0;
    input [3:0] sel;
    reg [6:0] result;
  begin
    result = input_0 & {7{sel[0]}};
    result = result | ( input_1 & {7{sel[1]}});
    result = result | ( input_2 & {7{sel[2]}});
    result = result | ( input_3 & {7{sel[3]}});
    MUX1HOT_v_7_4_2 = result;
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


  function automatic [10:0] MUX_v_11_2_2;
    input [10:0] input_0;
    input [10:0] input_1;
    input [0:0] sel;
    reg [10:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_11_2_2 = result;
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


  function automatic [72:0] MUX_v_73_2_2;
    input [72:0] input_0;
    input [72:0] input_1;
    input [0:0] sel;
    reg [72:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_73_2_2 = result;
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


  function automatic [32:0] readslicef_34_33_1;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 1;
    readslicef_34_33_1 = tmp[32:0];
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


  function automatic [9:0] signext_10_9;
    input [8:0] vector;
  begin
    signext_10_9= {{1{vector[8]}}, vector};
  end
  endfunction


  function automatic [10:0] conv_s2u_10_11 ;
    input [9:0]  vector ;
  begin
    conv_s2u_10_11 = {vector[9], vector};
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


  function automatic [18:0] conv_u2u_19_19 ;
    input [18:0]  vector ;
  begin
    conv_u2u_19_19 = vector;
  end
  endfunction


  function automatic [33:0] conv_u2u_33_34 ;
    input [32:0]  vector ;
  begin
    conv_u2u_33_34 = {1'b0, vector};
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
//  Design Unit:    esp_acc_softmax_cxx_store_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, plm_out_rsc_req_vz,
      plm_out_rsc_rls_lz, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_sync_vld,
      plm_out_rsci_q_d, plm_out_rsci_radr_d, plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_sync_vld;
  input [31:0] plm_out_rsci_q_d;
  output [6:0] plm_out_rsci_radr_d;
  output plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d;


  // Interconnect Declarations
  wire core_wen;
  wire core_wten;
  wire plm_conf_rsci_wen_comp;
  wire [31:0] plm_conf_rsci_idat_mxwt;
  wire plm_out_rsci_bawt;
  wire [31:0] plm_out_rsci_q_d_mxwt;
  wire dma_write_ctrl_rsci_wen_comp;
  wire dma_write_chnl_rsci_bawt;
  reg dma_write_chnl_rsci_iswt0;
  wire dma_write_chnl_rsci_wen_comp;
  reg dma_write_chnl_rsci_ivld_core_psct;
  wire plm_out_rsc_req_obj_wen_comp;
  reg [3:0] dma_write_ctrl_rsci_idat_10_7;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [5:0] fsm_output;
  wire or_tmp;
  wire and_dcpl_3;
  wire and_dcpl_5;
  wire or_dcpl_5;
  wire and_dcpl_6;
  wire and_dcpl_7;
  wire and_dcpl_9;
  wire and_dcpl_11;
  wire or_dcpl_9;
  wire and_dcpl_12;
  wire and_dcpl_13;
  wire or_dcpl_10;
  wire and_dcpl_16;
  wire or_dcpl_13;
  wire or_dcpl_14;
  wire or_dcpl_15;
  wire or_tmp_8;
  wire or_tmp_9;
  wire and_53_cse;
  wire [4:0] STORE_OUTER_LOOP_b_4_0_sva_2;
  wire [5:0] nl_STORE_OUTER_LOOP_b_4_0_sva_2;
  reg STORE_INNER_LOOP_stage_0_1;
  reg STORE_INNER_LOOP_stage_0;
  reg STORE_INNER_LOOP_stage_v_2;
  reg STORE_INNER_LOOP_stage_0_2;
  reg STORE_INNER_LOOP_stage_v;
  reg STORE_INNER_LOOP_stage_v_1;
  reg reg_plm_conf_rsci_oswt_cse;
  reg reg_plm_out_rsci_iswt0_cse;
  reg reg_dma_write_ctrl_rsci_oswt_cse;
  reg reg_acc_done_synci_iswt0_cse;
  reg reg_plm_out_rsc_rls_obj_iswt0_cse;
  wire STORE_INNER_LOOP_and_cse;
  reg [6:0] plm_out_rsci_radr_d_reg;
  wire [6:0] STORE_INNER_LOOP_i_mux_rmff;
  wire plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_50_rmff;
  wire or_39_itm;
  wire [32:0] z_out;
  reg [31:0] batch_sva;
  reg [3:0] offset_10_7_sva_1;
  reg [3:0] STORE_OUTER_LOOP_b_4_0_sva_3_0;
  reg [6:0] STORE_INNER_LOOP_i_7_0_sva_6_0;

  wire[0:0] STORE_OUTER_LOOP_not_1_nl;
  wire[0:0] or_20_nl;
  wire[0:0] or_50_nl;
  wire[3:0] STORE_OUTER_LOOP_b_mux_nl;
  wire[0:0] not_nl;
  wire[6:0] STORE_INNER_LOOP_i_mux_2_nl;
  wire[0:0] or_27_nl;
  wire[0:0] STORE_INNER_LOOP_mux_nl;
  wire[0:0] STORE_INNER_LOOP_mux_8_nl;
  wire[0:0] or_32_nl;
  wire[0:0] mux_17_nl;
  wire[0:0] and_108_nl;
  wire[33:0] acc_nl;
  wire[34:0] nl_acc_nl;
  wire[0:0] operator_32_false_operator_32_false_or_1_nl;
  wire[24:0] operator_32_false_operator_32_false_operator_32_false_nor_1_nl;
  wire[0:0] operator_32_false_or_3_nl;
  wire[2:0] operator_32_false_operator_32_false_and_2_nl;
  wire[2:0] operator_32_false_mux_1_nl;
  wire[0:0] operator_32_false_nor_5_nl;
  wire[3:0] operator_32_false_mux1h_2_nl;
  wire[0:0] operator_32_false_or_4_nl;
  wire[31:0] operator_32_false_operator_32_false_mux_1_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_write_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg =
      and_dcpl_3 & (fsm_output[3]);
  wire [63:0] nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat = {32'b11011110101011011011111011101111
      , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_store_core_core_fsm_inst_main_C_0_tr0;
  assign nl_store_core_core_fsm_inst_main_C_0_tr0 = ~ (z_out[32]);
  esp_acc_softmax_cxx_store_core_plm_conf_rsci store_core_plm_conf_rsci_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_rsc_dat),
      .plm_conf_rsc_vld(plm_conf_rsc_vld),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_rsci_oswt(reg_plm_conf_rsci_oswt_cse),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .plm_conf_rsci_idat_mxwt(plm_conf_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsci_1 store_core_plm_out_rsci_1_inst (
      .clk(clk),
      .rst(rst),
      .plm_out_rsci_q_d(plm_out_rsci_q_d),
      .plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsci_oswt_unreg(or_tmp_9),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_iswt0(reg_plm_out_rsci_iswt0_cse),
      .plm_out_rsci_q_d_mxwt(plm_out_rsci_q_d_mxwt),
      .plm_out_rsci_iswt0_pff(and_50_rmff)
    );
  esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci store_core_dma_write_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .dma_write_ctrl_rsci_oswt(reg_dma_write_ctrl_rsci_oswt_cse),
      .dma_write_ctrl_rsci_wen_comp(dma_write_ctrl_rsci_wen_comp),
      .dma_write_ctrl_rsci_idat(nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat[66:0])
    );
  esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci store_core_dma_write_chnl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg[0:0]),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_ivld_core_psct(dma_write_chnl_rsci_ivld_core_psct),
      .dma_write_chnl_rsci_idat(nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat[63:0])
    );
  esp_acc_softmax_cxx_store_core_acc_done_synci store_core_acc_done_synci_inst (
      .acc_done_sync_vld(acc_done_sync_vld),
      .core_wten(core_wten),
      .acc_done_synci_iswt0(reg_acc_done_synci_iswt0_cse)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj store_core_plm_out_rsc_rls_obj_inst
      (
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_iswt0(reg_plm_out_rsc_rls_obj_iswt0_cse)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj store_core_plm_out_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .core_wen(core_wen),
      .plm_out_rsc_req_obj_oswt(reg_dma_write_ctrl_rsci_oswt_cse),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_store_core_staller store_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_conf_rsci_wen_comp(plm_conf_rsci_wen_comp),
      .dma_write_ctrl_rsci_wen_comp(dma_write_ctrl_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_store_core_core_fsm store_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .main_C_0_tr0(nl_store_core_core_fsm_inst_main_C_0_tr0[0:0]),
      .STORE_INNER_LOOP_C_0_tr0(and_dcpl_5),
      .STORE_OUTER_LOOP_C_1_tr0(or_dcpl_5)
    );
  assign STORE_INNER_LOOP_and_cse = core_wen & (or_tmp_8 | or_tmp_9);
  assign and_50_rmff = and_dcpl_13 & (fsm_output[3]);
  assign or_39_itm = and_53_cse | ((z_out[32]) & (~ (STORE_OUTER_LOOP_b_4_0_sva_2[4]))
      & (fsm_output[4]));
  assign or_50_nl = or_dcpl_15 | (~ (fsm_output[3]));
  assign STORE_INNER_LOOP_i_mux_rmff = MUX_v_7_2_2(STORE_INNER_LOOP_i_7_0_sva_6_0,
      plm_out_rsci_radr_d_reg, or_50_nl);
  assign nl_STORE_OUTER_LOOP_b_4_0_sva_2 = conv_u2u_4_5(STORE_OUTER_LOOP_b_4_0_sva_3_0)
      + 5'b00001;
  assign STORE_OUTER_LOOP_b_4_0_sva_2 = nl_STORE_OUTER_LOOP_b_4_0_sva_2[4:0];
  assign or_tmp = dma_write_chnl_rsci_bawt | (~ STORE_INNER_LOOP_stage_v_2);
  assign and_dcpl_3 = STORE_INNER_LOOP_stage_v_2 & dma_write_chnl_rsci_bawt;
  assign and_dcpl_5 = ~((~ and_dcpl_3) | STORE_INNER_LOOP_stage_0_2 | STORE_INNER_LOOP_stage_0_1
      | STORE_INNER_LOOP_stage_0);
  assign or_dcpl_5 = (~ (z_out[32])) | (STORE_OUTER_LOOP_b_4_0_sva_2[4]);
  assign and_dcpl_6 = (~(STORE_INNER_LOOP_stage_v_1 & plm_out_rsci_bawt & STORE_INNER_LOOP_stage_0_2))
      & and_dcpl_3;
  assign and_dcpl_7 = plm_out_rsci_bawt & STORE_INNER_LOOP_stage_0_2;
  assign and_dcpl_9 = or_tmp & STORE_INNER_LOOP_stage_v_1 & and_dcpl_7;
  assign and_dcpl_11 = STORE_INNER_LOOP_stage_0_1 & STORE_INNER_LOOP_stage_v;
  assign or_dcpl_9 = and_dcpl_7 | (~ STORE_INNER_LOOP_stage_v_1);
  assign and_dcpl_12 = or_dcpl_9 & or_tmp;
  assign and_dcpl_13 = and_dcpl_12 & and_dcpl_11;
  assign or_dcpl_10 = ~(plm_out_rsci_bawt & STORE_INNER_LOOP_stage_0_2);
  assign and_dcpl_16 = STORE_INNER_LOOP_stage_v_2 & (~ dma_write_chnl_rsci_bawt);
  assign or_dcpl_13 = ~(STORE_INNER_LOOP_stage_0_1 & STORE_INNER_LOOP_stage_v);
  assign or_dcpl_14 = (or_dcpl_10 & STORE_INNER_LOOP_stage_v_1) | and_dcpl_16;
  assign or_dcpl_15 = or_dcpl_14 | or_dcpl_13;
  assign or_tmp_8 = and_dcpl_6 & (fsm_output[3]);
  assign or_tmp_9 = and_dcpl_9 & (fsm_output[3]);
  assign and_53_cse = (z_out[32]) & (fsm_output[1]);
  assign plm_out_rsci_radr_d = STORE_INNER_LOOP_i_mux_rmff;
  assign plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  always @(posedge clk) begin
    if ( STORE_INNER_LOOP_and_cse ) begin
      dma_write_chnl_rsci_ivld_core_psct <= ~ or_tmp_8;
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      dma_write_chnl_rsci_iswt0 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_cse ) begin
      dma_write_chnl_rsci_iswt0 <= ~ or_tmp_8;
    end
  end
  always @(posedge clk) begin
    if ( core_wen ) begin
      plm_out_rsci_radr_d_reg <= STORE_INNER_LOOP_i_mux_rmff;
      STORE_OUTER_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, STORE_OUTER_LOOP_b_mux_nl,
          not_nl);
      STORE_INNER_LOOP_i_7_0_sva_6_0 <= MUX_v_7_2_2(7'b0000000, STORE_INNER_LOOP_i_mux_2_nl,
          (fsm_output[3]));
    end
  end
  always @(posedge clk) begin
    if ( rst ) begin
      reg_plm_conf_rsci_oswt_cse <= 1'b0;
      reg_plm_out_rsci_iswt0_cse <= 1'b0;
      reg_dma_write_ctrl_rsci_oswt_cse <= 1'b0;
      reg_acc_done_synci_iswt0_cse <= 1'b0;
      reg_plm_out_rsc_rls_obj_iswt0_cse <= 1'b0;
      STORE_INNER_LOOP_stage_v <= 1'b0;
      STORE_INNER_LOOP_stage_0 <= 1'b0;
      STORE_INNER_LOOP_stage_v_1 <= 1'b0;
      STORE_INNER_LOOP_stage_v_2 <= 1'b0;
      STORE_INNER_LOOP_stage_0_1 <= 1'b0;
      STORE_INNER_LOOP_stage_0_2 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_plm_conf_rsci_oswt_cse <= (fsm_output[5]) | (fsm_output[0]);
      reg_plm_out_rsci_iswt0_cse <= and_50_rmff;
      reg_dma_write_ctrl_rsci_oswt_cse <= or_39_itm;
      reg_acc_done_synci_iswt0_cse <= ((~ (z_out[32])) & (fsm_output[1])) | (or_dcpl_5
          & (fsm_output[4]));
      reg_plm_out_rsc_rls_obj_iswt0_cse <= and_dcpl_5 & (fsm_output[3]);
      STORE_INNER_LOOP_stage_v <= ~((~(STORE_INNER_LOOP_stage_v & (~(and_dcpl_12
          & and_dcpl_11 & ((z_out[7]) | (~ STORE_INNER_LOOP_stage_0)))))) & (~((~((~(and_dcpl_12
          & STORE_INNER_LOOP_stage_0_1 & (~ (z_out[7])))) & STORE_INNER_LOOP_stage_v))
          & STORE_INNER_LOOP_stage_0)) & (fsm_output[3]));
      STORE_INNER_LOOP_stage_0 <= ~((~(STORE_INNER_LOOP_stage_0 & (or_dcpl_14 | or_dcpl_13
          | (~ (z_out[7]))))) & (fsm_output[3]));
      STORE_INNER_LOOP_stage_v_1 <= ((STORE_INNER_LOOP_stage_v_1 & (~(or_tmp & plm_out_rsci_bawt
          & or_dcpl_13 & STORE_INNER_LOOP_stage_0_2))) | and_dcpl_13) & (fsm_output[3]);
      STORE_INNER_LOOP_stage_v_2 <= ((STORE_INNER_LOOP_stage_v_2 & (~ and_dcpl_6))
          | and_dcpl_9) & (fsm_output[3]);
      STORE_INNER_LOOP_stage_0_1 <= ~((~(STORE_INNER_LOOP_mux_nl & (~(and_dcpl_12
          & and_dcpl_11 & (z_out[7]))))) & (fsm_output[3]));
      STORE_INNER_LOOP_stage_0_2 <= STORE_INNER_LOOP_mux_8_nl & (fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( core_wen & or_39_itm ) begin
      dma_write_ctrl_rsci_idat_10_7 <= MUX_v_4_2_2(4'b0000, offset_10_7_sva_1, STORE_OUTER_LOOP_not_1_nl);
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (fsm_output[3]) ) begin
      dma_write_chnl_rsci_idat_31_0 <= MUX_v_32_2_2(plm_out_rsci_q_d_mxwt, dma_write_chnl_rsci_idat_31_0,
          or_20_nl);
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (fsm_output[4:2]==3'b000) ) begin
      batch_sva <= plm_conf_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (~ (fsm_output[3])) ) begin
      offset_10_7_sva_1 <= z_out[3:0];
    end
  end
  assign STORE_OUTER_LOOP_b_mux_nl = MUX_v_4_2_2(STORE_OUTER_LOOP_b_4_0_sva_3_0,
      (STORE_OUTER_LOOP_b_4_0_sva_2[3:0]), fsm_output[4]);
  assign not_nl = ~ (fsm_output[1]);
  assign or_27_nl = and_dcpl_16 | (STORE_INNER_LOOP_stage_v_1 & (~ plm_out_rsci_bawt))
      | (~ STORE_INNER_LOOP_stage_v);
  assign STORE_INNER_LOOP_i_mux_2_nl = MUX_v_7_2_2((z_out[6:0]), STORE_INNER_LOOP_i_7_0_sva_6_0,
      or_27_nl);
  assign STORE_INNER_LOOP_mux_nl = MUX_s_1_2_2(STORE_INNER_LOOP_stage_0, STORE_INNER_LOOP_stage_0_1,
      or_dcpl_15);
  assign and_108_nl = STORE_INNER_LOOP_stage_0_2 & plm_out_rsci_bawt & STORE_INNER_LOOP_stage_v_1;
  assign mux_17_nl = MUX_s_1_2_2(and_108_nl, or_dcpl_9, and_dcpl_11);
  assign or_32_nl = (~ mux_17_nl) | and_dcpl_16;
  assign STORE_INNER_LOOP_mux_8_nl = MUX_s_1_2_2(STORE_INNER_LOOP_stage_0_1, STORE_INNER_LOOP_stage_0_2,
      or_32_nl);
  assign STORE_OUTER_LOOP_not_1_nl = ~ and_53_cse;
  assign or_20_nl = and_dcpl_16 | (~ STORE_INNER_LOOP_stage_v_1) | or_dcpl_10;
  assign operator_32_false_operator_32_false_or_1_nl = (~((fsm_output[3:2]!=2'b00)))
      | (fsm_output[1]) | (fsm_output[4]);
  assign operator_32_false_or_3_nl = (fsm_output[4:2]!=3'b000);
  assign operator_32_false_operator_32_false_operator_32_false_nor_1_nl = ~(MUX_v_25_2_2((plm_conf_rsci_idat_mxwt[31:7]),
      25'b1111111111111111111111111, operator_32_false_or_3_nl));
  assign operator_32_false_mux_1_nl = MUX_v_3_2_2((~ (plm_conf_rsci_idat_mxwt[6:4])),
      (STORE_INNER_LOOP_i_7_0_sva_6_0[6:4]), fsm_output[3]);
  assign operator_32_false_nor_5_nl = ~((fsm_output[2]) | (fsm_output[4]));
  assign operator_32_false_operator_32_false_and_2_nl = MUX_v_3_2_2(3'b000, operator_32_false_mux_1_nl,
      operator_32_false_nor_5_nl);
  assign operator_32_false_mux1h_2_nl = MUX1HOT_v_4_4_2(dma_write_ctrl_rsci_idat_10_7,
      (~ (plm_conf_rsci_idat_mxwt[3:0])), (STORE_OUTER_LOOP_b_4_0_sva_2[3:0]), (STORE_INNER_LOOP_i_7_0_sva_6_0[3:0]),
      {(fsm_output[2]) , (fsm_output[1]) , (fsm_output[4]) , (fsm_output[3])});
  assign operator_32_false_or_4_nl = (~((fsm_output[3:1]!=3'b000))) | (fsm_output[4]);
  assign operator_32_false_operator_32_false_mux_1_nl = MUX_v_32_2_2(32'b00000000000000000000000000000001,
      (~ batch_sva), fsm_output[4]);
  assign nl_acc_nl = ({operator_32_false_operator_32_false_or_1_nl , operator_32_false_operator_32_false_operator_32_false_nor_1_nl
      , operator_32_false_operator_32_false_and_2_nl , operator_32_false_mux1h_2_nl
      , operator_32_false_or_4_nl}) + conv_u2u_33_34({operator_32_false_operator_32_false_mux_1_nl
      , 1'b1});
  assign acc_nl = nl_acc_nl[33:0];
  assign z_out = readslicef_34_33_1(acc_nl);

  function automatic [3:0] MUX1HOT_v_4_4_2;
    input [3:0] input_3;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [3:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    result = result | ( input_3 & {4{sel[3]}});
    MUX1HOT_v_4_4_2 = result;
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


  function automatic [2:0] MUX_v_3_2_2;
    input [2:0] input_0;
    input [2:0] input_1;
    input [0:0] sel;
    reg [2:0] result;
  begin
    case (sel)
      1'b0 : begin
        result = input_0;
      end
      default : begin
        result = input_1;
      end
    endcase
    MUX_v_3_2_2 = result;
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


  function automatic [32:0] readslicef_34_33_1;
    input [33:0] vector;
    reg [33:0] tmp;
  begin
    tmp = vector >> 1;
    readslicef_34_33_1 = tmp[32:0];
  end
  endfunction


  function automatic [4:0] conv_u2u_4_5 ;
    input [3:0]  vector ;
  begin
    conv_u2u_4_5 = {1'b0, vector};
  end
  endfunction


  function automatic [33:0] conv_u2u_33_34 ;
    input [32:0]  vector ;
  begin
    conv_u2u_33_34 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config (
  clk, rst, conf_info_batch_rsc_dat, conf_info_batch_rsc_vld, conf_info_batch_rsc_triosy_lz,
      plm_conf_load_rsc_dat, plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy, plm_conf_compute_rsc_dat,
      plm_conf_compute_rsc_vld, plm_conf_compute_rsc_rdy, plm_conf_store_rsc_dat,
      plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] conf_info_batch_rsc_dat;
  input conf_info_batch_rsc_vld;
  output conf_info_batch_rsc_triosy_lz;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_config_core config_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_batch_rsc_dat(conf_info_batch_rsc_dat),
      .conf_info_batch_rsc_vld(conf_info_batch_rsc_vld),
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, plm_in_rsc_wadr,
      plm_in_rsc_d, plm_in_rsc_we, plm_in_rsc_req_vz, plm_in_rsc_rls_lz, dma_read_ctrl_rsc_dat,
      dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld,
      dma_read_chnl_rsc_rdy
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  output [6:0] plm_in_rsc_wadr;
  output [31:0] plm_in_rsc_d;
  output plm_in_rsc_we;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;


  // Interconnect Declarations
  wire [31:0] plm_in_rsci_d_d;
  wire [6:0] plm_in_rsci_wadr_d;
  wire plm_in_rsci_we_d_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_load_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_6_7_32_128_128_32_1_gen
      plm_in_rsci (
      .we(plm_in_rsc_we),
      .d(plm_in_rsc_d),
      .wadr(plm_in_rsc_wadr),
      .d_d(plm_in_rsci_d_d),
      .wadr_d(plm_in_rsci_wadr_d),
      .we_d(plm_in_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(plm_in_rsci_we_d_iff)
    );
  esp_acc_softmax_cxx_load_core load_core_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_rsc_dat),
      .plm_conf_rsc_vld(plm_conf_rsc_vld),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .plm_in_rsci_d_d(plm_in_rsci_d_d),
      .plm_in_rsci_wadr_d(plm_in_rsci_wadr_d),
      .plm_in_rsci_we_d_pff(plm_in_rsci_we_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, plm_in_rsc_radr,
      plm_in_rsc_q, plm_in_rsc_req_vz, plm_in_rsc_rls_lz, plm_out_rsc_wadr, plm_out_rsc_d,
      plm_out_rsc_we, plm_out_rsc_req_vz, plm_out_rsc_rls_lz
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  output [6:0] plm_in_rsc_radr;
  input [31:0] plm_in_rsc_q;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  output [6:0] plm_out_rsc_wadr;
  output [31:0] plm_out_rsc_d;
  output plm_out_rsc_we;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;


  // Interconnect Declarations
  wire [31:0] plm_in_rsci_q_d;
  wire [6:0] plm_in_rsci_radr_d;
  wire plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_rsci_d_d;
  wire [6:0] plm_out_rsci_wadr_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire [93:0] CALC_SOFTMAX_LOOP_mul_cmp_b;
  wire [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_clken;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_q;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_radr;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_we;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wadr;
  wire plm_out_rsci_we_d_iff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_mul_pipe #(.width_a(32'sd67),
  .signd_a(32'sd0),
  .width_b(32'sd94),
  .signd_b(32'sd0),
  .width_z(32'sd95),
  .clock_edge(32'sd1),
  .enable_active(32'sd1),
  .a_rst_active(32'sd0),
  .s_rst_active(32'sd1),
  .stages(32'sd3),
  .n_inreg(32'sd1)) CALC_SOFTMAX_LOOP_mul_cmp (
      .a(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .b(CALC_SOFTMAX_LOOP_mul_cmp_b),
      .clk(clk),
      .en(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .a_rst(1'b1),
      .s_rst(rst),
      .z(CALC_SOFTMAX_LOOP_mul_cmp_z)
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
  esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_11_7_32_128_128_32_1_gen
      plm_in_rsci (
      .q(plm_in_rsc_q),
      .radr(plm_in_rsc_radr),
      .q_d(plm_in_rsci_q_d),
      .radr_d(plm_in_rsci_radr_d),
      .readA_r_ram_ir_internal_RMASK_B_d(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_12_7_32_128_128_32_1_gen
      plm_out_rsci (
      .we(plm_out_rsc_we),
      .d(plm_out_rsc_d),
      .wadr(plm_out_rsc_wadr),
      .d_d(plm_out_rsci_d_d),
      .wadr_d(plm_out_rsci_wadr_d),
      .we_d(plm_out_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(plm_out_rsci_we_d_iff)
    );
  esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_15_7_67_128_128_67_1_gen
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci
      (
      .clken(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_clken),
      .q(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_q),
      .radr(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_radr),
      .we(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_we),
      .d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_d),
      .wadr(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wadr),
      .clken_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .radr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d),
      .wadr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d),
      .we_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_compute_core compute_core_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_rsc_dat),
      .plm_conf_rsc_vld(plm_conf_rsc_vld),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .plm_in_rsci_q_d(plm_in_rsci_q_d),
      .plm_in_rsci_radr_d(plm_in_rsci_radr_d),
      .plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .plm_out_rsci_d_d(plm_out_rsci_d_d),
      .plm_out_rsci_wadr_d(plm_out_rsci_wadr_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_wadr_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .CALC_SOFTMAX_LOOP_mul_cmp_b(CALC_SOFTMAX_LOOP_mul_cmp_b),
      .CALC_SOFTMAX_LOOP_mul_cmp_z(CALC_SOFTMAX_LOOP_mul_cmp_z),
      .plm_out_rsci_we_d_pff(plm_out_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store (
  clk, rst, plm_conf_rsc_dat, plm_conf_rsc_vld, plm_conf_rsc_rdy, plm_out_rsc_radr,
      plm_out_rsc_q, plm_out_rsc_req_vz, plm_out_rsc_rls_lz, dma_write_ctrl_rsc_dat,
      dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld,
      dma_write_chnl_rsc_rdy, acc_done_sync_vld
);
  input clk;
  input rst;
  input [31:0] plm_conf_rsc_dat;
  input plm_conf_rsc_vld;
  output plm_conf_rsc_rdy;
  output [6:0] plm_out_rsc_radr;
  input [31:0] plm_out_rsc_q;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  output acc_done_sync_vld;


  // Interconnect Declarations
  wire [31:0] plm_out_rsci_q_d;
  wire [6:0] plm_out_rsci_radr_d;
  wire plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_store_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_21_7_32_128_128_32_1_gen
      plm_out_rsci (
      .q(plm_out_rsc_q),
      .radr(plm_out_rsc_radr),
      .q_d(plm_out_rsci_q_d),
      .radr_d(plm_out_rsci_radr_d),
      .readA_r_ram_ir_internal_RMASK_B_d(plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_store_core store_core_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_rsc_dat),
      .plm_conf_rsc_vld(plm_conf_rsc_vld),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .acc_done_sync_vld(acc_done_sync_vld),
      .plm_out_rsci_q_d(plm_out_rsci_q_d),
      .plm_out_rsci_radr_d(plm_out_rsci_radr_d),
      .plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_struct
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_struct (
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_batch_rsc_dat, conf_info_batch_rsc_vld,
      conf_info_batch_rsc_triosy_lz, dma_read_ctrl_rsc_dat_size, dma_read_ctrl_rsc_dat_length,
      dma_read_ctrl_rsc_dat_index, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      dma_write_ctrl_rsc_dat_size, dma_write_ctrl_rsc_dat_length, dma_write_ctrl_rsc_dat_index,
      dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld,
      dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      store_acc_done_sync_vld
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;
  input [31:0] conf_info_batch_rsc_dat;
  input conf_info_batch_rsc_vld;
  output conf_info_batch_rsc_triosy_lz;
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
  output store_acc_done_sync_vld;


  // Interconnect Declarations
  wire [31:0] plm_conf_load_rsc_dat_nconfig_inst;
  wire [31:0] plm_conf_compute_rsc_dat_nconfig_inst;
  wire [31:0] plm_conf_store_rsc_dat_nconfig_inst;
  wire plm_conf_rsc_rdy_nload_inst;
  wire [6:0] plm_in_rsc_wadr_nload_inst;
  wire [31:0] plm_in_rsc_d_nload_inst;
  wire plm_in_rsc_we_nload_inst;
  wire plm_in_rsc_req_vz_nload_inst;
  wire [66:0] dma_read_ctrl_rsc_dat_nload_inst;
  wire dma_read_ctrl_rsc_vld_nload_inst;
  wire dma_read_chnl_rsc_rdy_nload_inst;
  wire plm_conf_rsc_rdy_ncompute_inst;
  wire [6:0] plm_in_rsc_radr_ncompute_inst;
  wire [31:0] plm_in_rsc_q_ncompute_inst;
  wire plm_in_rsc_req_vz_ncompute_inst;
  wire [6:0] plm_out_rsc_wadr_ncompute_inst;
  wire [31:0] plm_out_rsc_d_ncompute_inst;
  wire plm_out_rsc_we_ncompute_inst;
  wire plm_out_rsc_req_vz_ncompute_inst;
  wire plm_out_rsc_we_ncompute_inst_buz;
  wire plm_conf_rsc_rdy_nstore_inst;
  wire [6:0] plm_out_rsc_radr_nstore_inst;
  wire [31:0] plm_out_rsc_q_nstore_inst;
  wire plm_out_rsc_req_vz_nstore_inst;
  wire [66:0] dma_write_ctrl_rsc_dat_nstore_inst;
  wire dma_write_ctrl_rsc_vld_nstore_inst;
  wire [63:0] dma_write_chnl_rsc_dat_nstore_inst;
  wire dma_write_chnl_rsc_vld_nstore_inst;
  wire acc_done_sync_vld_nstore_inst;
  wire [31:0] debug_rsc_dat_nsoftmax_cxx_core_inst;
  wire conf_info_batch_rsc_triosy_lz_nconfig_inst_bud;
  wire plm_conf_load_rsc_vld_nconfig_inst_bud;
  wire plm_conf_rsc_rdy_nload_inst_bud;
  wire plm_conf_compute_rsc_vld_nconfig_inst_bud;
  wire plm_conf_rsc_rdy_ncompute_inst_bud;
  wire plm_conf_store_rsc_vld_nconfig_inst_bud;
  wire plm_conf_rsc_rdy_nstore_inst_bud;
  wire plm_in_rsc_rls_lz_nload_inst_bud;
  wire plm_in_rsc_rls_lz_ncompute_inst_bud;
  wire dma_read_ctrl_rsc_vld_nload_inst_bud;
  wire dma_read_chnl_rsc_rdy_nload_inst_bud;
  wire plm_out_rsc_we_ncompute_inst_buz_bud;
  wire plm_out_rsc_rls_lz_ncompute_inst_bud;
  wire plm_out_rsc_rls_lz_nstore_inst_bud;
  wire dma_write_ctrl_rsc_vld_nstore_inst_bud;
  wire dma_write_chnl_rsc_vld_nstore_inst_bud;
  wire acc_done_sync_vld_nstore_inst_bud;
  wire debug_rsc_triosy_lz_nsoftmax_cxx_core_inst_bud;
  wire plm_in_cns_R0;
  wire plm_in_cns_S1;
  wire plm_in_cns_R1;
  wire [31:0] plm_in_cns_d_shi0;
  wire [31:0] plm_in_cns_d_shi1;
  wire [31:0] plm_in_cns_q_sho0;
  wire [31:0] plm_in_cns_q_sho1;
  wire [6:0] plm_in_cns_radr_shi0;
  wire [6:0] plm_in_cns_radr_shi1;
  wire [6:0] plm_in_cns_wadr_shi0;
  wire [6:0] plm_in_cns_wadr_shi1;
  wire plm_in_cns_we_shi0;
  wire plm_in_cns_we_shi1;
  wire plm_out_cns_R0;
  wire plm_out_cns_S1;
  wire plm_out_cns_R1;
  wire [31:0] plm_out_cns_d_shi0;
  wire [31:0] plm_out_cns_d_shi1;
  wire [31:0] plm_out_cns_q_sho0;
  wire [31:0] plm_out_cns_q_sho1;
  wire [6:0] plm_out_cns_radr_shi0;
  wire [6:0] plm_out_cns_radr_shi1;
  wire [6:0] plm_out_cns_wadr_shi0;
  wire [6:0] plm_out_cns_wadr_shi1;
  wire plm_out_cns_we_shi0;
  wire plm_out_cns_we_shi1;
  wire plm_in_cns_S0_iff;
  wire plm_out_rsc_we_ncompute_inst_buz_iff;
  wire plm_out_rsc_we_ncompute_inst_buz_bud_iff;
  wire plm_out_cns_S0_iff;
  wire plm_in_cns_S0_dmo;
  wire plm_out_cns_S0_dmo;


  // Interconnect Declarations for Component Instantiations 
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd32),
  .depth(32'sd128),
  .latency(32'sd1)) plm_in_cns_comp (
      .clk(clk),
      .clken(1'b1),
      .d(plm_in_cns_d_shi0),
      .q(plm_in_cns_q_sho0),
      .radr(plm_in_cns_radr_shi0),
      .wadr(plm_in_cns_wadr_shi0),
      .we(plm_in_cns_we_shi0)
    );
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd32),
  .depth(32'sd128),
  .latency(32'sd1)) plm_in_cns_comp_1 (
      .clk(clk),
      .clken(1'b1),
      .d(plm_in_cns_d_shi1),
      .q(plm_in_cns_q_sho1),
      .radr(plm_in_cns_radr_shi1),
      .wadr(plm_in_cns_wadr_shi1),
      .we(plm_in_cns_we_shi1)
    );
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd32),
  .depth(32'sd128),
  .latency(32'sd1)) plm_out_cns_comp (
      .clk(clk),
      .clken(1'b1),
      .d(plm_out_cns_d_shi0),
      .q(plm_out_cns_q_sho0),
      .radr(plm_out_cns_radr_shi0),
      .wadr(plm_out_cns_wadr_shi0),
      .we(plm_out_cns_we_shi0)
    );
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd32),
  .depth(32'sd128),
  .latency(32'sd1)) plm_out_cns_comp_1 (
      .clk(clk),
      .clken(1'b1),
      .d(plm_out_cns_d_shi1),
      .q(plm_out_cns_q_sho1),
      .radr(plm_out_cns_radr_shi1),
      .wadr(plm_out_cns_wadr_shi1),
      .we(plm_out_cns_we_shi1)
    );
  esp_acc_softmax_cxx_config config_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_batch_rsc_dat(conf_info_batch_rsc_dat),
      .conf_info_batch_rsc_vld(conf_info_batch_rsc_vld),
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz_nconfig_inst_bud),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat_nconfig_inst),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld_nconfig_inst_bud),
      .plm_conf_load_rsc_rdy(plm_conf_rsc_rdy_nload_inst),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat_nconfig_inst),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld_nconfig_inst_bud),
      .plm_conf_compute_rsc_rdy(plm_conf_rsc_rdy_ncompute_inst),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat_nconfig_inst),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld_nconfig_inst_bud),
      .plm_conf_store_rsc_rdy(plm_conf_rsc_rdy_nstore_inst)
    );
  esp_acc_softmax_cxx_load load_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_load_rsc_dat_nconfig_inst),
      .plm_conf_rsc_vld(plm_conf_load_rsc_vld_nconfig_inst_bud),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy_nload_inst_bud),
      .plm_in_rsc_wadr(plm_in_rsc_wadr_nload_inst),
      .plm_in_rsc_d(plm_in_rsc_d_nload_inst),
      .plm_in_rsc_we(plm_in_rsc_we_nload_inst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz_nload_inst),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz_nload_inst_bud),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat_nload_inst),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld_nload_inst_bud),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy_nload_inst_bud)
    );
  esp_acc_softmax_cxx_compute compute_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_compute_rsc_dat_nconfig_inst),
      .plm_conf_rsc_vld(plm_conf_compute_rsc_vld_nconfig_inst_bud),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy_ncompute_inst_bud),
      .plm_in_rsc_radr(plm_in_rsc_radr_ncompute_inst),
      .plm_in_rsc_q(plm_in_rsc_q_ncompute_inst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz_ncompute_inst),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz_ncompute_inst_bud),
      .plm_out_rsc_wadr(plm_out_rsc_wadr_ncompute_inst),
      .plm_out_rsc_d(plm_out_rsc_d_ncompute_inst),
      .plm_out_rsc_we(plm_out_rsc_we_ncompute_inst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz_ncompute_inst),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz_ncompute_inst_bud)
    );
  esp_acc_softmax_cxx_store store_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_dat(plm_conf_store_rsc_dat_nconfig_inst),
      .plm_conf_rsc_vld(plm_conf_store_rsc_vld_nconfig_inst_bud),
      .plm_conf_rsc_rdy(plm_conf_rsc_rdy_nstore_inst_bud),
      .plm_out_rsc_radr(plm_out_rsc_radr_nstore_inst),
      .plm_out_rsc_q(plm_out_rsc_q_nstore_inst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz_nstore_inst),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz_nstore_inst_bud),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat_nstore_inst),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld_nstore_inst_bud),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat_nstore_inst),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld_nstore_inst_bud),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .acc_done_sync_vld(acc_done_sync_vld_nstore_inst_bud)
    );
  esp_acc_softmax_cxx_softmax_cxx_core softmax_cxx_core_inst (
      .clk(clk),
      .rst(rst),
      .debug_rsc_dat(debug_rsc_dat_nsoftmax_cxx_core_inst),
      .debug_rsc_triosy_lz(debug_rsc_triosy_lz_nsoftmax_cxx_core_inst_bud)
    );
  esp_acc_softmax_cxx_unreg_hier unreg (
      .in_0(plm_in_cns_S0_iff),
      .out_0(plm_in_cns_R0)
    );
  esp_acc_softmax_cxx_unreg_hier unreg_1 (
      .in_0(plm_in_cns_S1),
      .out_0(plm_in_cns_R1)
    );
  esp_acc_softmax_cxx_unreg_hier unreg_2 (
      .in_0(plm_out_cns_S0_iff),
      .out_0(plm_out_cns_R0)
    );
  esp_acc_softmax_cxx_unreg_hier unreg_3 (
      .in_0(plm_out_cns_S1),
      .out_0(plm_out_cns_R1)
    );
  esp_acc_softmax_cxx_softmax_cxx_plm_in_cns_bctl softmax_cxx_plm_in_cns_bctl_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_rsc_rdy_nload_inst(plm_conf_rsc_rdy_nload_inst),
      .plm_in_rsc_wadr_nload_inst(plm_in_rsc_wadr_nload_inst),
      .plm_in_rsc_d_nload_inst(plm_in_rsc_d_nload_inst),
      .plm_in_rsc_we_nload_inst(plm_in_rsc_we_nload_inst),
      .plm_in_rsc_req_vz_nload_inst(plm_in_rsc_req_vz_nload_inst),
      .dma_read_ctrl_rsc_vld_nload_inst(dma_read_ctrl_rsc_vld_nload_inst),
      .dma_read_chnl_rsc_rdy_nload_inst(dma_read_chnl_rsc_rdy_nload_inst),
      .plm_conf_rsc_rdy_ncompute_inst(plm_conf_rsc_rdy_ncompute_inst),
      .plm_in_rsc_radr_ncompute_inst(plm_in_rsc_radr_ncompute_inst),
      .plm_in_rsc_q_ncompute_inst(plm_in_rsc_q_ncompute_inst),
      .plm_in_rsc_req_vz_ncompute_inst(plm_in_rsc_req_vz_ncompute_inst),
      .plm_out_rsc_we_ncompute_inst_buz(plm_out_rsc_we_ncompute_inst_buz),
      .plm_conf_rsc_rdy_nload_inst_bud(plm_conf_rsc_rdy_nload_inst_bud),
      .plm_conf_rsc_rdy_ncompute_inst_bud(plm_conf_rsc_rdy_ncompute_inst_bud),
      .plm_in_rsc_rls_lz_nload_inst_bud(plm_in_rsc_rls_lz_nload_inst_bud),
      .plm_in_rsc_rls_lz_ncompute_inst_bud(plm_in_rsc_rls_lz_ncompute_inst_bud),
      .dma_read_ctrl_rsc_vld_nload_inst_bud(dma_read_ctrl_rsc_vld_nload_inst_bud),
      .dma_read_chnl_rsc_rdy_nload_inst_bud(dma_read_chnl_rsc_rdy_nload_inst_bud),
      .plm_out_rsc_we_ncompute_inst_buz_bud(plm_out_rsc_we_ncompute_inst_buz_bud),
      .plm_out_rsc_rls_lz_ncompute_inst_bud(1'b0),
      .plm_in_cns_S0(plm_in_cns_S0_dmo),
      .plm_in_cns_R0(plm_in_cns_R0),
      .plm_in_cns_S1(plm_in_cns_S1),
      .plm_in_cns_R1(plm_in_cns_R1),
      .plm_in_cns_d_shi0(plm_in_cns_d_shi0),
      .plm_in_cns_d_shi1(plm_in_cns_d_shi1),
      .plm_in_cns_q_sho0(plm_in_cns_q_sho0),
      .plm_in_cns_q_sho1(plm_in_cns_q_sho1),
      .plm_in_cns_radr_shi0(plm_in_cns_radr_shi0),
      .plm_in_cns_radr_shi1(plm_in_cns_radr_shi1),
      .plm_in_cns_wadr_shi0(plm_in_cns_wadr_shi0),
      .plm_in_cns_wadr_shi1(plm_in_cns_wadr_shi1),
      .plm_in_cns_we_shi0(plm_in_cns_we_shi0),
      .plm_in_cns_we_shi1(plm_in_cns_we_shi1),
      .plm_in_cns_S0_pff(plm_in_cns_S0_iff),
      .plm_out_rsc_we_ncompute_inst_buz_pff(plm_out_rsc_we_ncompute_inst_buz_iff),
      .plm_out_rsc_we_ncompute_inst_buz_bud_pff(plm_out_rsc_we_ncompute_inst_buz_bud_iff)
    );
  esp_acc_softmax_cxx_softmax_cxx_plm_out_cns_bctl softmax_cxx_plm_out_cns_bctl_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_wadr_ncompute_inst(plm_out_rsc_wadr_ncompute_inst),
      .plm_out_rsc_d_ncompute_inst(plm_out_rsc_d_ncompute_inst),
      .plm_out_rsc_we_ncompute_inst(plm_out_rsc_we_ncompute_inst),
      .plm_out_rsc_req_vz_ncompute_inst(plm_out_rsc_req_vz_ncompute_inst),
      .plm_out_rsc_we_ncompute_inst_buz(1'b0),
      .plm_conf_rsc_rdy_nstore_inst(plm_conf_rsc_rdy_nstore_inst),
      .plm_out_rsc_radr_nstore_inst(plm_out_rsc_radr_nstore_inst),
      .plm_out_rsc_q_nstore_inst(plm_out_rsc_q_nstore_inst),
      .plm_out_rsc_req_vz_nstore_inst(plm_out_rsc_req_vz_nstore_inst),
      .dma_write_ctrl_rsc_vld_nstore_inst(dma_write_ctrl_rsc_vld_nstore_inst),
      .dma_write_chnl_rsc_vld_nstore_inst(dma_write_chnl_rsc_vld_nstore_inst),
      .acc_done_sync_vld_nstore_inst(acc_done_sync_vld_nstore_inst),
      .plm_conf_rsc_rdy_nstore_inst_bud(plm_conf_rsc_rdy_nstore_inst_bud),
      .plm_out_rsc_we_ncompute_inst_buz_bud(plm_out_rsc_we_ncompute_inst_buz_bud),
      .plm_out_rsc_rls_lz_ncompute_inst_bud(plm_out_rsc_rls_lz_ncompute_inst_bud),
      .plm_out_rsc_rls_lz_nstore_inst_bud(plm_out_rsc_rls_lz_nstore_inst_bud),
      .dma_write_ctrl_rsc_vld_nstore_inst_bud(dma_write_ctrl_rsc_vld_nstore_inst_bud),
      .dma_write_chnl_rsc_vld_nstore_inst_bud(dma_write_chnl_rsc_vld_nstore_inst_bud),
      .acc_done_sync_vld_nstore_inst_bud(acc_done_sync_vld_nstore_inst_bud),
      .plm_out_cns_S0(plm_out_cns_S0_dmo),
      .plm_out_cns_R0(plm_out_cns_R0),
      .plm_out_cns_S1(plm_out_cns_S1),
      .plm_out_cns_R1(plm_out_cns_R1),
      .plm_out_cns_d_shi0(plm_out_cns_d_shi0),
      .plm_out_cns_d_shi1(plm_out_cns_d_shi1),
      .plm_out_cns_q_sho0(plm_out_cns_q_sho0),
      .plm_out_cns_q_sho1(plm_out_cns_q_sho1),
      .plm_out_cns_radr_shi0(plm_out_cns_radr_shi0),
      .plm_out_cns_radr_shi1(plm_out_cns_radr_shi1),
      .plm_out_cns_wadr_shi0(plm_out_cns_wadr_shi0),
      .plm_out_cns_wadr_shi1(plm_out_cns_wadr_shi1),
      .plm_out_cns_we_shi0(plm_out_cns_we_shi0),
      .plm_out_cns_we_shi1(plm_out_cns_we_shi1),
      .plm_out_rsc_we_ncompute_inst_buz_pff(plm_out_rsc_we_ncompute_inst_buz_iff),
      .plm_out_rsc_we_ncompute_inst_buz_bud_pff(plm_out_rsc_we_ncompute_inst_buz_bud_iff),
      .plm_out_cns_S0_pff(plm_out_cns_S0_iff)
    );
  assign conf_info_batch_rsc_triosy_lz = conf_info_batch_rsc_triosy_lz_nconfig_inst_bud;
  assign dma_read_ctrl_rsc_dat_index = dma_read_ctrl_rsc_dat_nload_inst[31:0];
  assign dma_read_ctrl_rsc_dat_length = dma_read_ctrl_rsc_dat_nload_inst[63:32];
  assign dma_read_ctrl_rsc_dat_size = dma_read_ctrl_rsc_dat_nload_inst[66:64];
  assign dma_write_ctrl_rsc_dat_index = dma_write_ctrl_rsc_dat_nstore_inst[31:0];
  assign dma_write_ctrl_rsc_dat_length = dma_write_ctrl_rsc_dat_nstore_inst[63:32];
  assign dma_write_ctrl_rsc_dat_size = dma_write_ctrl_rsc_dat_nstore_inst[66:64];
  assign debug_rsc_dat = debug_rsc_dat_nsoftmax_cxx_core_inst;
  assign debug_rsc_triosy_lz = debug_rsc_triosy_lz_nsoftmax_cxx_core_inst_bud;
  assign dma_read_ctrl_rsc_vld = dma_read_ctrl_rsc_vld_nload_inst;
  assign dma_read_chnl_rsc_rdy = dma_read_chnl_rsc_rdy_nload_inst;
  assign dma_write_ctrl_rsc_vld = dma_write_ctrl_rsc_vld_nstore_inst;
  assign dma_write_chnl_rsc_vld = dma_write_chnl_rsc_vld_nstore_inst;
  assign dma_write_chnl_rsc_dat = dma_write_chnl_rsc_dat_nstore_inst;
  assign store_acc_done_sync_vld = acc_done_sync_vld_nstore_inst;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    softmax_cxx_basic_fx32_dma64
// ------------------------------------------------------------------


module softmax_cxx_basic_fx32_dma64 (
  clk, rst, debug_rsc_dat, debug_rsc_triosy_lz, conf_info_batch_rsc_dat, conf_info_batch_rsc_vld,
      conf_info_batch_rsc_triosy_lz, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld,
      dma_read_ctrl_rsc_rdy, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, dma_write_chnl_rsc_dat,
      dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, store_acc_done_sync_vld
);
  input clk;
  input rst;
  output [31:0] debug_rsc_dat;
  output debug_rsc_triosy_lz;
  input [31:0] conf_info_batch_rsc_dat;
  input conf_info_batch_rsc_vld;
  output conf_info_batch_rsc_triosy_lz;
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
  output store_acc_done_sync_vld;


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
      .conf_info_batch_rsc_vld(conf_info_batch_rsc_vld),
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
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
      .store_acc_done_sync_vld(store_acc_done_sync_vld)
    );
  assign dma_read_ctrl_rsc_dat = {dma_read_ctrl_rsc_dat_size , dma_read_ctrl_rsc_dat_length
      , dma_read_ctrl_rsc_dat_index};
  assign dma_write_ctrl_rsc_dat = {dma_write_ctrl_rsc_dat_size , dma_write_ctrl_rsc_dat_length
      , dma_write_ctrl_rsc_dat_index};
endmodule



