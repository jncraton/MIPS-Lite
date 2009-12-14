library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Execute is
    port (clk : in std_logic;
          Operation, Func : in std_logic_vector(5 downto 0);
          read1Data,Read2Data : in std_logic_vector(31 downto 0);
          immediate : in std_logic_vector(31 downto 0);
          shift_amount : in std_logic_vector(31 downto 0);
          -- Control
          ALUSrc : in std_logic_vector(1 downto 0);
          ALUOp : in std_logic_vector(1 downto 0);
         
          ValueOut : out std_logic_vector(31 downto 0));

    end Execute;
    
    architecture rtl of Execute is
        -- ALU
        signal ALU_Value1,ALU_Value2: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal ALU_ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Overflow,ALU_Negative,ALU_Zero,ALU_CarryOut: STD_LOGIC;
        
    begin
            -- ALU
                ALU: entity work.ALU(rtl)
                    port map (ALU_Value1, ALU_Value2, ALU_Operation, ValueOut, 
                              ALU_Overflow,ALU_Negative,ALU_Zero,ALU_CarryOut);

            -- ALU input 1 comes from the register file output 1
                ALU_Value1 <= read1Data;
            
            -- ALUSrc mux - selects the ALU source (2nd one)
                GEN_ALUSrc_mux: for n in 0 to 31 generate
                    ALUSrc_mux: entity work.mux4to1_indiv(rtl)
                        port map(read2Data(n),
                                 immediate(n),
                                 shift_amount(n),
                                 'X',
                                 ALUSrc(0),
                                 ALUSrc(1),
                                 ALU_Value2(n));
                end generate GEN_ALUSrc_mux;
        
            -- ALU control
                ALUcontrol: entity work.ALUControl(rtl)
                    port map (ALUOp,Func,ALU_Operation);
                    
    end rtl;