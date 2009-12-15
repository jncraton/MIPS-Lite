library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity ForwardControl is
    port (clk : in std_logic;
          reset : in std_logic;
          EX_MEM_rd : in std_logic_vector(4 downto 0);
          MEM_WB_rd : in std_logic_vector(4 downto 0);
          MEM_WB_RegWrite : in std_logic;
          ID_EX_rs : in std_logic_vector(4 downto 0);
          ID_EX_rt : in std_logic_vector(4 downto 0);
          EX_MEM_RegWrite : in std_logic;

          ForwardA : out std_logic_vector(1 downto 0);
          ForwardB : out std_logic_vector(1 downto 0));
    end ForwardControl;
    
    architecture rtl of ForwardControl is
    signal cmp1, cmp2, cmp3, cmp4 : std_logic;
    begin
        comparator_1: entity work.comparator5(rtl)
            port map (EX_MEM_rd, ID_EX_rs, cmp1);
        ForwardA(1) <= cmp1 and EX_MEM_RegWrite;

        comparator_2: entity work.comparator5(rtl)
            port map (EX_MEM_rd, ID_EX_rt, cmp2);
        ForwardB(1) <= cmp2 and EX_MEM_RegWrite;
            
        comparator_3: entity work.comparator5(rtl)
            port map (MEM_WB_rd, ID_EX_rs, cmp3);
        ForwardA(0) <= cmp3 and MEM_WB_RegWrite;

        comparator_4: entity work.comparator5(rtl)
            port map (MEM_WB_rd, ID_EX_rt, cmp3);
        ForwardB(0) <= cmp4 and MEM_WB_RegWrite;

    end rtl;