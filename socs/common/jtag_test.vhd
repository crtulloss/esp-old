library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.test_int_package.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.ariane_esp_pkg.all;
use work.misc.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.cachepackage.all;
use work.memoryctrl.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;



entity jtag_test is
  port (
    rst                :        in  std_ulogic;
    refclk             :        in  std_ulogic;

    tdi                :        in  std_logic;
    tdo                :        out std_logic;
    tms                :        in  std_logic;
    tclk               :        in  std_logic;
    next_in            :        out std_logic;


    noc2_output_port:           in noc_flit_type;
    noc2_cpu_data_void_out:     in std_ulogic;
    noc3_output_port:           in noc_flit_type;
    noc3_cpu_data_void_out:     in std_ulogic;
    noc5_output_port:           in misc_noc_flit_type;
    noc5_cpu_data_void_out:     in std_ulogic;
    noc6_output_port:           in noc_flit_type;
    noc6_cpu_data_void_out:     in std_ulogic;      
    
    test2_cpu_data_void_out:    out std_ulogic;
    test2_output_port      :    out noc_flit_type;
    test3_cpu_data_void_out:    out std_ulogic;
    test3_output_port      :    out noc_flit_type;
    test5_cpu_data_void_out:    out std_ulogic;
    test5_output_port      :    out misc_noc_flit_type;
    test6_cpu_data_void_out:    out std_ulogic;
    test6_output_port       :    out noc_flit_type;

    noc1_in_port           :     in noc_flit_type;
    tonoc1_cpu_data_void_in:     in std_ulogic;
    noc3_in_port           :     in noc_flit_type;
    tonoc3_cpu_data_void_in:     in std_ulogic;
    noc4_in_port           :     in noc_flit_type;
    tonoc4_cpu_data_void_in:     in std_ulogic;
    noc5_in_port           :     in misc_noc_flit_type;
    tonoc5_cpu_data_void_in:     in std_ulogic;
 
    noc1_input_port:             out noc_flit_type;
    noc1_cpu_data_void_in:       out std_ulogic;
    noc3_input_port:             out noc_flit_type;
    noc3_cpu_data_void_in:       out std_ulogic;
    noc4_input_port:             out noc_flit_type;
    noc4_cpu_data_void_in:       out std_ulogic;
    noc5_input_port:             out misc_noc_flit_type;
    noc5_cpu_data_void_in:       out std_ulogic;

    noc1_stop_out_s4:            in std_logic;
    noc2_stop_out_s4:            in std_logic;
    noc3_stop_out_s4:            in std_logic;
    noc4_stop_out_s4:            in std_logic;
    noc5_stop_out_s4:            in std_logic;
    noc6_stop_out_s4:            in std_logic;

    noc1_cpu_stop_out:           out std_ulogic;
    noc2_cpu_stop_out:           out std_ulogic;
    noc3_cpu_stop_out:           out std_ulogic;
    noc4_cpu_stop_out:           out std_ulogic;
    noc5_cpu_stop_out:           out std_ulogic;
    noc6_cpu_stop_out:           out std_ulogic;

    noc1_cpu_stop_in:            in std_ulogic;
    noc2_cpu_stop_in:            in std_ulogic;
    noc3_cpu_stop_in:            in std_ulogic;
    noc4_cpu_stop_in:            in std_ulogic;
    noc5_cpu_stop_in:            in std_ulogic;
    noc6_cpu_stop_in:            in std_ulogic);

end;


