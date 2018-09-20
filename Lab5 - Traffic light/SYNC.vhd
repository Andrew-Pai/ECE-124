library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Sync is port (
	data_in			: in std_logic;
	clk				: in std_logic;
	rst_n			: in std_logic;
	data_out		: out std_logic
); 
end Sync;

architecture arch of Sync is
	component DFlipFlop is port (
		data_In			: in std_logic;
		clock			: in std_logic;
		rst_n			: in std_logic;
		data_Out		: out std_logic
	); 
	end component;
signal DFF_Out	:	std_logic;

begin
--prevents a metastable state from occuring by caputing the last recorded state from the first d-flipflop nd outputting that from the econd dflip flop
	INST1: DFlipFlop port map (data_In,clk,rst_n,DFF_Out);
	INST2: DFlipFlop port map( DFF_Out,clk,rst_n,data_Out);
end architecture arch;