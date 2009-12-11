LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Dff IS
    PORT (D, WE, clock: IN STD_LOGIC;
	  Q, Qprime: OUT STD_LOGIC);
END Dff;

ARCHITECTURE Behavior OF Dff IS
BEGIN
    PROCESS
    BEGIN
	WAIT UNTIL clock'EVENT AND clock = '1';
	-- could also be rising_edge(clock);
	IF WE = '1' THEN
	    Q <= D AFTER 135 ps;
	    Qprime <= NOT D AFTER 135 ps;
	END IF;
    END PROCESS;
END Behavior;
