library ieee;
use ieee.std_logic_1164.all;

entity demux_1to3 is
  port(
    data_in: in std_logic;
    sel: in std_logic_vector(2 downto 0);
    out1,out2,out3: out std_logic);
end demux_1to3;

architecture arch of demux_1to3 is
    begin
      process(data_in,sel)         
      begin
        out3<='0';
        out2<='0';
        out1<='0';
        case sel is
          when "001" =>
           out3<=data_in;
          when "010" =>
           out2<=data_in;
          when "100" =>
            out1<=data_in;
          when others =>
            null;
        end case;
      end process;
end arch;




    
