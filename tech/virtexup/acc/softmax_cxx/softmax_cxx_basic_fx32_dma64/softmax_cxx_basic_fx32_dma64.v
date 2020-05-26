
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
//  Generated date: Tue May 26 13:47:13 2020
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
//  Generated date: Tue May 26 13:47:33 2020
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
  clk, rst, core_wen, fsm_output, CONFIG_LOOP_C_0_tr0, LOAD_OUTER_LOOP_C_0_tr0, COMPUTE_LOOP_C_0_tr0,
      STORE_OUTER_LOOP_C_0_tr0
);
  input clk;
  input rst;
  input core_wen;
  output [5:0] fsm_output;
  reg [5:0] fsm_output;
  input CONFIG_LOOP_C_0_tr0;
  input LOAD_OUTER_LOOP_C_0_tr0;
  input COMPUTE_LOOP_C_0_tr0;
  input STORE_OUTER_LOOP_C_0_tr0;


  // FSM State Type Declaration for esp_acc_softmax_cxx_softmax_cxx_core_core_fsm_1
  parameter
    main_C_0 = 3'd0,
    CONFIG_LOOP_C_0 = 3'd1,
    LOAD_OUTER_LOOP_C_0 = 3'd2,
    COMPUTE_LOOP_C_0 = 3'd3,
    STORE_OUTER_LOOP_C_0 = 3'd4,
    main_C_1 = 3'd5;

  reg [2:0] state_var;
  reg [2:0] state_var_NS;


  // Interconnect Declarations for Component Instantiations 
  always @(*)
  begin : esp_acc_softmax_cxx_softmax_cxx_core_core_fsm_1
    case (state_var)
      CONFIG_LOOP_C_0 : begin
        fsm_output = 6'b000010;
        if ( CONFIG_LOOP_C_0_tr0 ) begin
          state_var_NS = LOAD_OUTER_LOOP_C_0;
        end
        else begin
          state_var_NS = CONFIG_LOOP_C_0;
        end
      end
      LOAD_OUTER_LOOP_C_0 : begin
        fsm_output = 6'b000100;
        if ( LOAD_OUTER_LOOP_C_0_tr0 ) begin
          state_var_NS = COMPUTE_LOOP_C_0;
        end
        else begin
          state_var_NS = LOAD_OUTER_LOOP_C_0;
        end
      end
      COMPUTE_LOOP_C_0 : begin
        fsm_output = 6'b001000;
        if ( COMPUTE_LOOP_C_0_tr0 ) begin
          state_var_NS = STORE_OUTER_LOOP_C_0;
        end
        else begin
          state_var_NS = COMPUTE_LOOP_C_0;
        end
      end
      STORE_OUTER_LOOP_C_0 : begin
        fsm_output = 6'b010000;
        if ( STORE_OUTER_LOOP_C_0_tr0 ) begin
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
      // main_C_0
      default : begin
        fsm_output = 6'b000001;
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
  clk, rst, core_wen, core_wten, dma_read_ctrl_rsci_wen_comp, dma_write_ctrl_rsci_wen_comp,
      dma_read_chnl_rsci_wen_comp, dma_write_chnl_rsci_wen_comp
);
  input clk;
  input rst;
  output core_wen;
  output core_wten;
  input dma_read_ctrl_rsci_wen_comp;
  input dma_write_ctrl_rsci_wen_comp;
  input dma_read_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_wen_comp;


  // Interconnect Declarations
  reg core_wten_reg;


  // Interconnect Declarations for Component Instantiations 
  assign core_wen = dma_read_ctrl_rsci_wen_comp & dma_write_ctrl_rsci_wen_comp &
      dma_read_chnl_rsci_wen_comp & dma_write_chnl_rsci_wen_comp;
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_dp
    (
  clk, rst, plm_out_data_rsci_q_d, plm_out_data_rsci_q_d_mxwt, plm_out_data_rsci_biwt_1,
      plm_out_data_rsci_bdwt_2
);
  input clk;
  input rst;
  input [31:0] plm_out_data_rsci_q_d;
  output [31:0] plm_out_data_rsci_q_d_mxwt;
  input plm_out_data_rsci_biwt_1;
  input plm_out_data_rsci_bdwt_2;


  // Interconnect Declarations
  reg plm_out_data_rsci_bcwt_1;
  reg [31:0] plm_out_data_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_out_data_rsci_q_d_mxwt = MUX_v_32_2_2(plm_out_data_rsci_q_d, plm_out_data_rsci_q_d_bfwt,
      plm_out_data_rsci_bcwt_1);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_out_data_rsci_bcwt_1 <= 1'b0;
    end
    else begin
      plm_out_data_rsci_bcwt_1 <= ~((~(plm_out_data_rsci_bcwt_1 | plm_out_data_rsci_biwt_1))
          | plm_out_data_rsci_bdwt_2);
    end
  end
  always @(posedge clk) begin
    if ( plm_out_data_rsci_biwt_1 ) begin
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
  core_wen, core_wten, plm_out_data_rsci_oswt_unreg_1, plm_out_data_rsci_iswt0_1,
      plm_out_data_rsci_biwt_1, plm_out_data_rsci_bdwt_2, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      plm_out_data_rsci_we_d_core_sct_pff, plm_out_data_rsci_iswt0_pff, plm_out_data_rsci_iswt0_1_pff
);
  input core_wen;
  input core_wten;
  input plm_out_data_rsci_oswt_unreg_1;
  input plm_out_data_rsci_iswt0_1;
  output plm_out_data_rsci_biwt_1;
  output plm_out_data_rsci_bdwt_2;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  output plm_out_data_rsci_we_d_core_sct_pff;
  input plm_out_data_rsci_iswt0_pff;
  input plm_out_data_rsci_iswt0_1_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_out_data_rsci_bdwt_2 = plm_out_data_rsci_oswt_unreg_1 & core_wen;
  assign plm_out_data_rsci_biwt_1 = (~ core_wten) & plm_out_data_rsci_iswt0_1;
  assign plm_out_data_rsci_we_d_core_sct_pff = plm_out_data_rsci_iswt0_pff & core_wen;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_out_data_rsci_iswt0_1_pff
      & core_wen;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_dp
    (
  clk, rst, plm_in_data_rsci_q_d, plm_in_data_rsci_bawt, plm_in_data_rsci_q_d_mxwt,
      plm_in_data_rsci_biwt, plm_in_data_rsci_bdwt, plm_in_data_rsci_biwt_1, plm_in_data_rsci_bdwt_2
);
  input clk;
  input rst;
  input [31:0] plm_in_data_rsci_q_d;
  output plm_in_data_rsci_bawt;
  output [31:0] plm_in_data_rsci_q_d_mxwt;
  input plm_in_data_rsci_biwt;
  input plm_in_data_rsci_bdwt;
  input plm_in_data_rsci_biwt_1;
  input plm_in_data_rsci_bdwt_2;


  // Interconnect Declarations
  reg plm_in_data_rsci_bcwt;
  reg plm_in_data_rsci_bcwt_1;
  reg [31:0] plm_in_data_rsci_q_d_bfwt;


  // Interconnect Declarations for Component Instantiations 
  assign plm_in_data_rsci_bawt = plm_in_data_rsci_biwt | plm_in_data_rsci_bcwt;
  assign plm_in_data_rsci_q_d_mxwt = MUX_v_32_2_2(plm_in_data_rsci_q_d, plm_in_data_rsci_q_d_bfwt,
      plm_in_data_rsci_bcwt_1);
  always @(posedge clk) begin
    if ( ~ rst ) begin
      plm_in_data_rsci_bcwt <= 1'b0;
      plm_in_data_rsci_bcwt_1 <= 1'b0;
    end
    else begin
      plm_in_data_rsci_bcwt <= ~((~(plm_in_data_rsci_bcwt | plm_in_data_rsci_biwt))
          | plm_in_data_rsci_bdwt);
      plm_in_data_rsci_bcwt_1 <= ~((~(plm_in_data_rsci_bcwt_1 | plm_in_data_rsci_biwt_1))
          | plm_in_data_rsci_bdwt_2);
    end
  end
  always @(posedge clk) begin
    if ( plm_in_data_rsci_biwt_1 ) begin
      plm_in_data_rsci_q_d_bfwt <= plm_in_data_rsci_q_d;
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_ctrl
    (
  core_wen, core_wten, plm_in_data_rsci_oswt_unreg, plm_in_data_rsci_iswt0, plm_in_data_rsci_oswt_unreg_1,
      plm_in_data_rsci_iswt0_1, plm_in_data_rsci_biwt, plm_in_data_rsci_bdwt, plm_in_data_rsci_biwt_1,
      plm_in_data_rsci_bdwt_2, plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct,
      plm_in_data_rsci_we_d_core_sct_pff, plm_in_data_rsci_iswt0_pff, plm_in_data_rsci_iswt0_1_pff
);
  input core_wen;
  input core_wten;
  input plm_in_data_rsci_oswt_unreg;
  input plm_in_data_rsci_iswt0;
  input plm_in_data_rsci_oswt_unreg_1;
  input plm_in_data_rsci_iswt0_1;
  output plm_in_data_rsci_biwt;
  output plm_in_data_rsci_bdwt;
  output plm_in_data_rsci_biwt_1;
  output plm_in_data_rsci_bdwt_2;
  output plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  output plm_in_data_rsci_we_d_core_sct_pff;
  input plm_in_data_rsci_iswt0_pff;
  input plm_in_data_rsci_iswt0_1_pff;



  // Interconnect Declarations for Component Instantiations 
  assign plm_in_data_rsci_bdwt = plm_in_data_rsci_oswt_unreg & core_wen;
  assign plm_in_data_rsci_biwt = (~ core_wten) & plm_in_data_rsci_iswt0;
  assign plm_in_data_rsci_bdwt_2 = plm_in_data_rsci_oswt_unreg_1 & core_wen;
  assign plm_in_data_rsci_biwt_1 = (~ core_wten) & plm_in_data_rsci_iswt0_1;
  assign plm_in_data_rsci_we_d_core_sct_pff = plm_in_data_rsci_iswt0_pff & core_wen;
  assign plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct = plm_in_data_rsci_iswt0_1_pff
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
  core_wen, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_iswt0, dma_write_chnl_rsci_irdy_oreg,
      dma_write_chnl_rsci_ivld_core_psct, dma_write_chnl_rsci_biwt, dma_write_chnl_rsci_bdwt,
      dma_write_chnl_rsci_bcwt, dma_write_chnl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_write_chnl_rsci_oswt_unreg;
  input dma_write_chnl_rsci_iswt0;
  input dma_write_chnl_rsci_irdy_oreg;
  input dma_write_chnl_rsci_ivld_core_psct;
  output dma_write_chnl_rsci_biwt;
  output dma_write_chnl_rsci_bdwt;
  input dma_write_chnl_rsci_bcwt;
  output dma_write_chnl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_write_chnl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_chnl_rsci_bdwt = dma_write_chnl_rsci_oswt_unreg & core_wen;
  assign dma_write_chnl_rsci_biwt = dma_write_chnl_rsci_ogwt & dma_write_chnl_rsci_irdy_oreg;
  assign dma_write_chnl_rsci_ogwt = dma_write_chnl_rsci_iswt0 & (~ dma_write_chnl_rsci_bcwt);
  assign dma_write_chnl_rsci_ivld_core_sct = dma_write_chnl_rsci_ivld_core_psct &
      dma_write_chnl_rsci_ogwt;
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
    (
  core_wen, dma_read_chnl_rsci_oswt_unreg, dma_read_chnl_rsci_iswt0, dma_read_chnl_rsci_irdy_core_psct,
      dma_read_chnl_rsci_ivld_oreg, dma_read_chnl_rsci_biwt, dma_read_chnl_rsci_bdwt,
      dma_read_chnl_rsci_bcwt, dma_read_chnl_rsci_irdy_core_sct
);
  input core_wen;
  input dma_read_chnl_rsci_oswt_unreg;
  input dma_read_chnl_rsci_iswt0;
  input dma_read_chnl_rsci_irdy_core_psct;
  input dma_read_chnl_rsci_ivld_oreg;
  output dma_read_chnl_rsci_biwt;
  output dma_read_chnl_rsci_bdwt;
  input dma_read_chnl_rsci_bcwt;
  output dma_read_chnl_rsci_irdy_core_sct;


  // Interconnect Declarations
  wire dma_read_chnl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_chnl_rsci_bdwt = dma_read_chnl_rsci_oswt_unreg & core_wen;
  assign dma_read_chnl_rsci_biwt = dma_read_chnl_rsci_ogwt & dma_read_chnl_rsci_ivld_oreg;
  assign dma_read_chnl_rsci_ogwt = dma_read_chnl_rsci_iswt0 & (~ dma_read_chnl_rsci_bcwt);
  assign dma_read_chnl_rsci_irdy_core_sct = dma_read_chnl_rsci_irdy_core_psct & dma_read_chnl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
    (
  clk, rst, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_bawt, dma_write_ctrl_rsci_wen_comp,
      dma_write_ctrl_rsci_biwt, dma_write_ctrl_rsci_bdwt, dma_write_ctrl_rsci_bcwt
);
  input clk;
  input rst;
  input dma_write_ctrl_rsci_oswt_unreg;
  output dma_write_ctrl_rsci_bawt;
  output dma_write_ctrl_rsci_wen_comp;
  input dma_write_ctrl_rsci_biwt;
  input dma_write_ctrl_rsci_bdwt;
  output dma_write_ctrl_rsci_bcwt;
  reg dma_write_ctrl_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bawt = dma_write_ctrl_rsci_biwt | dma_write_ctrl_rsci_bcwt;
  assign dma_write_ctrl_rsci_wen_comp = (~ dma_write_ctrl_rsci_oswt_unreg) | dma_write_ctrl_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_write_ctrl_rsci_bcwt <= ~((~(dma_write_ctrl_rsci_bcwt | dma_write_ctrl_rsci_biwt))
          | dma_write_ctrl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
    (
  core_wen, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_iswt0, dma_write_ctrl_rsci_irdy_oreg,
      dma_write_ctrl_rsci_ivld_core_psct, dma_write_ctrl_rsci_biwt, dma_write_ctrl_rsci_bdwt,
      dma_write_ctrl_rsci_bcwt, dma_write_ctrl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_write_ctrl_rsci_oswt_unreg;
  input dma_write_ctrl_rsci_iswt0;
  input dma_write_ctrl_rsci_irdy_oreg;
  input dma_write_ctrl_rsci_ivld_core_psct;
  output dma_write_ctrl_rsci_biwt;
  output dma_write_ctrl_rsci_bdwt;
  input dma_write_ctrl_rsci_bcwt;
  output dma_write_ctrl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_write_ctrl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_write_ctrl_rsci_bdwt = dma_write_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_write_ctrl_rsci_biwt = dma_write_ctrl_rsci_ogwt & dma_write_ctrl_rsci_irdy_oreg;
  assign dma_write_ctrl_rsci_ogwt = dma_write_ctrl_rsci_iswt0 & (~ dma_write_ctrl_rsci_bcwt);
  assign dma_write_ctrl_rsci_ivld_core_sct = dma_write_ctrl_rsci_ivld_core_psct &
      dma_write_ctrl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp
    (
  clk, rst, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_bawt, dma_read_ctrl_rsci_wen_comp,
      dma_read_ctrl_rsci_biwt, dma_read_ctrl_rsci_bdwt, dma_read_ctrl_rsci_bcwt
);
  input clk;
  input rst;
  input dma_read_ctrl_rsci_oswt_unreg;
  output dma_read_ctrl_rsci_bawt;
  output dma_read_ctrl_rsci_wen_comp;
  input dma_read_ctrl_rsci_biwt;
  input dma_read_ctrl_rsci_bdwt;
  output dma_read_ctrl_rsci_bcwt;
  reg dma_read_ctrl_rsci_bcwt;



  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bawt = dma_read_ctrl_rsci_biwt | dma_read_ctrl_rsci_bcwt;
  assign dma_read_ctrl_rsci_wen_comp = (~ dma_read_ctrl_rsci_oswt_unreg) | dma_read_ctrl_rsci_bawt;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_bcwt <= 1'b0;
    end
    else begin
      dma_read_ctrl_rsci_bcwt <= ~((~(dma_read_ctrl_rsci_bcwt | dma_read_ctrl_rsci_biwt))
          | dma_read_ctrl_rsci_bdwt);
    end
  end
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
    (
  core_wen, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_iswt0, dma_read_ctrl_rsci_irdy_oreg,
      dma_read_ctrl_rsci_ivld_core_psct, dma_read_ctrl_rsci_biwt, dma_read_ctrl_rsci_bdwt,
      dma_read_ctrl_rsci_bcwt, dma_read_ctrl_rsci_ivld_core_sct
);
  input core_wen;
  input dma_read_ctrl_rsci_oswt_unreg;
  input dma_read_ctrl_rsci_iswt0;
  input dma_read_ctrl_rsci_irdy_oreg;
  input dma_read_ctrl_rsci_ivld_core_psct;
  output dma_read_ctrl_rsci_biwt;
  output dma_read_ctrl_rsci_bdwt;
  input dma_read_ctrl_rsci_bcwt;
  output dma_read_ctrl_rsci_ivld_core_sct;


  // Interconnect Declarations
  wire dma_read_ctrl_rsci_ogwt;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_bdwt = dma_read_ctrl_rsci_oswt_unreg & core_wen;
  assign dma_read_ctrl_rsci_biwt = dma_read_ctrl_rsci_ogwt & dma_read_ctrl_rsci_irdy_oreg;
  assign dma_read_ctrl_rsci_ogwt = dma_read_ctrl_rsci_iswt0 & (~ dma_read_ctrl_rsci_bcwt);
  assign dma_read_ctrl_rsci_ivld_core_sct = dma_read_ctrl_rsci_ivld_core_psct & dma_read_ctrl_rsci_ogwt;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_wait_dp
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_wait_dp (
  clk, rst, dma_read_ctrl_rsci_irdy, dma_read_ctrl_rsci_irdy_oreg, dma_write_ctrl_rsci_irdy,
      dma_write_ctrl_rsci_irdy_oreg, dma_read_chnl_rsci_ivld, dma_read_chnl_rsci_ivld_oreg,
      dma_write_chnl_rsci_irdy, dma_write_chnl_rsci_irdy_oreg
);
  input clk;
  input rst;
  input dma_read_ctrl_rsci_irdy;
  output dma_read_ctrl_rsci_irdy_oreg;
  input dma_write_ctrl_rsci_irdy;
  output dma_write_ctrl_rsci_irdy_oreg;
  input dma_read_chnl_rsci_ivld;
  output dma_read_chnl_rsci_ivld_oreg;
  input dma_write_chnl_rsci_irdy;
  output dma_write_chnl_rsci_irdy_oreg;


  // Interconnect Declarations
  reg dma_read_ctrl_rsci_irdy_oreg_rneg;
  reg dma_write_ctrl_rsci_irdy_oreg_rneg;
  reg dma_read_chnl_rsci_ivld_oreg_rneg;
  reg dma_write_chnl_rsci_irdy_oreg_rneg;


  // Interconnect Declarations for Component Instantiations 
  assign dma_read_ctrl_rsci_irdy_oreg = ~ dma_read_ctrl_rsci_irdy_oreg_rneg;
  assign dma_write_ctrl_rsci_irdy_oreg = ~ dma_write_ctrl_rsci_irdy_oreg_rneg;
  assign dma_read_chnl_rsci_ivld_oreg = ~ dma_read_chnl_rsci_ivld_oreg_rneg;
  assign dma_write_chnl_rsci_irdy_oreg = ~ dma_write_chnl_rsci_irdy_oreg_rneg;
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_irdy_oreg_rneg <= 1'b0;
      dma_write_ctrl_rsci_irdy_oreg_rneg <= 1'b0;
      dma_read_chnl_rsci_ivld_oreg_rneg <= 1'b0;
      dma_write_chnl_rsci_irdy_oreg_rneg <= 1'b0;
    end
    else begin
      dma_read_ctrl_rsci_irdy_oreg_rneg <= ~ dma_read_ctrl_rsci_irdy;
      dma_write_ctrl_rsci_irdy_oreg_rneg <= ~ dma_write_ctrl_rsci_irdy;
      dma_read_chnl_rsci_ivld_oreg_rneg <= ~ dma_read_chnl_rsci_ivld;
      dma_write_chnl_rsci_irdy_oreg_rneg <= ~ dma_write_chnl_rsci_irdy;
    end
  end
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
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1 (
  clk, rst, plm_out_data_rsci_q_d, plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      core_wen, core_wten, plm_out_data_rsci_oswt_unreg_1, plm_out_data_rsci_iswt0_1,
      plm_out_data_rsci_q_d_mxwt, plm_out_data_rsci_we_d_pff, plm_out_data_rsci_iswt0_pff,
      plm_out_data_rsci_iswt0_1_pff
);
  input clk;
  input rst;
  input [31:0] plm_out_data_rsci_q_d;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_out_data_rsci_oswt_unreg_1;
  input plm_out_data_rsci_iswt0_1;
  output [31:0] plm_out_data_rsci_q_d_mxwt;
  output plm_out_data_rsci_we_d_pff;
  input plm_out_data_rsci_iswt0_pff;
  input plm_out_data_rsci_iswt0_1_pff;


  // Interconnect Declarations
  wire plm_out_data_rsci_biwt_1;
  wire plm_out_data_rsci_bdwt_2;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  wire plm_out_data_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl
      softmax_cxx_core_plm_out_data_rsci_1_plm_out_data_rsc_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_data_rsci_oswt_unreg_1(plm_out_data_rsci_oswt_unreg_1),
      .plm_out_data_rsci_iswt0_1(plm_out_data_rsci_iswt0_1),
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
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_biwt_1(plm_out_data_rsci_biwt_1),
      .plm_out_data_rsci_bdwt_2(plm_out_data_rsci_bdwt_2)
    );
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_core_sct_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1 (
  clk, rst, plm_in_data_rsci_q_d, plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      core_wen, core_wten, plm_in_data_rsci_oswt_unreg, plm_in_data_rsci_bawt, plm_in_data_rsci_iswt0,
      plm_in_data_rsci_oswt_unreg_1, plm_in_data_rsci_iswt0_1, plm_in_data_rsci_q_d_mxwt,
      plm_in_data_rsci_we_d_pff, plm_in_data_rsci_iswt0_pff, plm_in_data_rsci_iswt0_1_pff
);
  input clk;
  input rst;
  input [31:0] plm_in_data_rsci_q_d;
  output plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  input core_wen;
  input core_wten;
  input plm_in_data_rsci_oswt_unreg;
  output plm_in_data_rsci_bawt;
  input plm_in_data_rsci_iswt0;
  input plm_in_data_rsci_oswt_unreg_1;
  input plm_in_data_rsci_iswt0_1;
  output [31:0] plm_in_data_rsci_q_d_mxwt;
  output plm_in_data_rsci_we_d_pff;
  input plm_in_data_rsci_iswt0_pff;
  input plm_in_data_rsci_iswt0_1_pff;


  // Interconnect Declarations
  wire plm_in_data_rsci_biwt;
  wire plm_in_data_rsci_bdwt;
  wire plm_in_data_rsci_biwt_1;
  wire plm_in_data_rsci_bdwt_2;
  wire plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
  wire plm_in_data_rsci_we_d_core_sct_iff;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_ctrl
      softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_ctrl_inst (
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_data_rsci_oswt_unreg(plm_in_data_rsci_oswt_unreg),
      .plm_in_data_rsci_iswt0(plm_in_data_rsci_iswt0),
      .plm_in_data_rsci_oswt_unreg_1(plm_in_data_rsci_oswt_unreg_1),
      .plm_in_data_rsci_iswt0_1(plm_in_data_rsci_iswt0_1),
      .plm_in_data_rsci_biwt(plm_in_data_rsci_biwt),
      .plm_in_data_rsci_bdwt(plm_in_data_rsci_bdwt),
      .plm_in_data_rsci_biwt_1(plm_in_data_rsci_biwt_1),
      .plm_in_data_rsci_bdwt_2(plm_in_data_rsci_bdwt_2),
      .plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct(plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct),
      .plm_in_data_rsci_we_d_core_sct_pff(plm_in_data_rsci_we_d_core_sct_iff),
      .plm_in_data_rsci_iswt0_pff(plm_in_data_rsci_iswt0_pff),
      .plm_in_data_rsci_iswt0_1_pff(plm_in_data_rsci_iswt0_1_pff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_dp
      softmax_cxx_core_plm_in_data_rsci_1_plm_in_data_rsc_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .plm_in_data_rsci_q_d(plm_in_data_rsci_q_d),
      .plm_in_data_rsci_bawt(plm_in_data_rsci_bawt),
      .plm_in_data_rsci_q_d_mxwt(plm_in_data_rsci_q_d_mxwt),
      .plm_in_data_rsci_biwt(plm_in_data_rsci_biwt),
      .plm_in_data_rsci_bdwt(plm_in_data_rsci_bdwt),
      .plm_in_data_rsci_biwt_1(plm_in_data_rsci_biwt_1),
      .plm_in_data_rsci_bdwt_2(plm_in_data_rsci_bdwt_2)
    );
  assign plm_in_data_rsci_we_d_pff = plm_in_data_rsci_we_d_core_sct_iff;
  assign plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_core_sct;
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci (
  clk, rst, dma_write_chnl_rsc_dat, dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy,
      core_wen, dma_write_chnl_rsci_irdy, dma_write_chnl_rsci_oswt_unreg, dma_write_chnl_rsci_bawt,
      dma_write_chnl_rsci_iswt0, dma_write_chnl_rsci_wen_comp, dma_write_chnl_rsci_irdy_oreg,
      dma_write_chnl_rsci_ivld_core_psct, dma_write_chnl_rsci_idat
);
  input clk;
  input rst;
  output [63:0] dma_write_chnl_rsc_dat;
  output dma_write_chnl_rsc_vld;
  input dma_write_chnl_rsc_rdy;
  input core_wen;
  output dma_write_chnl_rsci_irdy;
  input dma_write_chnl_rsci_oswt_unreg;
  output dma_write_chnl_rsci_bawt;
  input dma_write_chnl_rsci_iswt0;
  output dma_write_chnl_rsci_wen_comp;
  input dma_write_chnl_rsci_irdy_oreg;
  input dma_write_chnl_rsci_ivld_core_psct;
  input [63:0] dma_write_chnl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_chnl_rsci_biwt;
  wire dma_write_chnl_rsci_bdwt;
  wire dma_write_chnl_rsci_bcwt;
  wire dma_write_chnl_rsci_ivld_core_sct;
  wire dma_write_chnl_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  wire [63:0] nl_dma_write_chnl_rsci_idat;
  assign nl_dma_write_chnl_rsci_idat = {32'b11011110101011011011111011101111 , (dma_write_chnl_rsci_idat[31:0])};
  esp_acc_softmax_cxx_ccs_out_buf_wait_v4 #(.rscid(32'sd7),
  .width(32'sd64),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_write_chnl_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dma_write_chnl_rsci_irdy),
      .ivld(dma_write_chnl_rsci_ivld_core_sct),
      .idat(nl_dma_write_chnl_rsci_idat[63:0]),
      .rdy(dma_write_chnl_rsc_rdy),
      .vld(dma_write_chnl_rsc_vld),
      .dat(dma_write_chnl_rsc_dat),
      .is_idle(dma_write_chnl_rsc_is_idle)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl
      softmax_cxx_core_dma_write_chnl_rsci_dma_write_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_write_chnl_rsci_oswt_unreg(dma_write_chnl_rsci_oswt_unreg),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_irdy_oreg(dma_write_chnl_rsci_irdy_oreg),
      .dma_write_chnl_rsci_ivld_core_psct(dma_write_chnl_rsci_ivld_core_psct),
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
      dma_read_chnl_rsci_wen_comp, dma_read_chnl_rsci_irdy_core_psct, dma_read_chnl_rsci_ivld,
      dma_read_chnl_rsci_ivld_oreg, dma_read_chnl_rsci_idat_mxwt
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
  output dma_read_chnl_rsci_ivld;
  input dma_read_chnl_rsci_ivld_oreg;
  output [31:0] dma_read_chnl_rsci_idat_mxwt;


  // Interconnect Declarations
  wire dma_read_chnl_rsci_biwt;
  wire dma_read_chnl_rsci_bdwt;
  wire dma_read_chnl_rsci_bcwt;
  wire dma_read_chnl_rsci_irdy_core_sct;
  wire [63:0] dma_read_chnl_rsci_idat;
  wire dma_read_chnl_rsc_is_idle;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt_pconst;


  // Interconnect Declarations for Component Instantiations 
  esp_acc_softmax_cxx_ccs_ctrl_in_buf_wait_v4 #(.rscid(32'sd6),
  .width(32'sd64),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_read_chnl_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .rdy(dma_read_chnl_rsc_rdy),
      .vld(dma_read_chnl_rsc_vld),
      .dat(dma_read_chnl_rsc_dat),
      .irdy(dma_read_chnl_rsci_irdy_core_sct),
      .ivld(dma_read_chnl_rsci_ivld),
      .idat(dma_read_chnl_rsci_idat),
      .is_idle(dma_read_chnl_rsc_is_idle)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl
      softmax_cxx_core_dma_read_chnl_rsci_dma_read_chnl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_read_chnl_rsci_oswt_unreg(dma_read_chnl_rsci_oswt_unreg),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_irdy_core_psct(dma_read_chnl_rsci_irdy_core_psct),
      .dma_read_chnl_rsci_ivld_oreg(dma_read_chnl_rsci_ivld_oreg),
      .dma_read_chnl_rsci_biwt(dma_read_chnl_rsci_biwt),
      .dma_read_chnl_rsci_bdwt(dma_read_chnl_rsci_bdwt),
      .dma_read_chnl_rsci_bcwt(dma_read_chnl_rsci_bcwt),
      .dma_read_chnl_rsci_irdy_core_sct(dma_read_chnl_rsci_irdy_core_sct)
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
      core_wen, dma_write_ctrl_rsci_irdy, dma_write_ctrl_rsci_oswt_unreg, dma_write_ctrl_rsci_bawt,
      dma_write_ctrl_rsci_iswt0, dma_write_ctrl_rsci_wen_comp, dma_write_ctrl_rsci_irdy_oreg,
      dma_write_ctrl_rsci_ivld_core_psct, dma_write_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_write_ctrl_rsc_dat;
  output dma_write_ctrl_rsc_vld;
  input dma_write_ctrl_rsc_rdy;
  input core_wen;
  output dma_write_ctrl_rsci_irdy;
  input dma_write_ctrl_rsci_oswt_unreg;
  output dma_write_ctrl_rsci_bawt;
  input dma_write_ctrl_rsci_iswt0;
  output dma_write_ctrl_rsci_wen_comp;
  input dma_write_ctrl_rsci_irdy_oreg;
  input dma_write_ctrl_rsci_ivld_core_psct;
  input [66:0] dma_write_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_write_ctrl_rsci_biwt;
  wire dma_write_ctrl_rsci_bdwt;
  wire dma_write_ctrl_rsci_bcwt;
  wire dma_write_ctrl_rsci_ivld_core_sct;
  wire dma_write_ctrl_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_write_ctrl_rsci_idat;
  assign nl_dma_write_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , (dma_write_ctrl_rsci_idat[10:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_buf_wait_v4 #(.rscid(32'sd5),
  .width(32'sd67),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_write_ctrl_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dma_write_ctrl_rsci_irdy),
      .ivld(dma_write_ctrl_rsci_ivld_core_sct),
      .idat(nl_dma_write_ctrl_rsci_idat[66:0]),
      .rdy(dma_write_ctrl_rsc_rdy),
      .vld(dma_write_ctrl_rsc_vld),
      .dat(dma_write_ctrl_rsc_dat),
      .is_idle(dma_write_ctrl_rsc_is_idle)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl
      softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_write_ctrl_rsci_oswt_unreg(dma_write_ctrl_rsci_oswt_unreg),
      .dma_write_ctrl_rsci_iswt0(dma_write_ctrl_rsci_iswt0),
      .dma_write_ctrl_rsci_irdy_oreg(dma_write_ctrl_rsci_irdy_oreg),
      .dma_write_ctrl_rsci_ivld_core_psct(dma_write_ctrl_rsci_ivld_core_psct),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt),
      .dma_write_ctrl_rsci_bcwt(dma_write_ctrl_rsci_bcwt),
      .dma_write_ctrl_rsci_ivld_core_sct(dma_write_ctrl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp
      softmax_cxx_core_dma_write_ctrl_rsci_dma_write_ctrl_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_write_ctrl_rsci_oswt_unreg(dma_write_ctrl_rsci_oswt_unreg),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_wen_comp(dma_write_ctrl_rsci_wen_comp),
      .dma_write_ctrl_rsci_biwt(dma_write_ctrl_rsci_biwt),
      .dma_write_ctrl_rsci_bdwt(dma_write_ctrl_rsci_bdwt),
      .dma_write_ctrl_rsci_bcwt(dma_write_ctrl_rsci_bcwt)
    );
endmodule

// ------------------------------------------------------------------
//  Design Unit:    esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci
// ------------------------------------------------------------------


module esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci (
  clk, rst, dma_read_ctrl_rsc_dat, dma_read_ctrl_rsc_vld, dma_read_ctrl_rsc_rdy,
      core_wen, dma_read_ctrl_rsci_irdy, dma_read_ctrl_rsci_oswt_unreg, dma_read_ctrl_rsci_bawt,
      dma_read_ctrl_rsci_iswt0, dma_read_ctrl_rsci_wen_comp, dma_read_ctrl_rsci_irdy_oreg,
      dma_read_ctrl_rsci_ivld_core_psct, dma_read_ctrl_rsci_idat
);
  input clk;
  input rst;
  output [66:0] dma_read_ctrl_rsc_dat;
  output dma_read_ctrl_rsc_vld;
  input dma_read_ctrl_rsc_rdy;
  input core_wen;
  output dma_read_ctrl_rsci_irdy;
  input dma_read_ctrl_rsci_oswt_unreg;
  output dma_read_ctrl_rsci_bawt;
  input dma_read_ctrl_rsci_iswt0;
  output dma_read_ctrl_rsci_wen_comp;
  input dma_read_ctrl_rsci_irdy_oreg;
  input dma_read_ctrl_rsci_ivld_core_psct;
  input [66:0] dma_read_ctrl_rsci_idat;


  // Interconnect Declarations
  wire dma_read_ctrl_rsci_biwt;
  wire dma_read_ctrl_rsci_bdwt;
  wire dma_read_ctrl_rsci_bcwt;
  wire dma_read_ctrl_rsci_ivld_core_sct;
  wire dma_read_ctrl_rsc_is_idle;


  // Interconnect Declarations for Component Instantiations 
  wire [66:0] nl_dma_read_ctrl_rsci_idat;
  assign nl_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , (dma_read_ctrl_rsci_idat[10:7]) , 7'b0000000};
  esp_acc_softmax_cxx_ccs_out_buf_wait_v4 #(.rscid(32'sd4),
  .width(32'sd67),
  .ph_clk(32'sd1),
  .ph_en(32'sd0),
  .ph_arst(32'sd0),
  .ph_srst(32'sd0)) dma_read_ctrl_rsci (
      .clk(clk),
      .en(1'b0),
      .arst(1'b1),
      .srst(rst),
      .irdy(dma_read_ctrl_rsci_irdy),
      .ivld(dma_read_ctrl_rsci_ivld_core_sct),
      .idat(nl_dma_read_ctrl_rsci_idat[66:0]),
      .rdy(dma_read_ctrl_rsc_rdy),
      .vld(dma_read_ctrl_rsc_vld),
      .dat(dma_read_ctrl_rsc_dat),
      .is_idle(dma_read_ctrl_rsc_is_idle)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl
      softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_ctrl_inst (
      .core_wen(core_wen),
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .dma_read_ctrl_rsci_irdy_oreg(dma_read_ctrl_rsci_irdy_oreg),
      .dma_read_ctrl_rsci_ivld_core_psct(dma_read_ctrl_rsci_ivld_core_psct),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt),
      .dma_read_ctrl_rsci_bcwt(dma_read_ctrl_rsci_bcwt),
      .dma_read_ctrl_rsci_ivld_core_sct(dma_read_ctrl_rsci_ivld_core_sct)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp softmax_cxx_core_dma_read_ctrl_rsci_dma_read_ctrl_wait_dp_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsci_oswt_unreg(dma_read_ctrl_rsci_oswt_unreg),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_wen_comp(dma_read_ctrl_rsci_wen_comp),
      .dma_read_ctrl_rsci_biwt(dma_read_ctrl_rsci_biwt),
      .dma_read_ctrl_rsci_bdwt(dma_read_ctrl_rsci_bdwt),
      .dma_read_ctrl_rsci_bcwt(dma_read_ctrl_rsci_bcwt)
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
      dma_write_chnl_rsc_vld, dma_write_chnl_rsc_rdy, acc_done_sync_vld, plm_in_data_rsci_d_d,
      plm_in_data_rsci_q_d, plm_in_data_rsci_radr_d, plm_in_data_rsci_wadr_d, plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      plm_out_data_rsci_d_d, plm_out_data_rsci_q_d, plm_out_data_rsci_radr_d, plm_out_data_rsci_wadr_d,
      plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d,
      plm_in_data_rsci_we_d_pff, plm_out_data_rsci_we_d_pff, ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
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
  output [31:0] plm_in_data_rsci_d_d;
  input [31:0] plm_in_data_rsci_q_d;
  output [6:0] plm_in_data_rsci_radr_d;
  output [6:0] plm_in_data_rsci_wadr_d;
  output plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output [31:0] plm_out_data_rsci_d_d;
  input [31:0] plm_out_data_rsci_q_d;
  output [6:0] plm_out_data_rsci_radr_d;
  output [6:0] plm_out_data_rsci_wadr_d;
  output plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d;
  output [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  input [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  output plm_in_data_rsci_we_d_pff;
  output plm_out_data_rsci_we_d_pff;
  output [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff;
  output ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff;


  // Interconnect Declarations
  wire core_wen;
  wire [31:0] conf_info_batch_rsci_idat;
  wire conf_done_rsci_idat;
  wire dma_read_ctrl_rsci_irdy;
  wire dma_read_ctrl_rsci_bawt;
  reg dma_read_ctrl_rsci_iswt0;
  wire core_wten;
  wire dma_read_ctrl_rsci_wen_comp;
  wire dma_read_ctrl_rsci_irdy_oreg;
  reg dma_read_ctrl_rsci_ivld_core_psct;
  wire dma_write_ctrl_rsci_irdy;
  wire dma_write_ctrl_rsci_bawt;
  reg dma_write_ctrl_rsci_iswt0;
  wire dma_write_ctrl_rsci_wen_comp;
  wire dma_write_ctrl_rsci_irdy_oreg;
  reg dma_write_ctrl_rsci_ivld_core_psct;
  wire dma_read_chnl_rsci_bawt;
  reg dma_read_chnl_rsci_iswt0;
  wire dma_read_chnl_rsci_wen_comp;
  reg dma_read_chnl_rsci_irdy_core_psct;
  wire dma_read_chnl_rsci_ivld;
  wire dma_read_chnl_rsci_ivld_oreg;
  wire [31:0] dma_read_chnl_rsci_idat_mxwt;
  wire dma_write_chnl_rsci_irdy;
  wire dma_write_chnl_rsci_bawt;
  reg dma_write_chnl_rsci_iswt0;
  wire dma_write_chnl_rsci_wen_comp;
  wire dma_write_chnl_rsci_irdy_oreg;
  reg dma_write_chnl_rsci_ivld_core_psct;
  wire plm_in_data_rsci_bawt;
  wire [31:0] plm_in_data_rsci_q_d_mxwt;
  wire [31:0] plm_out_data_rsci_q_d_mxwt;
  wire [94:0] CALC_SOFTMAX_LOOP_mul_cmp_z;
  reg [3:0] dma_read_ctrl_rsci_idat_10_7;
  reg [3:0] dma_write_ctrl_rsci_idat_10_7;
  reg [31:0] dma_write_chnl_rsci_idat_31_0;
  wire [5:0] fsm_output;
  wire COMPUTE_LOOP_nor_tmp;
  wire [4:0] COMPUTE_LOOP_acc_1_tmp;
  wire [5:0] nl_COMPUTE_LOOP_acc_1_tmp;
  wire [7:0] SUM_EXP_LOOP_acc_2_tmp;
  wire [8:0] nl_SUM_EXP_LOOP_acc_2_tmp;
  wire [7:0] CALC_EXP_LOOP_acc_1_tmp;
  wire [8:0] nl_CALC_EXP_LOOP_acc_1_tmp;
  wire or_tmp_1;
  wire nor_tmp;
  wire or_tmp_10;
  wire or_dcpl_14;
  wire and_dcpl_3;
  wire and_dcpl_6;
  wire or_dcpl_20;
  wire and_dcpl_24;
  wire or_dcpl_32;
  wire mux_tmp_48;
  wire and_dcpl_115;
  wire or_dcpl_54;
  wire and_dcpl_118;
  wire and_dcpl_119;
  wire or_dcpl_56;
  wire and_dcpl_121;
  wire and_dcpl_122;
  wire or_dcpl_59;
  wire or_dcpl_60;
  wire or_dcpl_62;
  wire and_dcpl_125;
  wire or_dcpl_63;
  wire and_dcpl_127;
  wire and_dcpl_132;
  wire and_dcpl_133;
  wire and_dcpl_134;
  wire and_dcpl_135;
  wire and_dcpl_136;
  wire and_dcpl_137;
  wire and_dcpl_144;
  wire nand_tmp_14;
  wire not_tmp_118;
  wire and_dcpl_152;
  wire nor_tmp_27;
  wire nand_tmp_15;
  wire or_tmp_80;
  wire and_dcpl_157;
  wire or_dcpl_86;
  wire or_dcpl_87;
  wire or_dcpl_89;
  wire and_dcpl_167;
  wire or_dcpl_91;
  wire and_dcpl_174;
  wire mux_tmp_93;
  wire and_dcpl_181;
  wire or_dcpl_94;
  wire or_dcpl_95;
  wire mux_tmp_94;
  wire and_dcpl_200;
  wire and_dcpl_207;
  wire or_dcpl_176;
  wire and_dcpl_218;
  wire or_dcpl_183;
  wire and_dcpl_223;
  wire or_tmp_104;
  wire or_dcpl_197;
  wire or_tmp_112;
  wire or_tmp_116;
  wire or_tmp_122;
  wire or_tmp_130;
  wire or_tmp_133;
  wire or_tmp_142;
  wire or_tmp_149;
  wire or_tmp_150;
  wire or_tmp_156;
  wire or_tmp_165;
  wire or_tmp_203;
  wire or_tmp_209;
  reg CALC_EXP_LOOP_and_svs_st_1;
  reg exitL_exit_STORE_INNER_LOOP_sva;
  wire exit_COMPUTE_LOOP_lpi_2_dfm_1;
  wire CALC_SOFTMAX_LOOP_equal_tmp_2;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0;
  reg exitL_exit_CALC_SOFTMAX_LOOP_sva;
  wire CALC_SOFTMAX_LOOP_equal_tmp_3;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1;
  wire CALC_SOFTMAX_LOOP_and_6_ssc_1;
  wire CALC_SOFTMAX_LOOP_and_7_ssc_1;
  wire CALC_EXP_LOOP_and_svs_1;
  wire CALC_SOFTMAX_LOOP_or_tmp_1;
  wire [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2;
  wire [74:0] nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2;
  reg exitL_exit_LOAD_INNER_LOOP_sva;
  reg CALC_EXP_LOOP_and_svs_st_4;
  reg CALC_EXP_LOOP_and_svs_st_6;
  reg CALC_EXP_LOOP_and_svs_st_5;
  reg CALC_EXP_LOOP_and_svs_st_2;
  reg LOAD_OUTER_LOOP_stage_0_1;
  reg STORE_INNER_LOOP_asn_itm_2;
  reg exit_STORE_OUTER_LOOP_sva_1_st_2;
  reg CALC_EXP_LOOP_and_svs_st_3;
  reg STORE_INNER_LOOP_asn_itm;
  reg CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1;
  reg exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2;
  reg CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4;
  reg exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_10;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_1;
  reg CALC_SOFTMAX_LOOP_and_13_itm_5;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_5;
  reg COMPUTE_LOOP_stage_0_6;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_3;
  reg COMPUTE_LOOP_stage_0_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_2;
  reg COMPUTE_LOOP_stage_0_3;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_0;
  reg COMPUTE_LOOP_stage_0;
  reg CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_3;
  reg CALC_SOFTMAX_LOOP_asn_itm_2;
  reg CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_9;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_1;
  reg CALC_SOFTMAX_LOOP_and_13_itm_4;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_0;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_8;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_1;
  reg CALC_SOFTMAX_LOOP_and_13_itm_3;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0;
  reg CALC_SOFTMAX_LOOP_asn_itm_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_7;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_1;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_6;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_0;
  reg exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1;
  reg exit_LOAD_OUTER_LOOP_sva_1_st_1;
  reg LOAD_INNER_LOOP_asn_itm_1;
  reg LOAD_INNER_LOOP_asn_itm;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_0;
  reg COMPUTE_LOOP_stage_0_12;
  reg exit_COMPUTE_LOOP_lpi_2_dfm_st_11;
  reg COMPUTE_LOOP_stage_0_7;
  reg CALC_SOFTMAX_LOOP_asn_14_itm_6;
  reg COMPUTE_LOOP_stage_0_5;
  reg CALC_SOFTMAX_LOOP_asn_14_itm_4;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1;
  reg COMPUTE_LOOP_stage_0_2;
  reg CALC_SOFTMAX_LOOP_and_13_itm_6;
  reg CALC_SOFTMAX_LOOP_asn_2_itm_3;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_4;
  wire [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1;
  wire or_186_tmp;
  wire or_303_tmp;
  wire CALC_SOFTMAX_LOOP_and_10_tmp;
  wire or_27_cse;
  wire LOAD_OUTER_LOOP_and_cse;
  wire LOAD_INNER_LOOP_data_ac_LOAD_INNER_LOOP_data_ac_or_cse;
  wire LOAD_INNER_LOOP_data_ac_and_cse;
  wire STORE_OUTER_LOOP_and_cse;
  wire STORE_INNER_LOOP_and_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_8_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_9_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_10_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_11_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_12_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_13_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_14_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_15_cse;
  reg reg_dma_read_chnl_rsci_oswt_cse;
  reg reg_plm_in_data_rsci_iswt0_1_cse;
  reg reg_plm_out_data_rsci_iswt0_1_cse;
  reg reg_acc_done_synci_iswt0_cse;
  wire or_69_cse;
  wire mux_107_cse;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1_1;
  reg [73:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2;
  wire and_286_m1c;
  reg [31:0] plm_in_data_rsci_d_d_reg;
  wire [31:0] LOAD_INNER_LOOP_data_ac_mux_rmff;
  reg [6:0] plm_in_data_rsci_radr_d_reg;
  wire [6:0] LOAD_INNER_LOOP_mux_1_rmff;
  reg [6:0] plm_in_data_rsci_wadr_d_reg;
  wire [6:0] CALC_EXP_LOOP_i_mux_rmff;
  wire plm_in_data_rsci_we_d_iff;
  wire and_476_rmff;
  wire plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_483_rmff;
  reg [31:0] plm_out_data_rsci_d_d_reg;
  wire [31:0] CALC_SOFTMAX_LOOP_mux_rmff;
  reg [6:0] plm_out_data_rsci_radr_d_reg;
  wire [6:0] STORE_INNER_LOOP_mux1h_3_rmff;
  reg [6:0] plm_out_data_rsci_wadr_d_reg;
  wire [6:0] CALC_SOFTMAX_LOOP_i_mux_rmff;
  wire plm_out_data_rsci_we_d_iff;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  wire and_490_rmff;
  reg [66:0] operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4;
  wire [93:0] operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
  wire [72:0] operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm;
  wire [3:0] z_out;
  wire [4:0] nl_z_out;
  wire [7:0] z_out_1;
  wire [8:0] nl_z_out_1;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2;
  reg [31:0] conf_info_batch_sva;
  reg [3:0] dma_write_data_index_10_7_sva;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3;
  reg COMPUTE_LOOP_stage_0_8;
  reg COMPUTE_LOOP_stage_0_9;
  reg COMPUTE_LOOP_stage_0_10;
  reg COMPUTE_LOOP_stage_0_11;
  reg [7:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm;
  reg [9:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm;
  reg [7:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm;
  wire [8:0] nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm;
  reg [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1;
  reg exit_COMPUTE_LOOP_sva_1_1;
  reg exit_COMPUTE_LOOP_sva_1_2;
  reg exit_COMPUTE_LOOP_sva_1_3;
  reg [31:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1;
  reg [4:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1;
  reg [9:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1;
  reg [2:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_2_itm_1;
  reg [6:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_3_itm_1;
  reg [6:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
  reg [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
  reg ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10;
  reg [6:0] CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11;
  reg CALC_SOFTMAX_LOOP_and_13_itm_1;
  reg CALC_SOFTMAX_LOOP_and_13_itm_2;
  reg CALC_SOFTMAX_LOOP_asn_14_itm_1;
  reg CALC_SOFTMAX_LOOP_asn_14_itm_2;
  reg CALC_SOFTMAX_LOOP_asn_14_itm_3;
  reg CALC_SOFTMAX_LOOP_asn_14_itm_5;
  reg [6:0] CALC_EXP_LOOP_i_7_0_lpi_2_6_0;
  reg [6:0] SUM_EXP_LOOP_i_7_0_lpi_2_6_0;
  reg [3:0] COMPUTE_LOOP_b_4_0_sva_3_0;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_1;
  reg lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_0;
  wire CALC_EXP_LOOP_and_svs_st_1_mx0c1;
  wire exitL_exit_LOAD_INNER_LOOP_sva_mx0w1;
  wire LOAD_INNER_LOOP_asn_itm_mx0c2;
  wire LOAD_OUTER_LOOP_stage_0_1_mx0c2;
  wire CALC_EXP_LOOP_and_svs_st_6_mx0c0;
  wire CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c0;
  wire CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1;
  wire [6:0] CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx1;
  wire COMPUTE_LOOP_b_4_0_sva_3_0_mx0c0;
  wire COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_4_mx0w0;
  wire COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_3_mx0w0;
  wire [93:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4;
  wire [18:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire signed [19:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire [18:0] ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_1_1;
  wire lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_0_1;
  wire [6:0] libraries_leading_sign_74_0_d122f99e9ffc18d7edc913ace0494619bed7_1;
  wire mux_122_tmp;
  wire or_284_tmp;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_tmp;
  wire and_279_rgt;
  wire and_285_rgt;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_3_rgt;
  wire CALC_SOFTMAX_LOOP_and_19_rgt;
  wire and_342_rgt;
  wire and_731_cse_1;
  wire nand_64_cse;
  wire ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse;
  wire ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse;
  wire CALC_SOFTMAX_LOOP_and_21_cse;
  wire mux_133_itm;
  wire [18:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28;
  wire COMPUTE_LOOP_acc_2_itm_32_1;

  wire[0:0] nor_43_nl;
  wire[0:0] or_313_nl;
  wire[0:0] and_354_nl;
  wire[0:0] and_356_nl;
  wire[0:0] LOAD_INNER_LOOP_LOAD_INNER_LOOP_and_nl;
  wire[0:0] and_362_nl;
  wire[0:0] mux_99_nl;
  wire[0:0] mux_98_nl;
  wire[0:0] mux_97_nl;
  wire[0:0] mux_95_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_or_nl;
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_4_nl;
  wire[0:0] nand_63_nl;
  wire[0:0] and_452_nl;
  wire[0:0] and_454_nl;
  wire[0:0] or_365_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_4_nl;
  wire[0:0] conf_done_mux1h_nl;
  wire[0:0] conf_done_and_1_nl;
  wire[0:0] conf_done_and_2_nl;
  wire[0:0] LOAD_INNER_LOOP_mux_12_nl;
  wire[3:0] dma_write_data_index_mux_nl;
  wire[0:0] dma_write_data_index_and_3_nl;
  wire[0:0] not_494_nl;
  wire[0:0] mux_113_nl;
  wire[0:0] and_298_nl;
  wire[0:0] CALC_EXP_LOOP_mux1h_6_nl;
  wire[0:0] CALC_EXP_LOOP_CALC_EXP_LOOP_or_nl;
  wire[0:0] operator_74_54_false_AC_TRN_AC_WRAP_1_operator_74_54_false_AC_TRN_AC_WRAP_1_and_nl;
  wire[0:0] CALC_EXP_LOOP_and_8_nl;
  wire[0:0] CALC_EXP_LOOP_and_9_nl;
  wire[0:0] LOAD_INNER_LOOP_mux_11_nl;
  wire[0:0] CALC_EXP_LOOP_CALC_EXP_LOOP_or_1_nl;
  wire[0:0] operator_74_54_false_AC_TRN_AC_WRAP_1_operator_74_54_false_AC_TRN_AC_WRAP_1_and_1_nl;
  wire[0:0] operator_74_54_false_AC_TRN_AC_WRAP_1_mux_nl;
  wire[0:0] or_295_nl;
  wire[0:0] mux_120_nl;
  wire[0:0] mux_119_nl;
  wire[0:0] mux_118_nl;
  wire[0:0] nand_57_nl;
  wire[0:0] mux_121_nl;
  wire[0:0] nand_20_nl;
  wire[0:0] CALC_EXP_LOOP_mux1h_12_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_nl;
  wire[0:0] CALC_EXP_LOOP_CALC_EXP_LOOP_and_nl;
  wire[0:0] CALC_EXP_LOOP_and_5_nl;
  wire[0:0] CALC_EXP_LOOP_and_6_nl;
  wire[0:0] and_712_nl;
  wire[0:0] mux_114_nl;
  wire[0:0] nor_45_nl;
  wire[0:0] CALC_EXP_LOOP_mux1h_16_nl;
  wire[0:0] CALC_EXP_LOOP_nor_3_nl;
  wire[0:0] CALC_EXP_LOOP_nor_4_nl;
  wire[0:0] CALC_EXP_LOOP_nor_5_nl;
  wire[0:0] mux_126_nl;
  wire[0:0] CALC_EXP_LOOP_CALC_EXP_LOOP_and_1_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_3_nl;
  wire[0:0] LOAD_INNER_LOOP_i_or_nl;
  wire[0:0] LOAD_INNER_LOOP_i_and_2_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_and_16_nl;
  wire[0:0] LOAD_INNER_LOOP_i_and_3_nl;
  wire[0:0] LOAD_INNER_LOOP_or_3_nl;
  wire[0:0] LOAD_INNER_LOOP_and_4_nl;
  wire[3:0] mux_nl;
  wire[0:0] or_497_nl;
  wire[0:0] nor_74_nl;
  wire[3:0] dma_read_data_index_and_nl;
  wire[3:0] dma_read_data_index_mux1h_nl;
  wire[0:0] and_660_nl;
  wire[0:0] or_462_nl;
  wire[0:0] and_665_nl;
  wire[0:0] STORE_OUTER_LOOP_not_4_nl;
  wire[0:0] mux_129_nl;
  wire[0:0] or_309_nl;
  wire[0:0] LOAD_OUTER_LOOP_LOAD_OUTER_LOOP_mux_nl;
  wire[0:0] STORE_INNER_LOOP_STORE_INNER_LOOP_and_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_nl;
  wire[0:0] ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_4_nl;
  wire[0:0] LOAD_INNER_LOOP_mux1h_nl;
  wire[0:0] and_346_nl;
  wire[0:0] and_348_nl;
  wire[0:0] LOAD_INNER_LOOP_mux_10_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_nor_1_nl;
  wire[0:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_1_nl;
  wire[73:0] CALC_SOFTMAX_LOOP_mux_23_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_mux_28_nl;
  wire[0:0] CALC_SOFTMAX_LOOP_or_14_nl;
  wire[6:0] CALC_SOFTMAX_LOOP_mux_29_nl;
  wire[46:0] ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire signed [47:0] nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl;
  wire[32:0] COMPUTE_LOOP_acc_2_nl;
  wire[33:0] nl_COMPUTE_LOOP_acc_2_nl;
  wire[0:0] nor_68_nl;
  wire[0:0] and_246_nl;
  wire[0:0] nand_40_nl;
  wire[0:0] mux_94_nl;
  wire[0:0] mux_93_nl;
  wire[0:0] mux_92_nl;
  wire[0:0] mux_112_nl;
  wire[0:0] and_708_nl;
  wire[0:0] mux_111_nl;
  wire[0:0] nor_42_nl;
  wire[3:0] STORE_OUTER_LOOP_mux_6_nl;
  wire[6:0] LOAD_INNER_LOOP_mux1h_11_nl;
  wire[0:0] LOAD_INNER_LOOP_or_5_nl;
  wire[0:0] LOAD_INNER_LOOP_and_11_nl;
  wire[0:0] LOAD_INNER_LOOP_and_12_nl;

  // Interconnect Declarations for Component Instantiations 
  wire[0:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_nl;
  wire [93:0] nl_CALC_SOFTMAX_LOOP_mul_cmp_b;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_nl
      = CALC_SOFTMAX_LOOP_and_13_itm_6 & (~((~ COMPUTE_LOOP_stage_0_7) | CALC_SOFTMAX_LOOP_asn_14_itm_6));
  assign nl_CALC_SOFTMAX_LOOP_mul_cmp_b = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4,
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_nl);
  wire[10:0] ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire[11:0] nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl;
  wire [73:0] nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a;
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_acc_nl
      = conv_s2u_9_11(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:10])
      + ({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm});
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
      = and_dcpl_135 & and_dcpl_144 & (fsm_output[2]);
  wire [66:0] nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_idat = {56'b01100000000000000000000000010000000000000000000000000000
      , dma_read_ctrl_rsci_idat_10_7 , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg
      = CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 & or_tmp_10 & dma_write_ctrl_rsci_bawt
      & STORE_INNER_LOOP_asn_itm_2 & (~ exit_STORE_OUTER_LOOP_sva_1_st_2) & (fsm_output[4]);
  wire [66:0] nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_idat =
      {56'b01100000000000000000000000010000000000000000000000000000 , dma_write_ctrl_rsci_idat_10_7
      , 7'b0000000};
  wire [0:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg
      = (~((~ CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1) | exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2
      | (~(dma_write_chnl_rsci_bawt & or_27_cse)))) & (fsm_output[4]);
  wire [63:0] nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat;
  assign nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat =
      {32'b11011110101011011011111011101111 , dma_write_chnl_rsci_idat_31_0};
  wire [0:0] nl_softmax_cxx_core_plm_in_data_rsci_1_inst_plm_in_data_rsci_oswt_unreg;
  assign nl_softmax_cxx_core_plm_in_data_rsci_1_inst_plm_in_data_rsci_oswt_unreg
      = plm_in_data_rsci_bawt & (~ exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2) & CALC_EXP_LOOP_and_svs_st_5
      & (fsm_output[2]);
  wire [0:0] nl_softmax_cxx_core_plm_in_data_rsci_1_inst_plm_in_data_rsci_oswt_unreg_1;
  assign nl_softmax_cxx_core_plm_in_data_rsci_1_inst_plm_in_data_rsci_oswt_unreg_1
      = COMPUTE_LOOP_stage_0_2 & (~ exit_COMPUTE_LOOP_lpi_2_dfm_st_1) & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1)
      & (fsm_output[3]);
  wire [0:0] nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_iswt0_pff;
  assign nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_iswt0_pff
      = COMPUTE_LOOP_stage_0_12 & (~ exit_COMPUTE_LOOP_lpi_2_dfm_st_11) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_1
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_0) & (fsm_output[3]);
  wire [0:0] nl_softmax_cxx_core_core_fsm_inst_LOAD_OUTER_LOOP_C_0_tr0;
  assign nl_softmax_cxx_core_core_fsm_inst_LOAD_OUTER_LOOP_C_0_tr0 = or_dcpl_14 &
      CALC_EXP_LOOP_and_svs_st_5 & (~(CALC_EXP_LOOP_and_svs_st_2 | LOAD_OUTER_LOOP_stage_0_1
      | CALC_EXP_LOOP_and_svs_st_1));
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
      .b(nl_CALC_SOFTMAX_LOOP_mul_cmp_b[93:0]),
      .clk(clk),
      .en(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .a_rst(1'b1),
      .s_rst(rst),
      .z(CALC_SOFTMAX_LOOP_mul_cmp_z)
    );
  esp_acc_softmax_cxx_mgc_shift_br_v5 #(.width_a(32'sd74),
  .signd_a(32'sd0),
  .width_s(32'sd8),
  .width_z(32'sd94)) operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg (
      .a(nl_operator_94_21_false_AC_TRN_AC_WRAP_rshift_rg_a[73:0]),
      .s(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm),
      .z(operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm)
    );
  esp_acc_softmax_cxx_mgc_shift_bl_v5 #(.width_a(32'sd21),
  .signd_a(32'sd0),
  .width_s(32'sd7),
  .width_z(32'sd67)) operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(nl_operator_67_47_false_AC_TRN_AC_WRAP_lshift_rg_a[20:0]),
      .s(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_18_12_itm_1),
      .z(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1)
    );
  esp_acc_softmax_cxx_mgc_shift_l_v5 #(.width_a(32'sd73),
  .signd_a(32'sd0),
  .width_s(32'sd7),
  .width_z(32'sd73)) operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg (
      .a(nl_operator_74_0_false_AC_TRN_AC_WRAP_lshift_rg_a[72:0]),
      .s(libraries_leading_sign_74_0_d122f99e9ffc18d7edc913ace0494619bed7_1),
      .z(operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm)
    );
  esp_acc_softmax_cxx_leading_sign_74_0  leading_sign_74_0_rg (
      .mantissa(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1),
      .rtn(libraries_leading_sign_74_0_d122f99e9ffc18d7edc913ace0494619bed7_1)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_wait_dp softmax_cxx_core_wait_dp_inst (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsci_irdy(dma_read_ctrl_rsci_irdy),
      .dma_read_ctrl_rsci_irdy_oreg(dma_read_ctrl_rsci_irdy_oreg),
      .dma_write_ctrl_rsci_irdy(dma_write_ctrl_rsci_irdy),
      .dma_write_ctrl_rsci_irdy_oreg(dma_write_ctrl_rsci_irdy_oreg),
      .dma_read_chnl_rsci_ivld(dma_read_chnl_rsci_ivld),
      .dma_read_chnl_rsci_ivld_oreg(dma_read_chnl_rsci_ivld_oreg),
      .dma_write_chnl_rsci_irdy(dma_write_chnl_rsci_irdy),
      .dma_write_chnl_rsci_irdy_oreg(dma_write_chnl_rsci_irdy_oreg)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_dma_read_ctrl_rsci softmax_cxx_core_dma_read_ctrl_rsci_inst
      (
      .clk(clk),
      .rst(rst),
      .dma_read_ctrl_rsc_dat(dma_read_ctrl_rsc_dat),
      .dma_read_ctrl_rsc_vld(dma_read_ctrl_rsc_vld),
      .dma_read_ctrl_rsc_rdy(dma_read_ctrl_rsc_rdy),
      .core_wen(core_wen),
      .dma_read_ctrl_rsci_irdy(dma_read_ctrl_rsci_irdy),
      .dma_read_ctrl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_read_ctrl_rsci_inst_dma_read_ctrl_rsci_oswt_unreg[0:0]),
      .dma_read_ctrl_rsci_bawt(dma_read_ctrl_rsci_bawt),
      .dma_read_ctrl_rsci_iswt0(dma_read_ctrl_rsci_iswt0),
      .dma_read_ctrl_rsci_wen_comp(dma_read_ctrl_rsci_wen_comp),
      .dma_read_ctrl_rsci_irdy_oreg(dma_read_ctrl_rsci_irdy_oreg),
      .dma_read_ctrl_rsci_ivld_core_psct(dma_read_ctrl_rsci_ivld_core_psct),
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
      .dma_write_ctrl_rsci_irdy(dma_write_ctrl_rsci_irdy),
      .dma_write_ctrl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_write_ctrl_rsci_inst_dma_write_ctrl_rsci_oswt_unreg[0:0]),
      .dma_write_ctrl_rsci_bawt(dma_write_ctrl_rsci_bawt),
      .dma_write_ctrl_rsci_iswt0(dma_write_ctrl_rsci_iswt0),
      .dma_write_ctrl_rsci_wen_comp(dma_write_ctrl_rsci_wen_comp),
      .dma_write_ctrl_rsci_irdy_oreg(dma_write_ctrl_rsci_irdy_oreg),
      .dma_write_ctrl_rsci_ivld_core_psct(dma_write_ctrl_rsci_ivld_core_psct),
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
      .dma_read_chnl_rsci_oswt_unreg(and_476_rmff),
      .dma_read_chnl_rsci_bawt(dma_read_chnl_rsci_bawt),
      .dma_read_chnl_rsci_iswt0(dma_read_chnl_rsci_iswt0),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_read_chnl_rsci_irdy_core_psct(dma_read_chnl_rsci_irdy_core_psct),
      .dma_read_chnl_rsci_ivld(dma_read_chnl_rsci_ivld),
      .dma_read_chnl_rsci_ivld_oreg(dma_read_chnl_rsci_ivld_oreg),
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
      .dma_write_chnl_rsci_irdy(dma_write_chnl_rsci_irdy),
      .dma_write_chnl_rsci_oswt_unreg(nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_oswt_unreg[0:0]),
      .dma_write_chnl_rsci_bawt(dma_write_chnl_rsci_bawt),
      .dma_write_chnl_rsci_iswt0(dma_write_chnl_rsci_iswt0),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_irdy_oreg(dma_write_chnl_rsci_irdy_oreg),
      .dma_write_chnl_rsci_ivld_core_psct(dma_write_chnl_rsci_ivld_core_psct),
      .dma_write_chnl_rsci_idat(nl_softmax_cxx_core_dma_write_chnl_rsci_inst_dma_write_chnl_rsci_idat[63:0])
    );
  esp_acc_softmax_cxx_softmax_cxx_core_plm_in_data_rsci_1 softmax_cxx_core_plm_in_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_in_data_rsci_q_d(plm_in_data_rsci_q_d),
      .plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_in_data_rsci_oswt_unreg(nl_softmax_cxx_core_plm_in_data_rsci_1_inst_plm_in_data_rsci_oswt_unreg[0:0]),
      .plm_in_data_rsci_bawt(plm_in_data_rsci_bawt),
      .plm_in_data_rsci_iswt0(reg_dma_read_chnl_rsci_oswt_cse),
      .plm_in_data_rsci_oswt_unreg_1(nl_softmax_cxx_core_plm_in_data_rsci_1_inst_plm_in_data_rsci_oswt_unreg_1[0:0]),
      .plm_in_data_rsci_iswt0_1(reg_plm_in_data_rsci_iswt0_1_cse),
      .plm_in_data_rsci_q_d_mxwt(plm_in_data_rsci_q_d_mxwt),
      .plm_in_data_rsci_we_d_pff(plm_in_data_rsci_we_d_iff),
      .plm_in_data_rsci_iswt0_pff(and_476_rmff),
      .plm_in_data_rsci_iswt0_1_pff(and_483_rmff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_plm_out_data_rsci_1 softmax_cxx_core_plm_out_data_rsci_1_inst
      (
      .clk(clk),
      .rst(rst),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .plm_out_data_rsci_oswt_unreg_1(or_tmp_150),
      .plm_out_data_rsci_iswt0_1(reg_plm_out_data_rsci_iswt0_1_cse),
      .plm_out_data_rsci_q_d_mxwt(plm_out_data_rsci_q_d_mxwt),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .plm_out_data_rsci_iswt0_pff(nl_softmax_cxx_core_plm_out_data_rsci_1_inst_plm_out_data_rsci_iswt0_pff[0:0]),
      .plm_out_data_rsci_iswt0_1_pff(and_490_rmff)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_acc_done_synci softmax_cxx_core_acc_done_synci_inst
      (
      .acc_done_sync_vld(acc_done_sync_vld),
      .core_wten(core_wten),
      .acc_done_synci_iswt0(reg_acc_done_synci_iswt0_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_debug_rsc_triosy_obj softmax_cxx_core_debug_rsc_triosy_obj_inst
      (
      .debug_rsc_triosy_lz(debug_rsc_triosy_lz),
      .core_wten(core_wten),
      .debug_rsc_triosy_obj_iswt0(reg_acc_done_synci_iswt0_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_info_batch_rsc_triosy_obj softmax_cxx_core_conf_info_batch_rsc_triosy_obj_inst
      (
      .conf_info_batch_rsc_triosy_lz(conf_info_batch_rsc_triosy_lz),
      .core_wten(core_wten),
      .conf_info_batch_rsc_triosy_obj_iswt0(reg_acc_done_synci_iswt0_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_conf_done_rsc_triosy_obj softmax_cxx_core_conf_done_rsc_triosy_obj_inst
      (
      .conf_done_rsc_triosy_lz(conf_done_rsc_triosy_lz),
      .core_wten(core_wten),
      .conf_done_rsc_triosy_obj_iswt0(reg_acc_done_synci_iswt0_cse)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_staller softmax_cxx_core_staller_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .core_wten(core_wten),
      .dma_read_ctrl_rsci_wen_comp(dma_read_ctrl_rsci_wen_comp),
      .dma_write_ctrl_rsci_wen_comp(dma_write_ctrl_rsci_wen_comp),
      .dma_read_chnl_rsci_wen_comp(dma_read_chnl_rsci_wen_comp),
      .dma_write_chnl_rsci_wen_comp(dma_write_chnl_rsci_wen_comp)
    );
  esp_acc_softmax_cxx_softmax_cxx_core_core_fsm softmax_cxx_core_core_fsm_inst (
      .clk(clk),
      .rst(rst),
      .core_wen(core_wen),
      .fsm_output(fsm_output),
      .CONFIG_LOOP_C_0_tr0(CALC_EXP_LOOP_and_svs_st_1),
      .LOAD_OUTER_LOOP_C_0_tr0(nl_softmax_cxx_core_core_fsm_inst_LOAD_OUTER_LOOP_C_0_tr0[0:0]),
      .COMPUTE_LOOP_C_0_tr0(COMPUTE_LOOP_nor_tmp),
      .STORE_OUTER_LOOP_C_0_tr0(and_dcpl_115)
    );
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d
      = core_wen;
  assign and_731_cse_1 = (z_out_1[7]) & (COMPUTE_LOOP_acc_1_tmp[4]);
  assign or_27_cse = (~ STORE_INNER_LOOP_asn_itm_2) | exit_STORE_OUTER_LOOP_sva_1_st_2
      | dma_write_ctrl_rsci_bawt;
  assign LOAD_OUTER_LOOP_and_cse = core_wen & ((and_dcpl_127 & COMPUTE_LOOP_acc_2_itm_32_1
      & LOAD_INNER_LOOP_asn_itm & and_dcpl_132 & (fsm_output[2])) | or_tmp_116);
  assign LOAD_INNER_LOOP_data_ac_mux_rmff = MUX_v_32_2_2(dma_read_chnl_rsci_idat_mxwt,
      plm_in_data_rsci_d_d_reg, or_tmp_122);
  assign CALC_EXP_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1,
      plm_in_data_rsci_wadr_d_reg, or_tmp_122);
  assign LOAD_INNER_LOOP_data_ac_LOAD_INNER_LOOP_data_ac_or_cse = ~(((~ nand_tmp_14)
      | or_dcpl_54) & or_dcpl_59 & or_dcpl_62 & and_dcpl_152 & (fsm_output[2]));
  assign mux_95_nl = MUX_s_1_2_2((~ or_tmp_80), nand_tmp_15, COMPUTE_LOOP_acc_2_itm_32_1);
  assign mux_97_nl = MUX_s_1_2_2(nand_tmp_15, mux_95_nl, LOAD_INNER_LOOP_asn_itm);
  assign mux_98_nl = MUX_s_1_2_2(nand_tmp_15, mux_97_nl, exitL_exit_LOAD_INNER_LOOP_sva);
  assign mux_99_nl = MUX_s_1_2_2(or_tmp_80, (~ mux_98_nl), and_dcpl_132);
  assign LOAD_INNER_LOOP_data_ac_and_cse = core_wen & (~((~ (fsm_output[2])) | mux_99_nl
      | and_dcpl_118));
  assign CALC_SOFTMAX_LOOP_mux_rmff = MUX_v_32_2_2((CALC_SOFTMAX_LOOP_mul_cmp_z[94:63]),
      plm_out_data_rsci_d_d_reg, or_tmp_130);
  assign CALC_SOFTMAX_LOOP_i_mux_rmff = MUX_v_7_2_2(CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11,
      plm_out_data_rsci_wadr_d_reg, or_tmp_130);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_tmp
      = CALC_SOFTMAX_LOOP_and_13_itm_6 & (~((~ COMPUTE_LOOP_stage_0_7) | CALC_SOFTMAX_LOOP_asn_14_itm_6));
  assign nand_63_nl = ~(mux_tmp_48 & COMPUTE_LOOP_stage_0 & (fsm_output[3]));
  assign LOAD_INNER_LOOP_mux_1_rmff = MUX_v_7_2_2(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx1,
      plm_in_data_rsci_radr_d_reg, nand_63_nl);
  assign STORE_OUTER_LOOP_and_cse = core_wen & (or_tmp_142 | (or_dcpl_20 & nor_tmp
      & (~ CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4) & CALC_EXP_LOOP_and_svs_st_1
      & (fsm_output[4])));
  assign STORE_INNER_LOOP_and_cse = core_wen & (or_tmp_149 | or_tmp_150);
  assign and_452_nl = mux_tmp_93 & or_tmp_1 & exitL_exit_STORE_INNER_LOOP_sva & CALC_EXP_LOOP_and_svs_st_5
      & CALC_EXP_LOOP_and_svs_st_3 & (fsm_output[4]);
  assign and_454_nl = and_dcpl_181 & (~ exitL_exit_STORE_INNER_LOOP_sva) & CALC_EXP_LOOP_and_svs_st_5
      & CALC_EXP_LOOP_and_svs_st_3 & (fsm_output[4]);
  assign or_365_nl = (~ (fsm_output[4])) | (~ mux_tmp_94) | or_dcpl_95;
  assign STORE_INNER_LOOP_mux1h_3_rmff = MUX1HOT_v_7_3_2((signext_7_1(~ COMPUTE_LOOP_acc_2_itm_32_1)),
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0, plm_out_data_rsci_radr_d_reg, {and_452_nl ,
      and_454_nl , or_365_nl});
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse = core_wen
      & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_8_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b000) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_9_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b001) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_10_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b010) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_11_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b011) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_12_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b100) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_13_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b101) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_14_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b110) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_15_cse
      = (operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[72:70]==3'b111) & or_tmp_165;
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
      = core_wen & (ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_8_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_9_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_10_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_11_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_12_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_13_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_14_cse
      | ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_15_cse);
  assign and_476_rmff = or_dcpl_59 & or_dcpl_62 & and_dcpl_152 & (fsm_output[2]);
  assign and_483_rmff = mux_tmp_48 & COMPUTE_LOOP_stage_0 & (fsm_output[3]);
  assign and_490_rmff = and_dcpl_200 & and_dcpl_3 & (fsm_output[4]);
  assign CALC_SOFTMAX_LOOP_and_21_cse = core_wen & (~((~ COMPUTE_LOOP_stage_0) |
      (fsm_output[5:4]!=2'b00)));
  assign and_279_rgt = COMPUTE_LOOP_stage_0_7 & (~ CALC_SOFTMAX_LOOP_and_13_itm_6)
      & (fsm_output[3]);
  assign and_286_m1c = COMPUTE_LOOP_stage_0_4 & (~ CALC_SOFTMAX_LOOP_asn_2_itm_3);
  assign and_285_rgt = COMPUTE_LOOP_stage_0_4 & CALC_SOFTMAX_LOOP_asn_2_itm_3 & (fsm_output[3]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_3_rgt
      = ((CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4 & (~ or_186_tmp) & and_286_m1c)
      | ((~ COMPUTE_LOOP_stage_0_4) & COMPUTE_LOOP_stage_0_5 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4))
      & (fsm_output[3]);
  assign CALC_SOFTMAX_LOOP_and_19_rgt = or_186_tmp & and_286_m1c & (fsm_output[3]);
  assign and_298_nl = CALC_EXP_LOOP_and_svs_st_2 & or_dcpl_62 & or_dcpl_60 & CALC_EXP_LOOP_and_svs_st_4;
  assign mux_113_nl = MUX_s_1_2_2(and_298_nl, or_dcpl_63, and_dcpl_132);
  assign or_284_tmp = (~ mux_113_nl) | and_dcpl_118;
  assign mux_122_tmp = MUX_s_1_2_2(and_dcpl_174, and_dcpl_181, and_dcpl_3);
  assign nand_64_cse = ~((COMPUTE_LOOP_acc_1_tmp[4]) & (z_out_1[7]));
  assign nor_45_nl = ~(COMPUTE_LOOP_acc_2_itm_32_1 | and_dcpl_167);
  assign mux_114_nl = MUX_s_1_2_2(or_dcpl_20, nor_45_nl, STORE_INNER_LOOP_asn_itm);
  assign and_712_nl = exitL_exit_STORE_INNER_LOOP_sva & mux_114_nl;
  assign mux_133_itm = MUX_s_1_2_2(and_712_nl, or_dcpl_20, and_731_cse_1);
  assign and_342_rgt = or_dcpl_20 & (~ STORE_INNER_LOOP_asn_itm);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_nor_1_nl
      = ~(CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4 | or_186_tmp);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_1_nl
      = CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4 & (~ or_186_tmp);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1
      = MUX1HOT_v_74_3_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
      {ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_nor_1_nl
      , ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_1_nl
      , or_186_tmp});
  assign CALC_EXP_LOOP_and_svs_1 = (CALC_EXP_LOOP_acc_1_tmp[7]) & (SUM_EXP_LOOP_acc_2_tmp[7]);
  assign exitL_exit_LOAD_INNER_LOOP_sva_mx0w1 = ~((COMPUTE_LOOP_acc_1_tmp[4]) | (~
      (z_out_1[7])));
  assign CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx1 = MUX_v_7_2_2(CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
      (signext_7_1(~ COMPUTE_LOOP_acc_2_itm_32_1)), exitL_exit_CALC_SOFTMAX_LOOP_sva);
  assign nl_COMPUTE_LOOP_acc_1_tmp = conv_u2u_4_5(COMPUTE_LOOP_b_4_0_sva_3_0) + 5'b00001;
  assign COMPUTE_LOOP_acc_1_tmp = nl_COMPUTE_LOOP_acc_1_tmp[4:0];
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_4_mx0w0 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1
      & (~ COMPUTE_LOOP_acc_2_itm_32_1);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0 = MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1,
      COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_4_mx0w0, exitL_exit_CALC_SOFTMAX_LOOP_sva);
  assign COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_3_mx0w0 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_0
      & (~ COMPUTE_LOOP_acc_2_itm_32_1);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0 = MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_0,
      COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_3_mx0w0, exitL_exit_CALC_SOFTMAX_LOOP_sva);
  assign exit_COMPUTE_LOOP_lpi_2_dfm_1 = (~ COMPUTE_LOOP_acc_2_itm_32_1) & exitL_exit_CALC_SOFTMAX_LOOP_sva;
  assign CALC_SOFTMAX_LOOP_mux_23_nl = MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_4,
      CALC_SOFTMAX_LOOP_asn_2_itm_3);
  assign nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2
      = CALC_SOFTMAX_LOOP_mux_23_nl + conv_u2u_67_74(operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2
      = nl_ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2[73:0];
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4
      = MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1,
      94'b1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111,
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3);
  assign CALC_SOFTMAX_LOOP_equal_tmp_2 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0);
  assign nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = $signed(({1'b1 , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm}))
      * $signed(conv_u2s_10_11(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = nl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1[18:0];
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_4
      = MUX_v_74_2_2(74'b00000000000000000000000000000000000000000000000000000000000000000000000000,
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_mx1,
      exit_COMPUTE_LOOP_sva_1_3);
  assign ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mul_psp_sva_1
      = conv_u2u_19_19(({ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_itm_1
      , 1'b0 , ac_math_ac_pow2_pwl_AC_TRN_33_7_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_output_pwl_mux_1_itm_1})
      * ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_slc_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_input_inter_32_14_11_0_1_itm_1);
  assign CALC_SOFTMAX_LOOP_or_tmp_1 = (lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0
      & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0)) | (~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0
      | lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0));
  assign CALC_SOFTMAX_LOOP_equal_tmp_3 = lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0
      & lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0;
  assign nl_CALC_EXP_LOOP_acc_1_tmp = conv_u2u_7_8(CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx1)
      + 8'b00000001;
  assign CALC_EXP_LOOP_acc_1_tmp = nl_CALC_EXP_LOOP_acc_1_tmp[7:0];
  assign CALC_SOFTMAX_LOOP_or_14_nl = ((~ (z_out_1[7])) & CALC_SOFTMAX_LOOP_equal_tmp_2)
      | CALC_SOFTMAX_LOOP_equal_tmp_3;
  assign CALC_SOFTMAX_LOOP_mux_28_nl = MUX_s_1_2_2((COMPUTE_LOOP_acc_1_tmp[4]), lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1,
      CALC_SOFTMAX_LOOP_or_14_nl);
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_1_1 = (CALC_SOFTMAX_LOOP_mux_28_nl
      & (~ CALC_SOFTMAX_LOOP_and_6_ssc_1)) | CALC_SOFTMAX_LOOP_and_7_ssc_1;
  assign lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_0_1 = (lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0
      & (~(CALC_SOFTMAX_LOOP_and_7_ssc_1 | ((z_out_1[7]) & CALC_SOFTMAX_LOOP_equal_tmp_2))))
      | CALC_SOFTMAX_LOOP_and_6_ssc_1;
  assign CALC_SOFTMAX_LOOP_mux_29_nl = MUX_v_7_2_2(SUM_EXP_LOOP_i_7_0_lpi_2_6_0,
      (signext_7_1(~ COMPUTE_LOOP_acc_2_itm_32_1)), exitL_exit_CALC_SOFTMAX_LOOP_sva);
  assign nl_SUM_EXP_LOOP_acc_2_tmp = conv_u2u_7_8(CALC_SOFTMAX_LOOP_mux_29_nl) +
      8'b00000001;
  assign SUM_EXP_LOOP_acc_2_tmp = nl_SUM_EXP_LOOP_acc_2_tmp[7:0];
  assign CALC_SOFTMAX_LOOP_and_6_ssc_1 = (~ CALC_EXP_LOOP_and_svs_1) & CALC_SOFTMAX_LOOP_or_tmp_1;
  assign CALC_SOFTMAX_LOOP_and_7_ssc_1 = CALC_EXP_LOOP_and_svs_1 & CALC_SOFTMAX_LOOP_or_tmp_1;
  assign nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = $signed(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1)
      * $signed(16'b0101110001010101);
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl
      = nl_ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl[46:0];
  assign ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_itm_46_28
      = readslicef_47_19_28(ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_mul_nl);
  assign nl_COMPUTE_LOOP_acc_2_nl = ({29'b10000000000000000000000000000 , COMPUTE_LOOP_b_4_0_sva_3_0})
      + conv_u2u_32_33(~ conf_info_batch_sva) + 33'b000000000000000000000000000000001;
  assign COMPUTE_LOOP_acc_2_nl = nl_COMPUTE_LOOP_acc_2_nl[32:0];
  assign COMPUTE_LOOP_acc_2_itm_32_1 = readslicef_33_1_32(COMPUTE_LOOP_acc_2_nl);
  assign COMPUTE_LOOP_nor_tmp = ~(COMPUTE_LOOP_stage_0 | COMPUTE_LOOP_stage_0_2 |
      COMPUTE_LOOP_stage_0_3 | COMPUTE_LOOP_stage_0_4 | COMPUTE_LOOP_stage_0_5 |
      COMPUTE_LOOP_stage_0_6 | COMPUTE_LOOP_stage_0_7 | COMPUTE_LOOP_stage_0_8 |
      COMPUTE_LOOP_stage_0_9 | COMPUTE_LOOP_stage_0_10 | COMPUTE_LOOP_stage_0_11
      | COMPUTE_LOOP_stage_0_12);
  assign or_tmp_1 = (~ CALC_EXP_LOOP_and_svs_st_6) | CALC_EXP_LOOP_and_svs_st_4;
  assign nor_tmp = CALC_EXP_LOOP_and_svs_st_6 & CALC_EXP_LOOP_and_svs_st_4;
  assign or_tmp_10 = exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2 | dma_write_chnl_rsci_bawt;
  assign or_dcpl_14 = plm_in_data_rsci_bawt | exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2;
  assign and_dcpl_3 = CALC_EXP_LOOP_and_svs_st_5 & CALC_EXP_LOOP_and_svs_st_3;
  assign and_dcpl_6 = or_27_cse & or_tmp_10;
  assign or_dcpl_20 = and_dcpl_6 | (~ CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1);
  assign and_dcpl_24 = COMPUTE_LOOP_stage_0_5 & (~ exit_COMPUTE_LOOP_lpi_2_dfm_st_4);
  assign or_dcpl_32 = (~ exitL_exit_CALC_SOFTMAX_LOOP_sva) | COMPUTE_LOOP_acc_2_itm_32_1;
  assign or_69_cse = (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1) | exitL_exit_CALC_SOFTMAX_LOOP_sva;
  assign nor_68_nl = ~(lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1 | exitL_exit_CALC_SOFTMAX_LOOP_sva);
  assign mux_tmp_48 = MUX_s_1_2_2(nor_68_nl, or_69_cse, COMPUTE_LOOP_acc_2_itm_32_1);
  assign and_dcpl_115 = and_dcpl_6 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1
      & (~ CALC_EXP_LOOP_and_svs_st_4) & (~ CALC_EXP_LOOP_and_svs_st_2) & (~ CALC_EXP_LOOP_and_svs_st_3);
  assign or_dcpl_54 = ~(LOAD_OUTER_LOOP_stage_0_1 & CALC_EXP_LOOP_and_svs_st_3);
  assign and_dcpl_118 = (~(plm_in_data_rsci_bawt | exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2))
      & CALC_EXP_LOOP_and_svs_st_5;
  assign and_dcpl_119 = ~(exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1 | dma_read_chnl_rsci_bawt);
  assign or_dcpl_56 = and_dcpl_119 | (~ CALC_EXP_LOOP_and_svs_st_2);
  assign and_dcpl_121 = (~ dma_read_ctrl_rsci_bawt) & LOAD_INNER_LOOP_asn_itm_1 &
      (~ exit_LOAD_OUTER_LOOP_sva_1_st_1);
  assign and_dcpl_122 = (and_dcpl_121 | or_dcpl_56) & CALC_EXP_LOOP_and_svs_st_4;
  assign or_dcpl_59 = or_dcpl_14 | (~ CALC_EXP_LOOP_and_svs_st_5);
  assign or_dcpl_60 = exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1 | dma_read_chnl_rsci_bawt;
  assign or_dcpl_62 = dma_read_ctrl_rsci_bawt | (~ LOAD_INNER_LOOP_asn_itm_1) | exit_LOAD_OUTER_LOOP_sva_1_st_1;
  assign and_dcpl_125 = or_dcpl_62 & or_dcpl_60;
  assign or_dcpl_63 = ~((~(and_dcpl_125 & CALC_EXP_LOOP_and_svs_st_2)) & CALC_EXP_LOOP_and_svs_st_4);
  assign and_dcpl_127 = or_dcpl_63 & or_dcpl_59;
  assign and_dcpl_132 = LOAD_OUTER_LOOP_stage_0_1 & CALC_EXP_LOOP_and_svs_st_3;
  assign and_dcpl_133 = and_dcpl_127 & and_dcpl_132;
  assign and_dcpl_134 = CALC_EXP_LOOP_and_svs_st_4 & CALC_EXP_LOOP_and_svs_st_2;
  assign and_dcpl_135 = or_dcpl_59 & or_dcpl_60;
  assign and_dcpl_136 = and_dcpl_135 & or_dcpl_62;
  assign and_dcpl_137 = and_dcpl_136 & and_dcpl_134;
  assign and_dcpl_144 = CALC_EXP_LOOP_and_svs_st_4 & dma_read_ctrl_rsci_bawt & LOAD_INNER_LOOP_asn_itm_1
      & (~ exit_LOAD_OUTER_LOOP_sva_1_st_1) & CALC_EXP_LOOP_and_svs_st_2;
  assign nand_tmp_14 = ~(exitL_exit_LOAD_INNER_LOOP_sva & (~ COMPUTE_LOOP_acc_2_itm_32_1));
  assign not_tmp_118 = ~(CALC_EXP_LOOP_and_svs_st_4 | (~ nand_tmp_14));
  assign and_dcpl_152 = CALC_EXP_LOOP_and_svs_st_4 & (~ exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1)
      & dma_read_chnl_rsci_bawt & CALC_EXP_LOOP_and_svs_st_2;
  assign nor_tmp_27 = or_dcpl_62 & CALC_EXP_LOOP_and_svs_st_2;
  assign nand_tmp_15 = ~(CALC_EXP_LOOP_and_svs_st_4 & (~(or_dcpl_60 & nor_tmp_27)));
  assign or_tmp_80 = (~ CALC_EXP_LOOP_and_svs_st_4) | exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1
      | (~(dma_read_chnl_rsci_bawt & nor_tmp_27));
  assign and_dcpl_157 = (~ exit_STORE_OUTER_LOOP_sva_1_st_2) & STORE_INNER_LOOP_asn_itm_2;
  assign or_dcpl_86 = ~(CALC_EXP_LOOP_and_svs_st_6 & CALC_EXP_LOOP_and_svs_st_4);
  assign or_dcpl_87 = or_dcpl_86 | CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4
      | (~ CALC_EXP_LOOP_and_svs_st_1);
  assign or_dcpl_89 = (and_dcpl_157 & (~ dma_write_ctrl_rsci_bawt)) | (~(dma_write_chnl_rsci_bawt
      | exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2));
  assign and_dcpl_167 = or_dcpl_89 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1;
  assign or_dcpl_91 = or_dcpl_86 | CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2;
  assign and_dcpl_174 = or_dcpl_20 & nor_tmp;
  assign and_246_nl = COMPUTE_LOOP_acc_2_itm_32_1 & or_dcpl_20;
  assign mux_tmp_93 = MUX_s_1_2_2((~ and_dcpl_167), and_246_nl, STORE_INNER_LOOP_asn_itm);
  assign and_dcpl_181 = or_dcpl_20 & or_tmp_1;
  assign or_dcpl_94 = ~(CALC_EXP_LOOP_and_svs_st_5 & CALC_EXP_LOOP_and_svs_st_3);
  assign or_dcpl_95 = (CALC_EXP_LOOP_and_svs_st_6 & (~ CALC_EXP_LOOP_and_svs_st_4))
      | or_dcpl_94;
  assign mux_tmp_94 = MUX_s_1_2_2(or_dcpl_20, mux_tmp_93, exitL_exit_STORE_INNER_LOOP_sva);
  assign and_dcpl_200 = mux_tmp_94 & or_tmp_1;
  assign and_dcpl_207 = or_dcpl_32 & COMPUTE_LOOP_stage_0;
  assign nand_40_nl = ~((~(or_dcpl_62 & CALC_EXP_LOOP_and_svs_st_2)) & CALC_EXP_LOOP_and_svs_st_4);
  assign mux_107_cse = MUX_s_1_2_2((~ CALC_EXP_LOOP_and_svs_st_4), nand_40_nl, or_dcpl_60);
  assign or_dcpl_176 = and_dcpl_125 | (~ CALC_EXP_LOOP_and_svs_st_4);
  assign and_dcpl_218 = or_dcpl_176 & or_dcpl_59;
  assign or_dcpl_183 = and_dcpl_167 | (~ (z_out_1[7])) | (~ CALC_EXP_LOOP_and_svs_st_5);
  assign mux_92_nl = MUX_s_1_2_2(not_tmp_118, nand_tmp_14, or_dcpl_60);
  assign mux_93_nl = MUX_s_1_2_2(not_tmp_118, mux_92_nl, or_dcpl_62);
  assign mux_94_nl = MUX_s_1_2_2(not_tmp_118, mux_93_nl, CALC_EXP_LOOP_and_svs_st_2);
  assign and_dcpl_223 = mux_94_nl & or_dcpl_59 & nand_64_cse;
  assign or_tmp_104 = CALC_EXP_LOOP_and_svs_st_1 | (~ mux_107_cse);
  assign or_dcpl_197 = and_dcpl_167 | (~ CALC_EXP_LOOP_and_svs_st_5);
  assign or_tmp_112 = and_dcpl_133 & (fsm_output[2]);
  assign or_tmp_116 = ((~ COMPUTE_LOOP_acc_2_itm_32_1) | (~ LOAD_INNER_LOOP_asn_itm)
      | or_dcpl_54) & or_dcpl_60 & or_dcpl_59 & and_dcpl_144 & (fsm_output[2]);
  assign or_tmp_122 = (~ (fsm_output[2])) | and_dcpl_118 | (~ CALC_EXP_LOOP_and_svs_st_4)
      | exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1 | and_dcpl_121 | (~(dma_read_chnl_rsci_bawt
      & CALC_EXP_LOOP_and_svs_st_2));
  assign or_tmp_130 = (~ COMPUTE_LOOP_stage_0_12) | exit_COMPUTE_LOOP_lpi_2_dfm_st_11
      | (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_1) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_0
      | (~ (fsm_output[3]));
  assign or_tmp_133 = (fsm_output[2:1]!=2'b00);
  assign or_tmp_142 = or_dcpl_87 & or_tmp_10 & and_dcpl_157 & dma_write_ctrl_rsci_bawt
      & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 & (fsm_output[4]);
  assign or_tmp_149 = or_27_cse & dma_write_chnl_rsci_bawt & (~ exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2)
      & or_dcpl_91 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 & (fsm_output[4]);
  assign or_tmp_150 = or_dcpl_20 & nor_tmp & (~ CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2)
      & (fsm_output[4]);
  assign or_tmp_156 = and_dcpl_174 & (fsm_output[4]);
  assign or_tmp_165 = ((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000))
      & and_dcpl_24 & CALC_EXP_LOOP_and_svs_st_4 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1)
      & (fsm_output[3]);
  assign nor_42_nl = ~(COMPUTE_LOOP_acc_2_itm_32_1 | (~ mux_107_cse));
  assign mux_111_nl = MUX_s_1_2_2(mux_107_cse, nor_42_nl, LOAD_INNER_LOOP_asn_itm);
  assign and_708_nl = exitL_exit_LOAD_INNER_LOOP_sva & mux_111_nl;
  assign mux_112_nl = MUX_s_1_2_2(and_708_nl, mux_107_cse, and_731_cse_1);
  assign or_tmp_203 = mux_112_nl & or_dcpl_59 & and_dcpl_132 & (fsm_output[2]);
  assign or_tmp_209 = and_dcpl_218 & CALC_EXP_LOOP_and_svs_st_3 & (fsm_output[2]);
  assign CALC_EXP_LOOP_and_svs_st_1_mx0c1 = CALC_EXP_LOOP_and_svs_st_1 & (fsm_output[1]);
  assign LOAD_INNER_LOOP_asn_itm_mx0c2 = (~ CALC_EXP_LOOP_and_svs_st_3) & (fsm_output[2]);
  assign LOAD_OUTER_LOOP_stage_0_1_mx0c2 = and_dcpl_223 & and_dcpl_132 & (fsm_output[2]);
  assign CALC_EXP_LOOP_and_svs_st_6_mx0c0 = LOAD_INNER_LOOP_asn_itm & CALC_EXP_LOOP_and_svs_st_3
      & (fsm_output[2]);
  assign CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c0 = or_dcpl_176
      & or_dcpl_59 & exitL_exit_LOAD_INNER_LOOP_sva & (fsm_output[2]);
  assign CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1 = or_dcpl_176
      & or_dcpl_59 & (~ exitL_exit_LOAD_INNER_LOOP_sva) & (fsm_output[2]);
  assign COMPUTE_LOOP_b_4_0_sva_3_0_mx0c0 = (fsm_output[1]) | ((~ LOAD_OUTER_LOOP_stage_0_1)
      & (fsm_output[2]));
  assign or_303_tmp = ((~ exitL_exit_CALC_SOFTMAX_LOOP_sva) & lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1)
      | CALC_EXP_LOOP_and_svs_1;
  assign CALC_SOFTMAX_LOOP_and_10_tmp = CALC_SOFTMAX_LOOP_equal_tmp_2 & (~ exit_COMPUTE_LOOP_lpi_2_dfm_1);
  assign or_186_tmp = (~ COMPUTE_LOOP_stage_0_5) | CALC_SOFTMAX_LOOP_asn_14_itm_4;
  assign plm_in_data_rsci_d_d = LOAD_INNER_LOOP_data_ac_mux_rmff;
  assign plm_in_data_rsci_radr_d = LOAD_INNER_LOOP_mux_1_rmff;
  assign plm_in_data_rsci_wadr_d = CALC_EXP_LOOP_i_mux_rmff;
  assign plm_in_data_rsci_we_d_pff = plm_in_data_rsci_we_d_iff;
  assign plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign plm_out_data_rsci_d_d = CALC_SOFTMAX_LOOP_mux_rmff;
  assign plm_out_data_rsci_radr_d = STORE_INNER_LOOP_mux1h_3_rmff;
  assign plm_out_data_rsci_wadr_d = CALC_SOFTMAX_LOOP_i_mux_rmff;
  assign plm_out_data_rsci_we_d_pff = plm_out_data_rsci_we_d_iff;
  assign plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d = plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d_reg;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d
      = operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1_1;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff
      = CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4;
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_pff
      = and_dcpl_24 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1) & (fsm_output[3]);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d
      = and_dcpl_24 & lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1 & (~ lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_0)
      & (fsm_output[3]);
  always @(posedge clk) begin
    if ( core_wen ) begin
      conf_info_batch_sva <= MUX_v_32_2_2(conf_info_batch_rsci_idat, conf_info_batch_sva,
          nor_43_nl);
      plm_in_data_rsci_d_d_reg <= LOAD_INNER_LOOP_data_ac_mux_rmff;
      plm_in_data_rsci_wadr_d_reg <= CALC_EXP_LOOP_i_mux_rmff;
      plm_out_data_rsci_d_d_reg <= CALC_SOFTMAX_LOOP_mux_rmff;
      plm_out_data_rsci_wadr_d_reg <= CALC_SOFTMAX_LOOP_i_mux_rmff;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2
          <= MUX1HOT_v_94_3_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4,
          {(fsm_output[0]) , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_or_nl
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_4_nl});
      plm_in_data_rsci_radr_d_reg <= LOAD_INNER_LOOP_mux_1_rmff;
      plm_out_data_rsci_radr_d_reg <= STORE_INNER_LOOP_mux1h_3_rmff;
      dma_write_data_index_10_7_sva <= MUX_v_4_2_2(4'b0000, dma_write_data_index_mux_nl,
          not_494_nl);
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2 <= MUX_v_7_2_2(({3'b000
          , dma_read_data_index_and_nl}), CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1,
          fsm_output[3]);
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_11 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10;
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_sva_1_1
          <= operator_94_21_false_AC_TRN_AC_WRAP_rshift_itm;
      operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1_1 <= operator_67_47_false_AC_TRN_AC_WRAP_lshift_ncse_sva_1;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3;
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
      SUM_EXP_LOOP_i_7_0_lpi_2_6_0 <= SUM_EXP_LOOP_acc_2_tmp[6:0];
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_10 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9;
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_3 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2;
      ac_math_ac_exp_pwl_0_AC_TRN_32_6_true_AC_TRN_AC_WRAP_67_47_AC_TRN_AC_WRAP_asn_itm_1
          <= plm_in_data_rsci_q_d_mxwt;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_9 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_8 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_7 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_6 <= CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5;
      CALC_SOFTMAX_LOOP_i_slc_CALC_SOFTMAX_LOOP_i_7_0_6_0_itm_5 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_4;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exit_LOAD_OUTER_LOOP_sva_1_st_1 <= 1'b0;
      exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1 <= 1'b0;
      LOAD_INNER_LOOP_asn_itm_1 <= 1'b0;
      exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1 <= 1'b0;
      exit_STORE_OUTER_LOOP_sva_1_st_2 <= 1'b0;
      exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2 <= 1'b0;
      STORE_INNER_LOOP_asn_itm_2 <= 1'b0;
      reg_dma_read_chnl_rsci_oswt_cse <= 1'b0;
      reg_plm_in_data_rsci_iswt0_1_cse <= 1'b0;
      reg_plm_out_data_rsci_iswt0_1_cse <= 1'b0;
      reg_acc_done_synci_iswt0_cse <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_2 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_4 <= 1'b0;
      CALC_EXP_LOOP_and_svs_st_5 <= 1'b0;
      COMPUTE_LOOP_stage_0 <= 1'b0;
      exitL_exit_CALC_SOFTMAX_LOOP_sva <= 1'b0;
      COMPUTE_LOOP_stage_0_2 <= 1'b0;
      COMPUTE_LOOP_stage_0_3 <= 1'b0;
      COMPUTE_LOOP_stage_0_4 <= 1'b0;
      COMPUTE_LOOP_stage_0_5 <= 1'b0;
      COMPUTE_LOOP_stage_0_6 <= 1'b0;
      COMPUTE_LOOP_stage_0_7 <= 1'b0;
      COMPUTE_LOOP_stage_0_8 <= 1'b0;
      COMPUTE_LOOP_stage_0_9 <= 1'b0;
      COMPUTE_LOOP_stage_0_10 <= 1'b0;
      COMPUTE_LOOP_stage_0_11 <= 1'b0;
      COMPUTE_LOOP_stage_0_12 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_11 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_0 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_14_itm_6 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_itm_6 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_6 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_5 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_0 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_14_itm_4 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_4 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_3 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_2 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_1 <= 1'b0;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= 74'b00000000000000000000000000000000000000000000000000000000000000000000000000;
      exit_COMPUTE_LOOP_sva_1_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_2_itm_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_14_itm_3 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_14_itm_5 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_10 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_itm_5 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_14_itm_2 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_9 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_itm_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_itm_4 <= 1'b0;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= 1'b0;
      exit_COMPUTE_LOOP_sva_1_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_asn_14_itm_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_8 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_itm_3 <= 1'b0;
      exit_COMPUTE_LOOP_sva_1_1 <= 1'b0;
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_0 <= 1'b0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_7 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_itm_2 <= 1'b0;
      CALC_SOFTMAX_LOOP_and_13_itm_1 <= 1'b0;
      STORE_INNER_LOOP_asn_itm <= 1'b0;
      exitL_exit_STORE_INNER_LOOP_sva <= 1'b0;
    end
    else if ( core_wen ) begin
      exit_LOAD_OUTER_LOOP_sva_1_st_1 <= MUX1HOT_s_1_3_2(exit_LOAD_OUTER_LOOP_sva_1_st_1,
          (~ COMPUTE_LOOP_acc_2_itm_32_1), CALC_EXP_LOOP_and_svs_st_6, {or_313_nl
          , and_354_nl , and_356_nl});
      exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1 <= MUX_s_1_2_2(exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1,
          LOAD_INNER_LOOP_LOAD_INNER_LOOP_and_nl, or_tmp_112);
      LOAD_INNER_LOOP_asn_itm_1 <= MUX_s_1_2_2(LOAD_INNER_LOOP_asn_itm_1, LOAD_INNER_LOOP_asn_itm,
          or_tmp_112);
      exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2 <= MUX_s_1_2_2(exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_2,
          exit_LOAD_OUTER_LOOP_lpi_2_dfm_st_1, and_362_nl);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1 <= MUX1HOT_s_1_3_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_1,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_1, lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_1_1,
          {(fsm_output[0]) , or_tmp_133 , (fsm_output[3])});
      exit_STORE_OUTER_LOOP_sva_1_st_2 <= MUX_s_1_2_2(exit_STORE_OUTER_LOOP_sva_1_st_2,
          CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4, or_tmp_156);
      exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2 <= MUX_s_1_2_2(exit_STORE_OUTER_LOOP_lpi_2_dfm_st_2,
          CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2, or_tmp_156);
      STORE_INNER_LOOP_asn_itm_2 <= MUX_s_1_2_2(STORE_INNER_LOOP_asn_itm_2, CALC_EXP_LOOP_and_svs_st_1,
          or_tmp_156);
      reg_dma_read_chnl_rsci_oswt_cse <= and_476_rmff;
      reg_plm_in_data_rsci_iswt0_1_cse <= and_483_rmff;
      reg_plm_out_data_rsci_iswt0_1_cse <= and_490_rmff;
      reg_acc_done_synci_iswt0_cse <= and_dcpl_115 & (fsm_output[4]);
      CALC_EXP_LOOP_and_svs_st_2 <= CALC_EXP_LOOP_mux1h_6_nl & (~ (fsm_output[1]));
      CALC_EXP_LOOP_and_svs_st_4 <= CALC_EXP_LOOP_mux1h_12_nl & (~ (fsm_output[1]));
      CALC_EXP_LOOP_and_svs_st_5 <= ~(CALC_EXP_LOOP_mux1h_16_nl | (fsm_output[1]));
      COMPUTE_LOOP_stage_0 <= ~((~(COMPUTE_LOOP_stage_0 & mux_129_nl)) & (fsm_output[3]));
      exitL_exit_CALC_SOFTMAX_LOOP_sva <= ~((lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_1_1
          | lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_0_1) & (fsm_output[3]));
      COMPUTE_LOOP_stage_0_2 <= COMPUTE_LOOP_stage_0 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_3 <= COMPUTE_LOOP_stage_0_2 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_4 <= COMPUTE_LOOP_stage_0_3 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_5 <= COMPUTE_LOOP_stage_0_4 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_6 <= COMPUTE_LOOP_stage_0_5 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_7 <= COMPUTE_LOOP_stage_0_6 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_8 <= (fsm_output[3]) & COMPUTE_LOOP_stage_0_7;
      COMPUTE_LOOP_stage_0_9 <= COMPUTE_LOOP_stage_0_8 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_10 <= COMPUTE_LOOP_stage_0_9 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_11 <= COMPUTE_LOOP_stage_0_10 & (fsm_output[3]);
      COMPUTE_LOOP_stage_0_12 <= COMPUTE_LOOP_stage_0_11 & (fsm_output[3]);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_11_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_11 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_10;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_3
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_0;
      CALC_SOFTMAX_LOOP_asn_14_itm_6 <= CALC_SOFTMAX_LOOP_asn_14_itm_5;
      CALC_SOFTMAX_LOOP_and_13_itm_6 <= CALC_SOFTMAX_LOOP_and_13_itm_5;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_6 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_5;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_5_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_5 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_4;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_4_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_0;
      CALC_SOFTMAX_LOOP_asn_14_itm_4 <= CALC_SOFTMAX_LOOP_asn_14_itm_3;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_4 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_3;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_3_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_3 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_2;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_2_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_2 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_1_mx0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_1_0_mx0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_1 <= exit_COMPUTE_LOOP_lpi_2_dfm_1;
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1
          <= ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2;
      exit_COMPUTE_LOOP_sva_1_3 <= exit_COMPUTE_LOOP_sva_1_2;
      CALC_SOFTMAX_LOOP_asn_2_itm_3 <= CALC_SOFTMAX_LOOP_asn_itm_2;
      CALC_SOFTMAX_LOOP_asn_14_itm_3 <= CALC_SOFTMAX_LOOP_asn_14_itm_2;
      CALC_SOFTMAX_LOOP_asn_14_itm_5 <= CALC_SOFTMAX_LOOP_asn_14_itm_4;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_10_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_10 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_9;
      CALC_SOFTMAX_LOOP_asn_itm_2 <= CALC_SOFTMAX_LOOP_asn_itm_1;
      CALC_SOFTMAX_LOOP_and_13_itm_5 <= CALC_SOFTMAX_LOOP_and_13_itm_4;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_2
          <= ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1;
      CALC_SOFTMAX_LOOP_asn_14_itm_2 <= CALC_SOFTMAX_LOOP_asn_14_itm_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_9_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_9 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_8;
      CALC_SOFTMAX_LOOP_asn_itm_1 <= exitL_exit_CALC_SOFTMAX_LOOP_sva;
      CALC_SOFTMAX_LOOP_and_13_itm_4 <= CALC_SOFTMAX_LOOP_and_13_itm_3;
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_nor_itm_1
          <= ~((ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_2!=74'b00000000000000000000000000000000000000000000000000000000000000000000000000));
      exit_COMPUTE_LOOP_sva_1_2 <= exit_COMPUTE_LOOP_sva_1_1;
      CALC_SOFTMAX_LOOP_asn_14_itm_1 <= ((COMPUTE_LOOP_acc_1_tmp[4]) & (z_out_1[7])
          & CALC_SOFTMAX_LOOP_equal_tmp_2) | exit_COMPUTE_LOOP_lpi_2_dfm_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_8_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_8 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_7;
      CALC_SOFTMAX_LOOP_and_13_itm_3 <= CALC_SOFTMAX_LOOP_and_13_itm_2;
      exit_COMPUTE_LOOP_sva_1_1 <= ~ COMPUTE_LOOP_acc_2_itm_32_1;
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_nl,
          ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_4_nl,
          fsm_output[4]);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_1 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_1;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_7_0 <= lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_1_st_6_0;
      exit_COMPUTE_LOOP_lpi_2_dfm_st_7 <= exit_COMPUTE_LOOP_lpi_2_dfm_st_6;
      CALC_SOFTMAX_LOOP_and_13_itm_2 <= CALC_SOFTMAX_LOOP_and_13_itm_1;
      CALC_SOFTMAX_LOOP_and_13_itm_1 <= CALC_EXP_LOOP_and_svs_1 & (~(CALC_SOFTMAX_LOOP_equal_tmp_2
          | CALC_SOFTMAX_LOOP_equal_tmp_3)) & (~ exit_COMPUTE_LOOP_lpi_2_dfm_1);
      STORE_INNER_LOOP_asn_itm <= LOAD_INNER_LOOP_mux1h_nl | (~ (fsm_output[4]));
      exitL_exit_STORE_INNER_LOOP_sva <= LOAD_INNER_LOOP_mux_10_nl | (~ (fsm_output[4]));
    end
  end
  always @(posedge clk) begin
    if ( LOAD_OUTER_LOOP_and_cse ) begin
      dma_read_ctrl_rsci_ivld_core_psct <= ~ or_tmp_116;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_ctrl_rsci_iswt0 <= 1'b0;
    end
    else if ( LOAD_OUTER_LOOP_and_cse ) begin
      dma_read_ctrl_rsci_iswt0 <= ~ or_tmp_116;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (fsm_output[2]) & (~ and_dcpl_122) & (~ and_dcpl_118) & COMPUTE_LOOP_acc_2_itm_32_1
        & LOAD_INNER_LOOP_asn_itm & LOAD_OUTER_LOOP_stage_0_1 & CALC_EXP_LOOP_and_svs_st_3
        ) begin
      dma_read_ctrl_rsci_idat_10_7 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2[3:0];
    end
  end
  always @(posedge clk) begin
    if ( LOAD_INNER_LOOP_data_ac_and_cse ) begin
      dma_read_chnl_rsci_irdy_core_psct <= LOAD_INNER_LOOP_data_ac_LOAD_INNER_LOOP_data_ac_or_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_read_chnl_rsci_iswt0 <= 1'b0;
    end
    else if ( LOAD_INNER_LOOP_data_ac_and_cse ) begin
      dma_read_chnl_rsci_iswt0 <= LOAD_INNER_LOOP_data_ac_LOAD_INNER_LOOP_data_ac_or_cse;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_0 <= 1'b0;
    end
    else if ( core_wen & (~ or_tmp_133) ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_0 <= MUX_s_1_2_2(lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_0_1, fsm_output[3]);
    end
  end
  always @(posedge clk) begin
    if ( STORE_OUTER_LOOP_and_cse ) begin
      dma_write_ctrl_rsci_ivld_core_psct <= ~ or_tmp_142;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_ctrl_rsci_iswt0 <= 1'b0;
    end
    else if ( STORE_OUTER_LOOP_and_cse ) begin
      dma_write_ctrl_rsci_iswt0 <= ~ or_tmp_142;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (~((~ (fsm_output[4])) | and_dcpl_167 | or_dcpl_87)) ) begin
      dma_write_ctrl_rsci_idat_10_7 <= CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2[3:0];
    end
  end
  always @(posedge clk) begin
    if ( STORE_INNER_LOOP_and_cse ) begin
      dma_write_chnl_rsci_ivld_core_psct <= ~ or_tmp_149;
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      dma_write_chnl_rsci_iswt0 <= 1'b0;
    end
    else if ( STORE_INNER_LOOP_and_cse ) begin
      dma_write_chnl_rsci_iswt0 <= ~ or_tmp_149;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (~((~ (fsm_output[4])) | and_dcpl_167 | or_dcpl_91)) ) begin
      dma_write_chnl_rsci_idat_31_0 <= plm_out_data_rsci_q_d_mxwt;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (~(or_tmp_133 | (or_186_tmp & (fsm_output[3])))) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2
          <= MUX_v_74_2_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_4_nl);
    end
  end
  always @(posedge clk) begin
    if ( ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_and_cse ) begin
      ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm <= nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm[7:0];
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_slc_ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_normalized_fixed_72_60_9_0_itm
          <= operator_74_0_false_AC_TRN_AC_WRAP_lshift_itm[69:60];
    end
  end
  always @(posedge clk) begin
    if ( ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_cse
        ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_1_itm
          <= MUX1HOT_v_10_8_2(10'b1111111101, 10'b1100011001, 10'b1001100100, 10'b0111010000,
          10'b0101010100, 10'b0011101011, 10'b0010010001, 10'b0001000100, {ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_8_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_9_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_10_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_11_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_12_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_13_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_14_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_15_cse});
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_mux_itm
          <= MUX1HOT_v_8_8_2(8'b00011100, 8'b01001011, 8'b01101100, 8'b10000100,
          8'b10010111, 8'b10100110, 8'b10110011, 8'b10111100, {ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_8_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_9_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_10_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_11_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_12_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_13_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_14_cse
          , ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_pwl_and_15_cse});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_1 <= 1'b0;
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_0 <= 1'b0;
    end
    else if ( CALC_SOFTMAX_LOOP_and_21_cse ) begin
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_1 <= MUX_s_1_2_2(COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_4_mx0w0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_1_1, and_dcpl_207);
      lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_6_0 <= MUX_s_1_2_2(COMPUTE_LOOP_if_COMPUTE_LOOP_if_and_3_mx0w0,
          lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_dfm_5_0_1, and_dcpl_207);
    end
  end
  always @(posedge clk) begin
    if ( core_wen & ((COMPUTE_LOOP_stage_0_7 & CALC_SOFTMAX_LOOP_and_13_itm_6 & (fsm_output[3]))
        | and_279_rgt) ) begin
      ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_3
          <= MUX_v_94_2_2(ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2_dfm_4,
          ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_lpi_2,
          and_279_rgt);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st_1 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[0]) | CALC_EXP_LOOP_and_svs_st_1_mx0c1 | or_tmp_203
        | (fsm_output[4:3]!=2'b00)) ) begin
      CALC_EXP_LOOP_and_svs_st_1 <= (conf_done_mux1h_nl & (~ or_tmp_203)) | CALC_EXP_LOOP_and_svs_st_1_mx0c1;
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (and_285_rgt | ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_3_rgt
        | CALC_SOFTMAX_LOOP_and_19_rgt) ) begin
      ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_1_1
          <= MUX1HOT_v_74_3_2(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2_dfm_4,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_sva_1_1,
          ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_lpi_2,
          {and_285_rgt , ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_3_rgt
          , CALC_SOFTMAX_LOOP_and_19_rgt});
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_INNER_LOOP_asn_itm <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_209 | LOAD_INNER_LOOP_asn_itm_mx0c2)
        ) begin
      LOAD_INNER_LOOP_asn_itm <= LOAD_INNER_LOOP_mux_12_nl | (fsm_output[1]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      exitL_exit_LOAD_INNER_LOOP_sva <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_209) ) begin
      exitL_exit_LOAD_INNER_LOOP_sva <= exitL_exit_LOAD_INNER_LOOP_sva_mx0w1 | (~
          or_tmp_209);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      LOAD_OUTER_LOOP_stage_0_1 <= 1'b0;
    end
    else if ( core_wen & ((fsm_output[1]) | or_tmp_203 | LOAD_OUTER_LOOP_stage_0_1_mx0c2)
        ) begin
      LOAD_OUTER_LOOP_stage_0_1 <= ~((~(CALC_EXP_LOOP_and_svs_st_1 | (~ LOAD_OUTER_LOOP_stage_0_1_mx0c2)))
          | or_tmp_203);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st_3 <= 1'b0;
    end
    else if ( core_wen & (~((fsm_output[0]) | (fsm_output[5]) | ((~ mux_121_nl) &
        (fsm_output[2])))) ) begin
      CALC_EXP_LOOP_and_svs_st_3 <= (LOAD_INNER_LOOP_mux_11_nl | (fsm_output[1])
          | ((~((~(and_dcpl_223 & LOAD_OUTER_LOOP_stage_0_1)) & CALC_EXP_LOOP_and_svs_st_3))
          & CALC_EXP_LOOP_and_svs_st_1 & (fsm_output[2]))) & (~(mux_120_nl & or_dcpl_59
          & and_dcpl_132 & (fsm_output[2])));
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_EXP_LOOP_and_svs_st_6 <= 1'b0;
    end
    else if ( core_wen & (CALC_EXP_LOOP_and_svs_st_6_mx0c0 | (fsm_output[4:3]!=2'b00))
        ) begin
      CALC_EXP_LOOP_and_svs_st_6 <= MUX1HOT_s_1_3_2((~ COMPUTE_LOOP_acc_2_itm_32_1),
          CALC_EXP_LOOP_CALC_EXP_LOOP_and_1_nl, ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_3_nl,
          {CALC_EXP_LOOP_and_svs_st_6_mx0c0 , (fsm_output[3]) , (fsm_output[4])});
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (or_tmp_209 | (fsm_output[4:3]!=2'b00)) ) begin
      CALC_EXP_LOOP_i_7_0_lpi_2_6_0 <= MUX1HOT_v_7_4_2((z_out_1[6:0]), (CALC_EXP_LOOP_acc_1_tmp[6:0]),
          (signext_7_1(~ CALC_EXP_LOOP_and_svs_1)), CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
          {LOAD_INNER_LOOP_i_or_nl , LOAD_INNER_LOOP_i_and_2_nl , CALC_SOFTMAX_LOOP_and_16_nl
          , LOAD_INNER_LOOP_i_and_3_nl});
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c0 |
        CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1 | (fsm_output[3]))
        ) begin
      CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1 <= MUX1HOT_v_7_3_2((signext_7_1(~
          COMPUTE_LOOP_acc_2_itm_32_1)), CALC_EXP_LOOP_i_7_0_lpi_2_6_0, (signext_7_1(~
          COMPUTE_LOOP_acc_2_itm_32_1)), {CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c0
          , LOAD_INNER_LOOP_or_3_nl , LOAD_INNER_LOOP_and_4_nl});
    end
  end
  always @(posedge clk) begin
    if ( core_wen & (COMPUTE_LOOP_b_4_0_sva_3_0_mx0c0 | (and_dcpl_218 & (z_out_1[7])
        & LOAD_OUTER_LOOP_stage_0_1 & CALC_EXP_LOOP_and_svs_st_3 & (fsm_output[2]))
        | (fsm_output[4:3]!=2'b00)) ) begin
      COMPUTE_LOOP_b_4_0_sva_3_0 <= MUX_v_4_2_2(4'b0000, mux_nl, nor_74_nl);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4 <= 1'b0;
    end
    else if ( core_wen & ((or_dcpl_20 & STORE_INNER_LOOP_asn_itm) | and_342_rgt |
        (~ (fsm_output[4]))) ) begin
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_3,
          LOAD_OUTER_LOOP_LOAD_OUTER_LOOP_mux_nl, fsm_output[4]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_3 <= 1'b0;
    end
    else if ( core_wen & (~((~(STORE_INNER_LOOP_asn_itm & CALC_EXP_LOOP_and_svs_st_5))
        & (fsm_output[4]))) ) begin
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_3 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2,
          (~ COMPUTE_LOOP_acc_2_itm_32_1), fsm_output[4]);
    end
  end
  always @(posedge clk) begin
    if ( ~ rst ) begin
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2 <= 1'b0;
    end
    else if ( core_wen & (~(and_dcpl_167 & (fsm_output[4]))) ) begin
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_2 <= MUX_s_1_2_2(CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1,
          STORE_INNER_LOOP_STORE_INNER_LOOP_and_nl, fsm_output[4]);
    end
  end
  assign nor_43_nl = ~((fsm_output[0]) | (fsm_output[5]));
  assign or_313_nl = (~ (fsm_output[2])) | and_dcpl_122 | and_dcpl_118 | or_dcpl_54;
  assign and_354_nl = and_dcpl_127 & LOAD_INNER_LOOP_asn_itm & LOAD_OUTER_LOOP_stage_0_1
      & CALC_EXP_LOOP_and_svs_st_3 & (fsm_output[2]);
  assign and_356_nl = and_dcpl_127 & (~ LOAD_INNER_LOOP_asn_itm) & LOAD_OUTER_LOOP_stage_0_1
      & CALC_EXP_LOOP_and_svs_st_3 & (fsm_output[2]);
  assign LOAD_INNER_LOOP_LOAD_INNER_LOOP_and_nl = (~ COMPUTE_LOOP_acc_2_itm_32_1)
      & exitL_exit_LOAD_INNER_LOOP_sva;
  assign and_362_nl = and_dcpl_137 & (fsm_output[2]);
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_or_nl
      = or_tmp_133 | ((~ ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_tmp)
      & (fsm_output[3]));
  assign ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_4_nl
      = ac_math_ac_reciprocal_pwl_AC_TRN_74_54_false_AC_TRN_AC_WRAP_94_21_false_AC_TRN_AC_WRAP_output_temp_and_2_tmp
      & (fsm_output[3]);
  assign dma_write_data_index_and_3_nl = (~ or_dcpl_183) & (fsm_output[4]);
  assign dma_write_data_index_mux_nl = MUX_v_4_2_2(dma_write_data_index_10_7_sva,
      z_out, dma_write_data_index_and_3_nl);
  assign not_494_nl = ~ (fsm_output[1]);
  assign CALC_EXP_LOOP_CALC_EXP_LOOP_or_nl = CALC_EXP_LOOP_and_svs_st_1 | COMPUTE_LOOP_nor_tmp;
  assign operator_74_54_false_AC_TRN_AC_WRAP_1_operator_74_54_false_AC_TRN_AC_WRAP_1_and_nl
      = CALC_EXP_LOOP_and_svs_st_2 & ((~ mux_133_itm) | or_dcpl_95);
  assign CALC_EXP_LOOP_and_8_nl = (~ or_284_tmp) & (fsm_output[2]);
  assign CALC_EXP_LOOP_and_9_nl = or_284_tmp & (fsm_output[2]);
  assign CALC_EXP_LOOP_mux1h_6_nl = MUX1HOT_s_1_4_2(LOAD_OUTER_LOOP_stage_0_1, CALC_EXP_LOOP_and_svs_st_2,
      CALC_EXP_LOOP_CALC_EXP_LOOP_or_nl, operator_74_54_false_AC_TRN_AC_WRAP_1_operator_74_54_false_AC_TRN_AC_WRAP_1_and_nl,
      {CALC_EXP_LOOP_and_8_nl , CALC_EXP_LOOP_and_9_nl , (fsm_output[3]) , (fsm_output[4])});
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_nl
      = (CALC_EXP_LOOP_and_svs_st_4 & (~(and_dcpl_136 & and_dcpl_134 & or_dcpl_54)))
      | and_dcpl_133;
  assign CALC_EXP_LOOP_CALC_EXP_LOOP_and_nl = CALC_EXP_LOOP_and_svs_st_3 & (~ COMPUTE_LOOP_nor_tmp);
  assign CALC_EXP_LOOP_and_5_nl = (~ mux_122_tmp) & (fsm_output[4]);
  assign CALC_EXP_LOOP_and_6_nl = mux_122_tmp & (fsm_output[4]);
  assign CALC_EXP_LOOP_mux1h_12_nl = MUX1HOT_s_1_4_2(ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_nl,
      CALC_EXP_LOOP_CALC_EXP_LOOP_and_nl, CALC_EXP_LOOP_and_svs_st_4, CALC_EXP_LOOP_and_svs_st_3,
      {(fsm_output[2]) , (fsm_output[3]) , CALC_EXP_LOOP_and_5_nl , CALC_EXP_LOOP_and_6_nl});
  assign CALC_EXP_LOOP_nor_3_nl = ~((CALC_EXP_LOOP_and_svs_st_5 & (~((and_dcpl_121
      | (~ CALC_EXP_LOOP_and_svs_st_4) | or_dcpl_56) & or_dcpl_14))) | and_dcpl_137);
  assign CALC_EXP_LOOP_nor_4_nl = ~(CALC_EXP_LOOP_and_svs_st_4 | COMPUTE_LOOP_nor_tmp);
  assign mux_126_nl = MUX_s_1_2_2(or_dcpl_20, mux_133_itm, CALC_EXP_LOOP_and_svs_st_2);
  assign CALC_EXP_LOOP_nor_5_nl = ~((CALC_EXP_LOOP_and_svs_st_5 & (~(mux_126_nl &
      or_tmp_1 & and_dcpl_3))) | ((~((~(and_dcpl_200 & nand_64_cse & CALC_EXP_LOOP_and_svs_st_3))
      & CALC_EXP_LOOP_and_svs_st_5)) & CALC_EXP_LOOP_and_svs_st_2));
  assign CALC_EXP_LOOP_mux1h_16_nl = MUX1HOT_s_1_3_2(CALC_EXP_LOOP_nor_3_nl, CALC_EXP_LOOP_nor_4_nl,
      CALC_EXP_LOOP_nor_5_nl, {(fsm_output[2]) , (fsm_output[3]) , (fsm_output[4])});
  assign and_660_nl = and_dcpl_218 & (z_out_1[7]) & CALC_EXP_LOOP_and_svs_st_3 &
      (fsm_output[2]);
  assign or_462_nl = ((((and_dcpl_121 | and_dcpl_119) & CALC_EXP_LOOP_and_svs_st_4)
      | and_dcpl_118 | (~ (z_out_1[7])) | (~ CALC_EXP_LOOP_and_svs_st_3)) & (fsm_output[2]))
      | (or_dcpl_89 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 & CALC_EXP_LOOP_and_svs_st_4
      & (fsm_output[4]));
  assign and_665_nl = or_dcpl_20 & (fsm_output[4]);
  assign dma_read_data_index_mux1h_nl = MUX1HOT_v_4_3_2(z_out, (CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2[3:0]),
      dma_write_data_index_10_7_sva, {and_660_nl , or_462_nl , and_665_nl});
  assign STORE_OUTER_LOOP_not_4_nl = ~ (fsm_output[1]);
  assign dma_read_data_index_and_nl = MUX_v_4_2_2(4'b0000, dma_read_data_index_mux1h_nl,
      STORE_OUTER_LOOP_not_4_nl);
  assign or_309_nl = (~ (z_out_1[7])) | (~ (COMPUTE_LOOP_acc_1_tmp[4])) | lfst_exit_CALC_SOFTMAX_LOOP_lpi_2_0;
  assign mux_129_nl = MUX_s_1_2_2(mux_tmp_48, or_dcpl_32, or_309_nl);
  assign CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_nl = ~(CALC_SOFTMAX_LOOP_equal_tmp_2
      | CALC_SOFTMAX_LOOP_equal_tmp_3 | exit_COMPUTE_LOOP_lpi_2_dfm_1 | COMPUTE_LOOP_nor_tmp);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_4_nl
      = (CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1 & (~(and_dcpl_6 & or_dcpl_86)))
      | and_dcpl_174;
  assign and_346_nl = or_dcpl_20 & CALC_EXP_LOOP_and_svs_st_5;
  assign and_348_nl = or_dcpl_89 & CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_1
      & CALC_EXP_LOOP_and_svs_st_5;
  assign LOAD_INNER_LOOP_mux1h_nl = MUX1HOT_s_1_3_2(exitL_exit_LOAD_INNER_LOOP_sva_mx0w1,
      exitL_exit_STORE_INNER_LOOP_sva, STORE_INNER_LOOP_asn_itm, {and_346_nl , (~
      CALC_EXP_LOOP_and_svs_st_5) , and_348_nl});
  assign LOAD_INNER_LOOP_mux_10_nl = MUX_s_1_2_2(exitL_exit_LOAD_INNER_LOOP_sva_mx0w1,
      exitL_exit_STORE_INNER_LOOP_sva, or_dcpl_197);
  assign ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_sum_exp_and_4_nl
      = CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_4 & (~ or_186_tmp) & (fsm_output[3]);
  assign nl_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_expret_qif_acc_itm  =
      ({1'b1 , (~ libraries_leading_sign_74_0_d122f99e9ffc18d7edc913ace0494619bed7_1)})
      + 8'b00110111;
  assign conf_done_and_1_nl = (~ and_dcpl_167) & (fsm_output[4]);
  assign conf_done_and_2_nl = and_dcpl_167 & (fsm_output[4]);
  assign conf_done_mux1h_nl = MUX1HOT_s_1_4_2(conf_done_rsci_idat, CALC_EXP_LOOP_and_svs_1,
      STORE_INNER_LOOP_asn_itm, CALC_EXP_LOOP_and_svs_st_1, {(fsm_output[0]) , (fsm_output[3])
      , conf_done_and_1_nl , conf_done_and_2_nl});
  assign LOAD_INNER_LOOP_mux_12_nl = MUX_s_1_2_2(exitL_exit_LOAD_INNER_LOOP_sva_mx0w1,
      exitL_exit_LOAD_INNER_LOOP_sva, LOAD_INNER_LOOP_asn_itm_mx0c2);
  assign CALC_EXP_LOOP_CALC_EXP_LOOP_or_1_nl = CALC_EXP_LOOP_and_svs_st_2 | COMPUTE_LOOP_nor_tmp;
  assign or_295_nl = and_dcpl_167 | or_dcpl_95;
  assign operator_74_54_false_AC_TRN_AC_WRAP_1_mux_nl = MUX_s_1_2_2(CALC_EXP_LOOP_and_svs_st_2,
      CALC_EXP_LOOP_and_svs_st_3, or_295_nl);
  assign operator_74_54_false_AC_TRN_AC_WRAP_1_operator_74_54_false_AC_TRN_AC_WRAP_1_and_1_nl
      = operator_74_54_false_AC_TRN_AC_WRAP_1_mux_nl & (~(mux_133_itm & or_tmp_1
      & and_dcpl_3));
  assign LOAD_INNER_LOOP_mux_11_nl = MUX_s_1_2_2(CALC_EXP_LOOP_CALC_EXP_LOOP_or_1_nl,
      operator_74_54_false_AC_TRN_AC_WRAP_1_operator_74_54_false_AC_TRN_AC_WRAP_1_and_1_nl,
      fsm_output[4]);
  assign nand_57_nl = ~((~(COMPUTE_LOOP_acc_2_itm_32_1 & CALC_EXP_LOOP_and_svs_st_1))
      & mux_107_cse);
  assign mux_118_nl = MUX_s_1_2_2(or_tmp_104, nand_57_nl, LOAD_INNER_LOOP_asn_itm);
  assign mux_119_nl = MUX_s_1_2_2(or_tmp_104, mux_118_nl, exitL_exit_LOAD_INNER_LOOP_sva);
  assign mux_120_nl = MUX_s_1_2_2((~ mux_119_nl), mux_107_cse, and_731_cse_1);
  assign nand_20_nl = ~(CALC_EXP_LOOP_and_svs_st_3 & (~(LOAD_OUTER_LOOP_stage_0_1
      & and_dcpl_127)));
  assign mux_121_nl = MUX_s_1_2_2(and_dcpl_133, nand_20_nl, CALC_EXP_LOOP_and_svs_st_1);
  assign CALC_EXP_LOOP_CALC_EXP_LOOP_and_1_nl = CALC_EXP_LOOP_and_svs_st_5 & (~ COMPUTE_LOOP_nor_tmp);
  assign ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_ac_math_ac_normalize_74_54_false_AC_TRN_AC_WRAP_leading_1_or_3_nl
      = (CALC_EXP_LOOP_and_svs_st_6 & (~(or_dcpl_20 & nor_tmp & or_dcpl_94))) | (and_dcpl_181
      & and_dcpl_3);
  assign LOAD_INNER_LOOP_i_or_nl = or_tmp_209 | (CALC_SOFTMAX_LOOP_and_10_tmp & (fsm_output[3]))
      | ((~ or_dcpl_197) & (fsm_output[4]));
  assign LOAD_INNER_LOOP_i_and_2_nl = (~ or_303_tmp) & (fsm_output[3]);
  assign CALC_SOFTMAX_LOOP_and_16_nl = (~ CALC_SOFTMAX_LOOP_and_10_tmp) & or_303_tmp
      & (fsm_output[3]);
  assign LOAD_INNER_LOOP_i_and_3_nl = or_dcpl_197 & (fsm_output[4]);
  assign LOAD_INNER_LOOP_or_3_nl = CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_1_mx0c1
      | ((~ exitL_exit_CALC_SOFTMAX_LOOP_sva) & (fsm_output[3]));
  assign LOAD_INNER_LOOP_and_4_nl = exitL_exit_CALC_SOFTMAX_LOOP_sva & (fsm_output[3]);
  assign or_497_nl = ((~ COMPUTE_LOOP_nor_tmp) & ((~ (z_out_1[7])) | or_69_cse) &
      (fsm_output[3])) | (or_dcpl_183 & (fsm_output[4]));
  assign mux_nl = MUX_v_4_2_2((COMPUTE_LOOP_acc_1_tmp[3:0]), COMPUTE_LOOP_b_4_0_sva_3_0,
      or_497_nl);
  assign nor_74_nl = ~((COMPUTE_LOOP_nor_tmp & (fsm_output[3])) | COMPUTE_LOOP_b_4_0_sva_3_0_mx0c0);
  assign LOAD_OUTER_LOOP_LOAD_OUTER_LOOP_mux_nl = MUX_s_1_2_2((~ COMPUTE_LOOP_acc_2_itm_32_1),
      CALC_SOFTMAX_LOOP_CALC_SOFTMAX_LOOP_nor_2_itm_3, and_342_rgt);
  assign STORE_INNER_LOOP_STORE_INNER_LOOP_and_nl = (~ COMPUTE_LOOP_acc_2_itm_32_1)
      & exitL_exit_STORE_INNER_LOOP_sva;
  assign STORE_OUTER_LOOP_mux_6_nl = MUX_v_4_2_2(dma_write_data_index_10_7_sva, (CALC_EXP_LOOP_i_slc_CALC_EXP_LOOP_i_7_0_6_0_1_itm_2[3:0]),
      fsm_output[2]);
  assign nl_z_out = STORE_OUTER_LOOP_mux_6_nl + 4'b0001;
  assign z_out = nl_z_out[3:0];
  assign LOAD_INNER_LOOP_or_5_nl = ((~ exitL_exit_LOAD_INNER_LOOP_sva) & (fsm_output[2]))
      | (fsm_output[3]) | ((~ exitL_exit_STORE_INNER_LOOP_sva) & (fsm_output[4]));
  assign LOAD_INNER_LOOP_and_11_nl = exitL_exit_LOAD_INNER_LOOP_sva & (fsm_output[2]);
  assign LOAD_INNER_LOOP_and_12_nl = exitL_exit_STORE_INNER_LOOP_sva & (fsm_output[4]);
  assign LOAD_INNER_LOOP_mux1h_11_nl = MUX1HOT_v_7_3_2(CALC_EXP_LOOP_i_7_0_lpi_2_6_0,
      (signext_7_1(~ COMPUTE_LOOP_acc_2_itm_32_1)), (signext_7_1(~ COMPUTE_LOOP_acc_2_itm_32_1)),
      {LOAD_INNER_LOOP_or_5_nl , LOAD_INNER_LOOP_and_11_nl , LOAD_INNER_LOOP_and_12_nl});
  assign nl_z_out_1 = conv_u2u_7_8(LOAD_INNER_LOOP_mux1h_11_nl) + 8'b00000001;
  assign z_out_1 = nl_z_out_1[7:0];

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


  function automatic [0:0] MUX1HOT_s_1_4_2;
    input [0:0] input_3;
    input [0:0] input_2;
    input [0:0] input_1;
    input [0:0] input_0;
    input [3:0] sel;
    reg [0:0] result;
  begin
    result = input_0 & {1{sel[0]}};
    result = result | ( input_1 & {1{sel[1]}});
    result = result | ( input_2 & {1{sel[2]}});
    result = result | ( input_3 & {1{sel[3]}});
    MUX1HOT_s_1_4_2 = result;
  end
  endfunction


  function automatic [9:0] MUX1HOT_v_10_8_2;
    input [9:0] input_7;
    input [9:0] input_6;
    input [9:0] input_5;
    input [9:0] input_4;
    input [9:0] input_3;
    input [9:0] input_2;
    input [9:0] input_1;
    input [9:0] input_0;
    input [7:0] sel;
    reg [9:0] result;
  begin
    result = input_0 & {10{sel[0]}};
    result = result | ( input_1 & {10{sel[1]}});
    result = result | ( input_2 & {10{sel[2]}});
    result = result | ( input_3 & {10{sel[3]}});
    result = result | ( input_4 & {10{sel[4]}});
    result = result | ( input_5 & {10{sel[5]}});
    result = result | ( input_6 & {10{sel[6]}});
    result = result | ( input_7 & {10{sel[7]}});
    MUX1HOT_v_10_8_2 = result;
  end
  endfunction


  function automatic [3:0] MUX1HOT_v_4_3_2;
    input [3:0] input_2;
    input [3:0] input_1;
    input [3:0] input_0;
    input [2:0] sel;
    reg [3:0] result;
  begin
    result = input_0 & {4{sel[0]}};
    result = result | ( input_1 & {4{sel[1]}});
    result = result | ( input_2 & {4{sel[2]}});
    MUX1HOT_v_4_3_2 = result;
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


  function automatic [7:0] MUX1HOT_v_8_8_2;
    input [7:0] input_7;
    input [7:0] input_6;
    input [7:0] input_5;
    input [7:0] input_4;
    input [7:0] input_3;
    input [7:0] input_2;
    input [7:0] input_1;
    input [7:0] input_0;
    input [7:0] sel;
    reg [7:0] result;
  begin
    result = input_0 & {8{sel[0]}};
    result = result | ( input_1 & {8{sel[1]}});
    result = result | ( input_2 & {8{sel[2]}});
    result = result | ( input_3 & {8{sel[3]}});
    result = result | ( input_4 & {8{sel[4]}});
    result = result | ( input_5 & {8{sel[5]}});
    result = result | ( input_6 & {8{sel[6]}});
    result = result | ( input_7 & {8{sel[7]}});
    MUX1HOT_v_8_8_2 = result;
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
  wire [31:0] plm_in_data_rsci_d_d;
  wire [31:0] plm_in_data_rsci_q_d;
  wire [6:0] plm_in_data_rsci_radr_d;
  wire [6:0] plm_in_data_rsci_wadr_d;
  wire plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire [31:0] plm_out_data_rsci_d_d;
  wire [31:0] plm_out_data_rsci_q_d;
  wire [6:0] plm_out_data_rsci_radr_d;
  wire [6:0] plm_out_data_rsci_wadr_d;
  wire plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d;
  wire [66:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d;
  wire plm_in_data_rsc_clken;
  wire [31:0] plm_in_data_rsc_q;
  wire [6:0] plm_in_data_rsc_radr;
  wire plm_in_data_rsc_we;
  wire [31:0] plm_in_data_rsc_d;
  wire [6:0] plm_in_data_rsc_wadr;
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
  wire plm_in_data_rsci_we_d_iff;
  wire plm_out_data_rsci_we_d_iff;
  wire [6:0] ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff;
  wire ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_we_d_iff;


  // Interconnect Declarations for Component Instantiations 
  BLOCK_1R1W_RBW #(.addr_width(32'sd7),
  .data_width(32'sd32),
  .depth(32'sd128),
  .latency(32'sd1)) plm_in_data_rsc_comp (
      .clk(clk),
      .clken(plm_in_data_rsc_clken),
      .d(plm_in_data_rsc_d),
      .q(plm_in_data_rsc_q),
      .radr(plm_in_data_rsc_radr),
      .wadr(plm_in_data_rsc_wadr),
      .we(plm_in_data_rsc_we)
    );
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
      plm_in_data_rsci (
      .clken(plm_in_data_rsc_clken),
      .q(plm_in_data_rsc_q),
      .radr(plm_in_data_rsc_radr),
      .we(plm_in_data_rsc_we),
      .d(plm_in_data_rsc_d),
      .wadr(plm_in_data_rsc_wadr),
      .clken_d(1'b1),
      .d_d(plm_in_data_rsci_d_d),
      .q_d(plm_in_data_rsci_q_d),
      .radr_d(plm_in_data_rsci_radr_d),
      .wadr_d(plm_in_data_rsci_wadr_d),
      .we_d(plm_in_data_rsci_we_d_iff),
      .writeA_w_ram_ir_internal_WMASK_B_d(plm_in_data_rsci_we_d_iff),
      .readA_r_ram_ir_internal_RMASK_B_d(plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d)
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
      .clken_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .radr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff),
      .wadr_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff),
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
      .plm_in_data_rsci_d_d(plm_in_data_rsci_d_d),
      .plm_in_data_rsci_q_d(plm_in_data_rsci_q_d),
      .plm_in_data_rsci_radr_d(plm_in_data_rsci_radr_d),
      .plm_in_data_rsci_wadr_d(plm_in_data_rsci_wadr_d),
      .plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_in_data_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .plm_out_data_rsci_d_d(plm_out_data_rsci_d_d),
      .plm_out_data_rsci_q_d(plm_out_data_rsci_q_d),
      .plm_out_data_rsci_radr_d(plm_out_data_rsci_radr_d),
      .plm_out_data_rsci_wadr_d(plm_out_data_rsci_wadr_d),
      .plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d(plm_out_data_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_clken_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_d_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_q_d),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_readA_r_ram_ir_internal_RMASK_B_d),
      .plm_in_data_rsci_we_d_pff(plm_in_data_rsci_we_d_iff),
      .plm_out_data_rsci_we_d_pff(plm_out_data_rsci_we_d_iff),
      .ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_pff(ac_math_ac_softmax_pwl_AC_TRN_false_0_0_AC_TRN_AC_WRAP_false_0_0_AC_TRN_AC_WRAP_128U_32_6_true_AC_TRN_AC_WRAP_32_2_AC_TRN_AC_WRAP_exp_arr_rsci_radr_d_iff),
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



