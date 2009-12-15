library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Register_EX_MEM is
    port (clk : in std_logic;
          ALU_ValueOut_out : out std_logic_vector(31 downto 0);
          ALU_ValueOut     :  in std_logic_vector(31 downto 0);

          read2Data_out : out std_logic_vector(31 downto 0);
          read2Data     :  in std_logic_vector(31 downto 0);

          PC_8_out : out std_logic_vector(31 downto 0);
          PC_8     :  in std_logic_vector(31 downto 0);

          WriteReg_out : out std_logic_vector(4 downto 0);
          WriteReg     :  in std_logic_vector(4 downto 0);

          MemWrite_out : out std_logic;
          MemWrite     :  in std_logic;

          MemRead_out : out std_logic;
          MemRead     :  in std_logic;

          RegWrite_out : out std_logic;
          RegWrite     :  in std_logic;

          MemToReg_out : out std_logic_vector(1 downto 0);
          MemToReg     :  in std_logic_vector(1 downto 0));
    end Register_EX_MEM;
    
    architecture rtl of Register_EX_MEM is
    begin
        ALU_ValueOut_reg: entity work.register32(rtl)
            port map (ALU_ValueOut, '1', clk, ALU_ValueOut_out, open);        
        read2Data_reg: entity work.register32(rtl)
            port map (read2Data, '1', clk, read2Data_out, open);
        PC_8_reg: entity work.register32(rtl)
            port map (PC_8, '1', clk, PC_8_out, open);        
        WriteReg_reg: entity work.register5(rtl)
            port map (WriteReg, '1', clk, WriteReg_out, open);        
        MemWrite_reg: entity work.register1(rtl)
            port map (MemWrite, '1', clk, MemWrite_out, open);        
        MemRead_reg: entity work.register1(rtl)
            port map (MemRead, '1', clk, MemRead_out, open); 
        RegWrite_reg: entity work.register1(rtl)
            port map (RegWrite, '1', clk, RegWrite_out, open);        
        MemToReg_reg: entity work.register2(rtl)
            port map (MemToReg, '1', clk, MemToReg_out, open);        
    end rtl;