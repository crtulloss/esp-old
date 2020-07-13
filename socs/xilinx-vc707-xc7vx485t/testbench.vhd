-----------------------------------------------------------------------------
--  Testbench for ESP on Xilinx VC707
------------------------------------------------------------------------------

library ieee;
library std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;



use ieee.std_logic_1164.all;
use work.libdcom.all;
use work.sim.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;

use work.grlib_config.all;

entity testbench is
end;

architecture behav of testbench is

  constant SIMULATION      : boolean := true;

  component top is
    generic (
      SIMULATION      : boolean);
    port (
      reset        : in    std_ulogic;
      sys_clk_p    : in    std_ulogic;
      sys_clk_n    : in    std_ulogic;


      tdi          : in    std_logic;
      tdo          : out   std_logic;
      tclk         : in    std_logic;
      tms          : in    std_logic;
      next_in      : out   std_logic;

      ddr3_dq      : inout std_logic_vector(63 downto 0);
      ddr3_dqs_p   : inout std_logic_vector(7 downto 0);
      ddr3_dqs_n   : inout std_logic_vector(7 downto 0);
      ddr3_addr    : out   std_logic_vector(13 downto 0);
      ddr3_ba      : out   std_logic_vector(2 downto 0);
      ddr3_ras_n   : out   std_logic;
      ddr3_cas_n   : out   std_logic;
      ddr3_we_n    : out   std_logic;
      ddr3_reset_n : out   std_logic;
      ddr3_ck_p    : out   std_logic_vector(0 downto 0);
      ddr3_ck_n    : out   std_logic_vector(0 downto 0);
      ddr3_cke     : out   std_logic_vector(0 downto 0);
      ddr3_cs_n    : out   std_logic_vector(0 downto 0);
      ddr3_dm      : out   std_logic_vector(7 downto 0);
      ddr3_odt     : out   std_logic_vector(0 downto 0);
      gtrefclk_p   : in    std_logic;
      gtrefclk_n   : in    std_logic;
      txp          : out   std_logic;
      txn          : out   std_logic;
      rxp          : in    std_logic;
      rxn          : in    std_logic;
      emdio        : inout std_logic;
      emdc         : out   std_ulogic;
      eint         : in    std_ulogic;
      erst         : out   std_ulogic;
      uart_rxd     : in    std_ulogic;
      uart_txd     : out   std_ulogic;
      uart_ctsn    : in    std_ulogic;
      uart_rtsn    : out   std_ulogic;
      button       : in    std_logic_vector(3 downto 0);
      switch       : inout std_logic_vector(4 downto 0);
      led          : out   std_logic_vector(6 downto 0));
  end component top;


  -- Bein TOP-level interface --


  -- Reset and clocl
  signal reset     : std_ulogic := '1';
  signal sys_clk_p : std_ulogic := '0';
  signal sys_clk_n : std_ulogic := '1';


  signal tclk      : std_logic := '0';
  signal tms       : std_logic  := '0';
  signal tdi       : std_logic;
  signal tdo       : std_logic;
  signal next_in  : std_logic;

  
  -- DDR3
  signal ddr3_dq      : std_logic_vector(63 downto 0);
  signal ddr3_dqs_p   : std_logic_vector(7 downto 0);
  signal ddr3_dqs_n   : std_logic_vector(7 downto 0);
  signal ddr3_addr    : std_logic_vector(13 downto 0);
  signal ddr3_ba      : std_logic_vector(2 downto 0);
  signal ddr3_ras_n   : std_logic;
  signal ddr3_cas_n   : std_logic;
  signal ddr3_we_n    : std_logic;
  signal ddr3_reset_n : std_logic;
  signal ddr3_ck_p    : std_logic_vector(0 downto 0);
  signal ddr3_ck_n    : std_logic_vector(0 downto 0);
  signal ddr3_cke     : std_logic_vector(0 downto 0);
  signal ddr3_cs_n    : std_logic_vector(0 downto 0);
  signal ddr3_dm      : std_logic_vector(7 downto 0);
  signal ddr3_odt     : std_logic_vector(0 downto 0);

  -- SGMII Ethernet
  signal gtrefclk_p : std_logic := '0';
  signal gtrefclk_n : std_logic := '1';
  signal txp        : std_logic;
  signal txn        : std_logic;
  signal rxp        : std_logic;
  signal rxn        : std_logic;
  signal emdio      : std_logic;
  signal emdc       : std_ulogic;
  signal eint       : std_ulogic;
  signal erst       : std_ulogic;

  -- UART
  signal uart_rxd  : std_ulogic;
  signal uart_txd  : std_ulogic;
  signal uart_ctsn : std_ulogic;
  signal uart_rtsn : std_ulogic;

  -- GPIO
  signal button : std_logic_vector(3 downto 0);
  signal switch : std_logic_vector(4 downto 0);
  signal led    : std_logic_vector(6 downto 0);

  signal testin: std_logic_vector(71 downto 0);
  signal source : std_logic_vector(2 downto 0);
  signal waittime,instr_n: integer;
   

  
  -- End TOP-level interface --

