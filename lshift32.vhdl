LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity lshift32 is
    port (i : in std_logic_vector(31 downto 0);
             sa : in std_logic_vector(4 downto 0);
             o : out std_logic_vector(31 downto 0));
    end lshift32;
     
     architecture rtl of lshift32 is
     signal mux_in: std_logic_vector(63 downto 0);
     signal mux_out: std_logic_vector(31 downto 0);
     begin
        mux_in_1: for n in 0 to 31 generate
            mux_in(n) <= i(31-n);
        end generate mux_in_1;

        mux_in(63 downto 32) <= x"00000000";

        mux_out_1: for n in 0 to 31 generate
             o(31-n) <= mux_out(n);
        end generate mux_out_1;
        -- Naive implementation (1024to32 Mux)
        GEN1: for n in 0 to 31 generate
            mux32to1: entity work.mux32to1(rtl)
                port map (mux_in(n+31 downto n), sa, mux_out(n));
        end generate GEN1;
        
     end rtl;

