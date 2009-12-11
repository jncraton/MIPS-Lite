library ieee;
use ieee.std_logic_1164.all;

ENTITY RegFile IS
    PORT(inst_in,next_PC_in,writeReg_in: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
         WE,clock:IN STD_LOGIC;
         writeData:IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         read1Data,read2Data: OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END RegFile;
    
    architecture rtl of RegFile is
    type REGISTERS is array(31 downto 0) of std_logic_vector(31 downto 0); 
    signal register_output:REGISTERS; 
    signal WE_select: std_logic_vector(31 downto 0);
    begin
        -- write reg decoder
        WE_decoder: entity work.decoder5to32(rtl)
            port map(WE, writeReg(4 downto 0), WE_select(31 downto 0));
            
        -- 32 registers
        GEN1: for n in 31 downto 1 generate
            ff: entity work.register32(rtl)
                port map (writeData, WE_select(n), clock, register_output(n)(31 downto 0));
        end generate GEN1;
        
        register_output(0)(31 downto 0) <= x"00000000";
        
        -- reg1 decoder (32 muxes)
        GEN2: for n in 31 downto 0 generate
            mux: entity work.mux32to1(rtl)
                port map (i(0) => register_output(0)(n),
                          i(1) => register_output(1)(n),
                          i(2) => register_output(2)(n),
                          i(3) => register_output(3)(n),
                          i(4) => register_output(4)(n),
                          i(5) => register_output(5)(n),
                          i(6) => register_output(6)(n),
                          i(7) => register_output(7)(n),
                          i(8) => register_output(8)(n),
                          i(9) => register_output(9)(n),
                          i(10) => register_output(10)(n),
                          i(11) => register_output(11)(n),
                          i(12) => register_output(12)(n),
                          i(13) => register_output(13)(n),
                          i(14) => register_output(14)(n),
                          i(15) => register_output(15)(n),
                          i(16) => register_output(16)(n),
                          i(17) => register_output(17)(n),
                          i(18) => register_output(18)(n),
                          i(19) => register_output(19)(n),
                          i(20) => register_output(20)(n),
                          i(21) => register_output(21)(n),
                          i(22) => register_output(22)(n),
                          i(23) => register_output(23)(n),
                          i(24) => register_output(24)(n),
                          i(25) => register_output(25)(n),
                          i(26) => register_output(26)(n),
                          i(27) => register_output(27)(n),
                          i(28) => register_output(28)(n),
                          i(29) => register_output(29)(n),
                          i(30) => register_output(30)(n),
                          i(31) => register_output(31)(n),
                          s => reg1(4 downto 0), o => read1Data(n));
        end generate GEN2;

        -- reg2 decoder (32 muxes)
        GEN3: for n in 31 downto 0 generate
            mux2: entity work.mux32to1(rtl)
                port map (i(0) => register_output(0)(n),
                          i(1) => register_output(1)(n),
                          i(2) => register_output(2)(n),
                          i(3) => register_output(3)(n),
                          i(4) => register_output(4)(n),
                          i(5) => register_output(5)(n),
                          i(6) => register_output(6)(n),
                          i(7) => register_output(7)(n),
                          i(8) => register_output(8)(n),
                          i(9) => register_output(9)(n),
                          i(10) => register_output(10)(n),
                          i(11) => register_output(11)(n),
                          i(12) => register_output(12)(n),
                          i(13) => register_output(13)(n),
                          i(14) => register_output(14)(n),
                          i(15) => register_output(15)(n),
                          i(16) => register_output(16)(n),
                          i(17) => register_output(17)(n),
                          i(18) => register_output(18)(n),
                          i(19) => register_output(19)(n),
                          i(20) => register_output(20)(n),
                          i(21) => register_output(21)(n),
                          i(22) => register_output(22)(n),
                          i(23) => register_output(23)(n),
                          i(24) => register_output(24)(n),
                          i(25) => register_output(25)(n),
                          i(26) => register_output(26)(n),
                          i(27) => register_output(27)(n),
                          i(28) => register_output(28)(n),
                          i(29) => register_output(29)(n),
                          i(30) => register_output(30)(n),
                          i(31) => register_output(31)(n),
                          s => reg2(4 downto 0), o => read2Data(n));
        end generate GEN3;
        
end rtl;
