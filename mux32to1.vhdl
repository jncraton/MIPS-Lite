LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity mux32to1 is
    port (i : in std_logic_vector(31 downto 0);
          s : in std_logic_vector(4 downto 0);
          o : out std_logic);
    end mux32to1;
    
    architecture rtl of mux32to1 is
        signal mux_out: std_logic_vector(1 downto 0);
    begin
        -- first level 16:1 muxes
        mux1: entity work.mux16to1(rtl)
            port map (i(15 downto 0), s(3 downto 0), o => mux_out(0));
        mux2: entity work.mux16to1(rtl)
            port map (i(31 downto 16), s(3 downto 0), mux_out(1));
        -- second level 2:1 muxes to mix 16:1 muxes 
        mux3: entity work.mux2to1(rtl)
            port map (mux_out(1 downto 0), s(4), o);
    end rtl;

