library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Memory is
    port (clk : in std_logic;
          WriteData : in std_logic_vector(31 downto 0);
          Address : in std_logic_vector(31 downto 0);
          MemWrite : in std_logic;
          MemRead : in std_logic;
          
          ReadData : out std_logic_vector(31 downto 0));

    end Memory;
    
    architecture rtl of Memory is
        signal data : std_logic_vector(31 downto 0);
        signal nwe, noe, ncs : std_logic;
        
    begin
            -- Data Memory
                memory: entity work.sram64kx8(sram_behaviour)
                    port map (ncs, Address, data, nwe, noe);
        
                nwe <= not MemWrite;
                noe <= not MemRead;
                ncs <= not (MemWrite or MemRead);

            -- connect data to reg out 2 with a tristate buffer
                GEN_memtris: for n in 31 downto 0 generate
                    data(n) <= WriteData(n) when MemWrite='1' else 'Z';
                end generate GEN_memtris;
                
            ReadData <= data;
    end rtl;