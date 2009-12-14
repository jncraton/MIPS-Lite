library ieee;
use ieee.std_logic_1164.all;

entity register1 is
    port (D : in std_logic;
          WE : in std_logic;
          clk : in std_logic;
          Q : out std_logic;
          Qprime : out std_logic);
    end register1;
    
    architecture rtl of register1 is
    begin
        ff: entity work.Dff(Behavior)
            port map (D, WE, clk, Q, Qprime);
    end rtl;
