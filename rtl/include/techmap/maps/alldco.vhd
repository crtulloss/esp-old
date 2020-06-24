library ieee;
use ieee.std_logic_1164.all;

package alldco is

  component GF12_DCO is
    port (
      CLK_RSTN : in  std_ulogic;
      DCO_SEL  : in  std_logic_vector(5 downto 0);
      DIV_SEL  : in  std_logic_vector(2 downto 0);
      DCLK     : out std_ulogic;
      DIV_CLK  : out std_ulogic;
      EN_CAP   : in  std_logic_vector(6 downto 0));
  end component GF12_DCO;

end package alldco;
