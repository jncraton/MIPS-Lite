LIBRARY ieee;
USE ieee.std_logic_1164.all;

 entity mux32to1_tb is
 end mux32to1_tb;

 architecture behav of mux32to1_tb is
    --  Declaration of the component that will be instantiated.
    component mux32to1
      port (i: std_logic_vector(31 downto 0);
            s: std_logic_vector(4 downto 0);
            o: out std_logic);
    end component;
    --  Specifies which entity is bound with the component.
    for mux32to1_0: mux32to1 use entity work.mux32to1;
    signal i: std_logic_vector(31 downto 0);
    signal s: std_logic_vector(4 downto 0);
    signal o: std_logic;
 begin
    --  Component instantiation.
    mux32to1_0: mux32to1 port map (i => i, s => s, o => o);

    --  This process does the real job.
    process
       type pattern_type is record
	  --  The inputs of the mux32to1.
	  i0, i1, i2, i3, i25, s4, s3, s2, s1, s0 : std_logic;
	  --  The expected outputs of the mux32to1.
	  o : std_logic;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
       constant patterns : pattern_array :=
	 (('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'),
	  ('1', '1', '1', '1', '0', '1', '1', '0', '0', '1', '0'),
	  ('1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '1'),
	  ('0', '1', '0', '0', '0', '0', '0', '0', '0', '1', '1'),
	  ('0', '0', '1', '0', '0', '0', '0', '0', '1', '0', '1'),
	  ('0', '0', '0', '1', '0', '0', '0', '0', '1', '1', '1'),
	  ('0', '0', '0', '0', '1', '1', '1', '0', '0', '1', '1'));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  i(0) <= patterns(x).i0;
	  i(1) <= patterns(x).i1;
	  i(2) <= patterns(x).i2;
	  i(3) <= patterns(x).i3;
      i(25) <= patterns(x).i25;
	  s(4) <= patterns(x).s4;
	  s(3) <= patterns(x).s3;
	  s(2) <= patterns(x).s2;
	  s(1) <= patterns(x).s1;
	  s(0) <= patterns(x).s0;
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
