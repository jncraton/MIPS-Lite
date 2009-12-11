LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity gate_or is
port(	i0,i1: in std_logic;
	    o: out std_logic
);
end gate_or;  

architecture rtl of gate_or is
begin
    o <= i0 or i1 after 35 ps;
end rtl;

