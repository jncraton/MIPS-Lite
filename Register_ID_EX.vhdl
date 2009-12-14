library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Register_ID_EX is
    port (clk : in std_logic;
          Operation_out : out std_logic_vector(5 downto 0);
          Operation : in std_logic_vector(5 downto 0);

          func_out : out std_logic_vector(5 downto 0);
          func     :  in std_logic_vector(5 downto 0);

          shift_amount_out : out std_logic_vector(31 downto 0);
          shift_amount     :  in std_logic_vector(31 downto 0);

          immediate_out : out std_logic_vector(31 downto 0);
          immediate     :  in std_logic_vector(31 downto 0);

          read1Data_out : out std_logic_vector(31 downto 0);
          read1Data     :  in std_logic_vector(31 downto 0);

          read2Data_out : out std_logic_vector(31 downto 0);
          read2Data     :  in std_logic_vector(31 downto 0);

          PC_8_out : out std_logic_vector(31 downto 0);
          PC_8     :  in std_logic_vector(31 downto 0);

          WriteReg_out : out std_logic_vector(4 downto 0);
          WriteReg     :  in std_logic_vector(4 downto 0);

          ALUSrc_out : out std_logic_vector(1 downto 0);
          ALUSrc     :  in std_logic_vector(1 downto 0);

          ALUOp_out : out std_logic_vector(1 downto 0);
          ALUOp     :  in std_logic_vector(1 downto 0);

          MemWrite_out : out std_logic;
          MemWrite     :  in std_logic;

          MemRead_out : out std_logic;
          MemRead     :  in std_logic;

          MemToReg_out : out std_logic_vector(1 downto 0);
          MemToReg     :  in std_logic_vector(1 downto 0);

          NextPC_out : out std_logic_vector(31 downto 0);
          NextPC     :  in std_logic_vector(31 downto 0));
    end Register_ID_EX;
    
    architecture rtl of Register_ID_EX is
    begin
        Operation_reg: entity work.register6(rtl)
            port map (Operation, '1', clk, Operation_out, open);
        Func_reg: entity work.register6(rtl)
            port map (Func, '1', clk, Func_out, open);
        shift_amount_reg: entity work.register32(rtl)
            port map (shift_amount, '1', clk, shift_amount_out, open);
        immediate_reg: entity work.register32(rtl)
            port map (immediate, '1', clk, immediate_out, open);
        read1Data_reg: entity work.register32(rtl)
            port map (read1Data, '1', clk, read1Data_out, open);
        read2Data_reg: entity work.register32(rtl)
            port map (read2Data, '1', clk, read2Data_out, open);
        PC_8_reg: entity work.register32(rtl)
            port map (PC_8, '1', clk, PC_8_out, open);        
        WriteReg_reg: entity work.register5(rtl)
            port map (WriteReg, '1', clk, WriteReg_out, open);        
        ALUSrc_reg: entity work.register2(rtl)
            port map (ALUSrc, '1', clk, ALUSrc_out, open);        
        ALUOp_reg: entity work.register2(rtl)
            port map (ALUOp, '1', clk, ALUOp_out, open);        
        MemWrite_reg: entity work.register1(rtl)
            port map (MemWrite, '1', clk, MemWrite_out, open);        
        MemRead_reg: entity work.register1(rtl)
            port map (MemRead, '1', clk, MemRead_out, open);        
        MemToReg_reg: entity work.register2(rtl)
            port map (MemToReg, '1', clk, MemToReg_out, open);
        NextPC_reg: entity work.register32(rtl)
            port map (NextPC, '1', clk, NextPC_out, open);        
        
    end rtl;