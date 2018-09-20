library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------


entity Decoder is port (
	state			: in std_logic_vector(3 downto 0);
	clken5		: in std_logic;
	clken1		: in std_logic;
	NS_Decoded	: out std_logic_vector(6 downto 0);
	EW_Decoded	: out std_logic_vector(6 downto 0)
); 
end Decoder;

architecture Behavioral of Decoder is
Signal NS : std_logic_vector(6 downto 0);
Signal NS_Strobe :std_logic_vector(6 downto 0);
Signal EW :	std_logic_vector(6 downto 0);
Signal EW_Strobe :std_logic_vector(6 downto 0);
begin



		NS_Decoded <= NS OR NS_Strobe;
		EW_Decoded <= EW OR EW_Strobe;

	--Based on the current state, set the 7 segment for NS and EW accordingly, except for the flashing state
	with state select				--GFEDCBA 
		NS 				 		 <="0001000" when "0010",    			   -- [2]      +---- a -----+
										 "0001000" when "0011",    -- [3]      |            |
										 "0001000" when "0100",    -- [4]      |            |
										 "0001000" when "0101",    -- [5]      f            b
										 "1000000" when "0110",    -- [6]      |            |
					 					 "1000000" when "0111",    -- [7]      |            |
										 "0000001" when "1000",    -- [8]      +---- g -----+
										 "0000001" when "1001",    -- [9]      |            |
										 "0000001" when "1010",    -- [A]      |            |
										 "0000001" when "1011",    -- [b]      e            c
										 "0001000" when "1100",		-- [c]      |            |
										 --							   -- [d]      |            |
										 "0000001" when "1110",    -- [E]      +---- d -----+
										 "0000001" when "1111",    -- [F]
										 "0000000" when others;    -- [ ]
	
	with state select				--GFEDCBA 
	EW		    			   <= "0000001" when "0000",   		   -- [0]
										 "0000001" when "0001",    -- [1]
										 "0000001" when "0010",    -- [2]      +---- a -----+
										 "0000001" when "0011",    -- [3]      |            |
										 "0000001" when "0100",    -- [4]      |            |
										 "0000001" when "0101",    -- [5]      f            b
										 "0000001" when "0110",    -- [6]      |            |
					 					 "0000001" when "0111",    -- [7]      |            |
										 --									   +---- g -----+
										 --						  		       |            |
										 "0001000" when "1010",    -- [A]      |            |
										 "0001000" when "1011",    -- [b]      e            c
										 "0000001" when "1100",		-- [c]      |            |
										 --						      -- [d]      |            |
										 "1000000" when "1110",    -- [E]      +---- d -----+
										 "1000000" when "1111",    -- [F]
										 "0000000" when others;    -- [ ]
	--This process is for the flashing state
	strobe: process(clken5,clken1, state) IS
	begin
	--If the clock is high then check if it's in the strobe state
	--checks the state, if it's in a state that requires strobing based off either the 5hz or the 1hz strobe depending on what the state requires
		
			IF(state = "0000" or state = "0001") THEN
				IF (clken5 = '1') THEN
					NS_Strobe <= "0001000";
				ELSE
					NS_Strobe <= "0000000";
				END IF;
			ELSIF (state = "1000" or state = "1001") THEN
				IF (clken5 = '1') THEN
					EW_Strobe<="0001000";
				ELSE
					EW_Strobe <= "0000000";
				END IF;
			ELSIF(state = "1101") THEN
				IF(clken1 = '1')THEN
					NS_Strobe <= "1000000";
					EW_Strobe<="0000001";
				ELSE
					NS_Strobe <= "0000000";
					EW_Strobe<="0000000";
				END IF;
			ELSE
				NS_Strobe <= "0000000";
				EW_Strobe<="0000000";
			END IF;
		
	end process;

end architecture Behavioral;