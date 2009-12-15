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
          WB_WriteData : in std_logic_vector(31 downto 0);
          MEM_ALU_ValueOut : in std_logic_vector(31 downto 0);
          -- Control
          ALUSrc : in std_logic_vector(1 downto 0);
          ALUOp : in std_logic_vector(1 downto 0);
          ForwardA : in std_logic_vector(1 downto 0);
          ForwardB : in std_logic_vector(1 downto 0);
         
          ValueOut : out std_logic_vector(31 downto 0));

    end Execute;
    
    architecture rtl of Execute is
        -- ALU
        signal ALU_Value1,ALU_Value2: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal ALU_ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Overflow,ALU_Negative,ALU_Zero,ALU_CarryOut: STD_LOGIC;
        signal ALU_Value1Fwd: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Value2Fwd: STD_LOGIC_VECTOR(31 DOWNTO 0);
        
    begin
            -- ALU
                ALU: entity work.ALU(rtl)
                    port map (ALU_Value1, ALU_Value2, ALU_Operation, ValueOut, 
                              ALU_Overflow,ALU_Negative,ALU_Zero,ALU_CarryOut);

            -- ALUForwardA mux - selects the ALU source for forwarding
                GEN_ALUForwardA_mux: for n in 0 to 31 generate
                    ALUForwardA_mux: entity work.mux4to1_indiv(rtl)
                        port map(read1Data(n),
                                 WB_WriteData(n),
                                 MEM_ALU_ValueOut(n),
                                 'X',
                                 ForwardA(0),
                                 ForwardA(1),
                                 ALU_Value1(n));
                end generate GEN_ALUForwardA_mux;

            -- ALUForwardB mux - selects the ALU source for forwarding
                GEN_ALUForwardB_mux: for n in 0 to 31 generate
                    ALUForwardB_mux: entity work.mux4to1_indiv(rtl)
                        port map(read2Data(n),
                                 WB_WriteData(n),
                                 MEM_ALU_ValueOut(n),
                                 'X',
                                 ForwardB(0),
                                 ForwardB(1),
                                 ALU_Value2Fwd(n));
                end generate GEN_ALUForwardB_mux;

            -- ALU input 1 comes from the register file output 1
                --ALU_Value1 <= read1Data;
            
            -- ALUSrc mux - selects the ALU source (2nd one)
                GEN_ALUSrc_mux: for n in 0 to 31 generate
                    ALUSrc_mux: entity work.mux4to1_indiv(rtl)
                        port map(ALU_Value2Fwd(n),
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