LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY sram_tb IS
END sram_tb;

ARCHITECTURE test OF sram_tb IS
    SIGNAL ncs, nwe, noe: STD_LOGIC;
    SIGNAL addr, data: STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    sram: ENTITY work.sram64kx8 PORT MAP(ncs, addr, data, nwe, noe);

    PROCESS BEGIN
	ncs <= '0';

	addr <= X"00000000";
	data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	nwe <= '1';
	noe <= '1';
	wait for 1 ns;
	noe <= '0';
	wait for 1 ns;
	data <= X"33333333";
	addr <= X"00000008";
	nwe <= '0';
	wait for 1 ns;
	addr <= X"00000004";
	data <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	nwe <= '1';
	noe <= '0';
	wait for 1 ns;
	wait;
    END PROCESS;
END test;
