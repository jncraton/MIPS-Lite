library ieee;
use  ieee.std_logic_1164.all;

entity decoder1to2 is
    port (i: in std_logic;
          s : in std_logic;
          o : out std_logic_vector(1 downto 0));
    end decoder1to2;

    architecture rtl of decoder1to2 is
    begin
        o(0) <= ( i and not s ) after 70 ps;
        o(1) <= ( i and s ) after 70 ps;
    end rtl;