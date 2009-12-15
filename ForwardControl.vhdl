library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.txt_util.all;

entity ForwardControl is
    port (clk : in std_logic;
          reset : in std_logic;
          EX_MEM_rd : in std_logic_vector(4 downto 0);
          MEM_WB_rd : in std_logic_vector(4 downto 0);
          ID_EX_rs : in std_logic_vector(4 downto 0);
          ID_EX_rt : in std_logic_vector(4 downto 0);

          ForwardA : out std_logic_vector(1 downto 0);
          ForwardB : out std_logic_vector(1 downto 0);
    end ForwardControl;
    
    architecture rtl of ForwardControl is
    begin
    end rtl;