LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity adder is
       port (i0, i1 : in std_logic; ci : in std_logic; s : out std_logic; co : out std_logic);
     end adder;
     
     architecture rtl of adder is
     begin
        s <= (i0 xor i1 xor ci) after 35 ps; --35
        co <= (i0 and i1) or (i0 and ci) or (i1 and ci) after 70 ps; --70
     end rtl;

