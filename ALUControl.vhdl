library ieee;
use ieee.std_logic_1164.all;

ENTITY ALUControl IS
    PORT(ALUOp: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        Func: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        Operation:OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ALUControl;
    
architecture rtl of ALUControl is
    signal use_func: std_logic;
    signal jr: std_logic;
    signal sw: std_logic;
    signal lw: std_logic;
    signal jal: std_logic;
    signal add: std_logic;
    signal addi: std_logic;
    signal sub: std_logic;
    signal ori: std_logic;
    signal beq: std_logic;
    signal j: std_logic;
    signal n_or: std_logic;
    signal slt: std_logic;
    signal sl_l: std_logic;
    signal sr_l: std_logic;
    
    signal alu_add: std_logic;
    signal alu_nor: std_logic;
    signal alu_or: std_logic;
    signal alu_sl: std_logic;
    signal alu_sr: std_logic;
    signal alu_sub: std_logic;
    signal alu_slt: std_logic;
    
    begin
    
    -- define some useful stuff
    
    use_func <= ALUOp(1) and not ALUOp(0);
    
   jr <= (    use_func and 
               not Func(5) and
               not Func(4) and
               Func(3) and
               not Func(2) and
               not Func(1) and
               not Func(0));

          
    add <= use_func and
           Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           not Func(1) and
           not Func(0);
    
    sub <= use_func and
           Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           Func(1) and
           not Func(0);

    n_or <= use_func and
           Func(5) and
           not Func(4) and
           not Func(3) and
           Func(2) and
           Func(1) and
           Func(0);
           
    slt <= use_func and
           Func(5) and
           not Func(4) and
           Func(3) and
           not Func(2) and
           Func(1) and
           not Func(0);
           
    sl_l <= use_func and
           not Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           not Func(1) and
           not Func(0);

    sr_l <= use_func and
           not Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           Func(1) and
           not Func(0);

        -- ALUOp 00=add
        --       01=subtract
        --       10=func
        --       11=or

    -- ALU functions
    alu_add <= (not ALUOp(1) and not ALUOp(0)) or
               add;
    alu_nor <= n_or;
    alu_or <= ALUOp(1) and ALUOp(0);
    alu_sl <= (sl_l);
    alu_sr <= (sr_l);
    alu_sub <= (not ALUOp(1) and ALUOp(0)) or
               sub;
    alu_sr <= (sr_l);
    alu_slt <= (slt);
               
    -- on to the actual outputs
    Operation(0) <= alu_nor or alu_sr or alu_slt;
    Operation(1) <= alu_sl or alu_sr or alu_or;
    Operation(2) <= alu_sub or alu_slt or alu_or;
    
    end rtl;
