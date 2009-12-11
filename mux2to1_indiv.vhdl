library ieee;
use  ieee.std_logic_1164.all;

entity mux2to1_indiv is
    port (i0: in std_logic;
          i1: in std_logic;
          s : in std_logic;
          o : out std_logic);
    end mux2to1_indiv;

    architecture rtl of mux2to1_indiv is
        signal s_not: std_logic;
        signal a,b: std_logic;
    begin
        o <= (( i0 and not s ) or ( i1 and s )) after 105 ps;
    end rtl;