architecture rtl of jtag_test is

  type jtag_state_type is (rti,rti1,inject1,inject2,inject3,inject4,inject5,inject6,extract, inject_instruction, read_and_check, writein,extr_source,waitfirstvoid,waitforvoid1,waitforvoid3,waitforvoid4,waitforvoid5,waitforvoid_fin);

  signal jtag_current, jtag_next : jtag_state_type;

  signal demux_sel:std_logic_vector(5 downto 0);
  signal compare_reg:std_logic_vector(5 downto 0);
  signal tdo_data,tdo_data0,sipo_clear,sel,sipo_en_in,sipo_en_out,sipo_done,en_sipo_comp,piso_load,piso_load0,piso_en,piso_en0,piso_done,piso_done0,instr_done :std_logic;
  signal sipo_en_i,sipo_en_o,sipo_en_ii,sipo_en_is,op_i,sipo_done_i,sipo_clear_i,tdi_i: std_logic_vector (5 downto 0);
 
  --signals for logic JTAG->CPU (NoC planes 2,3,5,6)

  signal rd_i2,rd_i3,rd_i5,rd_i6: std_logic;
  signal fwd_wr_full_o2,fwd_wr_full_o3,fwd_wr_full_o5,fwd_wr_full_o6: std_logic;
  signal fwd_rd_empty_o2,fwd_rd_empty_o3,fwd_rd_empty_o5,fwd_rd_empty_o6:std_logic;
  
  type test_vect is array(0 to 5) of std_logic_vector(NOC_FLIT_SIZE downto 0);

  signal test_in,test_in_sync: test_vect;

  signal sipo_comp                                     : std_logic_vector(NOC_FLIT_SIZE+6 downto 0);
  type t_comp is array (0 to 5) of std_logic_vector(NOC_FLIT_SIZE+8 downto 0);
  signal sipo_comp_i            : t_comp;

  signal test_compare           :std_logic_vector(NOC_FLIT_SIZE+6 downto 0);
  signal source_compare          :std_logic_vector(5 downto 0);
  signal test_out               :std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal piso_in                  : std_logic_vector(NOC_FLIT_SIZE+6 downto 0);

  --signals for logic CPU->JTAG (NoC planes 1,3,4,5)
  
  signal A,B,C,D                  : std_logic_vector(NOC_FLIT_SIZE downto 0);
    
  signal test1_out,t1_out              :noc_flit_type;
  
  signal test1_cpu_data_void_in,t1_cpu_data_void_in:std_ulogic;

  
  signal test3_out,t3_out              :noc_flit_type;
  signal test3_cpu_data_void_in,t3_cpu_data_void_in :std_ulogic;
 
  signal test4_out,t4_out              :noc_flit_type;
  signal test4_cpu_data_void_in,t4_cpu_data_void_in :std_ulogic;
 
  
  signal test5_out,t5_out              :misc_noc_flit_type;
  
  signal test5_cpu_data_void_in,t5_cpu_data_void_in :std_ulogic;

  signal noc_stop_out_test: std_logic_vector(5 downto 0);


  signal noc1_in_ext,noc3_in_ext,noc4_in_ext                     : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal noc1_in_port_sync,noc3_in_port_sync,noc4_in_port_sync   : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal fwd_rd_empty_o1out,fwd_rd_empty_o3out,fwd_rd_empty_o4out: std_logic;
  signal fwd_wr_full_o1out,fwd_wr_full_o3out,fwd_wr_full_o4out   : std_logic;
  signal rd_i1_out,rd_i3_out,rd_i4_out                           : std_logic;
  signal we_in1_out,we_in3_out,we_in4_out                        : std_logic;



  signal noc5_in_ext             : std_logic_vector(34 downto 0);
  signal noc5_in_port_sync       : std_logic_vector(34 downto 0);
  signal fwd_rd_empty_o5out      : std_logic;
  signal fwd_wr_full_o5out       : std_logic;
  signal rd_i5_out                : std_logic;
  signal we_in5_out              : std_logic;

begin
  
next_in<=instr_done;  
  
--jtag_fsm

CU_REG : process (tclk, rst)
begin
   if rst = '0' then
      jtag_current<= rti;
   elsif tclk'event and tclk='1' then
      jtag_current<=jtag_next;
   end if;
end process CU_REG;

