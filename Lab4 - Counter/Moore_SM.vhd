library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Moore_SM IS Port
(
 clk_input, rst_n										: IN std_logic;
 target													: IN std_logic_vector(3 downto 0);
 cur_val													: OUT std_logic_vector(3 downto 0);
 cnt														: OUT std_logic_vector (2 downto 0)
 );
END ENTITY;
Architecture MSM of Moore_SM is
component compx4 is
	port(
		inputA		: in std_logic_vector(3 downto 0);--Takes in current temp
		inputB		: in std_logic_vector(3 downto 0);--Takes in desired temp
		output		: out std_logic_vector(2 downto 0)--Groups the output of the comparator (A>B,A=B,A<B)
	);
end component compx4;
 
 
 

 
  
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15); -- list all the STATES

 
 SIGNAL current_state, next_state	:  STATE_NAMES;   -- signals of type STATE_NAMES
 Signal compareRes:		std_logic_vector (2 downto 0);--Groups the output of the comparator (A>B,A=B,A<B)
 Signal decoded:		std_logic_vector (3 downto 0);
 

BEGIN

 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 
-- REGISTER LOGIC PROCESS
-- add clock and any related inputs for state machine register section into Sensitivity List 

Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= S0;
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	ELSE
		current_state <= current_state;
	END IF;
END PROCESS;	



-- TRANSTION LOGIC PROCESS (to be combinational only)
-- add all transition inputs for state machine into Transition section Sensitivity List 
-- make sure that all conditional statement options are complete otherwise VHDL will infer LATCHES.
INST1: compx4 port map(target(3 downto 0),decoded(3 downto 0),compareRes(2 downto 0)); --target>decoded, target=decoded, target< decoded: determine if we need to count down, up, or hold
Transition_Section: PROCESS (target(3 downto 0), current_state) 

BEGIN

-- Based off current state and target state, looks at result of the comparator:
--If current > target, decrement states until target is reached
--If current == target, state remains the same
--If current < target, incrememnt until target is reached


     CASE current_state IS
         WHEN S0 =>		
            IF (compareRes ="100") THEN 
               next_state <= S1;
            ELSE 
               next_state <= S0;
            END IF;
				
         WHEN S1 =>
            IF ( compareRes ="100") THEN 
               next_state <= S2;
            ELSIF( compareRes="001") THEN
					next_State <= S0;
				ELSE
               next_state <= S1;
            END IF;	

         WHEN S2 =>
            IF ( compareRes ="100") THEN 
               next_state <= S3;
            ELSIF( compareRes="001") THEN
					next_State <= S1;
				ELSE
               next_state <= S2;
            END IF;			

         WHEN S3 =>
            IF ( compareRes ="100") THEN 
               next_state <= S4;
            ELSIF( compareRes="001") THEN
					next_State <= S2;
				ELSE
               next_state <= S3;
            END IF;			

         WHEN S4 =>
            IF ( compareRes ="100") THEN 
               next_state <= S5;
            ELSIF( compareRes="001") THEN
					next_State <= S3;
				ELSE
               next_state <= S4;
            END IF;			
         WHEN S5 =>
            IF ( compareRes ="100") THEN 
               next_state <= S6;
            ELSIF( compareRes="001") THEN
					next_State <= S4;
				ELSE
               next_state <= S5;
            END IF;			
         WHEN S6 =>
            IF ( compareRes ="100") THEN 
               next_state <= S7;
            ELSIF( compareRes="001") THEN
					next_State <= S5;
				ELSE
               next_state <= S6;
            END IF;			
         WHEN S7 =>
            IF ( compareRes ="100") THEN 
               next_state <= S8;
            ELSIF( compareRes="001") THEN
					next_State <= S6;
				ELSE
               next_state <= S7;
            END IF;			
         WHEN S8 =>
            IF ( compareRes ="100") THEN 
               next_state <= S9;
            ELSIF( compareRes="001") THEN
					next_State <= S7;
				ELSE
               next_state <= S8;
            END IF;			
         WHEN S9 =>
            IF ( compareRes ="100") THEN 
               next_state <= S10;
            ELSIF( compareRes="001") THEN
					next_State <= S8;
				ELSE
               next_state <= S9;
            END IF;			
         WHEN S10 =>
            IF ( compareRes ="100") THEN 
               next_state <= S11;
            ELSIF( compareRes="001") THEN
					next_State <= S9;
				ELSE
               next_state <= S10;
            END IF;			
         WHEN S11 =>
            IF ( compareRes ="100") THEN 
               next_state <= S12;
            ELSIF( compareRes="001") THEN
					next_State <= S10;
				ELSE
               next_state <= S11;
            END IF;			
         WHEN S12 =>
            IF ( compareRes ="100") THEN 
               next_state <= S13;
            ELSIF( compareRes="001") THEN
					next_State <= S11;
				ELSE
               next_state <= S12;
            END IF;			
         WHEN S13 =>
            IF ( compareRes ="100") THEN 
               next_state <= S14;
            ELSIF( compareRes="001") THEN
					next_State <= S12;
				ELSE
               next_state <= S13;
            END IF;			
         WHEN S14 =>
            IF ( compareRes ="100") THEN 
               next_state <= S15;
            ELSIF( compareRes="001") THEN
					next_State <= S13;
				ELSE
               next_state <= S14;
            END IF;			
         WHEN S15 =>
            IF ( compareRes ="001") THEN 
               next_state <= S14;
				ELSE
               next_state <= S15;
            END IF;						
         WHEN others =>
               next_state <= S0;

		END CASE;
 END PROCESS;
 
 cnt<=compareRes;--Output the comparator result to be displayed on LEDs
 
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
	"1100" when S12,
	"1101" when S13,
	"1110" when S14,
	"1111" when S15,
	"0000" when others;

cur_val <= decoded;--Output the current state to be displayed on the 7 segment

END ARCHITECTURE MSM;
