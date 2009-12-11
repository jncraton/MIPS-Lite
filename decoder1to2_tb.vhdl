library ieee;
use  ieee.std_logic_1164.all;

 entity decoder1to2_tb is
 end decoder1to2_tb;

 architecture behav of decoder1to2_tb is
    --  Declaration of the component that will be instantiated.
    component decoder1to2
      port (i: std_logic;
            s : in std_logic; 
            o : out std_logic_vector(1 downto 0));
    end component;
    --  Specifies which entity is bound with the component.
    for decoder1to2_0: decoder1to2 use entity work.decoder1to2;
    signal s, i : std_logic;
    signal o: std_logic_vector(1 downto 0);
 begin
    --  Component instantiation.
    decoder1to2_0: decoder1to2 port map (o => o, i => i, s => s);

    --  This process does the real job.
    process
       type pattern_type is record
	  --  The inputs of the decoder1to2.
	  i, s : std_logic;
	  --  The expected outputs of the decoder1to2.
	  o0, o1 : std_logic;
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
       constant patterns : pattern_array :=
	 (('0', '0', '0', '0'),
	  ('0', '1', '0', '0'),
	  ('1', '0', '1', '0'),
	  ('1', '1', '0', '1'));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  i <= patterns(x).i;
	  s <= patterns(x).s;
	  --  Wait for the results.
	  wait for 1 ns;
	  --  Check the outputs.
	  assert o(0) = patterns(x).o0
	     report "bad output" severity error;
	  assert o(1) = patterns(x).o1
	     report "bad output" severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
