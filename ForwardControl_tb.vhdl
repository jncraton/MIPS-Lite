LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

 entity ForwardControl_tb is
 end ForwardControl_tb;

 architecture behav of ForwardControl_tb is
    --  Declaration of the component that will be instantiated.
    component ForwardControl
        port (clk : in std_logic;
              reset : in std_logic;
              EX_MEM_rd : in std_logic_vector(4 downto 0);
              MEM_WB_rd : in std_logic_vector(4 downto 0);
              MEM_WB_RegWrite : in std_logic;
              ID_EX_rs : in std_logic_vector(4 downto 0);
              ID_EX_rt : in std_logic_vector(4 downto 0);
              EX_MEM_RegWrite : in std_logic;
    
              ForwardA : out std_logic_vector(1 downto 0);
              ForwardB : out std_logic_vector(1 downto 0));
    end component;
    --  Specifies which entity is bound with the component.
    for ForwardControl_0: ForwardControl use entity work.ForwardControl;
    signal EX_MEM_rd,MEM_WB_rd,ID_EX_rs,ID_EX_rt: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal clk,reset,MEM_WB_RegWrite,EX_MEM_RegWrite: STD_LOGIC;
    signal ForwardA,ForwardB: STD_LOGIC_VECTOR(1 DOWNTO 0);
 begin
    --  Component instantiation.
    ForwardControl_0: ForwardControl port map (clk => clk, 
                                                 reset => reset,
                                                 EX_MEM_rd => EX_MEM_rd,
                                                 MEM_WB_rd => MEM_WB_rd,
                                                 MEM_WB_RegWrite => MEM_WB_RegWrite,
                                                 ID_EX_rs => ID_EX_rs,
                                                 ID_EX_rt => ID_EX_rt,
                                                 EX_MEM_RegWrite => EX_MEM_RegWrite,
                                                 ForwardA => ForwardA,
                                                 ForwardB => ForwardB);
    --  This process does the real job.
    
    process
       type pattern_type is record
	  --  The inputs of the ForwardControl.
      EX_MEM_rd,MEM_WB_rd,ID_EX_rs,ID_EX_rt: STD_LOGIC_VECTOR(4 DOWNTO 0);
      MEM_WB_RegWrite,EX_MEM_RegWrite: STD_LOGIC;
	  --  The expected outputs of the ForwardControl.
      ForwardA,ForwardB: STD_LOGIC_VECTOR(1 DOWNTO 0);
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
     -- EX_MEM_rd MEM_WB_rd ID_EX_rs ID_EX_rt MEM_WB_RegWrite EX_MEM_RegWrite  A     B
        constant patterns : pattern_array :=
	 (("00000",  "00000",  "00000", "00000", '0',             '0',            "00","00"),
	  ("00000",  "00000",  "00000", "00000", '0',             '0',            "00","00"),
	  ("00000",  "00000",  "00000", "00000", '0',             '0',            "00","00"));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  EX_MEM_rd <= patterns(x).EX_MEM_rd;
	  MEM_WB_rd <= patterns(x).MEM_WB_rd;
	  ID_EX_rs <= patterns(x).ID_EX_rs;
	  ID_EX_rt <= patterns(x).ID_EX_rt;
	  MEM_WB_RegWrite <= patterns(x).MEM_WB_RegWrite;
	  EX_MEM_RegWrite <= patterns(x).EX_MEM_RegWrite;
	  --  Wait for the results.
	  wait for 2.2 ns;
	  --  Check the outputs.
	  assert ForwardA = patterns(x).ForwardA
	     report "Error" & LF &
	      "bad: "&str(ForwardA) severity error;
	  assert ForwardB = patterns(x).ForwardB
	     report "Error" & LF &
	      "bad: "&str(ForwardB) severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
