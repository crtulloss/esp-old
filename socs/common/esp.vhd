-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.sldcommon.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.soctiles.all;

entity esp is
  generic (
    SIMULATION : boolean := false);
  port (
    rst             : in    std_logic;
    sys_clk         : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
    refclk          : in    std_logic;
    pllbypass       : in    std_logic_vector(CFG_TILES_NUM - 1 downto 0);
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    cpuerr          : out   std_logic;
    ddr_ahbsi      : out ahb_slv_in_vector_type(0 to CFG_NMEM_TILE - 1);
    ddr_ahbso      : in  ahb_slv_out_vector_type(0 to CFG_NMEM_TILE - 1);
    eth0_apbi       : out apb_slv_in_type;
    eth0_apbo       : in  apb_slv_out_type;
    sgmii0_apbi     : out apb_slv_in_type;
    sgmii0_apbo     : in  apb_slv_out_type;
    eth0_ahbmi      : out ahb_mst_in_type;
    eth0_ahbmo      : in  ahb_mst_out_type;
    edcl_ahbmo      : in  ahb_mst_out_type;
    dvi_apbi        : out apb_slv_in_type;
    dvi_apbo        : in  apb_slv_out_type;
    dvi_ahbmi       : out ahb_mst_in_type;
    dvi_ahbmo       : in  ahb_mst_out_type;
    -- Monitor signals
    mon_noc         : out monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
    mon_acc         : out monitor_acc_vector(0 to relu(accelerators_num-1));
    mon_mem         : out monitor_mem_vector(0 to CFG_NMEM_TILE - 1);
    mon_l2          : out monitor_cache_vector(0 to relu(CFG_NL2 - 1));
    mon_llc         : out monitor_cache_vector(0 to relu(CFG_NLLC - 1));
    mon_dvfs        : out monitor_dvfs_vector(0 to CFG_TILES_NUM-1));
end;


architecture rtl of esp is

----------------------------------------------------------------------------------------------
-- SYNC_NOC_XY AND SYNC_NOC32_XY are going to be instanciated in the tiles
----------------------------------------------------------------------------------------------
--  component sync_noc_xy
--    generic (
--      PORTS     : std_logic_vector(4 downto 0);
--      local_x   : std_logic_vector(2 downto 0);
--      local_y   : std_logic_vector(2 downto 0);
--      has_sync  : integer range 0 to 1);
--    port (
--      clk           : in  std_logic;
--      clk_tile      : in  std_logic;
--      rst           : in  std_logic;
--      data_n_in     : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_s_in     : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_w_in     : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_e_in     : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      input_port    : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_void_in  : in  std_logic_vector(4 downto 0);
--      stop_in       : in  std_logic_vector(4 downto 0);
--      data_n_out    : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_s_out    : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_w_out    : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_e_out    : in  std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      output_port   : out std_logic_vector(NOC_FLIT_SIZE-1 downto 0);
--      data_void_out : out std_logic_vector(4 downto 0);
--      stop_out      : out std_logic_vector(4 downto 0);
      -- Monitor output. Can be left unconnected
--      mon_noc       : out monitor_noc_type
--      );
--  end component;

  component sync_noc32_xy
    generic (
      XLEN      : integer;
      YLEN      : integer;
      TILES_NUM : integer;
      has_sync  : integer range 0 to 1);
    port (
      clk           : in  std_logic;
      clk_tile      : in  std_logic_vector(TILES_NUM-1 downto 0);
      rst           : in  std_logic;
      input_port    : in  misc_noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_in  : in  std_logic_vector(TILES_NUM-1 downto 0);
      stop_in       : in  std_logic_vector(TILES_NUM-1 downto 0);
      output_port   : out misc_noc_flit_vector(TILES_NUM-1 downto 0);
      data_void_out : out std_logic_vector(TILES_NUM-1 downto 0);
      stop_out      : out std_logic_vector(TILES_NUM-1 downto 0);
      -- Monitor output. Can be left unconnected
      mon_noc       : out monitor_noc_vector(0 to TILES_NUM-1)
      );
  end component;

  constant nocs_num : integer := 6;

signal clk_tile : std_logic_vector(CFG_TILES_NUM-1 downto 0);
type noc_ctrl_matrix is array (1 to nocs_num) of std_logic_vector(CFG_TILES_NUM-1 downto 0);

signal noc_input_port_1  : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_input_port_2  : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_input_port_3  : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_input_port_4  : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_input_port_5  : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_input_port_6  : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_data_void_in  : noc_ctrl_matrix;
signal noc_stop_in       : noc_ctrl_matrix;
signal noc_output_port_1 : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_output_port_2 : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_output_port_3 : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_output_port_4 : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_output_port_5 : misc_noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_output_port_6 : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
signal noc_data_void_out : noc_ctrl_matrix;
signal noc_stop_out      : noc_ctrl_matrix;

signal rst_int       : std_logic;
signal srst          : std_logic;
signal sys_clk_int   : std_logic_vector(0 to CFG_NMEM_TILE - 1);
signal refclk_int    : std_logic_vector(CFG_TILES_NUM -1 downto 0);
signal pllbypass_int : std_logic_vector(CFG_TILES_NUM - 1 downto 0);
signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)
signal cpuerr_vec    : std_logic_vector(0 to CFG_NCPU_TILE-1);

type monitor_noc_cast_vector is array (1 to nocs_num) of monitor_noc_vector(0 to CFG_TILES_NUM-1);
signal mon_noc_vec : monitor_noc_cast_vector;
signal mon_dvfs_out : monitor_dvfs_vector(0 to CFG_TILES_NUM-1);
signal mon_dvfs_domain  : monitor_dvfs_vector(0 to CFG_TILES_NUM-1);

signal mon_l2_int : monitor_cache_vector(0 to CFG_TILES_NUM-1);
signal mon_llc_int : monitor_cache_vector(0 to CFG_TILES_NUM-1);

-- TODO: remove this; IRQ will flow through the NoC
signal irq : std_logic_vector(CFG_NCPU_TILE * 2 - 1 downto 0);
signal timer_irq : std_logic_vector(CFG_NCPU_TILE - 1 downto 0);
signal ipi : std_logic_vector(CFG_NCPU_TILE - 1 downto 0);

