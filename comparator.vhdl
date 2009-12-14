LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- returns high if i0 == i1 are identical

entity comparator is
    port (i0, i1 : in std_logic_vector(31 downto 0);
          result : out std_logic);
    end comparator;
    
    architecture rtl of comparator is
    begin
        result <= not ((i0(0) xor i1(0)) or
                  (i0(1) xor i1(1)) or
                  (i0(2) xor i1(2)) or
                  (i0(3) xor i1(3)) or
                  (i0(4) xor i1(4)) or
                  (i0(5) xor i1(5)) or
                  (i0(6) xor i1(6)) or
                  (i0(7) xor i1(7)) or
                  (i0(8) xor i1(8)) or
                  (i0(9) xor i1(9)) or
                  (i0(10) xor i1(10)) or
                  (i0(11) xor i1(11)) or
                  (i0(12) xor i1(12)) or
                  (i0(13) xor i1(13)) or
                  (i0(14) xor i1(14)) or
                  (i0(15) xor i1(15)) or
                  (i0(16) xor i1(16)) or
                  (i0(17) xor i1(17)) or
                  (i0(18) xor i1(18)) or
                  (i0(19) xor i1(19)) or
                  (i0(20) xor i1(20)) or
                  (i0(21) xor i1(21)) or
                  (i0(22) xor i1(22)) or
                  (i0(23) xor i1(23)) or
                  (i0(24) xor i1(24)) or
                  (i0(25) xor i1(25)) or
                  (i0(26) xor i1(26)) or
                  (i0(27) xor i1(27)) or
                  (i0(28) xor i1(28)) or
                  (i0(29) xor i1(29)) or
                  (i0(30) xor i1(30)) or
                  (i0(31) xor i1(31)));
    end rtl;

--ci i1 o
--0  0  0
--0  1  1
--1  0  1
--1  1  0