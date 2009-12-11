library ieee;
use ieee.std_logic_1164.all;

ENTITY Control IS
    PORT(Operation: IN STD_LOGIC_VECTOR(31 DOWNTO 26);
        Func:IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        Branch,MemRead,MemWrite,RegWrite,SignExtend:OUT STD_LOGIC;
        ALUSrc,MemToReg,RegDst,Jump,ALUOp:OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END Control;
    
architecture rtl of Control is
    signal r_type: std_logic;
    signal j_type: std_logic;
    signal i_type: std_logic;
    signal branch_type: std_logic;
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
    
    begin
    
    -- define some useful stuff
        
    r_type <= not (Operation(31) or Operation(30) or Operation(29)
               or Operation(28) or Operation(27) or Operation(26));
    
    j_type <= (not Operation(31) and not Operation(30) and not Operation(29)
               and not Operation(28) and Operation(27) and Operation(26)) 
               or ( not Operation(31) and not Operation(30) and not Operation(29)
               and not Operation(28) and Operation(27) and not Operation(26));
               
    i_type <= (not r_type) and (not j_type);
               
    branch_type <= ( not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               Operation(28) and 
               not Operation(27) and 
               not Operation(26))
               or
             -- bne
             ( not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               Operation(28) and 
               not Operation(27) and 
               Operation(26))
               or
             -- j
             ( not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               not Operation(28) and 
               Operation(27) and 
               not Operation(26))
               or                
             -- jal
             ( not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               not Operation(28) and 
               Operation(27) and 
               Operation(26))
               or                
             -- jr
             ( not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               not Operation(28) and 
               not Operation(27) and 
               not Operation(26) and
               not Func(5) and
               not Func(4) and
               Func(3) and
               not Func(2) and
               not Func(1) and
               not Func(0));

   jr <= (    not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               not Operation(28) and 
               not Operation(27) and 
               not Operation(26) and
               not Func(5) and
               not Func(4) and
               Func(3) and
               not Func(2) and
               not Func(1) and
               not Func(0));

   sw <=  Operation(31) and  
          not Operation(30) and 
          Operation(29) and
          not Operation(28) and 
          Operation(27) and 
          Operation(26);
          
   lw <=  Operation(31) and 
          not Operation(30) and 
          not Operation(29) and
          not Operation(28) and 
          Operation(27) and 
          Operation(26);
          
    jal <= not Operation(31) and 
           not Operation(30) and 
           not Operation(29) and
           not Operation(28) and 
           Operation(27) and 
           Operation(26);
           
    add <= r_type and
           Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           not Func(1) and
           not Func(0);
    
    addi <= not Operation(31) and
            not Operation(30) and
            Operation(29) and
            not Operation(28) and
            not Operation(27) and 
            not Operation(26);
    
    sub <= r_type and
           Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           Func(1) and
           not Func(0);

    ori <=  not Operation(31) and
            not Operation(30) and
            Operation(29) and
            Operation(28) and
            not Operation(27) and 
            Operation(26);

    beq <=  not Operation(31) and
            not Operation(30) and
            not Operation(29) and
            Operation(28) and
            not Operation(27) and 
            not Operation(26);

    j <=    not Operation(31) and
            not Operation(30) and
            not Operation(29) and
            not Operation(28) and
            Operation(27) and 
            not Operation(26);
            
    n_or <= r_type and
           Func(5) and
           not Func(4) and
           not Func(3) and
           Func(2) and
           Func(1) and
           Func(0);
           
    slt <= r_type and
           Func(5) and
           not Func(4) and
           Func(3) and
           not Func(2) and
           Func(1) and
           not Func(0);
           
    sl_l <= r_type and
           not Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           not Func(1) and
           not Func(0);

    sr_l <= r_type and
           not Func(5) and
           not Func(4) and
           not Func(3) and
           not Func(2) and
           Func(1) and
           not Func(0);

    -- on to the real work
           
    RegDst(1) <= not Operation(31) and not Operation(30) and not Operation(29)
               and not Operation(28) and Operation(27) and Operation(26);

    RegDst(0) <= r_type 
               and not (not Operation(31) and not Operation(30) and not Operation(29)
               and not Operation(28) and Operation(27) and Operation(26));

    Branch <= branch_type;

       Jump(0) <= j_type;
       -- true when instruction is a jr
       Jump(1) <= ( not Operation(31) and 
               not Operation(30) and 
               not Operation(29) and
               not Operation(28) and 
               not Operation(27) and 
               not Operation(26) and
               not Func(5) and
               not Func(4) and
               Func(3) and
               not Func(2) and
               not Func(1) and
               not Func(0));

       -- MemRead when lw
       MemRead <= lw;
       -- MemWrite when sw
       MemWrite <= sw;

       -- 1 when lw
       MemToReg(0) <= lw;
       
       -- 1 when jal
       MemToReg(1) <= jal;
               
       -- 1 for I-type
       ALUSrc(0) <= i_type and not beq;
       -- 1 for shift operations
       ALUSrc(1) <= r_type and
             (( not Func(5) and
               not Func(4) and
               not Func(3) and
               not Func(2) and
               not Func(1) and
               not Func(0))
               or
             -- srl
             ( not Func(5) and
               not Func(4) and
               not Func(3) and
               not Func(2) and
               Func(1) and
               not Func(0)));
               
       -- true for r-type instructions (except jr)
       -- true for i-type instructions except store word
       -- not true for anything that branches
       -- true for jal
       RegWrite <= (r_type or i_type or jal) and not jr and not sw and not (branch_type and not jal);

       ALUOp(1) <= not (add or addi or sub or lw or sw or branch_type);
       ALUOp(0) <= sub or ori;

       SignExtend <= not ori;
       
   end rtl;

-- RegDst 00 => from Rt 
--        01 => from Rd (r-type)
--        00 => PC