library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity Writeback is
    port (clk : in std_logic;
          ALU_ValueOut : in std_logic_vector(31 downto 0);
          MemOutData : in std_logic_vector(31 downto 0);
          PC_8 : in std_logic_vector(31 downto 0);
          MemToReg : in std_logic_vector(1 downto 0);
          
          WriteData : out std_logic_vector(31 downto 0));

    end Writeback;
    
    architecture rtl of Writeback is
    begin
            -- GEN_rf_writeData_mux selects data input for reg file
                GEN_rf_writeData_mux: for n in 0 to 31 generate
                    rf_writeData_mux: entity work.mux4to1_indiv(rtl)
                        port map(ALU_ValueOut(n),
                                 MemOutData(n),
                                 PC_8(n),
                                 '1',
                                 MemToReg(0),
                                 MemToReg(1),
                                 WriteData(n));
                end generate GEN_rf_writeData_mux;
    end rtl;