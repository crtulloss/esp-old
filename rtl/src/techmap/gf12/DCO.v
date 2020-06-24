`default_nettype none
// Tianyu Jia, 6/12/2020
// Behavior model of DCO
// Need to be replaced for real physical design
`timescale 1ns/1ps

module GF12_BUF(Y, A);
output Y;
wire Y;
input A;
wire A;
//CLK_BUF_CELL buf1(.Z(Y), .I(A));
assign Y=A;
endmodule

module GF12_MUX(Y, SEL, A, B);
output Y;
wire Y;
input A, B, SEL;
wire A, B, SEL;
//CLK_MUX_CEL mux2(.Z(Y), .S(SEL), .I0(A), .I1(B));
assign Y = (SEL) ? B : A;
endmodule

//Behavior model, tjia
//Fine tune, EN_CAP, 2MHz
//Coarse tune, SEL, 50MHz 
module GF12_DCO_RING(EN, DCLK, SEL, EN_CAP);
input EN;
wire EN;
input [5:0] SEL;
wire [5:0] SEL;
output DCLK;
wire DCLK;
input [5:0] EN_CAP;
wire [5:0] EN_CAP;

// synthesis translate_off
// synopsys translate_off
//#######################Need to be commented out for Physical Design######
///*
//behavior clock generation
reg clk_resolution=0;
reg clk_tmp=0;
reg [15:0] clk_cnt=0;
integer total_cnt, half_cnt;

assign total_cnt = SEL<<5 + EN_CAP;
assign half_cnt = total_cnt >> 1;

initial begin
  forever begin
    #0.001 clk_resolution = ~clk_resolution;  //2ps
  end
end

always @ (posedge clk_resolution) begin
  if (clk_cnt<total_cnt) begin
    clk_cnt <= clk_cnt + 1;
    if (clk_cnt == half_cnt) clk_tmp = ~clk_tmp;
  end
  else begin
    clk_cnt <= 0;
    clk_tmp = ~clk_tmp;
  end
end

assign DCLK = (EN) ? clk_tmp : 0;
//*/
//##################################Comment out End############
// synopsys translate_on
// synthesis translate_on

endmodule



module GF12_CLK_DIVIDER(CLK_IN, CLK_OUT, FRSTN);
input CLK_IN;
wire CLK_IN;
output CLK_OUT;
wire CLK_OUT;
input FRSTN;
wire FRSTN;

reg div_tmp=0;
always @ (posedge CLK_IN) begin
  div_tmp = ~div_tmp;
end

assign CLK_OUT = (FRSTN) ? div_tmp : 0;
endmodule

module GF12_MX_CLK_DIVIDER(CLK_IN, CLK_OUT, SEL, FRSTN);
input CLK_IN;
wire CLK_IN;
output CLK_OUT;
wire CLK_OUT;
input [2:0] SEL;
wire [2:0] SEL;
input FRSTN;
wire FRSTN;
wire [0:7] X0;
wire CLK_DIV;
GF12_BUF buf0(.Y(X0[0]), .A(CLK_IN));
GF12_CLK_DIVIDER DIV0 (.CLK_IN(X0[0]), .CLK_OUT(X0[1]), .FRSTN(FRSTN));
GF12_CLK_DIVIDER DIV1 (.CLK_IN(X0[1]), .CLK_OUT(X0[2]), .FRSTN(FRSTN));
GF12_CLK_DIVIDER DIV2 (.CLK_IN(X0[2]), .CLK_OUT(X0[3]), .FRSTN(FRSTN));
GF12_CLK_DIVIDER DIV3 (.CLK_IN(X0[3]), .CLK_OUT(X0[4]), .FRSTN(FRSTN));
GF12_CLK_DIVIDER DIV4 (.CLK_IN(X0[4]), .CLK_OUT(X0[5]), .FRSTN(FRSTN));
GF12_CLK_DIVIDER DIV5 (.CLK_IN(X0[5]), .CLK_OUT(X0[6]), .FRSTN(FRSTN));
GF12_CLK_DIVIDER DIV6 (.CLK_IN(X0[6]), .CLK_OUT(X0[7]), .FRSTN(FRSTN));
wire [3:0] X1;
wire [1:0] X2;
GF12_MUX mux10(.A(X0[0]), .B(X0[1]), .SEL(SEL[0]), .Y(X1[0]));
GF12_MUX mux11(.A(X0[2]), .B(X0[3]), .SEL(SEL[0]), .Y(X1[1]));
GF12_MUX mux12(.A(X0[4]), .B(X0[5]), .SEL(SEL[0]), .Y(X1[2]));
GF12_MUX mux13(.A(X0[6]), .B(X0[7]), .SEL(SEL[0]), .Y(X1[3]));
GF12_MUX mux20(.A(X1[0]), .B(X1[1]), .SEL(SEL[1]), .Y(X2[0]));
GF12_MUX mux21(.A(X1[2]), .B(X1[3]), .SEL(SEL[1]), .Y(X2[1]));
GF12_MUX mux30(.A(X2[0]), .B(X2[1]), .SEL(SEL[2]), .Y(CLK_DIV));
GF12_BUF bufmx(.Y(CLK_OUT), .A(CLK_DIV));
endmodule

//CHP_SEL, CHP_EN, CHP_NP_SEL, IN_CLK, CLK_SEL, 
module GF12_DCO(CLK_RSTN, DCO_SEL, DIV_SEL, DCLK, DIV_CLK, EN_CAP);
input CLK_RSTN;
wire CLK_RSTN;
input [5:0] DCO_SEL;
wire [5:0] DCO_SEL;
input [2:0] DIV_SEL;
wire [2:0] DIV_SEL;
output DCLK;
wire DCLK;
output DIV_CLK;
wire DIV_CLK;
// TODO only using 6:1, keeping it as 6:0 for compatibility (LSB floating)
input [6:0] EN_CAP;
wire [6:0] EN_CAP;


// DCO
wire RING_CLK;
GF12_DCO_RING DCO_CORE(.EN(CLK_RSTN), .SEL(DCO_SEL), .DCLK(RING_CLK), .EN_CAP(EN_CAP[6:1]));
GF12_BUF bufdclk(.Y(DCLK), .A(RING_CLK));

// Clock Divider
wire DIV_CLK_OUT;
GF12_MX_CLK_DIVIDER DIVIDER(.CLK_IN(RING_CLK), .CLK_OUT(DIV_CLK_OUT), .SEL(DIV_SEL), .FRSTN(CLK_RSTN));

GF12_BUF bufdivclk(.Y(DIV_CLK), .A(DIV_CLK_OUT));

endmodule

`default_nettype wire
