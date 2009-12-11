library ieee;
use ieee.std_logic_1164.all;

entity decoder5to32 is
    port (i : in std_logic;
          s : in std_logic_vector(4 downto 0);
          o : out std_logic_vector(31 downto 0));
    end decoder5to32;
    
    architecture rtl of decoder5to32 is
        signal decoder_out: std_logic_vector(1 downto 0);
    begin
        decoder3: entity work.decoder1to2(rtl)
            port map (i, s(4), decoder_out(1 downto 0));
        decoder1: entity work.decoder4to16(rtl)
            port map (decoder_out(1), s(3 downto 0), o(31 downto 16));
        decoder2: entity work.decoder4to16(rtl)
            port map (decoder_out(0), s(3 downto 0), o(15 downto 0));
    end rtl;
