library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    port(Value1,Value2:IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         Operation:IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         ValueOut:OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         Overflow,Negative,Zero,CarryOut:OUT STD_LOGIC);
end ALU;
    
architecture rtl of ALU is
    signal adder_out: std_logic_vector(31 downto 0);
    signal adder_carry: std_logic;
    signal lshift_out: std_logic_vector(31 downto 0);
    signal rshift_out: std_logic_vector(31 downto 0);
    signal nor_out: std_logic_vector(31 downto 0);
    signal or_out: std_logic_vector(31 downto 0);
    signal slt_out: std_logic_vector(31 downto 0);
    signal intermediate_out: std_logic_vector(31 downto 0);
    signal tmp1_out: std_logic_vector(31 downto 0);
    
    begin
        -- adder
        adder32: entity work.adder32(rtl)
            port map (Value1, Value2, Operation(2), adder_out, adder_carry);
    
        -- left shift
        lshift32: entity work.lshift32(rtl)
            port map (Value1, Value2(4 downto 0), lshift_out);
        
        -- right shift
        rshift32: entity work.rshift32(rtl)
            port map (Value1, Value2(4 downto 0), rshift_out);
        
        -- NOR
        GEN_nor: for n in 0 to 31 generate
            nor_out(n) <= not (Value1(n) or Value2(n)) after 35 ps;
        end generate GEN_nor;

        -- OR
        GEN_or: for n in 0 to 31 generate
            or_out(n) <= (Value1(n) or Value2(n)) after 35 ps;
        end generate GEN_or;

        -- Set Less Than
        -- All bits but least significant are zero
        GEN_slt: for n in 1 to 31 generate
            slt_out(n) <= '0';
        end generate GEN_slt;
        
        -- Least significant is the sign bit from adder
        -- If the sign is negative, then Value1 is less than Value2
        slt_out(0) <= adder_out(31);
        
        -- Connect ValueOut based on Operation
        GEN_connect: for n in 0 to 31 generate
            intermediate_out(n) <= (adder_out(n) and not Operation(0) and not Operation(1)) or
                           (lshift_out(n) and Operation(1) and not Operation(0)) or 
                           (rshift_out(n) and Operation(1) and Operation(0)) or
                           (nor_out(n) and not Operation(2) and not Operation(1) and Operation(0)) or
                           (or_out(n) and Operation(2) and Operation(1) and not Operation(0)) or
                           (slt_out(n) and Operation(2) and not Operation(1) and Operation(0))
                            after 105 ps;
        end generate GEN_connect;
        
        ValueOut <= intermediate_out;
        
        -- Calculate Zero based on ValueOut
        logical_not: entity work.logical_not(rtl)
            port map (intermediate_out, tmp1_out);

        Zero <= tmp1_out(0);
        
        -- Calculate Negative based on MSB of ValueOut
        Negative <= intermediate_out(31);

        -- Calculate CarryOut
        -- This may need to include negative somehow
        CarryOut <= adder_carry
                    and not Operation(0)
                    and not Operation(1)
                    and not Operation(2);

        -- Calculate Overflow
        -- This is wrong
        -- It doesn't account for shifting
        Overflow <= adder_carry
                    and not Operation(0)
                    and not Operation(1)
                    and not Operation(2);
                    
    end rtl;
