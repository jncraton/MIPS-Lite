library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Register_MEM_WB is
    port (clk : in std_logic;
          ALU_ValueOut_out : out std_logic_vector(31 downto 0);
          ALU_ValueOut     :  in std_logic_vector(31 downto 0);

          MemOutData_out : out std_logic_vector(31 downto 0);
          MemOutData     :  in std_logic_vector(31 downto 0);

          PC_8_out : out std_logic_vector(31 downto 0);
          PC_8     :  in std_logic_vector(31 downto 0);

          WriteReg_out : out std_logic_vector(4 downto 0);
          WriteReg     :  in std_logic_vector(4 downto 0);

          MemToReg_out : out std_logic_vector(1 downto 0);
          MemToReg     :  in std_logic_vector(1 downto 0);
          
          RegWrite_out : out std_logic;
          RegWrite     :  in std_logic);
          
    end Register_MEM_WB;
    
    architecture rtl of Register_MEM_WB is
    begin
        ALU_ValueOut_reg: entity work.register32(rtl)
            port map (ALU_ValueOut, '1', clk, ALU_ValueOut_out, open);        
        MemOutData_reg: entity work.register32(rtl)
            port map (MemOutData, '1', clk, MemOutData_out, open);
        PC_8_reg: entity work.register32(rtl)
            port map (PC_8, '1', clk, PC_8_out, open);        
        WriteReg_reg: entity work.register5(rtl)
            port map (WriteReg, '1', clk, WriteReg_out, open);        
        MemToReg_reg: entity work.register2(rtl)
            port map (MemToReg, '1', clk, MemToReg_out, open);
        RegWrite_reg: entity work.register1(rtl)
            port map (RegWrite, '1', clk, RegWrite_out, open);        
        
    end rtl;