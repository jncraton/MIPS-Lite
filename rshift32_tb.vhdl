LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity rshift32_tb is
end rshift32_tb;

 architecture behav of rshift32_tb is
    --  Declaration of the component that will be instantiated.
    component rshift32
    port (i : in std_logic_vector(31 downto 0);
             sa : in std_logic_vector(4 downto 0);
             o : out std_logic_vector(31 downto 0));    
    end component;
    --  Specifies which entity is bound with the component.
    for rshift32_0: rshift32 use entity work.rshift32;
    signal i,o: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sa: STD_LOGIC_vector(4 downto 0);
 begin
    --  Component instantiation.
    rshift32_0: rshift32 port map (i => i, sa => sa, o => o);
    --  This process does the real job.
    
    process
       type pattern_type is record
         i: std_logic_vector(31 downto 0);
         sa: std_logic_vector(4 downto 0);
         o: std_logic_vector(31 downto 0);
        
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
     ((x"00000000", "00000", x"00000000"),
      (x"80000001", "00000", x"80000001"),
      (x"80000000", "00001", x"40000000"),
      (x"80800001", "00001", x"40400000"));
    begin
       --  Check each pattern.
       for x in patterns'range loop
      --  Set the inputs.
      i <= patterns(x).i;
      sa <= patterns(x).sa;
      --  Wait for the results.
      wait for 2.2 ns;
      --  Check the outputs.
      assert o = patterns(x).o
         report "Output Error" & LF &
          "bad: "&str(o) & LF &
          "exp: "&str(patterns(x).o) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