begin

  rst_int <= rst;
  clk_int_gen: for i in 0 to CFG_NMEM_TILE - 1 generate
    sys_clk_int(i) <= sys_clk(i);
  end generate clk_int_gen;
  pllbypass_int <= pllbypass;

  cpuerr <= cpuerr_vec(0);

  -----------------------------------------------------------------------------
  -- UART pads
  -----------------------------------------------------------------------------

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => CFG_PADTECH) port map (uart_rtsn, uart_rtsn_int);


  -----------------------------------------------------------------------------
  -- DVFS domain probes steering
  -----------------------------------------------------------------------------
  domain_in_gen: for i in 0 to CFG_TILES_NUM-1 generate
    mon_dvfs_domain(i).clk <= '0';
    mon_dvfs_domain(i).transient <= mon_dvfs_out(tile_domain_master(i)).transient;
    mon_dvfs_domain(i).vf <= mon_dvfs_out(tile_domain_master(i)).vf;

    no_domain_master: if tile_domain(i) /= 0 and tile_has_pll(i) = 0 generate
      mon_dvfs_domain(i).acc_idle <= mon_dvfs_domain(tile_domain_master(i)).acc_idle;
      mon_dvfs_domain(i).traffic <= mon_dvfs_domain(tile_domain_master(i)).traffic;
      mon_dvfs_domain(i).burst <= mon_dvfs_domain(tile_domain_master(i)).burst;
      refclk_int(i) <= clk_tile(tile_domain_master(i));
    end generate no_domain_master;

    domain_master_gen: if tile_domain(i) = 0 or tile_has_pll(i) /= 0 generate
      refclk_int(i) <= refclk;
    end generate domain_master_gen;

  end generate domain_in_gen;

  domain_probes_gen: for k in 1 to domains_num-1 generate
    -- DVFS masters need info from slave DVFS tiles
    process (mon_dvfs_out)
      variable mon_dvfs_or : monitor_dvfs_type;
    begin  -- process
      mon_dvfs_or.acc_idle := '1';
      mon_dvfs_or.traffic := '0';
      mon_dvfs_or.burst := '0';
      for i in 0 to CFG_TILES_NUM-1 loop
        if tile_domain(i) = k then
          mon_dvfs_or.acc_idle := mon_dvfs_or.acc_idle and mon_dvfs_out(i).acc_idle;
          mon_dvfs_or.traffic := mon_dvfs_or.traffic or mon_dvfs_out(i).traffic;
          mon_dvfs_or.burst := mon_dvfs_or.burst or mon_dvfs_out(i).burst;
        end if;
      end loop;  -- i
      mon_dvfs_domain(domain_master_tile(k)).acc_idle <= mon_dvfs_or.acc_idle;
      mon_dvfs_domain(domain_master_tile(k)).traffic <= mon_dvfs_or.traffic;
      mon_dvfs_domain(domain_master_tile(k)).burst <= mon_dvfs_or.burst;
    end process;
  end generate domain_probes_gen;

  mon_dvfs <= mon_dvfs_out;

  -----------------------------------------------------------------------------
  -- NOC CONNECTIONS
  -----------------------------------------------------------------------------

  type handshake_vec is array (CFG_TILES_NUM-1 downto 0) of std_logic_vector(3 downto 0);


  signal noc1_data_n_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_s_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_w_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_e_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_in_i  : handshake_vec;
  signal noc1_stop_in_i       : handshake_vec;
  signal noc1_data_n_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_s_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_w_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_e_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc1_data_void_out_i : handshake_vec;
  signal noc1_stop_out_i      : handshake_vec;
  signal noc2_data_n_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_s_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_w_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_e_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_in_i  : handshake_vec;
  signal noc2_stop_in_i       : handshake_vec;
  signal noc2_data_n_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_s_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_w_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_e_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc2_data_void_out_i : handshake_vec;
  signal noc2_stop_out_i      : handshake_vec;
  signal noc3_data_n_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_s_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_w_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_e_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_in_i  : handshake_vec;
  signal noc3_stop_in_i       : handshake_vec;
  signal noc3_data_n_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_s_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_w_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_e_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc3_data_void_out_i : handshake_vec;
  signal noc3_stop_out_i      : handshake_vec;
  signal noc4_data_n_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_s_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_w_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_e_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_in_i  : handshake_vec;
  signal noc4_stop_in_i       : handshake_vec;
  signal noc4_data_n_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_s_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_w_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_e_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc4_data_void_out_i : handshake_vec;
  signal noc4_stop_out_i      : handshake_vec;
  signal noc5_data_n_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_s_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_w_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_e_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_in_i  : handshake_vec;
  signal noc5_stop_in_i       : handshake_vec;
  signal noc5_data_n_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_s_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_w_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_e_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc5_data_void_out_i : handshake_vec;
  signal noc5_stop_out_i      : handshake_vec;
  signal noc6_data_n_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_s_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_w_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_e_in       : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_in_i  : handshake_vec;
  signal noc6_stop_in_i       : handshake_vec;
  signal noc6_data_n_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_s_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_w_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_e_out      : noc_flit_vector(CFG_TILES_NUM-1 downto 0);
  signal noc6_data_void_out_i : handshake_vec;
  signal noc6_stop_out_i      : handshake_vec;

  meshgen_y: for i in 0 to YLEN-1 generate
    meshgen_x: for j in 0 to XLEN-1 generate

      y_0: if (i=0) generate
        -- North port is unconnected
        noc1_data_n_in(i*XLEN + j) <= (others => '0');
        noc1_data_void_in_i(i*XLEN + j)(0) <= '1';
        noc1_stop_in_i(i*XLEN + j)(0) <= '0';
        noc2_data_n_in(i*XLEN + j) <= (others => '0');
        noc2_data_void_in_i(i*XLEN + j)(0) <= '1';
        noc2_stop_in_i(i*XLEN + j)(0) <= '0';
        noc3_data_n_in(i*XLEN + j) <= (others => '0');
        noc3_data_void_in_i(i*XLEN + j)(0) <= '1';
        noc3_stop_in_i(i*XLEN + j)(0) <= '0';
        noc4_data_n_in(i*XLEN + j) <= (others => '0');
        noc4_data_void_in_i(i*XLEN + j)(0) <= '1';
        noc4_stop_in_i(i*XLEN + j)(0) <= '0';
        noc5_data_n_in(i*XLEN + j) <= (others => '0');
        noc5_data_void_in_i(i*XLEN + j)(0) <= '1';
        noc5_stop_in_i(i*XLEN + j)(0) <= '0';
        noc6_data_n_in(i*XLEN + j) <= (others => '0');
        noc6_data_void_in_i(i*XLEN + j)(0) <= '1';
        noc6_stop_in_i(i*XLEN + j)(0) <= '0';
      end generate y_0;

      y_non_0: if (i /= 0) generate
        -- North port is connected
        noc1_data_n_in(i*XLEN + j)         <= noc1_data_s_out((i-1)*XLEN + j);
        noc1_data_void_in_i(i*XLEN + j)(0) <= noc1_data_void_out_i((i-1)*XLEN + j)(1);
        noc1_stop_in_i(i*XLEN + j)(0)      <= noc1_stop_out_i((i-1)*XLEN + j)(1);
        noc2_data_n_in(i*XLEN + j)         <= noc2_data_s_out((i-1)*XLEN + j);
        noc2_data_void_in_i(i*XLEN + j)(0) <= noc2_data_void_out_i((i-1)*XLEN + j)(1);
        noc2_stop_in_i(i*XLEN + j)(0)      <= noc2_stop_out_i((i-1)*XLEN + j)(1);
        noc3_data_n_in(i*XLEN + j)         <= noc3_data_s_out((i-1)*XLEN + j);
        noc3_data_void_in_i(i*XLEN + j)(0) <= noc3_data_void_out_i((i-1)*XLEN + j)(1);
        noc3_stop_in_i(i*XLEN + j)(0)      <= noc3_stop_out_i((i-1)*XLEN + j)(1);
        noc4_data_n_in(i*XLEN + j)         <= noc4_data_s_out((i-1)*XLEN + j);
        noc4_data_void_in_i(i*XLEN + j)(0) <= noc4_data_void_out_i((i-1)*XLEN + j)(1);
        noc4_stop_in_i(i*XLEN + j)(0)      <= noc4_stop_out_i((i-1)*XLEN + j)(1);
        noc5_data_n_in(i*XLEN + j)         <= noc5_data_s_out((i-1)*XLEN + j);
        noc5_data_void_in_i(i*XLEN + j)(0) <= noc5_data_void_out_i((i-1)*XLEN + j)(1);
        noc5_stop_in_i(i*XLEN + j)(0)      <= noc5_stop_out_i((i-1)*XLEN + j)(1);
        noc6_data_n_in(i*XLEN + j)         <= noc6_data_s_out((i-1)*XLEN + j);
        noc6_data_void_in_i(i*XLEN + j)(0) <= noc6_data_void_out_i((i-1)*XLEN + j)(1);
        noc6_stop_in_i(i*XLEN + j)(0)      <= noc6_stop_out_i((i-1)*XLEN + j)(1);
      end generate y_non_0;

      y_YLEN: if (i=YLEN-1) generate
        -- South port is unconnected
        noc1_data_s_in(i*XLEN + j) <= (others => '0');
        noc1_data_void_in_i(i*XLEN + j)(1) <= '1';
        noc1_stop_in_i(i*XLEN + j)(1) <= '0';
        noc2_data_s_in(i*XLEN + j) <= (others => '0');
        noc2_data_void_in_i(i*XLEN + j)(1) <= '1';
        noc2_stop_in_i(i*XLEN + j)(1) <= '0';
        noc3_data_s_in(i*XLEN + j) <= (others => '0');
        noc3_data_void_in_i(i*XLEN + j)(1) <= '1';
        noc3_stop_in_i(i*XLEN + j)(1) <= '0';
        noc4_data_s_in(i*XLEN + j) <= (others => '0');
        noc4_data_void_in_i(i*XLEN + j)(1) <= '1';
        noc4_stop_in_i(i*XLEN + j)(1) <= '0';
        noc5_data_s_in(i*XLEN + j) <= (others => '0');
        noc5_data_void_in_i(i*XLEN + j)(1) <= '1';
        noc5_stop_in_i(i*XLEN + j)(1) <= '0';
        noc6_data_s_in(i*XLEN + j) <= (others => '0');
        noc6_data_void_in_i(i*XLEN + j)(1) <= '1';
        noc6_stop_in_i(i*XLEN + j)(1) <= '0';
      end generate y_YLEN;

      y_non_YLEN: if (i /= YLEN-1) generate
        -- south port is connected
        noc1_data_s_in(i*XLEN + j)         <= noc1_data_n_out((i+1)*XLEN + j);
        noc1_data_void_in_i(i*XLEN + j)(1) <= noc1_data_void_out_i((i+1)*XLEN + j)(0);
        noc1_stop_in_i(i*XLEN + j)(1)      <= noc1_stop_out_i((i+1)*XLEN + j)(0);
        noc2_data_s_in(i*XLEN + j)         <= noc2_data_n_out((i+1)*XLEN + j);
        noc2_data_void_in_i(i*XLEN + j)(1) <= noc2_data_void_out_i((i+1)*XLEN + j)(0);
        noc2_stop_in_i(i*XLEN + j)(1)      <= noc2_stop_out_i((i+1)*XLEN + j)(0);
        noc3_data_s_in(i*XLEN + j)         <= noc3_data_n_out((i+1)*XLEN + j);
        noc3_data_void_in_i(i*XLEN + j)(1) <= noc3_data_void_out_i((i+1)*XLEN + j)(0);
        noc3_stop_in_i(i*XLEN + j)(1)      <= noc3_stop_out_i((i+1)*XLEN + j)(0);
        noc4_data_s_in(i*XLEN + j)         <= noc4_data_n_out((i+1)*XLEN + j);
        noc4_data_void_in_i(i*XLEN + j)(1) <= noc4_data_void_out_i((i+1)*XLEN + j)(0);
        noc4_stop_in_i(i*XLEN + j)(1)      <= noc4_stop_out_i((i+1)*XLEN + j)(0);
        noc5_data_s_in(i*XLEN + j)         <= noc5_data_n_out((i+1)*XLEN + j);
        noc5_data_void_in_i(i*XLEN + j)(1) <= noc5_data_void_out_i((i+1)*XLEN + j)(0);
        noc5_stop_in_i(i*XLEN + j)(1)      <= noc5_stop_out_i((i+1)*XLEN + j)(0);
        noc6_data_s_in(i*XLEN + j)         <= noc6_data_n_out((i+1)*XLEN + j);
        noc6_data_void_in_i(i*XLEN + j)(1) <= noc6_data_void_out_i((i+1)*XLEN + j)(0);
        noc6_stop_in_i(i*XLEN + j)(1)      <= noc6_stop_out_i((i+1)*XLEN + j)(0);
      end generate y_non_YLEN;

      x_0: if (j=0) generate
        -- West port is unconnected
        noc1_data_w_in(i*XLEN + j) <= (others => '0');
        noc1_data_void_in_i(i*XLEN + j)(2) <= '1';
        noc1_stop_in_i(i*XLEN + j)(2) <= '0';
        noc2_data_w_in(i*XLEN + j) <= (others => '0');
        noc2_data_void_in_i(i*XLEN + j)(2) <= '1';
        noc2_stop_in_i(i*XLEN + j)(2) <= '0';
        noc3_data_w_in(i*XLEN + j) <= (others => '0');
        noc3_data_void_in_i(i*XLEN + j)(2) <= '1';
        noc3_stop_in_i(i*XLEN + j)(2) <= '0';
        noc4_data_w_in(i*XLEN + j) <= (others => '0');
        noc4_data_void_in_i(i*XLEN + j)(2) <= '1';
        noc4_stop_in_i(i*XLEN + j)(2) <= '0';
        noc5_data_w_in(i*XLEN + j) <= (others => '0');
        noc5_data_void_in_i(i*XLEN + j)(2) <= '1';
        noc5_stop_in_i(i*XLEN + j)(2) <= '0';
        noc6_data_w_in(i*XLEN + j) <= (others => '0');
        noc6_data_void_in_i(i*XLEN + j)(2) <= '1';
        noc6_stop_in_i(i*XLEN + j)(2) <= '0';
      end generate x_0;

      x_non_0: if (j /= 0) generate
        -- West port is connected
        noc1_data_w_in(i*XLEN + j)         <= noc1_data_e_out(i*XLEN + j - 1);
        noc1_data_void_in_i(i*XLEN + j)(2) <= noc1_data_void_out_i(i*XLEN + j - 1)(3);
        noc1_stop_in_i(i*XLEN + j)(2)      <= noc1_stop_out_i(i*XLEN + j - 1)(3);
        noc2_data_w_in(i*XLEN + j)         <= noc2_data_e_out(i*XLEN + j - 1);
        noc2_data_void_in_i(i*XLEN + j)(2) <= noc2_data_void_out_i(i*XLEN + j - 1)(3);
        noc2_stop_in_i(i*XLEN + j)(2)      <= noc2_stop_out_i(i*XLEN + j - 1)(3);
        noc3_data_w_in(i*XLEN + j)         <= noc3_data_e_out(i*XLEN + j - 1);
        noc3_data_void_in_i(i*XLEN + j)(2) <= noc3_data_void_out_i(i*XLEN + j - 1)(3);
        noc3_stop_in_i(i*XLEN + j)(2)      <= noc3_stop_out_i(i*XLEN + j - 1)(3);
        noc4_data_w_in(i*XLEN + j)         <= noc4_data_e_out(i*XLEN + j - 1);
        noc4_data_void_in_i(i*XLEN + j)(2) <= noc4_data_void_out_i(i*XLEN + j - 1)(3);
        noc4_stop_in_i(i*XLEN + j)(2)      <= noc4_stop_out_i(i*XLEN + j - 1)(3);
        noc5_data_w_in(i*XLEN + j)         <= noc5_data_e_out(i*XLEN + j - 1);
        noc5_data_void_in_i(i*XLEN + j)(2) <= noc5_data_void_out_i(i*XLEN + j - 1)(3);
        noc5_stop_in_i(i*XLEN + j)(2)      <= noc5_stop_out_i(i*XLEN + j - 1)(3);
        noc6_data_w_in(i*XLEN + j)         <= noc6_data_e_out(i*XLEN + j - 1);
        noc6_data_void_in_i(i*XLEN + j)(2) <= noc6_data_void_out_i(i*XLEN + j - 1)(3);
        noc6_stop_in_i(i*XLEN + j)(2)      <= noc6_stop_out_i(i*XLEN + j - 1)(3);
      end generate x_non_0;

      x_XLEN: if (j=XLEN-1) generate
        -- East port is unconnected
        noc1_data_e_in(i*XLEN + j) <= (others => '0');
        noc1_data_void_in_i(i*XLEN + j)(3) <= '1';
        noc1_stop_in_i(i*XLEN + j)(3) <= '0';
        noc2_data_e_in(i*XLEN + j) <= (others => '0');
        noc2_data_void_in_i(i*XLEN + j)(3) <= '1';
        noc2_stop_in_i(i*XLEN + j)(3) <= '0';
        noc3_data_e_in(i*XLEN + j) <= (others => '0');
        noc3_data_void_in_i(i*XLEN + j)(3) <= '1';
        noc3_stop_in_i(i*XLEN + j)(3) <= '0';
        noc4_data_e_in(i*XLEN + j) <= (others => '0');
        noc4_data_void_in_i(i*XLEN + j)(3) <= '1';
        noc4_stop_in_i(i*XLEN + j)(3) <= '0';
        noc5_data_e_in(i*XLEN + j) <= (others => '0');
        noc5_data_void_in_i(i*XLEN + j)(3) <= '1';
        noc5_stop_in_i(i*XLEN + j)(3) <= '0';
        noc6_data_e_in(i*XLEN + j) <= (others => '0');
        noc6_data_void_in_i(i*XLEN + j)(3) <= '1';
        noc6_stop_in_i(i*XLEN + j)(3) <= '0';
      end generate x_XLEN;

      x_non_XLEN: if (j /= XLEN-1) generate
        -- East port is connected
        noc1_data_e_in(i*XLEN + j)         <= noc1_data_w_out(i*XLEN + j + 1);
        noc1_data_void_in_i(i*XLEN + j)(3) <= noc1_data_void_out_i(i*XLEN + j + 1)(2);
        noc1_stop_in_i(i*XLEN + j)(3)      <= noc1_stop_out_i(i*XLEN + j + 1)(2);
        noc2_data_e_in(i*XLEN + j)         <= noc2_data_w_out(i*XLEN + j + 1);
        noc2_data_void_in_i(i*XLEN + j)(3) <= noc2_data_void_out_i(i*XLEN + j + 1)(2);
        noc2_stop_in_i(i*XLEN + j)(3)      <= noc2_stop_out_i(i*XLEN + j + 1)(2);
        noc3_data_e_in(i*XLEN + j)         <= noc3_data_w_out(i*XLEN + j + 1);
        noc3_data_void_in_i(i*XLEN + j)(3) <= noc3_data_void_out_i(i*XLEN + j + 1)(2);
        noc3_stop_in_i(i*XLEN + j)(3)      <= noc3_stop_out_i(i*XLEN + j + 1)(2);
        noc4_data_e_in(i*XLEN + j)         <= noc4_data_w_out(i*XLEN + j + 1);
        noc4_data_void_in_i(i*XLEN + j)(3) <= noc4_data_void_out_i(i*XLEN + j + 1)(2);
        noc4_stop_in_i(i*XLEN + j)(3)      <= noc4_stop_out_i(i*XLEN + j + 1)(2);
        noc5_data_e_in(i*XLEN + j)         <= noc5_data_w_out(i*XLEN + j + 1);
        noc5_data_void_in_i(i*XLEN + j)(3) <= noc5_data_void_out_i(i*XLEN + j + 1)(2);
        noc5_stop_in_i(i*XLEN + j)(3)      <= noc5_stop_out_i(i*XLEN + j + 1)(2);
        noc6_data_e_in(i*XLEN + j)         <= noc6_data_w_out(i*XLEN + j + 1);
        noc6_data_void_in_i(i*XLEN + j)(3) <= noc6_data_void_out_i(i*XLEN + j + 1)(2);
        noc6_stop_in_i(i*XLEN + j)(3)      <= noc6_stop_out_i(i*XLEN + j + 1)(2);
      end generate x_non_XLEN;

    end generate meshgen_x;
  end generate meshgen_y;

