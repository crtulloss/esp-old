library ieee;
use ieee.std_logic_1164.all;

  entity sipo is
    generic (DIM: integer);
      port(
         clk      : in std_logic;
         clear    : in std_logic;
         en_in    : in std_logic;
         serial_in: in std_logic;
         en_out   : in std_logic;
         en_comp  : in std_logic;    
         test_comp: out std_logic_vector(DIM-1 downto 0);  
         data_out : out std_logic_vector(DIM-6 downto 0);  
         op       : out std_logic; 
         done     : out std_logic);
   end sipo;

      
  architecture arch of sipo is
      signal q: std_logic_vector(DIM-1 downto 0);  
  begin
    process(clk,en_in,clear,serial_in)
    begin
      if clear='1' then
        q<=(others=>'0');
      elsif (clk'event and clk='1' and en_in='1') then
        q(DIM-2 downto 0)<=q(DIM-1 downto 1);
        q(DIM-1)<=serial_in;
      end if;
    end process;

    done<=q(0);  
    op<=q(1);
      process(en_comp,q)
        begin
            if en_comp='1' then
                test_comp<=q(DIM-1 downto 0);
            else
                test_comp<=(others=>'0');
            end if;
      end process;        

      
    process(en_out,q)
      begin
          if (en_out='1') then     
              data_out<=q(DIM-1 downto 5);         
          else  
              data_out<=(others=>'0');
          end if;
    end process;
        
  end;
  
    
