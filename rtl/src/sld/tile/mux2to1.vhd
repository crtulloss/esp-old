library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2to1 is
  port
    ( sel : in  std_logic;
      A   : in  std_logic;
      B   : in  std_logic;
      X   : out std_logic);
end mux2to1;

architecture arch of mux2to1 is
begin
  process(A,B,sel)
  begin
    case sel is
      when '1' => X<=A;
      when '0' => X<=B;
      when others=>null;
    end case;
  end process;
    
end arch;





