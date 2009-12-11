LIBRARY ieee;
USE ieee.std_logic_1164.all;

 entity decoder5to32_tb is
 end decoder5to32_tb;

 architecture behav of decoder5to32_tb is
    --  Declaration of the component that will be instantiated.
    component decoder5to32
      port (i: std_logic;
            s: std_logic_vector(4 downto 0);
            o: out std_logic_vector(31 downto 0));
    end component;
    --  Specifies which entity is bound with the component.
    for decoder5to32_0: decoder5to32 use entity work.decoder5to32;
    signal i: std_logic;
    signal s: std_logic_vector(4 downto 0);
    signal o: std_logic_vector(31 downto 0);
 begin
    --  Component instantiation.
    decoder5to32_0: decoder5to32 port map (i => i, s => s, o => o);

    --  This process does the real job.
    process
       type pattern_type is record
	  --  The inputs of the decoder5to32.
	  i,s4,s3, s2, s1, s0 : std_logic;
	  --  The expected outputs of the decoder5to32.
	  o0, o1, o2, o3, o12, o31 : std_logic;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
    --  i    s4   s3   s2   s1  s0   o0    o1   o2   o3   o12  o31
       constant patterns : pattern_array :=
	 (('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'),
	  ('1', '0', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0'),
	  ('1', '0', '0', '0', '0', '1', '0', '1', '0', '0', '0', '0'),
	  ('1', '0', '0', '0', '1', '0', '0', '0', '1', '0', '0', '0'),
	  ('1', '0', '0', '0', '1', '1', '0', '0', '0', '1', '0', '0'),
	  ('1', '0', '1', '1', '0', '0', '0', '0', '0', '0', '1', '0'),
	  ('1', '1', '1', '1', '1', '1', '0', '0', '0', '0', '0', '1'),
	  ('0', '1', '1', '1', '1', '1', '0', '0', '0', '0', '0', '0'));
    begin
      --  Check each pattern.
      for x in patterns'range loop
	  --  Set the inputs.
	  i <= patterns(x).i;
	  s(0) <= patterns(x).s0;
	  s(1) <= patterns(x).s1;
	  s(2) <= patterns(x).s2;
	  s(3) <= patterns(x).s3;
	  s(4) <= patterns(x).s4;
	  --  Wait for the results.
	  wait for 1 ns;
	  --  Check the outputs.
	  assert true --i = patterns(x).i;
	     report "bad output on 0" severity error;
	  assert o(0) = patterns(x).o0
	     report "bad output on 0" severity error;
	  assert o(1) = patterns(x).o1
	     report "bad output on 1" severity error;
	  assert o(2) = patterns(x).o2
	     report "bad output on 2" severity error;
	  assert o(3) = patterns(x).o3
	     report "bad output on 3" severity error;
	  assert o(12) = patterns(x).o12
	     report "bad output on 12" severity error;
	  assert o(31) = patterns(x).o31
	     report "bad output on 31" severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
