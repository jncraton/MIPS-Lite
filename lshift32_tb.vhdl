LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

entity lshift32_tb is
end lshift32_tb;

 architecture behav of lshift32_tb is
    --  Declaration of the component that will be instantiated.
    component lshift32
    port (i : in std_logic_vector(31 downto 0);
             sa : in std_logic_vector(4 downto 0);
             o : out std_logic_vector(31 downto 0));    
    end component;
    --  Specifies which entity is bound with the component.
    for lshift32_0: lshift32 use entity work.lshift32;
    signal i,o: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sa: STD_LOGIC_vector(4 downto 0);
 begin
    --  Component instantiation.
    lshift32_0: lshift32 port map (i => i, sa => sa, o => o);
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
      (x"00000001", "00001", x"00000002"),
      (x"00001000", "00010", x"00004000"),
      (x"00001000", "00100", x"00010000"),
      (x"00001000", "00001", x"00002000"),
      (x"10000001", "00001", x"20000002"));

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