NSL : process(jtag_current,tms,sipo_done,sipo_done_i,piso_done,piso_done0,tonoc1_cpu_data_void_in,tonoc5_cpu_data_void_in,noc5_in_port_sync,noc1_in_port_sync,noc4_in_port_sync,noc3_in_port_sync) 
begin 
   jtag_next <= jtag_current;
   case jtag_current is
     when rti =>                if tms='1' then
                                  
                                  jtag_next<=inject1;
                                end if;
                                noc_stop_out_test<=(others=>'1');
                                       
                                sel<='0';
                                piso_en<='0';
                                instr_done<='0';
                                demux_sel<="000000";

                                
                                
     when inject1 =>            demux_sel<="100000";
                                sel<='1';
                                instr_done<='1';
                                sipo_en_ii(0)<='1';
                                if sipo_done_i(0)='1' then
                                  jtag_next<=inject2;
                                  sipo_en_ii(0)<='0';
                                end if ;
     when inject2 =>            sipo_en_ii(1)<='1';
                                demux_sel<="010000";
                                if sipo_done_i(1)='1' then
                                  jtag_next<=inject3;
                                  sipo_en_ii(1)<='0';
                                end if ;
     when inject3 =>            sipo_en_ii(2)<='1';
                                demux_sel<="001000";
                                if sipo_done_i(2)='1' then
                                  jtag_next<=inject4;
                                  sipo_en_ii(2)<='0';
                                end if ;
     when inject4 =>            sipo_en_ii(3)<='1';
                                demux_sel<="000100";
                                if sipo_done_i(3)='1' then
                                  jtag_next<=inject5;
                                  sipo_en_ii(3)<='0';
                                end if ;
     when inject5 =>            sipo_en_ii(4)<='1';
                                demux_sel<="000010";
                                if sipo_done_i(4)='1' then
                                  jtag_next<=inject6;
                                  sipo_en_ii(4)<='0';
                                end if ;


     when inject6 =>            sipo_en_ii(5)<='1';
                                demux_sel<="000001";
                                
                                if sipo_done_i(5)='1' then
                                  jtag_next<=waitfirstvoid;
                                  sipo_en_ii(5)<='0';
                                  noc_stop_out_test(4)<='0';
                                  if noc5_in_port_sync(0)='0' then
                                    compare_reg<="000010";
                                  end if ;
                                end if ;

                              
     when rti1 =>               instr_done<='0';
                                sipo_clear<='1';
                                
                                piso_en<='0';
                                
                                piso_load<='0';

                                piso_en0<='0';
                                en_sipo_comp<='0';


                                sipo_en_out<='0';
                                if tms= '1' then 
                                jtag_next<=inject_instruction;                      
                                end if;
                                
                                
     when inject_instruction => instr_done<='1';
                                sipo_clear<='0';
                                sipo_en_in<='1';   
                                sel<='1';
                                demux_sel<=compare_reg;
                                if sipo_done='1' then
                                  sipo_en_in<='0';
                                  jtag_next<=waitforvoid1;
                                
                                end if;
                                                                                    
     when writein =>            sipo_en_out<='1';
                                en_sipo_comp<='1';
                                if sipo_comp_i(4)(1)='1' then
                                  compare_reg<="000010";
                                elsif sipo_comp_i(5)(1)='1' then
                                  compare_reg<="000001";                                  
                                elsif sipo_comp_i(2)(1)='1' then
                                  compare_reg<="001000";
                                elsif sipo_comp_i(1)(1)='1' then
                                  compare_reg<="010000";
                                end if;
                                piso_load0<='1';
                                       
                                  
                                
                                jtag_next<=extr_source; 
                                
     when extr_source =>        sipo_en_out<='0';
                                piso_load0<='0';
                                piso_en0<='1';
                                if piso_done0='1' then
                                  jtag_next<=rti1;
                                end if;
                                
       
     when waitfirstvoid =>      instr_done<='0';
                                
                                if noc5_in_port_sync(0)='0' then 
                                                                 
                                  jtag_next<=read_and_check; 
                                  noc_stop_out_test(4)<='1';
                                end if;
                                  


                                
     when waitforvoid1 =>   
                                instr_done<='0';
                                noc_stop_out_test(0)<='0';
                                if noc1_in_port_sync(0)='0' then
                                  compare_reg<="100000";
                                end if;
                                                                              
                                jtag_next<=waitforvoid3;
     when waitforvoid3 =>       if noc1_in_port_sync(0)='0' then
                                  jtag_next<=read_and_check;
                                  noc_stop_out_test(0)<='1';
                                else
                                  jtag_next<=waitforvoid4;
                                  noc_stop_out_test(0)<='1';
                                  noc_stop_out_test(2)<='0';
                                  if noc3_in_port_sync(0)='0'then
                                    compare_reg<="001000";
                                  end if ;
                                end if;
     when waitforvoid4 =>       if noc3_in_port_sync(0)='0' then
                                  jtag_next<=read_and_check;
                                  noc_stop_out_test(2)<='1';
                                else
                                  jtag_next<=waitforvoid5;
                                  noc_stop_out_test(2)<='1';
                                  noc_stop_out_test(3)<='0';
                                  if noc4_in_port_sync(0)='0'then
                                    compare_reg<="000100";
                                  end if ;
                                end if;
     when waitforvoid5 =>       
                                if noc4_in_port_sync(0)='0' then
                                  jtag_next<=read_and_check;
                                  noc_stop_out_test(3)<='1';
                                  
                                 else
                                  jtag_next<=waitforvoid_fin;
                                  noc_stop_out_test(3)<='1';
                                  noc_stop_out_test(4)<='0';
                                  if noc5_in_port_sync(0)='0'then
                                    compare_reg<="000010";
                                  end if ;
                                end if;





     when waitforvoid_fin =>      
                                if noc5_in_port_sync(0)='0' then  
                                    jtag_next<=read_and_check;
                                  else
                                    jtag_next<=writein;
                                  end if;
                                    noc_stop_out_test(4)<='1';
                                                         
     when read_and_check =>     noc_stop_out_test(4)<='1';
                                en_sipo_comp<='1';
                                piso_load<=not(test_out(0));
                                jtag_next<=extract;
                                
     when extract =>           
                                piso_load<='0';
                                en_sipo_comp<='0';
                                piso_en<='1';
                                if piso_done='1'then
                                  jtag_next<=rti1;
                                  sipo_clear<='1';
                                  
                                end if;
                                
 end case;
