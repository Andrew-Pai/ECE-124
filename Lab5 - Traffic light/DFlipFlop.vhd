library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DFlipFlop is port (
	data_In			: in std_logic;
	clock			: in std_logic;
	rst_n			: in std_logic;
	data_Out		: out std_logic
); 
end DFlipFlop;

architecture arch of DFlipFlop is
	signal currData	:	std_logic;
begin
-- on the rising edge of the clock it outputs the input signal, or holds it otherwise
	logic: Process (rst_n, clock, data_In)
	begin
		if(rst_n = '0') THEN
			currData <= '0';
		elsif (rising_edge(clock)) THEN
			currData <= data_In;
		else
			currData <= currData;
		end if;
	end process;
	
	data_Out <= currData;
	
end architecture arch;