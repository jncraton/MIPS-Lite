library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity InstructionDecode is
    port (clk : in std_logic;
          PC : in std_logic_vector(31 downto 0);
          inst_data : in std_logic_vector(31 downto 0);
          writeReg : in std_logic_vector(4 downto 0);
          writeData : in std_logic_vector(31 downto 0);
          
          operation : out std_logic_vector(5 downto 0);
          rs,rt,rd : out std_logic_vector(4 downto 0);
          shift_amount : out std_logic_vector(31 downto 0);
          func : out std_logic_vector(5 downto 0);
          jump_address : out std_logic_vector(31 downto 0);
          immediate : out std_logic_vector(31 downto 0);
          immediate_signExtend : out std_logic_vector(31 downto 0);
          Read1Data, Read2Data : out std_logic_vector(31 downto 0);
          InstWriteReg : out std_logic_vector(4 downto 0);
          Branch,MemRead,MemWrite,RegWrite,SignExtend,Halt, IsBranching:OUT STD_LOGIC;
          ALUSrc,MemToReg,RegDst,Jump,ALUOp:OUT STD_LOGIC_VECTOR(1 DOWNTO 0));

    end InstructionDecode;
    
    architecture rtl of InstructionDecode is
        signal rf_reg1, rf_reg2, rf_writeReg : std_logic_vector(4 downto 0);
        signal rf_WE : std_logic;
        signal Branch_i, Equal : std_logic;
        signal rs_i, rt_i, rd_i : std_logic_vector(4 downto 0);
        signal regdst_i : STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal read1Data_i, read2Data_i : std_logic_vector(31 downto 0);
        
    begin
            -- break up intruction instruction
                operation <= inst_data(31 downto 26);
                rs_i <= inst_data(25 downto 21);
                rs <= rs_i;
                rt_i <= inst_data(20 downto 16);
                rt <= rt_i;
                rd_i <= inst_data(15 downto 11);
                rd <= rd_i;
                shift_amount(31 downto 5) <= "000000000000000000000000000";
                shift_amount(4 downto 0) <= inst_data(10 downto 6);
                func <= inst_data(5 downto 0);
                jump_address(31 downto 28) <= PC(31 downto 28);
                jump_address(27 downto 2) <= inst_data(25 downto 0);
                jump_address(1 downto 0) <= "00";
    
                immediate(31 downto 16) <= x"0000";
                immediate(15 downto 0) <= inst_data(15 downto 0);
                GEN_signExtend: for n in 31 downto 16 generate
                    immediate_signExtend(n) <= inst_data(15);
                end generate GEN_signExtend;
                immediate_signExtend(15 downto 0) <= inst_data(15 downto 0);
                
            -- connect halt
                halt <= not (inst_data(31) and inst_data (30) and inst_data(29) and 
                             inst_data(28) and inst_data (27) and inst_data(26));

            -- Register File
                register_file: entity work.RegFile(rtl)
                    port map (rs_i, rt_i, writeReg, rf_WE, clk,                       
                              writeData, read1Data_i, read2Data_i);
                              
                RegWrite <= rf_WE;
                
                read1Data <= read1Data_i;
                read2Data <= read2Data_i;
        
            -- Control
                control: entity work.Control(rtl)
                    port map (inst_data(31 downto 26), inst_data(5 downto 0),
                              Branch_i,MemRead,MemWrite,
                              rf_WE,SignExtend,
                              ALUSrc,MemToReg,RegDst_i,
                              Jump,ALUOp);
                              
            Branch <= Branch_i;
            RegDst <= RegDst_i;
                              
            -- beq comparator
                comparator: entity work.comparator(rtl)
                    port map (read1Data_i, read2Data_i, equal);
                    
            IsBranching <= equal and Branch_i;

            -- writeReg_mux - selects which register should be written to
            GEN_writeReg_mux: for n in 4 downto 0 generate
                writeReg_mux: entity work.mux4to1_indiv(rtl)
                    port map(rt_i(n),
                             rd_i(n),
                             '1', -- R31 for JAL
                             'X',
                             RegDst_i(0),
                             RegDst_i(1),
                             InstWriteReg(n));
            end generate GEN_writeReg_mux;
            
    end rtl;