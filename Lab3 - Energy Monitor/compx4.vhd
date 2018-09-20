library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity compx4 is
	port(
		inputA		: in std_logic_vector(3 downto 0);--Takes in current temp
		inputB		: in std_logic_vector(3 downto 0);--Takes in desired temp
		output		: out std_logic_vector(2 downto 0)--Groups the output of the comparator (A>B,A=B,A<B)
	);
end entity compx4;

architecture compare of compx4 is
--4 Bit comparator uses 1 bit comparators
	component compx1 port(
		A		:in std_logic;
		B		:in std_logic;
		output		:out std_logic_vector(2 downto 0) --(A>B,A=B,A<B)
	);
	end component;
	--3 is 4th bit, 2  is 3rd bit, 1 is 2nd bit, and 0 is 1st bit.
	signal A3B3		: std_logic_vector (2 downto 0);
	signal A2B2		: std_logic_vector (2 downto 0);
	signal A1B1		: std_logic_vector (2 downto 0);
	signal A0B0		: std_logic_vector (2 downto 0);
	
begin
	--Create 4 instances of the 1 bit comparator to compare each bit of the input
	INST1: compx1 port map (inputA(3),inputB(3),A3B3(2 downto 0));--Compares 4th bit
	INST2: compx1 port map (inputA(2),inputB(2),A2B2(2 downto 0));--Compares 3rd bit
	INST3: compx1 port map (inputA(1),inputB(1),A1B1(2 downto 0));--Compares 2nd bit
	INST4: compx1 port map (inputA(0),inputB(0),A0B0(2 downto 0));--Compares 1st bit
	--output(2) is A>B, output(1) is A=B, output(0) is A<B
	--(2) is A#>B#, (1) is A#=B#, (0) is A#<B# < From the 1 bit comparator
	
	output(2) <= A3B3(2) OR (A2B2(2) AND A3B3(1)) OR (A1B1(2)AND A3B3(1) AND A2B2(1) ) OR (A0B0(2)AND A3B3(1) AND A2B2(1)AND A1B1(1));--C3 +C2B3+ C1B3B2+ C0B3B2B1
	
	output(1) <= A3B3(1) AND A2B2(1) AND A1B1(1) AND A0B0(1);--B3B2B1B0 
	output(0) <= A3B3(0) OR (A2B2(0) AND A3B3(1)) OR (A1B1(0)AND A3B3(1) AND A2B2(1) ) OR (A0B0(0)AND A3B3(1) AND A2B2(1)AND A1B1(1));--A3 +A2B3+ A1B3B2+ A0B3B2B1
	
end compare;	