--------------------------------------------------------------------------------------------------
-- Insert in the nocpackage.vhd
-- Remove the loops and use conditionals of local_x and local_y to find required ports
-- Same port generation must be used in tiles ports
-- This function will go to top and ROUTER_PORTS will be passed through parameter

type ports_vec is array (TILES_NUM-1 downto 0) of std_logic_vector(4 downto 0);

  function set_router_ports(
    constant XLEN : integer;
    constant YLEN : integer)
    return ports_vec is
    variable ports : ports_vec;
  begin
    ports := (others => (others => '0'));
    --   0,0    - 0,1 - 0,2 - ... -    0,XLEN-1
    --    |        |     |     |          |
    --   1,0    - ...   ...   ... -    1,XLEN-1
    --    |        |     |     |          |
    --   ...    - ...   ...   ... -      ...
    --    |        |     |     |          |
    -- YLEN-1,0 - ...   ...   ... - YLEN-1,XLEN-1
    for i in 0 to YLEN-1 loop
      for j in 0 to XLEN-1 loop
        -- local ports are all set
        ports(i * XLEN + j)(4) := '1';
        if j /= XLEN-1 then
          -- east ports
          ports(i * XLEN + j)(3) := '1';
        end if;
        if j /= 0 then
          -- west ports
          ports(i * XLEN + j)(2) := '1';
        end if;
        if i /= YLEN-1 then
          -- south ports
          ports(i * XLEN + j)(1) := '1';
        end if;
        if i /= 0 then
          -- nord ports
          ports(i * XLEN + j)(0) := '1';
        end if;
      end loop;  -- j
    end loop;  -- i
    return ports;
  end set_router_ports;

