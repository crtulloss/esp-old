-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.config.all;
use work.config_types.all;
use work.gencomp.all;
use work.alldco.all;

entity dco is

  generic (
    tech : integer := gf12
    );
  port (
    rstn      : in  std_ulogic;
    fsel_i    : in  std_logic_vector(12 downto 0);
    clk_o     : out std_ulogic;
    div_clk_o : out std_ulogic);          -- 1/8 of clk_o (bring to pin for testing)

end entity dco;


architecture rtl of dco is

  signal clk_nobuf : std_ulogic;
  signal div_clk_nobuf : std_ulogic;

begin  -- architecture rtl

  gf12_gen : if (tech = gf12) generate

    gf12_dco_1: GF12_DCO
      port map (
        CLK_RSTN => rstn,
        DCO_SEL  => fsel_i(12 downto 7),
        DIV_SEL  => "111",
        DCLK     => clk_nobuf,
        DIV_CLK  => div_clk_nobuf,
        EN_CAP   => fsel_i(6 downto 0));

    clk_o <= clk_nobuf;
    div_clk_o <= div_clk_nobuf;

  end generate;

-- pragma translate_off
  noram : if has_dco(tech) = 0 generate
    x : process
    begin
      assert false report "dco: technology " & tech_table(tech) &
	" not supported"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end architecture rtl;