end process NSL;



process(tms,noc1_stop_out_s4,noc2_stop_out_s4,noc3_stop_out_s4,noc4_stop_out_s4,noc5_stop_out_s4,noc6_stop_out_s4,noc_stop_out_test)
begin
  if tms='0' then
    noc1_cpu_stop_out<=noc1_stop_out_s4;
    noc2_cpu_stop_out<=noc2_stop_out_s4;
    noc3_cpu_stop_out<=noc3_stop_out_s4;
    noc4_cpu_stop_out<=noc4_stop_out_s4;
    noc5_cpu_stop_out<=noc5_stop_out_s4;
    noc6_cpu_stop_out<=noc6_stop_out_s4;
  else
    noc1_cpu_stop_out<=noc_stop_out_test(0);
    noc2_cpu_stop_out<=noc_stop_out_test(1);
    noc3_cpu_stop_out<=noc_stop_out_test(2);
    noc4_cpu_stop_out<=noc_stop_out_test(3);
    noc5_cpu_stop_out<=noc_stop_out_test(4);
    noc6_cpu_stop_out<=noc_stop_out_test(5);
  end if;
end process;



process(sipo_en_is,sipo_en_ii,jtag_current)
begin
  if jtag_current=inject_instruction then
    sipo_en_i<=sipo_en_is;
  else
    sipo_en_i<=sipo_en_ii;
  end if ;
end process;

process(compare_reg,sipo_done_i)
begin
  case compare_reg is
    when "100000" => sipo_done<=sipo_done_i(0);
    when "010000" => sipo_done<=sipo_done_i(1);
    when "001000" => sipo_done<=sipo_done_i(2);
    when "000100" => sipo_done<=sipo_done_i(3);
    when "000010" => sipo_done<=sipo_done_i(4);
    when "000001" => sipo_done<=sipo_done_i(5);
    when others => null;
  end case;

end process;




process(sipo_en_in,compare_reg)
begin
  if sipo_en_in='1' then
    case compare_reg is
      when "100000" =>     sipo_en_is(0)<='1';     
      when "010000" =>     sipo_en_is(1)<='1';
      when "001000" =>     sipo_en_is(2)<='1';              
      when "000100" =>     sipo_en_is(3)<='1';
      when "000010" =>     sipo_en_is(4)<='1';
      when "000001" =>     sipo_en_is(5)<='1';
      when others =>    null;
    end case;
  else
    sipo_en_is<=(others=>'0');
  end if ;
end process;


process(sipo_en_out,compare_reg)
begin
  if sipo_en_out='1' then
    if compare_reg="100000" then
      sipo_en_o(0)<='1';
    elsif compare_reg="010000" then
      sipo_en_o(1)<='1';
    elsif compare_reg="001000" then
      sipo_en_o(2)<='1';
    elsif compare_reg="000100" then
      sipo_en_o(3)<='1';
    elsif compare_reg="000010" then
      sipo_en_o(4)<='1';
    elsif compare_reg="000010" then
      sipo_en_o(5)<='1';
    end if;
  else
    sipo_en_o<=(others=>'0');
  end if;
