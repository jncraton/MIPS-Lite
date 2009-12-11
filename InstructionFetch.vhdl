library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity InstructionFetch is
    port (clk : in std_logic;
          next_PC : in std_logic_vector(31 downto 0);
          inst, PC, PC_4, PC_8 : out std_logic_vector(31 downto 0));
    end InstructionFetch;
    
    architecture rtl of InstructionFetch is
        signal PC_val: std_logic_vector(31 downto 0);

        signal inst_data: std_logic_vector(31 downto 0);
        signal inst_nwe: std_logic;
        signal inst_noe: std_logic;
        signal inst_ncs: std_logic;
        
    begin
            -- PC
                PC_register: entity work.register32(rtl)
                    port map (next_PC, '1', clk, PC_val, open);
                PC <= PC_val;
    
            -- Instruction Memory
                inst_memory: entity work.sram64kx8(sram_behaviour)
                    port map (inst_ncs, PC_val, inst_data, inst_nwe, inst_noe);
                
                    -- never write to instruction memory
                    inst_nwe <= '1';
                    inst_noe <= '0';
                    inst_ncs <= '1' when PC_val(0)='U' else '0';
                    
                    inst <= inst_data;
                    
            -- PC adder - adds 4 to the PC
                PC_adder: entity work.adder32(rtl)
                    port map(PC_val, x"00000004",
                             -- carry in is 0
                             '0',
                             PC_4,
                             open);
            
            -- PC adder8 - adds 8 to the PC
                PC_adder8: entity work.adder32(rtl)
                    port map(PC_val, x"00000008",
                             -- carry in is 0
                             '0',
                             PC_8,
                             open);
    end rtl;