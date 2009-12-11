LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity ALU_tb is
end ALU_tb;

 architecture behav of ALU_tb is
    --  Declaration of the component that will be instantiated.
    component ALU
    port(Value1,Value2:IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         Operation:IN STD_LOGIC_VECTOR(2 DOWNTO 0);
         ValueOut:OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         Overflow,Negative,Zero,CarryOut:OUT STD_LOGIC);
    end component;
    --  Specifies which entity is bound with the component.
    for ALU_0: ALU use entity work.ALU;
    signal Value1,Value2,ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal Operation: STD_LOGIC_vector(2 downto 0);
    signal Overflow,Negative,Zero,CarryOut: STD_LOGIC;
 begin
    --  Component instantiation.
    ALU_0: ALU port map (Value1 => Value1,
                             Value2 => Value2,
                             Operation => Operation,
                             ValueOut => ValueOut,
                             Overflow => Overflow,
                             Negative => Negative,
                             Zero => Zero,
                             CarryOut => CarryOut);
    --  This process does the real job.
    
    process
       type pattern_type is record
         Value1,Value2: STD_LOGIC_VECTOR(31 DOWNTO 0);
         Operation: STD_LOGIC_vector(2 downto 0);
         ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
         Overflow,Negative,Zero,CarryOut: STD_LOGIC;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        -- Value 1      Value 2     Op      ValueOut    O    N    Z    C
        -- Add
       ((x"00000000", x"00000000", "000", x"00000000", '0', '0', '1', '0'),
        (x"00000001", x"00000001", "000", x"00000002", '0', '0', '0', '0'),
        (x"FFFFFFFE", x"00000001", "000", x"FFFFFFFF", '0', '1', '0', '0'),
        (x"FFFFFFFF", x"00000001", "000", x"00000000", '1', '0', '1', '1'),
        -- Subtract
        (x"00000010", x"00000010", "100", x"00000000", '0', '0', '1', '0'),
        (x"00000200", x"00000100", "100", x"00000100", '0', '0', '0', '0'),
        (x"00000400", x"00000100", "100", x"00000300", '0', '0', '0', '0'),
        -- NOR
        (x"66666666", x"55555555", "001", x"88888888", '0', '1', '0', '0'),
        -- OR
        (x"f0f0f0f0", x"0f0f0f0f", "110", x"ffffffff", '0', '1', '0', '0'),
        -- Left Shift
        (x"00000001", x"00000004", "010", x"00000010", '0', '0', '0', '0'),
        (x"00000001", x"00000001", "010", x"00000002", '0', '0', '0', '0'),
        -- Right Shift
        (x"80000000", x"00000004", "011", x"08000000", '0', '0', '0', '0'),
        (x"80000000", x"00000001", "011", x"40000000", '0', '0', '0', '0'),
        -- Set Less Than
        (x"00000000", x"00000001", "101", x"00000001", '0', '0', '0', '0'),
        (x"00000020", x"00000001", "101", x"00000000", '0', '0', '1', '0'),
        (x"00000040", x"00000040", "101", x"00000000", '0', '0', '1', '0'),


        (x"00000000", x"00000000", "000", x"00000000", '0', '0', '1', '0'));
    begin
       --  Check each pattern.
       for x in patterns'range loop
      --  Set the inputs.
      Value1 <= patterns(x).Value1;
      Value2 <= patterns(x).Value2;
      Operation <= patterns(x).Operation;
      --  Wait for the results.
      wait for 10.0 ns;
      --  Check the outputs.
      assert ValueOut = patterns(x).ValueOut
         report "Output Error" & LF &
          "bad: "&str(ValueOut) & LF &
          "exp: "&str(patterns(x).ValueOut) & LF severity error;
      assert Zero = patterns(x).Zero
         report "Zero Error" & LF &
          "bad: "&str(Zero) & LF &
          "exp: "&str(patterns(x).Zero) & LF severity error;
      assert Negative = patterns(x).Negative
         report "Negative Error" & LF &
          "bad: "&str(Negative) & LF &
          "exp: "&str(patterns(x).Negative) & LF severity error;
      assert CarryOut = patterns(x).CarryOut
         report "CarryOut Error" & LF &
          "bad: "&str(CarryOut) & LF &
          "exp: "&str(patterns(x).CarryOut) & LF severity error;
      assert Overflow = patterns(x).Overflow
         report "Overflow Error" & LF &
          "bad: "&str(Overflow) & LF &
          "exp: "&str(patterns(x).Overflow) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
