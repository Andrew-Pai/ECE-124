library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TLU is
	port(
	
		systemState		:in std_logic_vector(2 downto 0);--Input from the comparator (A>B,A=B,A<B)
		button	:in std_logic_vector(3 downto 0);--Input from push buttons: 3(vacation mode), 2(Front door), 1(window), 0(back door)
		leds		:out std_logic_vector(7 downto 0) --0(furnace on), 1(system at temp, 2(A/C on), 3 (blower on), 4-6(doors and windows), 7 (vacation)
		
	);
end entity TLU;

architecture temp of TLU is
	--input signal will concat the systemState and button input signal
	signal input		: std_logic_vector (6 downto 0);
	
	begin
	input <= systemState & button; --concat the comparator output and button states together
	with input select
		leds <= "00001100" when "1000000", --current > desired
					"00000010" when "0100000", -- current = desired
					"00001001" when "0010000", --current < desired
					"10001100" when "1001000", --current > desired on vacation
					"10000010" when "0101000", -- current = desired on vacation
					"10001001" when "0011000", --current < desired on vacation
					button(3 downto 0) & "00"&systemState(1) & '0' when others;--If any of the doors or window are open, then the furnace, AC, and blower will be off
					--Takes buttons for door/window and vacation and directly maps to leds (7 down to 4) if any of them are pressed.
					--If current temp = desired temp, it directly maps to LED as well
		
		
end architecture temp;