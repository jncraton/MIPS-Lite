library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Register_IF_ID is
    port (clk : in std_logic;
          inst : in std_logic_vector(31 downto 0);
          inst_out : out std_logic_vector(31 downto 0);

          PC : in std_logic_vector(31 downto 0);
          PC_out : out std_logic_vector(31 downto 0);

          PC_4 : in std_logic_vector(31 downto 0);
          PC_4_out : out std_logic_vector(31 downto 0);

          PC_8 : in std_logic_vector(31 downto 0);
          PC_8_out : out std_logic_vector(31 downto 0));
          
    end Register_IF_ID;
    
    architecture rtl of Register_IF_ID is
    begin
        inst_reg: entity work.register32(Behavior)
            port map (inst, '1', clk, inst_out, open);        
        PC_reg: entity work.register32(Behavior)
            port map (PC, '1', clk, PC_out, open);        
        PC_4_reg: entity work.register32(Behavior)
            port map (PC_4, '1', clk, PC_4_out, open);        
        PC_8_reg: entity work.register32(Behavior)
            port map (PC_8, '1', clk, PC_8_out, open);        
    end rtl;