LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity mux16to1 is
    port (i : in std_logic_vector(15 downto 0);
          s : in std_logic_vector(3 downto 0);
          o : out std_logic);
    end mux16to1;
    
    architecture rtl of mux16to1 is
        signal mux_out: std_logic_vector(3 downto 0);
    begin
        -- first order 4:1 muxes
        mux1: entity work.mux4to1(rtl)
            port map (i(3 downto 0), s(1 downto 0), o => mux_out(0));
        mux2: entity work.mux4to1(rtl)
            port map (i(7 downto 4), s(1 downto 0), o => mux_out(1));
        mux3: entity work.mux4to1(rtl)
            port map (i(11 downto 8), s(1 downto 0), o => mux_out(2));
        mux4: entity work.mux4to1(rtl)
            port map (i(15 downto 12), s(1 downto 0), o => mux_out(3));

        -- 4:1 mux joining the other 4
        mux5: entity work.mux4to1(rtl)
            port map (mux_out(3 downto 0), s(3 downto 2), o);
    end rtl;