end process;
    
process(sipo_clear,compare_reg)
begin
  if sipo_clear='1' then
    case compare_reg is
      when "100000" =>     sipo_clear_i(0)<='1';
      when "010000" =>     sipo_clear_i(1)<='1';
      when "001000" =>     sipo_clear_i(2)<='1';
      when "000100" =>     sipo_clear_i(3)<='1';
      when "000010" =>     sipo_clear_i(4)<='1';
      when "000001" =>     sipo_clear_i(5)<='1';

      when others =>    null;
    end case;
  else
    sipo_clear_i<=(others=>'0');
  end if ;
end process;  

  GEN_SIPO: for i in 0 to 5 generate

    sipo_i: sipo
      generic map (DIM=>NOC_FLIT_SIZE+9)
      port map (
        clk          =>tclk,
        clear        =>sipo_clear_i(i),
        en_in        =>sipo_en_i(i),
        en_out       =>sipo_en_o(i),
        en_comp      =>en_sipo_comp,
        serial_in    =>tdi_i(i),
        test_comp    =>sipo_comp_i(i),
        data_out     =>test_in(i),
        op           =>op_i(i),
        done         =>sipo_done_i(i));


  end generate GEN_SIPO;


demux_1to6_1: demux_1to6
port map(
  data_in =>tdi,
  sel     =>demux_sel,
  out1   =>tdi_i(0),
  out2   =>tdi_i(1),
  out3   =>tdi_i(2),
  out4   =>tdi_i(3),
  out5   =>tdi_i(4),
  out6   =>tdi_i(5));


--from NoC plane 2

rd_i2<=not(noc2_cpu_stop_in);

async_fifo_0: async_fifo
  generic map (
    g_data_width => NOC_FLIT_SIZE+1,
    g_size       => 8)
  port map (
    rst_n_i    => rst,
    clk_wr_i   => tclk,
    we_i       => sipo_en_out,
    d_i        => test_in(1),
    wr_full_o  => fwd_wr_full_o2,
    clk_rd_i   => refclk,
    rd_i       => rd_i2,
    q_o        => test_in_sync(1),
    rd_empty_o => fwd_rd_empty_o2);



mux_2to1_1:mux_2to1
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test_in_sync(1)(NOC_FLIT_SIZE downto 1),
    B=>noc2_output_port,
    X=>test2_output_port);

mux2to1_1:mux2to1
  port map(
    sel=>sel,
    A=>fwd_rd_empty_o2,
    B=>noc2_cpu_data_void_out,
    X=>test2_cpu_data_void_out);

--from NoC plane 3


rd_i3<=not(noc3_cpu_stop_in) ;

async_fifo_1: async_fifo
  generic map (
    g_data_width => NOC_FLIT_SIZE+1,
    g_size       => 8)
  port map (
    rst_n_i    => rst,
    clk_wr_i   => tclk,
    we_i       => sipo_en_out,
    d_i        => test_in(2),
    wr_full_o  => fwd_wr_full_o3,
    clk_rd_i   => refclk,
    rd_i       => rd_i3,
    q_o        => test_in_sync(2),
    rd_empty_o => fwd_rd_empty_o3);



mux_2to1_2:mux_2to1
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test_in_sync(2)(NOC_FLIT_SIZE downto 1),
    B=>noc3_output_port,
    X=>test3_output_port);

mux2to1_2:mux2to1
  port map(
    sel=>sel,
    A=>fwd_rd_empty_o3,
    B=>noc3_cpu_data_void_out,
    X=>test3_cpu_data_void_out);

--from NoC plane 5

rd_i5<=not(noc5_cpu_stop_in) ;

async_fifo_2:async_fifo
  generic map (
    g_data_width => MISC_NOC_FLIT_SIZE+1,
    g_size       => 8)
  port map (
    rst_n_i    => rst,
    clk_wr_i   => tclk,
    we_i       => sipo_en_out,
    d_i        => test_in(4)(34 downto 0),
    wr_full_o  => fwd_wr_full_o5,
    clk_rd_i   => refclk,
    rd_i       => rd_i5,
    q_o        => test_in_sync(4)(34 downto 0),
    rd_empty_o => fwd_rd_empty_o5);


mux_2to1_3:mux_2to1
  generic map(sz=>MISC_NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test_in_sync(4)(34 downto 1),
    B=>noc5_output_port,
    X=>test5_output_port);

