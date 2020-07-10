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
  type jtag_state_type is (rti,rti1,inject1,inject2,inject3,extract, inject_instruction, read_and_check, writein,extr_source,waitfirstvoid,waitforvoid,waitforvoid1,waitforvoid2);

  signal jtag_current, jtag_next : jtag_state_type;

  --JTAG control signals
  signal tdo_data,tdo_data0,sipo_clear,add_clear,sel,add_en_in,sipo_en_in,sipo_en_out,en_sipo_comp,add_en_out,test_running,piso_load,piso_load0,piso_en,piso_en0,piso_done,piso_done0,instr_done :std_logic;
  signal sipo_en_in1,sipo_en_in2,sipo_en_in3,sipo_en_out1,sipo_en_out2,sipo_en_out3 : std_logic;
  signal sipo_en_in1_in,sipo_en_in2_in,sipo_en_in3_in,sipo_en_in1_sec,sipo_en_in2_sec,sipo_en_in3_sec: std_logic;
  signal flag_in,flag,flag2 :std_logic;

  --JTAG status signal
  signal add_done,sipo_done,sipo_done1,sipo_done2,sipo_done3,void_flag,op,op1,op2,op3: std_logic;
  signal addr: std_logic_vector(2 downto 0);

  signal tdi1,tdi2,tdi3,tail: std_logic;
  signal sipo_clear1,sipo_clear2,sipo_clear3 :std_logic;

  --syncronizing_signals
  signal test2_in_sync: std_logic_vector(NOC_FLIT_SIZE downto 0);


  --reset synchronizers:
  signal rst_sync5: std_logic;

  --Tile testing signals

  signal stop_in                : std_logic;

  signal test2_void_in,test5_void_in,test3_void_in  : std_logic;


  signal rd_i2,rd_i3,rd_i5,rd_i6: std_logic;
  signal fwd_wr_full_o2,fwd_wr_full_o3,fwd_wr_full_o5,fwd_wr_full_o6: std_logic;
  signal fwd_rd_empty_o2,fwd_rd_empty_o3,fwd_rd_empty_o5,fwd_rd_empty_o6:std_logic;
  




  signal A,B,C                  : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal sipo_in,sipo1_in       : std_logic;

  signal add_in                 : std_logic_vector(2 downto 0);
  signal test_in                : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test_sel_in            : std_logic_vector(2 downto 0);
  signal test2_in               : std_logic_vector(66 downto 0);
  signal test3_in               : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test5_in               : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test6_in               : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test5_in_sync          : std_logic_vector(34 downto 0);
  signal test3_in_sync          : std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal test6_in_sync          : std_logic_vector(NOC_FLIT_SIZE downto 0);

  signal test5_in_bis           :std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
  signal A_in                      : std_logic_vector(NOC_FLIT_SIZE+4 downto 0);


  
  --
  signal sipo_comp                                     : std_logic_vector(NOC_FLIT_SIZE+3 downto 0);
  signal sipo_comp1,sipo_comp2,sipo_comp3              :std_logic_vector(NOC_FLIT_SIZE+5 downto 0);
  signal test_compare           :std_logic_vector(NOC_FLIT_SIZE+3 downto 0);
  signal test_compare0          :std_logic_vector(2 downto 0);
  signal test_out               :std_logic_vector(NOC_FLIT_SIZE downto 0);
  signal piso_in                  : std_logic_vector(NOC_FLIT_SIZE+3 downto 0);
  signal demux_sel,test_sel_out,mux_test_sel_out,compare_reg,write_reg :std_logic_vector(2 downto 0);

  
  signal test1_out,t1_out              :noc_flit_type;
  
  signal test1_cpu_data_void_in,t1_cpu_data_void_in:std_ulogic;

  
  signal test3_out,t3_out              :noc_flit_type;
  signal test3_cpu_data_void_in,t3_cpu_data_void_in :std_ulogic;
 
  signal test4_out,t4_out              :noc_flit_type;
  signal test4_cpu_data_void_in,t4_cpu_data_void_in :std_ulogic;
 
  
  signal test5_out,t5_out              :misc_noc_flit_type;
  
  signal test5_cpu_data_void_in,t5_cpu_data_void_in :std_ulogic;

  signal noc1_stop_out_test      : std_ulogic;
  signal noc2_stop_out_test      : std_ulogic:='0';
  signal noc3_stop_out_test      : std_ulogic;
  signal noc4_stop_out_test      : std_ulogic:='0';
  signal noc5_stop_out_test      : std_ulogic;
  signal noc6_stop_out_test      : std_ulogic:='0';



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

