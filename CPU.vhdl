-- ghdl -m --ieee=synopsys CPU 2> compile_log.txt; cat compile_log.txt | grep CPU.vhdl; perl asm.pl; ./cpu > /dev/null 2> output.txt; cat output.txt| grep CPU.vhdl | grep :


library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity CPU is
end CPU;
    
architecture rtl of CPU is

    -- signal definitions
        signal clk: std_logic;
        signal reset: std_logic;
        signal halt: std_logic;
        
        signal isBranching: std_logic;

        -- ID
        signal ID_operation :  std_logic_vector(5 downto 0);
        signal ID_rs,ID_rt,ID_rd :  std_logic_vector(4 downto 0);
        signal ID_shift_amount :  std_logic_vector(31 downto 0);
        signal ID_func :  std_logic_vector(5 downto 0);
        signal ID_jump_address :  std_logic_vector(31 downto 0);
        signal ID_immediate :  std_logic_vector(31 downto 0);
        signal ID_immediate_signExtend :  std_logic_vector(31 downto 0);
        signal ID_Read1Data,ID_Read2Data :  std_logic_vector(31 downto 0);
        signal ID_Branch,ID_MemRead,ID_MemWrite,ID_RegWrite,ID_SignExtend,ID_Halt: STD_LOGIC;
        signal ID_ALUSrc,ID_MemToReg,ID_RegDst,ID_Jump,ID_ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- PC
        signal PC_in: std_logic_vector(31 downto 0);
        signal PC_WE: std_logic;
        signal PC: std_logic_vector(31 downto 0);
        signal ID_PC: std_logic_vector(31 downto 0);
        signal not_PC: std_logic_vector(31 downto 0);
    
        -- instruction memory
        signal inst_addr: std_logic_vector(31 downto 0);
        signal inst: std_logic_vector(31 downto 0);
        signal ID_inst: std_logic_vector(31 downto 0);
        signal inst_ncs: std_logic;
        signal inst_nwe: std_logic;
        signal inst_noe: std_logic;
    
        -- register file
        signal rf_reg1,rf_reg2,rf_writeReg: std_logic_vector(4 DOWNTO 0);
        signal rf_WE: std_logic;
        signal rf_writeData: std_logic_vector(31 DOWNTO 0);
        signal ID_writeData: std_logic_vector(31 DOWNTO 0);
        signal rf_read1Data,rf_read2Data: std_logic_vector(31 DOWNTO 0);
        
        -- ALU
        signal ALU_Value1,ALU_Value2: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
        signal ALU_ValueOut: STD_LOGIC_VECTOR(31 DOWNTO 0);
        signal ALU_Overflow,ALU_Negative,ALU_Zero,ALU_CarryOut: STD_LOGIC;
        
        -- data memory
        signal data_addr: std_logic_vector(31 downto 0);
        signal data_data: std_logic_vector(31 downto 0);
        signal data_ncs: std_logic;
        signal data_nwe: std_logic;
        signal data_noe: std_logic;
        signal data_output: std_logic_vector(31 downto 0);
        signal data_input: std_logic_vector(31 downto 0);
        
        -- Control
        signal ctrl_Operation: STD_LOGIC_VECTOR(31 DOWNTO 26);
        signal ctrl_Func: STD_LOGIC_VECTOR(5 DOWNTO 0);
        signal ctrl_Branch,ctrl_MemRead,ctrl_MemWrite,ctrl_RegWrite,ctrl_SignExtend: STD_LOGIC;
        signal ctrl_ALUSrc,ctrl_MemToReg,ctrl_RegDst,ctrl_Jump,ctrl_ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
    
        -- ALUControl
        signal ALUctrl_ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal ALUctrl_Func: STD_LOGIC_VECTOR(5 DOWNTO 0);
        signal ALUctrl_Operation: STD_LOGIC_VECTOR(2 DOWNTO 0);
    
        -- PC adder
        signal PC_adder_in: std_logic_vector(31 downto 0);
        signal PC_adder_ci : std_logic;
        signal PC_4 : std_logic_vector(31 downto 0);
        signal PC_adder_co : std_logic;
        
        -- PC adder8
        signal PC_adder8_in: std_logic_vector(31 downto 0);
        signal PC_adder8_ci : std_logic;
        signal PC_8 : std_logic_vector(31 downto 0);
        signal PC_adder8_co : std_logic;

        -- PC_branchDst_adder
        signal PC_branchDst_adder_in: std_logic_vector(31 downto 0);
        signal PC_branchDst_adder_ci : std_logic;
        signal PC_branchDst_adder_out : std_logic_vector(31 downto 0);
        signal PC_branchDst_adder_co : std_logic;
        
        -- PC branchDst
        signal PC_branchDst_out : std_logic_vector(31 downto 0);


        -- PC mux
        signal PC_mux_in: std_logic_vector(127 downto 0);
        signal PC_mux_sel: std_logic_vector(1 downto 0);
        signal PC_mux_out: std_logic_vector(31 downto 0);
        
        --instruction pieces
        
        signal operation: std_logic_vector(5 downto 0);
        signal rs: std_logic_vector(4 downto 0);
        signal rt: std_logic_vector(4 downto 0);
        signal rd: std_logic_vector(4 downto 0);
        signal immediate: std_logic_vector(31 downto 0);
        signal immediate_signExtend: std_logic_vector(31 downto 0);
        signal shift_amount: std_logic_vector(31 downto 0);
        signal func: std_logic_vector(5 downto 0);
        signal jump_address: std_logic_vector(31 downto 0);

    begin
        -- IF
            -- InstructionFetch
                InstructionFetch: entity work.InstructionFetch(rtl)
                    port map (clk, PC_in, inst, PC, PC_4, PC_8);
            
            GEN_PC_in: for n in 0 to 31 generate
                PC_in(n) <= reset and PC_mux_out(n);
            end generate GEN_PC_in;

            -- PC_branchdst_adder
                PC_branchDst_adder: entity work.adder32(rtl)
                    port map(PC, immediate_signExtend,
                             -- carry in is 0
                             '0',
                             PC_branchDst_adder_out,
                             PC_branchDst_adder_co);                      
            
            -- PC_branch_dst mux (either PC+4 or branch location)
            GEN_branchDst_mux: for n in 0 to 31 generate
                PC_branch_dst_adder: entity work.mux2to1_indiv(rtl)
                    port map(PC_4(n), 
                             PC_branchDst_adder_out(n),
                             isBranching,
                             PC_branchDst_out(n));
            end generate GEN_branchDst_mux;                         
            
            isBranching <= ALU_Zero and ctrl_Branch;
                             
            -- PC in mux - selects the input to the PC
                -- options are PC+4 normally, imm_pc_final on branch, or 0x00000000 for reset
                GEN_PC_mux: for n in 0 to 31 generate
                    PC_mux: entity work.mux4to1_indiv(rtl)
                        -- zero unless reset is high
                        port map(PC_branchDst_out(n), jump_address(n),
                                 rf_read1Data(n), '0',
                                 ctrl_Jump(0),
                                 ctrl_Jump(1),
                                 PC_mux_out(n));
                end generate GEN_PC_mux;
                
            -- IF/ID Register
            ID_inst <= inst;
            ID_PC <= PC;
            -- TODO: this should come from EX or MEM stage
            ID_writeData <= rf_writeData;
        
        -- ID

            
            -- InstructionFetch
                InstructionDecode: entity work.InstructionDecode(rtl)
                    port map (clk, ID_PC, ID_inst, ID_writeData,
                              ID_Operation, ID_rs, ID_rt, ID_rd,
                              ID_shift_amount, ID_func, ID_jump_address,
                              ID_immediate, ID_immediate_signExtend,
                              ID_Read1Data, ID_Read2Data,
                              ID_Branch,ID_MemRead,ID_MemWrite,
                              ID_RegWrite,ID_SignExtend,ID_Halt,
                              ID_ALUSrc,ID_MemToReg,ID_RegDst,
                              ID_Jump,ID_ALUOp);

            -- break up intruction 
                operation <= ID_Operation;
                rs <= ID_rs;
                rt <= ID_rt;
                rd <= ID_rd;
                shift_amount <= ID_shift_amount;
                func <= ID_func;
                jump_address <= ID_jump_address;
    
                immediate <= ID_immediate;
                immediate_signExtend <= ID_immediate_signExtend;
                
            -- connect halt
                halt <= ID_halt;
                
            -- Register File
                --rf_read1Data <= ID_Read1Data;
                --rf_read2Data <= ID_Read2Data;
                --rf_WriteData <= ID_writeData;
                register_file: entity work.RegFile(rtl)
                    port map (rf_reg1, rf_reg2, rf_writeReg, rf_WE, clk,                       
                              rf_writeData, rf_read1Data, rf_read2Data);
        
                rf_WE <= ctrl_RegWrite;

            -- Control
                control: entity work.Control(rtl)
                    port map (ctrl_Operation, ctrl_Func,
                              ctrl_Branch,ctrl_MemRead,ctrl_MemWrite,
                              ctrl_RegWrite,ctrl_SignExtend,
                              ctrl_ALUSrc,ctrl_MemToReg,ctrl_RegDst,
                              ctrl_Jump,ctrl_ALUOp);
                
                ctrl_Operation <= inst(31 downto 26);
                ctrl_Func <= inst(5 downto 0);
    
            
            -- connect register file inputs
            rf_reg1 <= rs;
            rf_reg2 <= rt;

            PC_adder_in <= PC;
        -- EX
            -- ALU
                ALU: entity work.ALU(rtl)
                    port map (ALU_Value1, ALU_Value2, ALU_Operation, ALU_ValueOut, 
                              ALU_Overflow,ALU_Negative,ALU_Zero,ALU_CarryOut);
                ALU_Operation <= ALUctrl_Operation;

            -- ALU input 1 comes from the register file output 1
                ALU_Value1 <= rf_read1Data;
            
            -- ALUSrc mux - selects the ALU source (2nd one)
                GEN_ALUSrc_mux: for n in 0 to 31 generate
                    ALUSrc_mux: entity work.mux4to1_indiv(rtl)
                        port map(rf_read2Data(n),
                                 immediate(n),
                                 shift_amount(n),
                                 'X',
                                 ctrl_ALUSrc(0),
                                 ctrl_ALUSrc(1),
                                 ALU_Value2(n));
                end generate GEN_ALUSrc_mux;
        
            -- ALU control
                ALUcontrol: entity work.ALUControl(rtl)
                    port map (ALUctrl_ALUOp,ALUctrl_Func,ALUctrl_Operation);
                    
                ALUctrl_ALUOp <= ctrl_ALUOp;
                ALUctrl_Func <= func;

        -- MEM
            -- Data Memory
                data_memory: entity work.sram64kx8(sram_behaviour)
                    port map (data_ncs, data_addr, data_data, data_nwe, data_noe);
        
                data_nwe <= not ctrl_MemWrite;
                data_noe <= not ctrl_MemRead;
                data_ncs <= not (ctrl_MemWrite or ctrl_MemRead);
                data_addr <= ALU_ValueOut;

            -- connect data_data to reg out 2 with a tristate buffer
                GEN_memdata_tris: for n in 31 downto 0 generate
                    data_data(n) <= rf_read2Data(n) when ctrl_memwrite='1' else 'Z';
                end generate GEN_memdata_tris;
        
        -- WB
            -- GEN_rf_writeData_mux selects data input for reg file
                GEN_rf_writeData_mux: for n in 0 to 31 generate
                    rf_writeData_mux: entity work.mux4to1_indiv(rtl)
                        port map(ALU_ValueOut(n),
                                 data_data(n),
                                 PC_8(n), -- should be PC + 8 eventually
                                 '1',
                                 ctrl_MemToReg(0),
                                 ctrl_MemToReg(1),
                                 rf_writeData(n));
                end generate GEN_rf_writeData_mux;

            -- writeReg_mux - selects which register should be written to
            GEN_writeReg_mux: for n in 4 downto 0 generate
                writeReg_mux: entity work.mux4to1_indiv(rtl)
                    port map(rt(n),
                             rd(n),
                             '1', -- TODO: is this correct (store in reg31)
                             'X',
                             ctrl_RegDst(0),
                             ctrl_RegDst(1),
                             rf_WriteReg(n));
            end generate GEN_writeReg_mux;
                                              
    clock: process begin
        loop
            clk <= '0'; 
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;
            exit when halt='0';
            if( ctrl_MemWrite = '1') then
                report "writing: " & str(data_data);
            end if;
        end loop;
        
        report "CPU Halted";

        wait;
    end process clock;
        
    run: process begin
        reset <= '0';

        wait until clk = '1';
        wait until clk = '0';

        reset <= '1';
        
        -- change false to true to verify first 25 instructions of test
        if (true) then

            wait until (clk = '0' and reset = '1');
    
            -- 1: nop
            assert inst = x"00000000"
                report "Instruction not NOP:" & str(inst);
                
            wait until clk = '1';
            wait until clk = '0';
    
            -- 2: lw from memory
            assert PC = x"00000004"
                report "Bad PC2 = " & str(PC);
            assert inst = x"8c088000"
                report "Instruction not lw:" & str(inst);
            assert data_data = x"f0f0f0f0"
                report "2 Bad data_data" & str(data_data);
            assert rf_writeData = x"f0f0f0f0"
                report "Bad rf_writeData" & str(rf_writeData);
            
            wait until clk = '1';
            wait until clk = '0';
    
            -- 3: add to $0 (0x00000000)
            assert PC = x"00000008"
                report "Bad PC3 = " & str(PC);
            assert inst = x"00084820"
                report "Instruction not expected:" & str(inst);
            assert rf_writeReg = b"01001"
                report "bad write reg:" & str(rf_writeReg);
            assert rf_writeData = x"f0f0f0f0"
                report "bad rf_writeData:" & str(rf_writeData);
            wait until (clk = '0');
            wait until (clk = '1');
    
            
            -- 4: sw back to memory
            assert PC = x"0000000c"
                report "Bad PC4 = " & str(PC);
            assert inst = x"ac098004"
                report "Instruction not expected:" & str(inst);
            assert data_data = x"f0f0f0f0"
                report "bad data_data:" & str(data_data);
            wait until (clk = '0');
            wait until (clk = '1');
              
    
                
            -- 5: lw out again to verify
            assert PC = x"00000010"
                report "Bad PC5 = " & str(PC);
            assert inst = x"8c0a8004"
                report "Instruction not lw:" & str(inst);
            assert data_data = x"f0f0f0f0"
                report "5 Bad data_data" & str(data_data);
            assert rf_writeData = x"f0f0f0f0"
                report "Bad rf_writeData" & str(rf_writeData);
            wait until (clk = '0');
            wait until (clk = '1');
              
            
            -- 6: lw again
            assert PC = x"00000014"
                report "Bad PC = " & str(PC);
            assert inst = x"8c0b8008"
                report "Instruction not lw:" & str(inst);
            assert data_data = x"ffffffff"
                report "6 Bad data_data" & str(data_data);
            assert rf_writeData = x"ffffffff"
                report "Bad rf_writeData" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
               
            
            -- 7: sub these two values
            assert PC = x"00000018"
                report "Bad PC = " & str(PC);
            assert inst = x"014b6022"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"f0f0f0f1"
                report "Bad rf_writeData" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
            
            -- 7: sll the result by 1
            -- TODO: shifting doesn't actually follow the green card.
            -- rs and rt need to be switched
            assert PC = x"0000001c"
                report "Bad PC = " & str(PC);
            assert inst = x"01806840"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"e1e1e1e2"
                report "Bad rf_writeData" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
            
            -- 8: srl the result by 1
            assert PC = x"00000020"
                report "Bad PC = " & str(PC);
            assert inst = x"01a07042"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"70f0f0f1"
                report "Bad rf_writeData" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
     
            
             -- 9: j out of here
            assert PC = x"00000024"
                report "Bad PC = " & str(PC);
            assert inst = x"08000040"
                report "Bad inst:" & str(inst);
            assert jump_address = x"00000100"
                report "Bad jump_address" & str(jump_address);
            assert ctrl_Jump = "01"
                report "Bad ctrl_Jump" & str(ctrl_Jump);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
            
             -- 10: nop to make sure we are in the right place
            assert PC = x"00000100"
                report "Bad PC = " & str(PC);
            assert inst = x"00000000"
                report "Bad inst:" & str(inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
             -- 11: ori to put a value in an address register
            assert PC = x"00000104"
                report "Bad PC = " & str(PC);
            assert inst = x"340f0200"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"00000200"
                report "Bad rf_writeData" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
             -- 12: jr to that value (0x00000200)
            assert PC = x"00000108"
                report "Bad PC = " & str(PC);
            assert inst = x"01e00008"
                report "Bad inst:" & str(inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 13: nop to make sure we are in the right place
            assert PC = x"00000200"
                report "Bad PC = " & str(PC);
            assert inst = x"00000000"
                report "Bad inst:" & str(inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 14: slt comparing r0 and r15 into r16
            assert PC = x"00000204"
                report "Bad PC = " & str(PC);
            assert inst = x"000f802a"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"00000001"
               report "Bad rf_writeData:" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 15: nor this with r0 to flip all the bits
            assert PC = x"00000208"
                report "Bad PC = " & str(PC);
            assert inst = x"00108827"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"fffffffe"
               report "Bad rf_writeData:" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 16: jal out of here to 0x0300
            assert PC = x"0000020c"
                report "Bad PC = " & str(PC);
            assert inst = x"0c0000c0"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"00000214"
               report "Bad rf_writeData:" & str(rf_writeData);
               
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 17: nop to make sure we are in the right place
            assert PC = x"00000300"
                report "Bad PC = " & str(PC);
            assert inst = x"00000000"
                report "Bad inst:" & str(inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 18: call a function (jal)
            assert PC = x"00000304"
                report "Bad PC = " & str(PC);
            assert inst = x"0c000100"
                report "Bad inst:" & str(inst);
            assert rf_writeData = x"0000030c"
               report "Bad rf_writeData:" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 19: ret from function (jr)
            assert PC = x"00000400"
                report "Bad PC 1= " & str(PC);
            assert inst = x"03e00008"
                report "Bad inst:" & str(inst);
            
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 20: nop just to check where we are
            assert PC = x"0000030c"
                report "Bad PC = " & str(PC);
            assert inst = x"00000000"
                report "Bad inst:" & str(inst);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 21: beq that will fail
            assert PC = x"00000310"
                report "Bad PC = " & str(PC);
            assert inst = x"10110010"
                report "Bad inst:" & str(inst);
            assert PC_branchDst_out = x"00000314"
                report "Bad PC_branchDst_out:" & str(PC_branchDst_out);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 22: nop to make sure we didn't branch
            assert PC = x"00000314"
                report "Bad PC (should not have branched) = " & str(PC);
            assert inst = x"00000000"
                report "Bad inst:" & str(inst);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 23: beq that will succeed
            assert PC = x"00000318"
                report "Bad PC = " & str(PC);
            assert inst = x"10000010"
                report "Bad inst:" & str(inst);
            assert PC_in = x"00000328"
                report "Bad PC_in:" & str(PC_in);
            assert ALU_Zero = '1'
                report "Bad ALU_Zero:" & str(ALU_Zero);
            assert PC_branchDst_out = x"00000328"
                report "Bad PC_branchDst_out:" & str(PC_branchDst_out);
            
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 24: nop to see that we took the branch
            assert PC = x"00000328"
                report "Bad PC = " & str(PC);
            assert inst = x"00000000"
                report "Bad inst:" & str(inst);
    
            wait until (clk = '0');
            wait until (clk = '1');
            
            -- 25+ do stuff until halt
        end if;
            
        wait;
    end process run;
    end rtl;

    
