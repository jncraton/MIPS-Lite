library ieee;
use ieee.std_logic_1164.all;

entity register4 is
    port (D : in std_logic_vector(3 downto 0);
          WE : in std_logic;
          clk : in std_logic;
          Q : out std_logic_vector(3 downto 0);
          Qprime : out std_logic_vector(3 downto 0));
    end register4;
    
    architecture rtl of register4 is
    begin
        GEN: for n in 3 downto 0 generate
            ff: entity work.Dff(Behavior)
                port map (D(n), WE, clk, Q(n), Qprime(n));
        end generate GEN;
    end rtl;