constant ROUTER_PORTS : ports_vec := set_router_ports(XLEN, YLEN);

------------------------------------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- TILES
  -----------------------------------------------------------------------------
  tiles_gen: for i in 0 to CFG_TILES_NUM - 1  generate
    empty_tile: if tile_type(i) = 0 generate

    tile_empty_i: tile_empty
     generic (
        SIMULATION => SIMULATION,
        tile_id    => i,
        PORTS      => ROUTER_PORTS,
        HAS_SYNC   => CFG_HAS_SYNC)
     port (
	sys_clk_int        => sys_clk_int(0),
	noc1_data_n_in     => noc1_data_n_in(i),
	noc1_data_s_in     => noc1_data_s_in(i),
	noc1_data_w_in     => noc1_data_w_in(i),
	noc1_data_e_in     => noc1_data_e_in(i),
	noc1_data_void_in  => noc1_data_void_in(i), 
	noc1_stop_in       => noc1_stop_in(i),
	noc1_data_n_out    => noc1_data_n_out(i),
	noc1_data_s_out    => noc1_data_s_out(i),
	noc1_data_w_out    => noc1_data_w_out(i),
	noc1_data_e_out    => noc1_data_e_out(i),
	noc1_data_void_out => noc1_data_void_out(i),
	noc1_stop_out      => noc1_stop_out(i),
	noc2_data_n_in     => noc2_data_n_in(i),
	noc2_data_s_in     => noc2_data_s_in (i),    
	noc2_data_w_in     => noc2_data_w_in(i),     
	noc2_data_e_in     => noc2_data_e_in(i),     
	noc2_data_void_in  => noc2_data_void_in(i),  
	noc2_stop_in       => noc2_stop_in(i),       
	noc2_data_n_out    => noc2_data_n_out(i),    
	noc2_data_s_out    => noc2_data_s_out(i),    
	noc2_data_w_out    => noc2_data_w_out(i),    
	noc2_data_e_out    => noc2_data_e_out(i),    
	noc2_data_void_out => noc2_data_void_out(i),
	noc2_stop_out      => noc2_stop_out(i),      
	noc3_data_n_in     => noc3_data_n_in(i),     
	noc3_data_s_in     => noc3_data_s_in(i),     
	noc3_data_w_in     => noc3_data_w_in(i),     
	noc3_data_e_in     => noc3_data_e_in(i),     
	noc3_data_void_in  => noc3_data_void_in(i),  
	noc3_stop_in       => noc3_stop_in(i),       
	noc3_data_n_out    => noc3_data_n_out(i),    
	noc3_data_s_out    => noc3_data_s_out(i),    
	noc3_data_w_out    => noc3_data_w_out(i),    
	noc3_data_e_out    => noc3_data_e_out(i),    
	noc3_data_void_out => noc3_data_void_out(i),
	noc3_stop_out      => noc3_stop_out(i),      
	noc4_data_n_in     => noc4_data_n_in(i),     
	noc4_data_s_in     => noc4_data_s_in(i),     
	noc4_data_w_in     => noc4_data_w_in(i),     
	noc4_data_e_in     => noc4_data_e_in(i),     
	noc4_data_void_in  => noc4_data_void_in(i),  
	noc4_stop_in       => noc4_stop_in(i),       
	noc4_data_n_out    => noc4_data_n_out(i),    
	noc4_data_s_out    => noc4_data_s_out(i),    
	noc4_data_w_out    => noc4_data_w_out(i),    
	noc4_data_e_out    => noc4_data_e_out(i),    
	noc4_data_void_out => noc4_data_void_out(i),
	noc4_stop_out      => noc4_stop_out(i),      
	noc5_data_n_in     => noc5_data_n_in(i),     
	noc5_data_s_in     => noc5_data_s_in(i),     
	noc5_data_w_in     => noc5_data_w_in(i),     
	noc5_data_e_in     => noc5_data_e_in(i),     
	noc5_data_void_in  => noc5_data_void_in(i),  
	noc5_stop_in       => noc5_stop_in(i),       
	noc5_data_n_out    => noc5_data_n_out(i),    
	noc5_data_s_out    => noc5_data_s_out(i),    
	noc5_data_w_out    => noc5_data_w_out(i),    
	noc5_data_e_out    => noc5_data_e_out(i),    
	noc5_data_void_out => noc5_data_void_out(i),
	noc5_stop_out      => noc5_stop_out(i),      
	noc6_data_n_in     => noc6_data_n_in(i),     
	noc6_data_s_in     => noc6_data_s_in(i),     
	noc6_data_w_in     => noc6_data_w_in(i),     
	noc6_data_e_in     => noc6_data_e_in(i),     
	noc6_data_void_in  => noc6_data_void_in(i),  
	noc6_stop_in       => noc6_stop_in(i),       
	noc6_data_n_out    => noc6_data_n_out(i),    
	noc6_data_s_out    => noc6_data_s_out(i),    
	noc6_data_w_out    => noc6_data_w_out(i),    
	noc6_data_e_out    => noc6_data_e_out(i),    
	noc6_data_void_out => noc6_data_void_out(i),
	noc6_stop_out      => noc6_stop_out(i),  
	noc1_mon_noc_vec   => mon_noc_vec(1)(i),  
	noc2_mon_noc_vec   => mon_noc_vec(2)(i),  
	noc3_mon_noc_vec   => mon_noc_vec(3)(i),  
	noc4_mon_noc_vec   => mon_noc_vec(4)(i),  
	noc5_mon_noc_vec   => mon_noc_vec(5)(i),  
	noc6_mon_noc_vec   => mon_noc_vec(6)(i),  
	mon_dvfs_out       => mon_dvfs_out(i),
	clk_tile           => clk_tile(i) );


    end generate empty_tile;






    empty_tile: if tile_type(i) = 0 generate
      noc_input_port_1(i) <= (others => '0');
      noc_data_void_in(1)(i) <= '1';
      noc_stop_in(1)(i) <= '0';
      noc_input_port_2(i) <= (others => '0');
      noc_data_void_in(2)(i) <= '1';
      noc_stop_in(2)(i) <= '0';
      noc_input_port_3(i) <= (others => '0');
      noc_data_void_in(3)(i) <= '1';
      noc_stop_in(3)(i) <= '0';
      noc_input_port_4(i) <= (others => '0');
      noc_data_void_in(4)(i) <= '1';
      noc_stop_in(4)(i) <= '0';
      noc_input_port_5(i) <= (others => '0');
      noc_data_void_in(5)(i) <= '1';
      noc_stop_in(5)(i) <= '0';
      noc_input_port_6(i) <= (others => '0');
      noc_data_void_in(6)(i) <= '1';
      noc_stop_in(6)(i) <= '0';
      mon_dvfs_out(i).vf <= (others => '0');
      mon_dvfs_out(i).clk <= sys_clk_int(0);
      mon_dvfs_out(i).acc_idle <= '0';
      mon_dvfs_out(i).traffic <= '0';
      mon_dvfs_out(i).burst <= '0';
      clk_tile(i) <= sys_clk_int(0);
    end generate empty_tile;

    cpu_tile: if tile_type(i) = 1 generate
      assert tile_cpu_id(i) /= -1 report "Undefined CPU ID for CPU tile" severity error;
      tile_cpu_i: tile_cpu

      generic (
        SIMULATION => SIMULATION,
        tile_id    => i,
        PORTS      => ROUTER_PORTS,
        HAS_SYNC   => CFG_HAS_SYNC)
      port (
        rst                => rst_int,
        srst               => srst,
        refclk             => refclk_int(i),
        pllbypass          => pllbypass_int(i),
        pllclk             => clk_tile(i),
        cpuerr             => cpuerr_vec(tile_cpu_id(i)),
        -- TODO: remove this; should use proxy
        irq                => irq((tile_cpu_id(i) + 1) * 2 - 1 downto tile_cpu_id(i) * 2),
        timer_irq          => timer_irq(tile_cpu_id(i)),
        ipi                => ipi(tile_cpu_id(i)),
        -- NOC
        sys_clk_int        => sys_clk_int(0),
        noc1_data_n_in     => noc1_data_n_in(i),
        noc1_data_s_in     => noc1_data_s_in(i),
        noc1_data_w_in     => noc1_data_w_in(i),
        noc1_data_e_in     => noc1_data_e_in(i),
        noc1_data_void_in  => noc1_data_void_in(i), 
        noc1_stop_in       => noc1_stop_in(i),
        noc1_data_n_out    => noc1_data_n_out(i),
        noc1_data_s_out    => noc1_data_s_out(i),
        noc1_data_w_out    => noc1_data_w_out(i),
        noc1_data_e_out    => noc1_data_e_out(i),
        noc1_data_void_out => noc1_data_void_out(i),
        noc1_stop_out      => noc1_stop_out(i),
        noc2_data_n_in     => noc2_data_n_in(i),
        noc2_data_s_in     => noc2_data_s_in (i),    
        noc2_data_w_in     => noc2_data_w_in(i),     
	noc2_data_e_in     => noc2_data_e_in(i),     
	noc2_data_void_in  => noc2_data_void_in(i),  
	noc2_stop_in       => noc2_stop_in(i),       
	noc2_data_n_out    => noc2_data_n_out(i),    
	noc2_data_s_out    => noc2_data_s_out(i),    
	noc2_data_w_out    => noc2_data_w_out(i),    
        noc2_data_e_out    => noc2_data_e_out(i),    
        noc2_data_void_out => noc2_data_void_out(i),
        noc2_stop_out      => noc2_stop_out(i),      
        noc3_data_n_in     => noc3_data_n_in(i),     
        noc3_data_s_in     => noc3_data_s_in(i),     
        noc3_data_w_in     => noc3_data_w_in(i),     
        noc3_data_e_in     => noc3_data_e_in(i),     
        noc3_data_void_in  => noc3_data_void_in(i),  
        noc3_stop_in       => noc3_stop_in(i),       
        noc3_data_n_out    => noc3_data_n_out(i),    
        noc3_data_s_out    => noc3_data_s_out(i),    
        noc3_data_w_out    => noc3_data_w_out(i),    
        noc3_data_e_out    => noc3_data_e_out(i),    
        noc3_data_void_out => noc3_data_void_out(i),
        noc3_stop_out      => noc3_stop_out(i),      
        noc4_data_n_in     => noc4_data_n_in(i),     
	noc4_data_s_in     => noc4_data_s_in(i),     
	noc4_data_w_in     => noc4_data_w_in(i),     
	noc4_data_e_in     => noc4_data_e_in(i),     
	noc4_data_void_in  => noc4_data_void_in(i),  
	noc4_stop_in       => noc4_stop_in(i),       
	noc4_data_n_out    => noc4_data_n_out(i),    
	noc4_data_s_out    => noc4_data_s_out(i),    
	noc4_data_w_out    => noc4_data_w_out(i),    
	noc4_data_e_out    => noc4_data_e_out(i),    
	noc4_data_void_out => noc4_data_void_out(i),
	noc4_stop_out      => noc4_stop_out(i),      
	noc5_data_n_in     => noc5_data_n_in(i),     
	noc5_data_s_in     => noc5_data_s_in(i),     
	noc5_data_w_in     => noc5_data_w_in(i),     
	noc5_data_e_in     => noc5_data_e_in(i),     
	noc5_data_void_in  => noc5_data_void_in(i),  
	noc5_stop_in       => noc5_stop_in(i),       
	noc5_data_n_out    => noc5_data_n_out(i),    
	noc5_data_s_out    => noc5_data_s_out(i),    
	noc5_data_w_out    => noc5_data_w_out(i),    
	noc5_data_e_out    => noc5_data_e_out(i),    
	noc5_data_void_out => noc5_data_void_out(i),
	noc5_stop_out      => noc5_stop_out(i),      
	noc6_data_n_in     => noc6_data_n_in(i),     
	noc6_data_s_in     => noc6_data_s_in(i),     
	noc6_data_w_in     => noc6_data_w_in(i),     
	noc6_data_e_in     => noc6_data_e_in(i),     
	noc6_data_void_in  => noc6_data_void_in(i),  
	noc6_stop_in       => noc6_stop_in(i),       
	noc6_data_n_out    => noc6_data_n_out(i),    
	noc6_data_s_out    => noc6_data_s_out(i),    
	noc6_data_w_out    => noc6_data_w_out(i),    
	noc6_data_e_out    => noc6_data_e_out(i),    
	noc6_data_void_out => noc6_data_void_out(i),
	noc6_stop_out      => noc6_stop_out(i),  
	noc1_mon_noc_vec   => mon_noc_vec(1)(i),
	noc2_mon_noc_vec   => mon_noc_vec(2)(i),
	noc3_mon_noc_vec   => mon_noc_vec(3)(i),
	noc4_mon_noc_vec   => mon_noc_vec(4)(i),
	noc5_mon_noc_vec   => mon_noc_vec(5)(i),
	noc6_mon_noc_vec   => mon_noc_vec(6)(i),
        mon_cache          => mon_l2_int(i),
        mon_dvfs_in        => mon_dvfs_domain(i),
        mon_dvfs           => mon_dvfs_out(i));

    end generate cpu_tile;



    cpu_tile: if tile_type(i) = 1 generate
      assert tile_cpu_id(i) /= -1 report "Undefined CPU ID for CPU tile" severity error;
      tile_cpu_i: tile_cpu
        generic map (
          SIMULATION => SIMULATION,
          tile_id    => i)
        port map (
          rst                => rst_int,
          srst               => srst,
          refclk             => refclk_int(i),
          pllbypass          => pllbypass_int(i),
          pllclk             => clk_tile(i),
          cpuerr             => cpuerr_vec(tile_cpu_id(i)),
          --TODO: REMOVE!
          irq                => irq((tile_cpu_id(i) + 1) * 2 - 1 downto tile_cpu_id(i) * 2),
          timer_irq          => timer_irq(tile_cpu_id(i)),
          ipi                => ipi(tile_cpu_id(i)),
          noc1_input_port    => noc_input_port_1(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port_1(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port_2(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port_2(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port_3(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port_3(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port_4(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port_4(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port_5(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port_5(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port_6(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port_6(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_cache          => mon_l2_int(i),
          mon_dvfs_in        => mon_dvfs_domain(i),
          mon_dvfs           => mon_dvfs_out(i));

    end generate cpu_tile;

    accelerator_tile: if tile_type(i) = 2 generate
      assert tile_device(i) /= 0 report "Undefined device ID for accelerator tile" severity error;
      tile_acc_i: tile_acc
        generic map (
          tile_id => i)
        port map (
          rst                => rst_int,
          refclk             => refclk_int(i),
          pllbypass          => pllbypass_int(i),
          pllclk             => clk_tile(i),
          noc1_input_port    => noc_input_port_1(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port_1(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port_2(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port_2(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port_3(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port_3(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port_4(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port_4(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port_5(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port_5(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port_6(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port_6(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_dvfs_in        => mon_dvfs_domain(i),
          --Monitor signals
          mon_acc            => mon_acc(tile_acc_id(i)),
          mon_cache          => mon_l2_int(i),
          mon_dvfs           => mon_dvfs_out(i)
          );

    end generate accelerator_tile;

    io_tile: if tile_type(i) = 3 generate
      tile_io_i : tile_io
        generic map (
          SIMULATION => SIMULATION)
        port map (
          rst                => rst_int,
          srst               => srst,
          clk                => refclk_int(i),
          eth0_apbi          => eth0_apbi,
          eth0_apbo          => eth0_apbo,
          sgmii0_apbi        => sgmii0_apbi,
          sgmii0_apbo        => sgmii0_apbo,
          eth0_ahbmi         => eth0_ahbmi,
          eth0_ahbmo         => eth0_ahbmo,
          edcl_ahbmo         => edcl_ahbmo,
          dvi_apbi           => dvi_apbi,
          dvi_apbo           => dvi_apbo,
          dvi_ahbmi          => dvi_ahbmi,
          dvi_ahbmo          => dvi_ahbmo,
          uart_rxd           => uart_rxd_int,
          uart_txd           => uart_txd_int,
          uart_ctsn          => uart_ctsn_int,
          uart_rtsn          => uart_rtsn_int,
          irq                => irq,
          timer_irq          => timer_irq,
          ipi                => ipi,
          noc1_input_port    => noc_input_port_1(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port_1(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port_2(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port_2(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port_3(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port_3(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port_4(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port_4(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port_5(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port_5(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port_6(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port_6(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_dvfs           => mon_dvfs_out(i));
      clk_tile(i) <= refclk_int(i);
    end generate io_tile;

    mem_tile: if tile_type(i) = 4 generate
      tile_mem_i: tile_mem
        generic map (
          tile_id => i)
        port map (
          rst                => rst_int,
          srst               => srst,
          clk                => sys_clk_int(tile_mem_id(i)),
          ddr_ahbsi          => ddr_ahbsi(tile_mem_id(i)),
          ddr_ahbso          => ddr_ahbso(tile_mem_id(i)),
          noc1_input_port    => noc_input_port_1(i),
          noc1_data_void_in  => noc_data_void_in(1)(i),
          noc1_stop_in       => noc_stop_in(1)(i),
          noc1_output_port   => noc_output_port_1(i),
          noc1_data_void_out => noc_data_void_out(1)(i),
          noc1_stop_out      => noc_stop_out(1)(i),
          noc2_input_port    => noc_input_port_2(i),
          noc2_data_void_in  => noc_data_void_in(2)(i),
          noc2_stop_in       => noc_stop_in(2)(i),
          noc2_output_port   => noc_output_port_2(i),
          noc2_data_void_out => noc_data_void_out(2)(i),
          noc2_stop_out      => noc_stop_out(2)(i),
          noc3_input_port    => noc_input_port_3(i),
          noc3_data_void_in  => noc_data_void_in(3)(i),
          noc3_stop_in       => noc_stop_in(3)(i),
          noc3_output_port   => noc_output_port_3(i),
          noc3_data_void_out => noc_data_void_out(3)(i),
          noc3_stop_out      => noc_stop_out(3)(i),
          noc4_input_port    => noc_input_port_4(i),
          noc4_data_void_in  => noc_data_void_in(4)(i),
          noc4_stop_in       => noc_stop_in(4)(i),
          noc4_output_port   => noc_output_port_4(i),
          noc4_data_void_out => noc_data_void_out(4)(i),
          noc4_stop_out      => noc_stop_out(4)(i),
          noc5_input_port    => noc_input_port_5(i),
          noc5_data_void_in  => noc_data_void_in(5)(i),
          noc5_stop_in       => noc_stop_in(5)(i),
          noc5_output_port   => noc_output_port_5(i),
          noc5_data_void_out => noc_data_void_out(5)(i),
          noc5_stop_out      => noc_stop_out(5)(i),
          noc6_input_port    => noc_input_port_6(i),
          noc6_data_void_in  => noc_data_void_in(6)(i),
          noc6_stop_in       => noc_stop_in(6)(i),
          noc6_output_port   => noc_output_port_6(i),
          noc6_data_void_out => noc_data_void_out(6)(i),
          noc6_stop_out      => noc_stop_out(6)(i),
          mon_mem            => mon_mem(tile_mem_id(i)),
          mon_cache          => mon_llc_int(i),
          mon_dvfs           => mon_dvfs_out(i));
      clk_tile(i) <= sys_clk_int(tile_mem_id(i));

    end generate mem_tile;

  end generate tiles_gen;


  -----------------------------------------------------------------------------
  -- NoC
  -----------------------------------------------------------------------------

  sync_noc_xy_1: sync_noc_xy
    generic map (
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port_1,
      data_void_in    => noc_data_void_in(1),
      stop_in         => noc_stop_in(1),
      output_port     => noc_output_port_1,
      data_void_out   => noc_data_void_out(1),
      stop_out        => noc_stop_out(1),
      mon_noc         => mon_noc_vec(1)
      );

  --noc_output_port_2 <= (others => (others => '0'));
  --noc_data_void_out(2) <= (others => '1');
  --noc_stop_out(2) <= (others => '0');
  --mon_noc_vec(2) <= (others => monitor_noc_none);
  sync_noc_xy_2: sync_noc_xy
    generic map (
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port_2,
      data_void_in    => noc_data_void_in(2),
      stop_in         => noc_stop_in(2),
      output_port     => noc_output_port_2,
      data_void_out   => noc_data_void_out(2),
      stop_out        => noc_stop_out(2),
      mon_noc         => mon_noc_vec(2)
      );

  sync_noc_xy_3: sync_noc_xy
    generic map (
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port_3,
      data_void_in    => noc_data_void_in(3),
      stop_in         => noc_stop_in(3),
      output_port     => noc_output_port_3,
      data_void_out   => noc_data_void_out(3),
      stop_out        => noc_stop_out(3),
      mon_noc         => mon_noc_vec(3)
      );

  sync_noc_xy_4: sync_noc_xy
    generic map (
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port_4,
      data_void_in    => noc_data_void_in(4),
      stop_in         => noc_stop_in(4),
      output_port     => noc_output_port_4,
      data_void_out   => noc_data_void_out(4),
      stop_out        => noc_stop_out(4),
      mon_noc         => mon_noc_vec(4)
      );

  sync_noc_xy_5: sync_noc32_xy
    generic map (
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port_5,
      data_void_in    => noc_data_void_in(5),
      stop_in         => noc_stop_in(5),
      output_port     => noc_output_port_5,
      data_void_out   => noc_data_void_out(5),
      stop_out        => noc_stop_out(5),
      mon_noc         => mon_noc_vec(5)
      );

  sync_noc_xy_6: sync_noc_xy
    generic map (
      XLEN      => CFG_XLEN,
      YLEN      => CFG_YLEN,
      TILES_NUM => CFG_TILES_NUM,
      has_sync  => CFG_HAS_SYNC)
    port map (
      clk             => sys_clk_int(0),
      clk_tile        => clk_tile,
      rst             => rst_int,
      input_port      => noc_input_port_6,
      data_void_in    => noc_data_void_in(6),
      stop_in         => noc_stop_in(6),
      output_port     => noc_output_port_6,
      data_void_out   => noc_data_void_out(6),
      stop_out        => noc_stop_out(6),
      mon_noc         => mon_noc_vec(6)
      );

  monitor_noc_gen: for i in 1 to nocs_num generate
    monitor_noc_tiles_gen: for j in 0 to CFG_TILES_NUM-1 generate
      mon_noc(i,j) <= mon_noc_vec(i)(j);
    end generate monitor_noc_tiles_gen;
  end generate monitor_noc_gen;

  monitor_l2_gen: for i in 0 to CFG_NL2 - 1 generate
    mon_l2(i) <= mon_l2_int(cache_tile_id(i));
  end generate monitor_l2_gen;

  monitor_llc_gen: for i in 0 to CFG_NLLC - 1 generate
    mon_llc(i) <= mon_llc_int(llc_tile_id(i));
  end generate monitor_llc_gen;


  -- Handle cases with no accelerators, no l2, no llc
  mon_acc_noacc_gen: if accelerators_num = 0 generate
    mon_acc(0) <= monitor_acc_none;
  end generate mon_acc_noacc_gen;

  mon_l2_nol2_gen: if CFG_NL2 = 0 generate
    mon_l2(0) <= monitor_cache_none;
  end generate mon_l2_nol2_gen;

  mon_llc_nollc_gen: if CFG_NLLC = 0 generate
    mon_llc(0) <= monitor_cache_none;
  end generate mon_llc_nollc_gen;

end;
