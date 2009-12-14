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
        
        -- IF
        signal IF_PC,IF_PC_4,IF_PC_8: std_logic_vector(31 downto 0);
        signal IF_NextPC: std_logic_vector(31 downto 0);
        signal IF_inst_addr: std_logic_vector(31 downto 0);
        signal IF_inst: std_logic_vector(31 downto 0);
        signal IF_inst_ncs: std_logic;
        signal IF_inst_nwe: std_logic;
        signal IF_inst_noe: std_logic;
        
        -- ID
        signal ID_PC, ID_PC_4, ID_PC_8: std_logic_vector(31 downto 0);
        signal ID_inst: std_logic_vector(31 downto 0);
        signal ID_writeRegIn, ID_writeReg : std_logic_vector(4 downto 0);
        signal ID_operation : std_logic_vector(5 downto 0);
        signal ID_rs,ID_rt,ID_rd : std_logic_vector(4 downto 0);
        signal ID_shift_amount : std_logic_vector(31 downto 0);
        signal ID_func : std_logic_vector(5 downto 0);
        signal ID_jump_address : std_logic_vector(31 downto 0);
        signal ID_immediate,ID_immediate_signExtend : std_logic_vector(31 downto 0);
        signal ID_Read1Data,ID_Read2Data : std_logic_vector(31 downto 0);
        signal ID_NextPC : std_logic_vector(31 downto 0);
        signal ID_Branch,ID_MemRead,ID_MemWrite,ID_RegWrite,ID_SignExtend,ID_Halt,ID_IsBranching: STD_LOGIC;
        signal ID_ALUSrc,ID_MemToReg,ID_RegDst,ID_Jump,ID_ALUOp: STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- EX

        signal EX_PC_8: std_logic_vector(31 downto 0);
        signal EX_operation :std_logic_vector(5 downto 0);
        signal EX_func :std_logic_vector(5 downto 0);
        signal EX_immediate :std_logic_vector(31 downto 0);
        signal EX_shift_amount :std_logic_vector(31 downto 0);
        signal EX_Read1Data,EX_Read2Data :std_logic_vector(31 downto 0);
        signal EX_ALU_ValueOut :std_logic_vector(31 downto 0);
        signal EX_ALUSrc,EX_ALUOp,EX_MemToReg: STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal EX_MemWrite, EX_MemRead : std_logic;
        signal EX_writeReg : std_logic_vector(4 downto 0);

        -- MEM
        signal MEM_Read2Data :std_logic_vector(31 downto 0);
        signal MEM_MemOutData :std_logic_vector(31 downto 0);
        signal MEM_ALU_ValueOut :std_logic_vector(31 downto 0);
        signal MEM_MemWrite, MEM_MemRead : std_logic;
        signal MEM_PC_8 :std_logic_vector(31 downto 0);
        signal MEM_WriteReg :std_logic_vector(4 downto 0);
        signal MEM_MemToReg :std_logic_vector(1 downto 0);

        -- WB
        
        signal WB_MemOutData : std_logic_vector(31 downto 0);
        signal WB_ALU_ValueOut :std_logic_vector(31 downto 0);
        signal WB_WriteData :std_logic_vector(31 downto 0);
        signal WB_PC_8 :std_logic_vector(31 downto 0);
        signal WB_WriteReg :std_logic_vector(4 downto 0);
        signal WB_MemToReg :std_logic_vector(1 downto 0);

    begin
        -- IF
            InstructionFetch: entity work.InstructionFetch(rtl)
                port map (clk, reset, ID_NextPC, IF_inst, IF_PC, IF_PC_4, IF_PC_8);
               
            Register_IF_ID: entity work.Register_IF_ID(rtl)
                port map (clk,
                          ID_inst, IF_inst,
                          ID_PC, IF_PC,
                          ID_PC_4, IF_PC_4,
                          ID_PC_8, IF_PC_8);
        
        -- ID
            InstructionDecode: entity work.InstructionDecode(rtl)
                port map (clk, reset, ID_PC, IF_PC_4, ID_PC_8, ID_inst, WB_WriteReg, WB_writeData,
                        ID_Operation, ID_rs, ID_rt, ID_rd,
                        ID_shift_amount, ID_func, ID_jump_address,
                        ID_immediate, ID_immediate_signExtend,
                        ID_Read1Data, ID_Read2Data,
                        ID_WriteReg,
                        ID_NextPC,
                        ID_Branch,ID_MemRead,ID_MemWrite,
                        ID_RegWrite,ID_SignExtend,ID_Halt,ID_IsBranching,
                        ID_ALUSrc,ID_MemToReg,ID_RegDst,
                        ID_Jump,ID_ALUOp);

            -- ID/EX Register
            Register_ID_EX: entity work.Register_ID_EX(rtl)
                port map (clk,
                        EX_Operation , ID_Operation,
                        EX_Func , ID_func,
                        EX_shift_amount , ID_shift_amount,
                        EX_immediate , ID_immediate,
                        EX_read1Data , ID_Read1Data,
                        EX_read2Data , ID_Read2Data,
                        EX_PC_8 , ID_PC_8,
                        EX_WriteReg , ID_WriteReg,
                        EX_ALUSrc , ID_ALUSrc,
                        EX_ALUOp , ID_ALUOp,
                        EX_MemWrite , ID_MemWrite,
                        EX_MemRead , ID_MemRead,
                        EX_MemToReg , ID_MemToReg,
                        IF_NextPC, ID_NextPC);

        -- EX
            Execute: entity work.Execute(rtl)
                port map (clk,EX_Operation, EX_Func, 
                        EX_Read1Data, EX_Read2Data,
                        EX_immediate, EX_shift_amount,
                        EX_ALUSrc, EX_ALUOp,
                        EX_ALU_ValueOut);
                    
            -- EX\MEM Register
            Register_EX_MEM: entity work.Register_EX_MEM(rtl)
                port map (clk,
                          MEM_ALU_ValueOut , EX_ALU_ValueOut,
                          MEM_Read2Data , EX_Read2Data,
                          MEM_PC_8 , EX_PC_8,
                          MEM_WriteReg , EX_WriteReg,
                          MEM_MemWrite , EX_MemWrite,
                          MEM_MemRead , EX_MemRead,
                          MEM_MemToReg , EX_MemToReg);

        -- MEM
            Memory: entity work.Memory(rtl)
                port map (clk,
                        MEM_Read2Data,
                        MEM_ALU_ValueOut,
                        MEM_MemWrite, MEM_MemRead,
                        MEM_MemOutData);
 
            -- MEM/WB Register
            Register_MEM_WB: entity work.Register_MEM_WB(rtl)
                port map (clk,
                          WB_MemOutData , MEM_MemOutData,
                          WB_ALU_ValueOut , MEM_ALU_ValueOut,
                          WB_PC_8 , MEM_PC_8,
                          WB_WriteReg , MEM_WriteReg,
                          WB_MemToReg , MEM_MemToReg);
            
        -- WB
                Writeback: entity work.Writeback(rtl)
                    port map (clk,
                            WB_ALU_ValueOut,
                            WB_MemOutData,
                            WB_PC_8,
                            WB_MemToReg,
                            WB_WriteData);
                                            
    clock: process begin
        loop
            clk <= '0'; 
            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';
            wait for 1 ns;
            if( MEM_MemWrite = '1') then
                report "writing: " & str(MEM_Read2Data);
            end if;
            exit when ID_halt='0';
        end loop;
        
        report "CPU Halted";

        wait;
    end process clock;
        
    run: process begin
        reset <= '0';

        wait until clk = '1';
        wait until clk = '0';
        wait until clk = '1';
        wait until clk = '0';
        wait until clk = '1';
        wait until clk = '0';
        wait until clk = '1';
        wait until clk = '0';
        wait until clk = '1';

        reset <= '1';
        
        report "STARTING THE CPU";
        
        -- change false to true to verify first 25 instructions of test
        if (true) then

            wait until (clk = '0' and reset = '1');
    
            -- 1: many nops
                assert IF_inst = x"00000000"
                    report "Instruction not NOP:" & str(IF_inst);
                assert IF_PC = x"00000000"
                    report "1Bad PC:" & str(IF_PC);
                    
                wait until clk = '1';
                wait until clk = '0';
    
                assert IF_inst = x"00000000"
                    report "Instruction not NOP:" & str(IF_inst);
                assert IF_PC = x"00000004"
                    report "2Bad PC:" & str(IF_PC);
                    
                wait until clk = '1';
                wait until clk = '0';
    
                assert IF_inst = x"00000000"
                    report "Instruction not NOP:" & str(IF_inst);
                assert IF_PC = x"00000008"
                    report "3Bad PC:" & str(IF_PC);
                    
                wait until clk = '1';
                wait until clk = '0';
    
                assert IF_inst = x"00000000"
                    report "Instruction not NOP:" & str(IF_inst);
                assert IF_PC = x"0000000c"
                    report "4Bad PC:" & str(IF_PC);
                    
                wait until clk = '1';
                wait until clk = '0';
    
                assert IF_inst = x"00000000"
                    report "Instruction not NOP:" & str(IF_inst);
                assert IF_PC = x"00000010"
                    report "5Bad PC:" & str(IF_PC);
                    
                wait until clk = '1';
                wait until clk = '0';

                assert IF_inst = x"00000000"
                    report "Instruction not NOP:" & str(IF_inst);
                assert IF_PC = x"00000014"
                    report "6Bad PC:" & str(IF_PC);
                    
                wait until clk = '1';
                wait until clk = '0';

            -- 2: lw from memory
                assert IF_PC = x"00000018"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"8c088000"
                    report "Instruction not lw:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';
                
                --ID
                
                assert IF_PC = x"0000001c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert ID_IsBranching = '0'
                    report "2 Bad ID_IsBranching" & str(ID_IsBranching);
                wait until clk = '1';
                wait until clk = '0';
    
                -- EX
                
                assert IF_PC = x"00000020"
                    report "Bad IF_PC = " & str(IF_PC);
                assert EX_ALU_ValueOut = x"00008000"
                    report "2 Bad EX_ALU_ValueOut" & str(EX_ALU_ValueOut);
                assert EX_Read1Data = x"00000000"
                    report "2 Bad EX_Read1Data" & str(EX_Read1Data);
    
                wait until clk = '1';
                wait until clk = '0';
                
                -- MEM
                assert IF_PC = x"00000024"
                    report "Bad IF_PC = " & str(IF_PC);
                wait until clk = '1';
                wait until clk = '0';
                
                -- WB
                
                assert IF_PC = x"00000028"
                    report "Bad IF_PC = " & str(IF_PC);
                assert WB_WriteData = x"f0f0f0f0"
                    report "2 Bad WB_WriteData" & str(WB_WriteData);
                wait until clk = '1';
                wait until clk = '0';

            -- 3: add to $0 (0x00000000)
                assert IF_PC = x"0000002c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00084820"
                    report "Instruction not expected:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';
        
                --ID
                
                assert IF_PC = x"00000030"
                    report "Bad IF_PC = " & str(IF_PC);
                assert ID_IsBranching = '0'
                    report "3 Bad ID_IsBranching" & str(ID_IsBranching);
                assert ID_read1Data = x"00000000"
                    report "3 bad ID_read1Data:" & str(ID_read1Data);
                assert ID_read2Data = x"f0f0f0f0"
                    report "3 bad ID_read2Data:" & str(ID_read2Data);
                
                wait until clk = '1';
                wait until clk = '0';
    
                -- EX
                
                assert IF_PC = x"00000034"
                    report "Bad IF_PC = " & str(IF_PC);
                assert EX_ALU_ValueOut = x"f0f0f0f0"
                    report "3 Bad EX_ALU_ValueOut" & str(EX_ALU_ValueOut);
                assert EX_Read1Data = x"00000000"
                    report "3 Bad EX_Read1Data" & str(EX_Read1Data);
    
                wait until clk = '1';
                wait until clk = '0';
                
                -- MEM
                assert IF_PC = x"00000038"
                    report "Bad IF_PC = " & str(IF_PC);
                wait until clk = '1';
                wait until clk = '0';
                
                -- WB
                
                assert IF_PC = x"0000003c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert WB_WriteData = x"f0f0f0f0"
                    report "3 bad WB_WriteData:" & str(WB_WriteData);
                wait until clk = '1';
                wait until clk = '0';            

            -- 4: sw back to memory
                assert IF_PC = x"00000040"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"ac098004"
                    report "Instruction not expected:" & str(IF_inst);
                wait until clk = '1';
                wait until clk = '0';            
            
                --ID
                
                assert IF_PC = x"00000044"
                    report "Bad IF_PC = " & str(IF_PC);
                assert ID_IsBranching = '0'
                    report "4 Bad ID_IsBranching" & str(ID_IsBranching);
                assert ID_read1Data = x"00000000"
                    report "4 bad ID_read1Data:" & str(ID_read1Data);
                assert ID_read2Data = x"f0f0f0f0"
                    report "4 bad ID_read2Data:" & str(ID_read2Data);
                
                wait until clk = '1';
                wait until clk = '0';
    
                -- EX
                
                assert IF_PC = x"00000048"
                    report "Bad IF_PC = " & str(IF_PC);
                assert EX_ALU_ValueOut = x"00008004"
                    report "3 Bad EX_ALU_ValueOut" & str(EX_ALU_ValueOut);
                assert EX_Read1Data = x"00000000"
                    report "3 Bad EX_Read1Data" & str(EX_Read1Data);
    
                wait until clk = '1';
                wait until clk = '0';
                
                -- MEM
                assert IF_PC = x"0000004c"
                    report "Bad IF_PC = " & str(IF_PC);
                wait until clk = '1';
                wait until clk = '0';
                
                -- WB
                
                assert IF_PC = x"00000050"
                    report "Bad IF_PC = " & str(IF_PC);
                wait until clk = '1';
                wait until clk = '0';            

            -- 5: lw out again to verify
                assert IF_PC = x"00000054"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"8c0a8004"
                    report "Instruction not lw:" & str(IF_inst);
                wait until clk = '1';
                wait until clk = '0';            
            
            -- 6: lw again
                assert IF_PC = x"00000058"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"8c0b8008"
                    report "Instruction not lw:" & str(IF_inst);
        
                wait until clk = '1';
                wait until clk = '0';            
             
                --ID
                
                assert IF_PC = x"0000005c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert ID_IsBranching = '0'
                    report "6 Bad ID_IsBranching" & str(ID_IsBranching);
                assert ID_read1Data = x"00000000"
                    report "6 bad ID_read1Data:" & str(ID_read1Data);
                
                wait until clk = '1';
                wait until clk = '0';
    
                -- EX
                
                assert IF_PC = x"00000060"
                    report "Bad IF_PC = " & str(IF_PC);
                assert EX_ALU_ValueOut = x"00008008"
                    report "6 Bad EX_ALU_ValueOut" & str(EX_ALU_ValueOut);
                assert EX_Read1Data = x"00000000"
                    report "6 Bad EX_Read1Data" & str(EX_Read1Data);
    
                wait until clk = '1';
                wait until clk = '0';
                
                -- MEM
                assert IF_PC = x"00000064"
                    report "Bad IF_PC = " & str(IF_PC);

                -- WB stage of 5
                assert WB_WriteData = x"f0f0f0f0"
                    report "Bad WB_WriteData" & str(WB_WriteData);

                wait until clk = '1';
                wait until clk = '0';

                -- WB
                
                assert IF_PC = x"00000068"
                    report "Bad IF_PC = " & str(IF_PC);
                assert WB_WriteData = x"ffffffff"
                    report "Bad WB_WriteData" & str(WB_WriteData);
                wait until clk = '1';
                wait until clk = '0';            
            
            -- 7: sub these two values
                assert IF_PC = x"0000006c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"014b6022"
                    report "Bad IF_inst:" & str(IF_inst);
        
                wait until clk = '1';
                wait until clk = '0';            
    
            -- 8: sll the result by 1
                -- TODO: shifting doesn't actually follow the green card.
                -- rs and rt need to be switched
                assert IF_PC = x"00000070"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"01406840"
                    report "Bad IF_inst:" & str(IF_inst);
                --assert WB_WriteData = x"e1e1e1e2"
                    --report "Bad WB_WriteData" & str(WB_WriteData);
                    
                wait until clk = '1';
                wait until clk = '0';            
    
            
            -- 9: srl the result by 1
                assert IF_PC = x"00000074"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"01407042"
                    report "Bad IF_inst:" & str(IF_inst);
                    
                wait until clk = '1';
                wait until clk = '0';            
     
                --ID
                
                assert IF_PC = x"00000078"
                    report "Bad IF_PC = " & str(IF_PC);
                
                wait until clk = '1';
                wait until clk = '0';
    
                -- EX
                
                assert IF_PC = x"0000007c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert EX_ALU_ValueOut = x"78787878"
                    report "10 Bad EX_ALU_ValueOut" & str(EX_ALU_ValueOut);
                assert EX_Read1Data = x"f0f0f0f0"
                    report "10 Bad EX_Read1Data" & str(EX_Read1Data);
                assert EX_Read2Data = x"00000000"
                    report "10 Bad EX_Read2Data" & str(EX_Read2Data);
                -- writeback for sub
                assert WB_WriteData = x"f0f0f0f1"
                    report "Bad WB_WriteData" & str(WB_WriteData);
    
                wait until clk = '1';
                wait until clk = '0';
                
                -- MEM
                assert IF_PC = x"00000080"
                    report "Bad IF_PC = " & str(IF_PC);

                wait until clk = '1';
                wait until clk = '0';

                -- WB
                
                assert IF_PC = x"00000084"
                    report "Bad IF_PC = " & str(IF_PC);
                assert WB_WriteData = x"78787878"
                    report "Bad WB_WriteData" & str(WB_WriteData);
                wait until clk = '1';
                wait until clk = '0';   
                
             -- 10: j out of here
                assert IF_PC = x"00000088"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"08000040"
                    report "Bad IF_inst:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';   
    
             -- 11: ori to put a value in an address register (jump delay slot)
                assert IF_PC = x"0000008c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"340f0200"
                    report "Bad IF_inst:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';   

            -- 12: nops to make sure we are in the right place 
            --                   (and to make sure the register is ready)
                assert IF_PC = x"00000100"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
                    
                wait until clk = '1';
                wait until clk = '0';

                -- EX (for the ori)
                
                assert IF_PC = x"00000104"
                    report "Bad IF_PC = " & str(IF_PC);
    
                wait until clk = '1';
                wait until clk = '0';
                
                -- MEM
                assert IF_PC = x"00000108"
                    report "Bad IF_PC = " & str(IF_PC);

                wait until clk = '1';
                wait until clk = '0';

                -- WB
                
                assert IF_PC = x"0000010c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert WB_WriteData = x"00000200"
                    report "Bad WB_WriteData" & str(WB_WriteData);

                wait until clk = '1';
                wait until clk = '0';   

            -- 12: jr to that value (0x00000200)
                assert IF_PC = x"00000110"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"01e00008"
                    report "Bad IF_inst:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';   
    
            -- 13: nop in branch delay slot
                assert IF_PC = x"00000114"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';   

            -- 14: nop after the jump just to make sure 
            --     we arrived in the right place
                assert IF_PC = x"00000200"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
                    
                wait until clk = '1';
                wait until clk = '0';   
    
            -- 15: slt comparing r0 and r15 into r16
                assert IF_PC = x"00000204"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"000f802a"
                    report "Bad IF_inst:" & str(IF_inst);
        
                wait until clk = '1';
                wait until clk = '0';   
            
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000208"
                    report "Bad IF_PC = " & str(IF_PC);
                assert ID_Read1Data = x"00000000"
                    report "Bad ID_Read1Data = " & str(ID_Read1Data);
                assert ID_Read2Data = x"00000200"
                    report "Bad ID_Read2Data = " & str(ID_Read2Data);

                wait until clk = '1';
                wait until clk = '0';   
    
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"0000020c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert EX_ALU_ValueOut = x"00000001"
                    report "Bad EX_ALU_ValueOut = " & str(EX_ALU_ValueOut);

                wait until clk = '1';
                wait until clk = '0';   

            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000210"
                    report "Bad IF_PC = " & str(IF_PC);

                wait until clk = '1';
                wait until clk = '0';   

            -- 16: nor this with r0 to flip all the bits
                assert IF_PC = x"00000214"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00108827"
                    report "Bad IF_inst:" & str(IF_inst);
                assert WB_WriteData = x"00000001"
                    report "Bad WB_WriteData:" & str(WB_WriteData);
        
                wait until clk = '1';
                wait until clk = '0';   

            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000218"
                    report "Bad IF_PC = " & str(IF_PC);
                assert ID_Read1Data = x"00000000"
                    report "Bad ID_Read1Data = " & str(ID_Read1Data);
                assert ID_Read2Data = x"00000001"
                    report "Bad ID_Read2Data = " & str(ID_Read2Data);

                wait until clk = '1';
                wait until clk = '0';   
    
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"0000021c"
                    report "Bad IF_PC = " & str(IF_PC);

                wait until clk = '1';
                wait until clk = '0';   

            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000220"
                    report "Bad IF_PC = " & str(IF_PC);

                wait until clk = '1';
                wait until clk = '0';   

            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000224"
                    report "Bad IF_PC = " & str(IF_PC);
                assert WB_WriteData = x"fffffffe"
                    report "Bad WB_WriteData:" & str(WB_WriteData);

                wait until clk = '1';
                wait until clk = '0';   

            -- 16: jal out of here to 0x0300
                assert IF_PC = x"00000228"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"0c0000c0"
                    report "Bad IF_inst:" & str(IF_inst);
                --assert WB_WriteData = x"00000230"
                 --report "Bad WB_WriteData:" & str(WB_WriteData);
                 
                wait until clk = '1';
                wait until clk = '0';   
    
            -- nop in branch delay slot
                assert IF_PC = x"0000022c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';
                
            -- 17: nop to make sure we are in the right place
                assert IF_PC = x"00000300"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';
    
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000304"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';   
                
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000308"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';   
                
            -- 18: call a function (jal)
                assert IF_PC = x"0000030c"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"0c000100"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';   
    
            -- nop in branch delay slot
                assert IF_PC = x"00000310"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';
                
            -- nop to make sure we are in the right place
                assert IF_PC = x"00000400"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';
    
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000404"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';   
                
            -- nop to delay until I implement forwarding/stalling
                assert IF_PC = x"00000408"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';   
                
    
            -- 19: ret from function (jr)
                assert IF_PC = x"0000040c"
                    report "Bad IF_PC 1= " & str(IF_PC);
                assert IF_inst = x"03e00008"
                    report "Bad IF_inst:" & str(IF_inst);
                
                wait until clk = '1';
                wait until clk = '0';   
    
            -- nop in branch delay slot
                assert IF_PC = x"00000410"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';
    
            -- 20: nop just to check where we are
                assert IF_PC = x"00000314"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
        
                wait until clk = '1';
                wait until clk = '0';
    
    
            -- 21: beq that will fail
                assert IF_PC = x"00000318"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"10110010"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';
    
    
            -- 22: nop to make sure we didn't branch
                assert IF_PC = x"0000031c"
                    report "Bad IF_PC (should not have branched) = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
    
                wait until clk = '1';
                wait until clk = '0';
    
    
            -- 23: beq that will succeed
                assert IF_PC = x"00000320"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"1000000c"
                    report "Bad IF_inst:" & str(IF_inst);
                --assert ID_nextPC = x"00000328"
                    --report "Bad ID_nextPC:" & str(ID_nextPC);
                
                wait until clk = '1';
                wait until clk = '0';
    
    
            -- nop in branch delay slot
                assert IF_PC = x"00000324"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);

                wait until clk = '1';
                wait until clk = '0';

            -- 24: nop to see that we took the branch
                assert IF_PC = x"00000334"
                    report "Bad IF_PC = " & str(IF_PC);
                assert IF_inst = x"00000000"
                    report "Bad IF_inst:" & str(IF_inst);
    
                wait until clk = '1';
                wait until clk = '0';
            
            -- 25+ do stuff until halt
        end if;
            
        wait;
    end process run;
    end rtl;

    