NSL : process(tail,jtag_current,tms,sipo_done,flag,sipo_done1,sipo_done2,sipo_done3,addr,piso_done,piso_done0,op,void_flag,test5_in,test3_in,tonoc1_cpu_data_void_in,tonoc5_cpu_data_void_in,noc5_in_port_sync,noc1_in_port_sync,sipo_comp1,sipo_comp2,sipo_comp3) 
begin 
   jtag_next <= jtag_current;
   case jtag_current is
     when rti =>                if tms='1' then
                                  
                                  jtag_next<=inject1;
                                end if;
                                noc1_stop_out_test<='1';
                                noc3_stop_out_test<='1';
                                noc5_stop_out_test<='1';
                                write_reg<="000";
                                flag2<='0';
                                
                                --flag_in<='1';
                                stop_in<='1';
                                sel<='0';
                                piso_en<='0';
                                instr_done<='0';
                                demux_sel<="000";

                                
                                
     when inject1 =>            demux_sel<="100";
                                sel<='1';
                                instr_done<='1';
                                sipo_en_in1_in<='1';
                                if sipo_done1='1' then
                                  jtag_next<=inject2;
                                  sipo_en_in1_in<='0';
                                end if ;
     when inject2 =>            sipo_en_in2_in<='1';
                                demux_sel<="010";
                                if sipo_done2='1' then
                                  jtag_next<=inject3;
                                  sipo_en_in2_in<='0';
                                end if ;
     when inject3 =>            sipo_en_in3_in<='1';
                                demux_sel<="001";
                                
                                if sipo_done3='1' then
                                  flag2<='1';
                                  jtag_next<=waitfirstvoid;
                                  sipo_en_in3_in<='0';
                                  noc5_stop_out_test<='0';
                                  if noc5_in_port_sync(0)='0' then
                                    compare_reg<="001";
                                    
                                 --   piso_load<='1';
                                  end if ;
                                  
                                end if ;
     
     when rti1 =>               instr_done<='0';
                                test_running<='0';
                                sipo_clear<='1';
                                stop_in<='1';
                                piso_en<='0';
                                
                                piso_load<='0';

                                piso_en0<='0';
                                flag_in<='0';
                                en_sipo_comp<='0';


                                sipo_en_out<='0';
                                test2_void_in<='1';
                                test3_void_in<='1';
                                test5_void_in<='1';
                                if tms= '1' then 
                                jtag_next<=inject_instruction;                      
                                end if;
                                
                                
     when inject_instruction => instr_done<='1';
                                sipo_clear<='0';
                                sipo_en_in<='1';   
                                test_running<='1';
                                sel<='1';
                                demux_sel<=compare_reg;
                                if sipo_done='1' then
                                  sipo_en_in<='0';
                                  jtag_next<=waitforvoid;
                                --  noc1_stop_out_test<='0';
                                end if;
                                  

   --  
