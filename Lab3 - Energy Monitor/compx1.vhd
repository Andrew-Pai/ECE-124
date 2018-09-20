library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity compx1 is
	port(
		A		:in std_logic;--bit being compared
		B		:in std_logic;--other bit being compared
		output		:out std_logic_vector(2 downto 0) --(A>B,A=B,A<B)
	);
end entity compx1;

architecture compare of compx1 is
	begin
		output(2) <= A AND NOT(B);--If A is 1 and B is 0 then A>B
		output(1) <= (NOT(A) AND NOT(B)) OR(A AND B);--if A and B are both 1 or both 0 then A=B
		output(0) <= NOT(A) AND B;--IF B is 1 and A is 0 then A<B
end architecture compare;