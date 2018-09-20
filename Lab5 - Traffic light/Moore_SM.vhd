library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Moore_SM IS Port
(
   enable,rst_n, clk		: IN std_logic;--Enable from the 1hz clock, and clk from 50MHz clock
	night,reduced			: IN std_logic;--night mode and reduced systems mode
	EW_button, NS_button	: IN std_logic;
	EW_clear, NS_clear	: out std_logic;
	cur_val		: out std_logic_vector(3 downto 0)
); 
end Moore_SM;


Architecture MSM of Moore_SM is


 
  
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17); -- list all the STATES

 
 SIGNAL current_state, next_state	:  STATE_NAMES;   -- signals of type STATE_NAMES
 Signal compareRes:		std_logic_vector (2 downto 0);--Groups the output of the comparator (A>B,A=B,A<B)
 Signal decoded:		std_logic_vector (3 downto 0);
 

BEGIN

 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 
-- REGISTER LOGIC PROCESS
-- add clock and any related inputs for state machine register section into Sensitivity List 

Register_Section: PROCESS ( rst_n, clk,enable, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= S0;
	ELSIF( rising_edge(clk) and enable = '1') THEN
		current_state <= next_State;
	ELSE
		current_state <= current_state;
	END IF;
END PROCESS;	



-- TRANSTION LOGIC PROCESS (to be combinational only)
-- add all transition inputs for state machine into Transition section Sensitivity List 
-- make sure that all conditional statement options are complete otherwise VHDL will infer LATCHES.
--INST1: compx4 port map(target(3 downto 0),decoded(3 downto 0),compareRes(2 downto 0)); --target>decoded, target=decoded, target< decoded: determine if we need to count down, up, or hold



Transition_Section: PROCESS (current_state,enable) 
BEGIN
-- increments everystate when the clken1 is high
--	when pb[0] is pressed states 0 to 4 will skip forward to state 6, or  if pb[1] is pressed, states 8 to 12 skip forward to state 14
--when switch 0 or 1 are on, it either state 7 or 15 will skip to their respective hold states 16 and 17 until both switches are off
     CASE current_state IS
         WHEN S0 =>
			NS_clear <= '0';
				IF( enable = '1') THEN
					IF(EW_button = '1') THEN
						next_state <= S6;
					ELSE
						next_state <= S1;
					END IF;
				ELSE
					next_state <= S0;
				END IF;
         WHEN S1 =>
				IF( enable = '1') THEN
					IF(EW_button = '1') THEN
						next_state <= S6;
					ELSE
						next_state <= S2;
					END IF;
				ELSE
					next_state <= S1;
				END IF;
			WHEN S2 =>
				IF( enable = '1') THEN
					IF(EW_button = '1') THEN
						next_state <= S6;
					ELSE
						next_state <= S3;
					END IF;
				ELSE
					next_state <= S2;
				END IF;
			WHEN S3 =>
				IF( enable = '1') THEN
					IF(EW_button = '1') THEN
						next_state <= S6;
					ELSE
						next_state <= S4;
					END IF;
				ELSE
					next_state <= S3;
				END IF;
			WHEN S4 =>
				IF( enable = '1') THEN
					IF(EW_button = '1') THEN
						next_state <= S6;
					ELSE
						next_state <= S5;
					END IF;
				ELSE
					next_state <= S4;
				END IF;
			WHEN S5 =>
				IF( enable = '1') THEN
					next_state <= S6;
				ELSE
					next_state <= S5;
				END IF;
			WHEN S6 =>
				IF( enable = '1') THEN
					IF(EW_button = '1') THEN
						EW_clear <= '1';
					END IF;
					next_state <= S7;
				ELSE
					next_state <= S6;
				END IF;
			WHEN S7 =>
				EW_clear <= '0';
				IF( enable = '1') THEN
					IF(reduced = '1') THEN
						next_state <= S17;
					ELSIF (night = '1') THEN
						next_state <= S16;
					ELSE
						next_state <= S8;
					END IF;
				ELSE
					next_state <= S7;
				END IF;
			WHEN S8 =>
				IF( enable = '1') THEN
					IF(NS_button = '1') THEN
						next_state <= S14;
					ELSE
						next_state <= S9;
					END IF;
				ELSE
					next_state <= S8;
				END IF;
			WHEN S9 =>
				IF( enable = '1') THEN
					IF(NS_button = '1') THEN
						next_state <= S14;
					ELSE
						next_state <= S10;
					END IF;
				ELSE
					next_state <= S9;
				END IF;
			WHEN S10 =>
				IF( enable = '1') THEN
					IF(NS_button = '1') THEN
						next_state <= S14;
					ELSE
						next_state <= S11;
					END IF;
				ELSE
					next_state <= S10;
				END IF;
			WHEN S11 =>
				IF( enable = '1') THEN
					IF(NS_button = '1') THEN
						next_state <= S14;
					ELSE
						next_state <= S12;
					END IF;
				ELSE
					next_state <= S11;
				END IF;
			WHEN S12 =>
				IF( enable = '1') THEN
					IF(NS_button = '1') THEN
						next_state <= S14;
					ELSE
						next_state <= S13;
					END IF;
				ELSE
					next_state <= S12;
				END IF;
			WHEN S13 =>
				IF( enable = '1') THEN
					next_state <= S14;
				ELSE
					next_state <= S13;
				END IF;
			WHEN S14 =>
				IF( enable = '1') THEN
					next_state <= S15;
				ELSE
					next_state <= S14;
				END IF;
			WHEN S15 =>
				IF( enable = '1') THEN
					IF(NS_button = '1') THEN
						NS_clear <= '1';
					END IF;
					IF(reduced = '1') THEN
						next_state <= S17;
					ELSIF (night = '1') THEN
						next_state <= S16;
					ELSE
						next_state <= S0;
					END IF;
				ELSE
					next_state <= S15;
				END IF;
			WHEN S16 =>
				IF(reduced = '1') THEN
					next_state <= S17;
				ELSIF(night = '0') THEN
					next_state <= S6;
				ELSE
					next_state<=S16;
				END IF;
			WHEN S17 =>	
				IF(reduced = '0') THEN
					IF(night = '1') THEN
						next_state <= S16;
					ELSE
						next_state <= S6;
					END IF;
				ELSE
					next_state <= S17;
				END IF;	
			WHEN others =>
            next_state <= S0;
		END CASE;
 END PROCESS;
 

 
 --Decoder to convert the decimal state into binary
 Decoder_Section: with Current_State select 
	decoded <= "0000" when S0,
	"0001" when S1,
	"0010" when S2,
	"0011" when S3,
	"0100" when S4,
	"0101" when S5,
	"0110" when S6,
	"0111" when S7,
	"1000" when S8,
	"1001" when S9,
	"1010" when S10,
	"1011" when S11,
	"1011" when S12,--state 12 and 13 are replaced with states 16 and 17 since the state's out put is the same.
	"1011" when S13,
	"1110" when S14,
	"1111" when S15,
	"1100" when S16,--replaces state 12
	"1101" when S17,--replaces state 13
	"0000" when others;

cur_val <= decoded;--Output the current state to be displayed on the 7 segment

END ARCHITECTURE MSM;
