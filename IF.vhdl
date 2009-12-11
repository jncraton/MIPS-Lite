LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- the behavior of this may not be what is expected
-- the carry in automatically flips the 

entity adder32 is
    port (i0, i1 : in std_logic_vector(31 downto 0);
          ci : in std_logic;
          s : out std_logic_vector(31 downto 0);
          co : out std_logic);
    end adder32;
    
    architecture rtl of adder32 is
        signal carry: std_logic_vector(32 downto 0);
        signal i1_subtraction: std_logic_vector(31 downto 0);
    begin
        -- generate 32 adders chained together
        carry(0) <= ci;
        co <= carry(32);
        
        -- flip if ci is high
        GEN_sub: for n in 0 to 31 generate
            i1_subtraction(n) <= (i1(n) xor ci) after 35 ps;
        end generate GEN_sub;
        
        GEN1: for n in 0 to 31 generate
            adder: entity work.adder(rtl)
                port map (i0(n), i1_subtraction(n), carry(n), s(n), carry(n+1));
        end generate GEN1;
    end rtl;

--ci i1 o
--0  0  0
--0  1  1
--1  0  1
--1  1  0