--				  if tail='0' and op<='1' then  --sbagliato                    
  --                                  jtag_next<=writein;
     
                                                                                    
     when writein =>            sipo_en_out<='1';
                                en_sipo_comp<='1';
                                if sipo_comp3(1)='1' then
                                  compare_reg<="001";
                                  
                                elsif sipo_comp2(1)='1' then
                                  compare_reg<="010";
                                elsif sipo_comp1(1)='1' then
                                  compare_reg<="100";
                                end if;
                                piso_load0<='1';
                               -- noc1_stop_out_test<='1';
                               -- noc2_stop_out_test<='1';
                               -- noc3_stop_out_test<='1';
                               -- noc4_stop_out_test<='1';
                               -- noc5_stop_out_test<='1';



                                
                                if addr="010" then
                                  test3_void_in<=test3_in_sync(0);
                            --      tail<=test1_in(65);
                                elsif addr="001" then
                                  test5_void_in<=test5_in_sync(0);
                                  --      tail<=test3_in(65);
                                  
                                end if;
                                jtag_next<=extr_source; 
                                
                 --               en_sipo_comp<='1';
     when extr_source =>        sipo_en_out<='0';
                                piso_load0<='0';
                                piso_en0<='1';
                                if piso_done0='1' then
                                  jtag_next<=rti1;
                                end if;
                                
       
     when waitfirstvoid =>      instr_done<='0';
                                
                                if noc5_in_port_sync(0)='0' then --if tonoc5_cpu_data_void_in='0'
                                                                  --then   ---
                                  jtag_next<=read_and_check;
                                  --compare_reg<=test_sel_out;
                                  --piso_load<='0';       --- --- 
                                  noc5_stop_out_test<='1';
                                end if;
                                  


                                
     when waitforvoid =>     -- noc1_stop_out_test<='0';
                             -- noc2_stop_out_test<='0';
                             --   noc3_stop_out_test<='0';
                             --   noc4_stop_onut_test<='0';
                             --   noc5_stop_out_test<='0';
                             --   noc6_stop_out_test<='0';
       --set stop_in='0',
                                instr_done<='0';
                               -- stop_in<='0';

                                
                               -- en_sipo_comp<='1';
                               -- if void_flag='1' then
                               --   piso_load<='1';
                               --   compare_reg<=test_sel_out;
                               --   jtag_next<=read_and_check;
                               -- elsif flag='0'then 
                               --   jtag_next<=writein;
                                -- end if;
                                noc1_stop_out_test<='0';
                                if noc1_in_port_sync(0)='0' then
                                  compare_reg<="100";
                                  
                                 -- piso_load<='1';  --- ---   
                               --   flag_in<='1';
                                end if;
                                                                              
                                jtag_next<=waitforvoid1;
     when waitforvoid1 =>       --noc1_stop_out_test<='0';
                                if noc1_in_port_sync(0)='0' then
                                  jtag_next<=read_and_check;
                                  noc1_stop_out_test<='1';
                                  
                                  
                                --  piso_load<='1';
                                else
                                  jtag_next<=waitforvoid2;
                                  noc1_stop_out_test<='1';
                                  noc5_stop_out_test<='0';
                                  if noc5_in_port_sync(0)='0'then
                                    compare_reg<="001";
                              --      piso_load<='1'; --- ---
                              --      flag_in<='1';
                                  end if ;
                                end if;
     when waitforvoid2 =>      -- if tonoc5_cpu_data_void_incpu_data_void_in='0' then

                                if noc5_in_port_sync(0)='0' then  
                                    jtag_next<=read_and_check;
                                  else
                                    jtag_next<=writein;
                                  end if;
                                  
                                 -- compare_reg<=test_sel_out;
                               --   piso_load<='0';  --- ---
                                  noc5_stop_out_test<='1';
                                --end if;
                                --noc1_stop_out_test<='1';
                                                         
     when read_and_check =>    -- noc1_stop_out_test<='1';
                               -- noc2_stop_out_test<='1';
                               -- noc3_stop_out_test<='1';
                               -- noc4_stop_out_test<='1';
                                noc5_stop_out_test<='1';
                               -- noc6_stop_out_test<='1';
                                en_sipo_comp<='1';
                                --      piso_load<='0';    --- ---
                                stop_in<='1';
                                flag_in<='0';
                                --if test_done then
                                --  jtag_next<=rti;
                                --else
                                piso_load<=not(test_out(0));
                                jtag_next<=extract;
                                
     when extract =>            --noc1_stop_out_test<='1';
                                --noc2_stop_out_test<='1';
                                --noc3_stop_out_test<='1';
                                --noc4_stop_out_test<='1';
                                --noc5_stop_out_test<='1';
                                --noc6_stop_out_test<='1';
                                flag2<='0';
                                piso_load<='0';
                                en_sipo_comp<='0';
                                piso_en<='1';
                                if piso_done='1'then
                                  jtag_next<=rti1;
                                  sipo_clear<='1';
                                  
                                end if;
                                
 end case;
