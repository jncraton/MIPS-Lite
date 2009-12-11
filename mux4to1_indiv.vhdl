LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity mux4to1_indiv is
    port (i0 : in std_logic;
          i1 : in std_logic;
          i2 : in std_logic;
          i3 : in std_logic;
          s0 : in std_logic;
          s1 : in std_logic;
          o : out std_logic);
    end mux4to1_indiv;
    
    architecture rtl of mux4to1_indiv is
        signal mux_out: std_logic_vector(1 downto 0);
        signal t1, t2: std_logic_vector(1 downto 0);
    begin
        t1(1) <= i1;
        t1(0) <= i0;
        mux1: entity work.mux2to1(rtl)
            port map (t1, s0, o => mux_out(0));
        t2(1) <= i3;
        t2(0) <= i2;
        mux2: entity work.mux2to1(rtl)
            port map (t2, s0, mux_out(1));
        mux3: entity work.mux2to1(rtl)
            port map (mux_out(1 downto 0), s1, o);
    end rtl;

