library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity piso is
    generic (sz:integer);
    port ( clk :  in   std_logic;
           load : in   std_logic;
           A :    in   std_logic_vector(sz-1 downto 0);
           shift_en : in std_logic;
           B :    out  std_logic_vector(sz-1 downto 0);
           Y :    out  std_logic;
           done:  out  std_logic);
end piso;

architecture arch of piso is

  signal sr: std_logic_vector(sz downto 0) := (others=>'0');
  constant ZERO : std_logic_vector(sz downto 0) := std_logic_vector(to_unsigned(0,sz+1 ));
   
begin

  process (clk,load,A)
  begin
   -- sr<=(others<='0');
    if (load = '1') then
      sr <= A & '1';
    elsif clk'event and clk='1' and shift_en='1' then
      sr <=sr(sz-1 downto 0) & '0';
    end if;
  end process;

  B<= sr(sz downto 1);
  Y <= sr(sz);      
  done<='1' when sr=ZERO else '0';
end arch;