end process NSL;



process(tms,noc1_stop_out_s4,noc2_stop_out_s4,noc3_stop_out_s4,noc4_stop_out_s4,noc5_stop_out_s4,noc6_stop_out_s4,noc1_stop_out_test,noc2_stop_out_test,noc3_stop_out_test,noc4_stop_out_test,noc5_stop_out_test,noc6_stop_out_test)
begin
  if tms='0' then
    noc1_cpu_stop_out<=noc1_stop_out_s4;
    noc2_cpu_stop_out<=noc2_stop_out_s4;
    noc3_cpu_stop_out<=noc3_stop_out_s4;
    noc4_cpu_stop_out<=noc4_stop_out_s4;
    noc5_cpu_stop_out<=noc5_stop_out_s4;
    noc6_cpu_stop_out<=noc6_stop_out_s4;
  else
    noc1_cpu_stop_out<=noc1_stop_out_test;
    noc2_cpu_stop_out<=noc2_stop_out_test;
    noc3_cpu_stop_out<=noc3_stop_out_test;
    noc4_cpu_stop_out<=noc4_stop_out_test;
    noc5_cpu_stop_out<=noc5_stop_out_test;
    noc6_cpu_stop_out<=noc6_stop_out_test;
  end if;
end process;

addr<=compare_reg;

flag<=flag_in;

--sipo_done<=sipo_done1 or sipo_done2 or sipo_done3;

process(addr)
begin
  case addr is
    when "100" => tail<=test2_in(65);
    when "010" => tail<=test3_in(65);
    when "001" => tail<=test5_in(33);
    when others=> tail<='0';
  end case;
end process;


process(sipo_en_in1_in,sipo_en_in2_in,sipo_en_in3_in,sipo_en_in1_sec,sipo_en_in2_sec,sipo_en_in3_sec,jtag_current)
begin
  if jtag_current=inject_instruction then
    sipo_en_in1<=sipo_en_in1_sec;
    sipo_en_in2<=sipo_en_in2_sec;
    sipo_en_in3<=sipo_en_in3_sec;
  else
    sipo_en_in1<=sipo_en_in1_in;
    sipo_en_in2<=sipo_en_in2_in;
    sipo_en_in3<=sipo_en_in3_in;
  end if ;
end process;

process(compare_reg,sipo_done1,sipo_done2,sipo_done3)
begin
  case compare_reg is
    when "001" => sipo_done<=sipo_done3;
    when "010" => sipo_done<=sipo_done2;
    when "100" => sipo_done<=sipo_done1;
    when others => null;
  end case;

end process;




process(sipo_en_in,compare_reg)
begin
  if sipo_en_in='1' then
    case compare_reg is
      when "001" =>     sipo_en_in3_sec<='1';
                     ---   sipo_done<=sipo_done3;
      when "010" =>     sipo_en_in2_sec<='1';
                     --   sipo_done<=sipo_done2;
      when "100" =>     sipo_en_in1_sec<='1';
                     --   sipo_done<=sipo_done1;
      when others =>    null;
    end case;
  else
    sipo_en_in1_sec<='0';
    sipo_en_in2_sec<='0';
    sipo_en_in3_sec<='0';
  end if ;
end process;

op<=op1 or op2 or op3;

process(sipo_en_out,compare_reg)
begin
  if sipo_en_out='1' then
    if compare_reg="100" then
      sipo_en_out1<='1';
    elsif compare_reg="010" then
      sipo_en_out2<='1';
    elsif compare_reg="001" then
      sipo_en_out3<='1';
    end if;
  else
    sipo_en_out1<='0';
    sipo_en_out2<='0';
    sipo_en_out3<='0';
  end if;
end process;
    
process(sipo_clear,compare_reg)
begin
  if sipo_clear='1' then
    case compare_reg is
      when "100" =>     sipo_clear1<='1';
      when "010" =>     sipo_clear2<='1';
      when "001" =>     sipo_clear3<='1';
      when others =>    null;
    end case;
  else
    sipo_clear1<='0';
    sipo_clear2<='0';
    sipo_clear3<='0';
  end if ;
