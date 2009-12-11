LIBRARY ieee;
USE ieee.std_logic_1164.all;

use std.textio.all;
use work.txt_util.all;

 entity Control_tb is
 end Control_tb;

 architecture behav of Control_tb is
    --  Declaration of the component that will be instantiated.
    component Control
        PORT(Operation: IN STD_LOGIC_VECTOR(31 DOWNTO 26);
            Func:IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            Branch,MemRead,MemWrite,RegWrite,SignExtend:OUT STD_LOGIC;
            ALUSrc,MemToReg,RegDst,Jump,ALUOp:OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
    end component;
    --  Specifies which entity is bound with the component.
    for Control_0: Control use entity work.Control;
    signal Operation: STD_LOGIC_VECTOR(31 DOWNTO 26);
    signal Func: STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal Branch,MemRead,MemWrite,RegWrite,SignExtend: STD_LOGIC;
    signal ALUSrc,MemToReg,RegDst,Jump,ALUOp:STD_LOGIC_VECTOR(1 DOWNTO 0);
 begin
    --  Component instantiation.
    Control_0: Control port map (Operation => Operation, 
                                 Func => Func,
                                 Branch => Branch,
                                 MemRead => MemRead,
                                 MemWrite => MemWrite,
                                 RegWrite => RegWrite,
                                 SignExtend => SignExtend,
                                 ALUSrc => ALUSrc,
                                 MemToReg => MemToReg,
                                 RegDst => RegDst,
                                 Jump => Jump,
                                 ALUOp => ALUOp);
    --  This process does the real job.
    
    process
        type pattern_type is record
            --  The inputs of the Control.
            Operation: STD_LOGIC_VECTOR(31 DOWNTO 26);
            Func:STD_LOGIC_VECTOR(5 DOWNTO 0);
            --  The expected outputs of the Control.
            Branch,MemRead,MemWrite,RegWrite,SignExtend: STD_LOGIC;
            ALUSrc,MemToReg,RegDst,Jump,ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
         -- Op        Func     Branch MemRead MemWrite RegWrite SignExtend ALUSrc MemToReg RegDst Jump ALUOp
            constant patterns : pattern_array :=
         (("000000", "000000",'0',    '0',    '0',     '1',     '1',       "10",  "00",    "01",  "00","10"),
          ---- r-type 20
          ("000000", "000000",'0',    '0',    '0',     '1',     '1',       "10",  "00",    "01",  "00","10"),
          ---- jal 30
          ("000011", "000000",'1',    '0',    '0',     '1',     '1',       "00",  "10",    "10",  "01","00"),
          ---- ori 40
          ("001101", "000000",'0',    '0',    '0',     '1',     '0',       "01",  "00",    "00",  "00","11"),
          ---- beq 50
          ("000100", "000000",'1',    '0',    '0',     '0',     '1',       "01",  "00",    "00",  "00","00"),
          ---- j 60
          ("000010", "000000",'1',    '0',    '0',     '0',     '1',       "00",  "00",    "00",  "01","00"),
          ---- jr 70
          ("000000", "001000",'1',    '0',    '0',     '0',     '1',       "00",  "00",    "01",  "10","00"),
          ---- sw 80
          ("101011", "000000",'0',    '0',    '1',     '0',     '1',       "01",  "00",    "00",  "00","00"),
          ---- lw 90
          ("100011", "000000",'0',    '1',    '0',     '1',     '1',       "01",  "01",    "00",  "00","00"),

          ("000000", "000000",'0',    '0',    '0',     '1',     '1',       "10",  "00",    "01",  "00","10"));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  Operation <= patterns(x).Operation;
	  Func <= patterns(x).Func;
	  --  Wait for the results.
	  wait for 10 ns;
	  --  Check the outputs.
	  assert RegDst = patterns(x).RegDst
	     report "RegDst Error" & LF &
	      "bad: "&str(RegDst) & LF &
	      "exp: "&str(patterns(x).RegDst) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert Branch = patterns(x).Branch
	     report "Branch Error" & LF &
	      "bad: "&str(Branch) & LF &
	      "exp: "&str(patterns(x).Branch) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert Jump = patterns(x).Jump
	     report "Jump Error" & LF &
	      "bad: "&str(Jump) & LF &
	      "exp: "&str(patterns(x).Jump) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert MemWrite = patterns(x).MemWrite
	     report "MemWrite Error" & LF &
	      "bad: "&str(MemWrite) & LF &
	      "exp: "&str(patterns(x).MemWrite) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert MemRead = patterns(x).MemRead
	     report "MemRead Error" & LF &
	      "bad: "&str(MemRead) & LF &
	      "exp: "&str(patterns(x).MemRead) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert MemToReg = patterns(x).MemToReg
	     report "MemToReg Error" & LF &
	      "bad: "&str(MemToReg) & LF &
	      "exp: "&str(patterns(x).MemToReg) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert ALUSrc = patterns(x).ALUSrc
	     report "ALUSrc Error" & LF &
	      "bad: "&str(ALUSrc) & LF &
	      "exp: "&str(patterns(x).ALUSrc) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert RegWrite = patterns(x).RegWrite
	     report "RegWrite Error" & LF &
	      "bad: "&str(RegWrite) & LF &
	      "exp: "&str(patterns(x).RegWrite) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
	  assert ALUOp = patterns(x).ALUOp
	     report "ALUOp Error" & LF &
	      "bad: "&str(ALUOp) & LF &
	      "exp: "&str(patterns(x).ALUOp) & LF &
	      "op: "&str(Operation) & LF &
	      "func: "&str(Func) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
