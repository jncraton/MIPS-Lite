LIBRARY ieee;
USE ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

 entity RegFile_tb is
 end RegFile_tb;

 architecture behav of RegFile_tb is
    --  Declaration of the component that will be instantiated.
    component RegFile
        PORT(reg1,reg2,writeReg: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
             WE,clock:IN STD_LOGIC;
             writeData:IN STD_LOGIC_VECTOR(31 DOWNTO 0);
             read1Data,read2Data: OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;
    --  Specifies which entity is bound with the component.
    for RegFile_0: RegFile use entity work.RegFile;
    signal reg1,reg2,writeReg: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal WE,clock: STD_LOGIC;
    signal writeData: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal read1Data,read2Data: STD_LOGIC_VECTOR(31 DOWNTO 0);
 begin
    --  Component instantiation.
    RegFile_0: RegFile port map (reg1 => reg1, 
                                 reg2 => reg2,
                                 writeReg => writeReg,
                                 WE => WE,
                                 clock => clock,
                                 writeData => writeData,
                                 read1Data => read1Data,
                                 read2Data => read2Data);

    --  This process does the real job.
    
    process
       type pattern_type is record
	  --  The inputs of the RegFile.
	  reg1, reg2, writeReg: std_logic_vector(4 downto 0); 
      WE, clock: std_logic;
	  --  The expected outputs of the RegFile.
      writeData, read1Data, read2Data : std_logic_vector (31 downto 0);
       end record;
       --  The patterns to apply.
       type pattern_array is array (natural range <>) of pattern_type;
     -- reg1     reg2     writeReg WE   clock writeData    read1Data    read2Data
        constant patterns : pattern_array :=
	 (("00000", "00000", "00000", '0', '1', x"00000000", x"00000000", x"00000000"),
      ("00000", "00000", "00000", '1', '1', x"FFFFFFFF", x"00000000", x"00000000"),
      -- register 1 test
      ("00000", "00000", "00001", '1', '0', x"10000001", x"00000000", x"00000000"),
      ("00000", "00000", "00001", '1', '1', x"10000001", x"00000000", x"00000000"),
      ("00000", "00000", "00001", '0', '0', x"10000001", x"00000000", x"00000000"),
      ("00001", "00001", "00000", '0', '1', x"00000000", x"10000001", x"10000001"),
      -- register 7 test
      ("00000", "00000", "00111", '1', '0', x"70000007", x"00000000", x"00000000"),
      ("00000", "00000", "00111", '1', '1', x"70000007", x"00000000", x"00000000"),
      ("00000", "00000", "00111", '0', '0', x"70000007", x"00000000", x"00000000"),
      ("00111", "00111", "00000", '0', '1', x"00000000", x"70000007", x"70000007"),
      -- register 31 test
      ("00000", "00000", "11111", '1', '0', x"31000031", x"00000000", x"00000000"),
      ("00000", "00000", "11111", '1', '1', x"31000031", x"00000000", x"00000000"),
      ("00000", "00000", "11111", '0', '0', x"31000031", x"00000000", x"00000000"),
      ("11111", "11111", "00000", '0', '1', x"00000000", x"31000031", x"31000031"),

      ("00000", "00000", "00000", '0', '1', x"00000000", x"00000000", x"00000000"));
    begin
       --  Check each pattern.
       for x in patterns'range loop
	  --  Set the inputs.
	  reg1 <= patterns(x).reg1;
	  reg2 <= patterns(x).reg2;
	  writeReg <= patterns(x).writeReg;
	  WE <= patterns(x).WE;
      clock <= patterns(x).clock;
	  writeData <= patterns(x).writeData;
	  --  Wait for the results.
	  wait for 1 ns;
	  --  Check the outputs.
	  assert read1Data = patterns(x).read1Data
	     report "reg1Data Error" & LF &
	      "bad: "&str(read1data) & LF &
	      "exp: "&str(patterns(x).read1Data) & LF &
	      "reg1: "&str(reg1) & LF &
	      "reg2: "&str(reg2) & LF &
	      "writeReg: "&str(writeReg) & LF &
	      "WE: "&str(WE) & LF &
	      "clock: "&str(clock) & LF &
	      "writeData: "&str(writeData) & LF &
	      "read1Data: "&str(read1Data) & LF &
	      "read2Data: "&str(read2Data) & LF severity error;
	  assert read2Data = patterns(x).read2Data
	     report "reg2Data Error" & LF &
	      "bad: "&str(read2data) & LF &
	      "exp: "&str(patterns(x).read2Data) & LF &
	      "reg1: "&str(reg1) & LF &
	      "reg2: "&str(reg2) & LF &
	      "writeReg: "&str(writeReg) & LF &
	      "WE: "&str(WE) & LF &
	      "clock: "&str(clock) & LF &
	      "writeData: "&str(writeData) & LF &
	      "read1Data: "&str(read1Data) & LF &
	      "read2Data: "&str(read2Data) & LF severity error;
       end loop;
       assert false report "end of test" severity note;
       --  Wait forever; this will finish the simulation.
       wait;
    end process;
 end behav;
