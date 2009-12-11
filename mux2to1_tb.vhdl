library ieee;
use  ieee.std_logic_1164.all;

 entity mux2to1_tb is
 end mux2to1_tb;

 architecture behav of mux2to1_tb is
    --  Declaration of the component that will be instantiated.
    component mux2to1
      port (i: std_logic_vector(1 downto 0);
            s : in std_logic; o : out std_logic);
    end component;
    --  Specifies which entity is bound with the component.
    for mux2to1_0: mux2to1 use entity work.mux2to1;
    signal i: std_logic_vector(1 downto 0);
    signal s, o : std_logic;
 begin
    --  Component instantiation.
    mux2to1_0: mux2to1 port map (i(0) => i(0), i(1) => i(1), s => s, o => o);

    --  This process does the real job.
    process
       type pattern_type is record
	  --  The inputs of the mux2to1.
	  i0, i1, s : std_logic;
	  --  The expected outputs of the mux2to1.
	  o : std_logic;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
       constant patterns : pattern_array :=
	 (('0', '0', '0', '0'),
	  ('0', '0', '1', '0'),
	  ('0', '1', '0', '0'),
	  ('0', '1', '1', '1'),
	  ('1', '0', '0', '1'),
	  ('1', '0', '1', '0'),
	  ('1', '1', '0', '1'),
	  ('1', '1', '1', '1'));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  i(0) <= patterns(x).i0;
	  i(1) <= patterns(x).i1;
	  s <= patterns(x).s;
	  --  Wait for the results.
	  wait for 1 ns;
	  --  Check the outputs.
	  assert o = patterns(x).o
	     report "bad output" severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
