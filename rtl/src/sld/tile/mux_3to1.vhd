library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_3to1 is
  generic (sz: integer);
  port
    ( sel : in  std_logic_vector(2 downto 0);
      A   : in  std_logic_vector (sz-1 downto 0);
      B   : in  std_logic_vector (sz-1 downto 0);
      C   : in  std_logic_vector (sz-1 downto 0);
      X   : out std_logic_vector (sz-1 downto 0));
end mux_3to1;

architecture arch of mux_3to1 is
begin

  process(sel,A,B,C)
    begin
      case sel is
        when "100" =>
          X<=A;
        when "010" =>
          X<=B;
        when "001"=>
          X<=C;
        when others =>
          X<= (others =>'0');
      end case;
    end process;

end arch;



