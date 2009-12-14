library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity InstructionDecode is
    port (clk : in std_logic;
          reset : in std_logic;
          PC, PC_4 : in std_logic_vector(31 downto 0);
          inst_data : in std_logic_vector(31 downto 0);
          writeReg : in std_logic_vector(4 downto 0);
          writeData : in std_logic_vector(31 downto 0);
          
          operation : out std_logic_vector(5 downto 0);
          rs,rt,rd : out std_logic_vector(4 downto 0);
          shift_amount : out std_logic_vector(31 downto 0);
          func : out std_logic_vector(5 downto 0);
          jump_address : out std_logic_vector(31 downto 0);
          immediate : out std_logic_vector(31 downto 0);
          immediate_signExtend : out std_logic_vector(31 downto 0);
          Read1Data, Read2Data : out std_logic_vector(31 downto 0);
          InstWriteReg : out std_logic_vector(4 downto 0);
          NextPC : out std_logic_vector(31 downto 0);
          Branch,MemRead,MemWrite,RegWrite,SignExtend,Halt, IsBranching:OUT STD_LOGIC;
          ALUSrc,MemToReg,RegDst,Jump,ALUOp:OUT STD_LOGIC_VECTOR(1 DOWNTO 0));

    end InstructionDecode;
    
    architecture rtl of InstructionDecode is
        signal rf_reg1, rf_reg2, rf_writeReg : std_logic_vector(4 downto 0);
        signal rf_WE : std_logic;
        signal Branch_i, Equal, isBranching_i : std_logic;
        signal Jump_i : std_logic_vector(1 downto 0);
        signal rs_i, rt_i, rd_i : std_logic_vector(4 downto 0);
        signal regdst_i : STD_LOGIC_VECTOR(1 DOWNTO 0);
        signal read1Data_i, read2Data_i : std_logic_vector(31 downto 0);
        signal immediate_signExtend_i : std_logic_vector(31 downto 0);
        signal jump_address_i : std_logic_vector(31 downto 0);

        signal PC_branchDst_adder_in: std_logic_vector(31 downto 0);
        signal PC_branchDst_adder_ci : std_logic;
        signal PC_branchDst_adder_out : std_logic_vector(31 downto 0);
        signal PC_branchDst_adder_co : std_logic;
        signal PC_branchDst_out : std_logic_vector(31 downto 0);
        signal PC_mux_in: std_logic_vector(127 downto 0);
        signal PC_mux_sel: std_logic_vector(1 downto 0);
        signal PC_mux_out: std_logic_vector(31 downto 0);        
    begin
            -- break up intruction instruction
                operation <= inst_data(31 downto 26);
                rs_i <= inst_data(25 downto 21);
                rs <= rs_i;
                rt_i <= inst_data(20 downto 16);
                rt <= rt_i;
                rd_i <= inst_data(15 downto 11);
                rd <= rd_i;
                shift_amount(31 downto 5) <= "000000000000000000000000000";
                shift_amount(4 downto 0) <= inst_data(10 downto 6);
                func <= inst_data(5 downto 0);
                jump_address_i(31 downto 28) <= PC(31 downto 28);
                jump_address_i(27 downto 2) <= inst_data(25 downto 0);
                jump_address_i(1 downto 0) <= "00";
                jump_address <= jump_address_i;
    
                immediate(31 downto 16) <= x"0000";
                immediate(15 downto 0) <= inst_data(15 downto 0);
                GEN_signExtend: for n in 31 downto 16 generate
                    immediate_signExtend(n) <= inst_data(15);
                    immediate_signExtend_i(n) <= inst_data(15);
                end generate GEN_signExtend;
                immediate_signExtend(15 downto 0) <= inst_data(15 downto 0);
                immediate_signExtend_i(15 downto 0) <= inst_data(15 downto 0);
                
            -- connect halt
                halt <= not (inst_data(31) and inst_data (30) and inst_data(29) and 
                             inst_data(28) and inst_data (27) and inst_data(26));

            -- Register File
                register_file: entity work.RegFile(rtl)
                    port map (rs_i, rt_i, writeReg, rf_WE, clk,                       
                              writeData, read1Data_i, read2Data_i);
                              
                RegWrite <= rf_WE;
                
                read1Data <= read1Data_i;
                read2Data <= read2Data_i;
        
            -- Control
                control: entity work.Control(rtl)
                    port map (inst_data(31 downto 26), inst_data(5 downto 0),
                              Branch_i,MemRead,MemWrite,
                              rf_WE,SignExtend,
                              ALUSrc,MemToReg,RegDst_i,
                              Jump_i,ALUOp);
                              
            Branch <= Branch_i;
            RegDst <= RegDst_i;
            Jump <= Jump_i;
                              
            -- beq comparator
                comparator: entity work.comparator(rtl)
                    port map (read1Data_i, read2Data_i, equal);
                    
            IsBranching_i <= equal and Branch_i;
            IsBranching <= equal and Branch_i;

            -- writeReg_mux - selects which register should be written to
            GEN_writeReg_mux: for n in 4 downto 0 generate
                writeReg_mux: entity work.mux4to1_indiv(rtl)
                    port map(rt_i(n),
                             rd_i(n),
                             '1', -- R31 for JAL
                             'X',
                             RegDst_i(0),
                             RegDst_i(1),
                             InstWriteReg(n));
            end generate GEN_writeReg_mux;
            
            GEN_NextPC: for n in 0 to 31 generate
                NextPC(n) <= reset and PC_mux_out(n);
            end generate GEN_NextPC;

            -- PC_branchdst_adder
                PC_branchDst_adder: entity work.adder32(rtl)
                    port map(PC_4, immediate_signExtend_i, --TODO: should be PC_4
                             -- carry in is 0
                             '0',
                             PC_branchDst_adder_out,
                             PC_branchDst_adder_co);                    
            
            -- PC_branch_dst mux (either PC+4 or branch location)
            GEN_branchDst_mux: for n in 0 to 31 generate
                PC_branch_dst_adder: entity work.mux2to1_indiv(rtl)
                    port map(PC_4(n), 
                             PC_branchDst_adder_out(n),
                             isBranching_i,
                             PC_branchDst_out(n));
            end generate GEN_branchDst_mux;                         
            
            -- PC in mux - selects the input to the PC
                -- options are PC+4 normally, imm_pc_final on branch, or 0x00000000 for reset
                GEN_PC_mux: for n in 0 to 31 generate
                    PC_mux: entity work.mux4to1_indiv(rtl)
                        -- zero unless reset is high
                        port map(PC_branchDst_out(n), jump_address_i(n),
                                 read1Data_i(n), '0',
                                 Jump_i(0),
                                 Jump_i(1),
                                 PC_mux_out(n));
                end generate GEN_PC_mux;
            
    end rtl;