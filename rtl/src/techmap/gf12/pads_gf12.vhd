-- This file is just a place-holder and will be removed once technology files
-- are in place.

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity gf12_inpad is
  port (pad : in std_ulogic; o : out std_ulogic);
end;
architecture rtl of gf12_inpad is

begin
  o <= pad;
end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity gf12_iopad  is
  port (pad : inout std_logic; i, en : in std_ulogic; o : out std_logic);
end ;
architecture rtl of gf12_iopad is

begin
  o <= pad;
  pad <= 'Z' when en = '0' else i;
end;

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;

entity gf12_outpad  is
  port (pad : out std_ulogic; i : in std_ulogic);
end ;
architecture rtl of gf12_outpad is

begin
  pad <= i;
end;

