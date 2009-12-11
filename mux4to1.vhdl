LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity mux4to1 is
    port (i : in std_logic_vector(3 downto 0);
          s : in std_logic_vector(1 downto 0);
          o : out std_logic);
    end mux4to1;
    
    architecture rtl of mux4to1 is
        signal mux_out: std_logic_vector(1 downto 0);
    begin
        mux1: entity work.mux2to1(rtl)
            port map (i(1 downto 0), s(0), o => mux_out(0));
        mux2: entity work.mux2to1(rtl)
            port map (i(3 downto 2), s(0), mux_out(1));
        mux3: entity work.mux2to1(rtl)
            port map (mux_out(1 downto 0), s(1), o);
    end rtl;

