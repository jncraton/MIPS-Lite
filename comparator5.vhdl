LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- returns high if i0 == i1 are identical

entity comparator5 is
    port (i0, i1 : in std_logic_vector(4 downto 0);
          result : out std_logic);
    end comparator5;
    
    architecture rtl of comparator5 is
    begin
        result <= not ((i0(0) xor i1(0)) or
                  (i0(1) xor i1(1)) or
                  (i0(2) xor i1(2)) or
                  (i0(3) xor i1(3)) or
                  (i0(4) xor i1(4)));
    end rtl;