mux2to1_3:mux2to1
  port map(
    sel=>sel,
    A=>fwd_rd_empty_o5,
    B=>noc5_cpu_data_void_out,
    X=>test5_cpu_data_void_out);

--from NoC plane 6


rd_i6<=not(noc6_cpu_stop_in) ;

async_fifo_3: async_fifo
  generic map (
    g_data_width => NOC_FLIT_SIZE+1,
    g_size       => 8)
  port map (
    rst_n_i    => rst,
    clk_wr_i   => tclk,
    we_i       => sipo_en_out,
    d_i        => test_in(5),
    wr_full_o  => fwd_wr_full_o6,
    clk_rd_i   => refclk,
    rd_i       => rd_i6,
    q_o        => test_in_sync(5),
    rd_empty_o => fwd_rd_empty_o6);



mux_2to1_4:mux_2to1
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test_in_sync(5)(NOC_FLIT_SIZE downto 1),
    B=>noc3_output_port,
    X=>test6_output_port);

mux2to1_4:mux2to1
  port map(
    sel=>sel,
    A=>fwd_rd_empty_o6,
    B=>noc6_cpu_data_void_out,
    X=>test6_cpu_data_void_out);


  process(compare_reg,sipo_comp_i)
  begin
    case compare_reg is
      when "100000" => sipo_comp<=sipo_comp_i(0)(NOC_FLIT_SIZE+8 downto 2);
      when "010000" => sipo_comp<=sipo_comp_i(1)(NOC_FLIT_SIZE+8 downto 2);
      when "001000" => sipo_comp<=sipo_comp_i(2)(NOC_FLIT_SIZE+8 downto 2);
      when "000100" => sipo_comp<=sipo_comp_i(3)(NOC_FLIT_SIZE+8 downto 2);
      when "000010" => sipo_comp<=sipo_comp_i(4)(NOC_FLIT_SIZE+8 downto 2);
      when "000001" => sipo_comp<=sipo_comp_i(5)(NOC_FLIT_SIZE+8 downto 2);
      when others => sipo_comp<=(others=>'0');
    end case;
  end process;
  
  
  
  tdoout: process(piso_en,piso_en0,test_out,sipo_comp,tdo_data,tdo_data0,jtag_current)
  begin
    if piso_en='1' then
      tdo<=tdo_data;
    elsif piso_en0='1' then
      tdo<=tdo_data0;     
    else
      if (jtag_current=read_and_check and test_compare=sipo_comp)  then
        tdo<='1';
      else
        tdo<='0';
      end if;
    end if;
  end process tdoout;


--to NoC plane 1
  
  rd_i1_out<=not(noc_stop_out_test(0));
  noc1_in_ext<=t1_out & t1_cpu_data_void_in ; 
  we_in1_out<=not(tonoc1_cpu_data_void_in);

  test1_out<=noc1_in_port_sync(NOC_FLIT_SIZE downto 1);
  test1_cpu_data_void_in<=noc1_in_port_sync(0);
  
  async_fifo_4: async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE+1,
      g_size       => 8)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in1_out,
      d_i        => noc1_in_ext,
      wr_full_o  => fwd_wr_full_o1out,
      clk_rd_i   => tclk,
      rd_i       => rd_i1_out,
      q_o        => noc1_in_port_sync,
      rd_empty_o => fwd_rd_empty_o1out);


  
demux_2to1_1:demux_1to2
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    data_in=>noc1_in_port,
    out1=>t1_out,
    out2=>noc1_input_port);

demux2to1_1:demux1to2
  port map(
    sel=>sel,
    data_in=>tonoc1_cpu_data_void_in,
    out1=>t1_cpu_data_void_in,
    out2=>noc1_cpu_data_void_in);

--to Noc plane 3

  rd_i3_out<=not(noc_stop_out_test(2));
  noc3_in_ext<=t3_out & t3_cpu_data_void_in ;
  we_in3_out<=not(tonoc3_cpu_data_void_in);

  test3_out<=noc3_in_port_sync(NOC_FLIT_SIZE downto 1);
  test3_cpu_data_void_in<=noc3_in_port_sync(0);
  
  async_fifo_5: async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE+1,
      g_size       => 8)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in3_out,
      d_i        => noc3_in_ext,
      wr_full_o  => fwd_wr_full_o3out,
      clk_rd_i   => tclk,
      rd_i       => rd_i3_out,
      q_o        => noc3_in_port_sync,
      rd_empty_o => fwd_rd_empty_o3out);


  