end process;  


sipo_1: sipo
 generic map (DIM=>NOC_FLIT_SIZE+6)
 port map (
   clk          =>tclk,
   clear        =>sipo_clear1,
   en_in        =>sipo_en_in1,
   en_out       =>sipo_en_out1,
   en_comp      =>en_sipo_comp,
   serial_in    =>tdi1,
   test_comp    =>sipo_comp1,
   data_out     =>test2_in,
   op           =>op1,
   done         =>sipo_done1);

sipo_2: sipo
 generic map (DIM=>NOC_FLIT_SIZE+6)
 port map (
   clk          =>tclk,
   clear        =>sipo_clear2,
   en_in        =>sipo_en_in2,
   en_out       =>sipo_en_out2,
   en_comp      =>en_sipo_comp,
   serial_in    =>tdi2,
   test_comp    =>sipo_comp2,
   data_out     =>test3_in,
   op           =>op2,
   done         =>sipo_done2);


sipo_3: sipo
 generic map (DIM=>NOC_FLIT_SIZE+6)
 port map (
   clk          =>tclk,
   clear        =>sipo_clear3,
   en_in        =>sipo_en_in3,
   en_out       =>sipo_en_out3,
   en_comp      =>en_sipo_comp,
   serial_in    =>tdi3,
   test_comp    =>sipo_comp3,
   data_out     =>test5_in,
   op           =>op3,
   done         =>sipo_done3);


demux_1to3_1: demux_1to3
port map(
  data_in =>tdi,
  sel     =>demux_sel, --
  out1   =>tdi1,
  out2   =>tdi2,
  out3   =>tdi3);

test5_in_bis<=test5_in(NOC_FLIT_SIZE downto 1);
  
--testing muxs

--A_in<=test1_in(66 downto 1);

--from NoC pplane 2

rd_i2<=not(noc2_cpu_stop_in);

async_fifo_0: async_fifo
  generic map (
    g_data_width => NOC_FLIT_SIZE+1,
    g_size       => 8)
  port map (
    rst_n_i    => rst,
    clk_wr_i   => tclk,
    we_i       => sipo_en_out,
    d_i        => test2_in(NOC_FLIT_SIZE downto 0),
    wr_full_o  => fwd_wr_full_o2,
    clk_rd_i   => refclk,
    rd_i       => rd_i2,
    q_o        => test2_in_sync,
    rd_empty_o => fwd_rd_empty_o2);



mux_2to1_1:mux_2to1
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test2_in_sync(NOC_FLIT_SIZE downto 1),
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
    d_i        => test3_in(NOC_FLIT_SIZE downto 0),
    wr_full_o  => fwd_wr_full_o3,
    clk_rd_i   => refclk,
    rd_i       => rd_i3,
    q_o        => test3_in_sync,
    rd_empty_o => fwd_rd_empty_o3);



mux_2to1_2:mux_2to1
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test3_in_sync(NOC_FLIT_SIZE downto 1),
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
    d_i        => test5_in(34 downto 0),
    wr_full_o  => fwd_wr_full_o5,
    clk_rd_i   => refclk,
    rd_i       => rd_i5,
    q_o        => test5_in_sync,
    rd_empty_o => fwd_rd_empty_o5);


mux_2to1_3:mux_2to1
  generic map(sz=>MISC_NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test5_in_sync(34 downto 1),
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
    d_i        => test6_in(NOC_FLIT_SIZE downto 0),
    wr_full_o  => fwd_wr_full_o6,
    clk_rd_i   => refclk,
    rd_i       => rd_i6,
    q_o        => test6_in_sync,
    rd_empty_o => fwd_rd_empty_o6);



mux_2to1_4:mux_2to1
  generic map(sz=>NOC_FLIT_SIZE)
  port map(
    sel=>sel,
    A=>test6_in_sync(NOC_FLIT_SIZE downto 1),
    B=>noc3_output_port,
    X=>test6_output_port);

