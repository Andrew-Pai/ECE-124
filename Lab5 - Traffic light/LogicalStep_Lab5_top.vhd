
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab5_top IS
   PORT
	(
   clkin_50		: in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb				: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab5_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab5_top IS


   component cycle_generator port (
          clkin      		: in  std_logic;
			 rst_n				: in  std_logic;
			 modulo 				: in  integer;	
			 strobe_out			: out	std_logic;
			 full_cycle_out	: out std_logic
  );
   end component;
	
   component segment7_mux port (
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	
			 DIN1 		: in  std_logic_vector(6 downto 0);
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );		
   end component;
	
	component Moore_SM IS Port
	(
		enable,rst_n, clk		: IN std_logic;
		night,reduced			: IN std_logic;--night mode and reduced systems mode
		EW_button, NS_button	:	IN std_logic;
		EW_clear, NS_clear	: out std_logic;
		cur_val		: out std_logic_vector(3 downto 0)
	); 
	end component;
	
	component Decoder is port (
		state			: in std_logic_vector(3 downto 0);
		clken5			: in std_logic;
		clken1		: in std_logic;
		NS_Decoded	: out std_logic_vector(6 downto 0);
		EW_Decoded	: out std_logic_vector(6 downto 0)
	); 
	end component;

	component Sync is port (
	data_in			: in std_logic;
	clk				: in std_logic;
	rst_n			: in std_logic;
	data_out		: out std_logic
	); 
	end component;
	
	component InputLatch is port (
	data_in			: in std_logic;
	clear			: in std_logic;
	clk				: in std_logic;
	enable			: in std_logic;
	rst_n			: in std_logic;
	data_out		: out std_logic
	); 
	end component;
	
----------------------------------------------------------------------------------------------------
	CONSTANT	SIM							:  boolean :=FALSE;

	CONSTANT CNTR1_modulo				: 	integer := 25000000;    	-- modulo count for 1Hz cycle generator 1 with 50Mhz clocking input
   CONSTANT CNTR2_modulo				: 	integer := 5000000;    	-- modulo count for 5Hz cycle generator 2 with 50Mhz clocking input
   CONSTANT CNTR1_modulo_sim			: 	integer := 199;   			-- modulo count for cycle generator 1 during simulation
   CONSTANT CNTR2_modulo_sim			: 	integer :=  39;   			-- modulo count for cycle generator 2 during simulation
	
   SIGNAL CNTR1_modulo_value			: 	integer ;   					-- modulo count for cycle generator 1 
   SIGNAL CNTR2_modulo_value			: 	integer ;   					-- modulo count for cycle generator 2 

   SIGNAL clken1,clken2					:  STD_LOGIC; 						-- clock enables 1 & 2

	SIGNAL strobe1, strobe2				:  std_logic;						-- strobes 1 & 2 with each one being 50% Duty Cycle
	SIGNAL NS_clear, EW_clear			: std_logic;
	SIGNAL syncInput1, syncInput2		: 	std_logic;
	SIGNAL pbOut1, pbOut2				:std_logic;
	SIGNAL cur_state						:std_logic_vector(3 downto 0);--Holds current state output from Moore_SM
	SIGNAL seg7_A, seg7_B				:  STD_LOGIC_VECTOR(6 downto 0); -- signals for inputs into seg7_mux.
	SIGNAL pb_bar0, pb_bar1				:std_logic;
	SIGNAL night, reduced				:std_logic;

	
BEGIN
----------------------------------------------------------------------------------------------------


MODULO_1_SELECTION:	CnTR1_modulo_value <= CNTR1_modulo when SIM = FALSE else CNTR1_modulo_sim; 

MODULO_2_SELECTION:	CNTR2_modulo_value <= CNTR2_modulo when SIM = FALSE else CNTR2_modulo_sim; 
						


----------------------------------------------------------------------------------------------------
-- Component Hook-up:					
pb_bar0 <= NOT(pb(0));
pb_bar1 <=NOT(pb(1));
--1 Hz and 5 Hz cycle generators
GEN1: 	cycle_generator port map(clkin_50, rst_n, CNTR1_modulo_value, strobe1, clken1);	
GEN2: 	cycle_generator port map(clkin_50, rst_n, CNTR2_modulo_value, strobe2, clken2);	

--push button inputs
INST1: Sync port map(pb_bar0,clkin_50,rst_n,syncInput1);
--saves the last pb input until cleared
INST2: InputLatch port map(syncInput1, EW_clear, clkin_50, clken2,rst_n,pbOut1);--ADD CLEAR FROM MOORE

--same but for pb[1]
INST3: Sync port map(pb_bar1,clkin_50,rst_n,syncInput2);
INST4: InputLatch port map(syncInput2, NS_clear, clkin_50, clken2,rst_n,pbOut2);--ADD CLEAR FROM MOORE

--synchronizes the switch input with the clock
INST5: Sync port map(sw(0),clkin_50,rst_n,night );
INST6: Sync port map(sw(1),clkin_50,rst_n, reduced);

--instantiate the moore_sm, the decoder, and the seven segment display
INST7: Moore_SM port map(clken1,rst_n, clkin_50, night, reduced, pbOut1,pbOut2,EW_clear, NS_clear, cur_state);--Takes input full-cycle 1 Hz clock so the Moore_SM updates every 1 second
INST8: Decoder port map (cur_state,strobe2,strobe1, seg7_A,seg7_B);--Takes the current state from the Moore_SM to decode into the appropriate light signal
INST9: segment7_mux port map (clkin_50, seg7_B,seg7_A,seg7_data, seg7_char2, seg7_char1);
	
leds(1 downto 0) <= Strobe1 & Strobe2;
--leds(3 downto 2) <= clken1 & clken2;
leds(7) <= pbOut1 OR pbOut2;
leds(6) <= night OR reduced;
leds(5 downto 2) <= cur_state;



END SimpleCircuit;
