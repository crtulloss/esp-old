library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demux_1to2 is
  generic(sz:integer ); 
  port(
    data_in: in std_logic_vector(sz-1 downto 0);
    sel: in std_logic;
    out1,out2: out std_logic_vector(sz-1 downto 0));
end demux_1to2;

architecture arch of demux_1to2 is
begin
  process(data_in,sel)
  begin
    if  sel='1' then
        out1<=data_in;
    else
        out2<=data_in;
    end if;
  end process;
end arch;







