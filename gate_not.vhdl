LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity gate_not is
port(	i: in std_logic;
	    o: out std_logic
);
end gate_not;  

architecture rtl of gate_not is
begin
    o <= not i after 35 ps;
end rtl;