demux_2to1_2:demux_1to2
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    data_in=>noc3_in_port,
    out1=>t3_out,
    out2=>noc3_input_port);

demux2to1_2:demux1to2
  port map(
    sel=>sel,
    data_in=>tonoc3_cpu_data_void_in,
    out1=>t3_cpu_data_void_in,
    out2=>noc3_cpu_data_void_in);



-- to NoC plane 4

  rd_i4_out<=not(noc_stop_out_test(3));
  noc4_in_ext<=t4_out & t4_cpu_data_void_in ;
  we_in4_out<=not(tonoc4_cpu_data_void_in);

  test4_out<=noc4_in_port_sync(NOC_FLIT_SIZE downto 1);
  test4_cpu_data_void_in<=noc4_in_port_sync(0);
  
  async_fifo_6: async_fifo
    generic map (
      g_data_width => NOC_FLIT_SIZE+1,
      g_size       => 8)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in4_out,
      d_i        => noc4_in_ext,
      wr_full_o  => fwd_wr_full_o4out,
      clk_rd_i   => tclk,
      rd_i       => rd_i4_out,
      q_o        => noc4_in_port_sync,
      rd_empty_o => fwd_rd_empty_o4out);


  
demux_2to1_3:demux_1to2
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    data_in=>noc4_in_port,
    out1=>t4_out,
    out2=>noc4_input_port);

demux2to1_3:demux1to2
  port map(
    sel=>sel,
    data_in=>tonoc4_cpu_data_void_in,
    out1=>t4_cpu_data_void_in,
    out2=>noc4_cpu_data_void_in);


--to NoC plane 5

  rd_i5_out<=not(noc_stop_out_test(4));
  noc5_in_ext<=t5_out & t5_cpu_data_void_in ;
  we_in5_out<=not(tonoc5_cpu_data_void_in);

  test5_out<=noc5_in_port_sync(MISC_NOC_FLIT_SIZE downto 1);
  test5_cpu_data_void_in<=noc5_in_port_sync(0);
  
  async_fifo_7: async_fifo
    generic map (
      g_data_width => MISC_NOC_FLIT_SIZE+1,
      g_size       => 8)
    port map (
      rst_n_i    => rst,
      clk_wr_i   => refclk,
      we_i       => we_in5_out,
      d_i        => noc5_in_ext,
      wr_full_o  => fwd_wr_full_o5out,
      clk_rd_i   => tclk,
      rd_i       => rd_i5_out,
      q_o        => noc5_in_port_sync,
      rd_empty_o => fwd_rd_empty_o5out);


  
demux_2to1_4:demux_1to2
  generic map(sz=>MISC_NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    data_in=>noc5_in_port,
    out1=>t5_out,
    out2=>noc5_input_port);

demux2to1_4:demux1to2
  port map(
    sel=>sel,
    data_in=>tonoc5_cpu_data_void_in,
    out1=>t5_cpu_data_void_in,
    out2=>noc5_cpu_data_void_in);



--final mux to test_out_reg

  A<=test1_out & test1_cpu_data_void_in;
  B<=test3_out & test3_cpu_data_void_in;
  C<=test4_out & test4_cpu_data_void_in;
  D<=noc_flit_pad & test5_out & test5_cpu_data_void_in;

  
mux_4to1_1:mux_4to1
  generic map(sz=>NOC_FLIT_SIZE+1)
  port map(
    sel=>compare_reg,
    A=>A,
    B=>B,
    C=>C,
    D=>D,
    X=>test_out);

  piso_in<=test_out & compare_reg;


piso_0:piso
 generic map(sz=>6 )
 port map(
   clk=>tclk,
   load=> piso_load0,
   A=>compare_reg,
   shift_en=>piso_en0,
   B=>source_compare,
   Y=>tdo_data0,
   done=>piso_done0);
  
  
  
piso_1:piso
 generic map(sz=>NOC_FLIT_SIZE+7 )
 port map(
   clk=>tclk,
   load=> piso_load,
   A=>piso_in,
   shift_en=>piso_en,
   B=>test_compare,
   Y=>tdo_data,
   done=>piso_done);
  
end;
