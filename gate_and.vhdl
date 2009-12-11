LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity gate_and is
port(	i0,i1: in std_logic;
	    o: out std_logic
);
end gate_and;

architecture rtl of gate_and is
begin
    o <= i0 and i1 after 35 ps;
end rtl;

