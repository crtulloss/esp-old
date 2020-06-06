-- Copyright (c) 2011-2019 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;

package allacc is

  component softmax_basic_fx32_dma64
    port (
      clk                        : in  std_ulogic;
      rst                        : in  std_ulogic;

      conf_info                  : in  std_logic_vector(31 downto 0);
      conf_done                  : in  std_ulogic;

      dma_read_ctrl_msg          : out std_logic_vector(66 downto 0);
      dma_read_ctrl_val          : out std_ulogic;
      dma_read_ctrl_rdy          : in  std_ulogic;

      dma_write_ctrl_msg         : out std_logic_vector(66 downto 0);
      dma_write_ctrl_val         : out std_ulogic;
      dma_write_ctrl_rdy         : in  std_ulogic;

      dma_read_chnl_msg          : in  std_logic_vector(63 downto 0);
      dma_read_chnl_val          : in  std_ulogic;
      dma_read_chnl_rdy          : out std_ulogic;

      dma_write_chnl_msg         : out std_logic_vector(63 downto 0);
      dma_write_chnl_val         : out std_ulogic;
      dma_write_chnl_rdy         : in  std_ulogic;

      acc_done                   : out std_ulogic
    );
  end component;



  component softmax_cxx_basic_fx32_dma64
    port (
      clk                        : in  std_ulogic;
      rst                        : in  std_ulogic;

      conf_info_rsc_dat          : in  std_logic_vector(31 downto 0);
      conf_info_rsc_vld          : in  std_ulogic;
      conf_info_rsc_rdy          : out std_ulogic;

      dma_read_ctrl_rsc_dat      : out std_logic_vector(66 downto 0);
      dma_read_ctrl_rsc_vld      : out std_ulogic;
      dma_read_ctrl_rsc_rdy      : in  std_ulogic;

      dma_write_ctrl_rsc_dat     : out std_logic_vector(66 downto 0);
      dma_write_ctrl_rsc_vld     : out std_ulogic;
      dma_write_ctrl_rsc_rdy     : in  std_ulogic;

      dma_read_chnl_rsc_dat      : in  std_logic_vector(63 downto 0);
      dma_read_chnl_rsc_vld      : in  std_ulogic;
      dma_read_chnl_rsc_rdy      : out std_ulogic;

      dma_write_chnl_rsc_dat     : out std_logic_vector(63 downto 0);
      dma_write_chnl_rsc_vld     : out std_ulogic;
      dma_write_chnl_rsc_rdy     : in  std_ulogic;

      acc_done_rsc_vld           : out std_ulogic
    );
  end component;



  component softmax_cxx_hier_fx32_dma64
    port (
      clk                        : in  std_ulogic;
      rst                        : in  std_ulogic;

      conf_info_rsc_dat          : in  std_logic_vector(31 downto 0);
      conf_info_rsc_vld          : in  std_ulogic;
      conf_info_rsc_rdy          : out std_ulogic;

      dma_read_ctrl_rsc_dat      : out std_logic_vector(66 downto 0);
      dma_read_ctrl_rsc_vld      : out std_ulogic;
      dma_read_ctrl_rsc_rdy      : in  std_ulogic;

      dma_write_ctrl_rsc_dat     : out std_logic_vector(66 downto 0);
      dma_write_ctrl_rsc_vld     : out std_ulogic;
      dma_write_ctrl_rsc_rdy     : in  std_ulogic;

      dma_read_chnl_rsc_dat      : in  std_logic_vector(63 downto 0);
      dma_read_chnl_rsc_vld      : in  std_ulogic;
      dma_read_chnl_rsc_rdy      : out std_ulogic;

      dma_write_chnl_rsc_dat     : out std_logic_vector(63 downto 0);
      dma_write_chnl_rsc_vld     : out std_ulogic;
      dma_write_chnl_rsc_rdy     : in  std_ulogic;

      acc_done_rsc_vld           : out std_ulogic
    );
  end component;



end;
