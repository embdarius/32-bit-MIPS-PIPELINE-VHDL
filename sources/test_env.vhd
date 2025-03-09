
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(31 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(31 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(31 downto 0);
           PCp4 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component ID
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           RegWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0);
           
           reg_WriteAddress : in STD_LOGIC_VECTOR(4 downto 0)
           );
end component;

component UC
    Port ( Instr : in STD_LOGIC_VECTOR(5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component EX is
    Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC);
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal Instruction, PCp4, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(31 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(31 downto 0);
signal func : STD_LOGIC_VECTOR(5 downto 0);
signal sa : STD_LOGIC_VECTOR(4 downto 0);
signal zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(31 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
signal id_wa_int_signal : STD_LOGIC_VECTOR(4 downto 0);
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);


signal REG_IF_ID : std_logic_vector(63 downto 0);  -- PC+4(32 bits ) and Instruction(32 bits);
signal PCp4_IF_ID : std_logic_vector(31 downto 0);
signal Instruction_IF_ID : std_logic_vector(31 downto 0);

signal REG_ID_EX : std_logic_vector(157 downto 0);
signal PCp4_ID_EX : std_logic_vector(31 downto 0);
signal EXT_Imm_ID_EX : std_logic_vector(31 downto 0);
signal RD1_ID_EX : std_logic_vector(31 downto 0);
signal RD2_ID_EX : std_logic_vector(31 downto 0);
signal sa_ID_EX : std_logic_vector(4 downto 0);
signal func_ID_EX : std_logic_vector(5 downto 0);
--MUX
signal MUXOutput_ID_EX : std_logic_vector(4 downto 0);
signal RegDst_ID_EX : std_logic;

signal REG_EX_MEM : std_logic_vector(105 downto 0);
signal MemWrite_REG_EX_MEM : std_logic;
signal Branch_REG_EX_MEM : std_logic;
signal ALURes_REG_EX_MEM : std_logic_vector(31 downto 0);
signal PCSrc_EX_MEM : std_logic;

signal REG_MEM_WB : std_logic_vector(70 downto 0);
signal WriteAddress_MEM_WB : std_logic_vector(4 downto 0);
signal RegWrite_MEM_WB : std_logic;
--MUX
signal MemToReg_MEM_WB : std_logic;
signal MUXOutput_MEM_WB : std_logic_vector(31 downto 0);

begin

    monopulse : MPG port map(en, btn(0), clk);
    
    -- main units
    inst_IFetch : IFetch port map(clk, btn(1), en, BranchAddress, JumpAddress, Jump, PCSrc_EX_MEM, Instruction, PCp4);
    inst_ID : ID port map(clk, en, Instruction_IF_ID(25 downto 0), WD, RegWrite_MEM_WB, RegDst, ExtOp, RD1, RD2, Ext_imm, func, sa, WriteAddress_MEM_WB);
    inst_UC : UC port map(Instruction_IF_ID(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    inst_EX : EX port map(PCp4_ID_EX, RD1_ID_EX, RD2_ID_EX, EXT_Imm_ID_EX, func_ID_EX, sa_ID_EX, ALUSrc, ALUOp, BranchAddress, ALURes, Zero);
    inst_MEM : MEM port map(clk, en, ALURes_REG_EX_MEM, RD2_ID_EX, MemWrite_REG_EX_MEM, MemData, ALURes1);

    -- Write-Back unit 
    WD <= MUXOutput_MEM_WB;   

    -- branch control
    PCSrc_EX_MEM <= REG_EX_MEM(2) AND REG_EX_MEM(36); --Branch AND Zero  
    PCSrc <= Zero and Branch;

    -- jump address
    JumpAddress <= PCp4_IF_ID(31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";
    
    --MUX OF ID_EX REGISTER
    RegDst_ID_EX <= REG_ID_EX(4);
    MUXOutput_ID_EX <= REG_ID_EX(152 downto 148) when RegDst_ID_EX = '0' else REG_ID_EX(157 downto 153);
    
    --MUX OF MEM/WB REGISTER
    MemToReg_MEM_WB <= REG_MEM_WB(1);
    MUXOutput_MEM_WB <= REG_MEM_WB(33 downto 2) when MemToReg_MEM_WB = '1' else REG_MEM_WB(65 downto 34);
    
    
    REG_IF_ID_process : process(clk)
    begin
        if(falling_edge(clk) and en = '1') then
            REG_IF_ID(31 downto 0) <= PCp4;  --PC + 4 
            REG_IF_ID(63 downto 32) <= Instruction;   -- Instruction
            
            
            PCp4_IF_ID <= PCp4;
            Instruction_IF_ID <= Instruction;  
        end if;
    end process REG_IF_ID_process;
  
    REG_ID_EX_process : process(clk)
    begin
        if(falling_edge(clk) and en = '1') then
            REG_ID_EX(1 downto 0) <= MemToReg & RegWrite;       -- WB 
            REG_ID_EX(3 downto 2) <= MemWrite & Branch;         --M
            REG_ID_EX(8 downto 4) <= ALUOp & ALUSrc & RegDst;   --EX 
            REG_ID_EX(40 downto 9) <= PCp4_IF_ID;     -- PC+4 FROM IF/ID REG 
            REG_ID_EX(72 downto 41) <= RD1;
            REG_ID_EX(104 downto 73) <= RD2;
            REG_ID_EX(109 downto 105) <= Instruction_IF_ID(10 downto 6);  
            REG_ID_EX(141 downto 110) <= EXT_Imm;  --nu sunt 100% sigur 
            REG_ID_EX(147 downto 142)  <= Instruction_IF_ID(5 downto 0);
            REG_ID_EX(152 downto 148) <= Instruction_IF_ID(20 downto 16);
            REG_ID_EX(157 downto 153) <= Instruction_IF_ID(15 downto 11);
            
            PCp4_ID_EX <= PCp4_IF_ID;
            EXT_Imm_ID_EX <= EXT_Imm;
            RD1_ID_EX <= RD1;
            RD2_ID_EX <= RD2;
            sa_ID_EX <= Instruction_IF_ID(10 downto 6);
            func_ID_EX <= Instruction_IF_ID(5 downto 0);
            
            --CRED CA TREBUIE SA MODIFIC INtrarile de ex Instruction, sa fie iesirea din REG_IF_ID ; 
        end if;
    end process REG_ID_EX_process;
    
    REG_EX_MEM_process : process(clk)
    begin
        if(falling_edge(clk) and en = '1') then
            REG_EX_MEM(1 downto 0) <= REG_ID_EX(1 downto 0);  --WB 
            REG_EX_MEM(3 downto 2) <= REG_ID_EX(3 downto 2);  --M
            REG_EX_MEM(35 downto 4) <=  BranchAddress;       --PCp4 + Ext_Imm from REG_ID_EX
            REG_EX_MEM(36) <= Zero;
            REG_EX_MEM(68 downto 37) <= ALURes;
            REG_EX_MEM(100 downto 69) <= RD2_ID_EX;         --RD2 from REG_ID_EX
            REG_EX_MEM(105 downto 101) <= MUXOutput_ID_EX;     --intermediary write address output from ID/EX ( ID entity ) 
            
            MemWrite_REG_EX_MEM <= REG_ID_EX(3);
            Branch_REG_EX_MEM <= REG_ID_EX(2);
            ALURes_REG_EX_MEM <= ALURes;
        end if;
    
    end process REG_EX_MEM_process;
    
    REG_MEM_WB_process : process(clk)
    begin
        if(falling_edge(clk) and en = '1') then
            REG_MEM_WB(1 downto 0) <= REG_EX_MEM(1 downto 0);   --WB
            REG_MEM_WB(33 downto 2) <= MemData;         --ReadData from DATA MEMORY ENTITY 
            REG_MEM_WB(65 downto 34) <= ALURes1;        --ALUResOut from DATA MEMORY ENTITY 
            REG_MEM_WB(70 downto 66)<= REG_EX_MEM(105 downto 101);      --intermediary write address output from EX/MEM Register 
            
            WriteAddress_MEM_WB <= REG_EX_MEM(105 downto 101);
            RegWrite_MEM_WB <= REG_MEM_WB(0);
        end if;
    end process REG_MEM_WB_process;
    
    

   -- SSD display MUX
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCp4 when "001",
                   RD1_ID_EX when "010",
                   RD2_ID_EX when "011",
                   Ext_Imm_ID_EX when "100",
                   ALURes_REG_EX_MEM when "101",
                   REG_MEM_WB(33 downto 2) when "110",  --MEMDATA FROM REG MEM_WB
                   WD when "111",
                   (others => 'X') when others; 

    display : SSD port map(clk, digits, an, cat);
    
    -- main controls on the leds
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;