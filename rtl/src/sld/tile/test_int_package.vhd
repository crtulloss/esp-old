
library ieee;
use ieee.std_logic_1164.all;
use work.nocpackage.all;
use work.sldcommon.all;


package test_int_package is


  --components
 



  component async_fifo
    generic (
      g_data_width : natural := NOC_FLIT_SIZE;
      g_size       : natural := 6);
    port (
      rst_n_i    : in  std_logic := '1';
      clk_wr_i   : in  std_logic;
      we_i       : in  std_logic;
      d_i        : in  std_logic_vector(g_data_width-1 downto 0);
      wr_full_o  : out std_logic;
      clk_rd_i   : in  std_logic;
      rd_i       : in  std_logic;
      q_o        : out std_logic_vector(g_data_width-1 downto 0);
      rd_empty_o : out std_logic);
  end component;
  
  

  component sipo 
    generic (DIM: integer);
    port(
      clk      : in std_logic;
      clear    : in std_logic;
      en_in    : in std_logic;
      serial_in: in std_logic;
      en_out   : in std_logic;
      en_comp  : in std_logic;
      test_comp: out std_logic_vector(DIM-3 downto 0);
      data_out : out std_logic_vector(DIM-6 downto 0);
      op       : out std_logic;
      done     : out std_logic);
  end component sipo;

  
        
  
  component demux_1to6
    port(
      data_in: in std_logic;
      sel: in std_logic_vector(5 downto 0);
      out1: out std_logic;
      out2: out std_logic;
      out3: out std_logic;
      out4: out std_logic;
      out5: out std_logic;
      out6: out std_logic);
  end component demux_1to6;


  component mux_4to1 
      generic (sz: integer);
      port
        ( sel : in  std_logic_vector(5 downto 0);
          A   : in  std_logic_vector (sz-1 downto 0);
          B   : in  std_logic_vector (sz-1 downto 0);
          C   : in  std_logic_vector (sz-1 downto 0);
          D   : in  std_logic_vector (sz-1 downto 0);
          X   : out std_logic_vector (sz-1 downto 0));
    end component mux_4to1;
        
 
  component mux_2to1 
    generic (sz: integer);
    port
      ( sel : in  std_logic;
        A   : in  std_logic_vector (sz-1 downto 0);
        B   : in  std_logic_vector (sz-1 downto 0);
        X   : out std_logic_vector (sz-1 downto 0));
  end component mux_2to1;


  component mux2to1 
    port
      ( sel : in  std_logic;
        A   : in  std_logic;
        B   : in  std_logic;
        X   : out std_logic);
  end component mux2to1;


  component demux_1to2
    generic(sz:integer );
    port(
      data_in: in std_logic_vector(sz-1 downto 0);
      sel: in std_logic;
      out1,out2: out std_logic_vector(sz-1 downto 0));
  end component demux_1to2;


  component demux1to2 
    port(
      data_in: in std_logic;
      sel: in std_logic;
      out1,out2: out std_logic);
  end component demux1to2;

  component piso
    generic (sz:integer);
    port ( clk :  in   std_logic;
           load : in   std_logic;
           A :    in   std_logic_vector(sz-1 downto 0);
           shift_en: in std_logic;
           B:     out std_logic_vector(sz-2 downto 0);
           Y :    out  std_logic;
           done:  out  std_logic);
  end component piso;

  component sipo1 
  generic (DIM: integer);
  port(
    clk,clear: in std_logic;
    en_in    : in std_logic;
    serial_in: in std_logic;
    en_out   : in std_logic;
    dirty    : out std_logic;
    data_out : out std_logic_vector(DIM-2 downto 0));
  end component sipo1;

end package test_int_package;
