
//------> ./softmax_cxx_ccs_ctrl_in_buf_wait_v4.v 
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
// Change History:
//    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
//                 Fix bug in that behavior.
//    2019-01-04 - Fixed bug 54073 - rdy signal should not be asserted during
//                 reset
//    2018-11-19 - Improved code coverage for is_idle
//    2018-08-22 - Added is_idle to interface (as compare to
//                 ccs_ctrl_in_buf_wait_v2)
//------------------------------------------------------------------------------


module esp_acc_softmax_cxx_ccs_ctrl_in_buf_wait_v4 (clk, en, arst, srst, irdy, ivld, idat, vld, rdy, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  =  1;
    parameter integer ph_en   =  1;
    parameter integer ph_arst =  1;
    parameter integer ph_srst =  1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    input              irdy;
    output             ivld;
    input  [width-1:0] dat;
    output             rdy;
    input              vld;
    output [width-1:0] idat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    wire               lbuf;
    wire               fbuf;
    reg    [width-1:0] abuf;
    reg                hs_init;

    assign lbuf = ~filled | irdy;
    assign filled_next = lbuf ? (vld && hs_init) : filled;

    assign rdy = lbuf && hs_init;

    assign ivld = filled_next;
    assign idat = abuf;

    assign fbuf = (lbuf && vld && hs_init) || (irdy && filled_next);
    assign is_idle = !fbuf && !lbuf;

    //assign is_idle = (~((rdy && vld && hs_init) || (irdy && ivld))) && !lbuf ;

    // Output registers:

    generate
    if (ph_arst == 0 && ph_clk==1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst==1 && ph_clk==1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst == 0 && ph_clk==0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    else if (ph_arst==1 && ph_clk==0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            hs_init <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= lbuf ? dat : abuf;
            filled <= filled_next;
            hs_init <= 1'b1;
        end
    end
    endgenerate


`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (rdy==0);
       endproperty
       a1: assert property(rdyAsrt);

    end
    endgenerate

`endif

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



//------> ./softmax_cxx_ccs_sync_out_wait_v1.v 
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

module esp_acc_softmax_cxx_ccs_sync_out_wait_v1 (vld, irdy, ivld, rdy);
  parameter integer rscid = 1;

  input  ivld;
  output irdy;
  output vld;
  input  rdy;

  wire   irdy;
  wire   vld;

  assign vld = ivld;
  assign irdy = rdy;
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
//  Generated date: Fri Jun  5 18:39:12 2020
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


//------> ./softmax_cxx_ccs_out_buf_wait_v4.v 
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

module esp_acc_softmax_cxx_ccs_out_buf_wait_v4 (clk, en, arst, srst, ivld, irdy, idat, rdy, vld, dat, is_idle);

    parameter integer rscid   = 1;
    parameter integer width   = 8;
    parameter integer ph_clk  =  1;
    parameter integer ph_en   =  1;
    parameter integer ph_arst =  1;
    parameter integer ph_srst =  1;

    input              clk;
    input              en;
    input              arst;
    input              srst;
    input              rdy;
    output             vld;
    input  [width-1:0] idat;
    output             irdy;
    input              ivld;
    output [width-1:0] dat;
    output             is_idle;

    reg                filled;
    wire               filled_next;
    reg                lbuf;
    wire               lbuf_next;
    reg    [width-1:0] abuf;
    wire               fbuf;
    reg                is_idle;

    assign lbuf_next = ~vld | rdy;
    assign filled_next = lbuf ? ivld : filled;
    assign vld = filled_next;
    assign irdy = lbuf_next;
    assign dat = lbuf ? idat : abuf;

    assign fbuf = (lbuf_next && ivld) || (rdy && filled_next);

//    assign is_idle = (~((rdy && vld) || (irdy && ivld))) && ~lbuf && (lbuf==lbuf_next);

    // Generate is_idle flag
    always@(lbuf, lbuf_next, fbuf)
      begin
        if (lbuf == lbuf_next)
          is_idle <= ~fbuf && ~lbuf;
        else
          is_idle <= 0;
      end


    // Output registers:
    generate
    if (ph_arst == 0 && ph_clk==1)
    begin: POS_CLK_NEG_ARST
        always @(posedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst==1 && ph_clk==1)
    begin: POS_CLK_POS_ARST
        always @(posedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst == 0 && ph_clk==0)
    begin: NEG_CLK_NEG_ARST
        always @(negedge clk or negedge arst)
        if (arst == 1'b0)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    else if (ph_arst==1 && ph_clk==0)
    begin: NEG_CLK_POS_ARST
        always @(negedge clk or posedge arst)
        if (arst == 1'b1)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (srst == ph_srst)
        begin
            abuf  <= {width{1'b0}};
            filled <= 1'b0;
            lbuf <= 1'b0;
        end
        else if (en == ph_en)
        begin
            abuf  <= dat;
            filled <= filled_next;
            lbuf <= lbuf_next;
        end
    end
    endgenerate

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

//------> ./softmax_cxx_ccs_sync_in_wait_v1.v 
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

module esp_acc_softmax_cxx_ccs_sync_in_wait_v1 (rdy, vld, irdy, ivld);
  parameter integer rscid = 1;

  output rdy;
  input  vld;
  input  irdy;
  output ivld;

  wire   ivld;
  wire   rdy;

  assign ivld = vld;
  assign rdy = irdy;
endmodule

//------> ./softmax_cxx_ccs_genreg_v1.v 
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

module esp_acc_softmax_cxx_ccs_genreg_v1 (clk, en, arst, srst, d, z);
    parameter integer width   = 1;
    parameter integer ph_clk  = 1;
    parameter integer ph_en   = 1;
    parameter integer ph_arst = 0;
    parameter integer ph_srst = 1;
    parameter         has_en  = 1'b1;

    input clk;
    input en;
    input arst;
    input srst;
    input      [width-1:0] d;
    output reg [width-1:0] z;

    //  Generate parameters
    //  ph_clk | ph_arst | has_en     Label:
    //    1        1          1       GEN_CLK1_ARST1_EN1
    //    1        1          0       GEN_CLK1_ARST1_EN0
    //    1        0          1       GEN_CLK1_ARST0_EN1
    //    1        0          0       GEN_CLK1_ARST0_EN0
    //    0        1          1       GEN_CLK0_ARST1_EN1
    //    0        1          0       GEN_CLK0_ARST1_EN0
    //    0        0          1       GEN_CLK0_ARST0_EN1
    //    0        0          0       GEN_CLK0_ARST0_EN0

    generate
      // Pos edge clock, pos edge async reset, has enable
      if (ph_clk == 1 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK1_ARST1_EN1
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST1_EN1

      // Pos edge clock, pos edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK1_ARST1_EN0
        always @(posedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST1_EN0

      // Pos edge clock, neg edge async reset, has enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK1_ARST0_EN1
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK1_ARST0_EN1

      // Pos edge clock, neg edge async reset, no enable
      else if (ph_clk == 1 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK1_ARST0_EN0
        always @(posedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK1_ARST0_EN0


      // Neg edge clock, pos edge async reset, has enable
      if (ph_clk == 0 & ph_arst == 1 & has_en == 1)
      begin: GEN_CLK0_ARST1_EN1
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST1_EN1

      // Neg edge clock, pos edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 1 & has_en == 0)
      begin: GEN_CLK0_ARST1_EN0
        always @(negedge clk or posedge arst)
          if (arst == 1'b1)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST1_EN0

      // Neg edge clock, neg edge async reset, has enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 1)
      begin: GEN_CLK0_ARST0_EN1
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else if (en == $unsigned(ph_en))
            z <= d;
      end  //GEN_CLK0_ARST0_EN1

      // Neg edge clock, neg edge async reset, no enable
      else if (ph_clk == 0 & ph_arst == 0 & has_en == 0)
      begin: GEN_CLK0_ARST0_EN0
        always @(negedge clk or negedge arst)
          if (arst == 1'b0)
            z <= {width{1'b0}};
          else if (srst == $unsigned(ph_srst))
            z <= {width{1'b0}};
          else
            z <= d;
      end  //GEN_CLK0_ARST0_EN0
    endgenerate
endmodule


//------> ./softmax_cxx_ccs_fifo_wait_core_v5.v 
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

/*
 *            _________________________________________________
 * WRITER    |                                                 |   READER
 *           |               ccs_fifo_wait_core                |
 *           |             _____________________               |
 *        --<|  din_rdy --<|  ---------------- <|--- dout_rdy <|---
 *           |             |       FIFO         |              |
 *        ---|> din_vld ---|> ----------------  |>-- dout_vld  |>--
 *        ---|>     din ---|> ----------------  |>-- dout      |>--
 *           |             |____________________|              |
 *           |_________________________________________________|
 *
 *    rdy    - can be considered as a notFULL signal
 *    vld    - can be considered as a notEMPTY signal
 *    is_idle - clk can be safely gated
 *
 * Change History:
 *    2019-01-24 - Add assertion to verify rdy signal behavior under reset.
 *                 Fix bug in that behavior.
 */

module esp_acc_softmax_cxx_ccs_fifo_wait_core_v5 (clk, en, arst, srst, din_vld, din_rdy, din, dout_vld, dout_rdy, dout, sd, is_idle);

    parameter integer rscid    = 0;     // resource ID
    parameter integer width    = 8;     // fifo width
    parameter integer sz_width = 8;     // size of port for elements in fifo
    parameter integer fifo_sz  = 8;     // fifo depth
    parameter integer ph_clk   = 1;  // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1;  // clock enable polarity
    parameter integer ph_arst  = 1;  // async reset polarity
    parameter integer ph_srst  = 1;  // sync reset polarity
    parameter integer ph_log2  = 3;     // log2(fifo_sz)

    input                 clk;
    input                 en;
    input                 arst;
    input                 srst;
    input                 din_vld;    // writer has valid data
    output                din_rdy;    // fifo ready for data (not full)
    input  [width-1:0]    din;
    output                dout_vld;   // fifo has valid data (not empty)
    input                 dout_rdy;   // reader ready for data
    output [width-1:0]    dout;
    output [sz_width-1:0] sd;
    output                is_idle;

    localparam integer fifo_b  = width * fifo_sz;
    localparam integer fifo_mx = (fifo_sz > 0) ? (fifo_sz-1) : 0 ;
    localparam integer fifo_mx_over_8 = fifo_mx / 8 ;

    reg      [fifo_mx:0] stat_pre;
    wire     [fifo_mx:0] stat;
    reg      [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff_pre;
    wire     [( (fifo_b > 0) ? fifo_b : 1)-1:0] buff;
    reg      [fifo_mx:0] en_l;
    reg      [fifo_mx_over_8:0] en_l_s;

    reg      [width-1:0] buff_nxt;

    reg                  stat_nxt;
    reg                  stat_behind;
    reg                  stat_ahead;
    reg                  en_l_var;

    integer              i;
    genvar               eni;

    wire [32:0]          size_t;
    reg  [31:0]          count;
    reg  [31:0]          count_t;
    reg  [32:0]          n_elem;
// synopsys translate_off
    reg  [31:0]          peak;
    initial
    begin
      count = 32'b0;
      peak  = 32'b0;
    end
// synopsys translate_on
  wire din_rdy_drv  ;
  wire dout_vld_drv ;
    wire                 active;
    wire                 din_vld_int;
    wire                 hs_init;

    //assign din_rdy  = din_rdy_drv;    // dout_rdy | (~stat[0] & hs_init);   // original
    assign din_rdy = (fifo_sz > 0) ? (~stat[0] | dout_rdy) && hs_init : dout_rdy ;
    assign dout_vld = dout_vld_drv;
    assign is_idle = (~((din_vld && din_rdy) || (dout_vld && dout_rdy))) && hs_init;

    generate
    if ( fifo_sz > 0 )
    begin: FIFO_REG
    assign din_vld_int = din_vld & hs_init;
    assign active =   (din_vld_int & din_rdy_drv) | (dout_rdy & dout_vld_drv);

      assign din_rdy_drv = dout_rdy | (~stat[0] & hs_init);
      assign dout_vld_drv = din_vld_int | stat[fifo_sz-1];

      assign size_t = (count - {31'b0 , (dout_rdy & stat[fifo_sz-1])}) + { 31'b0, din_vld_int};
      assign sd = size_t[sz_width-1:0];

      assign dout = (stat[fifo_sz-1]) ? buff[fifo_b-1:width*(fifo_sz-1)] : din;

      always @(*)
      begin: FIFOPROC
        n_elem = 33'b0;
        for (i = fifo_sz-1; i >= 0; i = i - 1)
        begin
          stat_behind = (i != 0) ? stat[i-1] : 1'b0;
          stat_ahead  = (i != (fifo_sz-1)) ? stat[i+1] : 1'b1;

          // Determine if this buffer element will have data
          stat_nxt = stat_ahead &                       // valid element ahead of this one (or head)
                       (stat_behind                     // valid element behind this one
                         | (stat[i] & (~dout_rdy))      // valid element and output not ready (in use, no tx)
                         | (stat[i] & din_vld_int)      // valid element and input has data
                         | (din_vld_int  & (~dout_rdy)) // input has data and output not ready
                       );
          stat_pre[i] = stat_nxt;

          if (dout_rdy & stat_behind )
          begin
            // pop n shift
            buff_nxt[0+:width] = buff[width*(i-1)+:width];
            en_l_var = 1'b1;
          end
          else if (din_vld_int & stat_nxt & ~((~dout_rdy) & stat[i]))
          begin
            // update tail with input data
            buff_nxt = din;
            en_l_var = 1'b1;
          end
          else
          begin
            // no-op, disable register
            buff_nxt = din; // Don't care input to disabled flop
            en_l_var = 1'b0;
          end
          buff_pre[width*i+:width] = buff_nxt[0+:width];

          if (ph_en != 0)
            en_l[i] = en & en_l_var;
          else
            en_l[i] = en | ~en_l_var;

          if ((stat_ahead == 1'b1) & (stat[i] == 1'b0))
            //found tail, update the number of elements for count
            n_elem = ($unsigned(fifo_sz) - 1) - $unsigned(i);
        end //for loop

        // Enable for stat registers (partitioned into banks of eight)
        // Take care of the head first
        if (ph_en != 0)
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en & active;
        else
          en_l_s[(((fifo_sz > 0) ? fifo_sz : 1)-1)/8] = en | ~active;

        // Now every eight
        for (i = fifo_sz-1; i >= 7; i = i - 1)
        begin
          if (($unsigned(i)%8) == 0)
          begin
            if (ph_en != 0)
              en_l_s[(i/8)-1] = en & (stat[i]) & (active);
            else
              en_l_s[(i/8)-1] = en | ~(stat[i]) | ~(active);
          end
        end

        // Update count and peak
        if ( stat[fifo_sz-1] == 1'b0 )
          count_t = 32'b0;
        else if ( stat[0] == 1'b1 )
          count_t = fifo_sz;
        else
          count_t = n_elem[31:0];
        count = count_t;
// synopsys translate_off
        if ( peak < count )
          peak = count;
// synopsys translate_on
      end //FIFOPROC

      // Handshake valid after reset
      esp_acc_softmax_cxx_ccs_genreg_v1
      #(
        .width   (1),
        .ph_clk  (ph_clk),
        .ph_en   (1),
        .ph_arst (ph_arst),
        .ph_srst (ph_srst),
        .has_en  (1'b0)
      )
      HS_INIT_REG
      (
        .clk     (clk),
        .en      (1'b1),
        .arst    (arst),
        .srst    (srst),
        .d       (1'b1),
        .z       (hs_init)
      );

      // Buffer and status registers
      for (eni = fifo_sz-1; eni >= 0; eni = eni - 1)
      begin: GEN_REGS
        esp_acc_softmax_cxx_ccs_genreg_v1
        #(
          .width   (1),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        STATREG
        (
          .clk     (clk),
          .en      (en_l_s[eni/8]),
          .arst    (arst),
          .srst    (srst),
          .d       (stat_pre[eni]),
          .z       (stat[eni])
        );

        esp_acc_softmax_cxx_ccs_genreg_v1
        #(
          .width   (width),
          .ph_clk  (ph_clk),
          .ph_en   (ph_en),
          .ph_arst (ph_arst),
          .ph_srst (ph_srst),
          .has_en  (1'b1)
        )
        BUFREG
        (
          .clk     (clk),
          .en      (en_l[eni]),
          .arst    (arst),
          .srst    (srst),
          .d       (buff_pre[width*eni+:width]),
          .z       (buff[width*eni+:width])
        );
      end

    end
    else
    begin: FEED_THRU
      assign din_rdy_drv  = dout_rdy;
      assign dout_vld_drv = din_vld;
      assign dout     = din;
      // non-blocking is not II=1 when fifo_sz=0
      assign sd = {{(sz_width-1){1'b0}}, (din_vld & ~dout_rdy)};
    end
    endgenerate

`ifdef RDY_ASRT
    generate
    if (ph_clk==1)
    begin: POS_CLK_ASSERT

       property rdyAsrt ;
         @(posedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (din_rdy==0);
       endproperty
       a1Pos: assert property(rdyAsrt);

    end else if (ph_clk==0)
    begin: NEG_CLK_ASSERT

       property rdyAsrt ;
         @(negedge clk) ((srst==ph_srst) || (arst==ph_arst)) |=> (din_rdy==0);
       endproperty
       a1Neg: assert property(rdyAsrt);

    end
    endgenerate

`endif

endmodule



//------> ./softmax_cxx_ccs_pipe_v5.v 
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
/*
 *
 *            _______________________________________________
 * WRITER    |                                              |          READER
 *           |                 ccs_pipe                     |
 *           |            ______________________            |
 *        --<| din_rdy --<|  ---------------- <|---dout_rdy<|---
 *           |            |       FIFO         |            |
 *        ---|>din_vld ---|> ----------------  |>--dout_vld |>--
 *        ---|>din -------|> ----------------  |> -----dout |>--
 *           |            |____________________|            |
 *           |______________________________________________|
 *
 *    din_rdy     - can be considered as a notFULL signal
 *    dout_vld    - can be considered as a notEMPTY signal
 *    write_stall - an internal debug signal formed from din_vld & !din_rdy
 *    read_stall  - an internal debug signal formed from dout_rdy & !dout_vld
 *    is_idle     - indicates the clock can be safely gated
 */

module esp_acc_softmax_cxx_ccs_pipe_v5 (clk, en, arst, srst, din_rdy, din_vld, din, dout_rdy, dout_vld, dout, sz, sz_req, is_idle);

    parameter integer rscid    = 0; // resource ID
    parameter integer width    = 8; // fifo width
    parameter integer sz_width = 8; // width of size of elements in fifo
    parameter integer fifo_sz  = 8; // fifo depth
    parameter integer log2_sz  = 3; // log2(fifo_sz)
    parameter integer ph_clk   = 1; // clock polarity 1=rising edge, 0=falling edge
    parameter integer ph_en    = 1; // clock enable polarity
    parameter integer ph_arst  = 1; // async reset polarity
    parameter integer ph_srst  = 1; // sync reset polarity

    // clock
    input              clk;
    input              en;
    input              arst;
    input              srst;

    // writer
    output             din_rdy;
    input              din_vld;
    input  [width-1:0] din;

    // reader
    input              dout_rdy;
    output             dout_vld;
    output [width-1:0] dout;

    // size
    output [sz_width-1:0] sz;
    input                 sz_req;
    output                is_idle;

// synopsys translate_off
    wire   write_stall;
    wire   read_stall;
    assign write_stall = din_vld & !din_rdy;
    assign read_stall  = dout_rdy & !dout_vld;
// synopsys translate_on

    esp_acc_softmax_cxx_ccs_fifo_wait_core_v5
    #(
        .rscid    (rscid),
        .width    (width),
        .sz_width (sz_width),
        .fifo_sz  (fifo_sz),
        .ph_clk   (ph_clk),
        .ph_en    (ph_en),
        .ph_arst  (ph_arst),
        .ph_srst  (ph_srst),
        .ph_log2  (log2_sz)
    )
    FIFO
    (
        .clk      (clk),
        .en       (en),
        .arst     (arst),
        .srst     (srst),
        .din_vld  (din_vld),
        .din_rdy  (din_rdy),
        .din      (din),
        .dout_vld (dout_vld),
        .dout_rdy (dout_rdy),
        .dout     (dout),
        .sd       (sz),
        .is_idle  (is_idle)
    );

endmodule


//------> ./softmax_cxx_ccs_sync_pipe_v1.v 
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

module esp_acc_softmax_cxx_ccs_sync_pipe_v1 (dout_vld, dout_rdy, din_vld, din_rdy);
  parameter integer rscid = 1;

  input  din_vld;
  output dout_vld;
  input  dout_rdy;
  output din_rdy;

  wire   dout_vld;
  wire   din_rdy;

  assign dout_vld = din_vld;
  assign din_rdy = dout_rdy;
endmodule

//------> ./softmax_cxx.v 
// ----------------------------------------------------------------------
//  HLS HDL:        Verilog Netlister
//  HLS Version:    10.5a/871028 Production Release
//  HLS Date:       Tue Apr 14 07:55:32 PDT 2020
// 
//  Generated by:   giuseppe@fastml02
//  Generated date: Fri Jun  5 18:39:58 2020
// ----------------------------------------------------------------------

// 
// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_plm_out_cns_bctl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_plm_out_cns_bctl (
  clk, rst, plm_out_rsc_wadr_ncompute_inst, plm_out_rsc_d_ncompute_inst, plm_out_rsc_we_ncompute_inst,
      plm_out_rsc_req_vz_ncompute_inst, plm_out_rsc_we_ncompute_inst_buz, conf_info_rsc_rdy_nstore_inst,
      plm_out_rsc_radr_nstore_inst, plm_out_rsc_q_nstore_inst, plm_out_rsc_req_vz_nstore_inst,
      dma_write_ctrl_rsc_vld_nstore_inst, dma_write_chnl_rsc_vld_nstore_inst, done_rsc_vld_nstore_inst,
      conf_info_rsc_rdy_nstore_inst_bud, plm_out_rsc_we_ncompute_inst_buz_bud, plm_out_rsc_rls_lz_ncompute_inst_bud,
      plm_out_rsc_rls_lz_nstore_inst_bud, dma_write_ctrl_rsc_vld_nstore_inst_bud,
      dma_write_chnl_rsc_vld_nstore_inst_bud, done_rsc_vld_nstore_inst_bud, plm_out_cns_S0,
      plm_out_cns_R0, plm_out_cns_S1, plm_out_cns_R1, plm_out_cns_d_shi0, plm_out_cns_d_shi1,
      plm_out_cns_q_sho0, plm_out_cns_q_sho1, plm_out_cns_radr_shi0, plm_out_cns_radr_shi1,
      plm_out_cns_wadr_shi0, plm_out_cns_wadr_shi1, plm_out_cns_we_shi0, plm_out_cns_we_shi1,
      plm_out_rsc_we_ncompute_inst_buz_pff, plm_out_rsc_we_ncompute_inst_buz_bud_pff,
      plm_out_cns_S0_pff
);
  input clk;
  input rst;
  input [6:0] plm_out_rsc_wadr_ncompute_inst;
  input [31:0] plm_out_rsc_d_ncompute_inst;
  input plm_out_rsc_we_ncompute_inst;
  output plm_out_rsc_req_vz_ncompute_inst;
  input plm_out_rsc_we_ncompute_inst_buz;
  output conf_info_rsc_rdy_nstore_inst;
  input [6:0] plm_out_rsc_radr_nstore_inst;
  output [31:0] plm_out_rsc_q_nstore_inst;
  output plm_out_rsc_req_vz_nstore_inst;
  output dma_write_ctrl_rsc_vld_nstore_inst;
  output dma_write_chnl_rsc_vld_nstore_inst;
  output done_rsc_vld_nstore_inst;
  input conf_info_rsc_rdy_nstore_inst_bud;
  output plm_out_rsc_we_ncompute_inst_buz_bud;
  input plm_out_rsc_rls_lz_ncompute_inst_bud;
  input plm_out_rsc_rls_lz_nstore_inst_bud;
  input dma_write_ctrl_rsc_vld_nstore_inst_bud;
  input dma_write_chnl_rsc_vld_nstore_inst_bud;
  input done_rsc_vld_nstore_inst_bud;
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
  assign conf_info_rsc_rdy_nstore_inst = conf_info_rsc_rdy_nstore_inst_bud;
  assign dma_write_ctrl_rsc_vld_nstore_inst = dma_write_ctrl_rsc_vld_nstore_inst_bud;
  assign dma_write_chnl_rsc_vld_nstore_inst = dma_write_chnl_rsc_vld_nstore_inst_bud;
  assign done_rsc_vld_nstore_inst = done_rsc_vld_nstore_inst_bud;
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
    if ( ~ rst ) begin
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
  clk, rst, conf_info_rsc_rdy_nload_inst, plm_in_rsc_wadr_nload_inst, plm_in_rsc_d_nload_inst,
      plm_in_rsc_we_nload_inst, plm_in_rsc_req_vz_nload_inst, dma_read_ctrl_rsc_vld_nload_inst,
      dma_read_chnl_rsc_rdy_nload_inst, done_rsc_vld_nload_inst, conf_info_rsc_rdy_ncompute_inst,
      plm_in_rsc_radr_ncompute_inst, plm_in_rsc_q_ncompute_inst, plm_in_rsc_req_vz_ncompute_inst,
      done_rsc_vld_ncompute_inst, plm_out_rsc_we_ncompute_inst_buz, conf_info_rsc_rdy_nload_inst_bud,
      conf_info_rsc_rdy_ncompute_inst_bud, plm_in_rsc_rls_lz_nload_inst_bud, plm_in_rsc_rls_lz_ncompute_inst_bud,
      dma_read_ctrl_rsc_vld_nload_inst_bud, dma_read_chnl_rsc_rdy_nload_inst_bud,
      done_rsc_vld_nload_inst_bud, plm_out_rsc_we_ncompute_inst_buz_bud, plm_out_rsc_rls_lz_ncompute_inst_bud,
      done_rsc_vld_ncompute_inst_bud, plm_in_cns_S0, plm_in_cns_R0, plm_in_cns_S1,
      plm_in_cns_R1, plm_in_cns_d_shi0, plm_in_cns_d_shi1, plm_in_cns_q_sho0, plm_in_cns_q_sho1,
      plm_in_cns_radr_shi0, plm_in_cns_radr_shi1, plm_in_cns_wadr_shi0, plm_in_cns_wadr_shi1,
      plm_in_cns_we_shi0, plm_in_cns_we_shi1, plm_in_cns_S0_pff, plm_out_rsc_we_ncompute_inst_buz_pff,
      plm_out_rsc_we_ncompute_inst_buz_bud_pff
);
  input clk;
  input rst;
  output conf_info_rsc_rdy_nload_inst;
  input [6:0] plm_in_rsc_wadr_nload_inst;
  input [31:0] plm_in_rsc_d_nload_inst;
  input plm_in_rsc_we_nload_inst;
  output plm_in_rsc_req_vz_nload_inst;
  output dma_read_ctrl_rsc_vld_nload_inst;
  output dma_read_chnl_rsc_rdy_nload_inst;
  output done_rsc_vld_nload_inst;
  output conf_info_rsc_rdy_ncompute_inst;
  input [6:0] plm_in_rsc_radr_ncompute_inst;
  output [31:0] plm_in_rsc_q_ncompute_inst;
  output plm_in_rsc_req_vz_ncompute_inst;
  output done_rsc_vld_ncompute_inst;
  output plm_out_rsc_we_ncompute_inst_buz;
  input conf_info_rsc_rdy_nload_inst_bud;
  input conf_info_rsc_rdy_ncompute_inst_bud;
  input plm_in_rsc_rls_lz_nload_inst_bud;
  input plm_in_rsc_rls_lz_ncompute_inst_bud;
  input dma_read_ctrl_rsc_vld_nload_inst_bud;
  input dma_read_chnl_rsc_rdy_nload_inst_bud;
  input done_rsc_vld_nload_inst_bud;
  input plm_out_rsc_we_ncompute_inst_buz_bud;
  input plm_out_rsc_rls_lz_ncompute_inst_bud;
  input done_rsc_vld_ncompute_inst_bud;
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
  assign conf_info_rsc_rdy_nload_inst = conf_info_rsc_rdy_nload_inst_bud;
  assign conf_info_rsc_rdy_ncompute_inst = conf_info_rsc_rdy_ncompute_inst_bud;
  assign dma_read_ctrl_rsc_vld_nload_inst = dma_read_ctrl_rsc_vld_nload_inst_bud;
  assign dma_read_chnl_rsc_rdy_nload_inst = dma_read_chnl_rsc_rdy_nload_inst_bud;
  assign done_rsc_vld_nload_inst = done_rsc_vld_nload_inst_bud;
  assign done_rsc_vld_ncompute_inst = done_rsc_vld_ncompute_inst_bud;
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
    if ( ~ rst ) begin
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_core_fsm
//  FSM Module
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_core_fsm (
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_softmax_cxx_core_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_softmax_cxx_core_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_staller (
  clk, rst, core_wen, core_wten, config_done_cnsi_wen_comp, load_done_cnsi_wen_comp,
      compute_done_cnsi_wen_comp, store_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  reg core_wten;
  input config_done_cnsi_wen_comp;
  input load_done_cnsi_wen_comp;
  input compute_done_cnsi_wen_comp;
  input store_done_cnsi_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = config_done_cnsi_wen_comp & load_done_cnsi_wen_comp & compute_done_cnsi_wen_comp
      & store_done_cnsi_wen_comp;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      core_wten <= 1'b0;
    end
    else begin
      core_wten <= ~ core_wen;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi_store_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi_store_done_wait_dp
    (
  clk, rst, store_done_cnsi_oswt_unreg, store_done_cnsi_bawt, store_done_cnsi_wen_comp,
      store_done_cnsi_biwt, store_done_cnsi_bdwt, store_done_cnsi_bcwt
);
  input clk;
  input rst;
  input store_done_cnsi_oswt_unreg;
  output store_done_cnsi_bawt;
  output store_done_cnsi_wen_comp;
  input store_done_cnsi_biwt;
  input store_done_cnsi_bdwt;
  output store_done_cnsi_bcwt;
  reg store_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign store_done_cnsi_bawt = store_done_cnsi_biwt | store_done_cnsi_bcwt;
  assign store_done_cnsi_wen_comp = (~ store_done_cnsi_oswt_unreg) | store_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      store_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      store_done_cnsi_bcwt <= ~((~(store_done_cnsi_bcwt | store_done_cnsi_biwt))
          | store_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi_store_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi_store_done_wait_ctrl
    (
  core_wen, store_done_cnsi_oswt_unreg, store_done_cnsi_iswt0, store_done_cnsi_ivld,
      store_done_cnsi_biwt, store_done_cnsi_bdwt, store_done_cnsi_bcwt, store_done_cnsi_irdy_core_sct
);
  input core_wen;
  input store_done_cnsi_oswt_unreg;
  input store_done_cnsi_iswt0;
  input store_done_cnsi_ivld;
  output store_done_cnsi_biwt;
  output store_done_cnsi_bdwt;
  input store_done_cnsi_bcwt;
  output store_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire store_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign store_done_cnsi_bdwt = store_done_cnsi_oswt_unreg & core_wen;
  assign store_done_cnsi_biwt = store_done_cnsi_ogwt & store_done_cnsi_ivld;
  assign store_done_cnsi_ogwt = store_done_cnsi_iswt0 & (~ store_done_cnsi_bcwt);
  assign store_done_cnsi_irdy_core_sct = store_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_dp
    (
  clk, rst, compute_done_cnsi_oswt_unreg, compute_done_cnsi_bawt, compute_done_cnsi_wen_comp,
      compute_done_cnsi_biwt, compute_done_cnsi_bdwt, compute_done_cnsi_bcwt
);
  input clk;
  input rst;
  input compute_done_cnsi_oswt_unreg;
  output compute_done_cnsi_bawt;
  output compute_done_cnsi_wen_comp;
  input compute_done_cnsi_biwt;
  input compute_done_cnsi_bdwt;
  output compute_done_cnsi_bcwt;
  reg compute_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign compute_done_cnsi_bawt = compute_done_cnsi_biwt | compute_done_cnsi_bcwt;
  assign compute_done_cnsi_wen_comp = (~ compute_done_cnsi_oswt_unreg) | compute_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      compute_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      compute_done_cnsi_bcwt <= ~((~(compute_done_cnsi_bcwt | compute_done_cnsi_biwt))
          | compute_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_ctrl
    (
  core_wen, compute_done_cnsi_oswt_unreg, compute_done_cnsi_iswt0, compute_done_cnsi_ivld,
      compute_done_cnsi_biwt, compute_done_cnsi_bdwt, compute_done_cnsi_bcwt, compute_done_cnsi_irdy_core_sct
);
  input core_wen;
  input compute_done_cnsi_oswt_unreg;
  input compute_done_cnsi_iswt0;
  input compute_done_cnsi_ivld;
  output compute_done_cnsi_biwt;
  output compute_done_cnsi_bdwt;
  input compute_done_cnsi_bcwt;
  output compute_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire compute_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign compute_done_cnsi_bdwt = compute_done_cnsi_oswt_unreg & core_wen;
  assign compute_done_cnsi_biwt = compute_done_cnsi_ogwt & compute_done_cnsi_ivld;
  assign compute_done_cnsi_ogwt = compute_done_cnsi_iswt0 & (~ compute_done_cnsi_bcwt);
  assign compute_done_cnsi_irdy_core_sct = compute_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi_load_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi_load_done_wait_dp
    (
  clk, rst, load_done_cnsi_oswt_unreg, load_done_cnsi_bawt, load_done_cnsi_wen_comp,
      load_done_cnsi_biwt, load_done_cnsi_bdwt, load_done_cnsi_bcwt
);
  input clk;
  input rst;
  input load_done_cnsi_oswt_unreg;
  output load_done_cnsi_bawt;
  output load_done_cnsi_wen_comp;
  input load_done_cnsi_biwt;
  input load_done_cnsi_bdwt;
  output load_done_cnsi_bcwt;
  reg load_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign load_done_cnsi_bawt = load_done_cnsi_biwt | load_done_cnsi_bcwt;
  assign load_done_cnsi_wen_comp = (~ load_done_cnsi_oswt_unreg) | load_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      load_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      load_done_cnsi_bcwt <= ~((~(load_done_cnsi_bcwt | load_done_cnsi_biwt)) | load_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi_load_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi_load_done_wait_ctrl
    (
  core_wen, load_done_cnsi_oswt_unreg, load_done_cnsi_iswt0, load_done_cnsi_irdy_core_psct,
      load_done_cnsi_ivld, load_done_cnsi_biwt, load_done_cnsi_bdwt, load_done_cnsi_bcwt,
      load_done_cnsi_irdy_core_sct
);
  input core_wen;
  input load_done_cnsi_oswt_unreg;
  input load_done_cnsi_iswt0;
  input load_done_cnsi_irdy_core_psct;
  input load_done_cnsi_ivld;
  output load_done_cnsi_biwt;
  output load_done_cnsi_bdwt;
  input load_done_cnsi_bcwt;
  output load_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire load_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign load_done_cnsi_bdwt = load_done_cnsi_oswt_unreg & core_wen;
  assign load_done_cnsi_biwt = load_done_cnsi_ogwt & load_done_cnsi_ivld;
  assign load_done_cnsi_ogwt = load_done_cnsi_iswt0 & (~ load_done_cnsi_bcwt);
  assign load_done_cnsi_irdy_core_sct = load_done_cnsi_irdy_core_psct & load_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi_config_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi_config_done_wait_dp
    (
  clk, rst, config_done_cnsi_oswt_unreg, config_done_cnsi_bawt, config_done_cnsi_wen_comp,
      config_done_cnsi_biwt, config_done_cnsi_bdwt, config_done_cnsi_bcwt
);
  input clk;
  input rst;
  input config_done_cnsi_oswt_unreg;
  output config_done_cnsi_bawt;
  output config_done_cnsi_wen_comp;
  input config_done_cnsi_biwt;
  input config_done_cnsi_bdwt;
  output config_done_cnsi_bcwt;
  reg config_done_cnsi_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign config_done_cnsi_bawt = config_done_cnsi_biwt | config_done_cnsi_bcwt;
  assign config_done_cnsi_wen_comp = (~ config_done_cnsi_oswt_unreg) | config_done_cnsi_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      config_done_cnsi_bcwt <= 1'b0;
    end
    else begin
      config_done_cnsi_bcwt <= ~((~(config_done_cnsi_bcwt | config_done_cnsi_biwt))
          | config_done_cnsi_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi_config_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi_config_done_wait_ctrl
    (
  core_wen, config_done_cnsi_oswt_unreg, config_done_cnsi_iswt0, config_done_cnsi_ivld,
      config_done_cnsi_biwt, config_done_cnsi_bdwt, config_done_cnsi_bcwt, config_done_cnsi_irdy_core_sct
);
  input core_wen;
  input config_done_cnsi_oswt_unreg;
  input config_done_cnsi_iswt0;
  input config_done_cnsi_ivld;
  output config_done_cnsi_biwt;
  output config_done_cnsi_bdwt;
  input config_done_cnsi_bcwt;
  output config_done_cnsi_irdy_core_sct;


  // Interconnect Declarations
  wire config_done_cnsi_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign config_done_cnsi_bdwt = config_done_cnsi_oswt_unreg & core_wen;
  assign config_done_cnsi_biwt = config_done_cnsi_ogwt & config_done_cnsi_ivld;
  assign config_done_cnsi_ogwt = config_done_cnsi_iswt0 & (~ config_done_cnsi_bcwt);
  assign config_done_cnsi_irdy_core_sct = config_done_cnsi_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci_acc_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci_acc_done_wait_dp (
  clk, rst, acc_done_rsci_bawt, acc_done_rsci_biwt, acc_done_rsci_bdwt
);
  input clk;
  input rst;
  output acc_done_rsci_bawt;
  input acc_done_rsci_biwt;
  input acc_done_rsci_bdwt;


  // Interconnect Declarations
  reg acc_done_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign acc_done_rsci_bawt = acc_done_rsci_biwt | acc_done_rsci_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      acc_done_rsci_bcwt <= 1'b0;
    end
    else begin
      acc_done_rsci_bcwt <= ~((~(acc_done_rsci_bcwt | acc_done_rsci_biwt)) | acc_done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci_acc_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci_acc_done_wait_ctrl
    (
  core_wen, acc_done_rsci_oswt_unreg, acc_done_rsci_iswt0, core_wten, acc_done_rsci_biwt,
      acc_done_rsci_bdwt
);
  input core_wen;
  input acc_done_rsci_oswt_unreg;
  input acc_done_rsci_iswt0;
  input core_wten;
  output acc_done_rsci_biwt;
  output acc_done_rsci_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign acc_done_rsci_bdwt = acc_done_rsci_oswt_unreg & core_wen;
  assign acc_done_rsci_biwt = (~ core_wten) & acc_done_rsci_iswt0;
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
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_config_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_config_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
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
//  Design Unit:    esp_acc_softmax_cxx_config_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_staller (
  core_wen, conf_info_rsci_wen_comp, plm_conf_load_rsci_wen_comp, plm_conf_compute_rsci_wen_comp,
      plm_conf_store_rsci_wen_comp, done_rsci_wen_comp
);
  output core_wen;
  input conf_info_rsci_wen_comp;
  input plm_conf_load_rsci_wen_comp;
  input plm_conf_compute_rsci_wen_comp;
  input plm_conf_store_rsci_wen_comp;
  input done_rsci_wen_comp;



  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & plm_conf_load_rsci_wen_comp & plm_conf_compute_rsci_wen_comp
      & plm_conf_store_rsci_wen_comp & done_rsci_wen_comp;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp
    (
  clk, rst, plm_conf_store_rsci_oswt_unreg, plm_conf_store_rsci_bawt, plm_conf_store_rsci_wen_comp,
      plm_conf_store_rsci_biwt, plm_conf_store_rsci_bdwt, plm_conf_store_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_store_rsci_oswt_unreg;
  output plm_conf_store_rsci_bawt;
  output plm_conf_store_rsci_wen_comp;
  input plm_conf_store_rsci_biwt;
  input plm_conf_store_rsci_bdwt;
  output plm_conf_store_rsci_bcwt;
  reg plm_conf_store_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_store_rsci_bawt = plm_conf_store_rsci_biwt | plm_conf_store_rsci_bcwt;
  assign plm_conf_store_rsci_wen_comp = (~ plm_conf_store_rsci_oswt_unreg) | plm_conf_store_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_conf_store_rsci_oswt_unreg, plm_conf_store_rsci_iswt0, plm_conf_store_rsci_irdy_oreg,
      plm_conf_store_rsci_biwt, plm_conf_store_rsci_bdwt, plm_conf_store_rsci_bcwt,
      plm_conf_store_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_store_rsci_oswt_unreg;
  input plm_conf_store_rsci_iswt0;
  input plm_conf_store_rsci_irdy_oreg;
  output plm_conf_store_rsci_biwt;
  output plm_conf_store_rsci_bdwt;
  input plm_conf_store_rsci_bcwt;
  output plm_conf_store_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_store_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_store_rsci_bdwt = plm_conf_store_rsci_oswt_unreg & core_wen;
  assign plm_conf_store_rsci_biwt = plm_conf_store_rsci_ogwt & plm_conf_store_rsci_irdy_oreg;
  assign plm_conf_store_rsci_ogwt = plm_conf_store_rsci_iswt0 & (~ plm_conf_store_rsci_bcwt);
  assign plm_conf_store_rsci_ivld_core_sct = plm_conf_store_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
    (
  clk, rst, plm_conf_compute_rsci_oswt_unreg, plm_conf_compute_rsci_bawt, plm_conf_compute_rsci_wen_comp,
      plm_conf_compute_rsci_biwt, plm_conf_compute_rsci_bdwt, plm_conf_compute_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_compute_rsci_oswt_unreg;
  output plm_conf_compute_rsci_bawt;
  output plm_conf_compute_rsci_wen_comp;
  input plm_conf_compute_rsci_biwt;
  input plm_conf_compute_rsci_bdwt;
  output plm_conf_compute_rsci_bcwt;
  reg plm_conf_compute_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_compute_rsci_bawt = plm_conf_compute_rsci_biwt | plm_conf_compute_rsci_bcwt;
  assign plm_conf_compute_rsci_wen_comp = (~ plm_conf_compute_rsci_oswt_unreg) |
      plm_conf_compute_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_conf_compute_rsci_oswt_unreg, plm_conf_compute_rsci_iswt0, plm_conf_compute_rsci_irdy_oreg,
      plm_conf_compute_rsci_biwt, plm_conf_compute_rsci_bdwt, plm_conf_compute_rsci_bcwt,
      plm_conf_compute_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_compute_rsci_oswt_unreg;
  input plm_conf_compute_rsci_iswt0;
  input plm_conf_compute_rsci_irdy_oreg;
  output plm_conf_compute_rsci_biwt;
  output plm_conf_compute_rsci_bdwt;
  input plm_conf_compute_rsci_bcwt;
  output plm_conf_compute_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_compute_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_compute_rsci_bdwt = plm_conf_compute_rsci_oswt_unreg & core_wen;
  assign plm_conf_compute_rsci_biwt = plm_conf_compute_rsci_ogwt & plm_conf_compute_rsci_irdy_oreg;
  assign plm_conf_compute_rsci_ogwt = plm_conf_compute_rsci_iswt0 & (~ plm_conf_compute_rsci_bcwt);
  assign plm_conf_compute_rsci_ivld_core_sct = plm_conf_compute_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp (
  clk, rst, plm_conf_load_rsci_oswt_unreg, plm_conf_load_rsci_bawt, plm_conf_load_rsci_wen_comp,
      plm_conf_load_rsci_biwt, plm_conf_load_rsci_bdwt, plm_conf_load_rsci_bcwt
);
  input clk;
  input rst;
  input plm_conf_load_rsci_oswt_unreg;
  output plm_conf_load_rsci_bawt;
  output plm_conf_load_rsci_wen_comp;
  input plm_conf_load_rsci_biwt;
  input plm_conf_load_rsci_bdwt;
  output plm_conf_load_rsci_bcwt;
  reg plm_conf_load_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_bawt = plm_conf_load_rsci_biwt | plm_conf_load_rsci_bcwt;
  assign plm_conf_load_rsci_wen_comp = (~ plm_conf_load_rsci_oswt_unreg) | plm_conf_load_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_conf_load_rsci_oswt_unreg, plm_conf_load_rsci_iswt0, plm_conf_load_rsci_irdy_oreg,
      plm_conf_load_rsci_biwt, plm_conf_load_rsci_bdwt, plm_conf_load_rsci_bcwt,
      plm_conf_load_rsci_ivld_core_sct
);
  input core_wen;
  input plm_conf_load_rsci_oswt_unreg;
  input plm_conf_load_rsci_iswt0;
  input plm_conf_load_rsci_irdy_oreg;
  output plm_conf_load_rsci_biwt;
  output plm_conf_load_rsci_bdwt;
  input plm_conf_load_rsci_bcwt;
  output plm_conf_load_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire plm_conf_load_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_bdwt = plm_conf_load_rsci_oswt_unreg & core_wen;
  assign plm_conf_load_rsci_biwt = plm_conf_load_rsci_ogwt & plm_conf_load_rsci_irdy_oreg;
  assign plm_conf_load_rsci_ogwt = plm_conf_load_rsci_iswt0 & (~ plm_conf_load_rsci_bcwt);
  assign plm_conf_load_rsci_ivld_core_sct = plm_conf_load_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_wait_dp (
  clk, rst, plm_conf_load_rsci_irdy, plm_conf_load_rsci_irdy_oreg, plm_conf_compute_rsci_irdy,
      plm_conf_compute_rsci_irdy_oreg, plm_conf_store_rsci_irdy, plm_conf_store_rsci_irdy_oreg
);
  input clk;
  input rst;
  input plm_conf_load_rsci_irdy;
  output plm_conf_load_rsci_irdy_oreg;
  input plm_conf_compute_rsci_irdy;
  output plm_conf_compute_rsci_irdy_oreg;
  input plm_conf_store_rsci_irdy;
  output plm_conf_store_rsci_irdy_oreg;


  // Interconnect Declarations
  reg plm_conf_load_rsci_irdy_oreg_rneg;
  reg plm_conf_compute_rsci_irdy_oreg_rneg;
  reg plm_conf_store_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign plm_conf_load_rsci_irdy_oreg = ~ plm_conf_load_rsci_irdy_oreg_rneg;
  assign plm_conf_compute_rsci_irdy_oreg = ~ plm_conf_compute_rsci_irdy_oreg_rneg;
  assign plm_conf_store_rsci_irdy_oreg = ~ plm_conf_store_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_load_rsci_irdy_oreg_rneg <= 1'b0;
      plm_conf_compute_rsci_irdy_oreg_rneg <= 1'b0;
      plm_conf_store_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      plm_conf_load_rsci_irdy_oreg_rneg <= ~ plm_conf_load_rsci_irdy;
      plm_conf_compute_rsci_irdy_oreg_rneg <= ~ plm_conf_compute_rsci_irdy;
      plm_conf_store_rsci_irdy_oreg_rneg <= ~ plm_conf_store_rsci_irdy;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
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
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
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
//  Design Unit:    esp_acc_softmax_cxx_config_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_conf_info_rsci_conf_info_wait_ctrl (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_biwt,
      conf_info_rsci_bdwt, conf_info_rsci_bcwt, conf_info_rsci_irdy_core_sct, conf_info_rsci_ivld
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;
  input conf_info_rsci_ivld;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_7_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_7_7_32_128_128_32_1_gen
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
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_load_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_load_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, dma_read_chnl_rsci_wen_comp,
      done_rsci_wen_comp, plm_in_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input conf_info_rsci_wen_comp;
  input dma_read_chnl_rsci_wen_comp;
  input done_rsci_wen_comp;
  input plm_in_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & dma_read_chnl_rsci_wen_comp & done_rsci_wen_comp
      & plm_in_rsc_req_obj_wen_comp;
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp (
  clk, rst, plm_in_rsc_req_obj_oswt_unreg, plm_in_rsc_req_obj_bawt, plm_in_rsc_req_obj_wen_comp,
      plm_in_rsc_req_obj_biwt, plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_in_rsc_req_obj_oswt_unreg;
  output plm_in_rsc_req_obj_bawt;
  output plm_in_rsc_req_obj_wen_comp;
  input plm_in_rsc_req_obj_biwt;
  input plm_in_rsc_req_obj_bdwt;
  output plm_in_rsc_req_obj_bcwt;
  reg plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_bawt = plm_in_rsc_req_obj_biwt | plm_in_rsc_req_obj_bcwt;
  assign plm_in_rsc_req_obj_wen_comp = (~ plm_in_rsc_req_obj_oswt_unreg) | plm_in_rsc_req_obj_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_in_rsc_req_obj_oswt_unreg, plm_in_rsc_req_obj_iswt0, plm_in_rsc_req_obj_vd,
      plm_in_rsc_req_obj_biwt, plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_in_rsc_req_obj_oswt_unreg;
  input plm_in_rsc_req_obj_iswt0;
  input plm_in_rsc_req_obj_vd;
  output plm_in_rsc_req_obj_biwt;
  output plm_in_rsc_req_obj_bdwt;
  input plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_bdwt = plm_in_rsc_req_obj_oswt_unreg & core_wen;
  assign plm_in_rsc_req_obj_biwt = plm_in_rsc_req_obj_iswt0 & (~ plm_in_rsc_req_obj_bcwt)
      & plm_in_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp (
  clk, rst, plm_in_rsc_rls_obj_bawt, plm_in_rsc_rls_obj_biwt, plm_in_rsc_rls_obj_bdwt
);
  input clk;
  input rst;
  output plm_in_rsc_rls_obj_bawt;
  input plm_in_rsc_rls_obj_biwt;
  input plm_in_rsc_rls_obj_bdwt;


  // Interconnect Declarations
  reg plm_in_rsc_rls_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_rls_obj_bawt = plm_in_rsc_rls_obj_biwt | plm_in_rsc_rls_obj_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsc_rls_obj_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsc_rls_obj_bcwt <= ~((~(plm_in_rsc_rls_obj_bcwt | plm_in_rsc_rls_obj_biwt))
          | plm_in_rsc_rls_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
    (
  core_wen, core_wten, plm_in_rsc_rls_obj_oswt_unreg, plm_in_rsc_rls_obj_iswt0, plm_in_rsc_rls_obj_biwt,
      plm_in_rsc_rls_obj_bdwt
);
  input core_wen;
  input core_wten;
  input plm_in_rsc_rls_obj_oswt_unreg;
  input plm_in_rsc_rls_obj_iswt0;
  output plm_in_rsc_rls_obj_biwt;
  output plm_in_rsc_rls_obj_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_rls_obj_bdwt = plm_in_rsc_rls_obj_oswt_unreg & core_wen;
  assign plm_in_rsc_rls_obj_biwt = (~ core_wten) & plm_in_rsc_rls_obj_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl (
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp (
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl (
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
    if ( ~ rst ) begin
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
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
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_conf_info_rsci_conf_info_wait_ctrl (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld_oreg, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  input conf_info_rsci_irdy_core_psct;
  input conf_info_rsci_ivld_oreg;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld_oreg;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_irdy_core_psct & conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_wait_dp (
  clk, rst, conf_info_rsci_ivld, conf_info_rsci_ivld_oreg
);
  input clk;
  input rst;
  input conf_info_rsci_ivld;
  output conf_info_rsci_ivld_oreg;


  // Interconnect Declarations
  reg conf_info_rsci_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_ivld_oreg = ~ conf_info_rsci_ivld_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_rsci_ivld_oreg_rneg <= ~ conf_info_rsci_ivld;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_18_7_67_128_128_67_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_18_7_67_128_128_67_1_gen
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
//  Design Unit:    esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_14_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_14_7_32_128_128_32_1_gen
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
//  Design Unit:    esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_13_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_13_7_32_128_128_32_1_gen
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
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_compute_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_compute_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
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
//  Design Unit:    esp_acc_softmax_cxx_compute_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, done_rsci_wen_comp, plm_in_rsc_req_obj_wen_comp,
      plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input conf_info_rsci_wen_comp;
  input done_rsci_wen_comp;
  input plm_in_rsc_req_obj_wen_comp;
  input plm_out_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & done_rsci_wen_comp & plm_in_rsc_req_obj_wen_comp
      & plm_out_rsc_req_obj_wen_comp;
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
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
    (
  clk, rst, plm_out_rsc_req_obj_oswt_unreg, plm_out_rsc_req_obj_bawt, plm_out_rsc_req_obj_wen_comp,
      plm_out_rsc_req_obj_biwt, plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_out_rsc_req_obj_oswt_unreg;
  output plm_out_rsc_req_obj_bawt;
  output plm_out_rsc_req_obj_wen_comp;
  input plm_out_rsc_req_obj_biwt;
  input plm_out_rsc_req_obj_bdwt;
  output plm_out_rsc_req_obj_bcwt;
  reg plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_bawt = plm_out_rsc_req_obj_biwt | plm_out_rsc_req_obj_bcwt;
  assign plm_out_rsc_req_obj_wen_comp = (~ plm_out_rsc_req_obj_oswt_unreg) | plm_out_rsc_req_obj_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_out_rsc_req_obj_oswt_unreg, plm_out_rsc_req_obj_iswt0, plm_out_rsc_req_obj_vd,
      plm_out_rsc_req_obj_biwt, plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_out_rsc_req_obj_oswt_unreg;
  input plm_out_rsc_req_obj_iswt0;
  input plm_out_rsc_req_obj_vd;
  output plm_out_rsc_req_obj_biwt;
  output plm_out_rsc_req_obj_bdwt;
  input plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_bdwt = plm_out_rsc_req_obj_oswt_unreg & core_wen;
  assign plm_out_rsc_req_obj_biwt = plm_out_rsc_req_obj_iswt0 & (~ plm_out_rsc_req_obj_bcwt)
      & plm_out_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp
    (
  clk, rst, plm_in_rsc_req_obj_oswt_unreg, plm_in_rsc_req_obj_bawt, plm_in_rsc_req_obj_wen_comp,
      plm_in_rsc_req_obj_biwt, plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_in_rsc_req_obj_oswt_unreg;
  output plm_in_rsc_req_obj_bawt;
  output plm_in_rsc_req_obj_wen_comp;
  input plm_in_rsc_req_obj_biwt;
  input plm_in_rsc_req_obj_bdwt;
  output plm_in_rsc_req_obj_bcwt;
  reg plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_bawt = plm_in_rsc_req_obj_biwt | plm_in_rsc_req_obj_bcwt;
  assign plm_in_rsc_req_obj_wen_comp = (~ plm_in_rsc_req_obj_oswt_unreg) | plm_in_rsc_req_obj_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_in_rsc_req_obj_oswt_unreg, plm_in_rsc_req_obj_iswt0, plm_in_rsc_req_obj_vd,
      plm_in_rsc_req_obj_biwt, plm_in_rsc_req_obj_bdwt, plm_in_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_in_rsc_req_obj_oswt_unreg;
  input plm_in_rsc_req_obj_iswt0;
  input plm_in_rsc_req_obj_vd;
  output plm_in_rsc_req_obj_biwt;
  output plm_in_rsc_req_obj_bdwt;
  input plm_in_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_req_obj_bdwt = plm_in_rsc_req_obj_oswt_unreg & core_wen;
  assign plm_in_rsc_req_obj_biwt = plm_in_rsc_req_obj_iswt0 & (~ plm_in_rsc_req_obj_bcwt)
      & plm_in_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp
    (
  clk, rst, plm_in_rsc_rls_obj_bawt, plm_in_rsc_rls_obj_biwt, plm_in_rsc_rls_obj_bdwt
);
  input clk;
  input rst;
  output plm_in_rsc_rls_obj_bawt;
  input plm_in_rsc_rls_obj_biwt;
  input plm_in_rsc_rls_obj_bdwt;


  // Interconnect Declarations
  reg plm_in_rsc_rls_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_rls_obj_bawt = plm_in_rsc_rls_obj_biwt | plm_in_rsc_rls_obj_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsc_rls_obj_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsc_rls_obj_bcwt <= ~((~(plm_in_rsc_rls_obj_bcwt | plm_in_rsc_rls_obj_biwt))
          | plm_in_rsc_rls_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl
    (
  core_wen, core_wten, plm_in_rsc_rls_obj_oswt_unreg, plm_in_rsc_rls_obj_iswt0, plm_in_rsc_rls_obj_biwt,
      plm_in_rsc_rls_obj_bdwt
);
  input core_wen;
  input core_wten;
  input plm_in_rsc_rls_obj_oswt_unreg;
  input plm_in_rsc_rls_obj_iswt0;
  output plm_in_rsc_rls_obj_biwt;
  output plm_in_rsc_rls_obj_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsc_rls_obj_bdwt = plm_in_rsc_rls_obj_oswt_unreg & core_wen;
  assign plm_in_rsc_rls_obj_biwt = (~ core_wten) & plm_in_rsc_rls_obj_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp
    (
  clk, rst, plm_out_rsc_rls_obj_bawt, plm_out_rsc_rls_obj_biwt, plm_out_rsc_rls_obj_bdwt
);
  input clk;
  input rst;
  output plm_out_rsc_rls_obj_bawt;
  input plm_out_rsc_rls_obj_biwt;
  input plm_out_rsc_rls_obj_bdwt;


  // Interconnect Declarations
  reg plm_out_rsc_rls_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_rls_obj_bawt = plm_out_rsc_rls_obj_biwt | plm_out_rsc_rls_obj_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsc_rls_obj_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsc_rls_obj_bcwt <= ~((~(plm_out_rsc_rls_obj_bcwt | plm_out_rsc_rls_obj_biwt))
          | plm_out_rsc_rls_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
    (
  core_wen, core_wten, plm_out_rsc_rls_obj_oswt_unreg, plm_out_rsc_rls_obj_iswt0,
      plm_out_rsc_rls_obj_biwt, plm_out_rsc_rls_obj_bdwt
);
  input core_wen;
  input core_wten;
  input plm_out_rsc_rls_obj_oswt_unreg;
  input plm_out_rsc_rls_obj_iswt0;
  output plm_out_rsc_rls_obj_biwt;
  output plm_out_rsc_rls_obj_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_rls_obj_bdwt = plm_out_rsc_rls_obj_oswt_unreg & core_wen;
  assign plm_out_rsc_rls_obj_biwt = (~ core_wten) & plm_out_rsc_rls_obj_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_dp (
  clk, rst, plm_out_rsci_bawt, plm_out_rsci_biwt, plm_out_rsci_bdwt
);
  input clk;
  input rst;
  output plm_out_rsci_bawt;
  input plm_out_rsci_biwt;
  input plm_out_rsci_bdwt;


  // Interconnect Declarations
  reg plm_out_rsci_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bawt = plm_out_rsci_biwt | plm_out_rsci_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsci_bcwt <= ~((~(plm_out_rsci_bcwt | plm_out_rsci_biwt)) | plm_out_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl (
  core_wen, core_wten, plm_out_rsci_oswt_unreg, plm_out_rsci_iswt0, plm_out_rsci_biwt,
      plm_out_rsci_bdwt, plm_out_rsci_we_d_core_sct_pff, plm_out_rsci_iswt0_pff
);
  input core_wen;
  input core_wten;
  input plm_out_rsci_oswt_unreg;
  input plm_out_rsci_iswt0;
  output plm_out_rsci_biwt;
  output plm_out_rsci_bdwt;
  output plm_out_rsci_we_d_core_sct_pff;
  input plm_out_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsci_bdwt = plm_out_rsci_oswt_unreg & core_wen;
  assign plm_out_rsci_biwt = (~ core_wten) & plm_out_rsci_iswt0;
  assign plm_out_rsci_we_d_core_sct_pff = plm_out_rsci_iswt0_pff & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp (
  clk, rst, plm_in_rsci_q_d, plm_in_rsci_bawt, plm_in_rsci_q_d_mxwt, plm_in_rsci_biwt,
      plm_in_rsci_bdwt
);
  input clk;
  input rst;
  input [31:0] plm_in_rsci_q_d;
  output plm_in_rsci_bawt;
  output [31:0] plm_in_rsci_q_d_mxwt;
  input plm_in_rsci_biwt;
  input plm_in_rsci_bdwt;


  // Interconnect Declarations
  reg plm_in_rsci_bcwt;
  reg [31:0] plm_in_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bawt = plm_in_rsci_biwt | plm_in_rsci_bcwt;
  assign plm_in_rsci_q_d_mxwt = MUX_v_32_2_2(plm_in_rsci_q_d, plm_in_rsci_q_d_bfwt,
      plm_in_rsci_bcwt);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_in_rsci_bcwt <= ~((~(plm_in_rsci_bcwt | plm_in_rsci_biwt)) | plm_in_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsci_q_d_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( plm_in_rsci_biwt ) begin
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
  core_wen, core_wten, plm_in_rsci_oswt_unreg, plm_in_rsci_iswt0, plm_in_rsci_biwt,
      plm_in_rsci_bdwt, plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct, plm_in_rsci_iswt0_pff
);
  input core_wen;
  input core_wten;
  input plm_in_rsci_oswt_unreg;
  input plm_in_rsci_iswt0;
  output plm_in_rsci_biwt;
  output plm_in_rsci_bdwt;
  output plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  input plm_in_rsci_iswt0_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_rsci_bdwt = plm_in_rsci_oswt_unreg & core_wen;
  assign plm_in_rsci_biwt = (~ core_wten) & plm_in_rsci_iswt0;
  assign plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_in_rsci_iswt0_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
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
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
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
//  Design Unit:    esp_acc_softmax_cxx_compute_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_conf_info_rsci_conf_info_wait_ctrl (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_ivld_oreg,
      conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt, conf_info_rsci_irdy_core_sct
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  input conf_info_rsci_ivld_oreg;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld_oreg;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_wait_dp (
  clk, rst, conf_info_rsci_ivld, conf_info_rsci_ivld_oreg
);
  input clk;
  input rst;
  input conf_info_rsci_ivld;
  output conf_info_rsci_ivld_oreg;


  // Interconnect Declarations
  reg conf_info_rsci_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_ivld_oreg = ~ conf_info_rsci_ivld_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_rsci_ivld_oreg_rneg <= ~ conf_info_rsci_ivld;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_24_7_32_128_128_32_1_gen
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_24_7_32_128_128_32_1_gen
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
  clk, rst, core_wen, fsm_output
);
  input clk;
  input rst;
  input core_wen;
  output [1:0] fsm_output;
  reg [1:0] fsm_output;


  // FSM State Type Declaration for esp_acc_softmax_cxx_store_core_core_fsm_1
  parameter
    core_rlp_C_0 = 1'd0,
    main_C_0 = 1'd1;

  reg [0:0] state_var;
  reg [0:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_store_core_core_fsm_1
    case (state_var)
      main_C_0 : begin
        fsm_output = 2'b10;
        state_var_NS = main_C_0;
      end
      // core_rlp_C_0
      default : begin
        fsm_output = 2'b01;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_staller
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_staller (
  clk, rst, core_wen, core_wten, conf_info_rsci_wen_comp, dma_write_chnl_rsci_wen_comp,
      done_rsci_wen_comp, plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input conf_info_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;
  input done_rsci_wen_comp;
  input plm_out_rsc_req_obj_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = conf_info_rsci_wen_comp & dma_write_chnl_rsci_wen_comp & done_rsci_wen_comp
      & plm_out_rsc_req_obj_wen_comp;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp
    (
  clk, rst, plm_out_rsc_req_obj_oswt_unreg, plm_out_rsc_req_obj_bawt, plm_out_rsc_req_obj_wen_comp,
      plm_out_rsc_req_obj_biwt, plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input clk;
  input rst;
  input plm_out_rsc_req_obj_oswt_unreg;
  output plm_out_rsc_req_obj_bawt;
  output plm_out_rsc_req_obj_wen_comp;
  input plm_out_rsc_req_obj_biwt;
  input plm_out_rsc_req_obj_bdwt;
  output plm_out_rsc_req_obj_bcwt;
  reg plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_bawt = plm_out_rsc_req_obj_biwt | plm_out_rsc_req_obj_bcwt;
  assign plm_out_rsc_req_obj_wen_comp = (~ plm_out_rsc_req_obj_oswt_unreg) | plm_out_rsc_req_obj_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
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
  core_wen, plm_out_rsc_req_obj_oswt_unreg, plm_out_rsc_req_obj_iswt0, plm_out_rsc_req_obj_vd,
      plm_out_rsc_req_obj_biwt, plm_out_rsc_req_obj_bdwt, plm_out_rsc_req_obj_bcwt
);
  input core_wen;
  input plm_out_rsc_req_obj_oswt_unreg;
  input plm_out_rsc_req_obj_iswt0;
  input plm_out_rsc_req_obj_vd;
  output plm_out_rsc_req_obj_biwt;
  output plm_out_rsc_req_obj_bdwt;
  input plm_out_rsc_req_obj_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_req_obj_bdwt = plm_out_rsc_req_obj_oswt_unreg & core_wen;
  assign plm_out_rsc_req_obj_biwt = plm_out_rsc_req_obj_iswt0 & (~ plm_out_rsc_req_obj_bcwt)
      & plm_out_rsc_req_obj_vd;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp
    (
  clk, rst, plm_out_rsc_rls_obj_bawt, plm_out_rsc_rls_obj_biwt, plm_out_rsc_rls_obj_bdwt
);
  input clk;
  input rst;
  output plm_out_rsc_rls_obj_bawt;
  input plm_out_rsc_rls_obj_biwt;
  input plm_out_rsc_rls_obj_bdwt;


  // Interconnect Declarations
  reg plm_out_rsc_rls_obj_bcwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_rls_obj_bawt = plm_out_rsc_rls_obj_biwt | plm_out_rsc_rls_obj_bcwt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsc_rls_obj_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsc_rls_obj_bcwt <= ~((~(plm_out_rsc_rls_obj_bcwt | plm_out_rsc_rls_obj_biwt))
          | plm_out_rsc_rls_obj_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
    (
  core_wen, core_wten, plm_out_rsc_rls_obj_oswt_unreg, plm_out_rsc_rls_obj_iswt0,
      plm_out_rsc_rls_obj_biwt, plm_out_rsc_rls_obj_bdwt
);
  input core_wen;
  input core_wten;
  input plm_out_rsc_rls_obj_oswt_unreg;
  input plm_out_rsc_rls_obj_iswt0;
  output plm_out_rsc_rls_obj_biwt;
  output plm_out_rsc_rls_obj_bdwt;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_rsc_rls_obj_bdwt = plm_out_rsc_rls_obj_oswt_unreg & core_wen;
  assign plm_out_rsc_rls_obj_biwt = (~ core_wten) & plm_out_rsc_rls_obj_iswt0;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_done_rsci_done_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_done_rsci_done_wait_dp (
  clk, rst, done_rsci_oswt_unreg, done_rsci_bawt, done_rsci_wen_comp, done_rsci_biwt,
      done_rsci_bdwt, done_rsci_bcwt
);
  input clk;
  input rst;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  output done_rsci_wen_comp;
  input done_rsci_biwt;
  input done_rsci_bdwt;
  output done_rsci_bcwt;
  reg done_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bawt = done_rsci_biwt | done_rsci_bcwt;
  assign done_rsci_wen_comp = (~ done_rsci_oswt_unreg) | done_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      done_rsci_bcwt <= 1'b0;
    end
    else begin
      done_rsci_bcwt <= ~((~(done_rsci_bcwt | done_rsci_biwt)) | done_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_done_rsci_done_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_done_rsci_done_wait_ctrl (
  core_wen, done_rsci_oswt_unreg, done_rsci_iswt0, done_rsci_biwt, done_rsci_bdwt,
      done_rsci_bcwt, done_rsci_ivld_core_sct, done_rsci_irdy
);
  input core_wen;
  input done_rsci_oswt_unreg;
  input done_rsci_iswt0;
  output done_rsci_biwt;
  output done_rsci_bdwt;
  input done_rsci_bcwt;
  output done_rsci_ivld_core_sct;
  input done_rsci_irdy;


  // Interconnect Declarations
  wire done_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign done_rsci_bdwt = done_rsci_oswt_unreg & core_wen;
  assign done_rsci_biwt = done_rsci_ogwt & done_rsci_irdy;
  assign done_rsci_ogwt = done_rsci_iswt0 & (~ done_rsci_bcwt);
  assign done_rsci_ivld_core_sct = done_rsci_ogwt;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
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
    if ( ~ rst ) begin
      plm_out_rsci_bcwt <= 1'b0;
    end
    else begin
      plm_out_rsci_bcwt <= ~((~(plm_out_rsci_bcwt | plm_out_rsci_biwt)) | plm_out_rsci_bdwt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsci_q_d_bfwt <= 32'b00000000000000000000000000000000;
    end
    else if ( plm_out_rsci_biwt ) begin
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_conf_info_rsci_conf_info_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_conf_info_rsci_conf_info_wait_dp (
  clk, rst, conf_info_rsci_oswt_unreg, conf_info_rsci_bawt, conf_info_rsci_wen_comp,
      conf_info_rsci_idat_mxwt, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_idat
);
  input clk;
  input rst;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
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
  assign conf_info_rsci_bawt = conf_info_rsci_biwt | conf_info_rsci_bcwt;
  assign conf_info_rsci_wen_comp = (~ conf_info_rsci_oswt_unreg) | conf_info_rsci_bawt;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_conf_info_rsci_conf_info_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_conf_info_rsci_conf_info_wait_ctrl (
  core_wen, conf_info_rsci_oswt_unreg, conf_info_rsci_iswt0, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld_oreg, conf_info_rsci_biwt, conf_info_rsci_bdwt, conf_info_rsci_bcwt,
      conf_info_rsci_irdy_core_sct
);
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  input conf_info_rsci_iswt0;
  input conf_info_rsci_irdy_core_psct;
  input conf_info_rsci_ivld_oreg;
  output conf_info_rsci_biwt;
  output conf_info_rsci_bdwt;
  input conf_info_rsci_bcwt;
  output conf_info_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire conf_info_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_bdwt = conf_info_rsci_oswt_unreg & core_wen;
  assign conf_info_rsci_biwt = conf_info_rsci_ogwt & conf_info_rsci_ivld_oreg;
  assign conf_info_rsci_ogwt = conf_info_rsci_iswt0 & (~ conf_info_rsci_bcwt);
  assign conf_info_rsci_irdy_core_sct = conf_info_rsci_irdy_core_psct & conf_info_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_wait_dp (
  clk, rst, conf_info_rsci_ivld, conf_info_rsci_ivld_oreg
);
  input clk;
  input rst;
  input conf_info_rsci_ivld;
  output conf_info_rsci_ivld_oreg;


  // Interconnect Declarations
  reg conf_info_rsci_ivld_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign conf_info_rsci_ivld_oreg = ~ conf_info_rsci_ivld_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_ivld_oreg_rneg <= 1'b0;
    end
    else begin
      conf_info_rsci_ivld_oreg_rneg <= ~ conf_info_rsci_ivld;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi (
  clk, rst, store_done_cns_rdy, store_done_cns_vld, core_wen, store_done_cnsi_oswt_unreg,
      store_done_cnsi_bawt, store_done_cnsi_iswt0, store_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output store_done_cns_rdy;
  input store_done_cns_vld;
  input core_wen;
  input store_done_cnsi_oswt_unreg;
  output store_done_cnsi_bawt;
  input store_done_cnsi_iswt0;
  output store_done_cnsi_wen_comp;


  // Interconnect Declarations
  wire store_done_cnsi_ivld;
  wire store_done_cnsi_biwt;
  wire store_done_cnsi_bdwt;
  wire store_done_cnsi_bcwt;
  wire store_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_in_wait_v1 #(.rscid(32'sd48)) store_done_cnsi (
      .vld(store_done_cns_vld),
      .rdy(store_done_cns_rdy),
      .ivld(store_done_cnsi_ivld),
      .irdy(store_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi_store_done_wait_ctrl
      softmax_cxx_core_core_store_done_cnsi_store_done_wait_ctrl_inst (
      .core_wen(core_wen),
      .store_done_cnsi_oswt_unreg(store_done_cnsi_oswt_unreg),
      .store_done_cnsi_iswt0(store_done_cnsi_iswt0),
      .store_done_cnsi_ivld(store_done_cnsi_ivld),
      .store_done_cnsi_biwt(store_done_cnsi_biwt),
      .store_done_cnsi_bdwt(store_done_cnsi_bdwt),
      .store_done_cnsi_bcwt(store_done_cnsi_bcwt),
      .store_done_cnsi_irdy_core_sct(store_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi_store_done_wait_dp softmax_cxx_core_core_store_done_cnsi_store_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .store_done_cnsi_oswt_unreg(store_done_cnsi_oswt_unreg),
      .store_done_cnsi_bawt(store_done_cnsi_bawt),
      .store_done_cnsi_wen_comp(store_done_cnsi_wen_comp),
      .store_done_cnsi_biwt(store_done_cnsi_biwt),
      .store_done_cnsi_bdwt(store_done_cnsi_bdwt),
      .store_done_cnsi_bcwt(store_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi (
  clk, rst, compute_done_cns_rdy, compute_done_cns_vld, core_wen, compute_done_cnsi_oswt_unreg,
      compute_done_cnsi_bawt, compute_done_cnsi_iswt0, compute_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output compute_done_cns_rdy;
  input compute_done_cns_vld;
  input core_wen;
  input compute_done_cnsi_oswt_unreg;
  output compute_done_cnsi_bawt;
  input compute_done_cnsi_iswt0;
  output compute_done_cnsi_wen_comp;


  // Interconnect Declarations
  wire compute_done_cnsi_ivld;
  wire compute_done_cnsi_biwt;
  wire compute_done_cnsi_bdwt;
  wire compute_done_cnsi_bcwt;
  wire compute_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_in_wait_v1 #(.rscid(32'sd47)) compute_done_cnsi (
      .vld(compute_done_cns_vld),
      .rdy(compute_done_cns_rdy),
      .ivld(compute_done_cnsi_ivld),
      .irdy(compute_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_ctrl
      softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_ctrl_inst (
      .core_wen(core_wen),
      .compute_done_cnsi_oswt_unreg(compute_done_cnsi_oswt_unreg),
      .compute_done_cnsi_iswt0(compute_done_cnsi_iswt0),
      .compute_done_cnsi_ivld(compute_done_cnsi_ivld),
      .compute_done_cnsi_biwt(compute_done_cnsi_biwt),
      .compute_done_cnsi_bdwt(compute_done_cnsi_bdwt),
      .compute_done_cnsi_bcwt(compute_done_cnsi_bcwt),
      .compute_done_cnsi_irdy_core_sct(compute_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_dp
      softmax_cxx_core_core_compute_done_cnsi_compute_done_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .compute_done_cnsi_oswt_unreg(compute_done_cnsi_oswt_unreg),
      .compute_done_cnsi_bawt(compute_done_cnsi_bawt),
      .compute_done_cnsi_wen_comp(compute_done_cnsi_wen_comp),
      .compute_done_cnsi_biwt(compute_done_cnsi_biwt),
      .compute_done_cnsi_bdwt(compute_done_cnsi_bdwt),
      .compute_done_cnsi_bcwt(compute_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi (
  clk, rst, load_done_cns_rdy, load_done_cns_vld, core_wen, load_done_cnsi_oswt_unreg,
      load_done_cnsi_bawt, load_done_cnsi_iswt0, load_done_cnsi_wen_comp, load_done_cnsi_irdy_core_psct
);
  input clk;
  input rst;
  output load_done_cns_rdy;
  input load_done_cns_vld;
  input core_wen;
  input load_done_cnsi_oswt_unreg;
  output load_done_cnsi_bawt;
  input load_done_cnsi_iswt0;
  output load_done_cnsi_wen_comp;
  input load_done_cnsi_irdy_core_psct;


  // Interconnect Declarations
  wire load_done_cnsi_ivld;
  wire load_done_cnsi_biwt;
  wire load_done_cnsi_bdwt;
  wire load_done_cnsi_bcwt;
  wire load_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_in_wait_v1 #(.rscid(32'sd46)) load_done_cnsi (
      .vld(load_done_cns_vld),
      .rdy(load_done_cns_rdy),
      .ivld(load_done_cnsi_ivld),
      .irdy(load_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi_load_done_wait_ctrl softmax_cxx_core_core_load_done_cnsi_load_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .load_done_cnsi_oswt_unreg(load_done_cnsi_oswt_unreg),
      .load_done_cnsi_iswt0(load_done_cnsi_iswt0),
      .load_done_cnsi_irdy_core_psct(load_done_cnsi_irdy_core_psct),
      .load_done_cnsi_ivld(load_done_cnsi_ivld),
      .load_done_cnsi_biwt(load_done_cnsi_biwt),
      .load_done_cnsi_bdwt(load_done_cnsi_bdwt),
      .load_done_cnsi_bcwt(load_done_cnsi_bcwt),
      .load_done_cnsi_irdy_core_sct(load_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi_load_done_wait_dp softmax_cxx_core_core_load_done_cnsi_load_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .load_done_cnsi_oswt_unreg(load_done_cnsi_oswt_unreg),
      .load_done_cnsi_bawt(load_done_cnsi_bawt),
      .load_done_cnsi_wen_comp(load_done_cnsi_wen_comp),
      .load_done_cnsi_biwt(load_done_cnsi_biwt),
      .load_done_cnsi_bdwt(load_done_cnsi_bdwt),
      .load_done_cnsi_bcwt(load_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi (
  clk, rst, config_done_cns_rdy, config_done_cns_vld, core_wen, config_done_cnsi_oswt_unreg,
      config_done_cnsi_bawt, config_done_cnsi_iswt0, config_done_cnsi_wen_comp
);
  input clk;
  input rst;
  output config_done_cns_rdy;
  input config_done_cns_vld;
  input core_wen;
  input config_done_cnsi_oswt_unreg;
  output config_done_cnsi_bawt;
  input config_done_cnsi_iswt0;
  output config_done_cnsi_wen_comp;


  // Interconnect Declarations
  wire config_done_cnsi_ivld;
  wire config_done_cnsi_biwt;
  wire config_done_cnsi_bdwt;
  wire config_done_cnsi_bcwt;
  wire config_done_cnsi_irdy_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_in_wait_v1 #(.rscid(32'sd45)) config_done_cnsi (
      .vld(config_done_cns_vld),
      .rdy(config_done_cns_rdy),
      .ivld(config_done_cnsi_ivld),
      .irdy(config_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi_config_done_wait_ctrl
      softmax_cxx_core_core_config_done_cnsi_config_done_wait_ctrl_inst (
      .core_wen(core_wen),
      .config_done_cnsi_oswt_unreg(config_done_cnsi_oswt_unreg),
      .config_done_cnsi_iswt0(config_done_cnsi_iswt0),
      .config_done_cnsi_ivld(config_done_cnsi_ivld),
      .config_done_cnsi_biwt(config_done_cnsi_biwt),
      .config_done_cnsi_bdwt(config_done_cnsi_bdwt),
      .config_done_cnsi_bcwt(config_done_cnsi_bcwt),
      .config_done_cnsi_irdy_core_sct(config_done_cnsi_irdy_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi_config_done_wait_dp
      softmax_cxx_core_core_config_done_cnsi_config_done_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .config_done_cnsi_oswt_unreg(config_done_cnsi_oswt_unreg),
      .config_done_cnsi_bawt(config_done_cnsi_bawt),
      .config_done_cnsi_wen_comp(config_done_cnsi_wen_comp),
      .config_done_cnsi_biwt(config_done_cnsi_biwt),
      .config_done_cnsi_bdwt(config_done_cnsi_bdwt),
      .config_done_cnsi_bcwt(config_done_cnsi_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci (
  clk, rst, acc_done_rsc_vld, core_wen, acc_done_rsci_oswt_unreg, acc_done_rsci_bawt,
      acc_done_rsci_iswt0, core_wten
);
  input clk;
  input rst;
  output acc_done_rsc_vld;
  input core_wen;
  input acc_done_rsci_oswt_unreg;
  output acc_done_rsci_bawt;
  input acc_done_rsci_iswt0;
  input core_wten;


  // Interconnect Declarations
  wire acc_done_rsci_biwt;
  wire acc_done_rsci_bdwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_vld_v1 #(.rscid(32'sd44)) acc_done_rsci (
      .vld(acc_done_rsc_vld),
      .ivld(acc_done_rsci_biwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci_acc_done_wait_ctrl softmax_cxx_core_core_acc_done_rsci_acc_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .acc_done_rsci_oswt_unreg(acc_done_rsci_oswt_unreg),
      .acc_done_rsci_iswt0(acc_done_rsci_iswt0),
      .core_wten(core_wten),
      .acc_done_rsci_biwt(acc_done_rsci_biwt),
      .acc_done_rsci_bdwt(acc_done_rsci_bdwt)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci_acc_done_wait_dp softmax_cxx_core_core_acc_done_rsci_acc_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .acc_done_rsci_bawt(acc_done_rsci_bawt),
      .acc_done_rsci_biwt(acc_done_rsci_biwt),
      .acc_done_rsci_bdwt(acc_done_rsci_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_wait_v1 #(.rscid(32'sd5)) done_rsci (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_config_core_done_rsci_done_wait_ctrl config_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_config_core_done_rsci_done_wait_dp config_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_plm_conf_store_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_plm_conf_store_rsci (
  clk, rst, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      core_wen, plm_conf_store_rsci_irdy, plm_conf_store_rsci_oswt_unreg, plm_conf_store_rsci_bawt,
      plm_conf_store_rsci_iswt0, plm_conf_store_rsci_wen_comp, plm_conf_store_rsci_irdy_oreg,
      plm_conf_store_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input core_wen;
  output plm_conf_store_rsci_irdy;
  input plm_conf_store_rsci_oswt_unreg;
  output plm_conf_store_rsci_bawt;
  input plm_conf_store_rsci_iswt0;
  output plm_conf_store_rsci_wen_comp;
  input plm_conf_store_rsci_irdy_oreg;
  input [31:0] plm_conf_store_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_store_rsci_biwt;
  wire plm_conf_store_rsci_bdwt;
  wire plm_conf_store_rsci_bcwt;
  wire plm_conf_store_rsci_ivld_core_sct;
  wire plm_conf_store_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_buf_wait_v4 #(.rscid(32'sd4),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_store_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_conf_store_rsci_irdy),
      .ivld(plm_conf_store_rsci_ivld_core_sct),
      .idat(plm_conf_store_rsci_idat),
      .rdy(plm_conf_store_rsc_rdy),
      .vld(plm_conf_store_rsc_vld),
      .dat(plm_conf_store_rsc_dat),
      .is_idle(plm_conf_store_rsc_is_idle)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl config_core_plm_conf_store_rsci_plm_conf_store_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_store_rsci_oswt_unreg(plm_conf_store_rsci_oswt_unreg),
      .plm_conf_store_rsci_iswt0(plm_conf_store_rsci_iswt0),
      .plm_conf_store_rsci_irdy_oreg(plm_conf_store_rsci_irdy_oreg),
      .plm_conf_store_rsci_biwt(plm_conf_store_rsci_biwt),
      .plm_conf_store_rsci_bdwt(plm_conf_store_rsci_bdwt),
      .plm_conf_store_rsci_bcwt(plm_conf_store_rsci_bcwt),
      .plm_conf_store_rsci_ivld_core_sct(plm_conf_store_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_store_rsci_plm_conf_store_wait_dp config_core_plm_conf_store_rsci_plm_conf_store_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_store_rsci_oswt_unreg(plm_conf_store_rsci_oswt_unreg),
      .plm_conf_store_rsci_bawt(plm_conf_store_rsci_bawt),
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
      core_wen, plm_conf_compute_rsci_irdy, plm_conf_compute_rsci_oswt_unreg, plm_conf_compute_rsci_bawt,
      plm_conf_compute_rsci_iswt0, plm_conf_compute_rsci_wen_comp, plm_conf_compute_rsci_irdy_oreg,
      plm_conf_compute_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  input core_wen;
  output plm_conf_compute_rsci_irdy;
  input plm_conf_compute_rsci_oswt_unreg;
  output plm_conf_compute_rsci_bawt;
  input plm_conf_compute_rsci_iswt0;
  output plm_conf_compute_rsci_wen_comp;
  input plm_conf_compute_rsci_irdy_oreg;
  input [31:0] plm_conf_compute_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_compute_rsci_biwt;
  wire plm_conf_compute_rsci_bdwt;
  wire plm_conf_compute_rsci_bcwt;
  wire plm_conf_compute_rsci_ivld_core_sct;
  wire plm_conf_compute_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_buf_wait_v4 #(.rscid(32'sd3),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_compute_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_conf_compute_rsci_irdy),
      .ivld(plm_conf_compute_rsci_ivld_core_sct),
      .idat(plm_conf_compute_rsci_idat),
      .rdy(plm_conf_compute_rsc_rdy),
      .vld(plm_conf_compute_rsc_vld),
      .dat(plm_conf_compute_rsc_dat),
      .is_idle(plm_conf_compute_rsc_is_idle)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl
      config_core_plm_conf_compute_rsci_plm_conf_compute_wait_ctrl_inst (
      .core_wen(core_wen),
      .plm_conf_compute_rsci_oswt_unreg(plm_conf_compute_rsci_oswt_unreg),
      .plm_conf_compute_rsci_iswt0(plm_conf_compute_rsci_iswt0),
      .plm_conf_compute_rsci_irdy_oreg(plm_conf_compute_rsci_irdy_oreg),
      .plm_conf_compute_rsci_biwt(plm_conf_compute_rsci_biwt),
      .plm_conf_compute_rsci_bdwt(plm_conf_compute_rsci_bdwt),
      .plm_conf_compute_rsci_bcwt(plm_conf_compute_rsci_bcwt),
      .plm_conf_compute_rsci_ivld_core_sct(plm_conf_compute_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp
      config_core_plm_conf_compute_rsci_plm_conf_compute_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_compute_rsci_oswt_unreg(plm_conf_compute_rsci_oswt_unreg),
      .plm_conf_compute_rsci_bawt(plm_conf_compute_rsci_bawt),
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
      core_wen, plm_conf_load_rsci_irdy, plm_conf_load_rsci_oswt_unreg, plm_conf_load_rsci_bawt,
      plm_conf_load_rsci_iswt0, plm_conf_load_rsci_wen_comp, plm_conf_load_rsci_irdy_oreg,
      plm_conf_load_rsci_idat
);
  input clk;
  input rst;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  input core_wen;
  output plm_conf_load_rsci_irdy;
  input plm_conf_load_rsci_oswt_unreg;
  output plm_conf_load_rsci_bawt;
  input plm_conf_load_rsci_iswt0;
  output plm_conf_load_rsci_wen_comp;
  input plm_conf_load_rsci_irdy_oreg;
  input [31:0] plm_conf_load_rsci_idat;


  // Interconnect Declarations
  wire plm_conf_load_rsci_biwt;
  wire plm_conf_load_rsci_bdwt;
  wire plm_conf_load_rsci_bcwt;
  wire plm_conf_load_rsci_ivld_core_sct;
  wire plm_conf_load_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_out_buf_wait_v4 #(.rscid(32'sd2),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_load_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(plm_conf_load_rsci_irdy),
      .ivld(plm_conf_load_rsci_ivld_core_sct),
      .idat(plm_conf_load_rsci_idat),
      .rdy(plm_conf_load_rsc_rdy),
      .vld(plm_conf_load_rsc_vld),
      .dat(plm_conf_load_rsc_dat),
      .is_idle(plm_conf_load_rsc_is_idle)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl config_core_plm_conf_load_rsci_plm_conf_load_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .plm_conf_load_rsci_oswt_unreg(plm_conf_load_rsci_oswt_unreg),
      .plm_conf_load_rsci_iswt0(plm_conf_load_rsci_iswt0),
      .plm_conf_load_rsci_irdy_oreg(plm_conf_load_rsci_irdy_oreg),
      .plm_conf_load_rsci_biwt(plm_conf_load_rsci_biwt),
      .plm_conf_load_rsci_bdwt(plm_conf_load_rsci_bdwt),
      .plm_conf_load_rsci_bcwt(plm_conf_load_rsci_bcwt),
      .plm_conf_load_rsci_ivld_core_sct(plm_conf_load_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_load_rsci_plm_conf_load_wait_dp config_core_plm_conf_load_rsci_plm_conf_load_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsci_oswt_unreg(plm_conf_load_rsci_oswt_unreg),
      .plm_conf_load_rsci_bawt(plm_conf_load_rsci_bawt),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_load_rsci_biwt(plm_conf_load_rsci_biwt),
      .plm_conf_load_rsci_bdwt(plm_conf_load_rsci_bdwt),
      .plm_conf_load_rsci_bcwt(plm_conf_load_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
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
  esp_acc_softmax_cxx_config_core_conf_info_rsci_conf_info_wait_ctrl config_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld)
    );
  esp_acc_softmax_cxx_config_core_conf_info_rsci_conf_info_wait_dp config_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj (
  clk, rst, plm_in_rsc_req_vz, core_wen, plm_in_rsc_req_obj_oswt_unreg, plm_in_rsc_req_obj_bawt,
      plm_in_rsc_req_obj_iswt0, plm_in_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_in_rsc_req_vz;
  input core_wen;
  input plm_in_rsc_req_obj_oswt_unreg;
  output plm_in_rsc_req_obj_bawt;
  input plm_in_rsc_req_obj_iswt0;
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
      .plm_in_rsc_req_obj_oswt_unreg(plm_in_rsc_req_obj_oswt_unreg),
      .plm_in_rsc_req_obj_iswt0(plm_in_rsc_req_obj_iswt0),
      .plm_in_rsc_req_obj_vd(plm_in_rsc_req_obj_vd),
      .plm_in_rsc_req_obj_biwt(plm_in_rsc_req_obj_biwt),
      .plm_in_rsc_req_obj_bdwt(plm_in_rsc_req_obj_bdwt),
      .plm_in_rsc_req_obj_bcwt(plm_in_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp load_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_obj_oswt_unreg(plm_in_rsc_req_obj_oswt_unreg),
      .plm_in_rsc_req_obj_bawt(plm_in_rsc_req_obj_bawt),
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
  clk, rst, plm_in_rsc_rls_lz, core_wen, core_wten, plm_in_rsc_rls_obj_oswt_unreg,
      plm_in_rsc_rls_obj_bawt, plm_in_rsc_rls_obj_iswt0
);
  input clk;
  input rst;
  output plm_in_rsc_rls_lz;
  input core_wen;
  input core_wten;
  input plm_in_rsc_rls_obj_oswt_unreg;
  output plm_in_rsc_rls_obj_bawt;
  input plm_in_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_in_rsc_rls_obj_biwt;
  wire plm_in_rsc_rls_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_in_rsc_rls_obj (
      .ld(plm_in_rsc_rls_obj_biwt),
      .lz(plm_in_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_oswt_unreg(plm_in_rsc_rls_obj_oswt_unreg),
      .plm_in_rsc_rls_obj_iswt0(plm_in_rsc_rls_obj_iswt0),
      .plm_in_rsc_rls_obj_biwt(plm_in_rsc_rls_obj_biwt),
      .plm_in_rsc_rls_obj_bdwt(plm_in_rsc_rls_obj_bdwt)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp load_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_rls_obj_bawt(plm_in_rsc_rls_obj_bawt),
      .plm_in_rsc_rls_obj_biwt(plm_in_rsc_rls_obj_biwt),
      .plm_in_rsc_rls_obj_bdwt(plm_in_rsc_rls_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_wait_v1 #(.rscid(32'sd10)) done_rsci (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_load_core_done_rsci_done_wait_ctrl load_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_load_core_done_rsci_done_wait_dp load_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_dma_read_chnl_rsci (
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
  esp_acc_softmax_cxx_ccs_in_wait_v1 #(.rscid(32'sd9),
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd8),
  .width(32'sd67)) dma_read_ctrl_rsci (
      .irdy(dma_read_ctrl_rsci_irdy),
      .ivld(dma_read_ctrl_rsci_biwt),
      .idat(nl_dma_read_ctrl_rsci_idat[66:0]),
      .rdy(dma_read_ctrl_rsc_rdy),
      .vld(dma_read_ctrl_rsc_vld),
      .dat(dma_read_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp load_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp_inst
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
//  Design Unit:    esp_acc_softmax_cxx_load_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  input conf_info_rsci_irdy_core_psct;
  output conf_info_rsci_ivld;
  input conf_info_rsci_ivld_oreg;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire [31:0] conf_info_rsci_idat;
  wire conf_info_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd6),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat),
      .is_idle(conf_info_rsc_is_idle)
    );
  esp_acc_softmax_cxx_load_core_conf_info_rsci_conf_info_wait_ctrl load_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_load_core_conf_info_rsci_conf_info_wait_dp load_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj (
  clk, rst, plm_out_rsc_req_vz, core_wen, plm_out_rsc_req_obj_oswt_unreg, plm_out_rsc_req_obj_bawt,
      plm_out_rsc_req_obj_iswt0, plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_out_rsc_req_vz;
  input core_wen;
  input plm_out_rsc_req_obj_oswt_unreg;
  output plm_out_rsc_req_obj_bawt;
  input plm_out_rsc_req_obj_iswt0;
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
      .plm_out_rsc_req_obj_oswt_unreg(plm_out_rsc_req_obj_oswt_unreg),
      .plm_out_rsc_req_obj_iswt0(plm_out_rsc_req_obj_iswt0),
      .plm_out_rsc_req_obj_vd(plm_out_rsc_req_obj_vd),
      .plm_out_rsc_req_obj_biwt(plm_out_rsc_req_obj_biwt),
      .plm_out_rsc_req_obj_bdwt(plm_out_rsc_req_obj_bdwt),
      .plm_out_rsc_req_obj_bcwt(plm_out_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp compute_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_obj_oswt_unreg(plm_out_rsc_req_obj_oswt_unreg),
      .plm_out_rsc_req_obj_bawt(plm_out_rsc_req_obj_bawt),
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
  clk, rst, plm_in_rsc_req_vz, core_wen, plm_in_rsc_req_obj_oswt_unreg, plm_in_rsc_req_obj_bawt,
      plm_in_rsc_req_obj_iswt0, plm_in_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_in_rsc_req_vz;
  input core_wen;
  input plm_in_rsc_req_obj_oswt_unreg;
  output plm_in_rsc_req_obj_bawt;
  input plm_in_rsc_req_obj_iswt0;
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
      .plm_in_rsc_req_obj_oswt_unreg(plm_in_rsc_req_obj_oswt_unreg),
      .plm_in_rsc_req_obj_iswt0(plm_in_rsc_req_obj_iswt0),
      .plm_in_rsc_req_obj_vd(plm_in_rsc_req_obj_vd),
      .plm_in_rsc_req_obj_biwt(plm_in_rsc_req_obj_biwt),
      .plm_in_rsc_req_obj_bdwt(plm_in_rsc_req_obj_bdwt),
      .plm_in_rsc_req_obj_bcwt(plm_in_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp compute_core_plm_in_rsc_req_obj_plm_in_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_obj_oswt_unreg(plm_in_rsc_req_obj_oswt_unreg),
      .plm_in_rsc_req_obj_bawt(plm_in_rsc_req_obj_bawt),
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
  clk, rst, plm_in_rsc_rls_lz, core_wen, core_wten, plm_in_rsc_rls_obj_oswt_unreg,
      plm_in_rsc_rls_obj_bawt, plm_in_rsc_rls_obj_iswt0
);
  input clk;
  input rst;
  output plm_in_rsc_rls_lz;
  input core_wen;
  input core_wten;
  input plm_in_rsc_rls_obj_oswt_unreg;
  output plm_in_rsc_rls_obj_bawt;
  input plm_in_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_in_rsc_rls_obj_biwt;
  wire plm_in_rsc_rls_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_in_rsc_rls_obj (
      .ld(plm_in_rsc_rls_obj_biwt),
      .lz(plm_in_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_oswt_unreg(plm_in_rsc_rls_obj_oswt_unreg),
      .plm_in_rsc_rls_obj_iswt0(plm_in_rsc_rls_obj_iswt0),
      .plm_in_rsc_rls_obj_biwt(plm_in_rsc_rls_obj_biwt),
      .plm_in_rsc_rls_obj_bdwt(plm_in_rsc_rls_obj_bdwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp compute_core_plm_in_rsc_rls_obj_plm_in_rsc_rls_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_rls_obj_bawt(plm_in_rsc_rls_obj_bawt),
      .plm_in_rsc_rls_obj_biwt(plm_in_rsc_rls_obj_biwt),
      .plm_in_rsc_rls_obj_bdwt(plm_in_rsc_rls_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj (
  clk, rst, plm_out_rsc_rls_lz, core_wen, core_wten, plm_out_rsc_rls_obj_oswt_unreg,
      plm_out_rsc_rls_obj_bawt, plm_out_rsc_rls_obj_iswt0
);
  input clk;
  input rst;
  output plm_out_rsc_rls_lz;
  input core_wen;
  input core_wten;
  input plm_out_rsc_rls_obj_oswt_unreg;
  output plm_out_rsc_rls_obj_bawt;
  input plm_out_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_out_rsc_rls_obj_biwt;
  wire plm_out_rsc_rls_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_out_rsc_rls_obj (
      .ld(plm_out_rsc_rls_obj_biwt),
      .lz(plm_out_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl
      compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_oswt_unreg(plm_out_rsc_rls_obj_oswt_unreg),
      .plm_out_rsc_rls_obj_iswt0(plm_out_rsc_rls_obj_iswt0),
      .plm_out_rsc_rls_obj_biwt(plm_out_rsc_rls_obj_biwt),
      .plm_out_rsc_rls_obj_bdwt(plm_out_rsc_rls_obj_bdwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp compute_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_rls_obj_bawt(plm_out_rsc_rls_obj_bawt),
      .plm_out_rsc_rls_obj_biwt(plm_out_rsc_rls_obj_biwt),
      .plm_out_rsc_rls_obj_bdwt(plm_out_rsc_rls_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_wait_v1 #(.rscid(32'sd15)) done_rsci (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_compute_core_done_rsci_done_wait_ctrl compute_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_compute_core_done_rsci_done_wait_dp compute_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_out_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_out_rsci_1 (
  clk, rst, core_wen, core_wten, plm_out_rsci_oswt_unreg, plm_out_rsci_bawt, plm_out_rsci_iswt0,
      plm_out_rsci_we_d_pff, plm_out_rsci_iswt0_pff
);
  input clk;
  input rst;
  input core_wen;
  input core_wten;
  input plm_out_rsci_oswt_unreg;
  output plm_out_rsci_bawt;
  input plm_out_rsci_iswt0;
  output plm_out_rsci_we_d_pff;
  input plm_out_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_out_rsci_biwt;
  wire plm_out_rsci_bdwt;
  wire plm_out_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl compute_core_plm_out_rsci_1_plm_out_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsci_oswt_unreg(plm_out_rsci_oswt_unreg),
      .plm_out_rsci_iswt0(plm_out_rsci_iswt0),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt),
      .plm_out_rsci_we_d_core_sct_pff(plm_out_rsci_we_d_core_sct_iff),
      .plm_out_rsci_iswt0_pff(plm_out_rsci_iswt0_pff)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsci_1_plm_out_rsc_wait_dp compute_core_plm_out_rsci_1_plm_out_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_biwt(plm_out_rsci_biwt),
      .plm_out_rsci_bdwt(plm_out_rsci_bdwt)
    );
  assign plm_out_rsci_we_d_pff = plm_out_rsci_we_d_core_sct_iff;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_plm_in_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_plm_in_rsci_1 (
  clk, rst, plm_in_rsci_q_d, plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d, core_wen,
      core_wten, plm_in_rsci_oswt_unreg, plm_in_rsci_bawt, plm_in_rsci_iswt0, plm_in_rsci_q_d_mxwt,
      plm_in_rsci_iswt0_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_rsci_q_d;
  output plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_in_rsci_oswt_unreg;
  output plm_in_rsci_bawt;
  input plm_in_rsci_iswt0;
  output [31:0] plm_in_rsci_q_d_mxwt;
  input plm_in_rsci_iswt0_pff;


  // Interconnect Declarations
  wire plm_in_rsci_biwt;
  wire plm_in_rsci_bdwt;
  wire plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl compute_core_plm_in_rsci_1_plm_in_rsc_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt_unreg(plm_in_rsci_oswt_unreg),
      .plm_in_rsci_iswt0(plm_in_rsci_iswt0),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt),
      .plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .plm_in_rsci_iswt0_pff(plm_in_rsci_iswt0_pff)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp compute_core_plm_in_rsci_1_plm_in_rsc_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_q_d(plm_in_rsci_q_d),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_q_d_mxwt(plm_in_rsci_q_d_mxwt),
      .plm_in_rsci_biwt(plm_in_rsci_biwt),
      .plm_in_rsci_bdwt(plm_in_rsci_bdwt)
    );
  assign plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_ivld,
      conf_info_rsci_ivld_oreg, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  output conf_info_rsci_ivld;
  input conf_info_rsci_ivld_oreg;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire [31:0] conf_info_rsci_idat;
  wire conf_info_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd12),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat),
      .is_idle(conf_info_rsc_is_idle)
    );
  esp_acc_softmax_cxx_compute_core_conf_info_rsci_conf_info_wait_ctrl compute_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_compute_core_conf_info_rsci_conf_info_wait_dp compute_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj (
  clk, rst, plm_out_rsc_req_vz, core_wen, plm_out_rsc_req_obj_oswt_unreg, plm_out_rsc_req_obj_bawt,
      plm_out_rsc_req_obj_iswt0, plm_out_rsc_req_obj_wen_comp
);
  input clk;
  input rst;
  input plm_out_rsc_req_vz;
  input core_wen;
  input plm_out_rsc_req_obj_oswt_unreg;
  output plm_out_rsc_req_obj_bawt;
  input plm_out_rsc_req_obj_iswt0;
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
      .plm_out_rsc_req_obj_oswt_unreg(plm_out_rsc_req_obj_oswt_unreg),
      .plm_out_rsc_req_obj_iswt0(plm_out_rsc_req_obj_iswt0),
      .plm_out_rsc_req_obj_vd(plm_out_rsc_req_obj_vd),
      .plm_out_rsc_req_obj_biwt(plm_out_rsc_req_obj_biwt),
      .plm_out_rsc_req_obj_bdwt(plm_out_rsc_req_obj_bdwt),
      .plm_out_rsc_req_obj_bcwt(plm_out_rsc_req_obj_bcwt)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp store_core_plm_out_rsc_req_obj_plm_out_rsc_req_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_obj_oswt_unreg(plm_out_rsc_req_obj_oswt_unreg),
      .plm_out_rsc_req_obj_bawt(plm_out_rsc_req_obj_bawt),
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
  clk, rst, plm_out_rsc_rls_lz, core_wen, core_wten, plm_out_rsc_rls_obj_oswt_unreg,
      plm_out_rsc_rls_obj_bawt, plm_out_rsc_rls_obj_iswt0
);
  input clk;
  input rst;
  output plm_out_rsc_rls_lz;
  input core_wen;
  input core_wten;
  input plm_out_rsc_rls_obj_oswt_unreg;
  output plm_out_rsc_rls_obj_bawt;
  input plm_out_rsc_rls_obj_iswt0;


  // Interconnect Declarations
  wire plm_out_rsc_rls_obj_biwt;
  wire plm_out_rsc_rls_obj_bdwt;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_mgc_io_sync_v2 #(.valid(32'sd0)) plm_out_rsc_rls_obj (
      .ld(plm_out_rsc_rls_obj_biwt),
      .lz(plm_out_rsc_rls_lz)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_oswt_unreg(plm_out_rsc_rls_obj_oswt_unreg),
      .plm_out_rsc_rls_obj_iswt0(plm_out_rsc_rls_obj_iswt0),
      .plm_out_rsc_rls_obj_biwt(plm_out_rsc_rls_obj_biwt),
      .plm_out_rsc_rls_obj_bdwt(plm_out_rsc_rls_obj_bdwt)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp store_core_plm_out_rsc_rls_obj_plm_out_rsc_rls_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_rls_obj_bawt(plm_out_rsc_rls_obj_bawt),
      .plm_out_rsc_rls_obj_biwt(plm_out_rsc_rls_obj_biwt),
      .plm_out_rsc_rls_obj_bdwt(plm_out_rsc_rls_obj_bdwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_done_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_done_rsci (
  clk, rst, done_rsc_rdy, done_rsc_vld, core_wen, done_rsci_oswt_unreg, done_rsci_bawt,
      done_rsci_iswt0, done_rsci_wen_comp
);
  input clk;
  input rst;
  input done_rsc_rdy;
  output done_rsc_vld;
  input core_wen;
  input done_rsci_oswt_unreg;
  output done_rsci_bawt;
  input done_rsci_iswt0;
  output done_rsci_wen_comp;


  // Interconnect Declarations
  wire done_rsci_biwt;
  wire done_rsci_bdwt;
  wire done_rsci_bcwt;
  wire done_rsci_ivld_core_sct;
  wire done_rsci_irdy;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_sync_out_wait_v1 #(.rscid(32'sd27)) done_rsci (
      .vld(done_rsc_vld),
      .rdy(done_rsc_rdy),
      .ivld(done_rsci_ivld_core_sct),
      .irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_store_core_done_rsci_done_wait_ctrl store_core_done_rsci_done_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_iswt0(done_rsci_iswt0),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt),
      .done_rsci_ivld_core_sct(done_rsci_ivld_core_sct),
      .done_rsci_irdy(done_rsci_irdy)
    );
  esp_acc_softmax_cxx_store_core_done_rsci_done_wait_dp store_core_done_rsci_done_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .done_rsci_oswt_unreg(done_rsci_oswt_unreg),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .done_rsci_biwt(done_rsci_biwt),
      .done_rsci_bdwt(done_rsci_bdwt),
      .done_rsci_bcwt(done_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_dma_write_chnl_rsci (
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd26),
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
  esp_acc_softmax_cxx_ccs_out_wait_v1 #(.rscid(32'sd25),
  .width(32'sd67)) dma_write_ctrl_rsci (
      .irdy(dma_write_ctrl_rsci_irdy),
      .ivld(dma_write_ctrl_rsci_biwt),
      .idat(nl_dma_write_ctrl_rsci_idat[66:0]),
      .rdy(dma_write_ctrl_rsc_rdy),
      .vld(dma_write_ctrl_rsc_vld),
      .dat(dma_write_ctrl_rsc_dat)
    );
  esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(dma_write_ctrl_rsci_oswt_unreg),
      .dma_write_ctrl_rsci_iswt0(dma_write_ctrl_rsci_iswt0),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt)
    );
  esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp store_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp_inst
      (
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
//  Design Unit:    esp_acc_softmax_cxx_store_core_conf_info_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core_conf_info_rsci (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, core_wen, conf_info_rsci_oswt_unreg,
      conf_info_rsci_bawt, conf_info_rsci_iswt0, conf_info_rsci_wen_comp, conf_info_rsci_irdy_core_psct,
      conf_info_rsci_ivld, conf_info_rsci_ivld_oreg, conf_info_rsci_idat_mxwt
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input core_wen;
  input conf_info_rsci_oswt_unreg;
  output conf_info_rsci_bawt;
  input conf_info_rsci_iswt0;
  output conf_info_rsci_wen_comp;
  input conf_info_rsci_irdy_core_psct;
  output conf_info_rsci_ivld;
  input conf_info_rsci_ivld_oreg;
  output [31:0] conf_info_rsci_idat_mxwt;


  // Interconnect Declarations
  wire conf_info_rsci_biwt;
  wire conf_info_rsci_bdwt;
  wire conf_info_rsci_bcwt;
  wire conf_info_rsci_irdy_core_sct;
  wire [31:0] conf_info_rsci_idat;
  wire conf_info_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd23),
  .width(32'sd32),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) conf_info_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(conf_info_rsc_rdy),
      .vld(conf_info_rsc_vld),
      .dat(conf_info_rsc_dat),
      .irdy(conf_info_rsci_irdy_core_sct),
      .ivld(conf_info_rsci_ivld),
      .idat(conf_info_rsci_idat),
      .is_idle(conf_info_rsc_is_idle)
    );
  esp_acc_softmax_cxx_store_core_conf_info_rsci_conf_info_wait_ctrl store_core_conf_info_rsci_conf_info_wait_ctrl_inst
      (
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_irdy_core_sct(conf_info_rsci_irdy_core_sct)
    );
  esp_acc_softmax_cxx_store_core_conf_info_rsci_conf_info_wait_dp store_core_conf_info_rsci_conf_info_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_oswt_unreg(conf_info_rsci_oswt_unreg),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt),
      .conf_info_rsci_biwt(conf_info_rsci_biwt),
      .conf_info_rsci_bdwt(conf_info_rsci_bdwt),
      .conf_info_rsci_bcwt(conf_info_rsci_bcwt),
      .conf_info_rsci_idat(conf_info_rsci_idat)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_core (
  clk, rst, acc_done_rsc_vld, config_done_cns_rdy, config_done_cns_vld, load_done_cns_rdy,
      load_done_cns_vld, compute_done_cns_rdy, compute_done_cns_vld, store_done_cns_rdy,
      store_done_cns_vld
);
  input clk;
  input rst;
  output acc_done_rsc_vld;
  output config_done_cns_rdy;
  input config_done_cns_vld;
  output load_done_cns_rdy;
  input load_done_cns_vld;
  output compute_done_cns_rdy;
  input compute_done_cns_vld;
  output store_done_cns_rdy;
  input store_done_cns_vld;


  // Interconnect Declarations
  wire core_wen;
  wire acc_done_rsci_bawt;
  wire core_wten;
  wire config_done_cnsi_bawt;
  wire config_done_cnsi_wen_comp;
  wire load_done_cnsi_bawt;
  wire load_done_cnsi_wen_comp;
  reg load_done_cnsi_irdy_core_psct;
  wire compute_done_cnsi_bawt;
  wire compute_done_cnsi_wen_comp;
  wire store_done_cnsi_bawt;
  wire store_done_cnsi_wen_comp;
  wire [1:0] fsm_output;
  wire and_dcpl_1;
  wire and_dcpl_2;
  wire and_dcpl_5;
  wire and_dcpl_13;
  wire and_dcpl_14;
  wire and_dcpl_17;
  wire and_dcpl_18;
  wire and_dcpl_19;
  wire and_dcpl_21;
  wire and_dcpl_26;
  wire and_dcpl_27;
  wire and_56_cse;
  reg main_stage_v_4;
  reg reg_store_done_cnsi_irdy_core_psct_cse;
  reg reg_compute_done_cnsi_irdy_core_psct_cse;
  reg reg_store_done_cnsi_oswt_cse;
  reg reg_load_done_cnsi_iswt0_cse;
  wire or_20_cse;
  wire or_17_cse;
  wire or_15_cse;
  wire or_cse;
  wire main_stage_v_4_mx0c1;
  reg reg_config_done_cnsi_iswt0_cse;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_core_core_acc_done_rsci softmax_cxx_core_core_acc_done_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .core_wen(core_wen),
      .acc_done_rsci_oswt_unreg(and_dcpl_27),
      .acc_done_rsci_bawt(acc_done_rsci_bawt),
      .acc_done_rsci_iswt0(reg_store_done_cnsi_oswt_cse),
      .core_wten(core_wten)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_config_done_cnsi softmax_cxx_core_core_config_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .config_done_cns_rdy(config_done_cns_rdy),
      .config_done_cns_vld(config_done_cns_vld),
      .core_wen(core_wen),
      .config_done_cnsi_oswt_unreg(and_56_cse),
      .config_done_cnsi_bawt(config_done_cnsi_bawt),
      .config_done_cnsi_iswt0(reg_config_done_cnsi_iswt0_cse),
      .config_done_cnsi_wen_comp(config_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_load_done_cnsi softmax_cxx_core_core_load_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .load_done_cns_rdy(load_done_cns_rdy),
      .load_done_cns_vld(load_done_cns_vld),
      .core_wen(core_wen),
      .load_done_cnsi_oswt_unreg(and_dcpl_19),
      .load_done_cnsi_bawt(load_done_cnsi_bawt),
      .load_done_cnsi_iswt0(reg_load_done_cnsi_iswt0_cse),
      .load_done_cnsi_wen_comp(load_done_cnsi_wen_comp),
      .load_done_cnsi_irdy_core_psct(load_done_cnsi_irdy_core_psct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_compute_done_cnsi softmax_cxx_core_core_compute_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .compute_done_cns_rdy(compute_done_cns_rdy),
      .compute_done_cns_vld(compute_done_cns_vld),
      .core_wen(core_wen),
      .compute_done_cnsi_oswt_unreg(and_dcpl_14),
      .compute_done_cnsi_bawt(compute_done_cnsi_bawt),
      .compute_done_cnsi_iswt0(reg_compute_done_cnsi_irdy_core_psct_cse),
      .compute_done_cnsi_wen_comp(compute_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_store_done_cnsi softmax_cxx_core_core_store_done_cnsi_inst
      (
      .clk(clk),
      .rst(rst),
      .store_done_cns_rdy(store_done_cns_rdy),
      .store_done_cns_vld(store_done_cns_vld),
      .core_wen(core_wen),
      .store_done_cnsi_oswt_unreg(and_dcpl_18),
      .store_done_cnsi_bawt(store_done_cnsi_bawt),
      .store_done_cnsi_iswt0(reg_store_done_cnsi_irdy_core_psct_cse),
      .store_done_cnsi_wen_comp(store_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_staller softmax_cxx_core_core_staller_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .config_done_cnsi_wen_comp(config_done_cnsi_wen_comp),
      .load_done_cnsi_wen_comp(load_done_cnsi_wen_comp),
      .compute_done_cnsi_wen_comp(compute_done_cnsi_wen_comp),
      .store_done_cnsi_wen_comp(store_done_cnsi_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_core_fsm softmax_cxx_core_core_core_fsm_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign or_20_cse = load_done_cnsi_bawt | (~ reg_load_done_cnsi_iswt0_cse);
  assign or_17_cse = compute_done_cnsi_bawt | (~ reg_compute_done_cnsi_irdy_core_psct_cse);
  assign or_15_cse = store_done_cnsi_bawt | (~ reg_store_done_cnsi_irdy_core_psct_cse);
  assign or_cse = acc_done_rsci_bawt | (~ main_stage_v_4);
  assign and_dcpl_1 = or_cse & or_15_cse;
  assign and_dcpl_2 = and_dcpl_1 & or_17_cse;
  assign and_dcpl_5 = load_done_cnsi_bawt & reg_load_done_cnsi_iswt0_cse;
  assign and_dcpl_13 = compute_done_cnsi_bawt & reg_compute_done_cnsi_irdy_core_psct_cse;
  assign and_dcpl_14 = and_dcpl_1 & and_dcpl_13;
  assign and_dcpl_17 = or_cse & store_done_cnsi_bawt & (~(compute_done_cnsi_bawt
      & reg_compute_done_cnsi_irdy_core_psct_cse)) & reg_store_done_cnsi_irdy_core_psct_cse;
  assign and_dcpl_18 = or_cse & reg_store_done_cnsi_irdy_core_psct_cse & store_done_cnsi_bawt;
  assign and_dcpl_19 = and_dcpl_2 & and_dcpl_5;
  assign and_dcpl_21 = and_dcpl_1 & and_dcpl_13 & (~(load_done_cnsi_bawt & reg_load_done_cnsi_iswt0_cse));
  assign and_dcpl_26 = and_dcpl_2 & and_dcpl_5 & (~ config_done_cnsi_bawt);
  assign and_dcpl_27 = main_stage_v_4 & acc_done_rsci_bawt;
  assign and_56_cse = and_dcpl_2 & or_20_cse & config_done_cnsi_bawt & (fsm_output[1]);
  assign main_stage_v_4_mx0c1 = and_dcpl_27 & (~(store_done_cnsi_bawt & reg_store_done_cnsi_irdy_core_psct_cse));
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_config_done_cnsi_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & ((config_done_cnsi_bawt & or_20_cse & or_17_cse & or_15_cse
        & or_cse) | (fsm_output[0])) ) begin
      reg_config_done_cnsi_iswt0_cse <= 1'b1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_store_done_cnsi_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_14 | and_dcpl_17) ) begin
      reg_store_done_cnsi_irdy_core_psct_cse <= ~ and_dcpl_17;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_store_done_cnsi_oswt_cse <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_store_done_cnsi_oswt_cse <= and_dcpl_18;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_compute_done_cnsi_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_19 | and_dcpl_21) ) begin
      reg_compute_done_cnsi_irdy_core_psct_cse <= ~ and_dcpl_21;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      load_done_cnsi_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (and_56_cse | (and_dcpl_2 & and_dcpl_5 & config_done_cnsi_bawt)
        | and_dcpl_26) ) begin
      load_done_cnsi_irdy_core_psct <= ~ and_dcpl_26;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_load_done_cnsi_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & (and_56_cse | and_dcpl_26) ) begin
      reg_load_done_cnsi_iswt0_cse <= ~ and_dcpl_26;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_18 | main_stage_v_4_mx0c1) ) begin
      main_stage_v_4 <= ~ main_stage_v_4_mx0c1;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_conf_load_rsc_dat,
      plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy, plm_conf_compute_rsc_dat, plm_conf_compute_rsc_vld,
      plm_conf_compute_rsc_rdy, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  wire conf_info_rsci_wen_comp;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_conf_load_rsci_irdy;
  wire plm_conf_load_rsci_bawt;
  wire plm_conf_load_rsci_wen_comp;
  wire plm_conf_load_rsci_irdy_oreg;
  wire plm_conf_compute_rsci_irdy;
  wire plm_conf_compute_rsci_bawt;
  wire plm_conf_compute_rsci_wen_comp;
  wire plm_conf_compute_rsci_irdy_oreg;
  wire plm_conf_store_rsci_irdy;
  wire plm_conf_store_rsci_bawt;
  wire plm_conf_store_rsci_wen_comp;
  wire plm_conf_store_rsci_irdy_oreg;
  reg [31:0] plm_conf_store_rsci_idat;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  wire [1:0] fsm_output;
  wire and_dcpl_1;
  wire and_dcpl_9;
  wire or_dcpl_3;
  wire or_dcpl_5;
  wire and_dcpl_15;
  wire and_dcpl_16;
  wire or_dcpl_6;
  wire and_dcpl_17;
  wire and_dcpl_20;
  wire or_tmp_8;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_plm_conf_store_rsci_ivld_core_psct_cse;
  reg [31:0] reg_plm_conf_compute_rsci_idat_cse;
  wire or_cse;
  reg reg_conf_info_rsci_iswt0_cse;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_config_core_conf_info_rsci config_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(or_tmp_8),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(reg_conf_info_rsci_iswt0_cse),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_config_core_wait_dp config_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsci_irdy(plm_conf_load_rsci_irdy),
      .plm_conf_load_rsci_irdy_oreg(plm_conf_load_rsci_irdy_oreg),
      .plm_conf_compute_rsci_irdy(plm_conf_compute_rsci_irdy),
      .plm_conf_compute_rsci_irdy_oreg(plm_conf_compute_rsci_irdy_oreg),
      .plm_conf_store_rsci_irdy(plm_conf_store_rsci_irdy),
      .plm_conf_store_rsci_irdy_oreg(plm_conf_store_rsci_irdy_oreg)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_load_rsci config_core_plm_conf_load_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_load_rsci_irdy(plm_conf_load_rsci_irdy),
      .plm_conf_load_rsci_oswt_unreg(and_dcpl_15),
      .plm_conf_load_rsci_bawt(plm_conf_load_rsci_bawt),
      .plm_conf_load_rsci_iswt0(reg_plm_conf_store_rsci_ivld_core_psct_cse),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_load_rsci_irdy_oreg(plm_conf_load_rsci_irdy_oreg),
      .plm_conf_load_rsci_idat(reg_plm_conf_compute_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_compute_rsci config_core_plm_conf_compute_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_compute_rsci_irdy(plm_conf_compute_rsci_irdy),
      .plm_conf_compute_rsci_oswt_unreg(and_dcpl_15),
      .plm_conf_compute_rsci_bawt(plm_conf_compute_rsci_bawt),
      .plm_conf_compute_rsci_iswt0(reg_plm_conf_store_rsci_ivld_core_psct_cse),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_compute_rsci_irdy_oreg(plm_conf_compute_rsci_irdy_oreg),
      .plm_conf_compute_rsci_idat(reg_plm_conf_compute_rsci_idat_cse)
    );
  esp_acc_softmax_cxx_config_core_plm_conf_store_rsci config_core_plm_conf_store_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy),
      .core_wen(core_wen),
      .plm_conf_store_rsci_irdy(plm_conf_store_rsci_irdy),
      .plm_conf_store_rsci_oswt_unreg(and_dcpl_15),
      .plm_conf_store_rsci_bawt(plm_conf_store_rsci_bawt),
      .plm_conf_store_rsci_iswt0(reg_plm_conf_store_rsci_ivld_core_psct_cse),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .plm_conf_store_rsci_irdy_oreg(plm_conf_store_rsci_irdy_oreg),
      .plm_conf_store_rsci_idat(plm_conf_store_rsci_idat)
    );
  esp_acc_softmax_cxx_config_core_done_rsci config_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_16),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_config_core_staller config_core_staller_inst (
      .core_wen(core_wen),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .plm_conf_load_rsci_wen_comp(plm_conf_load_rsci_wen_comp),
      .plm_conf_compute_rsci_wen_comp(plm_conf_compute_rsci_wen_comp),
      .plm_conf_store_rsci_wen_comp(plm_conf_store_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_config_core_core_fsm config_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign or_cse = done_rsci_bawt | (~ reg_done_rsci_ivld_core_psct_cse);
  assign and_dcpl_1 = plm_conf_load_rsci_bawt & plm_conf_compute_rsci_bawt;
  assign and_dcpl_9 = reg_done_rsci_ivld_core_psct_cse & (~ done_rsci_bawt);
  assign or_dcpl_3 = ~(plm_conf_load_rsci_bawt & plm_conf_compute_rsci_bawt);
  assign or_dcpl_5 = ((or_dcpl_3 | (~ plm_conf_store_rsci_bawt)) & reg_plm_conf_store_rsci_ivld_core_psct_cse)
      | and_dcpl_9 | (~ conf_info_rsci_bawt);
  assign and_dcpl_15 = or_cse & plm_conf_load_rsci_bawt & plm_conf_compute_rsci_bawt
      & plm_conf_store_rsci_bawt & reg_plm_conf_store_rsci_ivld_core_psct_cse;
  assign and_dcpl_16 = reg_done_rsci_ivld_core_psct_cse & done_rsci_bawt;
  assign or_dcpl_6 = ~(plm_conf_store_rsci_bawt & reg_plm_conf_store_rsci_ivld_core_psct_cse);
  assign and_dcpl_17 = (or_dcpl_3 | or_dcpl_6) & and_dcpl_16;
  assign and_dcpl_20 = or_cse & and_dcpl_1 & plm_conf_store_rsci_bawt & reg_plm_conf_store_rsci_ivld_core_psct_cse
      & (~ conf_info_rsci_bawt);
  assign or_tmp_8 = (~((~(and_dcpl_1 & plm_conf_store_rsci_bawt)) & reg_plm_conf_store_rsci_ivld_core_psct_cse))
      & or_cse & conf_info_rsci_bawt & (fsm_output[1]);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_conf_info_rsci_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & ((conf_info_rsci_bawt & (plm_conf_load_rsci_bawt | (~ reg_plm_conf_store_rsci_ivld_core_psct_cse))
        & (plm_conf_compute_rsci_bawt | (~ reg_plm_conf_store_rsci_ivld_core_psct_cse))
        & (plm_conf_store_rsci_bawt | (~ reg_plm_conf_store_rsci_ivld_core_psct_cse))
        & or_cse) | (fsm_output[0])) ) begin
      reg_conf_info_rsci_iswt0_cse <= 1'b1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_15 | and_dcpl_17) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_17;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_conf_store_rsci_idat <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_5 | ((and_dcpl_9 | or_dcpl_3 | or_dcpl_6 | (~
        conf_info_rsci_bawt)) & (fsm_output[0])))) ) begin
      plm_conf_store_rsci_idat <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_conf_store_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (or_tmp_8 | and_dcpl_20) ) begin
      reg_plm_conf_store_rsci_ivld_core_psct_cse <= ~ and_dcpl_20;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_conf_compute_rsci_idat_cse <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_5 | (fsm_output[0]))) ) begin
      reg_plm_conf_compute_rsci_idat_cse <= conf_info_rsci_idat_mxwt;
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_req_vz,
      plm_in_rsc_rls_lz, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld, dma_read_chnl_rsc_rdy, done_rsc_rdy,
      done_rsc_vld, plm_in_rsci_d_d, plm_in_rsci_wadr_d, plm_in_rsci_we_d_pff
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input [63:0] dma_read_chnl_rsc_dat;
  input dma_read_chnl_rsc_vld;
  output dma_read_chnl_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;
  output [31:0] plm_in_rsci_d_d;
  output [6:0] plm_in_rsci_wadr_d;
  output plm_in_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  reg conf_info_rsci_iswt0;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  reg conf_info_rsci_irdy_core_psct;
  wire conf_info_rsci_ivld;
  wire conf_info_rsci_ivld_oreg;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_in_rsci_bawt;
  wire dma_read_ctrl_rsci_bawt;
  wire dma_read_ctrl_rsci_irdy_mxwt;
  wire dma_read_chnl_rsci_bawt;
  wire dma_read_chnl_rsci_wen_comp;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  wire plm_in_rsc_rls_obj_bawt;
  wire plm_in_rsc_req_obj_bawt;
  reg plm_in_rsc_req_obj_iswt0;
  wire plm_in_rsc_req_obj_wen_comp;
  reg [3:0] dma_read_ctrl_rsci_idat_10_7;
  wire [1:0] fsm_output;
  wire [4:0] LOAD_BATCH_LOOP_acc_1_tmp;
  wire [5:0] nl_LOAD_BATCH_LOOP_acc_1_tmp;
  wire [7:0] LOAD_LOOP_acc_1_tmp;
  wire [8:0] nl_LOAD_LOOP_acc_1_tmp;
  wire or_tmp_1;
  wire and_tmp;
  wire and_tmp_2;
  wire or_tmp_25;
  wire or_tmp_59;
  wire and_tmp_23;
  wire nor_tmp_23;
  wire and_dcpl_3;
  wire and_tmp_45;
  wire or_dcpl_2;
  wire or_dcpl_3;
  wire and_tmp_48;
  wire mux_tmp_142;
  wire and_tmp_50;
  wire and_dcpl_8;
  wire and_dcpl_10;
  wire mux_tmp_173;
  wire or_tmp_181;
  wire and_tmp_63;
  wire and_tmp_64;
  wire mux_tmp_174;
  wire mux_tmp_175;
  wire or_dcpl_4;
  wire and_tmp_65;
  wire mux_tmp_178;
  wire and_dcpl_11;
  wire and_dcpl_15;
  wire and_dcpl_17;
  wire and_dcpl_30;
  wire and_dcpl_40;
  wire and_dcpl_43;
  wire and_dcpl_44;
  wire and_dcpl_45;
  wire and_dcpl_46;
  wire and_tmp_71;
  wire mux_tmp_196;
  wire or_tmp_204;
  wire or_tmp_207;
  wire and_dcpl_47;
  wire and_dcpl_49;
  wire and_dcpl_50;
  wire and_dcpl_52;
  wire and_dcpl_58;
  wire and_dcpl_64;
  wire or_dcpl_22;
  wire and_dcpl_66;
  wire mux_tmp_230;
  wire and_dcpl_69;
  wire or_dcpl_26;
  wire and_tmp_78;
  wire mux_tmp_233;
  wire and_dcpl_74;
  wire or_dcpl_32;
  wire and_dcpl_88;
  wire or_tmp_297;
  wire and_tmp_89;
  wire and_dcpl_89;
  wire and_dcpl_91;
  wire and_tmp_98;
  wire mux_tmp_296;
  wire or_tmp_337;
  wire and_dcpl_101;
  wire or_tmp_366;
  wire or_93_cse;
  wire and_231_cse;
  wire and_255_cse;
  wire and_267_cse;
  wire and_269_cse;
  wire main_stage_en_4;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0;
  wire lfst_exit_LOAD_LOOP_lpi_1_1_mx0;
  wire lfst_exit_LOAD_LOOP_lpi_1_0_mx0;
  wire exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3;
  reg exitL_exit_LOAD_BATCH_LOOP_sva;
  reg LOAD_BATCH_LOOP_asn_itm;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  reg main_stage_v_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1;
  wire LOAD_LOOP_and_1_ssc_1;
  wire LOAD_LOOP_and_2_ssc_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0;
  reg LOAD_LOOP_or_tmp_1;
  reg exit_LOAD_CTRL_LOOP_sva_st_1;
  reg main_stage_v_2;
  reg LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3;
  reg main_stage_v_3;
  reg LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  reg lfst_exit_LOAD_LOOP_lpi_1_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_0;
  reg LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1;
  reg LOAD_LOOP_equal_tmp_1;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2;
  reg reg_plm_in_rsc_rls_obj_ld_core_psct_cse;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_dma_read_chnl_rsci_irdy_core_psct_cse;
  reg reg_dma_read_ctrl_rsci_ivld_core_psct_cse;
  reg reg_dma_read_chnl_rsci_oswt_cse;
  wire LOAD_LOOP_i_and_1_cse;
  wire and_316_cse;
  wire or_60_cse;
  wire LOAD_CTRL_LOOP_and_2_cse;
  wire or_25_cse;
  wire or_339_cse;
  wire or_290_cse;
  wire or_122_cse;
  wire or_117_cse;
  wire or_150_cse;
  wire nand_63_cse;
  wire and_305_cse;
  wire mux_13_cse;
  wire and_292_cse;
  wire mux_199_cse;
  wire and_12_cse;
  wire nand_66_cse;
  wire mux_257_cse;
  wire and_48_cse;
  wire mux_291_cse;
  wire mux_27_cse;
  wire mux_118_cse;
  wire or_148_cse;
  reg [31:0] plm_in_rsci_d_d_reg;
  wire [31:0] LOAD_LOOP_data_ac_mux_rmff;
  reg [6:0] plm_in_rsci_wadr_d_reg;
  wire [6:0] LOAD_LOOP_i_mux_rmff;
  wire plm_in_rsci_we_d_iff;
  wire and_133_rmff;
  wire exitL_exit_LOAD_LOOP_lpi_1_dfm_mx0w0;
  reg [31:0] batch_lpi_1_dfm;
  reg exit_LOAD_CTRL_LOOP_sva_st;
  reg LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm;
  reg exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1;
  reg [3:0] LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0;
  reg [6:0] LOAD_LOOP_i_7_0_lpi_1_6_0;
  reg [6:0] LOAD_LOOP_i_7_0_sva_1_1_6_0;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1;
  reg lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0;
  wire conf_info_rsci_iswt0_mx0c1;
  wire [3:0] LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0;
  wire plm_in_rsc_req_obj_iswt0_mx0c1;
  wire [6:0] LOAD_LOOP_i_7_0_lpi_1_6_0_mx0w0;
  wire exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1;
  wire LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1;
  wire lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1;
  wire LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1;
  wire main_stage_v_2_mx0c1;
  wire exit_LOAD_CTRL_LOOP_sva_st_1_mx0c1;
  wire main_stage_v_3_mx0c1;
  wire exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1;
  wire exit_LOAD_BATCH_LOOP_lpi_1_dfm_4;
  wire LOAD_LOOP_and_15_cse;
  wire LOAD_LOOP_and_18_cse;
  wire LOAD_BATCH_LOOP_acc_itm_32_1;

  wire[0:0] mux_198_nl;
  wire[0:0] mux_197_nl;
  wire[0:0] nor_78_nl;
  wire[0:0] mux_196_nl;
  wire[0:0] mux_195_nl;
  wire[0:0] mux_194_nl;
  wire[0:0] nor_79_nl;
  wire[0:0] mux_193_nl;
  wire[0:0] nor_80_nl;
  wire[0:0] mux_192_nl;
  wire[0:0] mux_191_nl;
  wire[0:0] or_300_nl;
  wire[0:0] nor_74_nl;
  wire[0:0] LOAD_LOOP_mux_20_nl;
  wire[0:0] mux_261_nl;
  wire[0:0] mux_260_nl;
  wire[0:0] mux_259_nl;
  wire[0:0] mux_258_nl;
  wire[0:0] nor_73_nl;
  wire[0:0] mux_269_nl;
  wire[0:0] nor_89_nl;
  wire[0:0] nor_90_nl;
  wire[0:0] mux_268_nl;
  wire[0:0] and_174_nl;
  wire[0:0] mux_296_nl;
  wire[0:0] mux_311_nl;
  wire[0:0] LOAD_BATCH_LOOP_if_mux_2_nl;
  wire[0:0] mux_337_nl;
  wire[0:0] or_58_nl;
  wire[0:0] or_431_nl;
  wire[0:0] LOAD_LOOP_mux_6_nl;
  wire[0:0] mux_340_nl;
  wire[0:0] or_438_nl;
  wire[0:0] mux_339_nl;
  wire[0:0] and_295_nl;
  wire[0:0] mux_338_nl;
  wire[0:0] LOAD_BATCH_LOOP_not_12_nl;
  wire[0:0] LOAD_BATCH_LOOP_if_and_nl;
  wire[0:0] LOAD_BATCH_LOOP_if_and_1_nl;
  wire[0:0] LOAD_BATCH_LOOP_if_or_1_nl;
  wire[0:0] LOAD_LOOP_mux_19_nl;
  wire[0:0] and_171_nl;
  wire[0:0] mux_267_nl;
  wire[0:0] or_327_nl;
  wire[0:0] mux_266_nl;
  wire[0:0] and_297_nl;
  wire[32:0] LOAD_BATCH_LOOP_acc_nl;
  wire[33:0] nl_LOAD_BATCH_LOOP_acc_nl;
  wire[31:0] mux_10_nl;
  wire[6:0] LOAD_LOOP_i_mux_1_nl;
  wire[0:0] LOAD_LOOP_mux_7_nl;
  wire[0:0] LOAD_LOOP_mux_18_nl;
  wire[0:0] or_27_nl;
  wire[0:0] or_26_nl;
  wire[0:0] mux_12_nl;
  wire[0:0] or_24_nl;
  wire[0:0] mux_119_nl;
  wire[0:0] and_47_nl;
  wire[0:0] or_73_nl;
  wire[0:0] or_203_nl;
  wire[0:0] and_85_nl;
  wire[0:0] and_84_nl;
  wire[0:0] mux_210_nl;
  wire[0:0] or_242_nl;
  wire[0:0] mux_209_nl;
  wire[0:0] and_298_nl;
  wire[0:0] mux_217_nl;
  wire[0:0] mux_216_nl;
  wire[0:0] mux_215_nl;
  wire[0:0] mux_214_nl;
  wire[0:0] nor_117_nl;
  wire[0:0] and_160_nl;
  wire[0:0] mux_253_nl;
  wire[0:0] mux_252_nl;
  wire[0:0] and_163_nl;
  wire[0:0] mux_251_nl;
  wire[0:0] mux_250_nl;
  wire[0:0] mux_249_nl;
  wire[0:0] and_161_nl;
  wire[0:0] nor_64_nl;
  wire[0:0] mux_248_nl;
  wire[0:0] and_162_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] mux_286_nl;
  wire[0:0] nor_84_nl;
  wire[0:0] nor_85_nl;
  wire[0:0] mux_285_nl;
  wire[0:0] mux_284_nl;
  wire[0:0] mux_295_nl;
  wire[0:0] mux_294_nl;
  wire[0:0] and_190_nl;
  wire[0:0] mux_293_nl;
  wire[0:0] mux_292_nl;
  wire[0:0] nor_83_nl;
  wire[0:0] mux_290_nl;
  wire[0:0] mux_307_nl;
  wire[0:0] mux_306_nl;
  wire[0:0] or_78_nl;
  wire[0:0] mux_305_nl;
  wire[0:0] and_198_nl;
  wire[0:0] mux_319_nl;
  wire[0:0] mux_318_nl;
  wire[0:0] mux_317_nl;
  wire[0:0] nor_116_nl;
  wire[0:0] mux_132_nl;
  wire[0:0] mux_131_nl;
  wire[0:0] mux_130_nl;
  wire[0:0] mux_129_nl;
  wire[0:0] mux_128_nl;
  wire[0:0] mux_127_nl;
  wire[0:0] nor_98_nl;
  wire[0:0] mux_126_nl;
  wire[0:0] mux_125_nl;
  wire[0:0] mux_124_nl;
  wire[0:0] mux_123_nl;
  wire[0:0] nand_44_nl;
  wire[0:0] mux_28_nl;
  wire[0:0] mux_121_nl;
  wire[0:0] nor_99_nl;
  wire[0:0] nor_100_nl;
  wire[0:0] mux_120_nl;
  wire[0:0] and_306_nl;
  wire[0:0] nor_101_nl;
  wire[0:0] nand_65_nl;
  wire[0:0] mux_151_nl;
  wire[0:0] mux_150_nl;
  wire[0:0] mux_149_nl;
  wire[0:0] mux_148_nl;
  wire[0:0] mux_147_nl;
  wire[0:0] and_303_nl;
  wire[0:0] mux_146_nl;
  wire[0:0] mux_145_nl;
  wire[0:0] mux_144_nl;
  wire[0:0] mux_143_nl;
  wire[0:0] mux_142_nl;
  wire[0:0] and_304_nl;
  wire[0:0] mux_141_nl;
  wire[0:0] mux_140_nl;
  wire[0:0] mux_139_nl;
  wire[0:0] nor_97_nl;
  wire[0:0] mux_138_nl;
  wire[0:0] mux_137_nl;
  wire[0:0] mux_310_nl;
  wire[0:0] mux_309_nl;
  wire[0:0] nor_92_nl;
  wire[0:0] mux_316_nl;
  wire[0:0] mux_315_nl;
  wire[0:0] nand_61_nl;
  wire[0:0] mux_314_nl;
  wire[0:0] mux_313_nl;
  wire[0:0] or_401_nl;
  wire[0:0] mux_312_nl;
  wire[0:0] or_397_nl;
  wire[0:0] mux_165_nl;
  wire[0:0] and_65_nl;
  wire[0:0] mux_164_nl;
  wire[0:0] mux_163_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] mux_161_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] and_293_nl;
  wire[0:0] mux_158_nl;
  wire[0:0] mux_156_nl;
  wire[0:0] mux_275_nl;
  wire[0:0] and_178_nl;
  wire[0:0] mux_274_nl;
  wire[0:0] mux_273_nl;
  wire[0:0] mux_272_nl;
  wire[0:0] mux_271_nl;
  wire[0:0] nor_87_nl;
  wire[0:0] mux_270_nl;
  wire[0:0] nor_88_nl;
  wire[0:0] mux_324_nl;
  wire[0:0] or_417_nl;
  wire[0:0] mux_323_nl;
  wire[0:0] or_416_nl;
  wire[0:0] or_415_nl;
  wire[0:0] mux_330_nl;
  wire[0:0] and_220_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_load_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg;
  assign nl_load_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg = and_dcpl_64
      & and_dcpl_3 & (fsm_output[1]);
  wire [0:0] nl_load_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg;
  assign nl_load_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg = or_dcpl_3 & or_290_cse
      & plm_in_rsci_bawt & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0) & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1
      & and_dcpl_17;
  wire [66:0] nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_load_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_load_core_plm_in_rsc_rls_obj_inst_plm_in_rsc_rls_obj_oswt_unreg;
  assign nl_load_core_plm_in_rsc_rls_obj_inst_plm_in_rsc_rls_obj_oswt_unreg = or_dcpl_3
      & plm_in_rsci_bawt & plm_in_rsc_rls_obj_bawt & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2
      & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0) & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1
      & and_dcpl_17;
  wire [0:0] nl_load_core_plm_in_rsc_req_obj_inst_plm_in_rsc_req_obj_oswt_unreg;
  assign nl_load_core_plm_in_rsc_req_obj_inst_plm_in_rsc_req_obj_oswt_unreg = or_dcpl_3
      & plm_in_rsc_req_obj_bawt & exit_LOAD_CTRL_LOOP_sva_st_1 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1)
      & and_dcpl_17;
  esp_acc_softmax_cxx_load_core_wait_dp load_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg)
    );
  esp_acc_softmax_cxx_load_core_conf_info_rsci load_core_conf_info_rsci_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(nl_load_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg[0:0]),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsci_1 load_core_plm_in_rsci_1_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt_unreg(nl_load_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg[0:0]),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_iswt0(reg_dma_read_chnl_rsci_oswt_cse),
      .plm_in_rsci_we_d_pff(plm_in_rsci_we_d_iff),
      .plm_in_rsci_iswt0_pff(and_133_rmff)
    );
  esp_acc_softmax_cxx_load_core_dma_read_ctrl_rsci load_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_oswt_unreg(and_dcpl_58),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_iswt0(reg_dma_read_ctrl_rsci_ivld_core_psct_cse),
      .dma_read_ctrl_rsci_irdy_mxwt(dma_read_ctrl_rsci_irdy_mxwt),
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
      .dma_read_chnl_rsci_oswt_unreg(and_133_rmff),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_iswt0(reg_dma_read_chnl_rsci_irdy_core_psct_cse),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_idat_mxwt(dma_read_chnl_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_load_core_done_rsci load_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_43),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_rls_obj load_core_plm_in_rsc_rls_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_oswt_unreg(nl_load_core_plm_in_rsc_rls_obj_inst_plm_in_rsc_rls_obj_oswt_unreg[0:0]),
      .plm_in_rsc_rls_obj_bawt(plm_in_rsc_rls_obj_bawt),
      .plm_in_rsc_rls_obj_iswt0(reg_plm_in_rsc_rls_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_load_core_plm_in_rsc_req_obj load_core_plm_in_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .core_wen(core_wen),
      .plm_in_rsc_req_obj_oswt_unreg(nl_load_core_plm_in_rsc_req_obj_inst_plm_in_rsc_req_obj_oswt_unreg[0:0]),
      .plm_in_rsc_req_obj_bawt(plm_in_rsc_req_obj_bawt),
      .plm_in_rsc_req_obj_iswt0(plm_in_rsc_req_obj_iswt0),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_load_core_staller load_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_load_core_core_fsm load_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign and_292_cse = or_tmp_25 & mux_13_cse;
  assign nor_78_nl = ~(lfst_exit_LOAD_LOOP_lpi_1_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1
      | (~ mux_13_cse));
  assign mux_197_nl = MUX_s_1_2_2(nor_78_nl, and_tmp_65, LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1);
  assign nor_79_nl = ~(and_316_cse | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ mux_tmp_178));
  assign nor_80_nl = ~(dma_read_ctrl_rsci_irdy_mxwt | (~(dma_read_ctrl_rsci_bawt
      & mux_13_cse)));
  assign mux_193_nl = MUX_s_1_2_2(nor_80_nl, and_292_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_194_nl = MUX_s_1_2_2(nor_79_nl, mux_193_nl, LOAD_LOOP_or_tmp_1);
  assign mux_195_nl = MUX_s_1_2_2(mux_194_nl, and_tmp_65, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_192_nl = MUX_s_1_2_2(mux_tmp_178, and_tmp_65, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_196_nl = MUX_s_1_2_2(mux_195_nl, mux_192_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_198_nl = MUX_s_1_2_2(mux_197_nl, mux_196_nl, main_stage_v_1);
  assign mux_191_nl = MUX_s_1_2_2(mux_tmp_178, and_tmp_65, or_122_cse);
  assign mux_199_cse = MUX_s_1_2_2(mux_198_nl, mux_191_nl, or_tmp_1);
  assign and_133_rmff = and_dcpl_15 & and_dcpl_50;
  assign or_290_cse = plm_in_rsc_rls_obj_bawt | (~ LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2);
  assign LOAD_LOOP_i_mux_rmff = MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_1_6_0, plm_in_rsci_wadr_d_reg,
      or_dcpl_22);
  assign LOAD_LOOP_data_ac_mux_rmff = MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt,
      plm_in_rsci_d_d_reg, or_dcpl_22);
  assign and_316_cse = lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1 & lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0;
  assign nor_74_nl = ~(dma_read_ctrl_rsci_irdy_mxwt | (~ and_tmp_48));
  assign mux_257_cse = MUX_s_1_2_2(nor_74_nl, and_292_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign or_339_cse = exitL_exit_LOAD_BATCH_LOOP_sva | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign or_60_cse = (~ LOAD_BATCH_LOOP_asn_itm) | conf_info_rsci_bawt;
  assign LOAD_LOOP_and_15_cse = core_wen & (~ or_dcpl_4);
  assign LOAD_LOOP_i_and_1_cse = core_wen & (~((~ mux_tmp_230) | or_dcpl_26));
  assign LOAD_CTRL_LOOP_and_2_cse = core_wen & (~ (fsm_output[0]));
  assign or_58_nl = LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  assign or_431_nl = or_93_cse | (~ or_tmp_297);
  assign mux_337_nl = MUX_s_1_2_2(or_58_nl, or_431_nl, main_stage_v_1);
  assign LOAD_LOOP_and_18_cse = LOAD_CTRL_LOOP_and_2_cse & (~(mux_337_nl | or_tmp_1));
  assign or_117_cse = lfst_exit_LOAD_LOOP_lpi_1_0 | (~ lfst_exit_LOAD_LOOP_lpi_1_1)
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  assign LOAD_BATCH_LOOP_not_12_nl = ~ exitL_exit_LOAD_BATCH_LOOP_sva;
  assign LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0 = MUX_v_4_2_2(4'b0000, LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0,
      LOAD_BATCH_LOOP_not_12_nl);
  assign LOAD_BATCH_LOOP_if_and_nl = LOAD_LOOP_or_tmp_1 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign LOAD_BATCH_LOOP_if_and_1_nl = LOAD_LOOP_equal_tmp_1 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign LOAD_BATCH_LOOP_if_or_1_nl = and_316_cse | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign LOAD_LOOP_i_7_0_lpi_1_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~ dma_read_ctrl_rsci_irdy_mxwt)),
      LOAD_LOOP_i_7_0_sva_1_1_6_0, LOAD_LOOP_i_7_0_lpi_1_6_0, {LOAD_BATCH_LOOP_if_and_nl
      , LOAD_BATCH_LOOP_if_and_1_nl , LOAD_BATCH_LOOP_if_or_1_nl});
  assign LOAD_LOOP_mux_19_nl = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, (LOAD_BATCH_LOOP_acc_1_tmp[4]),
      LOAD_LOOP_acc_1_tmp[7]);
  assign and_297_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & (~ and_316_cse);
  assign mux_266_nl = MUX_s_1_2_2(and_297_nl, dma_read_ctrl_rsci_irdy_mxwt, LOAD_LOOP_or_tmp_1);
  assign or_327_nl = or_93_cse | (~ mux_266_nl);
  assign mux_267_nl = MUX_s_1_2_2(or_150_cse, or_327_nl, main_stage_v_1);
  assign and_171_nl = (~ mux_267_nl) & and_dcpl_46;
  assign exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1 = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4,
      LOAD_LOOP_mux_19_nl, and_171_nl);
  assign lfst_exit_LOAD_LOOP_lpi_1_1_mx0 = MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1,
      lfst_exit_LOAD_LOOP_lpi_1_1, or_dcpl_32);
  assign lfst_exit_LOAD_LOOP_lpi_1_0_mx0 = MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1,
      lfst_exit_LOAD_LOOP_lpi_1_0, or_dcpl_32);
  assign exitL_exit_LOAD_LOOP_lpi_1_dfm_mx0w0 = (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1
      | lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1)) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0 = lfst_exit_LOAD_LOOP_lpi_1_1_mx0
      & (~ exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1);
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0 = lfst_exit_LOAD_LOOP_lpi_1_0_mx0
      & (~ exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1);
  assign exit_LOAD_BATCH_LOOP_lpi_1_dfm_4 = (~ LOAD_BATCH_LOOP_acc_itm_32_1) & exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1;
  assign mux_10_nl = MUX_v_32_2_2(batch_lpi_1_dfm, conf_info_rsci_idat_mxwt, exitL_exit_LOAD_BATCH_LOOP_sva);
  assign nl_LOAD_BATCH_LOOP_acc_nl = ({29'b10000000000000000000000000000 , LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0})
      + conv_u2u_32_33(~ mux_10_nl) + 33'b000000000000000000000000000000001;
  assign LOAD_BATCH_LOOP_acc_nl = nl_LOAD_BATCH_LOOP_acc_nl[32:0];
  assign LOAD_BATCH_LOOP_acc_itm_32_1 = readslicef_33_1_32(LOAD_BATCH_LOOP_acc_nl);
  assign nl_LOAD_BATCH_LOOP_acc_1_tmp = conv_u2u_4_5(LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0)
      + 5'b00001;
  assign LOAD_BATCH_LOOP_acc_1_tmp = nl_LOAD_BATCH_LOOP_acc_1_tmp[4:0];
  assign LOAD_LOOP_i_mux_1_nl = MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_1_6_0, LOAD_LOOP_i_7_0_lpi_1_6_0_mx0w0,
      main_stage_v_1);
  assign nl_LOAD_LOOP_acc_1_tmp = conv_u2u_7_8(LOAD_LOOP_i_mux_1_nl) + 8'b00000001;
  assign LOAD_LOOP_acc_1_tmp = nl_LOAD_LOOP_acc_1_tmp[7:0];
  assign LOAD_LOOP_mux_7_nl = MUX_s_1_2_2(LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1,
      exitL_exit_LOAD_LOOP_lpi_1_dfm_mx0w0, main_stage_v_1);
  assign exitL_exitL_exit_LOAD_LOOP_lpi_1_dfm_1 = LOAD_LOOP_mux_7_nl | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3
      | exitL_exit_LOAD_BATCH_LOOP_sva;
  assign LOAD_LOOP_mux_18_nl = MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1, lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1,
      and_316_cse);
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_3_1_1 = (LOAD_LOOP_mux_18_nl & (~ LOAD_LOOP_and_1_ssc_1))
      | LOAD_LOOP_and_2_ssc_1;
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_3_0_1 = (and_316_cse & (~ LOAD_LOOP_and_2_ssc_1))
      | LOAD_LOOP_and_1_ssc_1;
  assign LOAD_LOOP_and_1_ssc_1 = (~ dma_read_ctrl_rsci_irdy_mxwt) & LOAD_LOOP_or_tmp_1;
  assign LOAD_LOOP_and_2_ssc_1 = dma_read_ctrl_rsci_irdy_mxwt & LOAD_LOOP_or_tmp_1;
  assign main_stage_en_4 = or_60_cse & (dma_read_ctrl_rsci_bawt | (~((~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)) & main_stage_v_1))) & (dma_read_chnl_rsci_bawt
      | (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0)
      & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1))) & (plm_in_rsc_req_obj_bawt
      | (~(exit_LOAD_CTRL_LOOP_sva_st_1 & ((lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0
      & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1)) | (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1
      | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0))) & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (plm_in_rsci_bawt | (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1
      & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0) & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (plm_in_rsc_rls_obj_bawt | (~(LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2
      & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0)
      & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2) & main_stage_v_2))) & (done_rsci_bawt
      | (~(exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 & main_stage_v_3)));
  assign or_tmp_1 = exitL_exit_LOAD_BATCH_LOOP_sva | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3;
  assign or_25_cse = (~ main_stage_v_2) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign or_27_nl = plm_in_rsc_req_obj_bawt | (~ exit_LOAD_CTRL_LOOP_sva_st_1) |
      (~ main_stage_v_2) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign or_24_nl = plm_in_rsc_rls_obj_bawt | (~ LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2)
      | (~ main_stage_v_2) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign mux_12_nl = MUX_s_1_2_2(or_25_cse, or_24_nl, plm_in_rsci_bawt);
  assign or_26_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0 | mux_12_nl;
  assign mux_13_cse = MUX_s_1_2_2(or_27_nl, or_26_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1);
  assign and_tmp = ((~ main_stage_v_3) | (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3)
      | done_rsci_bawt) & mux_13_cse;
  assign and_tmp_2 = dma_read_ctrl_rsci_bawt & and_tmp;
  assign or_tmp_25 = dma_read_chnl_rsci_bawt | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
  assign and_12_cse = or_tmp_25 & and_tmp;
  assign mux_27_cse = MUX_s_1_2_2(and_tmp_2, and_12_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign or_tmp_59 = LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 | exitL_exit_LOAD_BATCH_LOOP_sva
      | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3;
  assign or_93_cse = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign and_tmp_23 = LOAD_BATCH_LOOP_acc_itm_32_1 & and_tmp;
  assign or_122_cse = (~ main_stage_v_1) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign mux_118_cse = MUX_s_1_2_2(mux_27_cse, and_tmp, or_122_cse);
  assign nor_tmp_23 = dma_read_ctrl_rsci_irdy_mxwt & dma_read_ctrl_rsci_bawt;
  assign and_47_nl = nor_tmp_23 & and_tmp;
  assign mux_119_nl = MUX_s_1_2_2(and_47_nl, and_12_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_48_cse = (LOAD_BATCH_LOOP_acc_1_tmp[4]) & (LOAD_LOOP_acc_1_tmp[7]) &
      mux_119_nl;
  assign or_148_cse = and_316_cse | (~ mux_27_cse);
  assign or_150_cse = LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 | (~ lfst_exit_LOAD_LOOP_lpi_1_1)
      | lfst_exit_LOAD_LOOP_lpi_1_0 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  assign nand_66_cse = ~((LOAD_BATCH_LOOP_acc_1_tmp[4]) & (LOAD_LOOP_acc_1_tmp[7])
      & and_tmp);
  assign and_dcpl_3 = conf_info_rsci_bawt & LOAD_BATCH_LOOP_asn_itm;
  assign and_tmp_45 = LOAD_BATCH_LOOP_acc_itm_32_1 & mux_27_cse;
  assign or_dcpl_2 = (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3) | done_rsci_bawt;
  assign or_dcpl_3 = or_dcpl_2 | (~ main_stage_v_3);
  assign and_tmp_48 = dma_read_ctrl_rsci_bawt & mux_13_cse;
  assign mux_tmp_142 = MUX_s_1_2_2(and_tmp_48, and_292_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_tmp_50 = LOAD_BATCH_LOOP_acc_itm_32_1 & mux_tmp_142;
  assign and_dcpl_8 = (~ conf_info_rsci_bawt) & LOAD_BATCH_LOOP_asn_itm;
  assign and_dcpl_10 = exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 & (~ done_rsci_bawt)
      & main_stage_v_3;
  assign or_73_nl = (~ exit_LOAD_CTRL_LOOP_sva_st_1) | plm_in_rsc_req_obj_bawt;
  assign or_203_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0 | (or_290_cse & plm_in_rsci_bawt);
  assign mux_tmp_173 = MUX_s_1_2_2(or_73_nl, or_203_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1);
  assign or_tmp_181 = or_25_cse | mux_tmp_173;
  assign and_tmp_63 = or_tmp_25 & or_tmp_181;
  assign and_tmp_64 = dma_read_ctrl_rsci_bawt & or_tmp_181;
  assign mux_tmp_174 = MUX_s_1_2_2(and_tmp_64, and_tmp_63, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_tmp_175 = MUX_s_1_2_2(mux_tmp_174, or_tmp_181, or_122_cse);
  assign or_dcpl_4 = (~ mux_tmp_175) | and_dcpl_10;
  assign and_tmp_65 = LOAD_BATCH_LOOP_acc_itm_32_1 & mux_13_cse;
  assign and_85_nl = dma_read_ctrl_rsci_bawt & LOAD_BATCH_LOOP_acc_itm_32_1 & mux_13_cse;
  assign and_84_nl = or_tmp_25 & LOAD_BATCH_LOOP_acc_itm_32_1 & mux_13_cse;
  assign mux_tmp_178 = MUX_s_1_2_2(and_85_nl, and_84_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_dcpl_11 = (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1;
  assign and_dcpl_15 = or_tmp_181 & or_dcpl_3;
  assign and_dcpl_17 = (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2) & main_stage_v_2;
  assign and_dcpl_30 = dma_read_chnl_rsci_bawt & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0)
      & lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1;
  assign and_dcpl_40 = (mux_tmp_173 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & or_dcpl_3;
  assign and_dcpl_43 = exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 & done_rsci_bawt & main_stage_v_3;
  assign and_dcpl_44 = ~(mux_tmp_173 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2);
  assign and_dcpl_45 = (and_dcpl_44 | (~ main_stage_v_2) | (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2))
      & and_dcpl_43;
  assign and_dcpl_46 = ~(exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_LOAD_BATCH_LOOP_sva);
  assign and_tmp_71 = nor_tmp_23 & or_tmp_181;
  assign mux_tmp_196 = MUX_s_1_2_2(and_tmp_71, and_tmp_63, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign or_tmp_204 = and_316_cse | (~ mux_tmp_174);
  assign or_tmp_207 = or_150_cse | (~ or_tmp_181);
  assign and_298_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & (~ or_tmp_204);
  assign mux_209_nl = MUX_s_1_2_2(and_298_nl, mux_tmp_196, LOAD_LOOP_or_tmp_1);
  assign or_242_nl = or_93_cse | (~ mux_209_nl);
  assign mux_210_nl = MUX_s_1_2_2(or_tmp_207, or_242_nl, main_stage_v_1);
  assign and_dcpl_47 = (~ mux_210_nl) & or_dcpl_3;
  assign and_dcpl_49 = and_dcpl_47 & or_60_cse & and_dcpl_46;
  assign and_dcpl_50 = and_dcpl_30 & and_dcpl_11;
  assign nor_117_nl = ~(or_60_cse | (~ mux_13_cse));
  assign mux_214_nl = MUX_s_1_2_2(mux_13_cse, nor_117_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1);
  assign mux_215_nl = MUX_s_1_2_2(mux_214_nl, mux_13_cse, and_316_cse);
  assign mux_216_nl = MUX_s_1_2_2(mux_215_nl, mux_13_cse, LOAD_LOOP_or_tmp_1);
  assign mux_217_nl = MUX_s_1_2_2(mux_216_nl, mux_13_cse, or_339_cse);
  assign and_dcpl_52 = mux_217_nl & or_dcpl_3 & and_dcpl_50;
  assign and_dcpl_58 = and_dcpl_15 & dma_read_ctrl_rsci_bawt & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1)
      & and_dcpl_11;
  assign and_dcpl_64 = mux_tmp_175 & or_dcpl_3;
  assign or_dcpl_22 = (~ or_tmp_181) | and_dcpl_10 | (~ dma_read_chnl_rsci_bawt)
      | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0 | (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1)
      | or_122_cse;
  assign and_dcpl_66 = and_dcpl_64 & or_60_cse;
  assign mux_tmp_230 = MUX_s_1_2_2(mux_tmp_174, or_tmp_181, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_dcpl_69 = mux_tmp_230 & or_dcpl_3;
  assign or_dcpl_26 = and_dcpl_10 | (~ main_stage_v_1);
  assign and_tmp_78 = (dma_read_chnl_rsci_bawt | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & mux_13_cse;
  assign and_160_nl = (dma_read_ctrl_rsci_bawt | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)
      & mux_13_cse;
  assign mux_tmp_233 = MUX_s_1_2_2(and_160_nl, and_tmp_78, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign and_163_nl = or_150_cse & mux_13_cse;
  assign and_161_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 & mux_13_cse;
  assign nor_64_nl = ~(and_316_cse | (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1));
  assign mux_249_nl = MUX_s_1_2_2(mux_tmp_233, and_161_nl, nor_64_nl);
  assign and_162_nl = ((~(dma_read_ctrl_rsci_irdy_mxwt | (~ dma_read_ctrl_rsci_bawt)))
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & mux_13_cse;
  assign mux_248_nl = MUX_s_1_2_2(and_162_nl, and_tmp_78, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_250_nl = MUX_s_1_2_2(mux_249_nl, mux_248_nl, LOAD_LOOP_or_tmp_1);
  assign mux_251_nl = MUX_s_1_2_2(mux_250_nl, mux_tmp_233, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_252_nl = MUX_s_1_2_2(and_163_nl, mux_251_nl, main_stage_v_1);
  assign mux_246_nl = MUX_s_1_2_2(mux_13_cse, mux_tmp_233, main_stage_v_1);
  assign mux_253_nl = MUX_s_1_2_2(mux_252_nl, mux_246_nl, or_tmp_1);
  assign and_dcpl_74 = mux_253_nl & or_dcpl_3;
  assign or_dcpl_32 = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ main_stage_v_1);
  assign and_dcpl_88 = and_dcpl_69 & and_dcpl_8 & main_stage_v_1;
  assign or_tmp_297 = LOAD_LOOP_or_tmp_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1;
  assign and_tmp_89 = and_316_cse & mux_tmp_174;
  assign nor_84_nl = ~(LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 | (~ or_tmp_181));
  assign mux_284_nl = MUX_s_1_2_2(and_tmp_89, mux_tmp_174, or_tmp_297);
  assign mux_285_nl = MUX_s_1_2_2(mux_284_nl, or_tmp_181, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign nor_85_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ mux_285_nl));
  assign mux_286_nl = MUX_s_1_2_2(nor_84_nl, nor_85_nl, main_stage_v_1);
  assign and_dcpl_89 = mux_286_nl & or_dcpl_3;
  assign mux_291_cse = MUX_s_1_2_2(mux_tmp_142, mux_13_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_190_nl = LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 & mux_13_cse;
  assign nor_83_nl = ~(and_316_cse | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | LOAD_LOOP_or_tmp_1
      | (~ mux_tmp_142));
  assign mux_292_nl = MUX_s_1_2_2(nor_83_nl, mux_13_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_293_nl = MUX_s_1_2_2(mux_292_nl, mux_291_cse, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_294_nl = MUX_s_1_2_2(and_190_nl, mux_293_nl, main_stage_v_1);
  assign mux_290_nl = MUX_s_1_2_2(mux_tmp_142, mux_13_cse, or_122_cse);
  assign mux_295_nl = MUX_s_1_2_2(mux_294_nl, mux_290_nl, or_tmp_1);
  assign and_dcpl_91 = mux_295_nl & or_dcpl_3;
  assign and_tmp_98 = LOAD_BATCH_LOOP_acc_itm_32_1 & or_tmp_181;
  assign or_78_nl = LOAD_LOOP_or_tmp_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | LOAD_BATCH_LOOP_acc_itm_32_1;
  assign mux_306_nl = MUX_s_1_2_2(and_tmp_89, mux_tmp_174, or_78_nl);
  assign mux_307_nl = MUX_s_1_2_2(mux_306_nl, and_tmp_98, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_198_nl = LOAD_BATCH_LOOP_acc_itm_32_1 & mux_tmp_174;
  assign mux_305_nl = MUX_s_1_2_2(and_198_nl, and_tmp_98, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_tmp_296 = MUX_s_1_2_2(mux_307_nl, mux_305_nl, or_339_cse);
  assign or_tmp_337 = LOAD_BATCH_LOOP_acc_itm_32_1 | (~ or_tmp_181);
  assign nor_116_nl = ~(or_tmp_297 | or_tmp_204);
  assign mux_317_nl = MUX_s_1_2_2(nor_116_nl, or_tmp_181, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_318_nl = MUX_s_1_2_2(mux_317_nl, mux_tmp_230, or_339_cse);
  assign mux_319_nl = MUX_s_1_2_2(or_tmp_181, mux_318_nl, main_stage_v_1);
  assign and_dcpl_101 = mux_319_nl & or_dcpl_3 & or_60_cse;
  assign nor_98_nl = ~(or_117_cse | nand_66_cse);
  assign mux_127_nl = MUX_s_1_2_2(nor_98_nl, and_tmp, LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1);
  assign nand_44_nl = ~((LOAD_BATCH_LOOP_acc_1_tmp[4]) & (LOAD_LOOP_acc_1_tmp[7])
      & (~ or_148_cse));
  assign mux_123_nl = MUX_s_1_2_2(or_148_cse, nand_44_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1);
  assign mux_124_nl = MUX_s_1_2_2((~ mux_123_nl), and_48_cse, LOAD_LOOP_or_tmp_1);
  assign mux_125_nl = MUX_s_1_2_2(mux_124_nl, and_tmp, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_28_nl = MUX_s_1_2_2(mux_27_cse, and_tmp, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_126_nl = MUX_s_1_2_2(mux_125_nl, mux_28_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_128_nl = MUX_s_1_2_2(mux_127_nl, mux_126_nl, main_stage_v_1);
  assign nor_99_nl = ~(or_150_cse | nand_66_cse);
  assign and_306_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & (LOAD_BATCH_LOOP_acc_1_tmp[4])
      & (LOAD_LOOP_acc_1_tmp[7]) & (~ or_148_cse);
  assign mux_120_nl = MUX_s_1_2_2(and_306_nl, and_48_cse, LOAD_LOOP_or_tmp_1);
  assign nor_100_nl = ~(or_93_cse | (~ mux_120_nl));
  assign mux_121_nl = MUX_s_1_2_2(nor_99_nl, nor_100_nl, main_stage_v_1);
  assign mux_129_nl = MUX_s_1_2_2(mux_128_nl, mux_121_nl, LOAD_BATCH_LOOP_acc_itm_32_1);
  assign nor_101_nl = ~(LOAD_BATCH_LOOP_acc_itm_32_1 | (~ mux_118_cse));
  assign mux_130_nl = MUX_s_1_2_2(mux_129_nl, nor_101_nl, exit_LOAD_BATCH_LOOP_lpi_1_dfm_3);
  assign nand_65_nl = ~(LOAD_BATCH_LOOP_acc_itm_32_1 & mux_118_cse);
  assign mux_131_nl = MUX_s_1_2_2(mux_130_nl, nand_65_nl, exitL_exit_LOAD_BATCH_LOOP_sva);
  assign mux_132_nl = MUX_s_1_2_2(exitL_exit_LOAD_BATCH_LOOP_sva, mux_131_nl, or_60_cse);
  assign or_tmp_366 = (mux_132_nl & main_stage_en_4) | (fsm_output[0]);
  assign nand_63_cse = ~((LOAD_BATCH_LOOP_acc_1_tmp[4]) & (LOAD_LOOP_acc_1_tmp[7]));
  assign and_305_cse = (LOAD_BATCH_LOOP_acc_1_tmp[4]) & (LOAD_LOOP_acc_1_tmp[7]);
  assign and_303_nl = nand_63_cse & and_tmp;
  assign mux_147_nl = MUX_s_1_2_2(and_303_nl, and_tmp, or_117_cse);
  assign mux_148_nl = MUX_s_1_2_2(mux_147_nl, and_tmp_23, LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1);
  assign and_304_nl = nand_63_cse & mux_27_cse;
  assign mux_142_nl = MUX_s_1_2_2(and_tmp_45, and_304_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1);
  assign mux_143_nl = MUX_s_1_2_2(mux_142_nl, mux_27_cse, and_316_cse);
  assign mux_144_nl = MUX_s_1_2_2(mux_143_nl, and_tmp_23, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign nor_97_nl = ~(dma_read_ctrl_rsci_irdy_mxwt | (~ and_tmp_2));
  assign mux_139_nl = MUX_s_1_2_2(nor_97_nl, and_12_cse, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_140_nl = MUX_s_1_2_2(mux_27_cse, mux_139_nl, and_305_cse);
  assign mux_141_nl = MUX_s_1_2_2(mux_140_nl, and_tmp_23, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_145_nl = MUX_s_1_2_2(mux_144_nl, mux_141_nl, LOAD_LOOP_or_tmp_1);
  assign mux_138_nl = MUX_s_1_2_2(and_tmp_45, and_tmp_23, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_146_nl = MUX_s_1_2_2(mux_145_nl, mux_138_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_149_nl = MUX_s_1_2_2(mux_148_nl, mux_146_nl, main_stage_v_1);
  assign mux_137_nl = MUX_s_1_2_2(and_tmp_45, and_tmp_23, or_122_cse);
  assign mux_150_nl = MUX_s_1_2_2(mux_149_nl, mux_137_nl, or_tmp_1);
  assign mux_151_nl = MUX_s_1_2_2(mux_118_cse, mux_150_nl, main_stage_en_4);
  assign and_231_cse = mux_151_nl & and_dcpl_3 & (fsm_output[1]);
  assign and_255_cse = and_dcpl_74 & or_60_cse & (fsm_output[1]);
  assign nor_92_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ or_tmp_181));
  assign mux_309_nl = MUX_s_1_2_2(nor_92_nl, and_tmp_98, or_tmp_59);
  assign mux_310_nl = MUX_s_1_2_2(mux_309_nl, mux_tmp_296, main_stage_v_1);
  assign and_267_cse = mux_310_nl & or_dcpl_3 & or_60_cse & (fsm_output[1]);
  assign nand_61_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & or_tmp_181);
  assign mux_315_nl = MUX_s_1_2_2(nand_61_nl, or_tmp_337, or_tmp_59);
  assign or_401_nl = LOAD_LOOP_or_tmp_1 | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | LOAD_BATCH_LOOP_acc_itm_32_1
      | or_tmp_204;
  assign mux_313_nl = MUX_s_1_2_2(or_401_nl, or_tmp_337, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign or_397_nl = LOAD_BATCH_LOOP_acc_itm_32_1 | (~ mux_tmp_174);
  assign mux_312_nl = MUX_s_1_2_2(or_397_nl, or_tmp_337, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_314_nl = MUX_s_1_2_2(mux_313_nl, mux_312_nl, or_339_cse);
  assign mux_316_nl = MUX_s_1_2_2(mux_315_nl, mux_314_nl, main_stage_v_1);
  assign and_269_cse = (~ mux_316_nl) & or_dcpl_3 & or_60_cse & (fsm_output[1]);
  assign and_65_nl = ((~ main_stage_en_4) | LOAD_BATCH_LOOP_acc_itm_32_1) & mux_13_cse;
  assign and_293_nl = nand_63_cse & mux_tmp_142;
  assign mux_159_nl = MUX_s_1_2_2(and_tmp_50, and_293_nl, LOAD_BATCH_LOOP_if_asn_sft_lpi_1);
  assign mux_160_nl = MUX_s_1_2_2(mux_159_nl, mux_tmp_142, and_316_cse);
  assign mux_158_nl = MUX_s_1_2_2(mux_tmp_142, mux_257_cse, and_305_cse);
  assign mux_161_nl = MUX_s_1_2_2(mux_160_nl, mux_158_nl, LOAD_LOOP_or_tmp_1);
  assign mux_162_nl = MUX_s_1_2_2(mux_161_nl, and_tmp_65, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_156_nl = MUX_s_1_2_2(and_tmp_50, and_tmp_65, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_163_nl = MUX_s_1_2_2(mux_162_nl, mux_156_nl, or_339_cse);
  assign mux_164_nl = MUX_s_1_2_2(mux_291_cse, mux_163_nl, main_stage_en_4);
  assign mux_165_nl = MUX_s_1_2_2(and_65_nl, mux_164_nl, main_stage_v_1);
  assign conf_info_rsci_iswt0_mx0c1 = and_231_cse | (mux_165_nl & or_dcpl_3 & and_dcpl_3
      & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1);
  assign plm_in_rsc_req_obj_iswt0_mx0c1 = ((~(dma_read_ctrl_rsci_bawt & dma_read_ctrl_rsci_irdy_mxwt))
      | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 | or_122_cse) & or_dcpl_3 & plm_in_rsc_req_obj_bawt
      & exit_LOAD_CTRL_LOOP_sva_st_1 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1) &
      and_dcpl_17;
  assign and_178_nl = (LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 | exitL_exit_LOAD_BATCH_LOOP_sva
      | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 | (~ (LOAD_LOOP_acc_1_tmp[7])) | (~ lfst_exit_LOAD_LOOP_lpi_1_1)
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1) & or_tmp_181;
  assign nor_87_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ mux_tmp_174));
  assign nor_88_nl = ~(dma_read_ctrl_rsci_irdy_mxwt | (~ and_tmp_64));
  assign mux_270_nl = MUX_s_1_2_2(nor_88_nl, and_tmp_63, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_271_nl = MUX_s_1_2_2(nor_87_nl, mux_270_nl, LOAD_LOOP_or_tmp_1);
  assign mux_272_nl = MUX_s_1_2_2(mux_tmp_174, mux_271_nl, LOAD_LOOP_acc_1_tmp[7]);
  assign mux_273_nl = MUX_s_1_2_2(mux_272_nl, or_tmp_181, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_274_nl = MUX_s_1_2_2(mux_273_nl, mux_tmp_230, or_339_cse);
  assign mux_275_nl = MUX_s_1_2_2(and_178_nl, mux_274_nl, main_stage_v_1);
  assign LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1 = mux_275_nl & or_dcpl_3 & or_60_cse;
  assign lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1 = and_269_cse | (and_dcpl_101
      & (~ LOAD_BATCH_LOOP_acc_itm_32_1) & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1);
  assign LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1 = (and_dcpl_91 & or_60_cse
      & (fsm_output[1])) | (and_dcpl_101 & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1);
  assign or_416_nl = dma_read_ctrl_rsci_bawt | and_dcpl_44;
  assign or_415_nl = or_tmp_25 | and_dcpl_44;
  assign mux_323_nl = MUX_s_1_2_2(or_416_nl, or_415_nl, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign or_417_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | mux_323_nl;
  assign mux_324_nl = MUX_s_1_2_2(and_dcpl_44, or_417_nl, main_stage_v_1);
  assign main_stage_v_2_mx0c1 = (~ mux_324_nl) & or_dcpl_3 & main_stage_v_2;
  assign and_220_nl = lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 & and_tmp_63;
  assign mux_330_nl = MUX_s_1_2_2(and_220_nl, or_tmp_181, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign exit_LOAD_CTRL_LOOP_sva_st_1_mx0c1 = mux_330_nl & or_dcpl_3 & main_stage_v_1;
  assign main_stage_v_3_mx0c1 = (and_dcpl_44 | (~ main_stage_v_2)) & or_dcpl_2 &
      main_stage_v_3;
  assign exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1 = and_dcpl_47 & and_dcpl_46;
  assign plm_in_rsci_d_d = LOAD_LOOP_data_ac_mux_rmff;
  assign plm_in_rsci_wadr_d = LOAD_LOOP_i_mux_rmff;
  assign plm_in_rsci_we_d_pff = plm_in_rsci_we_d_iff;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_iswt0 <= 1'b0;
    end
    else if ( core_wen & (or_tmp_366 | conf_info_rsci_iswt0_mx0c1) ) begin
      conf_info_rsci_iswt0 <= (~ conf_info_rsci_iswt0_mx0c1) | or_tmp_366;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (or_tmp_366 | and_231_cse) ) begin
      conf_info_rsci_irdy_core_psct <= (~ and_231_cse) | or_tmp_366;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_LOAD_BATCH_LOOP_sva <= 1'b1;
    end
    else if ( core_wen & (~(or_dcpl_4 | and_dcpl_8 | (fsm_output[0]))) ) begin
      exitL_exit_LOAD_BATCH_LOOP_sva <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_idat_10_7 <= 4'b0000;
    end
    else if ( core_wen & (~((~ mux_199_cse) | and_dcpl_10 | and_dcpl_8 | (fsm_output[0])))
        ) begin
      dma_read_ctrl_rsci_idat_10_7 <= LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsc_req_obj_iswt0 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_15 & dma_read_ctrl_rsci_bawt & dma_read_ctrl_rsci_irdy_mxwt
        & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1) & and_dcpl_11) | plm_in_rsc_req_obj_iswt0_mx0c1)
        ) begin
      plm_in_rsc_req_obj_iswt0 <= ~ plm_in_rsc_req_obj_iswt0_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_in_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_dma_read_chnl_rsci_oswt_cse <= 1'b0;
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      plm_in_rsci_wadr_d_reg <= 7'b0000000;
      plm_in_rsci_d_d_reg <= 32'b00000000000000000000000000000000;
      LOAD_LOOP_i_7_0_lpi_1_6_0 <= 7'b0000000;
      lfst_exit_LOAD_LOOP_lpi_1_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_0 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_plm_in_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_15 & and_dcpl_30 & (~ LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)
          & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 & main_stage_v_1;
      reg_dma_read_chnl_rsci_oswt_cse <= and_133_rmff;
      reg_dma_read_ctrl_rsci_ivld_core_psct_cse <= mux_199_cse & or_dcpl_3 & or_60_cse
          & (fsm_output[1]);
      plm_in_rsci_wadr_d_reg <= LOAD_LOOP_i_mux_rmff;
      plm_in_rsci_d_d_reg <= LOAD_LOOP_data_ac_mux_rmff;
      LOAD_LOOP_i_7_0_lpi_1_6_0 <= MUX_v_7_2_2(LOAD_LOOP_i_7_0_lpi_1_6_0_mx0w0, LOAD_LOOP_i_7_0_lpi_1_6_0,
          or_300_nl);
      lfst_exit_LOAD_LOOP_lpi_1_1 <= lfst_exit_LOAD_LOOP_lpi_1_1_mx0;
      lfst_exit_LOAD_LOOP_lpi_1_0 <= lfst_exit_LOAD_LOOP_lpi_1_0_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_40 & main_stage_v_2 & exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2)
        | and_dcpl_45) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_45;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_49 | and_dcpl_52) ) begin
      reg_dma_read_chnl_rsci_irdy_core_psct_cse <= (~ and_dcpl_52) | and_dcpl_49;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_asn_itm <= 1'b1;
    end
    else if ( core_wen & ((main_stage_en_4 & (fsm_output[1])) | (main_stage_v_1 &
        main_stage_en_4)) ) begin
      LOAD_BATCH_LOOP_asn_itm <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( core_wen & (and_255_cse | (mux_261_nl & or_dcpl_3 & or_60_cse & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1)
        | and_dcpl_49) ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3 <= MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4,
          LOAD_LOOP_mux_20_nl, and_dcpl_49);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((mux_269_nl & or_dcpl_3 & or_60_cse & (LOAD_LOOP_acc_1_tmp[7])
        & (~ exit_LOAD_BATCH_LOOP_lpi_1_dfm_3) & (~ exitL_exit_LOAD_BATCH_LOOP_sva))
        | LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1) ) begin
      LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0 <= MUX_v_4_2_2((LOAD_BATCH_LOOP_acc_1_tmp[3:0]),
          LOAD_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_mx0w0, LOAD_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_88 | and_dcpl_66) ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1 <= MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1,
          (~ (LOAD_LOOP_acc_1_tmp[7])), and_dcpl_66);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_lpi_1_dfm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & exitL_exit_LOAD_BATCH_LOOP_sva ) begin
      batch_lpi_1_dfm <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_66 & (fsm_output[1])) | and_dcpl_88) ) begin
      main_stage_v_1 <= ~ and_dcpl_88;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else if ( core_wen & (((~ main_stage_v_1) & and_dcpl_89 & and_dcpl_46) | and_dcpl_91)
        ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1,
          exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, and_dcpl_91);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_or_tmp_1 <= 1'b0;
      LOAD_LOOP_equal_tmp_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_15_cse ) begin
      LOAD_LOOP_or_tmp_1 <= (lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0))
          | (~(lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0 | lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0));
      LOAD_LOOP_equal_tmp_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0 & (~ lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0);
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_1_0 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
    end
    else if ( core_wen & (~((~ mux_296_nl) | and_dcpl_10)) ) begin
      LOAD_LOOP_i_7_0_sva_1_1_6_0 <= LOAD_LOOP_acc_1_tmp[6:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_49 | and_255_cse | and_dcpl_88) ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 <= MUX1HOT_s_1_3_2((LOAD_LOOP_acc_1_tmp[7]),
          LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm, exitL_exit_LOAD_LOOP_lpi_1_dfm_mx0w0,
          {and_dcpl_49 , and_255_cse , and_dcpl_88});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 <= 1'b0;
    end
    else if ( core_wen & (and_267_cse | (mux_311_nl & or_dcpl_3 & or_60_cse & LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1)
        | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1) ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1 <= MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0,
          lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0 <= 1'b0;
    end
    else if ( core_wen & (and_267_cse | and_269_cse) ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0 <= MUX_s_1_2_2(lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0,
          lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0, and_269_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_89 & or_60_cse & and_dcpl_46) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1)
        ) begin
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= MUX_s_1_2_2(LOAD_BATCH_LOOP_if_mux_2_nl,
          exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_69 & main_stage_v_1) | main_stage_v_2_mx0c1)
        ) begin
      main_stage_v_2 <= ~ main_stage_v_2_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_CTRL_LOOP_sva_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_58 | exit_LOAD_CTRL_LOOP_sva_st_1_mx0c1) ) begin
      exit_LOAD_CTRL_LOOP_sva_st_1 <= MUX_s_1_2_2(dma_read_ctrl_rsci_irdy_mxwt, exit_LOAD_CTRL_LOOP_sva_st,
          exit_LOAD_CTRL_LOOP_sva_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0 <= 1'b0;
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= 1'b0;
    end
    else if ( LOAD_LOOP_i_and_1_cse ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_2 <= LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_2_0 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_0;
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2 <= 1'b0;
    end
    else if ( core_wen & (~((~ or_tmp_181) | and_dcpl_10)) ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2 <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_40 & main_stage_v_2) | main_stage_v_3_mx0c1)
        ) begin
      main_stage_v_3 <= ~ main_stage_v_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 <= 1'b0;
    end
    else if ( core_wen & (~(and_dcpl_44 | and_dcpl_10 | (~ main_stage_v_2))) ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_3 <= exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_CTRL_LOOP_sva_st <= 1'b0;
    end
    else if ( LOAD_CTRL_LOOP_and_2_cse & (~((~ main_stage_v_1) | LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
        | lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1)) ) begin
      exit_LOAD_CTRL_LOOP_sva_st <= dma_read_ctrl_rsci_irdy_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0 <= 1'b0;
    end
    else if ( LOAD_LOOP_and_18_cse ) begin
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_LOAD_LOOP_lpi_1_dfm_st_0 <= lfst_exit_LOAD_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_74 | exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1)
        ) begin
      exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1 <= MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4,
          LOAD_LOOP_mux_6_nl, exit_LOAD_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm <= 1'b0;
    end
    else if ( LOAD_CTRL_LOOP_and_2_cse & (~(mux_340_nl | and_dcpl_10 | or_tmp_1))
        ) begin
      LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm <= LOAD_LOOP_acc_1_tmp[7];
    end
  end
  assign or_300_nl = (~ mux_tmp_174) | or_dcpl_26;
  assign LOAD_LOOP_mux_20_nl = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, (LOAD_BATCH_LOOP_acc_1_tmp[4]),
      LOAD_LOOP_acc_1_tmp[7]);
  assign nor_73_nl = ~(LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ mux_tmp_142));
  assign mux_258_nl = MUX_s_1_2_2(nor_73_nl, mux_tmp_142, and_316_cse);
  assign mux_259_nl = MUX_s_1_2_2(mux_258_nl, mux_257_cse, LOAD_LOOP_or_tmp_1);
  assign mux_260_nl = MUX_s_1_2_2(mux_259_nl, mux_tmp_142, or_339_cse);
  assign mux_261_nl = MUX_s_1_2_2(mux_260_nl, mux_13_cse, or_122_cse);
  assign nor_89_nl = ~(LOAD_LOOP_i_slc_LOAD_LOOP_i_7_0_7_itm_1 | (~ lfst_exit_LOAD_LOOP_lpi_1_1)
      | LOAD_BATCH_LOOP_if_asn_sft_lpi_1 | (~ or_tmp_181));
  assign and_174_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & mux_tmp_174;
  assign mux_268_nl = MUX_s_1_2_2(and_174_nl, mux_tmp_196, LOAD_LOOP_or_tmp_1);
  assign nor_90_nl = ~(or_93_cse | (~ mux_268_nl));
  assign mux_269_nl = MUX_s_1_2_2(nor_89_nl, nor_90_nl, main_stage_v_1);
  assign mux_296_nl = MUX_s_1_2_2(or_tmp_181, mux_tmp_174, main_stage_v_1);
  assign mux_311_nl = MUX_s_1_2_2(and_tmp_98, mux_tmp_296, main_stage_v_1);
  assign LOAD_BATCH_LOOP_if_mux_2_nl = MUX_s_1_2_2(LOAD_BATCH_LOOP_if_asn_sft_lpi_1,
      LOAD_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1, main_stage_v_1);
  assign LOAD_LOOP_mux_6_nl = MUX_s_1_2_2(exit_LOAD_BATCH_LOOP_lpi_1_dfm_4, (LOAD_BATCH_LOOP_acc_1_tmp[4]),
      LOAD_LOOP_acc_1_tmp[7]);
  assign and_295_nl = LOAD_BATCH_LOOP_if_asn_sft_lpi_1 & (~(and_316_cse | (~((lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1
      | dma_read_ctrl_rsci_bawt) & or_tmp_181))));
  assign mux_338_nl = MUX_s_1_2_2(and_tmp_71, or_tmp_181, lfst_exit_LOAD_LOOP_lpi_1_dfm_st_1_1);
  assign mux_339_nl = MUX_s_1_2_2(and_295_nl, mux_338_nl, LOAD_LOOP_or_tmp_1);
  assign or_438_nl = or_93_cse | (~ mux_339_nl);
  assign mux_340_nl = MUX_s_1_2_2(or_tmp_207, or_438_nl, main_stage_v_1);

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


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [6:0] signext_7_1;
    input [0:0] vector;
  begin
    signext_7_1= {{6{vector[0]}}, vector};
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


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_req_vz,
      plm_in_rsc_rls_lz, plm_out_rsc_req_vz, plm_out_rsc_rls_lz, done_rsc_rdy, done_rsc_vld,
      plm_in_rsci_q_d, plm_in_rsci_radr_d, plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      plm_out_rsci_d_d, plm_out_rsci_wadr_d, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      CALC_SOFTMAX_LOOP_mul_cmp_b, CALC_SOFTMAX_LOOP_mul_cmp_en, CALC_SOFTMAX_LOOP_mul_cmp_z,
      plm_out_rsci_we_d_pff, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;
  input done_rsc_rdy;
  output done_rsc_vld;
  input [31:0] plm_in_rsci_q_d;
  output [6:0] plm_in_rsci_radr_d;
  output plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output [31:0] plm_out_rsci_d_d;
  output [6:0] plm_out_rsci_wadr_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d;
  output [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output [93:0] CALC_SOFTMAX_LOOP_mul_cmp_b;
  output CALC_SOFTMAX_LOOP_mul_cmp_en;
  input [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  output plm_out_rsci_we_d_pff;
  output [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  wire conf_info_rsci_ivld;
  wire conf_info_rsci_ivld_oreg;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_in_rsci_bawt;
  wire [31:0] plm_in_rsci_q_d_mxwt;
  wire plm_out_rsci_bawt;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  wire plm_out_rsc_rls_obj_bawt;
  wire plm_in_rsc_rls_obj_bawt;
  wire plm_in_rsc_req_obj_bawt;
  reg plm_in_rsc_req_obj_iswt0;
  wire plm_in_rsc_req_obj_wen_comp;
  wire plm_out_rsc_req_obj_bawt;
  reg plm_out_rsc_req_obj_iswt0;
  wire plm_out_rsc_req_obj_wen_comp;
  wire [1:0] fsm_output;
  wire [7:0] CALC_SOFTMAX_LOOP_acc_1_tmp;
  wire [8:0] nl_CALC_SOFTMAX_LOOP_acc_1_tmp;
  wire COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
  wire and_29_tmp;
  wire and_27_tmp;
  wire [7:0] SUM_EXP_LOOP_acc_2_tmp;
  wire [8:0] nl_SUM_EXP_LOOP_acc_2_tmp;
  wire [7:0] CALC_EXP_LOOP_acc_1_tmp;
  wire [8:0] nl_CALC_EXP_LOOP_acc_1_tmp;
  wire or_tmp_3;
  wire and_tmp;
  wire or_tmp_4;
  wire or_tmp_117;
  wire or_tmp_132;
  wire mux_tmp_64;
  wire and_dcpl_9;
  wire or_tmp_273;
  wire or_dcpl_5;
  wire or_dcpl_6;
  wire and_dcpl_13;
  wire and_dcpl_15;
  wire and_dcpl_17;
  wire and_dcpl_19;
  wire and_dcpl_22;
  wire and_dcpl_28;
  wire and_dcpl_29;
  wire or_dcpl_11;
  wire and_dcpl_33;
  wire or_tmp_300;
  wire mux_tmp_151;
  wire mux_tmp_153;
  wire mux_tmp_155;
  wire mux_tmp_157;
  wire and_dcpl_48;
  wire and_dcpl_54;
  wire and_dcpl_57;
  wire and_dcpl_61;
  wire and_dcpl_64;
  wire and_dcpl_65;
  wire or_dcpl_23;
  wire and_dcpl_84;
  wire or_dcpl_29;
  wire or_dcpl_30;
  wire and_dcpl_93;
  wire or_dcpl_40;
  wire and_dcpl_133;
  wire mux_tmp_171;
  wire and_dcpl_143;
  wire or_tmp_318;
  wire mux_tmp_172;
  wire or_dcpl_62;
  wire or_dcpl_64;
  wire mux_tmp_173;
  wire and_dcpl_161;
  wire and_tmp_79;
  wire and_dcpl_232;
  wire and_dcpl_237;
  wire or_dcpl_77;
  wire or_tmp_336;
  wire and_495_cse;
  wire and_493_cse;
  wire and_531_cse;
  wire [4:0] COMPUTE_LOOP_b_4_0_sva_2;
  wire [5:0] nl_COMPUTE_LOOP_b_4_0_sva_2;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0;
  reg exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1;
  reg main_stage_v_13;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12;
  reg main_stage_v_12;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14;
  reg main_stage_v_14;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1;
  wire CALC_SOFTMAX_LOOP_equal_tmp_3;
  wire CALC_SOFTMAX_LOOP_and_2_ssc_1;
  wire CALC_SOFTMAX_LOOP_and_3_ssc_1;
  wire CALC_SOFTMAX_LOOP_equal_tmp_2;
  wire CALC_EXP_LOOP_and_svs_1;
  wire CALC_SOFTMAX_LOOP_or_tmp_1;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_mx0w0;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  wire [74:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6;
  reg main_stage_v_6;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13;
  reg main_stage_v_3;
  reg main_stage_v_2;
  reg CALC_EXP_LOOP_and_svs_st_2;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1;
  reg main_stage_v_4;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1;
  reg main_stage_v_5;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1;
  reg CALC_EXP_LOOP_and_svs_st_5;
  reg CALC_EXP_LOOP_and_svs_st_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0;
  reg COMPUTE_LOOP_if_and_9_itm_6;
  reg main_stage_v_7;
  reg COMPUTE_LOOP_if_and_9_itm_7;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1;
  reg main_stage_v_8;
  reg main_stage_v_9;
  reg main_stage_v_10;
  reg main_stage_v_11;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0;
  reg CALC_SOFTMAX_LOOP_or_1_tmp_4;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4;
  reg CALC_SOFTMAX_LOOP_or_1_tmp_3;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5;
  reg CALC_SOFTMAX_LOOP_or_1_tmp_5;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0;
  reg exitL_exit_COMPUTE_LOOP_sva;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3;
  reg COMPUTE_LOOP_asn_itm;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1;
  reg CALC_EXP_LOOP_and_svs_st_1;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_12;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13;
  wire COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx0;
  reg reg_conf_info_rsci_iswt0_cse;
  reg reg_plm_in_rsc_rls_obj_ld_core_psct_cse;
  reg reg_plm_out_rsc_rls_obj_ld_core_psct_cse;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_plm_out_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse;
  reg reg_plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  wire CALC_EXP_LOOP_and_1_cse;
  wire CALC_SOFTMAX_LOOP_and_20_cse;
  wire CALC_SOFTMAX_LOOP_i_and_cse;
  wire CALC_SOFTMAX_LOOP_and_23_cse;
  wire CALC_SOFTMAX_LOOP_and_25_cse;
  wire COMPUTE_LOOP_and_cse;
  wire or_413_cse;
  wire or_131_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse;
  wire CALC_EXP_LOOP_i_and_cse;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_1_cse;
  wire or_414_cse;
  wire or_264_cse;
  wire [31:0] mux_16_cse;
  wire nor_74_cse;
  wire and_593_cse;
  wire and_592_cse;
  wire or_483_cse;
  wire and_475_cse;
  wire COMPUTE_LOOP_if_asn_sft_lpi_1_mx0;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse;
  wire and_102_cse;
  wire mux_148_cse;
  wire or_232_cse;
  wire nand_cse;
  reg [6:0] plm_in_rsci_radr_d_reg;
  wire [6:0] CALC_EXP_LOOP_i_mux_rmff;
  wire plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_467_rmff;
  reg [31:0] plm_out_rsci_d_d_reg;
  wire [31:0] CALC_SOFTMAX_LOOP_mux_rmff;
  reg [6:0] plm_out_rsci_wadr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_rmff;
  wire plm_out_rsci_we_d_iff;
  wire and_166_rmff;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1;
  wire [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1;
  reg [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4;
  reg [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1;
  wire [93:0] operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [72:0] operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1;
  reg [31:0] batch_lpi_1_dfm;
  reg main_stage_v_1;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st;
  reg CALC_EXP_LOOP_and_svs_st;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm;
  reg [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4;
  reg COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2;
  reg CALC_SOFTMAX_LOOP_or_1_tmp_1;
  reg CALC_SOFTMAX_LOOP_or_1_tmp_2;
  reg [31:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1;
  reg [4:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg [9:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1;
  reg [6:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_2;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_12;
  reg COMPUTE_LOOP_if_and_9_itm_1;
  reg COMPUTE_LOOP_if_and_9_itm_2;
  reg COMPUTE_LOOP_if_and_9_itm_3;
  reg COMPUTE_LOOP_if_and_9_itm_4;
  reg COMPUTE_LOOP_if_and_9_itm_5;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9;
  reg lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10;
  reg CALC_EXP_LOOP_and_svs_st_3;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_2;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_3;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_4;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_5;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_6;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_7;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_8;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_9;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_10;
  reg CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_11;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11;
  reg exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12;
  reg [3:0] COMPUTE_LOOP_b_4_0_lpi_1_3_0;
  reg [6:0] CALC_EXP_LOOP_i_7_0_lpi_1_6_0;
  reg [6:0] SUM_EXP_LOOP_i_7_0_lpi_1_6_0;
  reg [6:0] CALC_SOFTMAX_LOOP_i_7_0_lpi_1_6_0;
  reg [6:0] CALC_EXP_LOOP_i_7_0_lpi_1_dfm_1_6_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_0;
  wire plm_out_rsc_req_obj_iswt0_mx0c1;
  wire plm_in_rsc_req_obj_iswt0_mx0c1;
  wire main_stage_v_2_mx0c1;
  wire main_stage_v_3_mx0c1;
  wire main_stage_v_4_mx0c1;
  wire main_stage_v_5_mx0c1;
  wire main_stage_v_6_mx0c1;
  wire main_stage_v_7_mx0c1;
  wire main_stage_v_8_mx0c1;
  wire main_stage_v_9_mx0c1;
  wire main_stage_v_10_mx0c1;
  wire main_stage_v_11_mx0c1;
  wire main_stage_v_12_mx0c1;
  wire main_stage_v_13_mx0c1;
  wire main_stage_v_14_mx0c1;
  wire exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1;
  wire exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1;
  wire main_stage_v_1_mx0c1;
  wire CALC_EXP_LOOP_and_svs_st_1_mx0c1;
  wire [6:0] CALC_EXP_LOOP_i_7_0_lpi_1_dfm_6_0_mx1w0;
  wire COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1_mx0c1;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_mx0w0;
  wire [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0;
  wire [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire [8:0] nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c0;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c1;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c2;
  wire [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
  wire CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1_mx0c1;
  wire exit_COMPUTE_LOOP_lpi_1_dfm_4;
  wire [3:0] COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1;
  wire or_88_cse_1;
  wire or_51_cse_1;
  wire or_52_cse_1;
  wire or_66_cse_1;
  wire or_5_cse_1;
  wire or_6_cse_1;
  wire or_cse_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [6:0] libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1;
  wire and_432_rgt;
  wire and_436_rgt;
  wire CALC_SOFTMAX_LOOP_and_33_cse;
  wire ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse;
  wire CALC_SOFTMAX_LOOP_and_40_cse;
  wire CALC_SOFTMAX_LOOP_and_45_cse;
  reg [73:0] reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse;
  wire CALC_SOFTMAX_LOOP_i_and_7_itm;
  wire COMPUTE_LOOP_acc_itm_32_1;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1;

  wire[0:0] mux_176_nl;
  wire[0:0] mux_175_nl;
  wire[0:0] or_400_nl;
  wire[0:0] mux_156_nl;
  wire[0:0] or_364_nl;
  wire[0:0] or_533_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_19_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_53_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_i_and_5_nl;
  wire[0:0] and_256_nl;
  wire[6:0] CALC_SOFTMAX_LOOP_i_mux_16_nl;
  wire[0:0] mux_195_nl;
  wire[0:0] mux_194_nl;
  wire[0:0] and_434_nl;
  wire[0:0] or_172_nl;
  wire[0:0] or_165_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_13_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_27_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_18_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_52_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_COMPUTE_LOOP_not_4_nl;
  wire[0:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_nl;
  wire[0:0] COMPUTE_LOOP_if_and_1_nl;
  wire[73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_mux_3_nl;
  wire[32:0] COMPUTE_LOOP_acc_nl;
  wire[33:0] nl_COMPUTE_LOOP_acc_nl;
  wire[0:0] COMPUTE_LOOP_not_12_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_50_nl;
  wire[6:0] COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_2_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_COMPUTE_LOOP_not_nl;
  wire[46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire signed [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire[0:0] nor_58_nl;
  wire[0:0] or_230_nl;
  wire[0:0] mux_167_nl;
  wire[0:0] or_320_nl;
  wire[0:0] mux_169_nl;
  wire[0:0] or_314_nl;
  wire[0:0] mux_171_nl;
  wire[0:0] or_297_nl;
  wire[0:0] mux_173_nl;
  wire[0:0] or_270_nl;
  wire[0:0] mux_126_nl;
  wire[0:0] and_87_nl;
  wire[0:0] or_467_nl;
  wire[0:0] and_75_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] or_372_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] and_573_nl;
  wire[0:0] mux_180_nl;
  wire[0:0] and_568_nl;
  wire[0:0] nor_72_nl;
  wire[0:0] mux_183_nl;
  wire[0:0] nor_71_nl;
  wire[0:0] and_424_nl;
  wire[0:0] or_490_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_nl;

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
  wire [6:0] nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_s;
  assign nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_s = CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
  wire [72:0] nl_operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg_a;
  assign nl_operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg_a = reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[72:0];
  wire [0:0] nl_compute_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg;
  assign nl_compute_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg = and_dcpl_9
      & (fsm_output[1]);
  wire [0:0] nl_compute_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg;
  assign nl_compute_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg = and_dcpl_13
      & or_414_cse & and_592_cse & nor_74_cse;
  wire [0:0] nl_compute_core_plm_out_rsci_1_inst_plm_out_rsci_oswt_unreg;
  assign nl_compute_core_plm_out_rsci_1_inst_plm_out_rsci_oswt_unreg = or_dcpl_6
      & or_413_cse & and_dcpl_54 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13) &
      plm_out_rsci_bawt & main_stage_v_13;
  wire [0:0] nl_compute_core_plm_out_rsc_rls_obj_inst_plm_out_rsc_rls_obj_oswt_unreg;
  assign nl_compute_core_plm_out_rsc_rls_obj_inst_plm_out_rsc_rls_obj_oswt_unreg
      = or_dcpl_6 & and_dcpl_54 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13) & plm_out_rsci_bawt
      & plm_out_rsc_rls_obj_bawt & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13
      & main_stage_v_13;
  wire [0:0] nl_compute_core_plm_in_rsc_rls_obj_inst_plm_in_rsc_rls_obj_oswt_unreg;
  assign nl_compute_core_plm_in_rsc_rls_obj_inst_plm_in_rsc_rls_obj_oswt_unreg =
      and_dcpl_13 & and_592_cse & plm_in_rsc_rls_obj_bawt & CALC_EXP_LOOP_and_svs_st_2
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1) & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2);
  wire [0:0] nl_compute_core_plm_in_rsc_req_obj_inst_plm_in_rsc_req_obj_oswt_unreg;
  assign nl_compute_core_plm_in_rsc_req_obj_inst_plm_in_rsc_req_obj_oswt_unreg =
      and_dcpl_29 & (fsm_output[1]);
  wire [0:0] nl_compute_core_plm_out_rsc_req_obj_inst_plm_out_rsc_req_obj_oswt_unreg;
  assign nl_compute_core_plm_out_rsc_req_obj_inst_plm_out_rsc_req_obj_oswt_unreg
      = and_dcpl_19 & and_dcpl_17;
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
      .s(nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_s[6:0]),
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
      .mantissa(reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse),
      .rtn(libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1)
    );
  esp_acc_softmax_cxx_compute_core_wait_dp compute_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg)
    );
  esp_acc_softmax_cxx_compute_core_conf_info_rsci compute_core_conf_info_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(nl_compute_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg[0:0]),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(reg_conf_info_rsci_iswt0_cse),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsci_1 compute_core_plm_in_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsci_q_d(plm_in_rsci_q_d),
      .plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsci_oswt_unreg(nl_compute_core_plm_in_rsci_1_inst_plm_in_rsci_oswt_unreg[0:0]),
      .plm_in_rsci_bawt(plm_in_rsci_bawt),
      .plm_in_rsci_iswt0(reg_plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .plm_in_rsci_q_d_mxwt(plm_in_rsci_q_d_mxwt),
      .plm_in_rsci_iswt0_pff(and_467_rmff)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsci_1 compute_core_plm_out_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsci_oswt_unreg(nl_compute_core_plm_out_rsci_1_inst_plm_out_rsci_oswt_unreg[0:0]),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_iswt0(reg_plm_out_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse),
      .plm_out_rsci_we_d_pff(plm_out_rsci_we_d_iff),
      .plm_out_rsci_iswt0_pff(and_166_rmff)
    );
  esp_acc_softmax_cxx_compute_core_done_rsci compute_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_64),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_rls_obj compute_core_plm_out_rsc_rls_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_oswt_unreg(nl_compute_core_plm_out_rsc_rls_obj_inst_plm_out_rsc_rls_obj_oswt_unreg[0:0]),
      .plm_out_rsc_rls_obj_bawt(plm_out_rsc_rls_obj_bawt),
      .plm_out_rsc_rls_obj_iswt0(reg_plm_out_rsc_rls_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_rls_obj compute_core_plm_in_rsc_rls_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_rsc_rls_obj_oswt_unreg(nl_compute_core_plm_in_rsc_rls_obj_inst_plm_in_rsc_rls_obj_oswt_unreg[0:0]),
      .plm_in_rsc_rls_obj_bawt(plm_in_rsc_rls_obj_bawt),
      .plm_in_rsc_rls_obj_iswt0(reg_plm_in_rsc_rls_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_compute_core_plm_in_rsc_req_obj compute_core_plm_in_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .core_wen(core_wen),
      .plm_in_rsc_req_obj_oswt_unreg(nl_compute_core_plm_in_rsc_req_obj_inst_plm_in_rsc_req_obj_oswt_unreg[0:0]),
      .plm_in_rsc_req_obj_bawt(plm_in_rsc_req_obj_bawt),
      .plm_in_rsc_req_obj_iswt0(plm_in_rsc_req_obj_iswt0),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_plm_out_rsc_req_obj compute_core_plm_out_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .core_wen(core_wen),
      .plm_out_rsc_req_obj_oswt_unreg(nl_compute_core_plm_out_rsc_req_obj_inst_plm_out_rsc_req_obj_oswt_unreg[0:0]),
      .plm_out_rsc_req_obj_bawt(plm_out_rsc_req_obj_bawt),
      .plm_out_rsc_req_obj_iswt0(plm_out_rsc_req_obj_iswt0),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_staller compute_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .plm_in_rsc_req_obj_wen_comp(plm_in_rsc_req_obj_wen_comp),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_compute_core_core_fsm compute_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d
      = and_dcpl_13 & and_dcpl_57 & (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0));
  assign mux_175_nl = MUX_s_1_2_2(mux_tmp_157, (~ mux_148_cse), lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1);
  assign or_400_nl = (~ main_stage_v_11) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0;
  assign mux_176_nl = MUX_s_1_2_2(mux_175_nl, mux_tmp_157, or_400_nl);
  assign CALC_SOFTMAX_LOOP_mul_cmp_en = or_264_cse & or_131_cse & (~ mux_176_nl)
      & (fsm_output[1]);
  assign COMPUTE_LOOP_and_cse = core_wen & (~((~ and_29_tmp) | (fsm_output[0])));
  assign and_166_rmff = and_dcpl_48 & and_dcpl_15 & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0);
  assign or_413_cse = plm_out_rsc_rls_obj_bawt | (~ CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13);
  assign and_467_rmff = and_dcpl_28 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1)
      & (fsm_output[1]);
  assign or_414_cse = plm_in_rsc_rls_obj_bawt | (~ CALC_EXP_LOOP_and_svs_st_2);
  assign nor_74_cse = ~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2);
  assign CALC_SOFTMAX_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_12,
      plm_out_rsci_wadr_d_reg, or_dcpl_30);
  assign CALC_SOFTMAX_LOOP_mux_rmff = MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[94:63]),
      plm_out_rsci_d_d_reg, or_dcpl_30);
  assign or_533_nl = (~ and_27_tmp) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1
      | (fsm_output[0]);
  assign CALC_EXP_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_1_dfm_1_6_0,
      plm_in_rsci_radr_d_reg, or_533_nl);
  assign and_475_cse = and_29_tmp & (fsm_output[1]);
  assign CALC_EXP_LOOP_and_1_cse = core_wen & (~((~ and_27_tmp) | (fsm_output[0])));
  assign CALC_SOFTMAX_LOOP_and_33_cse = core_wen & (~ or_dcpl_40);
  assign or_131_cse = (~ main_stage_v_12) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12
      | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12 | plm_out_rsc_req_obj_bawt;
  assign CALC_SOFTMAX_LOOP_and_20_cse = core_wen & (~((~ and_tmp) | and_dcpl_22 |
      (~ main_stage_v_11)));
  assign CALC_SOFTMAX_LOOP_i_and_cse = core_wen & (~(or_dcpl_29 | (~((~(and_dcpl_84
      & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12))) & main_stage_v_12))));
  assign CALC_SOFTMAX_LOOP_and_23_cse = core_wen & mux_tmp_171 & and_29_tmp;
  assign CALC_SOFTMAX_LOOP_i_and_7_itm = core_wen & and_29_tmp;
  assign CALC_EXP_LOOP_i_and_cse = core_wen & (~ (fsm_output[0]));
  assign or_232_cse = COMPUTE_LOOP_COMPUTE_LOOP_or_tmp | (~ mux_tmp_64);
  assign CALC_SOFTMAX_LOOP_and_25_cse = core_wen & (and_495_cse | and_493_cse);
  assign mux_16_cse = MUX_v_32_2_2(batch_lpi_1_dfm, conf_info_rsci_idat_mxwt, exitL_exit_COMPUTE_LOOP_sva);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse
      = ~((ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1[11:10]!=2'b00)
      | or_dcpl_40);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1[11:10]==2'b01)
      & (~ or_dcpl_40);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1[11:10]==2'b10)
      & (~ or_dcpl_40);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse
      = (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1[11:10]==2'b11)
      & (~ or_dcpl_40);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
      = core_wen & (ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse
      | ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse);
  assign or_264_cse = (~ main_stage_v_14) | (~ exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14)
      | done_rsci_bawt;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      = core_wen & (and_tmp_79 | and_dcpl_237);
  assign mux_194_nl = MUX_s_1_2_2(mux_tmp_64, (~ mux_tmp_64), COMPUTE_LOOP_COMPUTE_LOOP_or_tmp);
  assign mux_195_nl = MUX_s_1_2_2(or_tmp_273, mux_194_nl, COMPUTE_LOOP_acc_itm_32_1);
  assign CALC_SOFTMAX_LOOP_and_40_cse = CALC_EXP_LOOP_i_and_cse & (~(mux_195_nl |
      (~ and_29_tmp)));
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_1_cse = core_wen
      & (~((~(or_264_cse & or_131_cse & or_483_cse & mux_148_cse)) | (~ main_stage_v_5)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1
      | (~ CALC_EXP_LOOP_and_svs_st_5)));
  assign and_432_rgt = and_dcpl_13 & or_dcpl_77;
  assign CALC_SOFTMAX_LOOP_and_45_cse = core_wen & and_27_tmp;
  assign and_436_rgt = and_dcpl_13 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1);
  assign or_172_nl = (~ main_stage_v_13) | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1)
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13;
  assign or_165_nl = plm_out_rsc_rls_obj_bawt | (~ CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13)
      | (~ main_stage_v_13) | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1) |
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13;
  assign mux_148_cse = MUX_s_1_2_2(or_172_nl, or_165_nl, plm_out_rsci_bawt);
  assign and_102_cse = or_264_cse & or_131_cse & mux_148_cse;
  assign CALC_SOFTMAX_LOOP_mux_52_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      (COMPUTE_LOOP_b_4_0_sva_2[4]), CALC_SOFTMAX_LOOP_acc_1_tmp[7]);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_18_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_mux_52_nl, CALC_SOFTMAX_LOOP_equal_tmp_2);
  assign exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1 = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_18_nl, mux_tmp_171);
  assign COMPUTE_LOOP_if_asn_sft_lpi_1_mx0 = MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1,
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1, and_27_tmp);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_COMPUTE_LOOP_not_4_nl
      = ~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
  assign CALC_EXP_LOOP_i_7_0_lpi_1_dfm_6_0_mx1w0 = MUX_v_7_2_2(7'b0000000, CALC_EXP_LOOP_i_7_0_lpi_1_6_0,
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_COMPUTE_LOOP_not_4_nl);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_nl = ~(CALC_SOFTMAX_LOOP_or_1_tmp_5
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5);
  assign COMPUTE_LOOP_if_and_1_nl = CALC_SOFTMAX_LOOP_or_1_tmp_5 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_mx0w0
      = MUX1HOT_v_74_3_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1,
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1,
      {COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5 , COMPUTE_LOOP_if_COMPUTE_LOOP_if_nor_nl
      , COMPUTE_LOOP_if_and_1_nl});
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_mx0w0
      + conv_u2u_67_74(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0[73:0];
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_mux_3_nl
      = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_mx0w0,
      main_stage_v_5);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_mx0w0
      = MUX_v_74_2_2(74'b00000000000000000000000000000000000000000000000000000000000000000000000000,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_mux_3_nl,
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0
      = MUX_v_10_8_2(10'b1111111101, 10'b1100011001, 10'b1001100100, 10'b0111010000,
      10'b0101010100, 10'b0011101011, 10'b0010010001, 10'b0001000100, operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]);
  assign nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0
      = ({1'b1 , (~ libraries_leading_sign_74_0_516239036a4348f23734e51cfda27e0bbee5_1)})
      + 8'b00110111;
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0
      = nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0[7:0];
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0
      = MUX_v_8_8_2(8'b00011100, 8'b01001011, 8'b01101100, 8'b10000100, 8'b10010111,
      8'b10100110, 8'b10110011, 8'b10111100, operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0
      = ~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1,
      94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3);
  assign exit_COMPUTE_LOOP_lpi_1_dfm_4 = (~ COMPUTE_LOOP_acc_itm_32_1) & COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
  assign CALC_SOFTMAX_LOOP_equal_tmp_2 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1
      & (~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0
      & (~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp);
  assign nl_COMPUTE_LOOP_acc_nl = ({29'b10000000000000000000000000000 , COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1})
      + conv_u2u_32_33(~ mux_16_cse) + 33'b000000000000000000000000000000001;
  assign COMPUTE_LOOP_acc_nl = nl_COMPUTE_LOOP_acc_nl[32:0];
  assign COMPUTE_LOOP_acc_itm_32_1 = readslicef_33_1_32(COMPUTE_LOOP_acc_nl);
  assign COMPUTE_LOOP_not_12_nl = ~ exitL_exit_COMPUTE_LOOP_sva;
  assign COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1 = MUX_v_4_2_2(4'b0000, COMPUTE_LOOP_b_4_0_lpi_1_3_0,
      COMPUTE_LOOP_not_12_nl);
  assign nl_COMPUTE_LOOP_b_4_0_sva_2 = conv_u2u_4_5(COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1)
      + 5'b00001;
  assign COMPUTE_LOOP_b_4_0_sva_2 = nl_COMPUTE_LOOP_b_4_0_sva_2[4:0];
  assign nl_CALC_SOFTMAX_LOOP_acc_1_tmp = conv_u2u_7_8(CALC_SOFTMAX_LOOP_i_7_0_lpi_1_6_0)
      + 8'b00000001;
  assign CALC_SOFTMAX_LOOP_acc_1_tmp = nl_CALC_SOFTMAX_LOOP_acc_1_tmp[7:0];
  assign COMPUTE_LOOP_COMPUTE_LOOP_or_tmp = exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm
      | exit_COMPUTE_LOOP_lpi_1_dfm_3 | exitL_exit_COMPUTE_LOOP_sva;
  assign COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx0 = MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_mx0,
      exit_COMPUTE_LOOP_lpi_1_dfm_4, COMPUTE_LOOP_COMPUTE_LOOP_or_tmp);
  assign and_29_tmp = (conf_info_rsci_bawt | (~ COMPUTE_LOOP_asn_itm)) & or_88_cse_1
      & or_51_cse_1 & or_52_cse_1 & or_66_cse_1 & or_5_cse_1 & or_6_cse_1 & or_cse_1;
  assign or_88_cse_1 = plm_in_rsc_req_obj_bawt | (~((~(lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1)) & main_stage_v_1));
  assign or_51_cse_1 = plm_in_rsci_bawt | (~(nor_74_cse & main_stage_v_2));
  assign or_52_cse_1 = plm_in_rsc_rls_obj_bawt | (~(CALC_EXP_LOOP_and_svs_st_2 &
      ((lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1))
      | (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0)))
      & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2) & main_stage_v_2));
  assign or_66_cse_1 = plm_out_rsc_req_obj_bawt | (~((~(lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12)) & main_stage_v_12));
  assign or_5_cse_1 = plm_out_rsci_bawt | (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0) & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13)
      & main_stage_v_13));
  assign or_6_cse_1 = plm_out_rsc_rls_obj_bawt | (~(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0)
      & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13) & main_stage_v_13));
  assign or_cse_1 = done_rsci_bawt | (~(exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 & main_stage_v_14));
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = conv_u2u_19_19(({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
      , 1'b0 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1})
      * ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1);
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = $signed(({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1}))
      * $signed(conv_u2s_10_11(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:0];
  assign CALC_SOFTMAX_LOOP_or_tmp_1 = (lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1)) | (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1));
  assign CALC_SOFTMAX_LOOP_equal_tmp_3 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1;
  assign CALC_SOFTMAX_LOOP_mux_50_nl = MUX_s_1_2_2((~ (CALC_SOFTMAX_LOOP_acc_1_tmp[7])),
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1, CALC_SOFTMAX_LOOP_equal_tmp_3);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1 = (CALC_SOFTMAX_LOOP_mux_50_nl
      & (~ CALC_SOFTMAX_LOOP_and_2_ssc_1)) | CALC_SOFTMAX_LOOP_and_3_ssc_1;
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1 = (lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1
      & (~(CALC_SOFTMAX_LOOP_and_3_ssc_1 | CALC_SOFTMAX_LOOP_equal_tmp_2))) | CALC_SOFTMAX_LOOP_and_2_ssc_1;
  assign CALC_EXP_LOOP_and_svs_1 = (CALC_EXP_LOOP_acc_1_tmp[7]) & (SUM_EXP_LOOP_acc_2_tmp[7]);
  assign nl_CALC_EXP_LOOP_acc_1_tmp = conv_u2u_7_8(CALC_EXP_LOOP_i_7_0_lpi_1_dfm_6_0_mx1w0)
      + 8'b00000001;
  assign CALC_EXP_LOOP_acc_1_tmp = nl_CALC_EXP_LOOP_acc_1_tmp[7:0];
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_COMPUTE_LOOP_not_nl
      = ~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_2_nl = MUX_v_7_2_2(7'b0000000, SUM_EXP_LOOP_i_7_0_lpi_1_6_0,
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_COMPUTE_LOOP_not_nl);
  assign nl_SUM_EXP_LOOP_acc_2_tmp = conv_u2u_7_8(COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_2_nl)
      + 8'b00000001;
  assign SUM_EXP_LOOP_acc_2_tmp = nl_SUM_EXP_LOOP_acc_2_tmp[7:0];
  assign CALC_SOFTMAX_LOOP_and_2_ssc_1 = (~ CALC_EXP_LOOP_and_svs_1) & CALC_SOFTMAX_LOOP_or_tmp_1;
  assign CALC_SOFTMAX_LOOP_and_3_ssc_1 = CALC_EXP_LOOP_and_svs_1 & CALC_SOFTMAX_LOOP_or_tmp_1;
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = $signed(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1)
      * $signed(16'b0101110001010101);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl[46:0];
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1
      = readslicef_47_19_28(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl);
  assign and_27_tmp = main_stage_v_1 & or_88_cse_1 & or_51_cse_1 & or_52_cse_1 &
      or_66_cse_1 & or_5_cse_1 & or_6_cse_1 & or_cse_1;
  assign or_tmp_3 = (or_413_cse & plm_out_rsci_bawt) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13
      | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0;
  assign nand_cse = ~(main_stage_v_13 & (~ or_tmp_3));
  assign and_tmp = or_131_cse & nand_cse;
  assign or_tmp_4 = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1;
  assign or_tmp_117 = lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12 | plm_out_rsc_req_obj_bawt;
  assign or_tmp_132 = exit_COMPUTE_LOOP_lpi_1_dfm_3 | exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm;
  assign and_593_cse = COMPUTE_LOOP_acc_itm_32_1 & and_29_tmp;
  assign nor_58_nl = ~(and_27_tmp | (~ COMPUTE_LOOP_if_asn_sft_lpi_1));
  assign or_230_nl = COMPUTE_LOOP_if_asn_sft_lpi_1 | and_27_tmp;
  assign mux_tmp_64 = MUX_s_1_2_2(nor_58_nl, or_230_nl, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign and_592_cse = main_stage_v_2 & plm_in_rsci_bawt;
  assign and_dcpl_9 = and_29_tmp & COMPUTE_LOOP_asn_itm;
  assign or_tmp_273 = COMPUTE_LOOP_COMPUTE_LOOP_or_tmp | mux_tmp_64;
  assign or_dcpl_5 = done_rsci_bawt | (~ exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14);
  assign or_dcpl_6 = or_dcpl_5 | (~ main_stage_v_14);
  assign and_dcpl_13 = and_tmp & or_dcpl_6;
  assign and_dcpl_15 = (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12) & main_stage_v_12;
  assign and_dcpl_17 = plm_out_rsc_req_obj_bawt & (~ lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12)
      & and_dcpl_15;
  assign and_dcpl_19 = nand_cse & or_dcpl_6;
  assign and_dcpl_22 = (~ done_rsci_bawt) & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 &
      main_stage_v_14;
  assign and_dcpl_28 = and_27_tmp & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_dcpl_29 = and_dcpl_28 & (~ lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1);
  assign or_dcpl_11 = ~(COMPUTE_LOOP_acc_itm_32_1 & and_29_tmp);
  assign and_dcpl_33 = ~(exit_COMPUTE_LOOP_lpi_1_dfm_3 | exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm);
  assign or_tmp_300 = (~ main_stage_v_6) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0 | (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1
      & mux_148_cse));
  assign mux_167_nl = MUX_s_1_2_2(or_tmp_300, (~ mux_148_cse), lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1);
  assign or_320_nl = (~ main_stage_v_7) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0;
  assign mux_tmp_151 = MUX_s_1_2_2(mux_167_nl, or_tmp_300, or_320_nl);
  assign mux_169_nl = MUX_s_1_2_2(mux_tmp_151, (~ mux_148_cse), lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1);
  assign or_314_nl = (~ main_stage_v_8) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0;
  assign mux_tmp_153 = MUX_s_1_2_2(mux_169_nl, mux_tmp_151, or_314_nl);
  assign mux_171_nl = MUX_s_1_2_2(mux_tmp_153, (~ mux_148_cse), lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1);
  assign or_297_nl = (~ main_stage_v_9) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0;
  assign mux_tmp_155 = MUX_s_1_2_2(mux_171_nl, mux_tmp_153, or_297_nl);
  assign mux_173_nl = MUX_s_1_2_2(mux_tmp_155, (~ mux_148_cse), lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1);
  assign or_270_nl = (~ main_stage_v_10) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0;
  assign mux_tmp_157 = MUX_s_1_2_2(mux_173_nl, mux_tmp_155, or_270_nl);
  assign and_dcpl_48 = and_dcpl_19 & or_tmp_117;
  assign and_dcpl_54 = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1;
  assign and_dcpl_57 = main_stage_v_5 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5);
  assign and_dcpl_61 = or_tmp_3 & or_dcpl_6;
  assign and_dcpl_64 = done_rsci_bawt & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 & main_stage_v_14;
  assign and_dcpl_65 = (~(or_tmp_3 & main_stage_v_13 & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13))
      & and_dcpl_64;
  assign or_dcpl_23 = ~(main_stage_v_7 & COMPUTE_LOOP_if_and_9_itm_7);
  assign and_dcpl_84 = ~(plm_out_rsc_req_obj_bawt | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12);
  assign or_dcpl_29 = ((~(((~((~ plm_out_rsc_rls_obj_bawt) & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13))
      & plm_out_rsci_bawt) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0)) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1
      & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13) & main_stage_v_13) | and_dcpl_22;
  assign or_dcpl_30 = or_dcpl_29 | and_dcpl_84 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12
      | (~ main_stage_v_12) | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1) |
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0;
  assign and_87_nl = or_414_cse & plm_in_rsci_bawt & and_tmp;
  assign mux_126_nl = MUX_s_1_2_2(and_87_nl, and_tmp, or_tmp_4);
  assign and_dcpl_93 = mux_126_nl & or_dcpl_6;
  assign or_dcpl_40 = (~ and_tmp) | and_dcpl_22;
  assign and_dcpl_133 = and_dcpl_19 & (or_tmp_117 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12);
  assign mux_tmp_171 = MUX_s_1_2_2((~ or_tmp_273), or_232_cse, COMPUTE_LOOP_acc_itm_32_1);
  assign and_dcpl_143 = (~ exitL_exit_COMPUTE_LOOP_sva) & and_29_tmp;
  assign or_tmp_318 = or_tmp_132 | mux_tmp_64;
  assign or_467_nl = or_tmp_132 | (~ mux_tmp_64);
  assign mux_tmp_172 = MUX_s_1_2_2((~ or_tmp_318), or_467_nl, COMPUTE_LOOP_acc_itm_32_1);
  assign or_dcpl_62 = exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm | exitL_exit_COMPUTE_LOOP_sva;
  assign or_dcpl_64 = mux_tmp_64 | exit_COMPUTE_LOOP_lpi_1_dfm_3;
  assign and_75_nl = COMPUTE_LOOP_acc_itm_32_1 & COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
  assign mux_tmp_173 = MUX_s_1_2_2(mux_tmp_171, and_75_nl, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1);
  assign and_dcpl_161 = and_dcpl_33 & and_dcpl_143;
  assign or_483_cse = (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000);
  assign and_tmp_79 = or_264_cse & or_131_cse & or_483_cse & mux_148_cse;
  assign and_dcpl_232 = ~((reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[2:1]!=2'b00));
  assign and_dcpl_237 = ~((~ and_dcpl_13) | (~ and_dcpl_232) | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[3])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[4])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[5])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[6])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[7])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[8])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[9])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[10])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[11])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[12])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[13])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[14])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[15])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[16])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[17])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[18])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[19])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[20])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[21])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[22])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[23])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[24])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[25])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[26])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[27])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[28])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[29])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[30])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[31])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[32])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[33])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[34])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[35])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[36])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[37])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[38])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[39])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[40])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[41])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[42])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[43])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[44])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[45])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[46])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[47])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[48])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[49])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[50])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[51])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[52])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[53])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[54])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[55])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[56])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[57])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[58])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[59])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[60])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[61])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[62])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[63])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[64])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[65])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[66])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[67])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[68])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[69])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[70])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[71])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[72])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[73])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[0]));
  assign or_dcpl_77 = COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4 | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1
      | (~ CALC_EXP_LOOP_and_svs_st_4);
  assign or_372_nl = COMPUTE_LOOP_acc_itm_32_1 | (~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp);
  assign mux_159_nl = MUX_s_1_2_2((~ or_232_cse), or_tmp_273, COMPUTE_LOOP_acc_itm_32_1);
  assign and_573_nl = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0) & (COMPUTE_LOOP_b_4_0_sva_2[4])
      & (CALC_SOFTMAX_LOOP_acc_1_tmp[7]) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1;
  assign mux_160_nl = MUX_s_1_2_2(or_372_nl, mux_159_nl, and_573_nl);
  assign or_tmp_336 = (mux_160_nl | (~ and_29_tmp)) & and_dcpl_9 & (fsm_output[1]);
  assign and_493_cse = (~ mux_tmp_171) & and_29_tmp & (fsm_output[1]);
  assign and_495_cse = mux_tmp_171 & and_29_tmp & (fsm_output[1]);
  assign and_531_cse = COMPUTE_LOOP_COMPUTE_LOOP_or_tmp & and_29_tmp & (fsm_output[1]);
  assign plm_out_rsc_req_obj_iswt0_mx0c1 = and_dcpl_19 & and_dcpl_17 & ((~ main_stage_v_11)
      | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11 | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11);
  assign plm_in_rsc_req_obj_iswt0_mx0c1 = (((~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp)
      | or_dcpl_11) & and_dcpl_29 & (fsm_output[1])) | ((and_dcpl_33 | or_dcpl_11)
      & and_dcpl_28 & (~(lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 | exitL_exit_COMPUTE_LOOP_sva)));
  assign main_stage_v_2_mx0c1 = and_dcpl_93 & main_stage_v_2 & (~ and_27_tmp);
  assign and_568_nl = (~(or_414_cse & plm_in_rsci_bawt & main_stage_v_2)) & and_tmp;
  assign nor_72_nl = ~(main_stage_v_2 | (~ and_tmp));
  assign mux_180_nl = MUX_s_1_2_2(and_568_nl, nor_72_nl, or_tmp_4);
  assign main_stage_v_3_mx0c1 = mux_180_nl & or_dcpl_6 & main_stage_v_3;
  assign main_stage_v_4_mx0c1 = and_dcpl_13 & main_stage_v_4 & (~ main_stage_v_3);
  assign main_stage_v_5_mx0c1 = and_dcpl_13 & main_stage_v_5 & (~ main_stage_v_4);
  assign main_stage_v_6_mx0c1 = and_dcpl_13 & (~ main_stage_v_5) & main_stage_v_6;
  assign main_stage_v_7_mx0c1 = and_dcpl_13 & main_stage_v_7 & (~ main_stage_v_6);
  assign main_stage_v_8_mx0c1 = and_dcpl_13 & main_stage_v_8 & (~ main_stage_v_7);
  assign main_stage_v_9_mx0c1 = and_dcpl_13 & main_stage_v_9 & (~ main_stage_v_8);
  assign main_stage_v_10_mx0c1 = and_dcpl_13 & main_stage_v_10 & (~ main_stage_v_9);
  assign main_stage_v_11_mx0c1 = and_dcpl_13 & main_stage_v_11 & (~ main_stage_v_10);
  assign main_stage_v_12_mx0c1 = and_dcpl_133 & main_stage_v_12 & (~ main_stage_v_11);
  assign nor_71_nl = ~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12 | lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12
      | plm_out_rsc_req_obj_bawt | (~ or_tmp_3));
  assign mux_183_nl = MUX_s_1_2_2(or_tmp_3, nor_71_nl, main_stage_v_12);
  assign main_stage_v_13_mx0c1 = mux_183_nl & or_dcpl_6 & main_stage_v_13;
  assign main_stage_v_14_mx0c1 = (~(or_tmp_3 & main_stage_v_13)) & or_dcpl_5 & main_stage_v_14;
  assign exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1 = and_495_cse | (mux_tmp_172 & and_dcpl_143);
  assign main_stage_v_1_mx0c1 = and_27_tmp & (~ and_29_tmp) & (fsm_output[1]);
  assign CALC_EXP_LOOP_and_svs_st_1_mx0c1 = ((~ mux_tmp_173) & and_29_tmp & (fsm_output[1]))
      | ((~(COMPUTE_LOOP_COMPUTE_LOOP_or_tmp & COMPUTE_LOOP_acc_itm_32_1)) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1
      & and_29_tmp);
  assign COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1_mx0c1 = and_531_cse | (or_tmp_132 &
      and_dcpl_143);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c0
      = and_tmp_79 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c1
      = ~((~ and_dcpl_13) | (~ and_dcpl_232) | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[3])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[4])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[5])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[6])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[7])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[8])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[9])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[10])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[11])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[12])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[13])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[14])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[15])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[16])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[17])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[18])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[19])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[20])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[21])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[22])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[23])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[24])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[25])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[26])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[27])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[28])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[29])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[30])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[31])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[32])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[33])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[34])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[35])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[36])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[37])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[38])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[39])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[40])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[41])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[42])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[43])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[44])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[45])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[46])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[47])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[48])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[49])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[50])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[51])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[52])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[53])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[54])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[55])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[56])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[57])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[58])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[59])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[60])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[61])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[62])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[63])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[64])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[65])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[66])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[67])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[68])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[69])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[70])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[71])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[72])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[73])
      | (reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse[0])
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1);
  assign and_424_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 & and_102_cse;
  assign or_490_nl = lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 | (~ and_102_cse);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c2
      = MUX_s_1_2_2(and_424_nl, or_490_nl, lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1);
  assign CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1_mx0c1 = ((or_dcpl_64
      | or_dcpl_62 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0)
      & and_29_tmp & (fsm_output[1])) | (lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0 & and_29_tmp);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_nl
      = (~ or_dcpl_23) & (fsm_output[1]);
  assign CALC_SOFTMAX_LOOP_mul_cmp_b = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_nl);
  assign plm_in_rsci_radr_d = CALC_EXP_LOOP_i_mux_rmff;
  assign plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_rsci_d_d = CALC_SOFTMAX_LOOP_mux_rmff;
  assign plm_out_rsci_wadr_d = CALC_SOFTMAX_LOOP_i_mux_rmff;
  assign plm_out_rsci_we_d_pff = plm_out_rsci_we_d_iff;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d
      = operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff
      = CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
      = and_dcpl_13 & and_dcpl_57 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d
      = and_dcpl_13 & and_dcpl_57 & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_conf_info_rsci_iswt0_cse <= 1'b0;
    end
    else if ( core_wen & (((~ mux_156_nl) & and_29_tmp) | (fsm_output[0]) | or_tmp_336)
        ) begin
      reg_conf_info_rsci_iswt0_cse <= ~ or_tmp_336;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_COMPUTE_LOOP_sva <= 1'b1;
      exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_or_1_tmp_1 <= 1'b0;
      COMPUTE_LOOP_if_and_9_itm_1 <= 1'b0;
    end
    else if ( COMPUTE_LOOP_and_cse ) begin
      exitL_exit_COMPUTE_LOOP_sva <= exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1;
      exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm <= (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1
          | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1)) | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1 <= ~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
      CALC_SOFTMAX_LOOP_or_1_tmp_1 <= CALC_SOFTMAX_LOOP_equal_tmp_2 | CALC_SOFTMAX_LOOP_equal_tmp_3;
      COMPUTE_LOOP_if_and_9_itm_1 <= CALC_EXP_LOOP_and_svs_1 & (~(CALC_SOFTMAX_LOOP_equal_tmp_2
          | CALC_SOFTMAX_LOOP_equal_tmp_3)) & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx0);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsc_req_obj_iswt0 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_11 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11)
        & (~ lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11)) | plm_out_rsc_req_obj_iswt0_mx0c1)
        ) begin
      plm_out_rsc_req_obj_iswt0 <= ~ plm_out_rsc_req_obj_iswt0_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_rsc_req_obj_iswt0 <= 1'b0;
    end
    else if ( core_wen & ((COMPUTE_LOOP_COMPUTE_LOOP_or_tmp & and_593_cse & (fsm_output[1]))
        | (or_tmp_132 & (~ exitL_exit_COMPUTE_LOOP_sva) & and_593_cse) | plm_in_rsc_req_obj_iswt0_mx0c1)
        ) begin
      plm_in_rsc_req_obj_iswt0 <= ~ plm_in_rsc_req_obj_iswt0_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_in_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_plm_out_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_plm_out_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse <= 1'b0;
      reg_plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= 1'b0;
      plm_out_rsci_wadr_d_reg <= 7'b0000000;
      plm_out_rsci_d_d_reg <= 32'b00000000000000000000000000000000;
      plm_in_rsci_radr_d_reg <= 7'b0000000;
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1 <= 67'b0000000000000000000000000000000000000000000000000000000000000000000;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4 <= 7'b0000000;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0 <= 1'b0;
      COMPUTE_LOOP_if_and_9_itm_7 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_12 <= 7'b0000000;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1 <= 1'b0;
      batch_lpi_1_dfm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen ) begin
      reg_plm_in_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_28 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1)
          & CALC_EXP_LOOP_and_svs_st_1;
      reg_plm_out_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_48 & and_dcpl_15 & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1
          & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0) & CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_12;
      reg_plm_out_rsci_writeA_w_ram_ir_internal_WMASK_B_d_core_psct_cse <= and_166_rmff;
      reg_plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= and_467_rmff;
      plm_out_rsci_wadr_d_reg <= CALC_SOFTMAX_LOOP_i_mux_rmff;
      plm_out_rsci_d_d_reg <= CALC_SOFTMAX_LOOP_mux_rmff;
      plm_in_rsci_radr_d_reg <= CALC_EXP_LOOP_i_mux_rmff;
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1 <= MUX_v_67_2_2(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_mx0w0,
          operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1, or_dcpl_40);
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3,
          CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_5,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6, or_dcpl_40);
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= MUX_s_1_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3,
          or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0, or_dcpl_40);
      COMPUTE_LOOP_if_and_9_itm_7 <= MUX_s_1_2_2(COMPUTE_LOOP_if_and_9_itm_6, COMPUTE_LOOP_if_and_9_itm_7,
          or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_6,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_7,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_8,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_9,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_10,
          COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11, or_dcpl_40);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_12 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_12, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1, or_dcpl_40);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0, or_dcpl_40);
      COMPUTE_LOOP_if_asn_sft_lpi_1 <= COMPUTE_LOOP_if_asn_sft_lpi_1_mx0;
      batch_lpi_1_dfm <= mux_16_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_61 & main_stage_v_13 & exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13)
        | and_dcpl_65) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_65;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_asn_itm <= 1'b1;
    end
    else if ( core_wen & and_475_cse ) begin
      COMPUTE_LOOP_asn_itm <= exit_COMPUTE_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ and_tmp) | and_dcpl_22 | or_dcpl_23)) ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1
          <= ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_1_dfm_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((and_27_tmp & (fsm_output[1])) | main_stage_v_2_mx0c1)
        ) begin
      main_stage_v_2 <= ~ main_stage_v_2_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st_2 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= 1'b0;
    end
    else if ( CALC_EXP_LOOP_and_1_cse ) begin
      CALC_EXP_LOOP_and_svs_st_2 <= CALC_EXP_LOOP_and_svs_st_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_93 & main_stage_v_2) | main_stage_v_3_mx0c1)
        ) begin
      main_stage_v_3 <= ~ main_stage_v_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_4 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4 <= 1'b0;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      CALC_EXP_LOOP_and_svs_st_5 <= 1'b0;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= 94'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_12 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_3 <= 1'b0;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3 <= 7'b0000000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1
          <= 10'b0000000000;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      COMPUTE_LOOP_if_and_9_itm_6 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_or_1_tmp_5 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_11 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_or_1_tmp_4 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3 <= 1'b0;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= 7'b0000000;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1
          <= 32'b00000000000000000000000000000000;
      COMPUTE_LOOP_if_and_9_itm_5 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_10 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_or_1_tmp_3 <= 1'b0;
      COMPUTE_LOOP_if_and_9_itm_4 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_9 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10 <= 1'b0;
      COMPUTE_LOOP_if_and_9_itm_3 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_8 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_7 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_6 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_5 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_4 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_3 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_33_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_2;
      CALC_EXP_LOOP_and_svs_st_4 <= CALC_EXP_LOOP_and_svs_st_3;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_3;
      reg_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_st_1_cse
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_mx0w0;
      CALC_EXP_LOOP_and_svs_st_5 <= CALC_EXP_LOOP_and_svs_st_4;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_12 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_11;
      CALC_EXP_LOOP_and_svs_st_3 <= CALC_EXP_LOOP_and_svs_st_2;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1
          <= ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1[9:0];
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_4 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      COMPUTE_LOOP_if_and_9_itm_6 <= COMPUTE_LOOP_if_and_9_itm_5;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_5 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4;
      CALC_SOFTMAX_LOOP_or_1_tmp_5 <= CALC_SOFTMAX_LOOP_or_1_tmp_4;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_dfm_mx0w0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_10 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_11 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_10;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_4 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3;
      CALC_SOFTMAX_LOOP_or_1_tmp_4 <= CALC_SOFTMAX_LOOP_or_1_tmp_3;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1
          <= plm_in_rsci_q_d_mxwt;
      COMPUTE_LOOP_if_and_9_itm_5 <= COMPUTE_LOOP_if_and_9_itm_4;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_9 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_10 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_9;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_11 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_3 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2;
      CALC_SOFTMAX_LOOP_or_1_tmp_3 <= CALC_SOFTMAX_LOOP_or_1_tmp_2;
      COMPUTE_LOOP_if_and_9_itm_4 <= COMPUTE_LOOP_if_and_9_itm_3;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_8 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_9 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_8;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_10 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9;
      COMPUTE_LOOP_if_and_9_itm_3 <= COMPUTE_LOOP_if_and_9_itm_2;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_7 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_8 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_7;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_9 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_6 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7 <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1[6:0];
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_7 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_6;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_8 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_5 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_6 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_5;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_7 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_5 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_4;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_6 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_4 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_3;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_5 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_2;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_3 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_2;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_4 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_3 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_3) | main_stage_v_4_mx0c1)
        ) begin
      main_stage_v_4 <= ~ main_stage_v_4_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_5 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_4) | main_stage_v_5_mx0c1)
        ) begin
      main_stage_v_5 <= ~ main_stage_v_5_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_6 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_5) | main_stage_v_6_mx0c1)
        ) begin
      main_stage_v_6 <= ~ main_stage_v_6_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_7 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_6) | main_stage_v_7_mx0c1)
        ) begin
      main_stage_v_7 <= ~ main_stage_v_7_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_8 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_7) | main_stage_v_8_mx0c1)
        ) begin
      main_stage_v_8 <= ~ main_stage_v_8_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_9 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_8) | main_stage_v_9_mx0c1)
        ) begin
      main_stage_v_9 <= ~ main_stage_v_9_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_10 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_9) | main_stage_v_10_mx0c1)
        ) begin
      main_stage_v_10 <= ~ main_stage_v_10_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_11 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_10) | main_stage_v_11_mx0c1)
        ) begin
      main_stage_v_11 <= ~ main_stage_v_11_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_12 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & main_stage_v_11) | main_stage_v_12_mx0c1)
        ) begin
      main_stage_v_12 <= ~ main_stage_v_12_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_20_cse ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_11;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_11;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_13 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_133 & main_stage_v_12) | main_stage_v_13_mx0c1)
        ) begin
      main_stage_v_13 <= ~ main_stage_v_13_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 <= 1'b0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_i_and_cse ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_13 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_12;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_13_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_12_0;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_13 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_12;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_29) ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_12;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_14 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_61 & main_stage_v_13) | main_stage_v_14_mx0c1)
        ) begin
      main_stage_v_14 <= ~ main_stage_v_14_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 <= 1'b0;
    end
    else if ( core_wen & (~((~ or_tmp_3) | and_dcpl_22 | (~ main_stage_v_13))) )
        begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_14 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_13;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_23_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_1_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_3_0_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( core_wen & (and_493_cse | ((~ mux_tmp_172) & and_dcpl_143) | exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1)
        ) begin
      exit_COMPUTE_LOOP_lpi_1_dfm_3 <= MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
          CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_19_nl, exit_COMPUTE_LOOP_lpi_1_dfm_3_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_7_0_lpi_1_6_0 <= 7'b0000000;
      COMPUTE_LOOP_b_4_0_lpi_1_3_0 <= 4'b0000;
      SUM_EXP_LOOP_i_7_0_lpi_1_6_0 <= 7'b0000000;
      CALC_EXP_LOOP_i_7_0_lpi_1_6_0 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1 <= 7'b0000000;
    end
    else if ( CALC_SOFTMAX_LOOP_i_and_7_itm ) begin
      CALC_SOFTMAX_LOOP_i_7_0_lpi_1_6_0 <= MUX_v_7_2_2((signext_7_1(~ CALC_EXP_LOOP_and_svs_1)),
          (CALC_SOFTMAX_LOOP_acc_1_tmp[6:0]), CALC_SOFTMAX_LOOP_i_and_5_nl);
      COMPUTE_LOOP_b_4_0_lpi_1_3_0 <= MUX_v_4_2_2((COMPUTE_LOOP_b_4_0_sva_2[3:0]),
          COMPUTE_LOOP_b_4_0_lpi_1_dfm_3_0_1, and_256_nl);
      SUM_EXP_LOOP_i_7_0_lpi_1_6_0 <= SUM_EXP_LOOP_acc_2_tmp[6:0];
      CALC_EXP_LOOP_i_7_0_lpi_1_6_0 <= CALC_EXP_LOOP_acc_1_tmp[6:0];
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1 <= CALC_SOFTMAX_LOOP_i_7_0_lpi_1_6_0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_1 <= 1'b0;
    end
    else if ( core_wen & (and_475_cse | main_stage_v_1_mx0c1) ) begin
      main_stage_v_1 <= ~ main_stage_v_1_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st_1 <= 1'b0;
    end
    else if ( core_wen & ((mux_tmp_173 & and_29_tmp & (fsm_output[1])) | (COMPUTE_LOOP_COMPUTE_LOOP_or_tmp
        & COMPUTE_LOOP_acc_itm_32_1 & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1 & and_29_tmp)
        | CALC_EXP_LOOP_and_svs_st_1_mx0c1) ) begin
      CALC_EXP_LOOP_and_svs_st_1 <= MUX_s_1_2_2(CALC_EXP_LOOP_and_svs_1, CALC_EXP_LOOP_and_svs_st,
          CALC_EXP_LOOP_and_svs_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_i_7_0_lpi_1_dfm_1_6_0 <= 7'b0000000;
    end
    else if ( CALC_EXP_LOOP_i_and_cse ) begin
      CALC_EXP_LOOP_i_7_0_lpi_1_dfm_1_6_0 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_1_dfm_1_6_0,
          CALC_EXP_LOOP_i_7_0_lpi_1_dfm_6_0_mx1w0, and_29_tmp);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_25_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1, and_493_cse);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_0, and_493_cse);
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= MUX_s_1_2_2((~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp),
          lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st, and_493_cse);
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1 <= MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
          CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_13_nl, and_495_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_161 | COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1_mx0c1)
        ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_mx0,
          exit_COMPUTE_LOOP_lpi_1_dfm_4, COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_161 | and_531_cse) ) begin
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= MUX_s_1_2_2(COMPUTE_LOOP_if_asn_sft_lpi_1_mx0,
          exit_COMPUTE_LOOP_lpi_1_dfm_4, and_531_cse);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
    end
    else if ( core_wen & (~((~ and_tmp) | and_dcpl_22 | (~ main_stage_v_5))) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_1_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= 3'b000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= 7'b0000000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= 5'b00000;
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= 3'b000;
    end
    else if ( ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_cse
        ) begin
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1
          <= MUX1HOT_v_3_4_2(3'b011, 3'b100, 3'b101, 3'b110, {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse});
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1
          <= MUX1HOT_v_7_4_2(7'b1111110, 7'b1000000, 7'b0100110, 7'b0110111, {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse});
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX1HOT_v_5_4_2(5'b01100, 5'b01110, 5'b10001, 5'b10100, {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse});
      ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= MUX1HOT_v_3_4_2(3'b010, 3'b110, 3'b001, 3'b101, {ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_12_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_13_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_14_cse
          , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_and_15_cse});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= 10'b0000000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= 8'b00000000;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1
          <= 10'b0000000000;
    end
    else if ( ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1
          <= MUX_v_10_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm,
          and_dcpl_237);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
          <= MUX_v_8_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm_mx0w0,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm,
          and_dcpl_237);
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm_1
          <= MUX_v_10_2_2((operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[69:60]),
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm,
          and_dcpl_237);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= 8'b00000000;
    end
    else if ( core_wen & (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c0
        | ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c1
        | ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c2)
        ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1 <= MUX1HOT_v_8_3_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm, ({1'b0
          , CALC_SOFTMAX_LOOP_i_mux_16_nl}), {ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c0
          , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c1
          , ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1_mx0c2});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_0 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_40_cse ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st <= ~ COMPUTE_LOOP_COMPUTE_LOOP_or_tmp;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_0_1;
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
    else if ( ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_1_cse
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
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_13 & (~(COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_st_4
        | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_4_1)) & CALC_EXP_LOOP_and_svs_st_4)
        | and_432_rgt) ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= MUX_s_1_2_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm,
          and_432_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st <= 1'b0;
    end
    else if ( CALC_EXP_LOOP_i_and_cse & mux_tmp_173 & and_29_tmp ) begin
      CALC_EXP_LOOP_and_svs_st <= CALC_EXP_LOOP_and_svs_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2 <= 1'b0;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= 7'b0000000;
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_or_1_tmp_2 <= 1'b0;
      COMPUTE_LOOP_if_and_9_itm_2 <= 1'b0;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_2 <= 7'b0000000;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_2 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_45_cse ) begin
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_2 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_1;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_1_dfm_1_6_0,
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1, and_434_nl);
      COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_2 <= COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_1;
      CALC_SOFTMAX_LOOP_or_1_tmp_2 <= CALC_SOFTMAX_LOOP_or_1_tmp_1;
      COMPUTE_LOOP_if_and_9_itm_2 <= COMPUTE_LOOP_if_and_9_itm_1;
      lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_2 <= lfst_exitL_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_2 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_1_itm_1;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_2 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1;
      exit_COMPUTE_LOOP_lpi_1_dfm_3_st_2 <= exit_COMPUTE_LOOP_lpi_1_dfm_3_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= 1'b0;
    end
    else if ( core_wen & (~((~ and_tmp) | and_dcpl_22 | (~ main_stage_v_4) | or_dcpl_77))
        ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= 7'b0000000;
    end
    else if ( core_wen & ((and_dcpl_13 & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_3_1)
        | and_436_rgt) ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_4 <= MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_3,
          (ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28_1[18:12]),
          and_436_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1 <= 1'b0;
    end
    else if ( core_wen & (((~ or_tmp_318) & (~ exitL_exit_COMPUTE_LOOP_sva) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1
        & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0) & and_29_tmp) | CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1_mx0c1)
        ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1 <= MUX_s_1_2_2((CALC_SOFTMAX_LOOP_acc_1_tmp[7]),
          CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm, CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm <= 1'b0;
    end
    else if ( CALC_EXP_LOOP_i_and_cse & (~(or_tmp_318 | exitL_exit_COMPUTE_LOOP_sva
        | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0
        | (~ and_29_tmp))) ) begin
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_7_itm <= CALC_SOFTMAX_LOOP_acc_1_tmp[7];
    end
  end
  assign or_364_nl = (~((COMPUTE_LOOP_b_4_0_sva_2[4]) & (CALC_SOFTMAX_LOOP_acc_1_tmp[7])
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_0)))
      | COMPUTE_LOOP_if_asn_sft_lpi_1_mx0;
  assign mux_156_nl = MUX_s_1_2_2(or_364_nl, COMPUTE_LOOP_acc_itm_32_1, COMPUTE_LOOP_COMPUTE_LOOP_or_tmp);
  assign CALC_SOFTMAX_LOOP_mux_53_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      (COMPUTE_LOOP_b_4_0_sva_2[4]), CALC_SOFTMAX_LOOP_acc_1_tmp[7]);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_19_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_mux_53_nl, CALC_SOFTMAX_LOOP_equal_tmp_2);
  assign CALC_SOFTMAX_LOOP_i_and_5_nl = CALC_SOFTMAX_LOOP_equal_tmp_2 & (~ COMPUTE_LOOP_if_asn_sft_lpi_1_dfm_mx0)
      & and_29_tmp;
  assign and_256_nl = (or_dcpl_64 | or_dcpl_62 | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_1)
      | (~ (CALC_SOFTMAX_LOOP_acc_1_tmp[7]))) & and_29_tmp;
  assign CALC_SOFTMAX_LOOP_mux_27_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      (COMPUTE_LOOP_b_4_0_sva_2[4]), CALC_SOFTMAX_LOOP_acc_1_tmp[7]);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_mux_13_nl = MUX_s_1_2_2(exit_COMPUTE_LOOP_lpi_1_dfm_4,
      CALC_SOFTMAX_LOOP_mux_27_nl, CALC_SOFTMAX_LOOP_equal_tmp_2);
  assign CALC_SOFTMAX_LOOP_i_mux_16_nl = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5,
      (ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm_1[6:0]),
      or_dcpl_40);
  assign and_434_nl = and_27_tmp & lfst_exit_CALC_SOFTMAX_LOOP_lpi_1_dfm_st_1_1;

  function automatic [2:0] MUX1HOT_v_3_4_2;
    input [2:0] input_3;
    input [2:0] input_2;
    input [2:0] input_1;
    input [2:0] input_0;
    input [3:0] sel;
    reg [2:0] result;
  begin
    result = input_0 & {3{sel[0]}};
    result = result | ( input_1 & {3{sel[1]}});
    result = result | ( input_2 & {3{sel[2]}});
    result = result | ( input_3 & {3{sel[3]}});
    MUX1HOT_v_3_4_2 = result;
  end
  endfunction


  function automatic [4:0] MUX1HOT_v_5_4_2;
    input [4:0] input_3;
    input [4:0] input_2;
    input [4:0] input_1;
    input [4:0] input_0;
    input [3:0] sel;
    reg [4:0] result;
  begin
    result = input_0 & {5{sel[0]}};
    result = result | ( input_1 & {5{sel[1]}});
    result = result | ( input_2 & {5{sel[2]}});
    result = result | ( input_3 & {5{sel[3]}});
    MUX1HOT_v_5_4_2 = result;
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


  function automatic [7:0] MUX1HOT_v_8_3_2;
    input [7:0] input_2;
    input [7:0] input_1;
    input [7:0] input_0;
    input [2:0] sel;
    reg [7:0] result;
  begin
    result = input_0 & {8{sel[0]}};
    result = result | ( input_1 & {8{sel[1]}});
    result = result | ( input_2 & {8{sel[2]}});
    MUX1HOT_v_8_3_2 = result;
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
//  Design Unit:    esp_acc_softmax_cxx_store_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store_core (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_out_rsc_req_vz,
      plm_out_rsc_rls_lz, dma_write_ctrl_rsc_dat, dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy,
      dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, done_rsc_rdy,
      done_rsc_vld, plm_out_rsci_q_d, plm_out_rsci_radr_d, plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;
  input [31:0] plm_out_rsci_q_d;
  output [6:0] plm_out_rsci_radr_d;
  output plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d;


  // Interconnect Declarations
  wire core_wen;
  wire conf_info_rsci_bawt;
  reg conf_info_rsci_iswt0;
  wire core_wten;
  wire conf_info_rsci_wen_comp;
  reg conf_info_rsci_irdy_core_psct;
  wire conf_info_rsci_ivld;
  wire conf_info_rsci_ivld_oreg;
  wire [31:0] conf_info_rsci_idat_mxwt;
  wire plm_out_rsci_bawt;
  wire [31:0] plm_out_rsci_q_d_mxwt;
  wire dma_write_ctrl_rsci_bawt;
  wire dma_write_ctrl_rsci_irdy_mxwt;
  wire dma_write_chnl_rsci_bawt;
  wire dma_write_chnl_rsci_wen_comp;
  wire done_rsci_bawt;
  wire done_rsci_wen_comp;
  wire plm_out_rsc_rls_obj_bawt;
  wire plm_out_rsc_req_obj_bawt;
  reg plm_out_rsc_req_obj_iswt0;
  wire plm_out_rsc_req_obj_wen_comp;
  reg [24:0] dma_write_ctrl_rsci_idat_31_7;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [1:0] fsm_output;
  wire [4:0] STORE_BATCH_LOOP_acc_2_tmp;
  wire [5:0] nl_STORE_BATCH_LOOP_acc_2_tmp;
  wire [7:0] STORE_INNER_LOOP_acc_1_tmp;
  wire [8:0] nl_STORE_INNER_LOOP_acc_1_tmp;
  wire or_tmp_1;
  wire or_tmp_4;
  wire and_tmp_3;
  wire and_tmp_10;
  wire or_tmp_29;
  wire and_tmp_19;
  wire or_tmp_58;
  wire or_tmp_78;
  wire nor_tmp_10;
  wire and_dcpl_1;
  wire and_tmp_38;
  wire and_tmp_43;
  wire or_tmp_105;
  wire and_tmp_54;
  wire and_tmp_55;
  wire and_tmp_56;
  wire mux_tmp_85;
  wire and_dcpl_5;
  wire and_dcpl_7;
  wire mux_tmp_114;
  wire mux_tmp_115;
  wire and_tmp_75;
  wire or_dcpl;
  wire or_dcpl_6;
  wire and_dcpl_9;
  wire and_dcpl_10;
  wire and_dcpl_12;
  wire or_dcpl_7;
  wire and_dcpl_13;
  wire or_dcpl_10;
  wire or_dcpl_11;
  wire and_tmp_77;
  wire or_tmp_146;
  wire and_tmp_78;
  wire or_tmp_148;
  wire and_dcpl_17;
  wire and_dcpl_18;
  wire or_tmp_156;
  wire or_tmp_158;
  wire and_dcpl_22;
  wire and_tmp_98;
  wire and_dcpl_24;
  wire and_dcpl_28;
  wire and_dcpl_30;
  wire and_dcpl_33;
  wire and_dcpl_36;
  wire and_dcpl_39;
  wire and_dcpl_51;
  wire and_dcpl_54;
  wire and_dcpl_56;
  wire and_dcpl_57;
  wire and_dcpl_62;
  wire and_dcpl_67;
  wire and_dcpl_75;
  wire and_dcpl_78;
  wire and_dcpl_80;
  wire and_dcpl_83;
  wire and_dcpl_87;
  wire or_dcpl_29;
  wire nor_tmp_50;
  wire mux_tmp_176;
  wire mux_tmp_186;
  wire and_dcpl_94;
  wire and_dcpl_95;
  wire and_dcpl_96;
  wire or_dcpl_36;
  wire and_dcpl_104;
  wire or_tmp_273;
  wire and_dcpl_105;
  wire and_tmp_158;
  wire and_dcpl_108;
  wire and_dcpl_113;
  wire mux_tmp_242;
  wire or_tmp_347;
  wire or_25_cse;
  wire and_324_cse;
  wire and_350_cse;
  wire main_stage_en_5;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0;
  wire exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3;
  reg exitL_exit_STORE_BATCH_LOOP_sva;
  reg STORE_BATCH_LOOP_asn_itm;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  reg main_stage_v_1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1;
  wire STORE_INNER_LOOP_and_1_ssc_1;
  wire STORE_INNER_LOOP_and_2_ssc_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0;
  reg STORE_INNER_LOOP_or_tmp_1;
  reg exit_STORE_CTRL_LOOP_sva_st_1;
  reg main_stage_v_2;
  reg STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3;
  reg main_stage_v_3;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4;
  reg main_stage_v_4;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0;
  reg STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_0;
  reg STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3;
  reg reg_plm_out_rsc_rls_obj_ld_core_psct_cse;
  reg reg_done_rsci_ivld_core_psct_cse;
  reg reg_dma_write_chnl_rsci_ivld_core_psct_cse;
  reg reg_dma_write_ctrl_rsci_ivld_core_psct_cse;
  reg reg_plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse;
  wire and_227_cse;
  wire STORE_INNER_LOOP_and_10_cse;
  wire STORE_INNER_LOOP_i_and_2_cse;
  wire STORE_INNER_LOOP_and_18_cse;
  wire and_392_cse;
  wire STORE_INNER_LOOP_and_20_cse;
  wire or_63_cse;
  wire or_32_cse;
  wire or_36_cse;
  wire or_35_cse;
  wire or_34_cse;
  wire or_75_cse;
  wire or_467_cse;
  wire or_369_cse;
  wire or_119_cse;
  wire or_111_cse;
  wire nor_55_cse;
  wire and_374_cse;
  wire mux_15_cse;
  wire and_37_cse;
  wire and_41_cse;
  wire or_109_cse;
  wire nand_70_cse;
  wire and_218_cse;
  wire and_281_cse;
  wire mux_146_cse;
  wire and_133_cse;
  wire and_214_cse;
  wire mux_152_cse;
  wire mux_188_cse;
  reg [6:0] plm_out_rsci_radr_d_reg;
  wire [6:0] STORE_INNER_LOOP_i_mux_rmff;
  wire plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_197_rmff;
  wire exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx0w0;
  reg [24:0] STORE_BATCH_LOOP_acc_3_psp_lpi_1;
  reg [31:0] batch_lpi_1_dfm;
  reg exit_STORE_CTRL_LOOP_sva_st;
  reg STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm;
  reg STORE_INNER_LOOP_equal_tmp_1;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1;
  reg exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2;
  reg [3:0] STORE_BATCH_LOOP_b_4_0_lpi_1_3_0;
  reg [6:0] STORE_INNER_LOOP_i_7_0_lpi_1_6_0;
  reg [6:0] STORE_INNER_LOOP_i_7_0_sva_1_1_6_0;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1;
  reg lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0;
  wire conf_info_rsci_iswt0_mx0c1;
  wire plm_out_rsc_req_obj_iswt0_mx0c1;
  wire [6:0] STORE_INNER_LOOP_i_7_0_lpi_1_6_0_mx0w0;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1;
  wire STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1;
  wire [31:0] batch_lpi_1_dfm_mx1;
  wire lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1;
  wire STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1;
  wire main_stage_v_2_mx0c1;
  wire exit_STORE_CTRL_LOOP_sva_st_1_mx0c1;
  wire main_stage_v_3_mx0c1;
  wire main_stage_v_4_mx0c1;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1;
  wire exit_STORE_BATCH_LOOP_lpi_1_dfm_4;
  wire [3:0] STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1;
  wire [24:0] STORE_BATCH_LOOP_acc_3_psp_sva_1;
  wire [25:0] nl_STORE_BATCH_LOOP_acc_3_psp_sva_1;
  wire STORE_BATCH_LOOP_acc_itm_32_1;

  wire[0:0] nor_84_nl;
  wire[0:0] mux_151_nl;
  wire[0:0] mux_150_nl;
  wire[0:0] nor_82_nl;
  wire[0:0] mux_149_nl;
  wire[0:0] mux_148_nl;
  wire[0:0] mux_147_nl;
  wire[0:0] nor_83_nl;
  wire[0:0] and_121_nl;
  wire[0:0] and_120_nl;
  wire[0:0] or_444_nl;
  wire[0:0] mux_163_nl;
  wire[0:0] mux_162_nl;
  wire[0:0] mux_161_nl;
  wire[0:0] mux_160_nl;
  wire[0:0] nor_85_nl;
  wire[0:0] mux_159_nl;
  wire[0:0] mux_158_nl;
  wire[0:0] mux_157_nl;
  wire[0:0] nor_86_nl;
  wire[0:0] and_130_nl;
  wire[0:0] and_129_nl;
  wire[0:0] or_273_nl;
  wire[0:0] or_281_nl;
  wire[0:0] STORE_INNER_LOOP_mux_20_nl;
  wire[0:0] mux_196_nl;
  wire[0:0] mux_195_nl;
  wire[0:0] mux_194_nl;
  wire[0:0] mux_193_nl;
  wire[0:0] and_226_nl;
  wire[0:0] mux_211_nl;
  wire[0:0] or_325_nl;
  wire[0:0] mux_241_nl;
  wire[0:0] nor_74_nl;
  wire[0:0] mux_240_nl;
  wire[0:0] nand_53_nl;
  wire[0:0] nand_54_nl;
  wire[0:0] STORE_BATCH_LOOP_if_mux_3_nl;
  wire[0:0] mux_269_nl;
  wire[0:0] or_61_nl;
  wire[0:0] or_432_nl;
  wire[0:0] STORE_INNER_LOOP_mux_6_nl;
  wire[0:0] STORE_BATCH_LOOP_if_and_nl;
  wire[0:0] STORE_BATCH_LOOP_if_and_1_nl;
  wire[0:0] STORE_BATCH_LOOP_if_or_1_nl;
  wire[0:0] STORE_INNER_LOOP_mux_19_nl;
  wire[0:0] and_245_nl;
  wire[0:0] mux_210_nl;
  wire[0:0] or_322_nl;
  wire[0:0] mux_209_nl;
  wire[0:0] and_380_nl;
  wire[0:0] STORE_BATCH_LOOP_not_12_nl;
  wire[32:0] STORE_BATCH_LOOP_acc_nl;
  wire[33:0] nl_STORE_BATCH_LOOP_acc_nl;
  wire[6:0] STORE_INNER_LOOP_i_mux_1_nl;
  wire[0:0] STORE_INNER_LOOP_mux_7_nl;
  wire[0:0] STORE_INNER_LOOP_mux_18_nl;
  wire[0:0] and_11_nl;
  wire[0:0] mux_14_nl;
  wire[0:0] mux_13_nl;
  wire[0:0] and_10_nl;
  wire[0:0] and_nl;
  wire[0:0] mux_50_nl;
  wire[0:0] or_83_nl;
  wire[0:0] mux_49_nl;
  wire[0:0] mux_70_nl;
  wire[0:0] and_40_nl;
  wire[0:0] and_91_nl;
  wire[0:0] mux_126_nl;
  wire[0:0] and_90_nl;
  wire[0:0] mux_134_nl;
  wire[0:0] mux_133_nl;
  wire[0:0] and_105_nl;
  wire[0:0] mux_132_nl;
  wire[0:0] mux_131_nl;
  wire[0:0] nor_116_nl;
  wire[0:0] mux_142_nl;
  wire[0:0] mux_141_nl;
  wire[0:0] mux_140_nl;
  wire[0:0] mux_139_nl;
  wire[0:0] mux_138_nl;
  wire[0:0] and_219_nl;
  wire[0:0] mux_187_nl;
  wire[0:0] mux_186_nl;
  wire[0:0] mux_185_nl;
  wire[0:0] mux_184_nl;
  wire[0:0] and_217_nl;
  wire[0:0] or_305_nl;
  wire[0:0] or_303_nl;
  wire[0:0] mux_198_nl;
  wire[0:0] and_381_nl;
  wire[0:0] mux_197_nl;
  wire[0:0] and_232_nl;
  wire[0:0] mux_223_nl;
  wire[0:0] mux_222_nl;
  wire[0:0] and_264_nl;
  wire[0:0] mux_224_nl;
  wire[0:0] or_346_nl;
  wire[0:0] mux_236_nl;
  wire[0:0] mux_235_nl;
  wire[0:0] mux_234_nl;
  wire[0:0] nor_93_nl;
  wire[0:0] mux_233_nl;
  wire[0:0] mux_232_nl;
  wire[0:0] and_274_nl;
  wire[0:0] mux_248_nl;
  wire[0:0] mux_247_nl;
  wire[0:0] mux_246_nl;
  wire[0:0] and_378_nl;
  wire[0:0] nor_89_nl;
  wire[0:0] mux_245_nl;
  wire[0:0] and_379_nl;
  wire[0:0] nor_91_nl;
  wire[0:0] nor_92_nl;
  wire[0:0] mux_82_nl;
  wire[0:0] mux_81_nl;
  wire[0:0] mux_80_nl;
  wire[0:0] mux_79_nl;
  wire[0:0] mux_78_nl;
  wire[0:0] mux_77_nl;
  wire[0:0] nor_102_nl;
  wire[0:0] mux_76_nl;
  wire[0:0] mux_75_nl;
  wire[0:0] mux_74_nl;
  wire[0:0] mux_73_nl;
  wire[0:0] nand_45_nl;
  wire[0:0] and_44_nl;
  wire[0:0] mux_72_nl;
  wire[0:0] nor_103_nl;
  wire[0:0] nor_104_nl;
  wire[0:0] mux_71_nl;
  wire[0:0] and_385_nl;
  wire[0:0] nor_105_nl;
  wire[0:0] nand_69_nl;
  wire[0:0] mux_94_nl;
  wire[0:0] mux_93_nl;
  wire[0:0] mux_92_nl;
  wire[0:0] and_60_nl;
  wire[0:0] mux_91_nl;
  wire[0:0] mux_90_nl;
  wire[0:0] mux_89_nl;
  wire[0:0] mux_88_nl;
  wire[0:0] mux_87_nl;
  wire[0:0] and_59_nl;
  wire[0:0] and_58_nl;
  wire[0:0] and_57_nl;
  wire[0:0] mux_86_nl;
  wire[0:0] mux_85_nl;
  wire[0:0] and_30_nl;
  wire[0:0] and_55_nl;
  wire[0:0] and_51_nl;
  wire[0:0] and_50_nl;
  wire[0:0] mux_109_nl;
  wire[0:0] mux_108_nl;
  wire[0:0] mux_107_nl;
  wire[0:0] mux_106_nl;
  wire[0:0] mux_105_nl;
  wire[0:0] mux_104_nl;
  wire[0:0] mux_103_nl;
  wire[0:0] mux_102_nl;
  wire[0:0] mux_101_nl;
  wire[0:0] mux_100_nl;
  wire[0:0] and_13_nl;
  wire[0:0] and_72_nl;
  wire[0:0] and_71_nl;
  wire[0:0] mux_99_nl;
  wire[0:0] mux_164_nl;
  wire[0:0] nor_94_nl;
  wire[0:0] or_77_nl;
  wire[0:0] mux_220_nl;
  wire[0:0] nor_60_nl;
  wire[0:0] mux_256_nl;
  wire[0:0] nor_88_nl;
  wire[0:0] mux_260_nl;
  wire[0:0] or_418_nl;
  wire[0:0] mux_259_nl;
  wire[0:0] or_417_nl;
  wire[0:0] or_415_nl;

  // Interconnect Declarations for Component Instantiations 
  wire [0:0] nl_store_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg;
  assign nl_store_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg = and_dcpl_78
      & and_dcpl_1 & (fsm_output[1]);
  wire [66:0] nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_store_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat = {35'b01100000000000000000000000010000000
      , dma_write_ctrl_rsci_idat_31_7 , 7'b0000000};
  wire [0:0] nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg =
      or_dcpl_11 & dma_write_chnl_rsci_bawt & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0) & and_dcpl_9;
  wire [63:0] nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat = {32'b11011110101011011011111011101111
      , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_store_core_plm_out_rsc_rls_obj_inst_plm_out_rsc_rls_obj_oswt_unreg;
  assign nl_store_core_plm_out_rsc_rls_obj_inst_plm_out_rsc_rls_obj_oswt_unreg =
      and_dcpl_36 & plm_out_rsci_bawt & plm_out_rsc_rls_obj_bawt & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0) & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1
      & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2) & main_stage_v_2;
  wire [0:0] nl_store_core_plm_out_rsc_req_obj_inst_plm_out_rsc_req_obj_oswt_unreg;
  assign nl_store_core_plm_out_rsc_req_obj_inst_plm_out_rsc_req_obj_oswt_unreg =
      and_dcpl_36 & and_dcpl_33;
  esp_acc_softmax_cxx_store_core_wait_dp store_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg)
    );
  esp_acc_softmax_cxx_store_core_conf_info_rsci store_core_conf_info_rsci_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .core_wen(core_wen),
      .conf_info_rsci_oswt_unreg(nl_store_core_conf_info_rsci_inst_conf_info_rsci_oswt_unreg[0:0]),
      .conf_info_rsci_bawt(conf_info_rsci_bawt),
      .conf_info_rsci_iswt0(conf_info_rsci_iswt0),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .conf_info_rsci_irdy_core_psct(conf_info_rsci_irdy_core_psct),
      .conf_info_rsci_ivld(conf_info_rsci_ivld),
      .conf_info_rsci_ivld_oreg(conf_info_rsci_ivld_oreg),
      .conf_info_rsci_idat_mxwt(conf_info_rsci_idat_mxwt)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsci_1 store_core_plm_out_rsci_1_inst (
      .clk(clk),
      .rst(rst),
      .plm_out_rsci_q_d(plm_out_rsci_q_d),
      .plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsci_oswt_unreg(and_dcpl_62),
      .plm_out_rsci_bawt(plm_out_rsci_bawt),
      .plm_out_rsci_iswt0(reg_plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse),
      .plm_out_rsci_q_d_mxwt(plm_out_rsci_q_d_mxwt),
      .plm_out_rsci_iswt0_pff(and_197_rmff)
    );
  esp_acc_softmax_cxx_store_core_dma_write_ctrl_rsci store_core_dma_write_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_write_ctrl_rsci_oswt_unreg(and_dcpl_75),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_iswt0(reg_dma_write_ctrl_rsci_ivld_core_psct_cse),
      .dma_write_ctrl_rsci_irdy_mxwt(dma_write_ctrl_rsci_irdy_mxwt),
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
      .dma_write_chnl_rsci_iswt0(reg_dma_write_chnl_rsci_ivld_core_psct_cse),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_idat(nl_store_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat[63:0])
    );
  esp_acc_softmax_cxx_store_core_done_rsci store_core_done_rsci_inst (
      .clk(clk),
      .rst(rst),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .core_wen(core_wen),
      .done_rsci_oswt_unreg(and_dcpl_54),
      .done_rsci_bawt(done_rsci_bawt),
      .done_rsci_iswt0(reg_done_rsci_ivld_core_psct_cse),
      .done_rsci_wen_comp(done_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_rls_obj store_core_plm_out_rsc_rls_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_rsc_rls_obj_oswt_unreg(nl_store_core_plm_out_rsc_rls_obj_inst_plm_out_rsc_rls_obj_oswt_unreg[0:0]),
      .plm_out_rsc_rls_obj_bawt(plm_out_rsc_rls_obj_bawt),
      .plm_out_rsc_rls_obj_iswt0(reg_plm_out_rsc_rls_obj_ld_core_psct_cse)
    );
  esp_acc_softmax_cxx_store_core_plm_out_rsc_req_obj store_core_plm_out_rsc_req_obj_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .core_wen(core_wen),
      .plm_out_rsc_req_obj_oswt_unreg(nl_store_core_plm_out_rsc_req_obj_inst_plm_out_rsc_req_obj_oswt_unreg[0:0]),
      .plm_out_rsc_req_obj_bawt(plm_out_rsc_req_obj_bawt),
      .plm_out_rsc_req_obj_iswt0(plm_out_rsc_req_obj_iswt0),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_store_core_staller store_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .conf_info_rsci_wen_comp(conf_info_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .done_rsci_wen_comp(done_rsci_wen_comp),
      .plm_out_rsc_req_obj_wen_comp(plm_out_rsc_req_obj_wen_comp)
    );
  esp_acc_softmax_cxx_store_core_core_fsm store_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output)
    );
  assign nor_84_nl = ~(dma_write_ctrl_rsci_irdy_mxwt | (~(dma_write_ctrl_rsci_bawt
      & and_tmp_3)));
  assign mux_146_cse = MUX_s_1_2_2(nor_84_nl, and_tmp_3, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign and_133_cse = STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_3;
  assign nor_82_nl = ~(STORE_BATCH_LOOP_if_asn_sft_lpi_1 | lfst_exit_STORE_INNER_LOOP_lpi_1_1
      | (~ and_tmp_3));
  assign mux_150_nl = MUX_s_1_2_2(nor_82_nl, and_133_cse, STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign nor_83_nl = ~(and_392_cse | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | (~(or_tmp_29
      & STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_3)));
  assign mux_147_nl = MUX_s_1_2_2(nor_83_nl, mux_146_cse, STORE_INNER_LOOP_or_tmp_1);
  assign mux_148_nl = MUX_s_1_2_2(mux_147_nl, and_133_cse, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_121_nl = or_25_cse & STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_3;
  assign mux_149_nl = MUX_s_1_2_2(mux_148_nl, and_121_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_151_nl = MUX_s_1_2_2(mux_150_nl, mux_149_nl, main_stage_v_1);
  assign and_120_nl = or_369_cse & STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_3;
  assign mux_152_cse = MUX_s_1_2_2(mux_151_nl, and_120_nl, or_tmp_1);
  assign and_197_rmff = and_dcpl_28 & and_dcpl_39 & and_dcpl_24;
  assign or_273_nl = (~ mux_tmp_115) | and_dcpl_7 | (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1)
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | (~ main_stage_v_1);
  assign STORE_INNER_LOOP_i_mux_rmff = MUX_v_7_2_2(STORE_INNER_LOOP_i_7_0_lpi_1_6_0,
      plm_out_rsci_radr_d_reg, or_273_nl);
  assign and_392_cse = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1 & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0;
  assign and_227_cse = ((~ main_stage_v_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)
      & mux_15_cse;
  assign nor_55_cse = ~(and_392_cse | (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1));
  assign or_63_cse = (~ STORE_BATCH_LOOP_asn_itm) | conf_info_rsci_bawt;
  assign STORE_INNER_LOOP_and_10_cse = core_wen & (~ or_dcpl);
  assign or_369_cse = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | (~ main_stage_v_1)
      | dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  assign and_281_cse = or_369_cse & mux_15_cse;
  assign STORE_INNER_LOOP_i_and_2_cse = core_wen & (~(or_dcpl_29 | (and_dcpl_87 &
      (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)) | (~ main_stage_v_1)));
  assign STORE_INNER_LOOP_and_18_cse = core_wen & (~((~ mux_tmp_242) | and_dcpl_7
      | (~ main_stage_v_2)));
  assign or_75_cse = (~ exit_STORE_CTRL_LOOP_sva_st_1) | plm_out_rsc_req_obj_bawt;
  assign or_467_cse = (~ STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2) |
      plm_out_rsc_rls_obj_bawt;
  assign or_61_nl = STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 | STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  assign or_432_nl = or_tmp_78 | (~ or_tmp_146);
  assign mux_269_nl = MUX_s_1_2_2(or_61_nl, or_432_nl, main_stage_v_1);
  assign STORE_INNER_LOOP_and_20_cse = core_wen & (~(mux_269_nl | or_tmp_1));
  assign STORE_BATCH_LOOP_if_and_nl = STORE_INNER_LOOP_or_tmp_1 & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign STORE_BATCH_LOOP_if_and_1_nl = STORE_INNER_LOOP_equal_tmp_1 & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign STORE_BATCH_LOOP_if_or_1_nl = and_392_cse | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign STORE_INNER_LOOP_i_7_0_lpi_1_6_0_mx0w0 = MUX1HOT_v_7_3_2((signext_7_1(~
      dma_write_ctrl_rsci_irdy_mxwt)), STORE_INNER_LOOP_i_7_0_sva_1_1_6_0, STORE_INNER_LOOP_i_7_0_lpi_1_6_0,
      {STORE_BATCH_LOOP_if_and_nl , STORE_BATCH_LOOP_if_and_1_nl , STORE_BATCH_LOOP_if_or_1_nl});
  assign STORE_INNER_LOOP_mux_19_nl = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      (STORE_BATCH_LOOP_acc_2_tmp[4]), STORE_INNER_LOOP_acc_1_tmp[7]);
  assign and_380_nl = STORE_BATCH_LOOP_if_asn_sft_lpi_1 & (~ and_392_cse);
  assign mux_209_nl = MUX_s_1_2_2(and_380_nl, dma_write_ctrl_rsci_irdy_mxwt, STORE_INNER_LOOP_or_tmp_1);
  assign or_322_nl = or_tmp_78 | (~ mux_209_nl);
  assign mux_210_nl = MUX_s_1_2_2(or_111_cse, or_322_nl, main_stage_v_1);
  assign and_245_nl = (~ mux_210_nl) & and_dcpl_13;
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1 = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      STORE_INNER_LOOP_mux_19_nl, and_245_nl);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0 = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_1, or_dcpl_36);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0 = MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_0, or_dcpl_36);
  assign batch_lpi_1_dfm_mx1 = MUX_v_32_2_2(batch_lpi_1_dfm, conf_info_rsci_idat_mxwt,
      exitL_exit_STORE_BATCH_LOOP_sva);
  assign exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx0w0 = (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1)) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0 = lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0
      & (~ exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0 = lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0
      & (~ exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1);
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_4 = (~ STORE_BATCH_LOOP_acc_itm_32_1) &
      exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1;
  assign STORE_BATCH_LOOP_not_12_nl = ~ exitL_exit_STORE_BATCH_LOOP_sva;
  assign STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1 = MUX_v_4_2_2(4'b0000, STORE_BATCH_LOOP_b_4_0_lpi_1_3_0,
      STORE_BATCH_LOOP_not_12_nl);
  assign nl_STORE_BATCH_LOOP_acc_nl = ({29'b10000000000000000000000000000 , STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1})
      + conv_u2u_32_33(~ batch_lpi_1_dfm_mx1) + 33'b000000000000000000000000000000001;
  assign STORE_BATCH_LOOP_acc_nl = nl_STORE_BATCH_LOOP_acc_nl[32:0];
  assign STORE_BATCH_LOOP_acc_itm_32_1 = readslicef_33_1_32(STORE_BATCH_LOOP_acc_nl);
  assign nl_STORE_BATCH_LOOP_acc_2_tmp = conv_u2u_4_5(STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1)
      + 5'b00001;
  assign STORE_BATCH_LOOP_acc_2_tmp = nl_STORE_BATCH_LOOP_acc_2_tmp[4:0];
  assign STORE_INNER_LOOP_i_mux_1_nl = MUX_v_7_2_2(STORE_INNER_LOOP_i_7_0_lpi_1_6_0,
      STORE_INNER_LOOP_i_7_0_lpi_1_6_0_mx0w0, main_stage_v_1);
  assign nl_STORE_INNER_LOOP_acc_1_tmp = conv_u2u_7_8(STORE_INNER_LOOP_i_mux_1_nl)
      + 8'b00000001;
  assign STORE_INNER_LOOP_acc_1_tmp = nl_STORE_INNER_LOOP_acc_1_tmp[7:0];
  assign STORE_INNER_LOOP_mux_7_nl = MUX_s_1_2_2(STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1,
      exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx0w0, main_stage_v_1);
  assign exitL_exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_1 = STORE_INNER_LOOP_mux_7_nl
      | exit_STORE_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_STORE_BATCH_LOOP_sva;
  assign nl_STORE_BATCH_LOOP_acc_3_psp_sva_1 = (batch_lpi_1_dfm_mx1[24:0]) + conv_u2u_4_25(STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1);
  assign STORE_BATCH_LOOP_acc_3_psp_sva_1 = nl_STORE_BATCH_LOOP_acc_3_psp_sva_1[24:0];
  assign STORE_INNER_LOOP_mux_18_nl = MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1,
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1, and_392_cse);
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_1_1 = (STORE_INNER_LOOP_mux_18_nl
      & (~ STORE_INNER_LOOP_and_1_ssc_1)) | STORE_INNER_LOOP_and_2_ssc_1;
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_3_0_1 = (and_392_cse & (~ STORE_INNER_LOOP_and_2_ssc_1))
      | STORE_INNER_LOOP_and_1_ssc_1;
  assign STORE_INNER_LOOP_and_1_ssc_1 = (~ dma_write_ctrl_rsci_irdy_mxwt) & STORE_INNER_LOOP_or_tmp_1;
  assign STORE_INNER_LOOP_and_2_ssc_1 = dma_write_ctrl_rsci_irdy_mxwt & STORE_INNER_LOOP_or_tmp_1;
  assign main_stage_en_5 = or_63_cse & (dma_write_ctrl_rsci_bawt | (~((~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)) & main_stage_v_1))) & (plm_out_rsc_req_obj_bawt
      | (~(exit_STORE_CTRL_LOOP_sva_st_1 & ((lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1)) | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0))) & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (plm_out_rsci_bawt | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0) & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2)
      & main_stage_v_2))) & (plm_out_rsc_rls_obj_bawt | (~(STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2
      & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0)
      & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2) & main_stage_v_2))) & (dma_write_chnl_rsci_bawt
      | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1 & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0)
      & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3) & main_stage_v_3))) & (done_rsci_bawt
      | (~(exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4 & main_stage_v_4)));
  assign or_25_cse = dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign or_tmp_1 = exitL_exit_STORE_BATCH_LOOP_sva | exit_STORE_BATCH_LOOP_lpi_1_dfm_3;
  assign or_tmp_4 = (~ main_stage_v_3) | dma_write_chnl_rsci_bawt | (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1)
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3;
  assign or_32_cse = (~ main_stage_v_4) | (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4)
      | done_rsci_bawt;
  assign or_36_cse = plm_out_rsc_req_obj_bawt | (~ exit_STORE_CTRL_LOOP_sva_st_1)
      | (~ main_stage_v_2) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign or_35_cse = (~ main_stage_v_2) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign or_34_cse = plm_out_rsc_rls_obj_bawt | (~ STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2)
      | (~ main_stage_v_2) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
  assign and_11_nl = or_36_cse & or_tmp_4;
  assign and_10_nl = or_35_cse & or_tmp_4;
  assign and_nl = or_34_cse & or_tmp_4;
  assign mux_13_nl = MUX_s_1_2_2(and_10_nl, and_nl, plm_out_rsci_bawt);
  assign mux_14_nl = MUX_s_1_2_2(mux_13_nl, or_tmp_4, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0);
  assign mux_15_cse = MUX_s_1_2_2(and_11_nl, mux_14_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign and_tmp_3 = or_32_cse & mux_15_cse;
  assign and_tmp_10 = or_25_cse & and_tmp_3;
  assign or_tmp_29 = dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  assign mux_49_nl = MUX_s_1_2_2(or_35_cse, or_34_cse, plm_out_rsci_bawt);
  assign or_83_nl = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 | mux_49_nl;
  assign mux_50_nl = MUX_s_1_2_2(or_36_cse, or_83_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign and_tmp_19 = or_32_cse & or_tmp_4 & mux_50_nl;
  assign or_tmp_58 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  assign and_37_cse = or_369_cse & and_tmp_19;
  assign or_tmp_78 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
  assign nor_tmp_10 = dma_write_ctrl_rsci_irdy_mxwt & dma_write_ctrl_rsci_bawt;
  assign and_40_nl = nor_tmp_10 & and_tmp_19;
  assign mux_70_nl = MUX_s_1_2_2(and_40_nl, and_tmp_19, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign and_41_cse = (STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[7])
      & mux_70_nl;
  assign or_109_cse = and_392_cse | (~(or_tmp_29 & and_tmp_19));
  assign or_111_cse = STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 | (~
      lfst_exit_STORE_INNER_LOOP_lpi_1_1) | lfst_exit_STORE_INNER_LOOP_lpi_1_0 |
      STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  assign nand_70_cse = ~((STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[7])
      & and_tmp_19);
  assign and_dcpl_1 = conf_info_rsci_bawt & STORE_BATCH_LOOP_asn_itm;
  assign or_119_cse = STORE_BATCH_LOOP_acc_itm_32_1 | (~ main_stage_en_5);
  assign and_tmp_38 = or_119_cse & and_tmp_19;
  assign and_tmp_43 = (~((STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[7])
      & main_stage_en_5)) & and_tmp_19;
  assign or_tmp_105 = exitL_exit_STORE_BATCH_LOOP_sva | exit_STORE_BATCH_LOOP_lpi_1_dfm_3
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1;
  assign and_tmp_54 = or_119_cse & and_tmp_3;
  assign and_tmp_55 = or_tmp_29 & and_tmp_3;
  assign and_tmp_56 = (~((~ or_tmp_29) | main_stage_en_5)) & and_tmp_3;
  assign mux_tmp_85 = MUX_s_1_2_2(and_tmp_56, and_tmp_55, STORE_BATCH_LOOP_acc_itm_32_1);
  assign and_dcpl_5 = (~ conf_info_rsci_bawt) & STORE_BATCH_LOOP_asn_itm;
  assign and_dcpl_7 = exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4 & (~ done_rsci_bawt)
      & main_stage_v_4;
  assign and_91_nl = or_75_cse & or_tmp_4;
  assign and_90_nl = or_467_cse & plm_out_rsci_bawt & or_tmp_4;
  assign mux_126_nl = MUX_s_1_2_2(and_90_nl, or_tmp_4, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0);
  assign mux_tmp_114 = MUX_s_1_2_2(and_91_nl, mux_126_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign mux_tmp_115 = MUX_s_1_2_2(mux_tmp_114, or_tmp_4, or_35_cse);
  assign and_tmp_75 = or_369_cse & mux_tmp_115;
  assign or_dcpl = (~ and_tmp_75) | and_dcpl_7;
  assign or_dcpl_6 = ((~ plm_out_rsc_rls_obj_bawt) & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2)
      | (~ plm_out_rsci_bawt) | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 | (~
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2
      | (~ main_stage_v_2);
  assign and_dcpl_9 = (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3) & main_stage_v_3;
  assign and_dcpl_10 = (~ dma_write_chnl_rsci_bawt) & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1;
  assign and_dcpl_12 = and_dcpl_10 & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0)
      & and_dcpl_9;
  assign or_dcpl_7 = and_dcpl_12 | and_dcpl_7;
  assign and_dcpl_13 = ~(exit_STORE_BATCH_LOOP_lpi_1_dfm_3 | exitL_exit_STORE_BATCH_LOOP_sva);
  assign or_dcpl_10 = (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4) | done_rsci_bawt;
  assign or_dcpl_11 = or_dcpl_10 | (~ main_stage_v_4);
  assign and_tmp_77 = or_25_cse & mux_tmp_115;
  assign or_tmp_146 = STORE_INNER_LOOP_or_tmp_1 | STORE_BATCH_LOOP_if_asn_sft_lpi_1;
  assign and_tmp_78 = or_tmp_29 & mux_tmp_115;
  assign or_tmp_148 = and_392_cse | (~ and_tmp_78);
  assign and_105_nl = STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 & mux_tmp_115;
  assign nor_116_nl = ~(or_tmp_146 | or_tmp_148);
  assign mux_131_nl = MUX_s_1_2_2(nor_116_nl, mux_tmp_115, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_132_nl = MUX_s_1_2_2(mux_131_nl, and_tmp_77, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_133_nl = MUX_s_1_2_2(and_105_nl, mux_132_nl, main_stage_v_1);
  assign mux_134_nl = MUX_s_1_2_2(mux_133_nl, and_tmp_75, or_tmp_1);
  assign and_dcpl_17 = mux_134_nl & or_dcpl_11;
  assign and_dcpl_18 = and_dcpl_17 & or_63_cse;
  assign or_tmp_156 = main_stage_v_1 | (~ mux_15_cse);
  assign or_tmp_158 = and_392_cse | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | STORE_INNER_LOOP_or_tmp_1;
  assign mux_139_nl = MUX_s_1_2_2(or_tmp_156, (~ mux_15_cse), or_tmp_29);
  assign mux_140_nl = MUX_s_1_2_2(mux_139_nl, or_tmp_156, or_tmp_158);
  assign mux_141_nl = MUX_s_1_2_2(mux_140_nl, or_tmp_156, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_138_nl = MUX_s_1_2_2((~ or_tmp_156), mux_15_cse, or_25_cse);
  assign mux_142_nl = MUX_s_1_2_2((~ mux_141_nl), mux_138_nl, or_tmp_105);
  assign and_dcpl_22 = mux_142_nl & or_dcpl_11 & or_63_cse;
  assign and_tmp_98 = STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 & STORE_BATCH_LOOP_acc_itm_32_1
      & and_tmp_3;
  assign and_dcpl_24 = (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & main_stage_v_1;
  assign and_dcpl_28 = mux_tmp_115 & or_dcpl_11;
  assign and_dcpl_30 = (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2) & main_stage_v_2;
  assign and_dcpl_33 = plm_out_rsc_req_obj_bawt & exit_STORE_CTRL_LOOP_sva_st_1 &
      (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1) & and_dcpl_30;
  assign and_dcpl_36 = or_tmp_4 & or_dcpl_11;
  assign and_dcpl_39 = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0);
  assign and_dcpl_51 = (STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3 | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0
      | (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1) | dma_write_chnl_rsci_bawt)
      & or_dcpl_11;
  assign and_dcpl_54 = exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4 & done_rsci_bawt &
      main_stage_v_4;
  assign and_dcpl_56 = and_dcpl_10 & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0)
      & (~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3);
  assign and_dcpl_57 = (and_dcpl_56 | (~ main_stage_v_3) | (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3))
      & and_dcpl_54;
  assign and_dcpl_62 = and_dcpl_36 & or_467_cse & plm_out_rsci_bawt & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0)
      & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 & and_dcpl_30;
  assign and_dcpl_67 = or_dcpl_6 & or_dcpl_11 & dma_write_chnl_rsci_bawt & lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1
      & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0) & and_dcpl_9;
  assign and_dcpl_75 = and_dcpl_28 & dma_write_ctrl_rsci_bawt & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1)
      & and_dcpl_24;
  assign and_dcpl_78 = and_tmp_75 & or_dcpl_11;
  assign and_dcpl_80 = and_dcpl_78 & or_63_cse;
  assign and_dcpl_83 = and_dcpl_28 & (or_tmp_29 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_dcpl_87 = ~(dma_write_ctrl_rsci_bawt | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign or_dcpl_29 = (~ mux_tmp_115) | and_dcpl_7;
  assign nor_tmp_50 = ~(dma_write_ctrl_rsci_irdy_mxwt | (~ dma_write_ctrl_rsci_bawt));
  assign and_218_cse = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 & and_tmp_3;
  assign and_214_cse = or_369_cse & and_tmp_3;
  assign and_219_nl = or_111_cse & and_tmp_3;
  assign mux_185_nl = MUX_s_1_2_2(and_tmp_10, and_218_cse, nor_55_cse);
  assign and_217_nl = (nor_tmp_50 | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) &
      and_tmp_3;
  assign mux_184_nl = MUX_s_1_2_2(and_217_nl, and_218_cse, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_186_nl = MUX_s_1_2_2(mux_185_nl, mux_184_nl, STORE_INNER_LOOP_or_tmp_1);
  assign mux_187_nl = MUX_s_1_2_2(mux_186_nl, and_tmp_10, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_188_cse = MUX_s_1_2_2(and_219_nl, mux_187_nl, main_stage_v_1);
  assign mux_tmp_176 = MUX_s_1_2_2(mux_188_cse, and_214_cse, or_tmp_1);
  assign or_305_nl = or_111_cse | (~ mux_tmp_115);
  assign and_381_nl = STORE_BATCH_LOOP_if_asn_sft_lpi_1 & (~ or_tmp_148);
  assign and_232_nl = nor_tmp_10 & mux_tmp_115;
  assign mux_197_nl = MUX_s_1_2_2(and_232_nl, mux_tmp_115, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_198_nl = MUX_s_1_2_2(and_381_nl, mux_197_nl, STORE_INNER_LOOP_or_tmp_1);
  assign or_303_nl = or_tmp_78 | (~ mux_198_nl);
  assign mux_tmp_186 = MUX_s_1_2_2(or_305_nl, or_303_nl, main_stage_v_1);
  assign and_dcpl_94 = (~ mux_tmp_186) & or_dcpl_11;
  assign and_dcpl_95 = and_dcpl_94 & or_63_cse;
  assign and_dcpl_96 = and_dcpl_95 & and_dcpl_13;
  assign or_dcpl_36 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ main_stage_v_1);
  assign and_dcpl_104 = and_dcpl_83 & and_dcpl_5 & main_stage_v_1;
  assign and_264_nl = and_392_cse & and_tmp_78;
  assign mux_222_nl = MUX_s_1_2_2(and_264_nl, and_tmp_78, or_tmp_146);
  assign mux_223_nl = MUX_s_1_2_2(mux_222_nl, mux_tmp_115, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign or_tmp_273 = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 | (~ mux_223_nl);
  assign or_346_nl = STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 | (~ mux_tmp_115);
  assign mux_224_nl = MUX_s_1_2_2(or_346_nl, or_tmp_273, main_stage_v_1);
  assign and_dcpl_105 = (~ mux_224_nl) & or_dcpl_11;
  assign and_tmp_158 = STORE_BATCH_LOOP_acc_itm_32_1 & mux_tmp_115;
  assign nor_93_nl = ~(STORE_BATCH_LOOP_if_asn_sft_lpi_1 | (~ mux_tmp_115));
  assign mux_234_nl = MUX_s_1_2_2(nor_93_nl, and_tmp_158, STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign mux_233_nl = MUX_s_1_2_2((~ or_tmp_273), and_tmp_77, STORE_BATCH_LOOP_acc_itm_32_1);
  assign mux_235_nl = MUX_s_1_2_2(mux_234_nl, mux_233_nl, main_stage_v_1);
  assign and_274_nl = STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_77;
  assign mux_232_nl = MUX_s_1_2_2(and_tmp_158, and_274_nl, main_stage_v_1);
  assign mux_236_nl = MUX_s_1_2_2(mux_235_nl, mux_232_nl, or_tmp_1);
  assign and_dcpl_108 = mux_236_nl & or_dcpl_11;
  assign and_378_nl = STORE_BATCH_LOOP_if_asn_sft_lpi_1 & mux_15_cse;
  assign nor_89_nl = ~(STORE_BATCH_LOOP_acc_itm_32_1 | (~ mux_15_cse));
  assign mux_246_nl = MUX_s_1_2_2(and_378_nl, nor_89_nl, STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign and_379_nl = ((~ or_tmp_158) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1)
      & (~((~ or_tmp_29) | STORE_BATCH_LOOP_acc_itm_32_1 | (~ mux_15_cse)));
  assign nor_91_nl = ~((~ STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1) | STORE_BATCH_LOOP_acc_itm_32_1
      | (~ mux_15_cse));
  assign mux_245_nl = MUX_s_1_2_2(and_379_nl, nor_91_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_247_nl = MUX_s_1_2_2(mux_246_nl, mux_245_nl, main_stage_v_1);
  assign nor_92_nl = ~((~ or_369_cse) | STORE_BATCH_LOOP_acc_itm_32_1 | (~ mux_15_cse));
  assign mux_248_nl = MUX_s_1_2_2(mux_247_nl, nor_92_nl, or_tmp_1);
  assign and_dcpl_113 = mux_248_nl & or_dcpl_11;
  assign mux_tmp_242 = MUX_s_1_2_2(mux_tmp_114, or_tmp_4, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2);
  assign nor_102_nl = ~((~ lfst_exit_STORE_INNER_LOOP_lpi_1_1) | lfst_exit_STORE_INNER_LOOP_lpi_1_0
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | nand_70_cse);
  assign mux_77_nl = MUX_s_1_2_2(nor_102_nl, and_tmp_19, STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign nand_45_nl = ~((STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[7])
      & (~ or_109_cse));
  assign mux_73_nl = MUX_s_1_2_2(or_109_cse, nand_45_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1);
  assign mux_74_nl = MUX_s_1_2_2((~ mux_73_nl), and_41_cse, STORE_INNER_LOOP_or_tmp_1);
  assign mux_75_nl = MUX_s_1_2_2(mux_74_nl, and_tmp_19, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_44_nl = or_25_cse & and_tmp_19;
  assign mux_76_nl = MUX_s_1_2_2(mux_75_nl, and_44_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_78_nl = MUX_s_1_2_2(mux_77_nl, mux_76_nl, main_stage_v_1);
  assign nor_103_nl = ~(or_111_cse | nand_70_cse);
  assign and_385_nl = STORE_BATCH_LOOP_if_asn_sft_lpi_1 & (STORE_BATCH_LOOP_acc_2_tmp[4])
      & (STORE_INNER_LOOP_acc_1_tmp[7]) & (~ or_109_cse);
  assign mux_71_nl = MUX_s_1_2_2(and_385_nl, and_41_cse, STORE_INNER_LOOP_or_tmp_1);
  assign nor_104_nl = ~(or_tmp_78 | (~ mux_71_nl));
  assign mux_72_nl = MUX_s_1_2_2(nor_103_nl, nor_104_nl, main_stage_v_1);
  assign mux_79_nl = MUX_s_1_2_2(mux_78_nl, mux_72_nl, STORE_BATCH_LOOP_acc_itm_32_1);
  assign nor_105_nl = ~(STORE_BATCH_LOOP_acc_itm_32_1 | (~ and_37_cse));
  assign mux_80_nl = MUX_s_1_2_2(mux_79_nl, nor_105_nl, exit_STORE_BATCH_LOOP_lpi_1_dfm_3);
  assign nand_69_nl = ~(STORE_BATCH_LOOP_acc_itm_32_1 & and_37_cse);
  assign mux_81_nl = MUX_s_1_2_2(mux_80_nl, nand_69_nl, exitL_exit_STORE_BATCH_LOOP_sva);
  assign mux_82_nl = MUX_s_1_2_2(exitL_exit_STORE_BATCH_LOOP_sva, mux_81_nl, or_63_cse);
  assign or_tmp_347 = (mux_82_nl & main_stage_en_5) | (fsm_output[0]);
  assign and_60_nl = ((~ lfst_exit_STORE_INNER_LOOP_lpi_1_1) | lfst_exit_STORE_INNER_LOOP_lpi_1_0
      | STORE_BATCH_LOOP_if_asn_sft_lpi_1 | (~ (STORE_BATCH_LOOP_acc_2_tmp[4])) |
      (~ (STORE_INNER_LOOP_acc_1_tmp[7])) | (~ main_stage_en_5)) & and_tmp_19;
  assign mux_92_nl = MUX_s_1_2_2(and_60_nl, and_tmp_38, STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign and_59_nl = or_tmp_29 & and_tmp_38;
  assign and_58_nl = or_tmp_29 & and_tmp_43;
  assign mux_87_nl = MUX_s_1_2_2(and_59_nl, and_58_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1);
  assign and_57_nl = or_tmp_29 & and_tmp_19;
  assign mux_88_nl = MUX_s_1_2_2(mux_87_nl, and_57_nl, and_392_cse);
  assign and_30_nl = dma_write_ctrl_rsci_bawt & and_tmp_19;
  assign and_55_nl = dma_write_ctrl_rsci_bawt & and_tmp_43;
  assign mux_85_nl = MUX_s_1_2_2(and_30_nl, and_55_nl, dma_write_ctrl_rsci_irdy_mxwt);
  assign mux_86_nl = MUX_s_1_2_2(mux_85_nl, and_tmp_43, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_89_nl = MUX_s_1_2_2(mux_88_nl, mux_86_nl, STORE_INNER_LOOP_or_tmp_1);
  assign mux_90_nl = MUX_s_1_2_2(mux_89_nl, and_tmp_38, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_51_nl = or_25_cse & and_tmp_38;
  assign mux_91_nl = MUX_s_1_2_2(mux_90_nl, and_51_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_93_nl = MUX_s_1_2_2(mux_92_nl, mux_91_nl, main_stage_v_1);
  assign and_50_nl = or_369_cse & and_tmp_38;
  assign mux_94_nl = MUX_s_1_2_2(mux_93_nl, and_50_nl, or_tmp_1);
  assign and_324_cse = mux_94_nl & and_dcpl_1 & (fsm_output[1]);
  assign and_350_cse = mux_tmp_176 & or_63_cse & (fsm_output[1]);
  assign and_374_cse = (STORE_BATCH_LOOP_acc_2_tmp[4]) & (STORE_INNER_LOOP_acc_1_tmp[7]);
  assign mux_103_nl = MUX_s_1_2_2(and_tmp_55, and_tmp_56, and_374_cse);
  assign mux_104_nl = MUX_s_1_2_2(mux_tmp_85, mux_103_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1);
  assign mux_105_nl = MUX_s_1_2_2(mux_104_nl, and_tmp_55, and_392_cse);
  assign and_13_nl = dma_write_ctrl_rsci_bawt & and_tmp_3;
  assign and_72_nl = (~((~ dma_write_ctrl_rsci_bawt) | main_stage_en_5)) & and_tmp_3;
  assign mux_100_nl = MUX_s_1_2_2(and_13_nl, and_72_nl, dma_write_ctrl_rsci_irdy_mxwt);
  assign and_71_nl = (~ main_stage_en_5) & and_tmp_3;
  assign mux_101_nl = MUX_s_1_2_2(mux_100_nl, and_71_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_102_nl = MUX_s_1_2_2(and_tmp_55, mux_101_nl, and_374_cse);
  assign mux_106_nl = MUX_s_1_2_2(mux_105_nl, mux_102_nl, STORE_INNER_LOOP_or_tmp_1);
  assign mux_107_nl = MUX_s_1_2_2(mux_106_nl, and_tmp_54, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_99_nl = MUX_s_1_2_2(mux_tmp_85, and_tmp_54, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign mux_108_nl = MUX_s_1_2_2(mux_107_nl, mux_99_nl, or_tmp_105);
  assign mux_109_nl = MUX_s_1_2_2(and_tmp_54, mux_108_nl, main_stage_v_1);
  assign conf_info_rsci_iswt0_mx0c1 = and_324_cse | (mux_109_nl & and_dcpl_1 & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign nor_94_nl = ~(nor_tmp_10 | and_dcpl_12);
  assign or_77_nl = (~ main_stage_v_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1
      | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
  assign mux_164_nl = MUX_s_1_2_2(nor_94_nl, or_tmp_4, or_77_nl);
  assign plm_out_rsc_req_obj_iswt0_mx0c1 = mux_164_nl & or_dcpl_11 & and_dcpl_33;
  assign nor_60_nl = ~(exitL_exit_STORE_BATCH_LOOP_sva | exit_STORE_BATCH_LOOP_lpi_1_dfm_3
      | (~ (STORE_INNER_LOOP_acc_1_tmp[7])));
  assign mux_220_nl = MUX_s_1_2_2(and_214_cse, mux_188_cse, nor_60_nl);
  assign STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1 = mux_220_nl & or_63_cse;
  assign lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1 = (and_dcpl_113 & or_63_cse
      & (fsm_output[1])) | (and_dcpl_22 & (~ STORE_BATCH_LOOP_acc_itm_32_1) & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1 = (and_dcpl_18 & (fsm_output[1]))
      | (and_dcpl_22 & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign nor_88_nl = ~(or_25_cse | (~ mux_tmp_242));
  assign mux_256_nl = MUX_s_1_2_2(mux_tmp_242, nor_88_nl, main_stage_v_1);
  assign main_stage_v_2_mx0c1 = mux_256_nl & or_dcpl_11 & main_stage_v_2;
  assign exit_STORE_CTRL_LOOP_sva_st_1_mx0c1 = and_dcpl_28 & or_tmp_58 & main_stage_v_1;
  assign or_417_nl = or_75_cse | and_dcpl_56;
  assign or_415_nl = lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 | (or_467_cse &
      plm_out_rsci_bawt) | and_dcpl_56;
  assign mux_259_nl = MUX_s_1_2_2(or_417_nl, or_415_nl, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1);
  assign or_418_nl = STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 | mux_259_nl;
  assign mux_260_nl = MUX_s_1_2_2(and_dcpl_56, or_418_nl, main_stage_v_2);
  assign main_stage_v_3_mx0c1 = (~ mux_260_nl) & or_dcpl_11 & main_stage_v_3;
  assign main_stage_v_4_mx0c1 = (and_dcpl_56 | (~ main_stage_v_3)) & or_dcpl_10 &
      main_stage_v_4;
  assign exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1 = and_dcpl_94 & and_dcpl_13;
  assign plm_out_rsci_radr_d = STORE_INNER_LOOP_i_mux_rmff;
  assign plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_iswt0 <= 1'b0;
    end
    else if ( core_wen & (or_tmp_347 | conf_info_rsci_iswt0_mx0c1) ) begin
      conf_info_rsci_iswt0 <= (~ conf_info_rsci_iswt0_mx0c1) | or_tmp_347;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      conf_info_rsci_irdy_core_psct <= 1'b0;
    end
    else if ( core_wen & (or_tmp_347 | and_324_cse) ) begin
      conf_info_rsci_irdy_core_psct <= ~ and_324_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_STORE_BATCH_LOOP_sva <= 1'b1;
    end
    else if ( core_wen & (~(or_dcpl | and_dcpl_5 | (fsm_output[0]))) ) begin
      exitL_exit_STORE_BATCH_LOOP_sva <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_idat_31_0 <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & (~(or_dcpl_7 | or_dcpl_6)) ) begin
      dma_write_chnl_rsci_idat_31_0 <= plm_out_rsci_q_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_idat_31_7 <= 25'b0000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_152_cse) | and_dcpl_5 | ((~ mux_163_nl) & (fsm_output[0]))))
        ) begin
      dma_write_ctrl_rsci_idat_31_7 <= MUX_v_25_2_2(STORE_BATCH_LOOP_acc_3_psp_lpi_1,
          STORE_BATCH_LOOP_acc_3_psp_sva_1, or_444_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_rsc_req_obj_iswt0 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_28 & dma_write_ctrl_rsci_bawt & dma_write_ctrl_rsci_irdy_mxwt
        & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1) & and_dcpl_24) | plm_out_rsc_req_obj_iswt0_mx0c1)
        ) begin
      plm_out_rsc_req_obj_iswt0 <= ~ plm_out_rsc_req_obj_iswt0_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_plm_out_rsc_rls_obj_ld_core_psct_cse <= 1'b0;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= 1'b0;
      reg_plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= 1'b0;
      plm_out_rsci_radr_d_reg <= 7'b0000000;
      STORE_INNER_LOOP_i_7_0_lpi_1_6_0 <= 7'b0000000;
      lfst_exit_STORE_INNER_LOOP_lpi_1_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_0 <= 1'b0;
    end
    else if ( core_wen ) begin
      reg_plm_out_rsc_rls_obj_ld_core_psct_cse <= and_dcpl_28 & and_dcpl_39 & (~
          STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1) & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1
          & main_stage_v_1;
      reg_dma_write_ctrl_rsci_ivld_core_psct_cse <= mux_152_cse & or_63_cse & (fsm_output[1]);
      reg_plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_psct_cse <= and_197_rmff;
      plm_out_rsci_radr_d_reg <= STORE_INNER_LOOP_i_mux_rmff;
      STORE_INNER_LOOP_i_7_0_lpi_1_6_0 <= MUX_v_7_2_2(STORE_INNER_LOOP_i_7_0_lpi_1_6_0_mx0w0,
          STORE_INNER_LOOP_i_7_0_lpi_1_6_0, or_281_nl);
      lfst_exit_STORE_INNER_LOOP_lpi_1_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_1_mx0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_0_mx0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_done_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_51 & main_stage_v_3 & exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3)
        | and_dcpl_57) ) begin
      reg_done_rsci_ivld_core_psct_cse <= ~ and_dcpl_57;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_62 | and_dcpl_67) ) begin
      reg_dma_write_chnl_rsci_ivld_core_psct_cse <= ~ and_dcpl_67;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_asn_itm <= 1'b1;
    end
    else if ( core_wen & ((main_stage_en_5 & (fsm_output[1])) | (main_stage_v_1 &
        main_stage_en_5)) ) begin
      STORE_BATCH_LOOP_asn_itm <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_mx1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3 <= 1'b0;
    end
    else if ( core_wen & (and_350_cse | (mux_196_nl & or_dcpl_11 & or_63_cse & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1)
        | and_dcpl_96) ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3 <= MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
          STORE_INNER_LOOP_mux_20_nl, and_dcpl_96);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_acc_3_psp_lpi_1 <= 25'b0000000000000000000000000;
    end
    else if ( core_wen & (~((~ mux_211_nl) & and_dcpl_13)) ) begin
      STORE_BATCH_LOOP_acc_3_psp_lpi_1 <= STORE_BATCH_LOOP_acc_3_psp_sva_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_b_4_0_lpi_1_3_0 <= 4'b0000;
    end
    else if ( core_wen & ((and_dcpl_95 & (STORE_INNER_LOOP_acc_1_tmp[7]) & (~ exit_STORE_BATCH_LOOP_lpi_1_dfm_3)
        & (~ exitL_exit_STORE_BATCH_LOOP_sva)) | STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1)
        ) begin
      STORE_BATCH_LOOP_b_4_0_lpi_1_3_0 <= MUX_v_4_2_2((STORE_BATCH_LOOP_acc_2_tmp[3:0]),
          STORE_BATCH_LOOP_b_4_0_lpi_1_dfm_3_0_1, STORE_BATCH_LOOP_b_4_0_lpi_1_3_0_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_104 | and_dcpl_80) ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1 <= MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1,
          (~ (STORE_INNER_LOOP_acc_1_tmp[7])), and_dcpl_80);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      batch_lpi_1_dfm <= 32'b00000000000000000000000000000000;
    end
    else if ( core_wen & exitL_exit_STORE_BATCH_LOOP_sva ) begin
      batch_lpi_1_dfm <= conf_info_rsci_idat_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_80 & (fsm_output[1])) | and_dcpl_104) ) begin
      main_stage_v_1 <= ~ and_dcpl_104;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= 1'b0;
    end
    else if ( core_wen & (((~ main_stage_v_1) & and_dcpl_105 & and_dcpl_13) | and_dcpl_17)
        ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1 <= MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1,
          exit_STORE_BATCH_LOOP_lpi_1_dfm_4, and_dcpl_17);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_or_tmp_1 <= 1'b0;
      STORE_INNER_LOOP_equal_tmp_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_10_cse ) begin
      STORE_INNER_LOOP_or_tmp_1 <= (lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0
          & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0)) | (~(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0
          | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0));
      STORE_INNER_LOOP_equal_tmp_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0
          & (~ lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0);
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_i_7_0_sva_1_1_6_0 <= 7'b0000000;
    end
    else if ( core_wen & (~(or_dcpl_29 | (and_dcpl_87 & main_stage_v_1))) ) begin
      STORE_INNER_LOOP_i_7_0_sva_1_1_6_0 <= STORE_INNER_LOOP_acc_1_tmp[6:0];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_96 | and_350_cse | and_dcpl_104) ) begin
      STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1 <= MUX1HOT_s_1_3_2((STORE_INNER_LOOP_acc_1_tmp[7]),
          STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm, exitL_exit_STORE_INNER_LOOP_lpi_1_dfm_mx0w0,
          {and_dcpl_96 , and_350_cse , and_dcpl_104});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_108 & or_63_cse & (fsm_output[1])) | (mux_241_nl
        & or_dcpl_11 & or_63_cse & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1)
        | lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1) ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1 <= MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0,
          lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_108 | and_dcpl_113) ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0 <= MUX_s_1_2_2(lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0,
          lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0, and_dcpl_113);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_105 & or_63_cse & and_dcpl_13) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1)
        ) begin
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1 <= MUX_s_1_2_2(STORE_BATCH_LOOP_if_mux_3_nl,
          exit_STORE_BATCH_LOOP_lpi_1_dfm_4, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_2 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_83 & main_stage_v_1) | main_stage_v_2_mx0c1)
        ) begin
      main_stage_v_2 <= ~ main_stage_v_2_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_CTRL_LOOP_sva_st_1 <= 1'b0;
    end
    else if ( core_wen & (and_dcpl_75 | exit_STORE_CTRL_LOOP_sva_st_1_mx0c1) ) begin
      exit_STORE_CTRL_LOOP_sva_st_1 <= MUX_s_1_2_2(dma_write_ctrl_rsci_irdy_mxwt,
          exit_STORE_CTRL_LOOP_sva_st, exit_STORE_CTRL_LOOP_sva_st_1_mx0c1);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 <= 1'b0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_i_and_2_cse ) begin
      STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_2 <= STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2 <= STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_3 <= 1'b0;
    end
    else if ( core_wen & ((mux_tmp_242 & or_dcpl_11 & main_stage_v_2) | main_stage_v_3_mx0c1)
        ) begin
      main_stage_v_3 <= ~ main_stage_v_3_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0 <= 1'b0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_18_cse ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_1;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_3_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_2_0;
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_3 <= STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_7) ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3 <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      main_stage_v_4 <= 1'b0;
    end
    else if ( core_wen & ((and_dcpl_51 & main_stage_v_3) | main_stage_v_4_mx0c1)
        ) begin
      main_stage_v_4 <= ~ main_stage_v_4_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4 <= 1'b0;
    end
    else if ( core_wen & (~(and_dcpl_56 | and_dcpl_7 | (~ main_stage_v_3))) ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_4 <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_3;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_CTRL_LOOP_sva_st <= 1'b0;
    end
    else if ( core_wen & (~ (fsm_output[0])) & (~(or_tmp_58 | (~ main_stage_v_1)))
        ) begin
      exit_STORE_CTRL_LOOP_sva_st <= dma_write_ctrl_rsci_irdy_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1 <= 1'b0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_20_cse ) begin
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_1_mx0w0;
      lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_0 <= lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_0_mx0w0;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2 <= 1'b0;
    end
    else if ( core_wen & (~ or_dcpl_29) ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_2 <= exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm <= 1'b0;
    end
    else if ( core_wen & (~(mux_tmp_186 | and_dcpl_7 | or_tmp_1)) ) begin
      STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm <= STORE_INNER_LOOP_acc_1_tmp[7];
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1 <= 1'b0;
    end
    else if ( core_wen & (mux_tmp_176 | exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1)
        ) begin
      exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1 <= MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
          STORE_INNER_LOOP_mux_6_nl, exit_STORE_BATCH_LOOP_lpi_1_dfm_3_st_1_mx0c1);
    end
  end
  assign or_444_nl = (and_dcpl_18 & STORE_BATCH_LOOP_acc_itm_32_1 & (fsm_output[1]))
      | (and_dcpl_22 & STORE_BATCH_LOOP_acc_itm_32_1 & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign nor_85_nl = ~(lfst_exit_STORE_INNER_LOOP_lpi_1_1 | (~ and_tmp_3));
  assign mux_160_nl = MUX_s_1_2_2(nor_85_nl, and_133_cse, STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1);
  assign mux_161_nl = MUX_s_1_2_2(mux_160_nl, and_tmp_98, STORE_BATCH_LOOP_if_asn_sft_lpi_1);
  assign nor_86_nl = ~(and_392_cse | (~ or_tmp_29) | STORE_BATCH_LOOP_if_asn_sft_lpi_1
      | (~ and_tmp_98));
  assign mux_157_nl = MUX_s_1_2_2(nor_86_nl, mux_146_cse, STORE_INNER_LOOP_or_tmp_1);
  assign mux_158_nl = MUX_s_1_2_2(mux_157_nl, and_tmp_98, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign and_130_nl = or_25_cse & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1
      & STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_3;
  assign mux_159_nl = MUX_s_1_2_2(mux_158_nl, and_130_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1);
  assign mux_162_nl = MUX_s_1_2_2(mux_161_nl, mux_159_nl, main_stage_v_1);
  assign and_129_nl = or_369_cse & STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1
      & STORE_BATCH_LOOP_acc_itm_32_1 & and_tmp_3;
  assign mux_163_nl = MUX_s_1_2_2(mux_162_nl, and_129_nl, or_tmp_1);
  assign or_281_nl = or_dcpl_29 | and_dcpl_87 | (~ main_stage_v_1);
  assign STORE_INNER_LOOP_mux_20_nl = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      (STORE_BATCH_LOOP_acc_2_tmp[4]), STORE_INNER_LOOP_acc_1_tmp[7]);
  assign mux_194_nl = MUX_s_1_2_2(and_281_cse, and_227_cse, nor_55_cse);
  assign and_226_nl = (nor_tmp_50 | (~ main_stage_v_1) | STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1)
      & mux_15_cse;
  assign mux_193_nl = MUX_s_1_2_2(and_226_nl, and_227_cse, lfst_exit_STORE_INNER_LOOP_lpi_1_dfm_st_1_1);
  assign mux_195_nl = MUX_s_1_2_2(mux_194_nl, mux_193_nl, STORE_INNER_LOOP_or_tmp_1);
  assign mux_196_nl = MUX_s_1_2_2(mux_195_nl, and_281_cse, or_tmp_105);
  assign or_325_nl = or_tmp_78 | (~ STORE_INNER_LOOP_or_tmp_1);
  assign mux_211_nl = MUX_s_1_2_2(STORE_INNER_LOOP_i_slc_STORE_INNER_LOOP_i_7_0_7_itm_1,
      or_325_nl, main_stage_v_1);
  assign nand_53_nl = ~(or_tmp_158 & main_stage_v_1 & or_tmp_29 & mux_15_cse);
  assign nand_54_nl = ~(main_stage_v_1 & mux_15_cse);
  assign mux_240_nl = MUX_s_1_2_2(nand_53_nl, nand_54_nl, STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_st_1);
  assign nor_74_nl = ~(or_tmp_105 | mux_240_nl);
  assign mux_241_nl = MUX_s_1_2_2(nor_74_nl, and_281_cse, STORE_BATCH_LOOP_acc_itm_32_1);
  assign STORE_BATCH_LOOP_if_mux_3_nl = MUX_s_1_2_2(STORE_BATCH_LOOP_if_asn_sft_lpi_1,
      STORE_BATCH_LOOP_if_asn_sft_lpi_1_dfm_1, main_stage_v_1);
  assign STORE_INNER_LOOP_mux_6_nl = MUX_s_1_2_2(exit_STORE_BATCH_LOOP_lpi_1_dfm_4,
      (STORE_BATCH_LOOP_acc_2_tmp[4]), STORE_INNER_LOOP_acc_1_tmp[7]);

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


  function automatic [0:0] readslicef_33_1_32;
    input [32:0] vector;
    reg [32:0] tmp;
  begin
    tmp = vector >> 32;
    readslicef_33_1_32 = tmp[0:0];
  end
  endfunction


  function automatic [6:0] signext_7_1;
    input [0:0] vector;
  begin
    signext_7_1= {{6{vector[0]}}, vector};
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


  function automatic [32:0] conv_u2u_32_33 ;
    input [31:0]  vector ;
  begin
    conv_u2u_32_33 = {1'b0, vector};
  end
  endfunction

endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core (
  clk, rst, acc_done_rsc_vld, config_done_cns_rdy, config_done_cns_vld, load_done_cns_rdy,
      load_done_cns_vld, compute_done_cns_rdy, compute_done_cns_vld, store_done_cns_rdy,
      store_done_cns_vld
);
  input clk;
  input rst;
  output acc_done_rsc_vld;
  output config_done_cns_rdy;
  input config_done_cns_vld;
  output load_done_cns_rdy;
  input load_done_cns_vld;
  output compute_done_cns_rdy;
  input compute_done_cns_vld;
  output store_done_cns_rdy;
  input store_done_cns_vld;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_core_core softmax_cxx_core_core_inst (
      .clk(clk),
      .rst(rst),
      .acc_done_rsc_vld(acc_done_rsc_vld),
      .config_done_cns_rdy(config_done_cns_rdy),
      .config_done_cns_vld(config_done_cns_vld),
      .load_done_cns_rdy(load_done_cns_rdy),
      .load_done_cns_vld(load_done_cns_vld),
      .compute_done_cns_rdy(compute_done_cns_rdy),
      .compute_done_cns_vld(compute_done_cns_vld),
      .store_done_cns_rdy(store_done_cns_rdy),
      .store_done_cns_vld(store_done_cns_vld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_config
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_config (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_conf_load_rsc_dat,
      plm_conf_load_rsc_vld, plm_conf_load_rsc_rdy, plm_conf_compute_rsc_dat, plm_conf_compute_rsc_vld,
      plm_conf_compute_rsc_rdy, plm_conf_store_rsc_dat, plm_conf_store_rsc_vld, plm_conf_store_rsc_rdy,
      done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [31:0] plm_conf_load_rsc_dat;
  output plm_conf_load_rsc_vld;
  input plm_conf_load_rsc_rdy;
  output [31:0] plm_conf_compute_rsc_dat;
  output plm_conf_compute_rsc_vld;
  input plm_conf_compute_rsc_rdy;
  output [31:0] plm_conf_store_rsc_dat;
  output plm_conf_store_rsc_vld;
  input plm_conf_store_rsc_rdy;
  input done_rsc_rdy;
  output done_rsc_vld;



  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_config_core config_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_load
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_load (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_wadr,
      plm_in_rsc_d, plm_in_rsc_we, plm_in_rsc_req_vz, plm_in_rsc_rls_lz, dma_read_ctrl_rsc_dat,
      dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy, dma_read_chnl_rsc_dat, dma_read_chnl_rsc_vld,
      dma_read_chnl_rsc_rdy, done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
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
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire [31:0] plm_in_rsci_d_d;
  wire [6:0] plm_in_rsci_wadr_d;
  wire plm_in_rsci_we_d_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_load_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_7_7_32_128_128_32_1_gen
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
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .dma_read_chnl_rsc_dat(dma_read_chnl_rsc_dat),
      .dma_read_chnl_rsc_vld(dma_read_chnl_rsc_vld),
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .plm_in_rsci_d_d(plm_in_rsci_d_d),
      .plm_in_rsci_wadr_d(plm_in_rsci_wadr_d),
      .plm_in_rsci_we_d_pff(plm_in_rsci_we_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_compute
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_compute (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_in_rsc_radr,
      plm_in_rsc_q, plm_in_rsc_req_vz, plm_in_rsc_rls_lz, plm_out_rsc_wadr, plm_out_rsc_d,
      plm_out_rsc_we, plm_out_rsc_req_vz, plm_out_rsc_rls_lz, done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
  output [6:0] plm_in_rsc_radr;
  input [31:0] plm_in_rsc_q;
  input plm_in_rsc_req_vz;
  output plm_in_rsc_rls_lz;
  output [6:0] plm_out_rsc_wadr;
  output [31:0] plm_out_rsc_d;
  output plm_out_rsc_we;
  input plm_out_rsc_req_vz;
  output plm_out_rsc_rls_lz;
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire [31:0] plm_in_rsci_q_d;
  wire [6:0] plm_in_rsci_radr_d;
  wire plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_rsci_d_d;
  wire [6:0] plm_out_rsci_wadr_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire [93:0] CALC_SOFTMAX_LOOP_mul_cmp_b;
  wire CALC_SOFTMAX_LOOP_mul_cmp_en;
  wire [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_clken;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_q;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_radr;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_we;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_d;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsc_wadr;
  wire plm_out_rsci_we_d_iff;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff;
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
  .s_rst_active(32'sd0),
  .stages(32'sd6),
  .n_inreg(32'sd1)) CALC_SOFTMAX_LOOP_mul_cmp (
      .a(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .b(CALC_SOFTMAX_LOOP_mul_cmp_b),
      .clk(clk),
      .en(CALC_SOFTMAX_LOOP_mul_cmp_en),
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
  esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_13_7_32_128_128_32_1_gen
      plm_in_rsci (
      .q(plm_in_rsc_q),
      .radr(plm_in_rsc_radr),
      .q_d(plm_in_rsci_q_d),
      .radr_d(plm_in_rsci_radr_d),
      .readA_r_ram_ir_internal_RMASK_B_d(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_wport_14_7_32_128_128_32_1_gen
      plm_out_rsci (
      .we(plm_out_rsc_we),
      .d(plm_out_rsc_d),
      .wadr(plm_out_rsc_wadr),
      .d_d(plm_out_rsci_d_d),
      .wadr_d(plm_out_rsci_wadr_d),
      .we_d(plm_out_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(plm_out_rsci_we_d_iff)
    );
  esp_acc_softmax_cxx_compute_Xilinx_RAMS_BLOCK_1R1W_RBW_rwport_en_18_7_67_128_128_67_1_gen
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
      .radr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff),
      .wadr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff),
      .we_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff),
      .readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
  esp_acc_softmax_cxx_compute_core compute_core_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .plm_in_rsci_q_d(plm_in_rsci_q_d),
      .plm_in_rsci_radr_d(plm_in_rsci_radr_d),
      .plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_in_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .plm_out_rsci_d_d(plm_out_rsci_d_d),
      .plm_out_rsci_wadr_d(plm_out_rsci_wadr_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .CALC_SOFTMAX_LOOP_mul_cmp_b(CALC_SOFTMAX_LOOP_mul_cmp_b),
      .CALC_SOFTMAX_LOOP_mul_cmp_en(CALC_SOFTMAX_LOOP_mul_cmp_en),
      .CALC_SOFTMAX_LOOP_mul_cmp_z(CALC_SOFTMAX_LOOP_mul_cmp_z),
      .plm_out_rsci_we_d_pff(plm_out_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_store
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_store (
  clk, rst, conf_info_rsc_dat, conf_info_rsc_vld, conf_info_rsc_rdy, plm_out_rsc_radr,
      plm_out_rsc_q, plm_out_rsc_req_vz, plm_out_rsc_rls_lz, dma_write_ctrl_rsc_dat,
      dma_write_ctrl_rsc_vld, dma_write_ctrl_rsc_rdy, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld,
      dma_write_chnl_rsc_rdy, done_rsc_rdy, done_rsc_vld
);
  input clk;
  input rst;
  input [31:0] conf_info_rsc_dat;
  input conf_info_rsc_vld;
  output conf_info_rsc_rdy;
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
  input done_rsc_rdy;
  output done_rsc_vld;


  // Interconnect Declarations
  wire [31:0] plm_out_rsci_q_d;
  wire [6:0] plm_out_rsci_radr_d;
  wire plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_store_Xilinx_RAMS_BLOCK_1R1W_RBW_rport_24_7_32_128_128_32_1_gen
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
      .conf_info_rsc_dat(conf_info_rsc_dat),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz),
      .dma_write_ctrl_rsc_dat(dma_write_ctrl_rsc_dat),
      .dma_write_ctrl_rsc_vld(dma_write_ctrl_rsc_vld),
      .dma_write_ctrl_rsc_rdy(dma_write_ctrl_rsc_rdy),
      .dma_write_chnl_rsc_dat(dma_write_chnl_rsc_dat),
      .dma_write_chnl_rsc_vld(dma_write_chnl_rsc_vld),
      .dma_write_chnl_rsc_rdy(dma_write_chnl_rsc_rdy),
      .done_rsc_rdy(done_rsc_rdy),
      .done_rsc_vld(done_rsc_vld),
      .plm_out_rsci_q_d(plm_out_rsci_q_d),
      .plm_out_rsci_radr_d(plm_out_rsci_radr_d),
      .plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_rsci_readA_r_ram_ir_internal_RMASK_B_d)
    );
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
  wire [31:0] plm_conf_load_rsc_dat_nconfig_inst;
  wire plm_conf_load_rsc_rdy_nconfig_inst;
  wire [31:0] plm_conf_compute_rsc_dat_nconfig_inst;
  wire plm_conf_compute_rsc_rdy_nconfig_inst;
  wire [31:0] plm_conf_store_rsc_dat_nconfig_inst;
  wire plm_conf_store_rsc_rdy_nconfig_inst;
  wire done_rsc_rdy_nconfig_inst;
  wire [31:0] conf_info_rsc_dat_nload_inst;
  wire conf_info_rsc_vld_nload_inst;
  wire conf_info_rsc_rdy_nload_inst;
  wire [6:0] plm_in_rsc_wadr_nload_inst;
  wire [31:0] plm_in_rsc_d_nload_inst;
  wire plm_in_rsc_we_nload_inst;
  wire plm_in_rsc_req_vz_nload_inst;
  wire [66:0] dma_read_ctrl_rsc_dat_nload_inst;
  wire dma_read_ctrl_rsc_vld_nload_inst;
  wire dma_read_chnl_rsc_rdy_nload_inst;
  wire done_rsc_rdy_nload_inst;
  wire done_rsc_vld_nload_inst;
  wire [31:0] conf_info_rsc_dat_ncompute_inst;
  wire conf_info_rsc_vld_ncompute_inst;
  wire conf_info_rsc_rdy_ncompute_inst;
  wire [6:0] plm_in_rsc_radr_ncompute_inst;
  wire [31:0] plm_in_rsc_q_ncompute_inst;
  wire plm_in_rsc_req_vz_ncompute_inst;
  wire [6:0] plm_out_rsc_wadr_ncompute_inst;
  wire [31:0] plm_out_rsc_d_ncompute_inst;
  wire plm_out_rsc_we_ncompute_inst;
  wire plm_out_rsc_req_vz_ncompute_inst;
  wire done_rsc_rdy_ncompute_inst;
  wire done_rsc_vld_ncompute_inst;
  wire plm_out_rsc_we_ncompute_inst_buz;
  wire [31:0] conf_info_rsc_dat_nstore_inst;
  wire conf_info_rsc_vld_nstore_inst;
  wire conf_info_rsc_rdy_nstore_inst;
  wire [6:0] plm_out_rsc_radr_nstore_inst;
  wire [31:0] plm_out_rsc_q_nstore_inst;
  wire plm_out_rsc_req_vz_nstore_inst;
  wire [66:0] dma_write_ctrl_rsc_dat_nstore_inst;
  wire dma_write_ctrl_rsc_vld_nstore_inst;
  wire [63:0] dma_write_chnl_rsc_dat_nstore_inst;
  wire dma_write_chnl_rsc_vld_nstore_inst;
  wire done_rsc_rdy_nstore_inst;
  wire done_rsc_vld_nstore_inst;
  wire config_done_cns_vld_nsoftmax_cxx_core_inst;
  wire load_done_cns_vld_nsoftmax_cxx_core_inst;
  wire compute_done_cns_vld_nsoftmax_cxx_core_inst;
  wire store_done_cns_vld_nsoftmax_cxx_core_inst;
  wire conf_info_rsc_rdy_nconfig_inst_bud;
  wire plm_conf_load_rsc_vld_nconfig_inst_bud;
  wire conf_info_rsc_rdy_nload_inst_bud;
  wire plm_conf_compute_rsc_vld_nconfig_inst_bud;
  wire conf_info_rsc_rdy_ncompute_inst_bud;
  wire plm_conf_store_rsc_vld_nconfig_inst_bud;
  wire conf_info_rsc_rdy_nstore_inst_bud;
  wire done_rsc_vld_nconfig_inst_bud;
  wire config_done_cns_rdy_nsoftmax_cxx_core_inst_bud;
  wire plm_in_rsc_rls_lz_nload_inst_bud;
  wire plm_in_rsc_rls_lz_ncompute_inst_bud;
  wire dma_read_ctrl_rsc_vld_nload_inst_bud;
  wire dma_read_chnl_rsc_rdy_nload_inst_bud;
  wire done_rsc_vld_nload_inst_bud;
  wire load_done_cns_rdy_nsoftmax_cxx_core_inst_bud;
  wire plm_out_rsc_we_ncompute_inst_buz_bud;
  wire plm_out_rsc_rls_lz_ncompute_inst_bud;
  wire plm_out_rsc_rls_lz_nstore_inst_bud;
  wire done_rsc_vld_ncompute_inst_bud;
  wire compute_done_cns_rdy_nsoftmax_cxx_core_inst_bud;
  wire dma_write_ctrl_rsc_vld_nstore_inst_bud;
  wire dma_write_chnl_rsc_vld_nstore_inst_bud;
  wire done_rsc_vld_nstore_inst_bud;
  wire store_done_cns_rdy_nsoftmax_cxx_core_inst_bud;
  wire acc_done_rsc_vld_nsoftmax_cxx_core_inst_bud;
  wire plm_conf_load_unc_2;
  wire plm_conf_load_idle;
  wire plm_conf_compute_unc_2;
  wire plm_conf_compute_idle;
  wire plm_conf_store_unc_2;
  wire plm_conf_store_idle;
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
  esp_acc_softmax_cxx_ccs_pipe_v5 #(.rscid(32'sd37),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd3),
  .log2_sz(32'sd2),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_load_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_conf_load_rsc_rdy_nconfig_inst),
      .din_vld(plm_conf_load_rsc_vld_nconfig_inst_bud),
      .din(plm_conf_load_rsc_dat_nconfig_inst),
      .dout_rdy(conf_info_rsc_rdy_nload_inst),
      .dout_vld(conf_info_rsc_vld_nload_inst),
      .dout(conf_info_rsc_dat_nload_inst),
      .sz(plm_conf_load_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_conf_load_idle)
    );
  esp_acc_softmax_cxx_ccs_pipe_v5 #(.rscid(32'sd38),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd14),
  .log2_sz(32'sd4),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_compute_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_conf_compute_rsc_rdy_nconfig_inst),
      .din_vld(plm_conf_compute_rsc_vld_nconfig_inst_bud),
      .din(plm_conf_compute_rsc_dat_nconfig_inst),
      .dout_rdy(conf_info_rsc_rdy_ncompute_inst),
      .dout_vld(conf_info_rsc_vld_ncompute_inst),
      .dout(conf_info_rsc_dat_ncompute_inst),
      .sz(plm_conf_compute_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_conf_compute_idle)
    );
  esp_acc_softmax_cxx_ccs_pipe_v5 #(.rscid(32'sd39),
  .width(32'sd32),
  .sz_width(32'sd1),
  .fifo_sz(32'sd4),
  .log2_sz(32'sd2),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) plm_conf_store_cns_pipe (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .din_rdy(plm_conf_store_rsc_rdy_nconfig_inst),
      .din_vld(plm_conf_store_rsc_vld_nconfig_inst_bud),
      .din(plm_conf_store_rsc_dat_nconfig_inst),
      .dout_rdy(conf_info_rsc_rdy_nstore_inst),
      .dout_vld(conf_info_rsc_vld_nstore_inst),
      .dout(conf_info_rsc_dat_nstore_inst),
      .sz(plm_conf_store_unc_2),
      .sz_req(1'b0),
      .is_idle(plm_conf_store_idle)
    );
  esp_acc_softmax_cxx_ccs_sync_pipe_v1 #(.rscid(32'sd40)) config_done_cns_pipe (
      .dout_rdy(done_rsc_vld_nconfig_inst_bud),
      .dout_vld(done_rsc_rdy_nconfig_inst),
      .din_vld(config_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .din_rdy(config_done_cns_vld_nsoftmax_cxx_core_inst)
    );
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
  esp_acc_softmax_cxx_ccs_sync_pipe_v1 #(.rscid(32'sd41)) load_done_cns_pipe (
      .dout_rdy(done_rsc_vld_nload_inst),
      .dout_vld(done_rsc_rdy_nload_inst),
      .din_vld(load_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .din_rdy(load_done_cns_vld_nsoftmax_cxx_core_inst)
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
  esp_acc_softmax_cxx_ccs_sync_pipe_v1 #(.rscid(32'sd42)) compute_done_cns_pipe (
      .dout_rdy(done_rsc_vld_ncompute_inst),
      .dout_vld(done_rsc_rdy_ncompute_inst),
      .din_vld(compute_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .din_rdy(compute_done_cns_vld_nsoftmax_cxx_core_inst)
    );
  esp_acc_softmax_cxx_ccs_sync_pipe_v1 #(.rscid(32'sd43)) store_done_cns_pipe (
      .dout_rdy(done_rsc_vld_nstore_inst),
      .dout_vld(done_rsc_rdy_nstore_inst),
      .din_vld(store_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .din_rdy(store_done_cns_vld_nsoftmax_cxx_core_inst)
    );
  esp_acc_softmax_cxx_config config_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_batch),
      .conf_info_rsc_vld(conf_info_rsc_vld),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_nconfig_inst_bud),
      .plm_conf_load_rsc_dat(plm_conf_load_rsc_dat_nconfig_inst),
      .plm_conf_load_rsc_vld(plm_conf_load_rsc_vld_nconfig_inst_bud),
      .plm_conf_load_rsc_rdy(plm_conf_load_rsc_rdy_nconfig_inst),
      .plm_conf_compute_rsc_dat(plm_conf_compute_rsc_dat_nconfig_inst),
      .plm_conf_compute_rsc_vld(plm_conf_compute_rsc_vld_nconfig_inst_bud),
      .plm_conf_compute_rsc_rdy(plm_conf_compute_rsc_rdy_nconfig_inst),
      .plm_conf_store_rsc_dat(plm_conf_store_rsc_dat_nconfig_inst),
      .plm_conf_store_rsc_vld(plm_conf_store_rsc_vld_nconfig_inst_bud),
      .plm_conf_store_rsc_rdy(plm_conf_store_rsc_rdy_nconfig_inst),
      .done_rsc_rdy(done_rsc_rdy_nconfig_inst),
      .done_rsc_vld(done_rsc_vld_nconfig_inst_bud)
    );
  esp_acc_softmax_cxx_load load_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_nload_inst),
      .conf_info_rsc_vld(conf_info_rsc_vld_nload_inst),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_nload_inst_bud),
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
      .dma_read_chnl_rsc_rdy(dma_read_chnl_rsc_rdy_nload_inst_bud),
      .done_rsc_rdy(done_rsc_rdy_nload_inst),
      .done_rsc_vld(done_rsc_vld_nload_inst_bud)
    );
  esp_acc_softmax_cxx_compute compute_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_ncompute_inst),
      .conf_info_rsc_vld(conf_info_rsc_vld_ncompute_inst),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_ncompute_inst_bud),
      .plm_in_rsc_radr(plm_in_rsc_radr_ncompute_inst),
      .plm_in_rsc_q(plm_in_rsc_q_ncompute_inst),
      .plm_in_rsc_req_vz(plm_in_rsc_req_vz_ncompute_inst),
      .plm_in_rsc_rls_lz(plm_in_rsc_rls_lz_ncompute_inst_bud),
      .plm_out_rsc_wadr(plm_out_rsc_wadr_ncompute_inst),
      .plm_out_rsc_d(plm_out_rsc_d_ncompute_inst),
      .plm_out_rsc_we(plm_out_rsc_we_ncompute_inst),
      .plm_out_rsc_req_vz(plm_out_rsc_req_vz_ncompute_inst),
      .plm_out_rsc_rls_lz(plm_out_rsc_rls_lz_ncompute_inst_bud),
      .done_rsc_rdy(done_rsc_rdy_ncompute_inst),
      .done_rsc_vld(done_rsc_vld_ncompute_inst_bud)
    );
  esp_acc_softmax_cxx_store store_inst (
      .clk(clk),
      .rst(rst),
      .conf_info_rsc_dat(conf_info_rsc_dat_nstore_inst),
      .conf_info_rsc_vld(conf_info_rsc_vld_nstore_inst),
      .conf_info_rsc_rdy(conf_info_rsc_rdy_nstore_inst_bud),
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
      .done_rsc_rdy(done_rsc_rdy_nstore_inst),
      .done_rsc_vld(done_rsc_vld_nstore_inst_bud)
    );
  esp_acc_softmax_cxx_softmax_cxx_core softmax_cxx_core_inst (
      .clk(clk),
      .rst(rst),
      .acc_done_rsc_vld(acc_done_rsc_vld_nsoftmax_cxx_core_inst_bud),
      .config_done_cns_rdy(config_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .config_done_cns_vld(config_done_cns_vld_nsoftmax_cxx_core_inst),
      .load_done_cns_rdy(load_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .load_done_cns_vld(load_done_cns_vld_nsoftmax_cxx_core_inst),
      .compute_done_cns_rdy(compute_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .compute_done_cns_vld(compute_done_cns_vld_nsoftmax_cxx_core_inst),
      .store_done_cns_rdy(store_done_cns_rdy_nsoftmax_cxx_core_inst_bud),
      .store_done_cns_vld(store_done_cns_vld_nsoftmax_cxx_core_inst)
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
      .conf_info_rsc_rdy_nload_inst(conf_info_rsc_rdy_nload_inst),
      .plm_in_rsc_wadr_nload_inst(plm_in_rsc_wadr_nload_inst),
      .plm_in_rsc_d_nload_inst(plm_in_rsc_d_nload_inst),
      .plm_in_rsc_we_nload_inst(plm_in_rsc_we_nload_inst),
      .plm_in_rsc_req_vz_nload_inst(plm_in_rsc_req_vz_nload_inst),
      .dma_read_ctrl_rsc_vld_nload_inst(dma_read_ctrl_rsc_vld_nload_inst),
      .dma_read_chnl_rsc_rdy_nload_inst(dma_read_chnl_rsc_rdy_nload_inst),
      .done_rsc_vld_nload_inst(done_rsc_vld_nload_inst),
      .conf_info_rsc_rdy_ncompute_inst(conf_info_rsc_rdy_ncompute_inst),
      .plm_in_rsc_radr_ncompute_inst(plm_in_rsc_radr_ncompute_inst),
      .plm_in_rsc_q_ncompute_inst(plm_in_rsc_q_ncompute_inst),
      .plm_in_rsc_req_vz_ncompute_inst(plm_in_rsc_req_vz_ncompute_inst),
      .done_rsc_vld_ncompute_inst(done_rsc_vld_ncompute_inst),
      .plm_out_rsc_we_ncompute_inst_buz(plm_out_rsc_we_ncompute_inst_buz),
      .conf_info_rsc_rdy_nload_inst_bud(conf_info_rsc_rdy_nload_inst_bud),
      .conf_info_rsc_rdy_ncompute_inst_bud(conf_info_rsc_rdy_ncompute_inst_bud),
      .plm_in_rsc_rls_lz_nload_inst_bud(plm_in_rsc_rls_lz_nload_inst_bud),
      .plm_in_rsc_rls_lz_ncompute_inst_bud(plm_in_rsc_rls_lz_ncompute_inst_bud),
      .dma_read_ctrl_rsc_vld_nload_inst_bud(dma_read_ctrl_rsc_vld_nload_inst_bud),
      .dma_read_chnl_rsc_rdy_nload_inst_bud(dma_read_chnl_rsc_rdy_nload_inst_bud),
      .done_rsc_vld_nload_inst_bud(done_rsc_vld_nload_inst_bud),
      .plm_out_rsc_we_ncompute_inst_buz_bud(plm_out_rsc_we_ncompute_inst_buz_bud),
      .plm_out_rsc_rls_lz_ncompute_inst_bud(1'b0),
      .done_rsc_vld_ncompute_inst_bud(done_rsc_vld_ncompute_inst_bud),
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
      .conf_info_rsc_rdy_nstore_inst(conf_info_rsc_rdy_nstore_inst),
      .plm_out_rsc_radr_nstore_inst(plm_out_rsc_radr_nstore_inst),
      .plm_out_rsc_q_nstore_inst(plm_out_rsc_q_nstore_inst),
      .plm_out_rsc_req_vz_nstore_inst(plm_out_rsc_req_vz_nstore_inst),
      .dma_write_ctrl_rsc_vld_nstore_inst(dma_write_ctrl_rsc_vld_nstore_inst),
      .dma_write_chnl_rsc_vld_nstore_inst(dma_write_chnl_rsc_vld_nstore_inst),
      .done_rsc_vld_nstore_inst(done_rsc_vld_nstore_inst),
      .conf_info_rsc_rdy_nstore_inst_bud(conf_info_rsc_rdy_nstore_inst_bud),
      .plm_out_rsc_we_ncompute_inst_buz_bud(plm_out_rsc_we_ncompute_inst_buz_bud),
      .plm_out_rsc_rls_lz_ncompute_inst_bud(plm_out_rsc_rls_lz_ncompute_inst_bud),
      .plm_out_rsc_rls_lz_nstore_inst_bud(plm_out_rsc_rls_lz_nstore_inst_bud),
      .dma_write_ctrl_rsc_vld_nstore_inst_bud(dma_write_ctrl_rsc_vld_nstore_inst_bud),
      .dma_write_chnl_rsc_vld_nstore_inst_bud(dma_write_chnl_rsc_vld_nstore_inst_bud),
      .done_rsc_vld_nstore_inst_bud(done_rsc_vld_nstore_inst_bud),
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
  assign conf_info_rsc_rdy = conf_info_rsc_rdy_nconfig_inst_bud;
  assign dma_read_ctrl_rsc_dat_index = dma_read_ctrl_rsc_dat_nload_inst[31:0];
  assign dma_read_ctrl_rsc_dat_length = dma_read_ctrl_rsc_dat_nload_inst[63:32];
  assign dma_read_ctrl_rsc_dat_size = dma_read_ctrl_rsc_dat_nload_inst[66:64];
  assign dma_write_ctrl_rsc_dat_index = dma_write_ctrl_rsc_dat_nstore_inst[31:0];
  assign dma_write_ctrl_rsc_dat_length = dma_write_ctrl_rsc_dat_nstore_inst[63:32];
  assign dma_write_ctrl_rsc_dat_size = dma_write_ctrl_rsc_dat_nstore_inst[66:64];
  assign dma_read_ctrl_rsc_vld = dma_read_ctrl_rsc_vld_nload_inst;
  assign dma_read_chnl_rsc_rdy = dma_read_chnl_rsc_rdy_nload_inst;
  assign dma_write_ctrl_rsc_vld = dma_write_ctrl_rsc_vld_nstore_inst;
  assign dma_write_chnl_rsc_vld = dma_write_chnl_rsc_vld_nstore_inst;
  assign dma_write_chnl_rsc_dat = dma_write_chnl_rsc_dat_nstore_inst;
  assign acc_done_rsc_vld = acc_done_rsc_vld_nsoftmax_cxx_core_inst_bud;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    softmax_cxx_hier_fx32_dma64
// ------------------------------------------------------------------


module softmax_cxx_hier_fx32_dma64 (
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