begin

  -- clock and reset
  reset     <= '0'           after 2500 ns;
  sys_clk_p <= not sys_clk_p after 2.5 ns;
  sys_clk_n <= not sys_clk_n after 2.5 ns;

  tclk <= not tclk after 20 ns;                       --aumenta clock

  tms   <= '1'               after 2740 ns;
  -- jtag inout



  PROC_SEQUENCER : process
    file text_file1 : text open read_mode is "/home/gabriele/epochs2/esp/socs/xilinx-vc707-xc7vx485t/stim1.txt";
    file text_file2 : text open read_mode is "/home/gabriele/epochs2/esp/socs/xilinx-vc707-xc7vx485t/stim2.txt";
    file text_file3 : text open read_mode is "/home/gabriele/epochs2/esp/socs/xilinx-vc707-xc7vx485t/stim3.txt";
    file out_file : text open write_mode is "test_out.txt";
    variable text_line :line ;
    variable out_line :line;
    variable ok : boolean;
    variable char : character;
    variable instr_no : integer;
    variable wait_time : integer;
    variable instruction : bit_vector(71 downto 0);
    variable instr_out   : bit_vector(69 downto 0);

  begin

    wait until tms='1';
    readline(text_file1, text_line);
    read(text_line, instr_no,ok);
    read(text_line, wait_time,ok);
    read(text_line,instruction,ok);
    instr_n<=instr_no;
    waittime<=wait_time;
    testin<=To_StdLogicVector(instruction);
    wait until next_in='1';
    for i in 0 to 71  loop
      tdi<=testin(i);
      wait for 40 ns;
    end loop;
    wait for 40 ns;

    readline(text_file2, text_line);
    read(text_line, instr_no,ok);
    read(text_line, wait_time,ok);
    read(text_line,instruction,ok);
    instr_n<=instr_no;
    waittime<=wait_time;
    testin<=To_StdLogicVector(instruction);
    for i in 0 to 71  loop
      tdi<=testin(i);
      wait for 40 ns;
    end loop;

    wait for 40 ns;

    readline(text_file3, text_line);
    read(text_line, instr_no,ok);
    read(text_line, wait_time,ok);
    read(text_line,instruction,ok);
    instr_n<=instr_no;
    waittime<=wait_time;
    testin<=To_StdLogicVector(instruction);

    for i in 0 to 70  loop
      tdi<=testin(i);
      wait for 40 ns;
    end loop;
    tdi<=testin(71);


    wait until tdo='1';
    wait until tdo='0';

    wait for 10 ns;

    for i in 0 to 66 loop
      write(out_line,to_bit(tdo));
      wait for 40 ns;
    end loop;

    for i in 0 to 2 loop
      write(out_line,to_bit(tdo));
      source(2-i)<=tdo;
      wait for 40 ns;
    end loop;

    writeline(out_file,out_line);


    while not ((endfile(text_file1)) and endfile(text_file2) and endfile(text_file3)) loop


      wait until next_in='1';

      assert next_in='0' report "while loop entered"  severity note;

      case source is
        when "100" => readline(text_file1, text_line);
        when "010" => readline(text_file2, text_line);
        when "001" => readline(text_file3, text_line);
        when others=> null;
      end case;



      read(text_line, instr_no,ok);
      read(text_line, wait_time,ok);
      read(text_line,instruction,ok);
      waittime<=wait_time;
      testin<=To_StdLogicVector(instruction);

      for i in 0 to 71  loop
        tdi<=testin(i);
        wait for 40 ns;
      end loop;

      wait for 130 ns;   --3 clock cycles

      if tdo='1' then

        assert tdo='0' report "--------if1 entered"  severity note;

        wait until tdo='0';
        wait for 10 ns;

        for i in 0 to 66 loop
          write(out_line,to_bit(tdo));
          wait for 40 ns;
        end loop;

        for i in 0 to 2 loop
          write(out_line,to_bit(tdo));
          source(2-i)<=tdo;
          wait for 40 ns;
        end loop;

        writeline(out_file,out_line);

      else
        wait for 50 ns;            --one clock cycle

        if tdo='1' then

          assert tdo='0' report "------------------if5 entered"  severity note;

          wait until tdo='0';
          wait for 2 ns;

          for i in 0 to 66 loop
            write(out_line,to_bit(tdo));
            wait for 40 ns;
          end loop;

          for i in 0 to 2 loop
            write(out_line,to_bit(tdo));
            source(2-i)<=tdo;
            wait for 40 ns;
          end loop;

          assert tdo='1' report "write5"  severity note;
          writeline(out_file,out_line);

        else

          assert tdo='1' report "////// writein entered" severity note;

          wait for 40 ns;

          for i in 0 to 2 loop
            source(2-i)<=tdo;
            wait for 40 ns;
          end loop;

        end if;
      end if;
    end loop;

  end process;


  
  -- DDR3
  ddr3_dq    <= (others => 'Z');
  ddr3_dqs_p <= (others => 'Z');
  ddr3_dqs_n <= (others => 'Z');


  -- Ethernet (There is no behavioral testbench for the SGMII PHY)
  gtrefclk_p <= not gtrefclk_p after 4 ns;
  gtrefclk_n <= not gtrefclk_n after 4 ns;
  rxp        <= '0';
  rxn        <= '1';
  emdio      <= 'H';
  eint       <= '0';

  -- UART
  uart_rxd  <= '0';
  uart_ctsn <= '0';

  -- Switches
  button <= (others => '0');
  switch <= (others => '0');


  top_1 : entity work.top
    generic map (
      SIMULATION      => SIMULATION)
    port map (
      reset        => reset,
      sys_clk_p    => sys_clk_p,
      sys_clk_n    => sys_clk_n,

      tdi          => tdi,
      tdo          => tdo,
      tclk         => tclk,
      tms          => tms,
      next_in      => next_in,
            
      ddr3_dq      => ddr3_dq,
      ddr3_dqs_p   => ddr3_dqs_p,
      ddr3_dqs_n   => ddr3_dqs_n,
      ddr3_addr    => ddr3_addr,
      ddr3_ba      => ddr3_ba,
      ddr3_ras_n   => ddr3_ras_n,
      ddr3_cas_n   => ddr3_cas_n,
      ddr3_we_n    => ddr3_we_n,
      ddr3_reset_n => ddr3_reset_n,
      ddr3_ck_p    => ddr3_ck_p,
      ddr3_ck_n    => ddr3_ck_n,
      ddr3_cke     => ddr3_cke,
      ddr3_cs_n    => ddr3_cs_n,
      ddr3_dm      => ddr3_dm,
      ddr3_odt     => ddr3_odt,
      gtrefclk_p   => gtrefclk_p,
      gtrefclk_n   => gtrefclk_n,
      txp          => txp,
      txn          => txn,
      rxp          => rxp,
      rxn          => rxn,
      emdio        => emdio,
      emdc         => emdc,
      eint         => eint,
      erst         => erst,
      uart_rxd     => uart_rxd,
      uart_txd     => uart_txd,
      uart_ctsn    => uart_ctsn,
      uart_rtsn    => uart_rtsn,
      button       => button,
      switch       => switch,
      led          => led);

end;

