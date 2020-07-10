library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2to1 is
  generic (sz: integer);
  port
    ( sel : in  std_logic;
      A   : in  std_logic_vector (sz-1 downto 0);
      B   : in  std_logic_vector (sz-1 downto 0);
      X   : out std_logic_vector (sz-1 downto 0));
end mux_2to1;

architecture arch of mux_2to1 is
begin
  process(A,B,sel)
    begin
      case sel is
        when '1' => X <=A;
        when '0' => X <=B;
        when others=>null;
      end case;
  end process;
end arch;
