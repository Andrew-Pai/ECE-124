
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50		: in	std_logic;
	rst_n			: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

Component Moore_SM IS Port
(
 clk_input, rst_n										: IN std_logic; 
 target													: IN std_logic_vector(3 downto 0); --target number value
 cur_val													: OUT std_logic_vector(3 downto 0); --current state value
 cnt														: OUT std_logic_vector (2 downto 0) --comparator output
 );
END Component;
component segment7_mux is
   port (
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	
			 DIN1 		: in  std_logic_vector(6 downto 0);
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
        );
end component segment7_mux;

component SevenSegment is port (
   
   hex	   :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   
   sevenseg :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end component SevenSegment;


	
----------------------------------------------------------------------------------------------------
	CONSTANT	SIM							:  boolean := FALSE; 	-- set to TRUE for simulation runs otherwise keep at 0.
   CONSTANT CLK_DIV_SIZE				: 	INTEGER := 24;    -- size of vectors for the counters

   SIGNAL 	Main_CLK						:  STD_LOGIC; 			-- main clock to drive sequencing of State Machine

	SIGNAL 	bin_counter					:  UNSIGNED(CLK_DIV_SIZE-1 downto 0); -- := to_unsigned(0,CLK_DIV_SIZE); -- reset binary counter to zero
	
	SIGNAL	Simple_States 				: std_logic_vector(3 downto 0); --states for shift register
	SIGNAL	Left0_Right1				: std_logic; --direction of shift register

	SIGNAL	cur_val						:std_logic_vector(3 downto 0); -- current state value
	SIGNAL	compare_result				:std_logic_vector(2 downto 0); -- result of comparator(XXX) target>decoded, target=decoded, target< decoded
	
	SIGNAL	seg7_target					:std_logic_vector(6 downto 0); --decoded target hex
	SIGNAL	seg7_curr					:std_logic_vector(6 downto 0); --decoded current number hex
----------------------------------------------------------------------------------------------------
BEGIN

-- CLOCKING GENERATOR WHICH DIVIDES THE INPUT CLOCK DOWN TO A LOWER FREQUENCY

BinCLK: PROCESS(clkin_50, rst_n) is
   BEGIN
		IF (rising_edge(clkin_50)) THEN -- binary counter increments on rising clock edge
         bin_counter <= bin_counter + 1;
      END IF;
   END PROCESS;

Clock_Source:
				Main_Clk <= 
				clkin_50 when sim = TRUE else				-- for simulations only
				std_logic(bin_counter(23));								-- for real FPGA operation
					
---------------------------------------------------------------------------------------------------


leds(3) <= Main_clk; --set led(3) to flash with the clock
leds(2 downto 0) <= compare_result(2 downto 0); --set leds to show comparator result
Inst1: Moore_SM port map(Main_clk, rst_n,sw(3 downto 0), cur_val(3 downto 0),compare_result(2 downto 0)); --instantiate the MooreSM


INST2: SevenSegment port map(cur_val(3 downto 0), seg7_curr(6 downto 0)); --convert the output of the state machine to decoded 7 bit
INST3: SevenSegment port map(sw(3 downto 0), seg7_target(6 downto 0)); --convert the target input to 7 bit
Inst4: segment7_mux port map(clkin_50, seg7_curr(6 downto 0), seg7_target(6 downto 0),seg7_data(6 downto 0),  seg7_char1, seg7_char2); --display numbers


Left0_Right1	<=	pb(0);
leds(7 downto 4)	<=	Simple_States;

process (Main_Clk, rst_n) is
begin
	if(rst_n='0') then
		Simple_States	<=	"1000";
	elsif (rising_edge(Main_clk)) then
		if(Left0_Right1 = '1') then
			Simple_States (3 downto 0) <= Simple_States(0) & Simple_States(3 downto 1);
		else
			Simple_States(3 downto 0) <= Simple_States(2 downto 0) & Simple_States(3);
		end if;
	end if;
end process;


END SimpleCircuit;
