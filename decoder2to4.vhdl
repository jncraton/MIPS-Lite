library ieee;
use ieee.std_logic_1164.all;

entity decoder2to4 is
    port (i : in std_logic;
          s : in std_logic_vector(1 downto 0);
          o : out std_logic_vector(3 downto 0));
    end decoder2to4;
    
    architecture rtl of decoder2to4 is
        signal decoder_out: std_logic_vector(1 downto 0);
    begin
        decoder3: entity work.decoder1to2(rtl)
            port map (i, s(1), decoder_out(1 downto 0));
        decoder1: entity work.decoder1to2(rtl)
            port map (decoder_out(1), s(0), o(3 downto 2));
        decoder2: entity work.decoder1to2(rtl)
            port map (decoder_out(0), s(0), o(1 downto 0));
    end rtl;
