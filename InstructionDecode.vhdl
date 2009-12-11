library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity InstructionDecode is
    port (clk : in std_logic;
          next_PC : in std_logic_vector(31 downto 0);
          inst, PC, PC_4, PC_8 : out std_logic_vector(31 downto 0));
    end InstructionDecode;
    
    architecture rtl of InstructionDecode is
        signal PC_val: std_logic_vector(31 downto 0);

        signal inst_data: std_logic_vector(31 downto 0);
        signal inst_nwe: std_logic;
        signal inst_noe: std_logic;
        signal inst_ncs: std_logic;
        
    begin
            -- break up intruction instruction
                operation <= inst_data(31 downto 26);
                rs <= inst_data(25 downto 21);
                rt <= inst_data(20 downto 16);
                rd <= inst_data(15 downto 11);
                shift_amount(31 downto 5) <= "000000000000000000000000000";
                shift_amount(4 downto 0) <= inst_data(10 downto 6);
                func <= inst_data(5 downto 0);
                jump_address(31 downto 28) <= PC(31 downto 28);
                jump_address(27 downto 2) <= inst_data(25 downto 0);
                jump_address(1 downto 0) <= "00";
    
                immediate(31 downto 16) <= x"0000";
                immediate(15 downto 0) <= inst_data(15 downto 0);
                GEN_signExtend: for n in 31 downto 16 generate
                    immediate_signExtend(n) <= immediate(15);
                end generate GEN_signExtend;
                immediate_signExtend(15 downto 0) <= inst_data(15 downto 0);
                
            -- connect halt
                halt <= not (operation(0) and operation (1) and operation(2) and 
                             operation(3) and operation (4) and operation(5));

            -- Register File
                register_file: entity work.RegFile(rtl)
                    port map (rf_reg1, rf_reg2, rf_writeReg, rf_WE, clk,                       
                              rf_writeData, rf_read1Data, rf_read2Data);
        
                rf_WE <= ctrl_RegWrite;
    end rtl;