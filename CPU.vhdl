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
        
        -- IF
        signal IF_PC,IF_PC_4,IF_PC_8: std_logic_vector(31 downto 0);
        signal IF_PC_in: std_logic_vector(31 downto 0);
        signal IF_inst_addr: std_logic_vector(31 downto 0);
        signal IF_inst: std_logic_vector(31 downto 0);
        signal IF_inst_ncs: std_logic;
        signal IF_inst_nwe: std_logic;
        signal IF_inst_noe: std_logic;
        
        -- ID
        signal ID_PC: std_logic_vector(31 downto 0);
        signal ID_inst: std_logic_vector(31 downto 0);
        signal ID_writeReg : std_logic_vector(4 downto 0);
        signal ID_operation : std_logic_vector(5 downto 0);
        signal ID_rs,ID_rt,ID_rd : std_logic_vector(4 downto 0);
        signal ID_shift_amount : std_logic_vector(31 downto 0);
        signal ID_func : std_logic_vector(5 downto 0);
        signal ID_jump_address : std_logic_vector(31 downto 0);
        signal ID_immediate,ID_immediate_signExtend : std_logic_vector(31 downto 0);
        signal ID_Read1Data,ID_Read2Data : std_logic_vector(31 downto 0);
        signal ID_writeData: std_logic_vector(31 DOWNTO 0);
        signal ID_Branch,ID_MemRead,ID_MemWrite,ID_RegWrite,ID_SignExtend,ID_Halt,ID_IsBranching: STD_LOGIC;
        signal ID_ALUSrc,ID_MemToReg,ID_RegDst,ID_Jump,ID_ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- EX

        signal EX_operation :  std_logic_vector(5 downto 0);
        signal EX_func :  std_logic_vector(5 downto 0);
        signal EX_immediate :  std_logic_vector(31 downto 0);
        signal EX_shift_amount :  std_logic_vector(31 downto 0);
        signal EX_Read1Data,EX_Read2Data :  std_logic_vector(31 downto 0);
        signal EX_ALU_ValueOut :  std_logic_vector(31 downto 0);
        signal EX_ALUSrc,EX_ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal EX_MemWrite, EX_MemRead : std_logic;

        -- MEM
        signal MEM_Read2Data :  std_logic_vector(31 downto 0);
        signal MEM_MemOutData :  std_logic_vector(31 downto 0);
        signal MEM_ALU_ValueOut :  std_logic_vector(31 downto 0);
        signal MEM_MemWrite, MEM_MemRead : std_logic;

        -- WB
        
        signal WB_MemOutData : std_logic_vector(31 downto 0);
        
    
    
        -- register file
        signal rf_reg1,rf_reg2,rf_writeReg: std_logic_vector(4 DOWNTO 0);
        signal rf_writeData: std_logic_vector(31 DOWNTO 0);
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
        
        --IF_instruction pieces
        
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
                    port map (clk, IF_PC_in, IF_inst, IF_PC, IF_PC_4, IF_PC_8);
            
            GEN_IF_PC_in: for n in 0 to 31 generate
                IF_PC_in(n) <= reset and PC_mux_out(n);
            end generate GEN_IF_PC_in;

            -- PC_branchdst_adder
                PC_branchDst_adder: entity work.adder32(rtl)
                    port map(IF_PC, immediate_signExtend,
                             -- carry in is 0
                             '0',
                             PC_branchDst_adder_out,
                             PC_branchDst_adder_co);                      
            
            -- PC_branch_dst mux (either PC+4 or branch location)
            GEN_branchDst_mux: for n in 0 to 31 generate
                PC_branch_dst_adder: entity work.mux2to1_indiv(rtl)
                    port map(IF_PC_4(n), 
                             PC_branchDst_adder_out(n),
                             ID_isBranching,
                             PC_branchDst_out(n));
            end generate GEN_branchDst_mux;                         
            
            --isBranching <= ALU_Zero and ID_Branch;
                             
            -- PC in mux - selects the input to the PC
                -- options are PC+4 normally, imm_pc_final on branch, or 0x00000000 for reset
                GEN_PC_mux: for n in 0 to 31 generate
                    PC_mux: entity work.mux4to1_indiv(rtl)
                        -- zero unless reset is high
                        port map(PC_branchDst_out(n), jump_address(n),
                                 rf_read1Data(n), '0',
                                 ID_Jump(0),
                                 ID_Jump(1),
                                 PC_mux_out(n));
                end generate GEN_PC_mux;
                
            -- IF/ID Register
                ID_inst <= IF_inst;
                ID_PC <= IF_PC;
                -- TODO: this should come from EX or MEM stage
                ID_writeData <= rf_writeData;
                ID_writeReg <= rf_writeReg;
                --isBranching <= '0';--ID_isBranching;
        
        -- ID

            
            -- InstructionDecode
                InstructionDecode: entity work.InstructionDecode(rtl)
                    port map (clk, ID_PC, ID_inst, ID_writeReg, ID_writeData,
                              ID_Operation, ID_rs, ID_rt, ID_rd,
                              ID_shift_amount, ID_func, ID_jump_address,
                              ID_immediate, ID_immediate_signExtend,
                              ID_Read1Data, ID_Read2Data,
                              ID_Branch,ID_MemRead,ID_MemWrite,
                              ID_RegWrite,ID_SignExtend,ID_Halt,ID_IsBranching,
                              ID_ALUSrc,ID_MemToReg,ID_RegDst,
                              ID_Jump,ID_ALUOp);

            -- ID/EX Register
                EX_Operation <= ID_Operation;

                EX_shift_amount <= ID_shift_amount;
                EX_Func <= ID_func;
    
                EX_immediate <= ID_immediate;
            
                EX_read1Data <= ID_Read1Data;
                EX_read2Data <= ID_Read2Data;

                EX_ALUSrc <= ID_ALUSrc;
                EX_ALUOp <= ID_ALUOp;
            
                EX_MemWrite <= ID_MemWrite;
                EX_MemRead <= ID_MemRead;
            -- Map to globals TODO: this goes away
            
                operation <= ID_Operation;
                rs <= ID_rs;
                rt <= ID_rt;
                rd <= ID_rd;
                shift_amount <= ID_shift_amount;
                func <= ID_func;
                jump_address <= ID_jump_address;
    
                immediate <= ID_immediate;
                immediate_signExtend <= ID_immediate_signExtend;
            
                halt <= ID_halt;
            
                rf_read1Data <= ID_Read1Data;
                rf_read2Data <= ID_Read2Data;

                rf_reg1 <= rs;
                rf_reg2 <= rt;

        -- EX
                Execute: entity work.Execute(rtl)
                    port map (clk,EX_Operation, EX_Func, 
                              EX_Read1Data, EX_Read2Data,
                              EX_immediate, EX_shift_amount,
                              EX_ALUSrc, EX_ALUOp,
                              EX_ALU_ValueOut);
                    
              -- EX\MEM Register
              MEM_ALU_ValueOut <= EX_ALU_ValueOut;
              MEM_Read2Data <= EX_Read2Data;
              MEM_MemWrite <= EX_MemWrite;
              MEM_MemRead <= EX_MemRead;
              
              --TODO: this goes away
              ALU_ValueOut <= EX_ALU_ValueOut;

        -- MEM
                Memory: entity work.Memory(rtl)
                    port map (clk,
                              MEM_Read2Data,
                              MEM_ALU_ValueOut,
                              MEM_MemWrite, MEM_MemRead,
                              MEM_MemOutData);
 
            -- MEM/WB Register
                              
            --data_data <= MEM_MemOutData;
            WB_MemOutData <= MEM_MemOutData;
        
        -- WB
            -- GEN_rf_writeData_mux selects data input for reg file
                GEN_rf_writeData_mux: for n in 0 to 31 generate
                    rf_writeData_mux: entity work.mux4to1_indiv(rtl)
                        port map(ALU_ValueOut(n),
                                 WB_MemOutData(n),
                                 IF_PC_8(n), -- should be PC + 8 eventually
                                 '1',
                                 ID_MemToReg(0),
                                 ID_MemToReg(1),
                                 rf_writeData(n));
                end generate GEN_rf_writeData_mux;

            -- writeReg_mux - selects which register should be written to
            GEN_writeReg_mux: for n in 4 downto 0 generate
                writeReg_mux: entity work.mux4to1_indiv(rtl)
                    port map(rt(n),
                             rd(n),
                             '1', -- R31 for JAL
                             'X',
                             ID_RegDst(0),
                             ID_RegDst(1),
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
            if( MEM_MemWrite = '1') then
                report "writing: " & str(MEM_Read2Data);
            end if;
            exit when halt='0';
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
            assert IF_inst = x"00000000"
                report "Instruction not NOP:" & str(IF_inst);
                
            wait until clk = '1';
            wait until clk = '0';
    
            -- 2: lw from memory
            assert IF_PC = x"00000004"
                report "Bad IF_PC2 = " & str(IF_PC);
            assert IF_inst = x"8c088000"
                report "Instruction not lw:" & str(IF_inst);
            assert EX_ALU_ValueOut = x"00008000"
                report "2 Bad EX_ALU_ValueOut" & str(EX_ALU_ValueOut);
            assert rf_writeData = x"f0f0f0f0"
                report "2 Bad rf_writeData" & str(rf_writeData);
            assert EX_Read1Data = x"00000000"
                report "2 Bad EX_Read1Data" & str(EX_Read1Data);
            assert ID_IsBranching = '0'
                report "2 Bad ID_IsBranching" & str(ID_IsBranching);
            
            wait until clk = '1';
            wait until clk = '0';
    
            -- 3: add to $0 (0x00000000)
            assert IF_PC = x"00000008"
                report "Bad IF_PC3 = " & str(IF_PC);
            assert IF_inst = x"00084820"
                report "Instruction not expected:" & str(IF_inst);
            assert rf_writeReg = b"01001"
                report "bad write reg:" & str(rf_writeReg);
            assert rf_writeData = x"f0f0f0f0"
                report "3 bad rf_writeData:" & str(rf_writeData);
            assert ALU_ValueOut = x"f0f0f0f0"
                report "3 bad ALU_ValueOut:" & str(ALU_ValueOut);
            wait until (clk = '0');
            wait until (clk = '1');
    
            
            -- 4: sw back to memory
            assert IF_PC = x"0000000c"
                report "Bad IF_PC4 = " & str(IF_PC);
            assert IF_inst = x"ac098004"
                report "Instruction not expected:" & str(IF_inst);
            wait until (clk = '0');
            wait until (clk = '1');
              
    
                
            -- 5: lw out again to verify
            assert IF_PC = x"00000010"
                report "Bad IF_PC5 = " & str(IF_PC);
            assert IF_inst = x"8c0a8004"
                report "Instruction not lw:" & str(IF_inst);
            assert rf_writeData = x"f0f0f0f0"
                report "Bad rf_writeData" & str(rf_writeData);
            wait until (clk = '0');
            wait until (clk = '1');
              
            
            -- 6: lw again
            assert IF_PC = x"00000014"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"8c0b8008"
                report "Instruction not lw:" & str(IF_inst);
            assert rf_writeData = x"ffffffff"
                report "Bad rf_writeData" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
               
            
            -- 7: sub these two values
            assert IF_PC = x"00000018"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"014b6022"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"f0f0f0f1"
                report "Bad rf_writeData" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
            
            -- 7: sll the result by 1
            -- TODO: shifting doesn't actually follow the green card.
            -- rs and rt need to be switched
            assert IF_PC = x"0000001c"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"01806840"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"e1e1e1e2"
                report "Bad rf_writeData" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
            
            -- 8: srl the result by 1
            assert IF_PC = x"00000020"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"01a07042"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"70f0f0f1"
                report "Bad rf_writeData" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
     
            
             -- 9: j out of here
            assert IF_PC = x"00000024"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"08000040"
                report "Bad IF_inst:" & str(IF_inst);
            assert jump_address = x"00000100"
                report "Bad jump_address" & str(jump_address);
            assert ID_Jump = "01"
                report "Bad ID_Jump" & str(ID_Jump);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
            
             -- 10: nop to make sure we are in the right place
            assert IF_PC = x"00000100"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"00000000"
                report "Bad IF_inst:" & str(IF_inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
             -- 11: ori to put a value in an address register
            assert IF_PC = x"00000104"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"340f0200"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"00000200"
                report "Bad rf_writeData" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
             -- 12: jr to that value (0x00000200)
            assert IF_PC = x"00000108"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"01e00008"
                report "Bad IF_inst:" & str(IF_inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 13: nop to make sure we are in the right place
            assert IF_PC = x"00000200"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"00000000"
                report "Bad IF_inst:" & str(IF_inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 14: slt comparing r0 and r15 into r16
            assert IF_PC = x"00000204"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"000f802a"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"00000001"
               report "Bad rf_writeData:" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 15: nor this with r0 to flip all the bits
            assert IF_PC = x"00000208"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"00108827"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"fffffffe"
               report "Bad rf_writeData:" & str(rf_writeData);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 16: jal out of here to 0x0300
            assert IF_PC = x"0000020c"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"0c0000c0"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"00000214"
               report "Bad rf_writeData:" & str(rf_writeData);
               
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 17: nop to make sure we are in the right place
            assert IF_PC = x"00000300"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"00000000"
                report "Bad IF_inst:" & str(IF_inst);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 18: call a function (jal)
            assert IF_PC = x"00000304"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"0c000100"
                report "Bad IF_inst:" & str(IF_inst);
            assert rf_writeData = x"0000030c"
               report "Bad rf_writeData:" & str(rf_writeData);
                
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 19: ret from function (jr)
            assert IF_PC = x"00000400"
                report "Bad IF_PC 1= " & str(IF_PC);
            assert IF_inst = x"03e00008"
                report "Bad IF_inst:" & str(IF_inst);
            
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 20: nop just to check where we are
            assert IF_PC = x"0000030c"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"00000000"
                report "Bad IF_inst:" & str(IF_inst);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 21: beq that will fail
            assert IF_PC = x"00000310"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"10110010"
                report "Bad IF_inst:" & str(IF_inst);
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 22: nop to make sure we didn't branch
            assert IF_PC = x"00000314"
                report "Bad IF_PC (should not have branched) = " & str(IF_PC);
            assert IF_inst = x"00000000"
                report "Bad IF_inst:" & str(IF_inst);
    
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 23: beq that will succeed
            assert IF_PC = x"00000318"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"10000010"
                report "Bad IF_inst:" & str(IF_inst);
            
            wait until (clk = '0');
            wait until (clk = '1');
    
    
            -- 24: nop to see that we took the branch
            assert IF_PC = x"00000328"
                report "Bad IF_PC = " & str(IF_PC);
            assert IF_inst = x"00000000"
                report "Bad IF_inst:" & str(IF_inst);
    
            wait until (clk = '0');
            wait until (clk = '1');
            
            -- 25+ do stuff until halt
        end if;
            
        wait;
    end process run;
    end rtl;

    
