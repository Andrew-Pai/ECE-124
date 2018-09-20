library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InputLatch is port (
	data_in			: in std_logic;
	clear			: in std_logic;
	clk				: in std_logic;
	enable			: in std_logic;
	rst_n			: in std_logic;
	data_out		: out std_logic
); 
end InputLatch;

architecture arch of InputLatch is
signal DFF_Out	:	std_logic;
signal DFF_IN	:	std_logic;

begin
--holds the signal from either of the push buttons until the it recieves the clear signal from the statemachine
	DFF_IN <= NOT(clear) AND (data_in OR DFF_Out);

	DFF: Process (rst_n, clk,DFF_IN, enable)
	begin
		if(rst_n = '0' or clear = '1') THEN
			DFF_Out <= '0';
		elsif (rising_edge(clk) and enable = '1') THEN
			DFF_Out <= DFF_IN;
		else
			DFF_Out <= DFF_Out;
		end if;
	end process;
	data_out <= DFF_Out;
	
end architecture arch;