mux2to1_4:mux2to1
  port map(
    sel=>sel,
    A=>fwd_rd_empty_o6,
    B=>noc6_cpu_data_void_out,
    X=>test6_cpu_data_void_out);



  void_flag<=((not(tonoc5_cpu_data_void_in)) or  (not(tonoc3_cpu_data_void_in)) or (not(tonoc1_cpu_data_void_in)));

--set_stop :process(stop_in)
--begin
--  if stop_in='0' then
--    noc1_stop_out_test<='0';
--    noc3_stop_out_test<='0';
--    noc5_stop_out_test<='0';
--  else
--    noc1_stop_out_test<='1';
--    noc3_stop_out_test<='1';
--    noc5_stop_out_test<='1';
--  end if ;
--end process set_stop;



  testselout: process(sipo_comp,void_flag,tonoc5_cpu_data_void_in,tonoc3_cpu_data_void_in,tonoc1_cpu_data_void_in)
  begin
      if (tonoc5_cpu_data_void_in='0') then 
        test_sel_out<="001";
      elsif (tonoc1_cpu_data_void_in='0') then
        test_sel_out<="100";
      elsif (tonoc3_cpu_data_void_in='0') then
       test_sel_out<="010";        
      else
        test_sel_out<="000";
      end if;
    
    
  end process testselout;

  process(compare_reg,sipo_comp1,sipo_comp2,sipo_comp3)
  begin
    case compare_reg is
      when "100" => sipo_comp<=sipo_comp1(NOC_FLIT_SIZE+5 downto 2);
      when "010" => sipo_comp<=sipo_comp2(NOC_FLIT_SIZE+5 downto 2);
      when "001" => sipo_comp<=sipo_comp3(NOC_FLIT_SIZE+5 downto 2);
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
  
  --rst_sync5<= (flag2 and rst and not(fwd_rd_empty_o5out) and not(we_in5_out)) or we_in5_out;
  rd_i1_out<=not(noc1_stop_out_test);
  noc1_in_ext<=t1_out & t1_cpu_data_void_in ; --noc1_in_port & tonoc1_cpu_data_void_in;
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

  --rst_sync5<= (flag2 and rst and not(fwd_rd_empty_o5out) and not(we_in5_out)) or we_in5_out;
  rd_i3_out<=not(noc3_stop_out_test);
  noc3_in_ext<=t3_out & t3_cpu_data_void_in ; --noc1_in_port & tonoc1_cpu_data_void_in;
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

  --rst_sync5<= (flag2 and rst and not(fwd_rd_empty_o5out) and not(we_in5_out)) or we_in5_out;
  rd_i4_out<=not(noc4_stop_out_test);
  noc4_in_ext<=t4_out & t4_cpu_data_void_in ; --noc1_in_port & tonoc1_cpu_data_void_in;
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


  --rst_sync5<= (flag2 and rst and not(fwd_rd_empty_o5out) and not(we_in5_out)) or we_in5_out;
  rd_i5_out<=not(noc5_stop_out_test);
  noc5_in_ext<=t5_out & t5_cpu_data_void_in ; --noc1_in_port & tonoc1_cpu_data_void_in;
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
  C<=noc_flit_pad & test5_out & test5_cpu_data_void_in;

  
mux_3to1_1:mux_3to1
  generic map(sz=>NOC_FLIT_SIZE+1)
  port map(
    sel=>compare_reg,
    A=>A,
    B=>B,
    C=>C,
    X=>test_out);

  piso_in<=test_out & compare_reg;


piso_0:piso
 generic map(sz=>3 )
 port map(
   clk=>tclk,
   load=> piso_load0,
   A=>compare_reg,
   shift_en=>piso_en0,
   B=>test_compare0,
   Y=>tdo_data0,
   done=>piso_done0);
  
  
  
piso_1:piso
 generic map(sz=>NOC_FLIT_SIZE+4 )
 port map(
   clk=>tclk,
   load=> piso_load,
   A=>piso_in,
   shift_en=>piso_en,
   B=>test_compare,
   Y=>tdo_data,
   done=>piso_done);
  
end;
