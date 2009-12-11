LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity logical_not is
       port (i: in std_logic_vector(31 downto 0); 
             o : out std_logic_vector(31 downto 0));
     end logical_not;
     
     architecture rtl of logical_not is
     begin
        GEN_zeros: for n in 1 to 31 generate
            o(n) <= '0';
        end generate GEN_zeros;
        
        o(0) <= not (
                   i(0)
                or i(1)
                or i(2)
                or i(3)
                or i(4)
                or i(5)
                or i(6)
                or i(7)
                or i(8)
                or i(9)
                or i(10)
                or i(11)
                or i(12)
                or i(13)
                or i(14)
                or i(15)
                or i(16)
                or i(17)
                or i(18)
                or i(19)
                or i(20)
                or i(21)
                or i(22)
                or i(23)
                or i(24)
                or i(25)
                or i(26)
                or i(27)
                or i(28)
                or i(29)
                or i(30)
                or i(31)) after 175 ps;
     end rtl;

