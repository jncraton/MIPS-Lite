LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

 entity ALUControl_tb is
 end ALUControl_tb;

 architecture behav of ALUControl_tb is
    --  Declaration of the component that will be instantiated.
    component ALUControl
    PORT(ALUOp: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         Func: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
         Operation:OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
    end component;
    --  Specifies which entity is bound with the component.
    for ALUControl_0: ALUControl use entity work.ALUControl;
    signal ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal Func: STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal Operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
 begin
    --  Component instantiation.
    ALUControl_0: ALUControl port map (ALUOp => ALUOp, 
                                 Func => Func,
                                 Operation => Operation);
    --  This process does the real job.
    
    process
        type pattern_type is record
            --  The inputs of the ALUControl.
            ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
            Func: STD_LOGIC_VECTOR(5 DOWNTO 0);
            --  The expected outputs of the ALUControl.
            Operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
         -- ALUOp     Func Operation
            constant patterns : pattern_array :=
          ---- add 10 
          (("10", "100000","000"),
          ---- addi 20
          ("00", "000000","000"),
          ---- ori 30
          ("11", "000000","110"),
          ---- sub 40
          ("10", "100010","100"),
          ---- slt 50
          ("10", "101010","101"),
          ---- j 60
          ("00", "101010","000"),
          ---- nor 70
          ("10", "100111","001"),
          ---- beq 80
          ("01", "000000","100"));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  ALUOp <= patterns(x).ALUOp;
	  Func <= patterns(x).Func;
	  --  Wait for the results.
	  wait for 10 ns;
	  --  Check the outputs.
	  assert Operation = patterns(x).Operation
	     report "Operation Error" & LF &
	      "bad: "&str(Operation) & LF &
	      "exp: "&str(patterns(x).Operation) & LF &
	      "ALUOp: "&str(ALUOp) & LF &
	      "function "&str(Func) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
