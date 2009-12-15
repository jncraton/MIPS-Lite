LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- returns high if i0 == i1 and i0!=0 and i1!=0

entity ForwardComparator is
    port (i0, i1 : in std_logic_vector(4 downto 0);
          result : out std_logic);
    end ForwardComparator;
    
    architecture rtl of ForwardComparator is
    signal equal, zero : std_logic;
    begin
        equal <= not ((i0(0) xor i1(0)) or
                  (i0(1) xor i1(1)) or
                  (i0(2) xor i1(2)) or
                  (i0(3) xor i1(3)) or
                  (i0(4) xor i1(4)));
                  
        zero <= not ((i0(0) or i1(0)) or
                  (i0(1) or i1(1)) or
                  (i0(2) or i1(2)) or
                  (i0(3) or i1(3)) or
                  (i0(4) or i1(4)));
                  
        result <= equal and (not zero);
    end rtl;