library ieee;
use  ieee.std_logic_1164.all;

entity mux2to1 is
    port (i: in std_logic_vector(1 downto 0);
          s : in std_logic;
          o : out std_logic);
    end mux2to1;

    architecture rtl of mux2to1 is
        signal s_not: std_logic;
        signal a,b: std_logic;
    begin
        o <= (( i(0) and not s ) or ( i(1) and s )) after 105 ps;
    end rtl;

