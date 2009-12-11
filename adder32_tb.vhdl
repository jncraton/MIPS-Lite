LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

 entity adder32_tb is
 end adder32_tb;

 architecture behav of adder32_tb is
    --  Declaration of the component that will be instantiated.
    component adder32
        port (i0, i1 : in std_logic_vector(31 downto 0);
              ci : in std_logic;
              s : out std_logic_vector(31 downto 0);
              co : out std_logic);
    end component;
    --  Specifies which entity is bound with the component.
    for adder32_0: adder32 use entity work.adder32;
    signal i0,i1,s: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal ci,co: STD_LOGIC;
 begin
    --  Component instantiation.
    adder32_0: adder32 port map (i0 => i0, 
                                 i1 => i1,
                                 ci => ci,
                                 s => s,
                                 co => co);
    --  This process does the real job.
    
    process
       type pattern_type is record
	  --  The inputs of the adder32.
	  i0, i1: std_logic_vector(31 downto 0);
      ci: std_logic;
	  --  The expected outputs of the adder32.
      s : std_logic_vector (31 downto 0);
      co : std_logic;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
     -- i0       i1               ci    s           co
        constant patterns : pattern_array :=
	 ((x"00000000", x"00000000", '0', x"00000000", '0'),
      (x"00000001", x"00000001", '0', x"00000002", '0'),
      (x"80000001", x"80000001", '0', x"00000002", '1'),
      (x"80000001", x"80000001", '1', x"00000000", '0'),
      (x"FFFFFFFF", x"00000001", '0', x"00000000", '1'),
      (x"00001000", x"00001000", '0', x"00002000", '0'));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  i0 <= patterns(x).i0;
	  i1 <= patterns(x).i1;
	  ci <= patterns(x).ci;
	  --  Wait for the results.
	  wait for 2.2 ns;
	  --  Check the outputs.
	  assert s = patterns(x).s
	     report "Sum Error" & LF &
	      "bad: "&str(s) & LF &
	      "exp: "&str(patterns(x).s) & LF &
	      "i0: "&str(i0) & LF &
	      "i1: "&str(i1) & LF &
	      "ci: "&str(ci) & LF &
	      "s: "&str(s) & LF &
	      "co: "&str(co) & LF severity error;
	  assert co = patterns(x).co
	     report "Carry Out Error" & LF &
	      "bad: "&str(co) & LF &
	      "exp: "&str(patterns(x).co) & LF &
	      "i0: "&str(i0) & LF &
	      "i1: "&str(i1) & LF &
	      "ci: "&str(ci) & LF &
	      "s: "&str(s) & LF &
	      "co: "&str(co) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
