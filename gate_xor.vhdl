LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity gate_xor is
port(	i0,i1: in std_logic;
	    o: out std_logic
);
end gate_xor;  

architecture rtl of gate_xor is
begin
    o <= i0 xor i1 after 35 ps;
end rtl;

