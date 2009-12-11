LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity rshift32 is
    port (i : in std_logic_vector(31 downto 0);
             sa : in std_logic_vector(4 downto 0);
             o : out std_logic_vector(31 downto 0));
    end rshift32;
     
     architecture rtl of rshift32 is
     signal mux_in: std_logic_vector(63 downto 0);
     begin
        mux_in(31 downto 0) <= i(31 downto 0);
        mux_in(63 downto 32) <= x"00000000";
        -- Naive implementation (1024to32 Mux)
        GEN1: for n in 0 to 31 generate
            mux32to1: entity work.mux32to1(rtl)
                port map (mux_in(n+31 downto n), sa, o(n));
        end generate GEN1;
        
     end rtl;

