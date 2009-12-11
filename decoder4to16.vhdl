library ieee;
use ieee.std_logic_1164.all;

entity decoder4to16 is
    port (i : in std_logic;
          s : in std_logic_vector(3 downto 0);
          o : out std_logic_vector(15 downto 0));
    end decoder4to16;
    
    architecture rtl of decoder4to16 is
        signal decoder_out: std_logic_vector(3 downto 0);
    begin
        decoder5: entity work.decoder2to4(rtl)
            port map (i, s(3 downto 2), decoder_out(3 downto 0));
        decoder1: entity work.decoder2to4(rtl)
            port map (decoder_out(3), s(1 downto 0), o(15 downto 12));
        decoder2: entity work.decoder2to4(rtl)
            port map (decoder_out(2), s(1 downto 0), o(11 downto 8));
        decoder3: entity work.decoder2to4(rtl)
            port map (decoder_out(1), s(1 downto 0), o(7 downto 4));
        decoder4: entity work.decoder2to4(rtl)
            port map (decoder_out(0), s(1 downto 0), o(3 downto 0));
    end rtl;
